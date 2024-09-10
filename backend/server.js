const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

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
  nickname: String,
  favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Location' }],
});

const eventSchema = new mongoose.Schema({
  title: String,
  location: { type: mongoose.Schema.Types.ObjectId, ref: 'Location' },
  locationName: String, // Ensure this field is present
  startTime: Date,
  endTime: Date,
  tag: String // Single tag
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
  const { username, password, nickname } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ username, password: hashedPassword, nickname });
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
    res.status(200).send({ message: 'Login successful', token });
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


app.post('/events', async (req, res) => {
  const { title, location, startTime, endTime, tag } = req.body;

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
      tag // Save the single tag
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
    res.status(200).send({ events });
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

    res.status(200).send({ events });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

app.get('/events/tag/:tag', async (req, res) => {
  const { tag } = req.params;

  try {
    const events = await Event.find({ tag });
    res.status(200).send({ events });
  } catch (err) {
    res.status(400).send({ error: err.message });
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
      image: loc.image ? `http://10.0.2.2:3000/${loc.image.replace('\\', '/')}` : ''
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
      image: location.image ? `http://localhost:${port}/${location.image.replace('\\', '/')}` : ''
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

    res.status(200).send({ events });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});



// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
