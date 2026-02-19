# ReliefRouter Flutter Implementation - Project Summary

## 📋 Overview

This is a complete Flutter implementation for **ReliefRouter** (also known as BanjirAid), a flood emergency triage and dispatch system designed for your hackathon. The app features **role-based access control** with three distinct interfaces based on user email patterns.

## 🎯 Key Features Implemented

### ✅ Role-Based Authentication
- **@admin emails** → Admin Dashboard (full system oversight)
- **@rescue emails** → Rescue Team Dashboard (field operations)
- **Regular emails** → Citizen Interface (submit help requests)

### ✅ Three Complete Interfaces

#### 1. Citizen Interface
- Submit emergency help requests
- GPS location capture with manual fallback
- Track submitted requests in real-time
- View request status updates
- Safety tips and emergency contacts
- Clean, intuitive UI for stress situations

#### 2. Rescue Team Dashboard
- Live ticket queue with real-time updates
- Filter by status (New, Assigned, En Route, Resolved)
- Filter by priority (P1, P2, P3)
- Update ticket status with action buttons
- Assign tickets to rescue team
- Detailed ticket information display
- Statistics overview

#### 3. Admin Dashboard
- Complete system overview with statistics
- Manage all tickets (view, edit, delete)
- Advanced search and filtering
- Analytics dashboard (placeholder for expansion)
- Settings for teams, zones, permissions
- Four-tab interface: Overview, All Tickets, Analytics, Settings

## 📁 Project Structure

```
relief_router/
├── lib/
│   ├── main.dart                          # App entry + role routing
│   ├── services/
│   │   └── auth_service.dart             # Authentication & role detection
│   └── screens/
│       ├── auth/
│       │   ├── login_screen.dart         # Login with role info
│       │   └── register_screen.dart      # User registration
│       ├── citizen/
│       │   ├── citizen_home_screen.dart  # Main citizen interface
│       │   ├── submit_request_screen.dart # Emergency request form
│       │   └── my_requests_screen.dart   # Track submissions
│       ├── responder/
│       │   └── responder_dashboard.dart  # Rescue team interface
│       └── admin/
│           └── admin_dashboard.dart      # Admin control panel
├── pubspec.yaml                           # Dependencies
├── README.md                              # Project overview
├── SETUP_GUIDE.md                         # Detailed setup instructions
└── ROLE_ROUTING_EXPLAINED.md             # Role system documentation
```

## 🔧 Technology Stack

- **Framework**: Flutter 3.0+
- **Authentication**: Firebase Auth (Email/Password)
- **Database**: Cloud Firestore (Real-time)
- **Location**: Geolocator package
- **State Management**: StatefulWidget
- **UI Components**: Material Design 3

## 📦 Dependencies

```yaml
firebase_core: ^2.24.2       # Firebase initialization
firebase_auth: ^4.15.3       # User authentication
cloud_firestore: ^4.13.6     # Real-time database
geolocator: ^10.1.0          # GPS location
intl: ^0.18.1                # Date/time formatting
```

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK 3.0.0+
- Firebase account
- Android Studio or VS Code
- Android/iOS device or emulator

### 2. Setup Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Set up Firebase (see SETUP_GUIDE.md)
# - Create Firebase project
# - Enable Email/Password auth
# - Create Firestore database
# - Download config files

# 3. Run the app
flutter run
```

### 3. Create Test Accounts

In Firebase Console → Authentication → Users:

```
Admin:    admin@admin.com      / Admin123!
Rescuer:  team1@rescue.com     / Rescue123!
Citizen:  citizen@gmail.com    / Citizen123!
```

## 📊 Data Model

### Ticket Schema
```dart
{
  'ticket_id': String,              // Auto-generated
  'status': String,                 // new, triaged, assigned, en_route, resolved
  'priority': String?,              // p1, p2, p3 (AI-assigned)
  'incident_type': String,          // rescue, medical, supplies, hazard, info
  'raw_message': String,            // User description
  'location_text': String,          // Landmark/address
  'gps_lat': double?,               // GPS latitude
  'gps_lng': double?,               // GPS longitude
  'people_count': int,              // Number affected
  'vulnerable_people': bool,        // Elderly/disabled/infants
  'injuries': String,               // yes/no/unknown
  'water_level': String?,           // ankle/knee/waist/chest/roof
  'reporter_email': String,         // User email
  'reporter_name': String?,         // Optional name
  'reporter_contact': String?,      // Optional phone
  'created_at': Timestamp,          // Submission time
  'updated_at': Timestamp,          // Last modified
  'assigned_team_id': String?,      // Assigned rescue team
}
```

## 🔒 Security Implementation

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAdmin() {
      return request.auth != null && 
             request.auth.token.email.matches('.*@admin.*');
    }
    
    function isRescuer() {
      return request.auth != null && 
             request.auth.token.email.matches('.*@rescue.*');
    }
    
    match /tickets/{ticket} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if isAdmin() || isRescuer();
      allow delete: if isAdmin();
    }
  }
}
```

## 🎨 UI/UX Features

### Citizen Interface
- ✅ Emergency-focused design with red accents
- ✅ Large, touch-friendly buttons
- ✅ GPS with one-tap location capture
- ✅ Category quick-select buttons
- ✅ Real-time status tracking
- ✅ Safety guidelines prominently displayed

