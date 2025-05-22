import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/dns_platform_interface.dart';
import '../models/dns_preset.dart';
import '../platform/windows_dns.dart';
import 'package:flutter/foundation.dart';

class DnsService {
  final DnsPlatformInterface platformChanger =
      WindowsDnsChanger(); // وابسته به پلتفرم
  List<DnsPreset> presets = [];

  final ValueNotifier<Set<String>> selectedIPv4 = ValueNotifier({});
  final ValueNotifier<Set<String>> selectedIPv6 = ValueNotifier({});
  final ValueNotifier<String> customIPv4 = ValueNotifier('');
  final ValueNotifier<String> customIPv6 = ValueNotifier('');

  Future<void> loadPresets() async {
    final data = await rootBundle.loadString('assets/dns_presets.json');
    final list = jsonDecode(data) as List;
    presets = list.map((e) => DnsPreset.fromJson(e)).toList();
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

  Future<void> applySelected() async {
    final ipv4 = [...selectedIPv4.value];
    final ipv6 = [...selectedIPv6.value];
    if (customIPv4.value.trim().isNotEmpty) ipv4.add(customIPv4.value.trim());
    if (customIPv6.value.trim().isNotEmpty) ipv6.add(customIPv6.value.trim());
    await platformChanger.setDns(ipv4, ipv6);
  }

  Future<List<String>> getCurrentDns() async {
    return await platformChanger.getCurrentDns();
  }

  final ValueNotifier<DnsPreset?> selectedPreset = ValueNotifier(null);

  void selectPreset(DnsPreset? preset) {
    selectedPreset.value = preset;
    if (preset != null) {
      selectedIPv4.value = {...preset.ipv4};
      selectedIPv6.value = {...preset.ipv6};
    }
  }
}
