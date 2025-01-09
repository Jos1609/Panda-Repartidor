import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/delivery_stats.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String driverId;

  static var instance;

  OrderService({required this.driverId}) {
    assert(driverId.isNotEmpty, 'El ID del repartidor no puede estar vacío');
  }

/// Stream para obtener órdenes activas asignadas al repartidor y órdenes libres
Stream<List<DeliveryOrder>> getActiveOrders() {
  return _firestore
      .collection('orders')
      .where('status', whereIn: [
        'pending', // Pedidos pendientes
        'assigned', // Pedidos asignados
        'inProgress',
      ])
      .where('deliveryPersonId', whereIn: [driverId, '']) // Órdenes del repartidor y sin asignar
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map((snapshot) => _processOrdersSnapshot(snapshot));
}
  List<DeliveryOrder> _processOrdersSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs
          .map((doc) => DeliveryOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al procesar órdenes: $e');
      return [];
    }
  }

  /// Actualiza el estado de una orden
  Future<void> updateOrderStatus(
      String orderId, OrderStatus newStatus, String updatedBy) async {
    try {
      // Referencia al documento del pedido
      final orderRef = _firestore.collection('orders').doc(orderId);

      // Ejecutar la transacción
      await _firestore.runTransaction((transaction) async {
        // Obtener los datos actuales del pedido
        final orderDoc = await transaction.get(orderRef);

        if (!orderDoc.exists) {
          throw Exception('El pedido no existe.');
        }

        // Convertir los datos actuales del documento a un objeto
        final orderData = orderDoc.data()!;
        final List<dynamic> statusHistory = orderData['statusHistory'] ?? [];

        // Crear un nuevo registro para el historial de estados
        final statusLog = {
          'status': newStatus.toString().split('.').last,
          'timestamp': Timestamp.now(),
          'updatedBy': updatedBy,
        };

        // Agregar el nuevo registro al historial existente
        statusHistory.add(statusLog);

        // Actualizar el estado y el historial en la transacción
        transaction.update(orderRef, {
          'status': newStatus.toString().split('.').last,
          'deliveryPersonId': driverId,
          'statusHistory': statusHistory,
        });
      });
    } catch (e) {
      throw Exception('Error al actualizar el estado del pedido: $e');
    }
  }

  /// Obtiene estadísticas del día para el repartidor
  Future<DeliveryStats> getTodayStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final querySnapshot = await _firestore
          .collection('orders')
          .where('deliveryPersonId', isEqualTo: driverId)
          .where('status', isEqualTo: 'delivered')
          .where('orderDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      double totalEarnings = 0;
      int deliveredOrders = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalEarnings += ((data['deliveryFee'] ?? 0) * 0.8);
        deliveredOrders++;
      }

      return DeliveryStats(
        totalDeliveries: deliveredOrders,
        totalEarnings: totalEarnings,
        rating: 4.8, // Implementar sistema de calificaciones
        onlineHours: 0, // Implementar tracking de tiempo
        cancelledOrders: 0,
      );
    } catch (e) {
      throw 'Error al obtener estadísticas: $e';
    }
  }

  /// Asigna una orden al repartidor
  Future<void> assignOrder(String orderId) async {
    try {
      // Crear estado inicial en statusHistory
      final statusLog = {
        'status': OrderStatus.assigned.toString().split('.').last,
        'timestamp': Timestamp.now(),
      };

      await _firestore.collection('orders').doc(orderId).update({
        'deliveryPersonId': driverId,
        'status': OrderStatus.assigned.toString().split('.').last,
        'statusHistory': FieldValue.arrayUnion([statusLog]),
      });
    } catch (e) {
      throw 'Error al asignar orden: $e';
    }
  }
}
