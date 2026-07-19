# API Documentation - Flutter to Odoo Integration

## Overview

This document describes the API contract between the Flutter mobile app and the Odoo 18 backend. All endpoints use JSON-RPC 2.0 format.

## Base Configuration

```dart
Base URL: Configured by user on first launch
Format: https://your-odoo-server.com
```

## Request Format

All API requests follow this structure:

```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    // Endpoint-specific parameters
  },
  "id": 1234567890
}
```

## Response Format

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

## Authentication

### Login
**Endpoint:** `/api/auth/login`  
**Method:** POST  
**Auth Required:** No

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "login": "user@example.com",
    "password": "userpassword"
  },
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user_id": 123,
    "name": "John Doe",
    "email": "user@example.com",
    "phone": "+1234567890",
    "partner_id": 456,
    "session_id": "abc123xyz..."
  }
}
```

**Flutter Usage:**
```dart
final response = await authService.login(
  email: 'user@example.com',
  password: 'password',
);
```

---

### Signup
**Endpoint:** `/api/auth/signup`  
**Method:** POST  
**Auth Required:** No

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "phone": "+1234567890"  // Optional
  },
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Signup successful",
  "data": {
    "user_id": 124,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "partner_id": 457,
    "session_id": "def456uvw..."
  }
}
```

---

### Logout
**Endpoint:** `/api/auth/logout`  
**Method:** POST  
**Auth Required:** Yes

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

## Company Information

### Get Company Info
**Endpoint:** `/api/company/info`  
**Method:** POST  
**Auth Required:** No

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "name": "Company Name",
    "email": "info@company.com",
    "phone": "+1234567890",
    "street": "123 Main St",
    "street2": "Suite 100",
    "city": "New York",
    "zip": "10001",
    "country": "United States",
    "website": "https://www.company.com",
    "logo": "base64_encoded_image_string"
  }
}
```

**Flutter Usage:**
```dart
final response = await appointmentService.getCompanyInfo();
Company company = response.data;
```

---

## Appointments

### List All Appointments
**Endpoint:** `/api/appointments/list`  
**Method:** POST  
**Auth Required:** No

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "name": "General Consultation",
      "description": "30 minute consultation",
      "location": "Office 101",
      "fees": 50.00,
      "appointment_type": "online",
      "appointment_type_display": "Online",
      "slot_duration": 30,
      "buffer_time": 5,
      "image": "base64_encoded_image_string",
      "user_ids": [10, 11],
      "users": [
        {
          "id": 10,
          "name": "Dr. Smith",
          "timezone": "America/New_York"
        }
      ]
    }
  ]
}
```

---

### Get Appointment Details
**Endpoint:** `/api/appointments/<appointment_id>`  
**Method:** POST  
**Auth Required:** No

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": 1,
    "name": "General Consultation",
    "description": "30 minute consultation",
    "location": "Office 101",
    "fees": 50.00,
    "appointment_type": "online",
    "appointment_type_display": "Online",
    "slot_duration": 30,
    "buffer_time": 5,
    "image": "base64_encoded_image_string",
    "start_time": 9.0,
    "end_time": 17.0,
    "user_ids": [10],
    "users": [
      {
        "id": 10,
        "name": "Dr. Smith",
        "timezone": "America/New_York"
      }
    ],
    "available_days": {
      "mon": true,
      "tue": true,
      "wed": true,
      "thu": true,
      "fri": true,
      "sat": false,
      "sun": false
    }
  }
}
```

---

### Get Available Time Slots
**Endpoint:** `/api/appointments/timeslots`  
**Method:** POST  
**Auth Required:** No

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "appointment_id": 1,
    "date": "2025-10-15",
    "user_id": 10  // Optional
  },
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": 101,
      "name": "09:00 – 09:30",
      "day": "tue",
      "is_booked": false
    },
    {
      "id": 102,
      "name": "09:30 – 10:00",
      "day": "tue",
      "is_booked": true
    }
  ]
}
```

**Flutter Usage:**
```dart
final response = await appointmentService.getTimeSlots(
  appointmentId: 1,
  date: '2025-10-15',
  userId: 10,
);
List<TimeSlot> slots = response.data;
```

---

