import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class SystemStatusWidget extends StatefulWidget {
  const SystemStatusWidget({super.key});

  @override
  State<SystemStatusWidget> createState() => _SystemStatusWidgetState();
}

class _SystemStatusWidgetState extends State<SystemStatusWidget> {
  List<String> localIps = ['Loading...'];
  String publicIpv4 = 'Loading...';
  String publicIpv6 = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    final locals = await _getAllLocalIps();
    final ipv4 = await _getPublicIp('https://api.ipify.org');
    final ipv6 = await getPublicIpv6();
    setState(() {
      localIps = locals;
      publicIpv4 = ipv4 ?? 'Not found';
      publicIpv6 = ipv6 ?? 'Not found';
    });
  }

  Future<List<String>> _getAllLocalIps() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.any,
    );
    final ips = <String>[];
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback) {
          ips.add('${interface.name} → ${addr.type.name}: ${addr.address}');
        }
      }
    }
    return ips.isEmpty ? ['Not found'] : ips;
  }

  Future<String?> _getPublicIp(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) return res.body;
    } catch (_) {}
    return null;
  }

  Future<String?> getPublicIpv6() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://api64.ipify.org'));
      final response = await request.close();
      if (response.statusCode == 200) {
        return await response.transform(utf8.decoder).join();
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Local IPs:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...localIps.map((ip) => Text(ip)),
        const SizedBox(height: 10),
        const Text(
          'Public IPs:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('IPv4: $publicIpv4'),
        Text('IPv6: $publicIpv6'),
      ],
    );
  }
}
