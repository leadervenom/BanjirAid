# ReliefRouter - Complete Setup Guide For Contributers or Developers

## Quick Start Summary


1. Install Flutter SDK
2. Set up Firebase project
3. Configure Firebase in your app
4. Add platform-specific permissions
5. Create test accounts
6. Run the app

---

## Detailed Setup Instructions

### 1. Flutter Installation

#### Windows
```bash
# Download Flutter SDK from https://flutter.dev
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

flutter doctor
```

#### macOS
```bash
# Install using Homebrew
brew install flutter

# Or download from https://flutter.dev
flutter doctor
```

#### Linux
```bash
# Download and extract Flutter
# Add to PATH in ~/.bashrc
export PATH="$PATH:/path/to/flutter/bin"

flutter doctor
```

### 2. Firebase Project Setup

#### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Enter project name: "ReliefRouter" or "BanjirAid"
4. Disable Google Analytics (optional)
5. Click "Create Project"

#### Step 2: Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get Started"
3. Select "Email/Password" under Sign-in method
4. Enable "Email/Password"
5. Save

#### Step 3: Create Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create Database"
3. Select "Start in test mode" (we'll add security rules later)
4. Choose a location close to your users
5. Click "Enable"

#### Step 4: Add Android App
1. Click "Add App" → Android icon
2. Android package name: `com.reliefrouter.app` (or your choice)
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

#### Step 5: Add iOS App (if needed)
1. Click "Add App" → iOS icon
2. iOS bundle ID: `com.reliefrouter.app`
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

### 3. Configure Your Flutter Project

#### Update android/app/build.gradle
Add at the bottom of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Add to dependencies:
```gradle
dependencies {
    // ... other dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

#### Update android/build.gradle
Add to dependencies:
```gradle
buildscript {
    dependencies {
        // ... other dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### Update android/app/src/main/AndroidManifest.xml
```xml
<manifest ...>
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application ...>
        ...
    </application>
</manifest>
```

#### Update ios/Runner/Info.plist
```xml
<dict>
    <!-- ... existing keys ... -->
    
    <!-- Add location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to help rescue teams find you during emergencies</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>We need your location to help rescue teams find you during emergencies</string>
</dict>
```

### 4. Firestore Security Rules

Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             request.auth.token.email.matches('.*@admin.*');
    }
    
    // Helper function to check if user is rescuer
    function isRescuer() {
      return request.auth != null && 
             request.auth.token.email.matches('.*@rescue.*');
    }
    
    // Helper function to check if user is citizen
    function isCitizen() {
      return request.auth != null;
    }
    
    // Tickets collection
    match /tickets/{ticket} {
      // Anyone authenticated can read
      allow read: if isCitizen();
      
      // Anyone authenticated can create
      allow create: if isCitizen();
      
      // Only admin and rescuers can update
      allow update: if isAdmin() || isRescuer();
      
      // Only admin can delete
      allow delete: if isAdmin();
    }
    
    // Teams collection (future use)
    match /teams/{team} {
      allow read: if isCitizen();
      allow write: if isAdmin();
    }
    
    // Zones collection (future use)
    match /zones/{zone} {
      allow read: if isCitizen();
      allow write: if isAdmin();
    }
  }
}
```

### 5. Create Test Accounts

Use Firebase Console → Authentication → Users → Add User

#### Admin Account
- Email: `admin@admin.com`
- Password: `Admin123!`
- Role: Admin (detected by @admin in email)

#### Rescue Team Accounts
- Email: `team1@rescue.com`
- Password: `Rescue123!`
- Role: Rescuer

- Email: `team2@rescue.com`
- Password: `Rescue123!`
- Role: Rescuer

#### Citizen Accounts
- Email: `john.doe@gmail.com`
- Password: `Citizen123!`
- Role: Citizen

- Email: `jane.smith@yahoo.com`
- Password: `Citizen123!`
- Role: Citizen

### 6. Run the Application

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Or run on specific device
flutter devices  # List devices
flutter run -d <device-id>

# Build for release (Android)
flutter build apk --release

# Build for release (iOS)
flutter build ios --release
```

---

## Role-Based Access Explained

### How Role Detection Works

The app uses email patterns to determine user roles:

