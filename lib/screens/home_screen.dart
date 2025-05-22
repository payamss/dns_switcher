import 'package:dns_switcher/widgets/dns_checkbox_group.dart';
import 'package:dns_switcher/widgets/system_status_widget.dart';
import 'package:flutter/material.dart';
import '../services/dns_service.dart';
import '../widgets/dns_checkbox_list.dart';
import '../widgets/dns_input_field.dart';
import '../widgets/dns_selector_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = DnsService();
  List<String> currentDns = [];

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    await service.loadPresets();
    final dns = await service.getCurrentDns();
    setState(() => currentDns = dns);
  }

  Future<void> _onApply() async {
    await service.applySelected();
    final dns = await service.getCurrentDns();
    setState(() => currentDns = dns);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("DNS Applied")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DNS Switcher')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            const SystemStatusWidget(), // ✅ در بالا نمایش داده می‌شود
            const SizedBox(height: 10),
            Text(
              "Current DNS: ${currentDns.join(', ')}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            DnsSelectorWidget(service: service), // Dropdown selector
            const SizedBox(height: 10),
            DnsCheckboxGroup(service: service),
            DnsInputField(service: service),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onApply,
              icon: const Icon(Icons.dns),
              label: const Text("Apply DNS"),
            ),
          ],
        ),
      ),
    );
  }
}
