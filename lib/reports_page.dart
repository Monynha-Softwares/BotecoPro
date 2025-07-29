import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'services/service_provider.dart';
import 'widgets/shared_widgets.dart';
import 'models/data_models.dart';
import 'pages/orders_page.dart';
import 'theme.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  List<Sale> _sales = [];
  List<Product> _products = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Dia';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final service = Provider.of<ServiceProvider>(context, listen: false);
    final sales = await service.getSales();
    final products = await service.getProducts();

    if (mounted) {
      setState(() {
        _sales = sales;
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatórios',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Vendas'),
            Tab(text: 'Produtos'),
            Tab(text: 'Estoque'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.receipt_long, 
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            tooltip: 'Ver pedidos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: BotecoLoader(message: "Carregando relatórios..."))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSalesReport(),
                _buildProductsReport(),
                _buildInventoryReport(),
              ],
            ),
    );
  }

  Widget _buildSalesReport() {
    // Filter sales based on selected period
    final List<Sale> filteredSales = _filterSalesByPeriod(_sales, _selectedPeriod, _selectedDate);

    // Calculate total sales amount
    final double totalSales = filteredSales.fold(0, (sum, sale) => sum + sale.total);

    // Group sales by date for the chart
    final Map<String, double> salesByDate = _getSalesByDate(filteredSales, _selectedPeriod);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildSummaryCard(
              title: 'Total de Vendas',
              value: formatCurrency(totalSales),
              subtitle: '${filteredSales.length} vendas no período',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Vendas por ${_selectedPeriod.toLowerCase()}',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (salesByDate.isEmpty)
              _buildEmptyState('Nenhuma venda no período selecionado')
            else
              _buildSalesChart(salesByDate),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimas vendas',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Ver todos os pedidos'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (filteredSales.isEmpty)
              _buildEmptyState('Nenhuma venda no período selecionado')
            else
              _buildSalesList(filteredSales),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsReport() {
    // Create a map to count products sold
    final Map<String, ProductSaleInfo> productSales = {};

    // Process all sales to count products
    for (var sale in _sales) {
      final order = _getOrderById(sale.orderId);
      if (order != null) {
        for (var item in order.items) {
          if (productSales.containsKey(item.productId)) {
            productSales[item.productId]!.quantity += item.quantity.toDouble();
            productSales[item.productId]!.revenue += item.total;
          } else {
            productSales[item.productId] = ProductSaleInfo(
              name: item.productName,
              quantity: item.quantity.toDouble(),
              revenue: item.total,
            );
          }
        }
      }
    }

    // Sort by revenue
    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              title: 'Produtos Vendidos',
              value: '${productSales.length}',
              subtitle: 'Total de produtos diferentes',
              icon: Icons.shopping_cart,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Produtos mais vendidos',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (sortedProducts.isEmpty)
              _buildEmptyState('Nenhum produto vendido ainda')
            else
              _buildTopProductsList(sortedProducts),
            const SizedBox(height: 24),
            Text(
              'Distribuição de vendas por categoria',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (sortedProducts.isEmpty)
              _buildEmptyState('Nenhum produto vendido ainda')
            else
              _buildCategoryPieChart(productSales),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryReport() {
    // Find low stock products
    final List<Product> lowStockProducts = _products
      .where((product) => product.stockQuantity <= 10)
      .toList();

    // Find out of stock products
    final List<Product> outOfStockProducts = _products
      .where((product) => product.stockQuantity <= 0)
      .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Estoque Baixo',
                    value: '${lowStockProducts.length}',
                    subtitle: 'Produtos com estoque ≤ 10',
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                    small: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Sem Estoque',
                    value: '${outOfStockProducts.length}',
                    subtitle: 'Produtos esgotados',
                    icon: Icons.error,
                    color: Colors.red,
                    small: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Produtos com estoque baixo',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (lowStockProducts.isEmpty)
              _buildEmptyState('Nenhum produto com estoque baixo')
            else
              _buildLowStockList(lowStockProducts),
            const SizedBox(height: 24),
            Text(
              'Valor do estoque por categoria',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildStockValueBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Período:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedPeriod,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'Dia', child: Text('Dia')),
                  DropdownMenuItem(value: 'Semana', child: Text('Semana')),
                  DropdownMenuItem(value: 'Mês', child: Text('Mês')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _selectedPeriod == 'Dia'
                  ? DateFormat('dd/MM/yyyy').format(_selectedDate)
                  : _selectedPeriod == 'Semana'
                  ? 'Semana de ${DateFormat('dd/MM').format(_getStartOfWeek(_selectedDate))}'
                  : DateFormat('MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool small = false,
  }) {
    return Container(
      padding: EdgeInsets.all(small ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: small ? 40 : 60,
            height: small ? 40 : 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: small ? 24 : 30,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: const Duration(milliseconds: 300))
    .moveY(begin: 20, duration: const Duration(milliseconds: 300));
  }

  Widget _buildSalesChart(Map<String, double> salesByDate) {
    // Prepare the chart data
    final List<String> dates = salesByDate.keys.toList();
    final List<double> values = salesByDate.values.toList();
    final double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          groupsSpace: 12,
          maxY: maxY * 1.2, // Add some space at the top
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SideTitleWidget(axisSide: AxisSide.left, child: Text('0'));
                  return SideTitleWidget(
                    axisSide: AxisSide.left,
                    child: Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= dates.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: AxisSide.bottom,
                    child: Text(
                      dates[value.toInt()],
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: List.generate(
            dates.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  color: Theme.of(context).colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, ProductSaleInfo> productSales) {
    // Group by category
    final Map<ProductCategory, double> salesByCategory = {};

    for (var entry in productSales.entries) {
      final product = _getProductById(entry.key);
      if (product != null) {
        if (salesByCategory.containsKey(product.category)) {
          salesByCategory[product.category] = salesByCategory[product.category]! + entry.value.revenue;
        } else {
          salesByCategory[product.category] = entry.value.revenue;
        }
      }
    }

    // Prepare chart data
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    int i = 0;
    final totalSales = salesByCategory.values.fold(0.0, (a, b) => a + b);

    for (var entry in salesByCategory.entries) {
      final percentage = totalSales > 0 ? (entry.value / totalSales) * 100 : 0;
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(
              salesByCategory.length,
              (index) {
                final entry = salesByCategory.entries.elementAt(index);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getCategoryName(entry.key),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCurrency(entry.value),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockValueBarChart() {
    // Group by category
    final Map<ProductCategory, double> stockByCategory = {};

    for (var product in _products) {
      final stockValue = product.price * product.stockQuantity;
      if (stockByCategory.containsKey(product.category)) {
        stockByCategory[product.category] = stockByCategory[product.category]! + stockValue;
      } else {
        stockByCategory[product.category] = stockValue;
      }
    }

    // Prepare chart data
    final List<String> categories = stockByCategory.keys.map((cat) => _getCategoryName(cat)).toList();
    final List<double> values = stockByCategory.values.toList();
    final double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          groupsSpace: 12,
          maxY: maxY * 1.2,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SideTitleWidget(axisSide: AxisSide.left, child: Text('0'));
                  return SideTitleWidget(
                    axisSide: AxisSide.left,
                    child: Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= categories.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: AxisSide.bottom,
                    child: Text(
                      categories[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: List.generate(
            categories.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  color: _getCategoryColor(ProductCategory.values[index % ProductCategory.values.length]),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesList(List<Sale> sales) {
    final sortedSales = List<Sale>.from(sales)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedSales.length > 10 ? 10 : sortedSales.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sale = sortedSales[index];
          final order = _getOrderById(sale.orderId);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.receipt,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              'Venda #${sale.id.substring(0, 6)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mesa: ${order?.tableNumber ?? "N/A"}',
                ),
                Text(
                  'Data: ${formatDateTime(sale.timestamp)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Text(
              formatCurrency(sale.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopProductsList(List<ProductSaleInfo> products) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length > 5 ? 5 : products.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = products[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Quantidade vendida: ${product.quantity}'),
            trailing: Text(
              formatCurrency(product.revenue),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLowStockList(List<Product> products) {
    final sortedProducts = List<Product>.from(products)
      ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedProducts.length > 5 ? 5 : sortedProducts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = sortedProducts[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStockStatusColor(product.stockQuantity).withOpacity(0.2),
              child: Icon(
                _getStockStatusIcon(product.stockQuantity),
                color: _getStockStatusColor(product.stockQuantity),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Categoria: ${_getCategoryName(product.category)}'),
            trailing: Text(
              '${product.stockQuantity} ${product.unit}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStockStatusColor(product.stockQuantity),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<Sale> _filterSalesByPeriod(List<Sale> sales, String period, DateTime selectedDate) {
    return sales.where((sale) {
      if (period == 'Dia') {
        return sale.timestamp.year == selectedDate.year &&
               sale.timestamp.month == selectedDate.month &&
               sale.timestamp.day == selectedDate.day;
      } else if (period == 'Semana') {
        final startOfWeek = _getStartOfWeek(selectedDate);
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return sale.timestamp.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
               sale.timestamp.isBefore(endOfWeek.add(const Duration(days: 1)));
      } else { // Mês
        return sale.timestamp.year == selectedDate.year &&
               sale.timestamp.month == selectedDate.month;
      }
    }).toList();
  }

  Map<String, double> _getSalesByDate(List<Sale> sales, String period) {
    final Map<String, double> result = {};
    final DateFormat dateFormat;

    if (period == 'Dia') {
      dateFormat = DateFormat('HH:mm');
      // Create a map with hours
      for (int hour = 0; hour < 24; hour++) {
        final time = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour);
        result[dateFormat.format(time)] = 0;
      }
    } else if (period == 'Semana') {
      dateFormat = DateFormat('EEE');
      // Create a map with days of week
      final startOfWeek = _getStartOfWeek(_selectedDate);
      for (int day = 0; day < 7; day++) {
        final date = startOfWeek.add(Duration(days: day));
        result[dateFormat.format(date)] = 0;
      }
    } else { // Mês
      dateFormat = DateFormat('dd');
      // Create a map with days of month
      final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(_selectedDate.year, _selectedDate.month, day);
        result[dateFormat.format(date)] = 0;
      }
    }

    // Fill with actual data
    for (var sale in sales) {
      String key;
      if (period == 'Dia') {
        key = dateFormat.format(sale.timestamp);
      } else if (period == 'Semana') {
        key = dateFormat.format(sale.timestamp);
      } else { // Mês
        key = dateFormat.format(sale.timestamp);
      }

      if (result.containsKey(key)) {
        result[key] = result[key]! + sale.total;
      } else {
        result[key] = sale.total;
      }
    }

    return result;
  }

  DateTime _getStartOfWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  Order? _getOrderById(String orderId) {
    return null; // In a real implementation, this would fetch the order from the service provider
  }

  Product? _getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.drink:
        return 'Bebidas';
      case ProductCategory.food:
        return 'Comidas';
      case ProductCategory.other:
        return 'Outros';
    }
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.drink:
        return Colors.blue;
      case ProductCategory.food:
        return Colors.orange;
      case ProductCategory.other:
        return Colors.purple;
    }
  }

  IconData _getStockStatusIcon(int stockQuantity) {
    if (stockQuantity <= 0) return Icons.error;
    if (stockQuantity <= 5) return Icons.warning_amber;
    if (stockQuantity <= 10) return Icons.info_outline;
    return Icons.check_circle;
  }

  Color _getStockStatusColor(int stockQuantity) {
    if (stockQuantity <= 0) return Colors.red;
    if (stockQuantity <= 5) return Colors.orange;
    if (stockQuantity <= 10) return Colors.amber;
    return Colors.green;
  }
}

class ProductSaleInfo {
  final String name;
  double quantity;
  double revenue;

  ProductSaleInfo({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}