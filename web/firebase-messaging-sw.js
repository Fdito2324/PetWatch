importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAAIabppA866YJOLsfXT5NtIn01dCstPMs",
  authDomain: "fernandovidal-be766.firebaseapp.com",
  projectId: "fernandovidal-be766",
  storageBucket: "fernandovidal-be766.firebasestorage.app",
  messagingSenderId: "92964835784",
  appId: "1:92964835784:web:9388230c7a30a9a208f0fd",
  measurementId: "G-L1LDSMKS7F"
});

const messaging = firebase.messaging();
