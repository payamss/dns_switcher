import 'package:flutter/material.dart';
import '../services/dns_service.dart';

class DnsInterfaceSelector extends StatelessWidget {
  final DnsService service;

  const DnsInterfaceSelector({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: service.interfaces,
      builder: (_, interfaces, __) {
        return ValueListenableBuilder<String?>(
          valueListenable: service.selectedInterface,
          builder: (_, selected, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Network Interface:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selected,
                  hint: const Text("Choose interface"),
                  items: interfaces.map((iface) {
                    return DropdownMenuItem(value: iface, child: Text(iface));
                  }).toList(),
                  onChanged: (val) => service.selectedInterface.value = val,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
