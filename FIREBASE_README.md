Steps to create the composite index and apply security rules

1. Create the composite index (required by your query)

- The app logs include a direct URL to create the index. Click it from the device/emulator or copy the URL and open it in your browser.
  Example URL format (yours will be different):
  https://console.firebase.google.com/v1/r/project/edtech-e5440/firestore/indexes?create_composite=...

- If you prefer to create the index manually in the Console:
  - Open Firebase Console → Select project → Firestore Database → Indexes → "Create composite index"
  - Collection ID: rooms
  - Fields:
    - members — array-contains
    - createdAt — Descending
  - Leave **name** default settings (console may add it automatically).
  - Create and wait (index build may take a few minutes).

2. Apply the security rules (recommended role-based rules)

- I added a sample rules file `firestore.rules` in the project root. It enforces:

  - Only authenticated users can create rooms, and createdBy must match the caller UID.
  - Only members listed in a room can read messages and the room document.
  - Messages are write-once (create allowed), no updates/deletes.

- To test/deploy rules via Firebase Console:

  - Open Firebase Console → Firestore Database → Rules
  - Replace rules with the contents of `firestore.rules` and Publish.

- To deploy rules from your machine using Firebase CLI:
  - Install and login: `npm install -g firebase-tools` and `firebase login`
  - Initialize if not done: `firebase init` (choose Firestore rules only or configure as needed)
  - Place `firestore.rules` in the selected location (or set `firestore.rules` in firebase.json)
  - Deploy: `firebase deploy --only firestore:rules`

3. Rapid local testing with Emulator Suite (recommended for dev)

- Install and start emulators:
  - `firebase emulators:start --only firestore,auth` (run from project with firebase.json)
- In your Flutter app (dev mode), connect to emulator:
  ```dart
  await Firebase.initializeApp(...);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  ```
  Note: On Android emulator use host `10.0.2.2` instead of `localhost` if needed.

4. Verify

- After index is built, run the app and the "query requires index" error should stop.
- After rules are applied, attempt create room and ensure you are authenticated. If permission denied persists, check the rules and the shape of the document written (createdBy must match caller UID).

If you want, I can:

- Apply `firestore.rules` to your Firebase project via the Firebase CLI (you must provide project access or run commands locally), or
- Walk you step-by-step while you click the Console link and create the index.

Cara cepat (PowerShell) untuk deploy rules + index dari repo ini:

1. Buka PowerShell di folder proyek (F:\\edtech)
2. Jalankan skrip deploy yang sudah saya tambahkan:

```powershell
Set-Location -Path 'F:\\edtech'
.\n+\scripts\deploy-firebase.ps1
```

Catatan:

- Skrip akan menginstal `firebase-tools` jika belum tersedia, meminta Anda login, lalu meminta memilih project dan melakukan deploy `firestore.rules` dan `firestore.indexes.json`.
- Anda tetap harus mengkonfirmasi project `edtech-e5440` saat diminta.
