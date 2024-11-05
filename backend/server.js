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
const nodemailer = require('nodemailer');
const crypto = require('crypto');

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
  location: { type: mongoose.Schema.Types.ObjectId, ref: 'Location' },
  resetPasswordCode: String,
  resetPasswordExpires: Date,
  enabledBar: { type: Boolean, default: false },
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

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'Barbuzzofficial@gmail.com',
    pass: 'rczc vfox tzop rqhj',
  },
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
      enabledBar: false, // Initially set to false for all applicants
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
    const user = await User.findOne({ username: req.user.username }).populate('location');
    if (!user) return res.status(404).send({ error: 'User not found' });

    // Prepare the user profile data
    const userProfile = {
      username: user.username,
      email: user.email,
      venueAddress: user.venueAddress,
      venueName: user.venueName,
      venueDescription: user.venueDescription,
      venueWebsite: user.venueWebsite,
      type: user.type,
      favorites: user.favorites,
      location: user.location,
    };

    res.status(200).send(userProfile);
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

app.get('/forgot-username/:email', async(req, res) =>{
  try{
    const email = req.params.email;
    const user = await User.findOne({ email });

    if (user) {
      res.status(200).json({ username: user.username }); // Send the username in the response
    } else {
      res.status(404).json({ error: 'User not found' }); // If no user found, send 404
    }
  } catch (error) {
    res.status(500).json({ error: 'Server error' }); // Handle server errors
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

app.put('/profile', authenticateToken, async (req, res) => {
  const { username, email, venueAddress, venueName, venueDescription, venueWebsite } = req.body;

  try {
    // Update user details based on the authenticated user's username (or ID)
    const updatedUser = await User.findOneAndUpdate(
      { username: req.user.username }, // Query to find the user
      { // Update object
        username,
        email,
        venueAddress,
        venueName,
        venueDescription,
        venueWebsite,
      },
      { new: true, useFindAndModify: false } // Options to return the updated document
    );

    if (!updatedUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Generate a new JWT token with the updated username
    const token = jwt.sign({ username: updatedUser.username }, JWT_SECRET, { expiresIn: '1h' });

    res.status(200).json({
      message: 'Profile updated successfully',
      user: updatedUser,
      token // Include the new token in the response
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to update profile' });
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

app.put('/location/:id', authenticateToken, async (req, res) => {
  const { id: locationId } = req.params; // Extract locationId from the request URL
  const { location, address, description } = req.body;

  try {
    // Update location details using the locationId from params
    const updatedLocation = await Location.findOneAndUpdate(
      { _id: locationId }, // Query to find the location by its ID
      { // Update fields
        location: location,
        description: description,
        address: address
      },
      { new: true, useFindAndModify: false } // Options to return the updated document
    );

    if (!updatedLocation) {
      return res.status(404).json({ error: 'Location not found' });
    }

    res.status(200).json({
      message: 'Location updated successfully',
      location: updatedLocation
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to update location' });
  }
});

app.post('/forgot-password', async (req, res) =>{
  const { email } = req.body;
  try{
    const user = await User.findOne({ email });
    if (!user){
      return res.status((404).json({ message: 'User not found'}));
    }

    const resetCode = Math.floor(10000 + Math.random() * 90000);
    const resetExpires = Date.now() + 36000000;

    user.resetPasswordCode = resetCode;
    user.resetPasswordExpires = resetExpires;

    await user.save();

    const mailOptions = {
      from: 'Barbuzzofficial@gmail.com',
      to: user.email,
      subject: 'Password Reset Code',
      text: `You requested to reset your password. Your 5-digit code is: ${resetCode}. The code is valid for 1 hour.`,
    }
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error(error);
        return res.status(500).json({ message: 'Error sending email' });
      }
      res.status(200).json({ message: 'Password reset code sent' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
})

app.post('/verify-code', async (req, res) => {
  const { email, code, newPassword } = req.body;
  try {
    const user = await User.findOne({ email, resetPasswordCode: code, resetPasswordExpires: { $gt: Date.now() } });
    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired reset code' });
    }

    // Hash the new password and save
    user.password = await bcrypt.hash(newPassword, 10);
    user.resetPasswordCode = undefined;
    user.resetPasswordExpires = undefined;

    await user.save();

    res.status(200).json({ message: 'Password reset successful' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Route to accept an applicant by setting enabledBar to true
app.put('/applicants/accept/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Find the applicant
    const applicant = await User.findById(id);
    if (!applicant) {
      return res.status(404).json({ error: 'Applicant not found' });
    }

    let locationId = null;

    // Create location only if user type is 1
    if (applicant.type === 1) {
      const location = new Location({
        location: applicant.venueName,
        address: applicant.venueAddress,
        description: applicant.venueDescription,
      });

      await location.save();
      locationId = location._id;
    }

    // Update the applicant with enabledBar true and locationId if created
    applicant.enabledBar = true;
    applicant.location = locationId;
    await applicant.save();

    res.json({ message: 'Applicant accepted', applicant });
  } catch (error) {
    res.status(500).json({ error: 'Error accepting applicant' });
  }
});


// Route to deny (delete) an applicant
app.delete('/applicants/deny/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await User.findByIdAndDelete(id);
    res.json({ message: 'Applicant denied and deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Error denying applicant' });
  }
});


// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
