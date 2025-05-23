# Billing & Subscription System

## Overview

The billing system uses Stripe for payment processing and subscription management. It supports two plans:

1. **Basic Plan** ($9.99/month)
   - Up to 20 meetings per day
   - Basic booking features
   - Email notifications
   - Calendar integration

2. **Pro Plan** ($29.99/month)
   - Unlimited meetings
   - Advanced booking features
   - Smart tags & analytics
   - CSV export
   - Priority support

## Architecture

### Flutter App

- `SubscriptionService`: Handles Stripe integration and subscription management
- `SubscribeScreen`: UI for plan selection and checkout
- Feature gating based on subscription status

### Cloud Functions

- `createCheckoutSession`: Creates a Stripe checkout session
- `createPortalSession`: Creates a Stripe customer portal session
- `handleStripeWebhook`: Processes Stripe webhook events

### Firestore Schema

```typescript
users/{userId}/
  stripeCustomerId: string
  subscription/
    current/
      plan: 'basic' | 'pro'
      status: 'active' | 'canceled' | 'past_due'
      stripeSubscriptionId: string
      currentPeriodEnd: timestamp
      cancelAtPeriodEnd: boolean
```

## Implementation Details

### Subscription Flow

1. User selects a plan in `SubscribeScreen`
2. App calls `createCheckoutSession` with the selected price ID
3. Stripe Checkout opens for payment
4. On successful payment, Stripe sends a webhook event
5. `handleStripeWebhook` updates the user's subscription status in Firestore
6. App UI updates to reflect new subscription status

### Feature Gating

Features are gated based on the user's subscription plan:

```dart
final canAccessFeature = await subscriptionService.isFeatureAvailable('feature_name');
if (!canAccessFeature) {
  // Show upgrade prompt
}
```

### Customer Portal

Users can manage their subscription through the Stripe Customer Portal:

1. App calls `createPortalSession`
2. User is redirected to the portal
3. User can update payment method, cancel subscription, etc.
4. Changes are reflected in the app via webhook events

## Security

- All Stripe API calls are made through Cloud Functions
- Webhook signature verification ensures events are from Stripe
- Firestore security rules protect subscription data
- No sensitive data is stored in the app

## Testing

1. Unit tests for `SubscriptionService`
2. Integration tests for checkout flow
3. Webhook testing using Stripe CLI

## Deployment

1. Set up Stripe products and prices
2. Configure webhook endpoint
3. Set environment variables in Firebase
4. Deploy Cloud Functions
5. Update app with Stripe publishable key

## Monitoring

- Monitor webhook events in Stripe Dashboard
- Track subscription metrics in Firebase Analytics
- Set up alerts for failed payments
- Monitor customer portal usage 