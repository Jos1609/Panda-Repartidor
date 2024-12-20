import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:panda_repartidor/models/order.dart';
import 'package:panda_repartidor/widgets/adaptive_map.dart';
import 'package:panda_repartidor/widgets/custom_bottom_bar.dart';

import '../models/delivery_stats.dart';
import '../services/order_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/active_order_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OrderService _orderService =
      OrderService(driverId: 'current_driver_id');
  bool _isAvailable = true;
  GoogleMapController? _mapController;
  DeliveryStats? _stats;
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _orderService.getTodayStats();
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // AppBar personalizado con estado del repartidor
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panda Delivery',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _isAvailable ? 'En línea' : 'Fuera de línea',
              style: TextStyle(
                color: _isAvailable ? AppTheme.primaryColor : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // Toggle para disponibilidad
          Row(
            children: [
              Text(
                _isAvailable ? 'Disponible' : 'No disponible',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (value) async {
                  setState(() => _isAvailable = value);
                  await _orderService.updateDriverStatus(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Mapa con ubicación actual y ruta
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isMapExpanded ? 400 : 200,
                    child: Stack(
                      children: [
                        AdaptiveMap(
                          height: _isMapExpanded ? 400 : 200,
                          onMapCreated: (controller) =>
                              _mapController = controller,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                        ),
                        // Botón para expandir/contraer mapa
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: FloatingActionButton.small(
                            onPressed: () => setState(
                                () => _isMapExpanded = !_isMapExpanded),
                            backgroundColor: Colors.white,
                            child: Icon(
                              _isMapExpanded
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Estadísticas del día
                  if (_stats != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: StatsCard(stats: _stats!)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.2),
                    ),

                  // Pedidos activos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Pedidos Activos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: StreamBuilder<List<DeliveryOrder>>(
                            stream: _orderService.getActiveOrders(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.length ?? 0;
                              return Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Lista de pedidos activos
            StreamBuilder<List<DeliveryOrder>>(
              stream: _orderService.getActiveOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No hay pedidos'),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.moped_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay pedidos activos',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = orders[index];
                        return ActiveOrderCard(
                          order: order,
                          onStatusUpdate: (newStatus) async {
                            await _orderService.updateOrderStatus(
                              order.id,
                              newStatus,
                            );
                          },
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 100 * index),
                            );
                      },
                      childCount: orders.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Menú inferior con accesos rápidos
     bottomNavigationBar: const CustomBottomBar(),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}