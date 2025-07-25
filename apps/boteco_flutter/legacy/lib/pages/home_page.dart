import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/service_provider.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_drawer.dart';
import '../models/data_models.dart';
import 'tables_page.dart';
import 'products_page.dart';
import 'suppliers_page.dart';
import '../reports_page.dart';
import 'recipes_page.dart';
import 'production_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
const HomePage({Key? key}) : super(key: key);

@override
State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
int _activeTablesCount = 0;
double _todaySales = 0;
int _lowStockProductsCount = 0;
List<TableModel> _tables = [];
List<Order> _activeOrders = [];
bool _isLoading = true;

@override
void initState() {
super.initState();
_loadData();
}

Future<void> _loadData() async {
setState(() {
_isLoading = true;
});

final service = Provider.of<ServiceProvider>(context, listen: false);
await service.initializeData();

final tables = await service.getTables();
final activeOrders = await service.getActiveOrders();
final todaySales = await service.getTodaySales();
final lowStockProducts = await service.getLowStockProducts(10);

if (mounted) {
setState(() {
_tables = tables;
_activeOrders = activeOrders;
_activeTablesCount = tables.where((table) => table.status == TableStatus.occupied).length;
_todaySales = todaySales;
_lowStockProductsCount = lowStockProducts.length;
_isLoading = false;
});
}
}

@override
Widget build(BuildContext context) {
final serviceProvider = Provider.of<ServiceProvider>(context);

return Scaffold(
drawer: const AppDrawer(),
appBar: AppBar(
title: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.sports_bar,
color: Theme.of(context).colorScheme.onPrimary,
),
const SizedBox(width: 8),
Text(
'Boteco PRO',
style: Theme.of(context).textTheme.titleLarge!.copyWith(
color: Theme.of(context).colorScheme.onPrimary,
fontWeight: FontWeight.bold,
),
),
],
),
backgroundColor: Theme.of(context).colorScheme.primary,
centerTitle: true,
elevation: 0,
actions: [
// Switch para modo online/offline
Row(
children: [
Text(
serviceProvider.isOnline ? 'Online' : 'Offline',
style: TextStyle(
color: Theme.of(context).colorScheme.onPrimary,
fontSize: 12,
),
),
Switch(
value: serviceProvider.isOnline,
onChanged: (value) async {
await serviceProvider.toggleOnlineMode(value);
_loadData(); // Recarregar dados após mudar o modo
},
activeColor: Colors.greenAccent,
activeTrackColor: Colors.green,
),
],
),
],
),
body: _isLoading
? const Center(child: BotecoLoader(message: "Carregando dados..."))
: RefreshIndicator(
onRefresh: _loadData,
color: Theme.of(context).colorScheme.primary,
child: SingleChildScrollView(
physics: const AlwaysScrollableScrollPhysics(),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildWelcomeHeader(),
if (serviceProvider.isSyncing)
Container(
margin: const EdgeInsets.all(16),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.blue.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Colors.blue, width: 1),
),
child: Row(
children: [
const SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(strokeWidth: 2),
),
const SizedBox(width: 16),
const Text('Sincronizando dados com o servidor...'),
],
),
),
_buildStatusCards(),
_buildMenuGrid(),
if (_activeOrders.isNotEmpty) _buildRecentOrdersSection(),
],
),
),
),
);
}

Widget _buildWelcomeHeader() {
final now = DateTime.now();
String greeting;
if (now.hour < 12) {
greeting = 'Bom dia';
} else if (now.hour < 18) {
greeting = 'Boa tarde';
} else {
greeting = 'Boa noite';
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
Theme.of(context).colorScheme.primary,
Theme.of(context).colorScheme.primary.withOpacity(0.8),
],
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
),
borderRadius: const BorderRadius.only(
bottomLeft: Radius.circular(32),
bottomRight: Radius.circular(32),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
greeting,
style: Theme.of(context).textTheme.headlineSmall!.copyWith(
color: Theme.of(context).colorScheme.onPrimary,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(now),
style: Theme.of(context).textTheme.titleMedium!.copyWith(
color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
),
),
const SizedBox(height: 16),
Row(
children: [
Expanded(
child: Card(
elevation: 0,
color: Colors.white.withOpacity(0.2),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
Icons.money,
color: Theme.of(context).colorScheme.onPrimary,
size: 20,
),
const SizedBox(width: 8),
Text(
'Vendas hoje',
style: TextStyle(
color: Theme.of(context).colorScheme.onPrimary,
fontWeight: FontWeight.bold,
),
),
],
),
const SizedBox(height: 8),
Text(
formatCurrency(_todaySales),
style: Theme.of(context).textTheme.headlineSmall!.copyWith(
color: Theme.of(context).colorScheme.onPrimary,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
),
],
),
],
),
);
}

