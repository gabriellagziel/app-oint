import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

const webhookSecret = functions.config().stripe.webhook_secret;

export const handleStripeWebhook = functions.https.onRequest(
  async (req, res) => {
    const sig = req.headers['stripe-signature'];

    if (!sig) {
      res.status(400).send('Missing stripe-signature header');
      return;
    }

    let event: Stripe.Event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        webhookSecret,
      );
    } catch (err) {
      console.error('Webhook signature verification failed:', err);
      res.status(400).send('Webhook signature verification failed');
      return;
    }

    try {
      switch (event.type) {
        case 'customer.subscription.created':
        case 'customer.subscription.updated':
          await handleSubscriptionChange(event.data.object as Stripe.Subscription);
          break;

        case 'customer.subscription.deleted':
          await handleSubscriptionDeletion(event.data.object as Stripe.Subscription);
          break;

        case 'checkout.session.completed':
          await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session);
          break;
      }

      res.json({ received: true });
    } catch (error) {
      console.error('Error processing webhook:', error);
      res.status(500).send('Webhook handler failed');
    }
  },
);

async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  const customer = await stripe.customers.retrieve(customerId);
  const firebaseUID = customer.metadata.firebaseUID;

  if (!firebaseUID) {
    throw new Error('No Firebase UID found in customer metadata');
  }

  const plan = subscription.items.data[0].price.nickname || 'basic';
  const status = subscription.status;

  await admin
    .firestore()
    .collection('users')
    .doc(firebaseUID)
    .collection('subscription')
    .doc('current')
    .set({
      plan,
      status,
      stripeSubscriptionId: subscription.id,
      currentPeriodEnd: admin.firestore.Timestamp.fromDate(
        new Date(subscription.current_period_end * 1000),
      ),
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
    });
}

async function handleSubscriptionDeletion(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  const customer = await stripe.customers.retrieve(customerId);
  const firebaseUID = customer.metadata.firebaseUID;

  if (!firebaseUID) {
    throw new Error('No Firebase UID found in customer metadata');
  }

  await admin
    .firestore()
    .collection('users')
    .doc(firebaseUID)
    .collection('subscription')
    .doc('current')
    .set({
      plan: 'basic',
      status: 'canceled',
      stripeSubscriptionId: null,
      currentPeriodEnd: admin.firestore.Timestamp.fromDate(
        new Date(subscription.current_period_end * 1000),
      ),
      cancelAtPeriodEnd: false,
    });
}

async function handleCheckoutSessionCompleted(session: Stripe.Checkout.Session) {
  if (!session.subscription) {
    return;
  }

  const subscription = await stripe.subscriptions.retrieve(
    session.subscription as string,
  );
  await handleSubscriptionChange(subscription);
} 