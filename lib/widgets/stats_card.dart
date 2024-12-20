import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/delivery_stats.dart';

class StatsCard extends StatelessWidget {
  final DeliveryStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.motorcycle,
                value: stats.totalDeliveries.toString(),
                label: 'Entregas',
              ),
              _buildStatItem(
                icon: Icons.attach_money,
                value: 'S/ ${stats.totalEarnings.toStringAsFixed(2)}',
                label: 'Ganancias',
              ),
              _buildStatItem(
                icon: Icons.star,
                value: stats.rating.toStringAsFixed(1),
                label: 'Rating',
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.timer,
                value: '${stats.onlineHours}h',
                label: 'En línea',
              ),
              _buildStatItem(
                icon: Icons.cancel_outlined,
                value: stats.cancelledOrders.toString(),
                label: 'Cancelados',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}