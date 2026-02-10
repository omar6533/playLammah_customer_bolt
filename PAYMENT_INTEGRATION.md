# Payment Integration with Moyasar

This document explains the payment integration using Moyasar API.

## Setup

### 1. Environment Variables

Add your Moyasar API key to the `.env` file:

```
MOYASAR_API_KEY=sk_test_your_actual_api_key_here
```

Replace `sk_test_your_actual_api_key_here` with your actual Moyasar API key from the [Moyasar Dashboard](https://dashboard.moyasar.com/).

### 2. Run Flutter Commands

After adding the API key, run the following commands in your terminal:

```bash
# Install dependencies
flutter pub get

# Generate routes
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## How It Works

### 1. Payment Flow

1. User selects a game package from the purchase dialog
2. The app creates a Moyasar invoice with user and package details
3. User is redirected to Moyasar's payment page
4. After payment:
   - **Success**: User is redirected to the success screen
   - **Failure**: User is redirected to the failure screen

### 2. Components

#### Payment Service (`lib/services/payment_service.dart`)
- Handles API calls to Moyasar
- Creates payment invoices
- Returns payment URL for user to complete payment

#### Purchase Dialog (`lib/widgets/purchase_dialog.dart`)
- Displays available game packages
- Handles package selection
- Initiates payment flow
- Opens payment URL in external browser

#### Success Screen (`lib/screens/payment_success_screen.dart`)
- Displayed after successful payment
- Shows confirmation message
- Allows user to return to landing page or start a new game

#### Failure Screen (`lib/screens/payment_failure_screen.dart`)
- Displayed after failed payment
- Shows error message
- Allows user to return to landing page or retry

### 3. Metadata Sent to Moyasar

When creating a payment invoice, the following metadata is sent:

```dart
{
  'user_id': userId,
  'user_email': userProfile.email,
  'user_name': userProfile.name,
  'user_mobile': userProfile.mobile,
  'package_id': package.id,
  'package_title': package.title,
  'games_count': package.gameCount.toString(),
  'price': package.price,
}
```

### 4. Available Packages

Default packages are defined in `PurchaseDialog.getDefaultPackages()`:

- **10 Games**: SAR 230
- **5 Games**: SAR 122
- **2 Games**: SAR 55
- **1 Game**: SAR 30

### 5. Firebase Integration

When you connect packages from Firebase, use the `packages` parameter:

```dart
PurchaseDialog.show(
  context: context,
  packages: packagesFromFirebase, // Your Firebase data
  moyasarApiKey: AppConfig.moyasarApiKey,
  callbackUrl: AppConfig.paymentCallbackUrl,
  successUrl: AppConfig.paymentSuccessUrl,
  onPackageSelected: (package) {
    // Handle post-selection logic
  },
);
```

## Testing

1. Use test API keys from Moyasar for testing
2. Test with Moyasar's test cards:
   - Success: 4111 1111 1111 1111
   - Failure: 4000 0000 0000 0002

## Production

1. Replace test API key with production key in `.env`
2. Update callback URLs in `lib/config/app_config.dart`:
   - `paymentCallbackUrl`
   - `paymentSuccessUrl`
3. Implement webhook handler to update user's game count in Firebase

## Security Notes

- Never commit your production API key to version control
- API key is stored in `.env` file (add to `.gitignore`)
- Payment processing happens on Moyasar's secure servers
- User data is encrypted in transit
