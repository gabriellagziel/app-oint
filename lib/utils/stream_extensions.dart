import 'package:cloud_firestore/cloud_firestore.dart';

extension QueryStreamX<T> on Query<T> {
  /// Stream a collection with typed converters.
  Stream<List<T>> streamCollection() =>
      snapshots().map((s) => s.docs.map((d) => d.data()).toList());
}
