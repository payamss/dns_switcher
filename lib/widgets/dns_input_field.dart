import 'package:flutter/material.dart';
import '../services/dns_service.dart';
import 'package:flutter/services.dart';

class Ipv4InputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    List<String> octets = [];

    for (int i = 0; i < digits.length && octets.length < 4; i += 3) {
      int end = (i + 3 > digits.length) ? digits.length : i + 3;
      octets.add(digits.substring(i, end));
    }

    String formatted = octets.join('.');
    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class DnsInputField extends StatefulWidget {
  final DnsService service;

  const DnsInputField({super.key, required this.service});

  @override
  State<DnsInputField> createState() => _DnsInputFieldState();
}

class _DnsInputFieldState extends State<DnsInputField> {
  late final TextEditingController ipv4Controller;
  late final TextEditingController ipv6Controller;

  @override
  void initState() {
    super.initState();

    ipv4Controller = TextEditingController(
      text: widget.service.customIPv4.value,
    );
    ipv6Controller = TextEditingController(
      text: widget.service.customIPv6.value,
    );

    // Listen to changes in ValueNotifier and update controllers
    widget.service.customIPv4.addListener(_updateIpv4);
    widget.service.customIPv6.addListener(_updateIpv6);

    // Also listen to controller changes and update ValueNotifier
    ipv4Controller.addListener(() {
      widget.service.customIPv4.value = ipv4Controller.text;
    });
    ipv6Controller.addListener(() {
      widget.service.customIPv6.value = ipv6Controller.text;
    });
  }

  void _updateIpv4() {
    if (ipv4Controller.text != widget.service.customIPv4.value) {
      ipv4Controller.text = widget.service.customIPv4.value;
    }
  }

  void _updateIpv6() {
    if (ipv6Controller.text != widget.service.customIPv6.value) {
      ipv6Controller.text = widget.service.customIPv6.value;
    }
  }

  @override
  void dispose() {
    ipv4Controller.dispose();
    ipv6Controller.dispose();
    widget.service.customIPv4.removeListener(_updateIpv4);
    widget.service.customIPv6.removeListener(_updateIpv6);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom IPv4:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: ipv4Controller,
          decoration: const InputDecoration(hintText: 'Enter IPv4 address'),
          inputFormatters: [Ipv4InputFormatter()],
        ),
        const SizedBox(height: 10),
        const Text(
          'Custom IPv6:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: ipv6Controller,
          decoration: const InputDecoration(hintText: 'Enter IPv6 address'),
        ),
      ],
    );
  }
}
