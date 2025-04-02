const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewReportNotification = onDocumentCreated(
  { document: "lost_dogs/{reportId}" },
  (event) => {
    // En triggers v2, los datos vienen en event.data.value.fields
    // Cada campo se representa con un objeto (por ejemplo, para cadenas: { stringValue: "valor" }).
    const reportData = event.data.value.fields;
    const name = reportData.name ? reportData.name.stringValue : "Sin nombre";
    const payload = {
      notification: {
        title: "Nuevo reporte",
        body: `Se ha reportado un nuevo perro: ${name}`,
      },
    };
    return admin.messaging().sendToTopic("reports", payload);
  }
);
