import 'dart:io';
import 'package:flutter/material.dart';

import '../core/dns_platform_interface.dart';

class WindowsDnsChanger implements DnsPlatformInterface {
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

  Future<Map<String, List<String>>> getDnsPerInterface(
    List<String> interfaces,
  ) async {
    final Map<String, List<String>> dnsMap = {};

    for (final iface in interfaces) {
      final result = await Process.run('netsh', [
        'interface',
        'ip',
        'show',
        'dns',
        'name=$iface',
      ]);

      final output = result.stdout.toString();
      final dnsLines = output
          .split('\n')
          .where((line) => line.contains("Statically Configured DNS Servers"))
          .toList();

      dnsMap[iface] = dnsLines
          .map(
            (e) =>
                e.replaceAll("Statically Configured DNS Servers:", "").trim(),
          )
          .toList();
    }

    return dnsMap;
  }

  @override
  Future<List<String>> getAvailableInterfaces() async {
    final result = await Process.run('netsh', [
      'interface',
      'show',
      'interface',
    ]);
    final lines = result.stdout.toString().split('\n');
    return lines
        .skip(3) // skip headers
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          final parts = line.trim().split(RegExp(r'\s{2,}'));
          return parts.length == 4 ? parts[3] : null;
        })
        .whereType<String>()
        .toList();
  }

  @override
  Future<bool> setDns(
    List<String> ipv4,
    List<String> ipv6, {
    required String interface,
  }) async {
    try {
      if (ipv4.isEmpty) return false;

      // Set the first DNS
      await Process.run('netsh', [
        'interface',
        'ip',
        'set',
        'dns',
        interface,
        'static',
        ipv4.first,
      ]);

      // Add additional DNS
      for (int i = 1; i < ipv4.length; i++) {
        await Process.run('netsh', [
          'interface',
          'ip',
          'add',
          'dns',
          interface,
          ipv4[i],
          'index=${i + 1}',
        ]);
      }

      return true;
    } catch (e) {
      debugPrint("DNS SET ERROR: $e");
      return false;
    }
  }
}
