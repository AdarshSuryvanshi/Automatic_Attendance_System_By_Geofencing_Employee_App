# Automatic Attendance System by Geofencing - Employee App

A Flutter-based mobile application that enables employees and students to automatically track their attendance using geofencing technology. This app works seamlessly with the admin panel to provide a complete attendance management solution.

## 🌟 Overview

The Employee App automatically marks attendance when users enter designated geographical areas (geofences) set up by administrators. No manual check-in required - just carry your phone and your attendance is tracked automatically!

## 🚀 Key Features

### Automatic Attendance
- **Geofence Detection**: Automatic check-in/check-out when entering/leaving designated areas
- **Real-time Tracking**: Live location monitoring for accurate attendance marking
- **Smart Notifications**: Push notifications for attendance confirmations
- **Offline Support**: Queue attendance data when offline and sync when connected
- **Multiple Locations**: Support for multiple office/campus locations

### User Dashboard
- **Today's Status**: Quick view of today's attendance status
- **Attendance History**: View past attendance records with dates and times
- **Monthly Summary**: Overview of monthly attendance statistics
- **Leave Requests**: Submit and track leave applications
- **Profile Management**: Update personal information and preferences

### Location Features
- **GPS Tracking**: High-precision location tracking
- **Background Location**: Continue tracking even when app is in background
- **Geofence Alerts**: Visual and audio alerts when entering/leaving work areas
- **Location History**: Track your location history throughout the day
- **Battery Optimization**: Efficient location tracking to preserve battery life

### Reports & Analytics
- **Personal Reports**: View individual attendance reports
- **Time Tracking**: Track total hours spent at work locations
- **Attendance Trends**: Visual charts showing attendance patterns
- **Export Data**: Export personal attendance data
- **Performance Metrics**: View attendance percentage and streaks

## 📱 Screenshots

<!-- Add your app screenshots here -->
*Screenshots will be added soon*

## 🛠️ Technologies Used

- **Frontend**: Flutter (Dart)
- **Database**: Firebase Firestore / SQLite
- **Authentication**: Firebase Authentication
- **Location Services**: Geolocator, Location
- **Background Processing**: WorkManager / Background Fetch
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Maps Integration**: Google Maps API
- **State Management**: Provider / Bloc
- **Local Storage**: Shared Preferences / Hive

## 📋 Prerequisites

Before running this application, make sure you have:

- Flutter SDK (version 3.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase project setup
- Google Maps API key
- Android/iOS development environment
- Physical device for location testing (recommended)

## 🚀 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/AdarshSuryvanshi/Automatic_Attendance_System_By_Geofencing_Employee_App.git
   cd Automatic_Attendance_System_By_Geofencing_Employee_App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication, Firestore, and Cloud Messaging in Firebase Console

4. **Configure Google Maps**
   - Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_API_KEY_HERE"/>
   ```
   - Add API key in `ios/Runner/AppDelegate.swift`

5. **Configure Location Permissions**
   - Update `android/app/src/main/AndroidManifest.xml` with location permissions
   - Update `ios/Runner/Info.plist` with location usage descriptions

6. **Run the application**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Environment Setup
Create a `.env` file in the root directory:
```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
API_BASE_URL=your_api_base_url
```

### Required Permissions
#### Android
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `INTERNET`
- `WAKE_LOCK`

#### iOS
- Location When In Use Usage Description
- Location Always And When In Use Usage Description
- Background App Refresh

## 📚 How to Use

### First Time Setup
1. **Download & Install**: Install the app from your organization
2. **Login**: Use your employee credentials provided by admin
3. **Enable Permissions**: Allow location access for automatic tracking
4. **Profile Setup**: Complete your profile information

### Daily Usage
1. **Automatic Check-in**: App automatically detects when you arrive at work
2. **Work Tracking**: Your location is monitored throughout the day
3. **Automatic Check-out**: App detects when you leave the workplace
4. **View Status**: Check your attendance status anytime in the app

### Key Features Usage
- **Dashboard**: View today's attendance and quick stats
- **History**: Check past attendance records
- **Leaves**: Apply for leaves directly from the app
- **Reports**: View your attendance analytics
- **Settings**: Customize notification preferences

## 🏗️ Project Structure

```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── attendance_model.dart
│   ├── leave_model.dart
│   └── location_model.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── home_screen.dart
│   ├── attendance/
│   │   ├── attendance_history.dart
│   │   └── attendance_details.dart
│   ├── leaves/
│   │   ├── leave_application.dart
│   │   └── leave_history.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── location_service.dart
│   ├── attendance_service.dart
│   ├── notification_service.dart
│   └── api_service.dart
├── widgets/
│   ├── common/
│   ├── attendance/
│   └── charts/
└── utils/
    ├── constants.dart
    ├── helpers.dart
    ├── location_utils.dart
    └── validators.dart
```

## 🔐 Security & Privacy

### Data Protection
- All location data is encrypted in transit
- Personal information is securely stored
- Location tracking only during work hours (configurable)
- Option to disable tracking outside work premises

### Privacy Controls
- View and control what data is shared
- Option to request data deletion
- Transparent privacy policy
- Minimal data collection approach

## 🔧 Troubleshooting

### Common Issues

**Location Not Detected**
- Ensure GPS is enabled
- Check location permissions
- Try restarting the app
- Check if geofence is properly configured

**Attendance Not Marking**
- Verify you're within the designated area
- Check internet connectivity
- Ensure background app refresh is enabled
- Contact your administrator

**Battery Drain**
- App is optimized for minimal battery usage
- Adjust location accuracy in settings if needed
- Enable battery optimization exclusion for the app

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [Admin Dashboard App](https://github.com/AdarshSuryvanshi/Automatic_Attendance_System_By_Geofencing_Admin_App) - Administrative panel for managing the system
- [Web Dashboard](link-to-web-dashboard) - Web-based management interface

## 📞 Support

Need help? We're here for you:

- 📧 Email: [your-email@example.com]
- 🐛 Bug Reports: [GitHub Issues](https://github.com/AdarshSuryvanshi/Automatic_Attendance_System_By_Geofencing_Employee_App/issues)
- 💬 Feature Requests: [GitHub Discussions]

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Firebase for backend services
- Google Maps team for location services
- All beta testers who helped improve the app
- Open source community for various packages used

## 📱 App Store Links

<!-- Add when published -->
- 🍎 [iOS App Store](#) (Coming Soon)
- 🤖 [Google Play Store](#) (Coming Soon)

## 🎯 Roadmap

### Upcoming Features
- [ ] Face recognition for enhanced security
- [ ] Offline mode improvements
- [ ] Apple Watch / Wear OS support
- [ ] Voice commands integration
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Biometric authentication
- [ ] Integration with calendar apps
- [ ] Smart suggestions for leave planning
- [ ] Team collaboration features

### Version History
- **v1.0.0** - Initial release with core geofencing features
- **v1.1.0** - Added attendance analytics and reports
- **v1.2.0** - Improved battery optimization and background tracking

---

## 🌟 Why Choose This App?

✅ **Zero Hassle**: No manual check-in/check-out required  
✅ **High Accuracy**: GPS-based precise location tracking  
✅ **Battery Friendly**: Optimized for all-day usage  
✅ **Secure**: Enterprise-grade security and privacy  
✅ **User Friendly**: Intuitive interface and smooth experience  
✅ **Reliable**: Works offline and syncs automatically  

---

**⭐ Rate us 5 stars if this app makes your attendance tracking effortless!**

**🔔 Enable notifications to stay updated with your attendance status**

---

*Made with ❤️ using Flutter for seamless attendance tracking*
