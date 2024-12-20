import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class ActiveOrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final Function(OrderStatus) onStatusUpdate;

  const ActiveOrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: _getStatusIcon(),
        title: Text(
          order.restaurantName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Pedido #${order.id.substring(0, 6)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Text(
          'S/ ${order.total.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.store,
                  'Restaurante',
                  order.restaurantAddress,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person,
                  'Cliente',
                  order.customerAddress,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.phone,
                  'Teléfono',
                  order.customerPhone,
                ),
                if (order.notes != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.note,
                    'Notas',
                    order.notes!,
                  ),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                content,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate(OrderStatus.picked),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Recoger Pedido'),
              ),
            ),
          ],
        );
      case OrderStatus.picked:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate(OrderStatus.delivering),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Iniciar Entrega'),
              ),
            ),
          ],
        );
      case OrderStatus.delivering:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate(OrderStatus.completed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Completar Entrega'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _getStatusIcon() {
    final iconData = switch (order.status) {
      OrderStatus.pending => Icons.schedule,
      OrderStatus.picked => Icons.store,
      OrderStatus.delivering => Icons.directions_bike,
      OrderStatus.completed => Icons.check_circle,
      OrderStatus.cancelled => Icons.cancel,
    };

    return Icon(
      iconData,
      color: AppTheme.primaryColor,
      size: 28,
    );
  }
}