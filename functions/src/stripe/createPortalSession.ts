import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

export const createPortalSession = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated',
      );
    }

    try {
      // Get user's Stripe customer ID from Firestore
      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(context.auth.uid)
        .get();
      const userData = userDoc.data();
      const customerId = userData?.stripeCustomerId;

      if (!customerId) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'No Stripe customer found for user',
        );
      }

      // Create portal session
      const session = await stripe.billingPortal.sessions.create({
        customer: customerId,
        return_url: `${functions.config().app.url}/account`,
      });

      return {
        url: session.url,
      };
    } catch (error) {
      console.error('Error creating portal session:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error creating portal session',
      );
    }
  },
); 