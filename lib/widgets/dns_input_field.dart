import 'package:flutter/material.dart';
import '../services/dns_service.dart';

class DnsInputField extends StatelessWidget {
  final DnsService service;

  const DnsInputField({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom IPv4:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ValueListenableBuilder<String>(
          valueListenable: service.customIPv4,
          builder: (_, value, __) => TextField(
            onChanged: (val) => service.customIPv4.value = val,
            controller: TextEditingController(text: value),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Custom IPv6:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ValueListenableBuilder<String>(
          valueListenable: service.customIPv6,
          builder: (_, value, __) => TextField(
            onChanged: (val) => service.customIPv6.value = val,
            controller: TextEditingController(text: value),
          ),
        ),
      ],
    );
  }
}
