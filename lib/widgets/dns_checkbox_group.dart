import 'package:flutter/material.dart';
import '../services/dns_service.dart';

class DnsCheckboxGroup extends StatelessWidget {
  final DnsService service;

  const DnsCheckboxGroup({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.selectedPreset,
      builder: (_, preset, __) {
        if (preset == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select IPs:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...preset.ipv4.map(
              (ip) => ValueListenableBuilder<Set<String>>(
                valueListenable: service.selectedIPv4,
                builder: (_, selected, __) => CheckboxListTile(
                  title: Text("IPv4: $ip"),
                  value: selected.contains(ip),
                  onChanged: (val) => service.toggle(ip, 'v4', val!),
                ),
              ),
            ),
            ...preset.ipv6.map(
              (ip) => ValueListenableBuilder<Set<String>>(
                valueListenable: service.selectedIPv6,
                builder: (_, selected, __) => CheckboxListTile(
                  title: Text("IPv6: $ip"),
                  value: selected.contains(ip),
                  onChanged: (val) => service.toggle(ip, 'v6', val!),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
