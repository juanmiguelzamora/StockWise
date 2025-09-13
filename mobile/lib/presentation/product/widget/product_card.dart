import 'package:flutter/material.dart';
import 'package:mobile/domain/product/entity/product.dart';

/// A single card showing product details, quantity counter and stock badge.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  Widget _buildBadge(StockStatus status) {
    String text;
    Color color;
    switch (status) {
      case StockStatus.inStock:
        text = 'In Stock';
        color = Colors.green;
        break;
      case StockStatus.lowStock:
        text = 'Low Stock';
        color = Colors.orange;
        break;
      case StockStatus.outOfStock:
        text = 'Out of Stock';
        color = Colors.red;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = stockStatusFromQuantity(product.quantity);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Image (network)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(product.category, style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 8),
                  _buildBadge(status),
                ],
              ),
            ),
            // Quantity controls
            Column(
              children: [
                IconButton(
                  onPressed: () => onIncrement(),
                  icon: Icon(Icons.add_circle_outline),
                ),
                Text(product.quantity.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: product.quantity == 0 ? null : () => onDecrement(),
                  icon: Icon(Icons.remove_circle_outline),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}