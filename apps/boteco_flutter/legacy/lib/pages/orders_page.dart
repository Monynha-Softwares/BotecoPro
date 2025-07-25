import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/service_provider.dart';
import '../services/sound_provider.dart';
import '../widgets/shared_widgets.dart';
import '../models/data_models.dart';
import 'order_details_page.dart';
import 'tables_page.dart';
import '../theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final service = Provider.of<ServiceProvider>(context, listen: false);
    final allOrders = await service.getOrders();

    if (mounted) {
      setState(() {
        _activeOrders = allOrders.where((order) => !order.isClosed).toList();
        _completedOrders = allOrders.where((order) => order.isClosed).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedidos',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: botecoWine,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Ativos'),
            Tab(text: 'Concluídos'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: BotecoLoader(message: "Carregando pedidos..."),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_activeOrders, true),
                _buildOrdersList(_completedOrders, false),
              ],
            ),
    );
  }



  Widget _buildOrdersList(List<Order> orders, bool isActive) {
    if (orders.isEmpty) {
      return Center(
        child: EmptyStateCard(
          message: isActive ? 'Nenhum pedido ativo no momento' : 'Nenhum pedido concluído',
          icon: Icons.receipt_long,
          actionText: isActive ? 'Ir para Mesas' : null,
          onAction: isActive
              ? () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const TablesPage(),
                    ),
                  )
              : null,
        ),
      );
    }

    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: botecoWine,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(sortedOrders[index], index, isActive);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index, bool isActive) {
    final delay = Duration(milliseconds: 50 * index);
    final totalItems = order.items.length;
    final totalValue = order.total;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Play navigation sound
          Provider.of<SoundProvider>(context, listen: false).playNavegacao();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          ).then((_) => _loadOrders());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: botecoWine,
                    radius: 24,
                    child: Text(
                      '${order.tableNumber}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mesa ${order.tableNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDateTime(order.createdAt),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Itens:',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '$totalItems',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          formatCurrency(totalValue),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: botecoWine,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive && order.items.isNotEmpty) ...[  
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(order: order),
                        ),
                      ).then((_) => _loadOrders()),
                      icon: Icon(Icons.visibility, size: 18, color: botecoWine),
                      label: Text('Ver Detalhes', style: TextStyle(color: botecoWine)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveY(begin: 20, duration: const Duration(milliseconds: 300));
  }
}