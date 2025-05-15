import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // TODO: Replace these values with your Firebase project configuration
    // You can find these values in your Firebase Console:
    // 1. Go to Firebase Console (https://console.firebase.google.com/)
    // 2. Select your project
    // 3. Click Project Settings (gear icon)
    // 4. Under "Your apps", click the Flutter icon
    // 5. Register your app if not already done
    // 6. Copy the configuration values here
    return const FirebaseOptions(
      apiKey: 'your-api-key', // Replace with actual API key
      appId: 'your-app-id', // Replace with actual App ID
      messagingSenderId: 'your-sender-id', // Replace with actual Sender ID
      projectId: 'your-project-id', // Replace with actual Project ID
    );
  }
}