### Rescue Dashboard
- ✅ Live updating ticket queue
- ✅ Color-coded priorities (P1=Red, P2=Orange, P3=Blue)
- ✅ Status badges for quick identification
- ✅ Statistics cards at top
- ✅ Filter chips for quick sorting
- ✅ Detailed ticket sheets with action buttons

### Admin Interface
- ✅ Tabbed navigation (Overview, Tickets, Analytics, Settings)
- ✅ System-wide statistics
- ✅ Search functionality
- ✅ Expandable ticket cards
- ✅ Inline editing and deletion
- ✅ Professional purple theme

## 📱 User Workflows

### Citizen Flow
1. Register/Login with regular email
2. Auto-routed to Citizen Interface
3. Submit help request with details
4. Optionally capture GPS location
5. Track request in "My Requests"
6. View status updates in real-time

### Rescuer Flow
1. Login with @rescue email
2. View live ticket queue
3. Filter by priority/status
4. Select ticket to view details
5. Assign ticket to self
6. Update status: Assigned → En Route → Resolved

### Admin Flow
1. Login with @admin email
2. View system overview and statistics
3. Monitor all tickets
4. Search/filter specific tickets
5. Manually update or delete tickets
6. Access analytics and settings

## 🔄 Real-time Features

- **Live Updates**: All dashboards update in real-time using Firestore snapshots
- **Status Sync**: Status changes reflect immediately across all users
- **Statistics**: Counts and metrics update dynamically
- **No Polling**: Efficient event-driven architecture

## 🌟 Standout Features

1. **Automatic Role Detection**: No manual role assignment needed
2. **Separate Interfaces**: Each role gets appropriate tools
3. **Real-time Sync**: All changes propagate instantly
4. **Offline-Ready Structure**: Built for future offline support
5. **Material Design 3**: Modern, accessible UI
6. **Safety-First**: Prominent emergency information
7. **Mobile-Optimized**: Touch-friendly, responsive design

## 📈 Future Enhancements

### Planned for Post-Hackathon

- [ ] **AI Triage** using Gemini API
  - Automatic priority assignment
  - Duplicate detection
  - Abnormality flagging

- [ ] **Map View**
  - Visual ticket locations
  - Team positioning
  - Route optimization

- [ ] **Push Notifications**
  - New ticket alerts
  - Status updates
  - Urgent priority notifications

- [ ] **Photo Attachments**
  - Upload situation photos
  - Before/after documentation

- [ ] **Offline Mode**
  - Local database caching
  - Queue sync when online

- [ ] **Multi-language**
  - Malay/English support
  - Auto-detection

- [ ] **Team Management**
  - Create and manage teams
  - Coverage zone assignment
  - Availability tracking

## 🐛 Known Limitations

1. **No AI Triage Yet**: Priority must be manually set or left null
2. **Basic Filtering**: Advanced queries not implemented
3. **No Map View**: Location shows as text only
4. **No Attachments**: Photo upload not included
5. **Simple Deduplication**: No automatic duplicate detection
6. **English Only**: Multi-language not implemented

## 📖 Documentation Included

1. **README.md**: Project overview and quick start
2. **SETUP_GUIDE.md**: Detailed Firebase and platform setup
3. **ROLE_ROUTING_EXPLAINED.md**: Role system architecture
4. **Inline Comments**: All code is well-documented

## ✅ Testing Checklist

### Pre-Demo Testing
- [ ] Create admin, rescuer, and citizen accounts
- [ ] Test role routing for each email type
- [ ] Submit ticket as citizen
- [ ] View ticket in rescuer dashboard
- [ ] Update ticket status as rescuer
- [ ] View ticket in admin dashboard
- [ ] Test search/filter in admin panel
- [ ] Verify real-time updates
- [ ] Test on actual device (not just emulator)

## 🎯 Hackathon Presentation Tips

### Key Points to Highlight

1. **Problem Solved**: Chaotic flood emergency reporting → Organized triage system
2. **Role Separation**: Different interfaces for different needs
3. **Real-time Updates**: No refresh needed, instant sync
4. **Mobile-First**: Built for emergency situations
5. **Scalable Architecture**: Ready for AI and advanced features
6. **User-Centered Design**: Intuitive for stressed users

### Demo Flow Suggestion

1. **Show Problem** (30s): Explain flood emergency chaos
2. **Citizen Demo** (1.5min): Submit urgent request
3. **Rescuer Demo** (1.5min): Show triage and assignment
4. **Admin Demo** (1min): System oversight
5. **Highlight Features** (1min): Real-time, role-based, mobile
6. **Future Vision** (30s): AI triage, maps, notifications

## 🤝 Support

For issues or questions:
1. Check SETUP_GUIDE.md for detailed instructions
2. Review ROLE_ROUTING_EXPLAINED.md for role system
3. Check Flutter and Firebase documentation
4. Review inline code comments

## 📄 License

MIT License - Feel free to modify and use for your hackathon.

---

## 🏆 Built For

**KitaHack Hackathon**  
**Team**: Milo Ais Ikat  
**Project**: ReliefRouter (BanjirAid)  
**Goal**: Making flood emergency response more efficient

---

**Good luck with your hackathon presentation! 🚀**
