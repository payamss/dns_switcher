import 'package:flutter/material.dart';

class CurrentDnsPerInterfaceWidget extends StatelessWidget {
  final Map<String, List<String>> dnsMap;
  final VoidCallback onReload;

  const CurrentDnsPerInterfaceWidget({
    super.key,
    required this.dnsMap,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Current DNS (Per Interface)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Reload", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Interface",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "DNS Servers",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (dnsMap.isEmpty)
              const Text("No data found.", style: TextStyle(color: Colors.grey))
            else
              ...dnsMap.entries.map((entry) {
                final name = entry.key;
                final dnsList = entry.value.where((e) => e.isNotEmpty).toList();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(name)),
                    Expanded(
                      child: dnsList.isEmpty
                          ? const Text(
                              "None",
                              style: TextStyle(color: Colors.grey),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  dnsList.map((dns) => Text(dns)).toList(),
                            ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