```dart
// In auth_service.dart
static UserRole getUserRole(String email) {
  final lowerEmail = email.toLowerCase();
  
  if (lowerEmail.contains('@admin')) {
    return UserRole.admin;  // Full system access
  } else if (lowerEmail.contains('@rescue')) {
    return UserRole.rescuer;  // Field operations
  } else {
    return UserRole.citizen;  // Submit requests
  }
}
```

### Role Capabilities

| Feature | Citizen | Rescuer | Admin |
|---------|---------|---------|-------|
| Submit Requests | ✅ | ✅ | ✅ |
| View Own Requests | ✅ | ❌ | ❌ |
| View All Tickets | ❌ | ✅ | ✅ |
| Update Status | ❌ | ✅ | ✅ |
| Assign Tickets | ❌ | ✅ | ✅ |
| Delete Tickets | ❌ | ❌ | ✅ |
| System Analytics | ❌ | ❌ | ✅ |
| Manage Settings | ❌ | ❌ | ✅ |

---

## Troubleshooting

### Common Issues

#### 1. Firebase not initialized
**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**:
- Ensure `google-services.json` is in `android/app/`
- Check that Firebase is initialized in `main.dart`:
  ```dart
  await Firebase.initializeApp();
  ```

#### 2. Location permissions denied
**Error**: Location services disabled or permissions denied

**Solution**:
- Check AndroidManifest.xml has location permissions
- For iOS, check Info.plist has location keys
- Request permissions at runtime

#### 3. Build fails on Android
**Error**: Various Gradle errors

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 4. Can't sign in
**Error**: Invalid credentials or user not found

**Solution**:
- Check Firebase Console → Authentication that user exists
- Verify email/password are correct
- Check Firebase Auth is enabled

#### 5. Tickets not appearing
**Error**: Empty list or loading forever

**Solution**:
- Check Firestore rules allow read access
- Verify internet connection
- Check Firebase Console → Firestore for data

---

## Testing Workflow

### 1. Test Citizen Flow
1. Register with `test@gmail.com`
2. Login → Should see Citizen Interface
3. Submit a help request with:
   - Type: Rescue
   - Message: "Trapped on 2nd floor, water rising"
   - Location: Use GPS or enter manually
   - People: 3
   - Water Level: Waist
   - Vulnerable: Yes
4. Go to "My Requests" → Verify request appears

### 2. Test Rescuer Flow
1. Register with `rescuer@rescue.com`
2. Login → Should see Rescue Team Dashboard
3. View new ticket from citizen
4. Filter by priority
5. Click ticket → View details
6. Assign to yourself
7. Mark as "En Route"
8. Mark as "Resolved"

### 3. Test Admin Flow
1. Register with `superadmin@admin.com`
2. Login → Should see Admin Dashboard
3. Check Overview tab for statistics
4. Go to All Tickets tab
5. Search for specific ticket
6. Update ticket status
7. Delete test ticket
8. View Analytics tab

---

## Next Steps

After basic setup:

1. **Add AI Triage** (Cloud Functions + Gemini API)
2. **Implement Map View** (Google Maps Flutter)
3. **Add Push Notifications** (FCM)
4. **Enable Offline Mode** (Local DB + Sync)
5. **Add Photo Upload** (Firebase Storage)
6. **Implement Team Management**
7. **Add Multi-language Support**

---

## Production Deployment

### Android
```bash
# Create keystore
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release

# Update android/app/build.gradle with signing config
# Build release APK
flutter build apk --release

# Or build App Bundle for Play Store
flutter build appbundle --release
```

### iOS
```bash
# In Xcode, configure signing
# Build archive
flutter build ios --release

# Open in Xcode for App Store submission
open ios/Runner.xcworkspace
```

### Security Checklist
- [ ] Update Firestore rules for production
- [ ] Enable App Check
- [ ] Add rate limiting
- [ ] Implement proper error logging
- [ ] Add analytics tracking
- [ ] Configure backup strategy
- [ ] Set up monitoring/alerting

---

## Support & Resources

- Flutter Docs: https://docs.flutter.dev
- Firebase Docs: https://firebase.google.com/docs
- Firestore Security: https://firebase.google.com/docs/firestore/security/get-started
- Geolocator Plugin: https://pub.dev/packages/geolocator

For project-specific questions, contact the development team.
