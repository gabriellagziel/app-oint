# Authentication Guide

## Apple Sign-In Integration

### Prerequisites

1. Apple Developer Account
2. Xcode 12.0 or later
3. iOS 13.0 or later target
4. Firebase project with Apple Sign-In enabled

### Setup Instructions

1. **Apple Developer Account Setup**
   - Log in to [Apple Developer Portal](https://developer.apple.com)
   - Create an App ID with Sign In with Apple capability
   - Generate a Service ID for your app
   - Configure the Service ID with your app's domain and bundle ID

2. **Xcode Configuration**
   - Open your project in Xcode
   - Enable "Sign In with Apple" capability
   - Add the following to your `Info.plist`:
     ```xml
     <key>CFBundleURLTypes</key>
     <array>
       <dict>
         <key>CFBundleURLSchemes</key>
         <array>
           <string>your.bundle.id</string>
         </array>
       </dict>
     </array>
     ```

3. **Firebase Configuration**
   - Go to Firebase Console
   - Enable Apple Sign-In in Authentication section
   - Download and add the updated `GoogleService-Info.plist`

### Usage

```dart
final authService = AuthService();

try {
  final user = await authService.signInWithApple();
  if (user != null) {
    // Handle successful sign-in
  }
} catch (e) {
  // Handle error
}
```

### Platform Support

- iOS: Fully supported
- Android: Not supported
- Web: Not supported

### Error Handling

The service handles the following error cases:
- Platform not supported
- User cancellation
- Network errors
- Invalid credentials
- Firebase authentication errors

### Testing

Run the test suite:
```bash
flutter test test/features/auth/services/apple_sign_in_service_test.dart
```

### Monitoring

Apple Sign-In attempts are logged using the `logging` package. Check the logs for:
- Successful sign-ins
- Failed attempts
- Platform-specific issues

#### Real-Time Monitoring

The `AppleSignInMonitor` class provides real-time monitoring capabilities:

1. **Log File Location**
   - Logs are stored in the app's documents directory: `logs/apple_sign_in.log`
   - Format: `[Timestamp] [Level] [Message]`

2. **Failure Detection**
   - Monitors for multiple failures within a 5-minute window
   - Triggers alerts after 3 consecutive failures
   - Maintains a list of recent failures for analysis

3. **Usage Example**
   ```dart
   final monitor = AppleSignInMonitor();
   
   // Log a sign-in attempt
   monitor.logSignInAttempt(
     userId: 'user123',
     success: true,
   );
   
   // Get recent failures
   final failures = monitor.getRecentFailures();
   ```

4. **Alert Configuration**
   - Alerts are triggered when:
     - 3 or more failures occur within 5 minutes
     - Same user experiences multiple failures
   - Alert mechanism can be customized in `_triggerAlert()`

### Troubleshooting

Common issues and solutions:
1. **Sign-In Button Not Showing**
   - Verify Apple Sign-In capability is enabled in Xcode
   - Check bundle ID matches Apple Developer configuration

2. **Authentication Fails**
   - Verify Firebase configuration
   - Check Apple Developer account status
   - Ensure proper scopes are requested

3. **Platform-Specific Issues**
   - iOS: Check minimum deployment target
   - Verify proper entitlements
   - Check provisioning profile 