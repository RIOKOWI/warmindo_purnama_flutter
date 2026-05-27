import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/models/product_model.dart';

/// Card widget displaying a single product
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'id_ID');

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Price
                Text(
                  'Rp ${priceFormat.format(product.price)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Stock info
                Text(
                  product.isAvailable ? 'Stok: ${product.stock}' : 'Habis',
                ),
                const SizedBox(height: 8),
                // Add button - disabled if out of stock
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.isAvailable ? () => _addToCart(context) : null,
                    child: Text(product.isAvailable ? 'Tambah' : 'Habis'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final cart = context.read<CartProvider>();
    cart.addItem(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
      ),
    );
  }
}