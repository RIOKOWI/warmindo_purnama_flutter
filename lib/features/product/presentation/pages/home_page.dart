import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/category_filter_widget.dart';
import '../widgets/product_grid.dart';

/// Home page displaying products and categories
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch data after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: const Column(
        children: [
          CategoryFilterWidget(),
          Expanded(
            child: ProductGrid(),
          ),
        ],
      ),
    );
  }
}