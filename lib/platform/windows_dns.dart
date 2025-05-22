import 'dart:io';
import '../core/dns_platform_interface.dart';

class WindowsDnsChanger implements DnsPlatformInterface {
  final String interfaceName;

  WindowsDnsChanger({this.interfaceName = "Ethernet"});

  @override
  Future<List<String>> getCurrentDns() async {
    final result = await Process.run('netsh', [
      'interface',
      'ip',
      'show',
      'dns',
    ]);
    return result.stdout
        .toString()
        .split('\n')
        .where((line) => line.contains("Statically Configured DNS Servers"))
        .map((e) => e.trim())
        .toList();
  }

  @override
  Future<bool> setDns(List<String> ipv4, List<String> ipv6) async {
    try {
      await Process.run('netsh', [
        'interface',
        'ip',
        'set',
        'dns',
        interfaceName,
        'static',
        ipv4.first,
      ]);
      if (ipv4.length > 1) {
        for (int i = 1; i < ipv4.length; i++) {
          await Process.run('netsh', [
            'interface',
            'ip',
            'add',
            'dns',
            interfaceName,
            ipv4[i],
            'index=${i + 1}',
          ]);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
