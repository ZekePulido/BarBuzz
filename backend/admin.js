const admin = require('firebase-admin');

// Initialize Firebase Admin SDK (ensure you have set up your service account)
admin.initializeApp({
  credential: admin.credential.cert(require('../lib/utils/barbuzz-bba60-firebase-adminsdk-zxhhy-57b27eb7cf.json')),
});

const createAdminUser = async (email, password) => {
  try {
    const user = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: true, // Set this to true if you want the email to be verified by default
      displayName: 'Admin User',
    });

    console.log('Successfully created user:', user.uid);

    // Set custom claims to make the user an admin
    await admin.auth().setCustomUserClaims(user.uid, { isAdmin: true });
    console.log(`Admin claim set for user: ${email}`);
  } catch (error) {
    console.error('Error creating user:', error);
  }
};

// Replace these with your desired admin email and password
createAdminUser('barbuzz@gmail.com', 'password');
