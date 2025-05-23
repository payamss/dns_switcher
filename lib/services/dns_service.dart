// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dns_preset.dart';
import '../platform/windows_dns.dart';

class DnsService {
  final WindowsDnsChanger platformChanger = WindowsDnsChanger();

  List<DnsPreset> presets = [];

  final ValueNotifier<Set<String>> selectedIPv4 = ValueNotifier({});
  final ValueNotifier<Set<String>> selectedIPv6 = ValueNotifier({});
  final ValueNotifier<String> customIPv4 = ValueNotifier('');
  final ValueNotifier<String> customIPv6 = ValueNotifier('');

  final ValueNotifier<String?> selectedPresetLabel = ValueNotifier(null);

  final ValueNotifier<String?> selectedInterface = ValueNotifier(null);
  final ValueNotifier<List<String>> _interfaces = ValueNotifier([]);
  ValueListenable<List<String>> get interfaces => _interfaces;

  final ValueNotifier<List<String>> interfaceDnsPreview = ValueNotifier([]);

  static const _customIPv4Key = 'custom_ipv4';
  static const _customIPv6Key = 'custom_ipv6';

  Future<void> loadInterfaces() async {
    final list = await platformChanger.getAvailableInterfaces();
    _interfaces.value = list;

    final preferred = list.firstWhere(
      (e) =>
          e.toLowerCase().contains("ethernet") ||
          e.toLowerCase().contains("wi-fi"),
      orElse: () => list.isNotEmpty ? list.first : '',
    );

    if (preferred.isNotEmpty) {
      selectedInterface.value = preferred;
    }

    selectedInterface.addListener(() async {
      final iface = selectedInterface.value;
      if (iface != null) {
        final dnsMap = await getCurrentDnsPerInterface();
        interfaceDnsPreview.value = dnsMap[iface] ?? [];
      }
    });
  }

  Future<void> loadPresets() async {
    final data = await rootBundle.loadString('assets/dns_presets.json');
    final list = jsonDecode(data) as List;
    presets = list.map((e) => DnsPreset.fromJson(e)).toList();

    if (selectedPresetLabel.value == null ||
        !presets.any((p) => p.label == selectedPresetLabel.value)) {
      selectedPresetLabel.value = null;
    }
  }

  Future<void> loadCustomDnsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    customIPv4.value = prefs.getString(_customIPv4Key) ?? '';
    customIPv6.value = prefs.getString(_customIPv6Key) ?? '';
  }

  Future<void> saveCustomDnsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customIPv4Key, customIPv4.value);
    await prefs.setString(_customIPv6Key, customIPv6.value);
  }

  void toggle(String ip, String version, bool selected) {
    final set = version == 'v4' ? selectedIPv4.value : selectedIPv6.value;
    if (selected) {
      set.add(ip);
    } else {
      set.remove(ip);
    }
    if (version == 'v4') {
      selectedIPv4.notifyListeners();
    } else {
      selectedIPv6.notifyListeners();
    }
  }

  void selectPresetByLabel(String? label) {
    selectedPresetLabel.value = label;
    final preset = presets.firstWhere(
      (e) => e.label == label,
      orElse: () => DnsPreset(label: '', ipv4: [], ipv6: []),
    );
    selectedIPv4.value = {...preset.ipv4};
    selectedIPv6.value = {...preset.ipv6};
  }

  Future<void> applySelected() async {
    final ipv4 = [...selectedIPv4.value];
    final ipv6 = [...selectedIPv6.value];

    if (customIPv4.value.trim().isNotEmpty) ipv4.add(customIPv4.value.trim());
    if (customIPv6.value.trim().isNotEmpty) ipv6.add(customIPv6.value.trim());

    final iface = selectedInterface.value;
    if (iface == null || iface.isEmpty) return;

    await saveCustomDnsToPrefs(); // ⬅️ Save on apply
    await platformChanger.setDns(ipv4, ipv6, interface: iface);
  }

  Future<List<String>> getCurrentDns() async {
    return await platformChanger.getCurrentDns();
  }

  Future<Map<String, List<String>>> getCurrentDnsPerInterface() async {
    final interfaces = _interfaces.value;
    if (interfaces.isEmpty) return {};
    return await platformChanger.getDnsPerInterface(interfaces);
  }
}
