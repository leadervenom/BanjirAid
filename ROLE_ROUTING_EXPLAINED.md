# Role-Based Authentication & Routing System

## How It Works

ReliefRouter/BanjirAid uses email patterns to automatically route users to the appropriate interface after login.

```
                                LOGIN
                                  |
                                  v
                        +-------------------+
                        | Check User Email  |
                        +-------------------+
                                  |
                    +-------------+-------------+
                    |             |             |
                    v             v             v
            Contains @admin   Contains @rescue  Regular email
                    |             |             |
                    v             v             v
          +---------------+ +---------------+ +---------------+
          | Admin         | | Rescue Team   | | Citizen       |
          | Dashboard     | | Dashboard     | | Interface     |
          +---------------+ +---------------+ +---------------+
          |               | |               | |               |
          | • Overview    | | • Ticket List | | • Submit      |
          | • All Tickets | | • Filters     | |   Request     |
          | • Analytics   | | • Status      | | • Track       |
          | • Settings    | |   Updates     | |   Requests    |
          | • Full Access | | • Assignment  | | • Safety Tips |
          +---------------+ +---------------+ +---------------+
```

## Email Pattern Detection

### Code Implementation

```dart
// services/auth_service.dart

enum UserRole {
  admin,
  rescuer,
  citizen,
}

static UserRole getUserRole(String email) {
  final lowerEmail = email.toLowerCase();
  
  if (lowerEmail.contains('@admin')) {
    return UserRole.admin;
  } else if (lowerEmail.contains('@rescue')) {
    return UserRole.rescuer;
  } else {
    return UserRole.citizen;
  }
}
```

## Example Users

### Admin Users
✅ `admin@admin.com` → Admin Dashboard
✅ `superadmin@admin.org` → Admin Dashboard
✅ `manager@admin.net` → Admin Dashboard
❌ `admin@gmail.com` → Citizen Interface (doesn't contain @admin)

### Rescue Team Users
✅ `team1@rescue.com` → Rescue Dashboard
✅ `field@rescue.org` → Rescue Dashboard
✅ `responder@rescue.net` → Rescue Dashboard
❌ `rescue@gmail.com` → Citizen Interface (doesn't contain @rescue)

### Citizen Users
✅ `john@gmail.com` → Citizen Interface
✅ `jane@yahoo.com` → Citizen Interface
✅ `victim@hotmail.com` → Citizen Interface
✅ Any other email → Citizen Interface

## Main App Flow

```dart
// main.dart

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Not logged in
        if (!snapshot.hasData) {
          return LoginScreen();
        }
        
        // Logged in - Route based on email
        return RoleBasedRouter(user: snapshot.data!);
      },
    );
  }
}

class RoleBasedRouter extends StatelessWidget {
  final User user;

  @override
  Widget build(BuildContext context) {
    final email = user.email?.toLowerCase() ?? '';
    final role = AuthService.getUserRole(email);

    switch (role) {
      case UserRole.admin:
        return AdminDashboard();
      case UserRole.rescuer:
        return ResponderDashboard();
      case UserRole.citizen:
      default:
        return CitizenHomeScreen();
    }
  }
}
```

## Security Implementation

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Check if user is admin
    function isAdmin() {
      return request.auth != null && 
             request.auth.token.email.matches('.*@admin.*');
    }
    
    // Check if user is rescuer
    function isRescuer() {
      return request.auth != null && 
             request.auth.token.email.matches('.*@rescue.*');
    }
    
    // Tickets permissions
    match /tickets/{ticket} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if isAdmin() || isRescuer();
      allow delete: if isAdmin();
    }
  }
}
```

## User Journey Examples

### Scenario 1: Flood Victim
1. Sarah downloads the app
2. Registers with `sarah@gmail.com`
3. Automatically routed to **Citizen Interface**
4. Submits help request: "Trapped on roof, 2nd floor"
5. Tracks request status in "My Requests"

### Scenario 2: Rescue Team Member
1. Officer Ahmad gets assigned to rescue operations
2. Registers with `ahmad@rescue.com`
3. Automatically routed to **Rescue Team Dashboard**
4. Sees Sarah's request in the queue
5. Assigns it to himself
6. Updates status: Assigned → En Route → Resolved

### Scenario 3: Operations Manager
1. Manager registers with `ops@admin.com`
2. Automatically routed to **Admin Dashboard**
3. Monitors all tickets system-wide
4. Views analytics and statistics
5. Manages team assignments
6. Reviews audit logs

## Benefits of This Approach

### ✅ Advantages
- **Simple**: No complex role assignment needed
- **Automatic**: Users get the right interface immediately
- **Flexible**: Easy to add new role types
- **Secure**: Backed by Firestore security rules
- **Clear**: Email pattern makes role obvious

### ⚠️ Considerations
- Users must register with appropriate email domain
- Can't change roles without new account
- Email pattern must be maintained
- Organization needs to control email domains

## Alternative Implementation (Future)

For production systems, you might want:

```dart
// Store role in Firestore user document
class UserProfile {
  String uid;
  String email;
  UserRole role;  // Explicitly set
  String? teamId;
  DateTime createdAt;
}

// Admin can assign roles manually
Future<void> assignRole(String userId, UserRole role) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'role': role.toString()});
}
```

## Testing the System

### Test Account Creation

```dart
// In Firebase Console → Authentication → Add User

// Admin
admin@admin.com / Admin123!

// Rescuers
team1@rescue.com / Rescue123!
team2@rescue.com / Rescue123!

// Citizens  
john@gmail.com / Citizen123!
jane@yahoo.com / Citizen123!
```

### Verification Steps

1. **Login with admin@admin.com**
   - Should see Admin Dashboard
   - Should see 4 tabs: Overview, All Tickets, Analytics, Settings
   - Should see system-wide statistics

2. **Login with team1@rescue.com**
   - Should see Rescue Team Dashboard
   - Should see ticket filters
   - Should be able to update ticket status

3. **Login with john@gmail.com**
   - Should see Citizen Interface
   - Should see 3 bottom tabs: Home, Submit Request, My Requests
   - Should be able to submit help request

## Troubleshooting

### User sees wrong interface

**Problem**: Admin user sees Citizen interface

**Solution**: Check email contains `@admin`
- ✅ Correct: `manager@admin.com`
- ❌ Wrong: `admin@gmail.com`

### Can't update ticket

**Problem**: Citizen trying to update ticket status

**Solution**: Only Rescuers and Admins can update
- Create account with `@rescue` or `@admin` email

### Firestore permission denied

**Problem**: "Missing or insufficient permissions"

**Solution**: 
1. Check Firestore rules are deployed
2. Verify user is authenticated
3. Check email pattern matches role requirements

---

## Summary

The role-based routing system provides:
- **Automatic role detection** based on email patterns
- **Three distinct interfaces** for different user types
- **Secure access control** via Firestore rules
- **Simple user management** without complex configuration

This makes the app intuitive while maintaining security and proper access control for emergency response operations.
