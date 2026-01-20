import 'package:flutter/material.dart';

/// Customers tab showing customer list.
class CustomersTab extends StatelessWidget {
  const CustomersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
      ),
      body: const Center(
        child: Text('Customer List - Coming Soon'),
      ),
    );
  }
}