Widget _buildStatusCards() {
return Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
child: Text(
'Status Atual',
style: Theme.of(context).textTheme.titleLarge!.copyWith(
fontWeight: FontWeight.bold,
),
),
),
StatusCard(
title: 'Mesas ocupadas',
value: '$_activeTablesCount de ${_tables.length}',
icon: Icons.table_bar,
color: const Color(0xFFFF9800),
),
StatusCard(
title: 'Pedidos ativos',
value: '${_activeOrders.length}',
icon: Icons.receipt_long,
color: const Color(0xFF4CAF50),
),
StatusCard(
title: 'Produtos com estoque baixo',
value: '$_lowStockProductsCount',
icon: Icons.warning_amber,
color: _lowStockProductsCount > 0
? const Color(0xFFF44336)
: const Color(0xFF4CAF50),
),
],
),
);
}

Widget _buildMenuGrid() {
return Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
child: Text(
'Menu Principal',
style: Theme.of(context).textTheme.titleLarge!.copyWith(
fontWeight: FontWeight.bold,
),
),
),
GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
children: [
MenuCard(
title: 'Mesas',
icon: Icons.table_restaurant,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const TablesPage(),
),
).then((_) => _loadData());
},
backgroundColor: const Color(0xFF6F61EF),
),
MenuCard(
title: 'Produtos',
icon: Icons.inventory_2,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProductsPage(),
),
).then((_) => _loadData());
},
backgroundColor: const Color(0xFF39D2C0),
),
MenuCard(
title: 'Fornecedores',
icon: Icons.local_shipping,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const SuppliersPage(),
),
).then((_) => _loadData());
},
backgroundColor: const Color(0xFFEE8B60),
),
MenuCard(
title: 'Relatórios',
icon: Icons.bar_chart,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ReportsPage(),
),
).then((_) => _loadData());
},
backgroundColor: const Color(0xFF888888),
),
],
),
const SizedBox(height: 16),
Padding(
padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
child: Text(
'Receitas e Produções',
style: Theme.of(context).textTheme.titleLarge!.copyWith(
fontWeight: FontWeight.bold,
),
),
),
GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
children: [
MenuCard(
title: 'Receitas',
icon: Icons.menu_book,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const RecipesPage(),
),
).then((_) => _loadData());
},
backgroundColor: const Color(0xFF5D8A66),
),
MenuCard(
title: 'Produções Caseiras',
icon: Icons.production_quantity_limits,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProductionPage(),
),
).then((_) => _loadData());
},
backgroundColor: const Color(0xFFAD6A6C),
),
],
),
],
),
);
}

Widget _buildRecentOrdersSection() {
return Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
child: Text(
'Pedidos Ativos',
style: Theme.of(context).textTheme.titleLarge!.copyWith(
fontWeight: FontWeight.bold,
),
),
),
ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: _activeOrders.length > 3 ? 3 : _activeOrders.length,
itemBuilder: (context, index) {
final order = _activeOrders[index];
return Card(
margin: const EdgeInsets.only(bottom: 8.0),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
child: ListTile(
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
leading: CircleAvatar(
backgroundColor: Theme.of(context).colorScheme.primary,
child: Text(
'${order.tableNumber}',
style: TextStyle(
color: Theme.of(context).colorScheme.onPrimary,
fontWeight: FontWeight.bold,
),
),
),
title: Text(
'Mesa ${order.tableNumber}',
style: const TextStyle(fontWeight: FontWeight.bold),
),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'${order.items.length} itens - ${formatCurrency(order.total)}',
),
const SizedBox(height: 4),
StatusBadge(status: order.status),
],
),
trailing: Icon(
Icons.arrow_forward_ios,
color: Theme.of(context).colorScheme.primary,
size: 16,
),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const TablesPage(),
),
).then((_) => _loadData());
},
),
)
.animate()
.fadeIn()
.slideX(begin: 30, duration: Duration(milliseconds: 200 + (index * 100)));
},
),
if (_activeOrders.length > 3)
Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: Center(
child: TextButton.icon(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const TablesPage(),
),
).then((_) => _loadData());
},
icon: Icon(
Icons.visibility,
color: Theme.of(context).colorScheme.primary,
),
label: Text(
'Ver todos os pedidos',
style: TextStyle(
color: Theme.of(context).colorScheme.primary,
fontWeight: FontWeight.bold,
),
),
),
),
),
],
),
);
}
}