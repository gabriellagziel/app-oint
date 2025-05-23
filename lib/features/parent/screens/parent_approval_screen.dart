import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/services/parental_consent_service.dart';

class ParentApprovalScreen extends StatefulWidget {
  final String parentUid;

  const ParentApprovalScreen({super.key, required this.parentUid});

  @override
  State<ParentApprovalScreen> createState() => _ParentApprovalScreenState();
}

class _ParentApprovalScreenState extends State<ParentApprovalScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _consentService = ParentalConsentService();
  bool _isLoading = false;

  Future<void> _handleApproval(String childId, bool approved) async {
    setState(() => _isLoading = true);
    try {
      if (approved) {
        await _consentService.approveChild(widget.parentUid, childId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child approved successfully')),
        );
      } else {
        await _consentService.denyChild(widget.parentUid, childId);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Child request denied')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenRef = _firestore
        .collection('users')
        .doc(widget.parentUid)
        .collection('children')
        .where('status', isEqualTo: 'waiting_approval');

    return Scaffold(
      appBar: AppBar(title: const Text("Approve Child Requests")),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: childrenRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading requests."));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No pending approvals."));
              }

              final children = snapshot.data!.docs;

              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  final childId = child.id;

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text("Child ID: $childId"),
                      subtitle: const Text("Waiting for your approval"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _handleApproval(childId, true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _handleApproval(childId, false),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
