import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/delivery_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class OrderService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final String driverId;

  OrderService({required this.driverId});

 Stream<List<DeliveryOrder>> getActiveOrders() {
    return _firestore
        .collection('orders')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: [
          'pending',
          'picked',
          'delivering'
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DeliveryOrder.fromMap(doc.data()))
              .toList();
        });
  }

  Future<DeliveryStats> getTodayStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final statsDoc = await _firestore
        .collection('driver_stats')
        .doc(driverId)
        .collection('daily')
        .doc(startOfDay.toIso8601String().split('T')[0])
        .get();

    return DeliveryStats.fromMap(statsDoc.data() ?? {});
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDriverStatus(bool isAvailable) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'isAvailable': isAvailable,
      'lastStatusUpdate': FieldValue.serverTimestamp(),
    });
  }
}
