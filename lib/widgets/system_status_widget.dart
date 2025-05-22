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
  String publicIpv4Location = 'Loading...';
  String publicIpv6Location = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    final locals = await _getAllLocalIps();
    final ipv4 = await _getPublicIp('https://api.ipify.org');
    final ipv6 = await getPublicIpv6();

    final ipv4Loc = ipv4 != null ? await getGeoInfo(ipv4) : 'Unknown';
    final ipv6Loc = ipv6 != null ? await getGeoInfo(ipv6) : 'Unknown';

    setState(() {
      localIps = locals;
      publicIpv4 = ipv4 ?? 'Not found';
      publicIpv6 = ipv6 ?? 'Not found';
      publicIpv4Location = ipv4Loc;
      publicIpv6Location = ipv6Loc;
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
          final emoji = addr.type == InternetAddressType.IPv4 ? '🔹' : '🟣';
          ips.add('$emoji ${interface.name}: ${addr.address}');
        }
      }
    }
    return ips.isEmpty ? ['⚠️ Not found'] : ips;
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
    } catch (_) {}
    return null;
  }

  Future<String> getGeoInfo(String ip) async {
    try {
      final res = await http.get(Uri.parse('https://ipapi.co/$ip/json/'));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final country = json['country_name'];
        final city = json['city'];
        return '$city, $country';
      }
    } catch (_) {}
    return 'Unknown location';
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (title == 'Local IPs' || title == 'Public IPs')
                  ElevatedButton.icon(
                    onPressed: _loadSystemInfo,
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
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          "Local IPs",
          Icons.lan,
          localIps.map((ip) {
            final parts = ip.split(': ');
            return Tooltip(
              message: parts.length > 1 ? parts.last : '',
              child: Text(ip, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
        _buildSection("Public IPs", Icons.public, [
          Tooltip(
            message: publicIpv4Location,
            child: Row(
              children: [
                const Icon(Icons.language, size: 18),
                const SizedBox(width: 6),
                Text("IPv4: $publicIpv4"),
              ],
            ),
          ),
          Tooltip(
            message: publicIpv6Location,
            child: Row(
              children: [
                const Icon(Icons.language, size: 18),
                const SizedBox(width: 6),
                Text("IPv6: $publicIpv6"),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}
