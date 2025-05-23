import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_providers.dart';

class SubscribeScreen extends ConsumerStatefulWidget {
  const SubscribeScreen({super.key});

  @override
  ConsumerState<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends ConsumerState<SubscribeScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _handleSubscribe(String priceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(subscriptionServiceProvider);
      final sessionId = await service.createCheckoutSession(priceId: priceId);
      await service.handleCheckoutSession(sessionId);

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Plan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    _buildPlanCard(
                      title: 'Basic',
                      price: '\$9.99',
                      period: 'per month',
                      features: [
                        'Up to 20 meetings per day',
                        'Basic booking features',
                        'Email notifications',
                        'Calendar integration',
                      ],
                      priceId: 'price_basic_monthly',
                      isPopular: false,
                    ),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      title: 'Pro',
                      price: '\$29.99',
                      period: 'per month',
                      features: [
                        'Unlimited meetings',
                        'Advanced booking features',
                        'Smart tags & analytics',
                        'CSV export',
                        'Priority support',
                      ],
                      priceId: 'price_pro_monthly',
                      isPopular: true,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required String priceId,
    required bool isPopular,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border:
              isPopular
                  ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(price, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 4),
                Text(period, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSubscribe(priceId),
                child: Text('Subscribe to $title'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
