import 'package:flutter/material.dart';
import '../services/dns_service.dart';
import '../models/dns_preset.dart';

class DnsSelectorWidget extends StatelessWidget {
  final DnsService service;

  const DnsSelectorWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<DnsPreset?>(
          valueListenable: service.selectedPreset,
          builder: (_, selected, __) {
            return DropdownButton<DnsPreset>(
              value: selected,
              isExpanded: true,
              hint: const Text("Select DNS Provider"),
              items: service.presets.map((preset) {
                return DropdownMenuItem<DnsPreset>(
                  value: preset,
                  child: Text(preset.label),
                );
              }).toList(),
              onChanged: service.selectPreset,
            );
          },
        ),
      ],
    );
  }
}
