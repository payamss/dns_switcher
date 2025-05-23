import 'package:flutter/material.dart';

class CurrentDnsWidget extends StatelessWidget {
  final List<String> dnsList;

  const CurrentDnsWidget({super.key, required this.dnsList});

  @override
  Widget build(BuildContext context) {
    final hasData = dnsList.any((dns) => dns.trim().isNotEmpty);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.dns, size: 20),
                SizedBox(width: 8),
                Text(
                  "Current DNS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasData)
              ...dnsList.where((e) => e.trim().isNotEmpty).map(
                    (e) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.arrow_right, size: 20),
                      title: Text(
                        e.trim(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
            else
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "No static DNS configured.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