### Book Appointment
**Endpoint:** `/api/appointments/book`  
**Method:** POST  
**Auth Required:** Yes

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "appointment_id": 1,
    "date": "2025-10-15",
    "slot_id": 101,
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "+1234567890",
    "description": "First time visit",  // Optional
    "user_id": 10  // Optional
  },
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Appointment booked successfully",
  "data": {
    "booking_id": 500,
    "booking_reference": "John Doe",
    "status": "confirmed"
  }
}
```

---

## Bookings

### Get My Bookings
**Endpoint:** `/api/bookings/my`  
**Method:** POST  
**Auth Required:** Yes

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": 500,
      "name": "John Doe",
      "appointment_name": "General Consultation",
      "appointment_type": "Online",
      "location": "Office 101",
      "date": "2025-10-15",
      "time_slot": "09:00 – 09:30",
      "start": "2025-10-15 09:00:00",
      "stop": "2025-10-15 09:30:00",
      "fees": 50.00,
      "state": "draft",
      "state_display": "Draft",
      "description": "First time visit"
    }
  ]
}
```

---

### Cancel Booking
**Endpoint:** `/api/bookings/<booking_id>/cancel`  
**Method:** POST  
**Auth Required:** Yes

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking cancelled successfully"
}
```

---

## Profile

### Get Profile
**Endpoint:** `/api/profile`  
**Method:** POST  
**Auth Required:** Yes

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "user_id": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "street": "123 Main St",
    "street2": "Apt 4B",
    "city": "New York",
    "zip": "10001",
    "country": "United States"
  }
}
```

---

### Update Profile
**Endpoint:** `/api/profile/update`  
**Method:** POST  
**Auth Required:** Yes

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "name": "John Doe",
    "phone": "+1234567890",
    "street": "456 Oak Ave",
    "street2": "Suite 5",
    "city": "Boston",
    "zip": "02101"
  },
  "id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

---

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "message": "Error message description",
  "code": 400
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| 400  | Bad Request - Invalid parameters |
| 401  | Unauthorized - Invalid credentials |
| 403  | Forbidden - Insufficient permissions |
| 404  | Not Found - Resource doesn't exist |
| 409  | Conflict - Duplicate entry |
| 500  | Internal Server Error |

### Error Examples

**Invalid Credentials:**
```json
{
  "success": false,
  "message": "Invalid credentials",
  "code": 401
}
```

**Missing Parameters:**
```json
{
  "success": false,
  "message": "appointment_id and date are required",
  "code": 400
}
```

**User Already Exists:**
```json
{
  "success": false,
  "message": "User with this email already exists",
  "code": 409
}
```

---

## Authentication Flow

### Session Management

1. **Login/Signup**: Returns `session_id`
2. **Store Session**: App saves `session_id` locally
3. **Authenticated Requests**: Include session in Cookie header
4. **Logout**: Invalidates session

### Example with Session

```http
POST /api/bookings/my HTTP/1.1
Host: your-server.com
Content-Type: application/json
Cookie: session_id=abc123xyz...

{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {},
  "id": 1
}
```

---

## Testing APIs

### Using cURL

```bash
# Login
curl -X POST https://your-server.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "call",
    "params": {
      "login": "user@example.com",
      "password": "password"
    },
    "id": 1
  }'

# Get Appointments
curl -X POST https://your-server.com/api/appointments/list \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "call",
    "params": {},
    "id": 1
  }'
```

### Using Postman

1. Create new POST request
2. Set URL to endpoint
3. Set Headers: `Content-Type: application/json`
4. Set Body (raw JSON):
   ```json
   {
     "jsonrpc": "2.0",
     "method": "call",
     "params": { ... },
     "id": 1
   }
   ```
5. Send request

---

## Best Practices

1. **Always validate responses** before using data
2. **Handle errors gracefully** with user-friendly messages
3. **Store sensitive data securely** (use encrypted storage for tokens)
4. **Implement request timeouts** (default: 30 seconds)
5. **Add retry logic** for failed requests
6. **Log API calls** for debugging (remove in production)
7. **Use HTTPS** in production for security

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-13 | Initial API specification |

---

For implementation details, see the Flutter service files:
- `lib/services/api_service.dart`
- `lib/services/auth_service.dart`
- `lib/services/appointment_service.dart`
