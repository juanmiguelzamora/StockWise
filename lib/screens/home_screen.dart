import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSmall = screenWidth * 0.035;
    double fontMedium = screenWidth * 0.045;
    double fontLarge = screenWidth * 0.055;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/stockwise_logo.png',
                    height: screenHeight * 0.06,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(
                          fontSize: fontMedium,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "John Doe",
                        style: TextStyle(
                          fontSize: fontLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Today",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            "Jul, 29 2025",
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: fontSmall,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem("392", "Total", fontLarge, fontSmall),
                          Container(
                            width: 1,
                            height: screenHeight * 0.05,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          _StatItem("123", "Stock In", fontLarge, fontSmall),
                          Container(
                            width: 1,
                            height: screenHeight * 0.05,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          _StatItem("242", "Stock Out", fontLarge, fontSmall),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _StockAlertCard(
                        color: Colors.black87,
                        title: "Overstock",
                        value: "10",
                        fontLarge: fontLarge,
                        fontSmall: fontSmall,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _StockAlertCard(
                        color: Colors.redAccent,
                        title: "Out of Stock",
                        value: "99",
                        fontLarge: fontLarge,
                        fontSmall: fontSmall,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _StockAlertCard(
                        color: Colors.orangeAccent,
                        title: "Low Stock Alerts",
                        value: "32",
                        fontLarge: fontLarge,
                        fontSmall: fontSmall,
                        isLongTitle: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: fontMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontSize: fontSmall,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Detailed history items (with images)
                _HistoryItem(
                  imagePath: 'assets/headphones.png',
                  title: 'Wireless Headphones',
                  stock: '454',
                  change: '+100',
                  changeColor: Colors.green,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/headphones.png',
                  title: 'Wireless Headphones',
                  stock: '404',
                  change: '-50',
                  changeColor: Colors.red,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/mouse.png',
                  title: 'Gaming Mouse',
                  stock: '50',
                  change: '+100',
                  changeColor: Colors.green,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/mouse.png',
                  title: 'Gaming Mouse',
                  stock: '45',
                  change: '-50',
                  changeColor: Colors.red,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/keyboard.png',
                  title: 'Mechanical Keyboard',
                  stock: '120',
                  change: '+20',
                  changeColor: Colors.green,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/keyboard.png',
                  title: 'Mechanical Keyboard',
                  stock: '100',
                  change: '-10',
                  changeColor: Colors.red,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/monitor.png',
                  title: '4K Monitor',
                  stock: '35',
                  change: '+5',
                  changeColor: Colors.green,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/monitor.png',
                  title: '4K Monitor',
                  stock: '30',
                  change: '-2',
                  changeColor: Colors.red,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                _HistoryItem(
                  imagePath: 'assets/microphone.png',
                  title: 'USB Microphone',
                  stock: '20',
                  change: '+1',
                  changeColor: Colors.green,
                  fontMedium: fontMedium,
                  fontSmall: fontSmall,
                ),
                SizedBox(height: screenHeight * 0.03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Stock In History",
                    style: TextStyle(
                      fontSize: fontMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  children: List.generate(
                    15,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryCard(
                        title: "Item ${index + 1}",
                        subtitle: "Stocked on Jul ${index + 1}, 2025",
                        quantity: "${(index + 1) * 5}",
                        fontMedium: fontMedium,
                        fontSmall: fontSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _StatItem(String value, String label, double fontLarge, double fontSmall) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: fontSmall,
          ),
        ),
      ],
    );
  }

  Widget _StockAlertCard({
    required Color color,
    required String title,
    required String value,
    required double fontLarge,
    required double fontSmall,
    bool isLongTitle = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isLongTitle ? fontSmall * 0.9 : fontSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _HistoryItem({
    required String imagePath,
    required String title,
    required String stock,
    required String change,
    required Color changeColor,
    required double fontMedium,
    required double fontSmall,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: fontMedium,
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: fontMedium,
                    ),
                  ),
                  Text(
                    'Stock: $stock',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: fontSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            change,
            style: TextStyle(
              color: changeColor,
              fontSize: fontMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _HistoryCard({
    required String title,
    required String subtitle,
    required String quantity,
    required double fontMedium,
    required double fontSmall,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: fontSmall,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            "+$quantity",
            style: TextStyle(
              fontSize: fontMedium,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
