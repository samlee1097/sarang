const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onPartnerRequestCreated = onDocumentCreated("partnerRequests/{requestId}", async (event) => {
    // In v2, the document snapshot is located inside 'event.data'
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event");
        return;
    }
    
    const request = snapshot.data();
    console.log(`Processing new partner request for: ${request.toEmail}`);
    
    try {
        const usersRef = admin.firestore().collection("users");
        const userSnapshot = await usersRef.where("email", "==", request.toEmail).limit(1).get();
        
        if (userSnapshot.empty) {
            console.log("Target user not found.");
            return;
        }
        
        const targetUser = userSnapshot.docs[0].data();
        const fcmToken = targetUser.fcmToken;
        
        if (!fcmToken) {
            console.log("Target user missing FCM Token.");
            return;
        }
        
        const payload = {
            notification: {
                title: "New Link Request ✨",
                body: `${request.fromEmail} is requesting to connect.`
            },
            token: fcmToken
        };
        
        await admin.messaging().send(payload);
        console.log("Successfully sent push notification");
        
    } catch (error) {
        console.error("Error sending push notification:", error);
    }
});
