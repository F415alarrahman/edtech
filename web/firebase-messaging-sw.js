// web/firebase-messaging-sw.js

// Firebase v9 compat (yang cocok dengan FlutterFire)
importScripts(
  "https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js"
);

// Pake config Web dari DefaultFirebaseOptions.web kamu
firebase.initializeApp({
  apiKey: "AIzaSyBvVrztRrfNIn5bzx3nucZE0zxpzoVc_90",
  authDomain: "edtech-e5440.firebaseapp.com",
  projectId: "edtech-e5440",
  storageBucket: "edtech-e5440.firebasestorage.app",
  messagingSenderId: "118237122687",
  appId: "1:118237122687:web:c05c6b50c6b743c1cbaf4a",
  measurementId: "G-VLTZ8EZT45",
});

// Init messaging
const messaging = firebase.messaging();

// (opsional) handle background message
// self.addEventListener('push', (e) => { /* custom */ });
