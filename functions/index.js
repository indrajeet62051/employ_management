const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

// Configure email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

exports.sendAttendanceEmails = functions.https.onCall(async (data, context) => {
  const { attendanceRecords, date } = data;
  
  try {
    // Send email to each employee
    const emailPromises = attendanceRecords.map(async (record) => {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: record.email,
        subject: `Your Attendance for ${date}`,
        text: `Hi ${record.name},\n\nYour attendance for ${date} has been marked as: ${record.status}.\n\nRegards,\nCompany Admin`,
        html: `
          <div style="font-family: Arial, sans-serif;">
            <h2>Attendance Notification</h2>
            <p>Hi ${record.name},</p>
            <p>Your attendance for <strong>${date}</strong> has been marked as: <strong>${record.status}</strong>.</p>
            <br>
            <p>Regards,<br>Company Admin</p>
          </div>
        `,
      };

      return transporter.sendMail(mailOptions);
    });

    await Promise.all(emailPromises);
    return { success: true, message: 'Emails sent successfully' };
  } catch (error) {
    console.error('Error sending emails:', error);
    throw new functions.https.HttpsError('internal', 'Error sending emails');
  }
}); 