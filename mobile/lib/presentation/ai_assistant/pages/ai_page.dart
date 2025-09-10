import 'package:flutter/material.dart';
import 'package:mobile/presentation/ai_assistant/ai_provider.dart';
import 'package:provider/provider.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA), // Background color
      appBar: AppBar(
        title: const Text(
          'Inventory Assistant',
          style: TextStyle(
            color: Color(0xFF212121), // Text color
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Ask about inventory',
                labelStyle: const TextStyle(color: Color(0xFF212121)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5283FF), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5283FF), width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF212121)),
                  onPressed: () => controller.clear(),
                ),
              ),
              cursorColor: const Color(0xFF5283FF),
            ),
            const SizedBox(height: 16),
            // Ask Button
            ElevatedButton(
              onPressed: () {
                provider.askInventory(controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5283FF), // Button color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Ask'),
            ),
            const SizedBox(height: 16),
            // Loading Indicator
            if (provider.isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5283FF)),
                ),
              ),
            // Error Message
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  provider.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // Response Card
            if (provider.response != null)
              Expanded(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item: ${provider.response!.item}',
                            style: const TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current Stock: ${provider.response!.currentStock}',
                            style: const TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Average Daily Sales: ${provider.response!.averageDailySales}',
                            style: const TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Restock Needed: ${provider.response!.restockNeeded ? "Yes" : "No"}',
                            style: TextStyle(
                              color: provider.response!.restockNeeded
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recommendation: ${provider.response!.recommendation}',
                            style: const TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}