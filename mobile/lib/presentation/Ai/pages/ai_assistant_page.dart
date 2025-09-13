import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/Ai/bloc/assistant_cubit.dart';


class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssistantCubit(),
      child: const AiAssistantPageContent(),
    );
  }
}

class AiAssistantPageContent extends StatelessWidget {
  const AiAssistantPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI Assistant"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  "AI Assistant",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.read<AssistantCubit>().clearMessages(),
                  child: const Text("Clear"),
                )
              ],
            ),
            const SizedBox(height: 16),

            // --- Chat Messages ---
            Expanded(
              child: BlocBuilder<AssistantCubit, AssistantState>(
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Hello! I’m your Stockwise AI Assistant powered by advanced "
                        "language models. I can provide deep insights into your inventory, "
                        "recommend trends, and help you optimize your stock management. "
                        "What would you like to explore?",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(state.messages[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- Input Field ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final msg = controller.text.trim();
                      context.read<AssistantCubit>().sendMessage(msg);
                      controller.clear();
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
