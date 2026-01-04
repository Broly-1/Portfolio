# Portfolio Admin App

This is the admin application for managing the Hassan Kamran portfolio website content.

## 🔐 Authentication

The app now has secure login functionality. Only the admin email `hassangaming111@gmail.com` can access the admin panel.

### Firebase Setup Required:

1. **Enable Firebase Authentication:**
   - Go to Firebase Console → Authentication
   - Click "Get Started"
   - Enable "Email/Password" sign-in method

2. **Create Admin Account:**
   - In Authentication → Users tab
   - Click "Add User"
   - Email: `hassangaming111@gmail.com`
   - Password: (Choose a secure password - you'll use this to login)

3. **Update Firestore Security Rules:**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /about/{document=**} {
         allow read: if true;
         allow write: if request.auth != null && 
                      request.auth.token.email == 'hassangaming111@gmail.com';
       }
     }
   }
   ```

4. **Update Storage Security Rules:**
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /about/{allPaths=**} {
         allow read: if true;
         allow write: if request.auth != null && 
                      request.auth.token.email == 'hassangaming111@gmail.com';
       }
     }
   }
   ```

## Features

### ✅ Implemented
- **🔐 Secure Login**: Email/password authentication with admin-only access
- **Edit About Section**: Update profile information including:
  - Profile image upload
  - Title/Role
  - Bio/Description
  - Location
  - Email
  - GitHub URL
  - LinkedIn URL
- **🚪 Logout**: Secure logout functionality

### 🚧 Coming Soon
- Projects Management
- Skills Management
- Contact Information Management

## Firebase Setup

The app uses Firebase for data storage and image hosting:

- **Firebase Authentication**: Secure admin login
  - Admin Email: `hassangaming111@gmail.com`
  
- **Firestore Database**: Stores all text content
  - Collection: `about`
  - Document: `main`
  
- **Firebase Storage**: Stores uploaded images
  - Folder: `about/` (for profile images)

## Running the Admin App

To run the admin app:

```bash
flutter run -t applib/main.dart
```

Or select `applib/main.dart` as the entry point in your IDE.

### First Time Login:
1. Launch the app
2. Enter email: `hassangaming111@gmail.com`
3. Enter the password you created in Firebase Console
4. Click "Login"

## Data Structure

### About Section (Firestore: `about/main`)
```json
{
  "title": "Flutter Developer",
  "bio": "Full bio text...",
  "location": "New York, USA",
  "email": "email@example.com",
  "github": "https://github.com/username",
  "linkedin": "https://linkedin.com/in/username",
  "imageUrl": "https://firebasestorage.googleapis.com/...",
  "updatedAt": "2026-01-04T12:00:00.000Z"
}
```

## Dependencies

- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database operations
- `firebase_storage`: Image storage
- `image_picker`: Select images from gallery
- `flutter/material`: UI framework

## File Structure

```
applib/
├── main.dart                       # Admin app entry point with auth wrapper
├── Homescreen.dart                 # Dashboard with logout button
├── screens/
│   ├── login_screen.dart          # Secure login screen
│   └── edit_about_screen.dart     # Edit About section screen
└── services/
    └── firebase_service.dart       # Firebase operations including auth
```

## Security Features

- ✅ Email-based authentication
- ✅ Admin email validation (only hassangaming111@gmail.com)
- ✅ Automatic session management
- ✅ Protected routes (auto-redirect to login if not authenticated)
- ✅ Firestore security rules enforced on backend
- ✅ Storage security rules for file uploads

## Usage

1. Launch the admin app
2. Login with admin credentials
3. Navigate using the dashboard cards
4. Click on "Edit About Section" to update website content
5. Upload images, edit text fields
6. Click "Save Changes" to publish updates
7. Use logout button in app bar when done

All changes are immediately reflected in the main website after saving.
