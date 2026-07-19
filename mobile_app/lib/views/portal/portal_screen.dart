import 'package:appointment_booking_app/controllers/company_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../controllers/portal_controller.dart';
import '../../utils/app_theme.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final controller = Provider.of<PortalController>(context, listen: false);
    await controller.fetchOrders();
    await controller.fetchInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Invoices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrdersTab(),
          _InvoicesTab(),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PortalController>(
      builder: (context, controller, child) {
        if (controller.isOrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return Card(
              child: ListTile(
                title: Text(order.name),
                subtitle: Text('${order.stateDisplay} - ${order.dateOrder}'),
                trailing: Text('${order.currencySymbol}${order.amountTotal}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _InvoicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PortalController>(
      builder: (context, controller, child) {
        if (controller.isInvoicesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.invoices.isEmpty) {
          return const Center(child: Text('No invoices found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.invoices.length,
          itemBuilder: (context, index) {
            final invoice = controller.invoices[index];
            return Card(
              child: ListTile(
                title: Text(invoice.name),
                subtitle: Text('${invoice.stateDisplay} - ${invoice.invoiceDate}'),
                trailing: Text('${invoice.currencySymbol}${invoice.amountTotal}'),
              ),
            );
          },
        );
      },
    );
  }
}
