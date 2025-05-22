import 'package:flutter/material.dart';
import '../services/dns_service.dart';

class DnsCheckboxList extends StatelessWidget {
  final DnsService service;

  const DnsCheckboxList({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: service.presets.map((preset) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preset.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...preset.ipv4.map(
              (ip) => ValueListenableBuilder<Set<String>>(
                valueListenable: service.selectedIPv4,
                builder: (_, selected, __) {
                  return CheckboxListTile(
                    title: Text("IPv4: $ip"),
                    value: selected.contains(ip),
                    onChanged: (val) => service.toggle(ip, 'v4', val!),
                  );
                },
              ),
            ),
            ...preset.ipv6.map(
              (ip) => ValueListenableBuilder<Set<String>>(
                valueListenable: service.selectedIPv6,
                builder: (_, selected, __) {
                  return CheckboxListTile(
                    title: Text("IPv6: $ip"),
                    value: selected.contains(ip),
                    onChanged: (val) => service.toggle(ip, 'v6', val!),
                  );
                },
              ),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}
