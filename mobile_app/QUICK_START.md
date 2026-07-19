# Quick Start Guide

Get up and running with the Odoo Appointment App in 5 minutes!

## Prerequisites

- Flutter SDK installed (run `flutter doctor` to verify)
- An Android emulator or iOS simulator running
- Access to an Odoo 18 server with the appointment module

## Step 1: Get Dependencies

```bash
cd odoo_appointment_app
flutter pub get
```

## Step 2: Run the App

```bash
flutter run
```

## Step 3: Configure Server

When the app launches:

1. You'll see a "Server Configuration" screen
2. Enter your Odoo server URL (e.g., `https://yourserver.odoo.com`)
3. Click "Save & Continue"

## Step 4: Sign Up or Login

### New User (Sign Up)
1. Click "Sign Up" on the login screen
2. Fill in:
   - Full Name
   - Email
   - Phone (optional)
   - Password
3. Click "Sign Up"

### Existing User (Login)
1. Enter your email and password
2. Click "Sign In"

## Step 5: Book an Appointment

1. Browse available appointments on the home screen
2. Tap on an appointment card
3. Select a date from the calendar
4. Choose an available time slot
5. Fill in your details
6. Click "Confirm Booking"

Done! 🎉

## Viewing Your Bookings

- Tap the "My Bookings" tab at the bottom
- See all your appointments
- Cancel if needed

## Your Profile

- Tap the "Profile" tab
- View your information
- See company details
- Logout when done

## Troubleshooting

**Can't connect to server?**
- Check your internet connection
- Verify the server URL is correct
- Make sure the server is running

**App crashes?**
```bash
flutter clean
flutter pub get
flutter run
```

**Need help?**
- Check README.md for detailed documentation
- Check SETUP_GUIDE.md for installation help
- Check API_DOCUMENTATION.md for API details

## Next Steps

- Customize the theme in `lib/main.dart`
- Add your app icon
- Build for production: `flutter build apk` or `flutter build ios`

Happy booking! 📅
