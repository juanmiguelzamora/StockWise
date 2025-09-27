import 'package:flutter/material.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({Key? key}) : super(key: key);

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final List<Map<String, dynamic>> inventoryItems = [
    {
      'name': 'Wireless Headphones',
      'sku': 'SKU: WH123',
      'category': 'Category: Audio',
      'quantity': 454,
      'status': 'In Stock',
      'image': 'headphone.png',
    },
    {
      'name': 'Gaming Mouse',
      'sku': 'SKU: GM456',
      'category': 'Category: Accessories',
      'quantity': 50,
      'status': 'Low Stock',
      'image': 'mouse.png',
    },
    {
      'name': 'Bluetooth Speaker',
      'sku': 'SKU: BS789',
      'category': 'Category: Audio',
      'quantity': 0,
      'status': 'Out of Stock',
      'image': 'speaker.png',
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'In Stock':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void updateQuantity(int index, bool increase) {
    setState(() {
      int qty = inventoryItems[index]['quantity'];
      if (increase) {
        qty++;
      } else if (qty > 0) {
        qty--;
      }
      inventoryItems[index]['quantity'] = qty;
      if (qty == 0) {
        inventoryItems[index]['status'] = 'Out of Stock';
      } else if (qty < 100) {
        inventoryItems[index]['status'] = 'Low Stock';
      } else {
        inventoryItems[index]['status'] = 'In Stock';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double spacingXS = screenHeight * 0.005;
    double spacingS = screenHeight * 0.01;
    double spacingM = screenHeight * 0.02;
    double spacingL = screenHeight * 0.03;

    double fontSmall = screenWidth * 0.035;
    double fontMedium = screenWidth * 0.045;
    double iconSize = screenWidth * 0.045;
    double iconButtonSize = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/stockwise_logo.png',
                  height: screenHeight * 0.08,
                ),
              ),
              SizedBox(height: spacingL),
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(fontSize: fontMedium),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey, size: iconSize),
                    hintText: "Search Here...",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: fontSmall,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: "Categories",
                    items: ["Categories", "Jeans", "Shorts", "T-shirt"]
                        .map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(fontSize: fontSmall),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {},
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  DropdownButton<String>(
                    value: "All Status",
                    items: ["All Status", "In Stock", "Low Stock", "Out of Stock"]
                        .map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(fontSize: fontSmall),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {},
                  ),
                ],
              ),
              SizedBox(height: spacingM),
              Expanded(
                child: ListView.builder(
                  itemCount: inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = inventoryItems[index];
                    final Color statusColor = getStatusColor(item['status']);

                    return Container(
                      margin: EdgeInsets.only(bottom: spacingS),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.18,
                            height: screenWidth * 0.18,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Center(
                              child: Text(
                                item['image'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSmall * 0.9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontSize: fontMedium,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: screenWidth * 0.3,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                        vertical: screenHeight * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          item['status'],
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: fontSmall,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacingXS),
                                Text(item['sku'],
                                    style: TextStyle(fontSize: fontSmall, color: Colors.grey[700])),
                                Text(item['category'],
                                    style: TextStyle(fontSize: fontSmall, color: Colors.grey[700])),
                                SizedBox(height: spacingS),
                                Row(
                                  children: [
                                    Text(
                                      'Qty: ${item['quantity']}',
                                      style: TextStyle(
                                        fontSize: fontSmall,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () => updateQuantity(index, false),
                                      child: Container(
                                        width: iconButtonSize,
                                        height: iconButtonSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.withOpacity(0.1),
                                        ),
                                        child: Icon(Icons.remove, color: Colors.red, size: iconSize),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    GestureDetector(
                                      onTap: () => updateQuantity(index, true),
                                      child: Container(
                                        width: iconButtonSize,
                                        height: iconButtonSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green.withOpacity(0.1),
                                        ),
                                        child: Icon(Icons.add, color: Colors.green, size: iconSize),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}