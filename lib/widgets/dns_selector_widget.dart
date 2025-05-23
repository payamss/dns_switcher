import 'package:flutter/material.dart';
import '../services/dns_service.dart';

class DnsSelectorWidget extends StatelessWidget {
  final DnsService service;

  const DnsSelectorWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: service.selectedPresetLabel,
      builder: (_, selectedLabel, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select DNS Provider",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedLabel,
              hint: const Text("Choose provider"),
              items: service.presets.map((preset) {
                return DropdownMenuItem<String>(
                  value: preset.label,
                  child: Text(preset.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  service.selectPresetByLabel(value);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
