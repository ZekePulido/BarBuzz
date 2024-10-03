const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const app = express();
const port = 3000;

// Hardcoded JWT secret key (for learning purposes only)
const JWT_SECRET = 'your_jwt_secret'; // Replace with a secure secret

// Connect to MongoDB
mongoose.connect('mongodb+srv://BarBuzz:Upcoming1!@cluster0.fn8pr.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Middleware
app.use(bodyParser.json());
app.use(cors({ origin: '*' }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Serve images from the uploads directory

// Define User Schema
const userSchema = new mongoose.Schema({
  username: String,
  password: String,
  email: String, // New field for email
  confirmEmail: String, // New field for email confirmation
  venueAddress: String, // New field for venue address
  venueName: String, // New field for venue name
  venueDescription: String, // New field for venue description
  venueWebsite: String, // New field for venue website
  type: Number, // 1 for bar, 0 for signup
  favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Location' }],
  location: { type: mongoose.Schema.Types.ObjectId, ref: 'Location' }
});

const eventSchema = new mongoose.Schema({
  title: String,
  location: { type: mongoose.Schema.Types.ObjectId, ref: 'Location' },
  locationName: String, // Ensure this field is present
  startTime: Date,
  endTime: Date,
  tag: String, // Single tag
  description: String, // New field for event description
  image: String, // New field for event image
});

const locationSchema = new mongoose.Schema({
  location: String,
  image: String, // Path to the image
  address: String,
  description: String, // Add description field
});

const User = mongoose.model('User', userSchema);
const Event = mongoose.model('Event', eventSchema);
const Location = mongoose.model('Location', locationSchema);

// Set up multer for file uploads
const upload = multer({ 
  dest: 'uploads/', // Directory to save uploaded files
  limits: { fileSize: 5 * 1024 * 1024 }, // Limit file size to 5MB
  fileFilter: (req, file, cb) => {
    // Only accept image files
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'), false);
    }
    cb(null, true);
  }
});

// Sign Up Route
app.post('/signup', async (req, res) => {
  const { username, password, email, confirmEmail, venueAddress, venueName, venueDescription, venueWebsite, type } = req.body;
  try {
    // Basic validation
    if (email !== confirmEmail) {
      return res.status(400).send({ error: 'Emails do not match' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    let locationId;

     // Create a location only if the user type is 1
     if (type === 1) {
      const location = new Location({
        location: venueName, // Use the venue name for the location
        address: venueAddress,
        description: venueDescription,
        // Optionally include an image if provided
      });

      await location.save();
      locationId = location._id; // Store the newly created location ID
    }

    const user = new User({ 
      username, 
      password: hashedPassword, 
      email,
      confirmEmail,
      venueAddress,
      venueName,
      venueDescription,
      venueWebsite,
      type,
      location: locationId ? locationId : null,
    });
    await user.save();
    res.status(201).send({ message: 'User created successfully' });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});


// Login Route
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await User.findOne({ username });
    if (!user) return res.status(400).send({ error: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).send({ error: 'Invalid credentials' });

    const token = jwt.sign({ username: user.username }, JWT_SECRET, { expiresIn: '1h' });
    res.status(200).send({ message: 'Login successful', token, type: user.type });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Middleware to authenticate JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (token == null) return res.sendStatus(401);

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Route to get user profile
app.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) return res.status(404).send({ error: 'User not found' });

    res.status(200).send({
      username: user.username,
      nickname: user.nickname,
    });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

app.get('/bar-profile', authenticateToken, async (req, res) => {
  try {
    const bar = await User.findOne({ username: req.user.username }).populate('location');
    if (!bar) return res.status(404).send({ error: 'Bar not found' });

    if (!bar.location) return res.status(404).send({ error: 'Location not found for this bar' });

    // Fetch the events for the bar's location
    const events = await Event.find({ location: bar.location._id });

    // Convert image path to a full URL if necessary
    const eventsWithFullImageUrls = events.map(event => ({
      _id: event._id, // Include event ID
      title: event.title,
      startTime: event.startTime,
      endTime: event.endTime,
      tag: event.tag,
      description: event.description,
      image: event.image ? `http://10.0.2.2:${port}/${event.image.replace('\\', '/')}` : '',
      locationName: event.locationName,
    }));

    res.status(200).send({
      venueName: bar.venueName,
      venueAddress: bar.venueAddress,
      venueDescription: bar.venueDescription,
      locationId: bar.location._id,
      events: eventsWithFullImageUrls, // Include events in the response
    });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});


// Route to add or remove a favorite location
app.post('/favorites', authenticateToken, async (req, res) => {
  const { locationId } = req.body; // locationId should be an ObjectId

  if (!mongoose.Types.ObjectId.isValid(locationId)) {
    return res.status(400).send({ error: 'Invalid location ID' });
  }

  try {
    const user = await User.findOne({ username: req.user.username }).populate('favorites');
    if (!user) return res.status(404).send({ error: 'User not found' });

    const location = await Location.findById(locationId);
    if (!location) return res.status(404).send({ error: 'Location not found' });

    const isFavorited = user.favorites.some(fav => fav._id.equals(locationId));

    if (isFavorited) {
      user.favorites = user.favorites.filter(id => !id.equals(locationId));
    } else {
      user.favorites.push(locationId);
    }

    await user.save();
    res.status(200).send({ message: 'Favorites updated successfully', favorites: user.favorites });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get the user's favorites
app.get('/favorites', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username }).populate('favorites');
    if (!user) return res.status(404).send({ error: 'User not found' });

    res.status(200).send({ favorites: user.favorites });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to create an event with optional image upload
app.post('/events', upload.single('image'), async (req, res) => {
  const { title, location, startTime, endTime, tag, description } = req.body;
  const image = req.file ? req.file.path : '';

  try {
    // Find the location to get the name
    const loc = await Location.findById(location);
    if (!loc) {
      return res.status(404).send({ error: 'Location not found' });
    }

    const event = new Event({
      title,
      location,
      locationName: loc.location, // Save the location name
      startTime: new Date(startTime),
      endTime: new Date(endTime),
      tag, // Save the single tag
      description, // Save the description
      image, // Save the image path
    });

    await event.save();
    res.status(201).send({ message: 'Event created successfully', event });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get events
app.get('/events', async (req, res) => {
  try {
    const events = await Event.find();
    // Convert image path to a full URL if necessary
    const eventsWithFullImageUrls = events.map(event => ({
      ...event.toObject(),
      image: event.image ? `http://10.0.2.2:${port}/${event.image.replace('\\', '/')}` : ''
    }));
    res.status(200).send({ events: eventsWithFullImageUrls });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get event by event ID
app.get('/events/:eventId', async (req, res) => {
  const { eventId } = req.params;

  // Validate if the provided event ID is valid
  if (!mongoose.Types.ObjectId.isValid(eventId)) {
    return res.status(400).send({ error: 'Invalid event ID' });
  }

  try {
    const event = await Event.findById(eventId); // Removed .populate('location') to keep the response lightweight
    if (!event) return res.status(404).send({ error: 'Event not found' });

    // Prepare the event data, including a full image URL
    const eventWithFullImageUrl = {
      ...event.toObject(),
      image: event.image ? `http://10.0.2.2:${port}/${event.image.replace('\\', '/')}` : ''
    };

    res.status(200).send(eventWithFullImageUrl); // Send event details as a response
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get events by a specific date
app.get('/events/:date', async (req, res) => {
  const { date } = req.params;
  try {
    const startOfDay = new Date(date);
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    const events = await Event.find({
      startTime: { $lt: endOfDay },
      endTime: { $gte: startOfDay },
    });

    // Convert image path to a full URL if necessary
    const eventsWithFullImageUrls = events.map(event => ({
      ...event.toObject(),
      image: event.image ? `http://10.0.2.2:${port}/${event.image.replace('\\', '/')}` : ''
    }));
    res.status(200).send({ events: eventsWithFullImageUrls });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get events by tag
app.get('/events/tag/:tag', async (req, res) => {
  const { tag } = req.params;

  try {
    const events = await Event.find({ tag });
    // Convert image path to a full URL if necessary
    const eventsWithFullImageUrls = events.map(event => ({
      ...event.toObject(),
      image: event.image ? `http://10.0.2.2:${port}/${event.image.replace('\\', '/')}` : ''
    }));
    res.status(200).send({ events: eventsWithFullImageUrls });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to update an event
app.put('/events/:eventId', async (req, res) => {
  const { eventId } = req.params;

  // Validate if the provided event ID is valid
  if (!mongoose.Types.ObjectId.isValid(eventId)) {
    return res.status(400).send({ error: 'Invalid event ID' });
  }

  try {
    const event = await Event.findById(eventId);
    if (!event) return res.status(404).send({ error: 'Event not found' });

    // Update only the fields that were provided in the request
    Object.keys(req.body).forEach(key => {
      if (req.body[key] !== undefined) {
        event[key] = req.body[key];
      }
    });

    await event.save();
    res.status(200).send({ message: 'Event updated successfully', event });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});


// Route to delete an event
app.delete('/events/:eventId', async (req, res) => {
  try {
    const eventId = req.params.eventId;

    // If eventId is supposed to be an ObjectId
    if (!mongoose.Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ error: 'Invalid event ID format.' });
    }

    const event = await Event.findOneAndDelete({ _id: eventId }); // Use _id for ObjectId search
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
    res.status(200).json({ message: 'Event deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Route to create a location with image upload
app.post('/locations', upload.single('image'), async (req, res) => {
  const { location, address, description } = req.body; // Include description
  const image = req.file ? req.file.path : '';

  try {
    const loc = new Location({ location, image, address, description }); // Save description
    await loc.save();
    res.status(201).send({ message: 'Location created successfully', loc });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get all locations
app.get('/locations', async (req, res) => {
  try {
    const locations = await Location.find();
    // Convert the image path to a full URL if necessary
    const locationsWithFullImageUrls = locations.map(loc => ({
      ...loc.toObject(),
      image: loc.image ? `http://10.0.2.2:${port}/${loc.image.replace('\\', '/')}` : ''
    }));    
    res.status(200).send(locationsWithFullImageUrls);
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get location by ID
app.get('/locations/:id', async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).send({ error: 'Invalid location ID' });
  }

  try {
    const location = await Location.findById(id);
    if (!location) return res.status(404).send({ error: 'Location not found' });

    const locationWithFullImageUrl = {
      ...location.toObject(),
      image: location.image ? `http://10.0.2.2:${port}/${location.image.replace('\\', '/')}` : ''
    };

    res.status(200).send(locationWithFullImageUrl);
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Route to get all events for a specific location
app.get('/locations/:id/events', async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).send({ error: 'Invalid location ID' });
  }

  try {
    // Find all events for the location
    const events = await Event.find({ location: id });

    // Convert image path to a full URL if necessary
    const eventsWithFullImageUrls = events.map(event => ({
      ...event.toObject(),
      image: event.image ? `http://10.0.2.2:${port}/${event.image.replace('\\', '/')}` : ''
    }));
    res.status(200).send({ events: eventsWithFullImageUrls });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
