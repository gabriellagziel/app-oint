import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

export const createCheckoutSession = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated',
      );
    }

    const { priceId, promoCode } = data;
    if (!priceId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Price ID is required',
      );
    }

    try {
      // Get user's email from Firestore
      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(context.auth.uid)
        .get();
      const userData = userDoc.data();
      const email = userData?.email;

      // Create Stripe customer if doesn't exist
      let customerId = userData?.stripeCustomerId;
      if (!customerId) {
        const customer = await stripe.customers.create({
          email,
          metadata: {
            firebaseUID: context.auth.uid,
          },
        });
        customerId = customer.id;

        // Save Stripe customer ID to Firestore
        await admin
          .firestore()
          .collection('users')
          .doc(context.auth.uid)
          .update({
            stripeCustomerId: customerId,
          });
      }

      // Create checkout session
      const session = await stripe.checkout.sessions.create({
        customer: customerId,
        payment_method_types: ['card'],
        line_items: [
          {
            price: priceId,
            quantity: 1,
          },
        ],
        mode: 'subscription',
        success_url: `${functions.config().app.url}/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${functions.config().app.url}/cancel`,
        allow_promotion_codes: true,
        promotion_code: promoCode,
        metadata: {
          firebaseUID: context.auth.uid,
        },
      });

      return {
        sessionId: session.id,
      };
    } catch (error) {
      console.error('Error creating checkout session:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error creating checkout session',
      );
    }
  },
); 