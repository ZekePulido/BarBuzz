const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const nodemailer = require('nodemailer');
const firebaseAdmin = require('firebase-admin');

const app = express();
const port = 3000;

// Hardcoded JWT secret key (for learning purposes only)
const JWT_SECRET = 'your_jwt_secret'; // Replace with a secure secret

const serviceAccount = require('../lib/utils/barbuzz-bba60-firebase-adminsdk-zxhhy-57b27eb7cf.json');
firebaseAdmin.initializeApp({
  credential: firebaseAdmin.credential.cert(serviceAccount),
});





// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
