# ReliefRouter (BanjirAid)

Flood Emergency Triage & Dispatch System with AI-powered assistance for efficient search and rescue operations.

## Features

### Role-Based Access Control
The app automatically routes users to different interfaces based on their email:

- **@admin emails** → Admin Dashboard (Full system oversight)
- **@rescue emails** → Rescue Team Dashboard (Field operations)
- **Regular emails (e.g., @gmail.com)** → Citizen Interface (Submit help requests)

### Three Distinct Interfaces

#### 1. Citizen Interface
- Submit help requests with detailed information
- GPS location capture or manual landmark entry
- Track submitted requests
- View request status updates
- Safety tips and emergency contacts

#### 2. Rescue Team Dashboard
- View all tickets in real-time
- Filter by status (New, Assigned, En Route, Resolved)
- Filter by priority (P1, P2, P3)
- Update ticket status
- Assign tickets to themselves
- Mark progress (Assigned → En Route → Resolved)

#### 3. Admin Dashboard
- Complete system overview with statistics
- Manage all tickets (view, edit, delete)
- Search and filter functionality
- Analytics dashboard
- Settings for teams, zones, and permissions
- Audit logs

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase account
- Android Studio / VS Code
- Git

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd relief_router
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a new Firebase project at https://console.firebase.google.com
   
   b. Enable the following services:
      - Authentication (Email/Password)
      - Cloud Firestore
   
   c. Download configuration files:
      - For Android: `google-services.json` → `android/app/`
      - For iOS: `GoogleService-Info.plist` → `ios/Runner/`
   
   d. Update Firebase configuration in your project

4. **Configure Firestore Security Rules**
   
   Go to Firestore → Rules and add:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /tickets/{ticket} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update: if request.auth != null && 
                       (request.auth.token.email.matches('.*@admin.*') || 
                        request.auth.token.email.matches('.*@rescue.*'));
         allow delete: if request.auth != null && 
                       request.auth.token.email.matches('.*@admin.*');
       }
     }
   }
   ```

5. **Android Permissions**
   
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

6. **iOS Permissions**
   
   Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to help rescue teams find you</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>We need your location to help rescue teams find you</string>
   ```

7. **Run the app**
   ```bash
   flutter run
   ```

## Test Accounts

Create test accounts with these email formats:

### Admin Account
- Email: `admin@admin.com`
- Password: `admin123`

### Rescue Team Account
- Email: `team1@rescue.com`
- Password: `rescue123`

### Citizen Account
- Email: `citizen@gmail.com`
- Password: `citizen123`

## Project Structure

```
lib/
├── main.dart                          # App entry point with role routing
├── services/
│   └── auth_service.dart             # Authentication & role detection
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login page
│   │   └── register_screen.dart      # Registration page
│   ├── citizen/
│   │   ├── citizen_home_screen.dart  # Citizen dashboard
│   │   ├── submit_request_screen.dart # Submit help request
│   │   └── my_requests_screen.dart   # View submitted requests
│   ├── responder/
│   │   └── responder_dashboard.dart  # Rescue team interface
│   └── admin/
│       └── admin_dashboard.dart      # Admin control panel
```

## Data Model

### Ticket Fields
- `ticket_id`: Unique identifier
- `status`: new, triaged, assigned, en_route, resolved, closed
- `priority`: p1, p2, p3 (set by AI triage)
- `incident_type`: rescue, medical, supplies, hazard, information
- `raw_message`: User's description
- `location_text`: Landmark or address
- `gps_lat`, `gps_lng`: GPS coordinates
- `people_count`: Number of affected people
- `vulnerable_people`: Boolean for elderly/disabled/infants
- `injuries`: yes/no/unknown
- `water_level`: ankle/knee/waist/chest/roof/unknown
- `reporter_email`: User's email
- `created_at`, `updated_at`: Timestamps

## Key Features

### For Citizens
- ✅ Quick emergency request submission
- ✅ Category-based incident types
- ✅ GPS location or manual entry
- ✅ Real-time request tracking
- ✅ Safety guidelines
- ✅ Emergency contacts

### For Rescue Teams
- ✅ Live ticket queue with filters
- ✅ Priority-based sorting
- ✅ Status management
- ✅ Quick ticket assignment
- ✅ Progress tracking
- ✅ Detailed ticket information

### For Admins
- ✅ System-wide overview
- ✅ All tickets management
- ✅ Search and filter
- ✅ Manual status updates
- ✅ Ticket deletion
- ✅ Statistics dashboard

## Future Enhancements

- [ ] AI-powered triage using Gemini API
- [ ] Automatic duplicate detection
- [ ] Map view for tickets
- [ ] Team assignment logic
- [ ] Push notifications
- [ ] Offline mode
- [ ] Multi-language support (Malay/English)
- [ ] Photo attachments
- [ ] Advanced analytics
- [ ] Audit trail

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **Location**: Geolocator
- **State Management**: StatefulWidget
- **Real-time Updates**: Firestore Snapshots

## License

MIT License - See LICENSE file for details

## Support

For issues or questions, please contact the development team.

---

**Built for KitaHack - Making Emergency Response More Efficient**
