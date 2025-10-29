const admin = require("firebase-admin");

// Load service account
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const messaging = admin.messaging();

console.log("✅ Local notifier started... Listening for new messages...");

const processed = new Set(); // hindari kirim notif dua kali

// Fungsi ambil members room
async function getRoomMembers(roomId) {
  const roomSnap = await db.doc(`rooms/${roomId}`).get();
  const data = roomSnap.exists ? roomSnap.data() : {};
  return data.members || [];
}

// Ambil token FCM user
async function getUserTokens(uid) {
  const snap = await db
    .collection("users")
    .doc(uid)
    .collection("fcmTokens")
    .get();
  return snap.docs.map((d) => d.id);
}

// Dengarkan Firestore realtime
db.collectionGroup("messages")
  .orderBy("createdAt", "desc")
  .limit(50)
  .onSnapshot(async (snap) => {
    for (const change of snap.docChanges()) {
      if (change.type !== "added") continue;

      const ref = change.doc.ref;
      const fullPath = ref.path;
      if (processed.has(fullPath)) continue;
      processed.add(fullPath);

      const message = change.doc.data();
      const pathParts = fullPath.split("/");
      const roomId = pathParts[1];
      const senderId = message.authorId;
      const text = message.text || "Pesan baru masuk";

      try {
        const members = await getRoomMembers(roomId);
        const targets = members.filter((m) => m !== senderId);

        let tokens = [];
        for (const uid of targets) {
          const userTokens = await getUserTokens(uid);
          tokens.push(...userTokens);
        }
        tokens = tokens.filter(Boolean);

        if (tokens.length === 0) {
          console.log(`[SKIP] No tokens for room ${roomId}`);
          continue;
        }

        const res = await messaging.sendEachForMulticast({
          tokens,
          notification: {
            title: "Pesan Baru",
            body: text,
          },
          data: { roomId },
        });

        console.log(
          `[NOTIF] room=${roomId} success=${res.successCount} fail=${res.failureCount}`
        );
      } catch (err) {
        console.error("[ERROR]", err);
      }
    }
  });
