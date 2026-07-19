# Odoo Appointment Booking App

A professional Flutter mobile application for booking appointments integrated with Odoo 18.

## Features

- 🔐 User Authentication (Login & Signup)
- 📅 Browse Available Appointments/Services
- 🕒 Interactive Calendar for Date Selection
- ⏰ Real-time Time Slot Availability
- 📝 Easy Booking with User Details
- 📱 View & Manage Your Bookings
- 👤 User Profile with Company Information
- 🎨 Responsive Design (Mobile, Tablet, Desktop)
- 🔄 Offline-first with Local Storage
- 🏢 Multi-user Support per Service

## Architecture

The app follows **MVC (Model-View-Controller)** architecture pattern with Provider for state management:

```
lib/
├── config/
│   └── app_config.dart           # App configuration & endpoints
├── models/
│   ├── user_model.dart           # User data model
│   ├── appointment_model.dart    # Appointment data model
│   ├── time_slot_model.dart      # Time slot data model
│   ├── booking_model.dart        # Booking data model
│   ├── company_model.dart        # Company data model
│   └── api_response_model.dart   # API response wrapper
├── services/
│   ├── api_service.dart          # HTTP/API communication
│   ├── storage_service.dart      # Local data persistence
│   ├── auth_service.dart         # Authentication logic
│   └── appointment_service.dart  # Appointment business logic
├── providers/
│   ├── auth_provider.dart        # Auth state management
│   └── appointment_provider.dart # Appointment state management
├── screens/
│   ├── splash_screen.dart
│   ├── setup_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── appointments/
│   │   ├── appointments_list_screen.dart
│   │   ├── appointment_detail_screen.dart
│   │   ├── time_slot_screen.dart
│   │   └── booking_form_screen.dart
│   ├── bookings/
│   │   └── my_bookings_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── main.dart                      # App entry point
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile deployment)
- Odoo 18 Server with the custom appointment module installed

### Installation

1. **Clone the repository**
   ```bash
   cd odoo_appointment_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

On first launch, the app will prompt you to enter your Odoo server URL:

1. Launch the app
2. Enter your Odoo server URL (e.g., `https://your-server.odoo.com`)
3. Click "Save & Continue"

The configuration is saved locally and persists across app restarts.

## Odoo Backend Requirements

### Required Odoo Module

The Flutter app requires the custom Odoo appointment module with the following API endpoints:

#### Authentication APIs
- `POST /api/auth/login` - User login
- `POST /api/auth/signup` - User registration
- `POST /api/auth/logout` - User logout

#### Appointment APIs
- `POST /api/company/info` - Get company information & logo
- `POST /api/appointments/list` - List all appointments
- `POST /api/appointments/<id>` - Get appointment details
- `POST /api/appointments/timeslots` - Get available time slots
- `POST /api/appointments/book` - Book an appointment

#### Booking APIs
- `POST /api/bookings/my` - Get user's bookings
- `POST /api/bookings/<id>/cancel` - Cancel a booking

#### Profile APIs
- `POST /api/profile` - Get user profile
- `POST /api/profile/update` - Update user profile

### API Request Format

All API calls use JSON-RPC 2.0 format:

```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "login": "user@example.com",
    "password": "password"
  },
  "id": 1234567890
}
```

### API Response Format

```json
{
  "success": true,
  "message": "Success message",
  "data": { 
    // Response data
  },
  "code": 200
}
```

## App Flow

1. **Splash Screen** → Checks configuration and authentication
2. **Setup Screen** (first launch) → Configure Odoo server URL
3. **Login/Signup** → User authentication
4. **Home Screen** → Bottom navigation with 3 tabs:
   - **Appointments** - Browse available services
   - **My Bookings** - View and manage bookings
   - **Profile** - User and company information

### Booking Flow

1. Select an appointment from the list
2. Choose a date from the calendar
3. Select an available time slot
4. Fill in booking details
5. Confirm booking
6. View in "My Bookings" tab

## Key Features Explained

### Responsive Design

The app automatically adapts to different screen sizes:
- **Mobile (< 600px)**: Single column layout
- **Tablet (600-900px)**: 2-column grid
- **Desktop (> 900px)**: 3-column grid with side-by-side views

### State Management

Uses Provider pattern for:
- **AuthProvider**: Manages authentication state
- **AppointmentProvider**: Manages appointments, bookings, and company data

### Local Storage

Uses SharedPreferences for:
- User session persistence
- Server URL configuration
- Auto-login capability

### Image Handling

Supports base64 encoded images from Odoo:
- Company logos
- Appointment service images
- Automatic fallback for missing images

## Customization

### Changing Theme Colors

Edit `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change this color
    brightness: Brightness.light,
  ),
  ...
)
```

### Adding New Features

1. Create model in `lib/models/`
2. Add API call in appropriate service
3. Create provider if needed
4. Build UI in `lib/screens/`
5. Add route in `lib/main.dart`

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Production

### Android

```bash
flutter build apk --release
# OR for app bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if Odoo server URL is correct
   - Ensure server is accessible from your device
   - Check firewall settings

2. **Authentication Failed**
   - Verify credentials
   - Check if user has portal access
   - Ensure API endpoints are enabled

3. **Images Not Loading**
   - Verify base64 encoding in Odoo
   - Check network connectivity
   - Clear app cache

### Debug Mode

Enable debug logging in `lib/services/api_service.dart`:

```dart
final Logger _logger = Logger(
  level: Level.debug, // Change to Level.verbose for more details
);
```

## Security Considerations

- Never hardcode API credentials
- Use HTTPS for production servers
- Implement proper session management
- Validate all user inputs
- Handle sensitive data securely

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Dependencies

- `provider` - State management
- `http` - HTTP client
- `shared_preferences` - Local storage
- `table_calendar` - Calendar widget
- `intl` - Internationalization
- `logger` - Logging

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- GitHub Issues: [Create an issue]
- Email: support@yourcompany.com

## Version History

- **1.0.0** (2025-10-13)
  - Initial release
  - Core booking functionality
  - User authentication
  - Profile management
  - Responsive design

---

Built with ❤️ using Flutter
