# Firebase Cloud Messaging (FCM) Setup Guide

This guide will help you set up and test Firebase Cloud Messaging in your iOS app.

## What's Been Implemented

### 1. App Delegate Setup (`GoogsApp.swift`)

- ✅ Firebase Messaging delegate
- ✅ Notification permission request
- ✅ FCM token handling
- ✅ APNs token registration
- ✅ Notification presentation in foreground

### 2. FCM Service (`Services/FCMService.swift`)

- ✅ Token management
- ✅ Permission handling
- ✅ Topic subscription
- ✅ Test notifications
- ✅ Status monitoring

### 3. Backend Integration (`Services/BackendAPI.swift`)

- ✅ FCM token update endpoint
- ✅ Token storage and retrieval

### 4. Test Interface (`Views/FCMTestView.swift`)

- ✅ Status display
- ✅ Permission testing
- ✅ Token management
- ✅ Topic subscription
- ✅ Debug tools

## Testing Your FCM Setup

### Step 1: Build and Run

1. Build your app in Xcode
2. Run on a physical device (FCM doesn't work in simulator)
3. Navigate to **Notifications** in your app's side menu
4. Tap **"Open FCM Test"**

### Step 2: Check Initial Status

The FCM Test view will show:

- **FCM Token**: Should display a long string or "Not available"
- **Registered**: Should show "Yes" if token is available
- **Permission**: Should show current permission status

### Step 3: Request Permission

1. Tap **"Request Permission"**
2. Allow notifications when prompted
3. Check that status updates to "Authorized"

### Step 4: Test Local Notifications

1. Tap **"Send Test Notification"**
2. Wait 5 seconds
3. You should see a notification appear

### Step 5: Check Console Output

1. Tap **"Print Status to Console"**
2. Check Xcode console for detailed FCM status
3. Look for messages like:
   ```
   Firebase registration token: [long-token-string]
   APNs token set for FCM
   ```

## Expected Console Output

When FCM is working correctly, you should see:

```
Notification permission granted
Firebase registration token: [your-fcm-token]
APNs token set for FCM
Sending FCM token to backend: [your-fcm-token]
```

## Troubleshooting

### Issue: "FCM Token: Not available"

**Possible causes:**

- App not running on physical device
- Firebase configuration issue
- Network connectivity problem

**Solutions:**

1. Ensure you're running on a physical device
2. Check Firebase Console → Project Settings → Cloud Messaging
3. Verify `GoogleService-Info.plist` is properly configured

### Issue: "Permission: Denied"

**Solutions:**

1. Go to iOS Settings → Googs → Notifications
2. Enable notifications
3. Or delete and reinstall the app

### Issue: No console output

**Solutions:**

1. Check that Firebase is properly initialized
2. Verify `FirebaseApp.configure()` is called
3. Check network connectivity

## Backend Integration

### FCM Token Endpoint

Your backend should implement:

```
POST /auth/fcm-token
Authorization: Bearer [jwt-token]
Content-Type: application/json

{
  "fcm_token": "your-fcm-token-here"
}
```

### Sending Notifications

Once tokens are stored, you can send notifications from your backend using Firebase Admin SDK:

```python
# In your backend
from firebase_admin import messaging

def send_notification(fcm_token, title, body):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=fcm_token
    )

    response = messaging.send(message)
    return response
```

## Advanced Features

### Topic Subscription

Users can subscribe to topics for broadcast notifications:

```swift
// Subscribe to general notifications
fcmService.subscribe(toTopic: "googs_notifications")

// Subscribe to user-specific notifications
fcmService.subscribe(toTopic: "user_\(userId)")
```

### Custom Notification Handling

The app delegate handles:

- Foreground notifications (shows banner)
- Notification taps (can trigger navigation)
- Deep linking (extract data from userInfo)

### Background Notifications

The app is configured to receive notifications when in background via:

- `UIBackgroundModes` in Info.plist
- `FirebaseAppDelegateProxyEnabled = false`

## Security Considerations

1. **Token Storage**: FCM tokens are stored in UserDefaults (not Keychain) as they're not sensitive
2. **Token Refresh**: Tokens automatically refresh when needed
3. **Backend Validation**: Always validate FCM tokens on your backend
4. **Topic Security**: Use server-side topic subscription for sensitive topics

## Next Steps

1. **Test the setup** using the FCM Test view
2. **Implement backend endpoint** for storing FCM tokens
3. **Set up notification sending** from your backend
4. **Add notification handling** for specific app actions
5. **Implement topic-based notifications** for different user segments

## Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** → **Cloud Messaging**
4. Upload your APNs certificate (if using APNs)
5. Or use Firebase's automatic certificate management

## Testing with Firebase Console

1. Go to Firebase Console → **Cloud Messaging**
2. Click **"Send your first message"**
3. Enter notification details
4. Under **Target**, select **"Single device"**
5. Paste your FCM token (copy from the test view)
6. Send the message
7. Check that notification appears on your device

Your FCM setup is now complete and ready for testing!
