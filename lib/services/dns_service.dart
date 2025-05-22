import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../core/dns_platform_interface.dart';
import '../models/dns_preset.dart';
import '../platform/windows_dns.dart';

class DnsService {
  final WindowsDnsChanger platformChanger = WindowsDnsChanger();

  List<DnsPreset> presets = [];

  final ValueNotifier<Set<String>> selectedIPv4 = ValueNotifier({});
  final ValueNotifier<Set<String>> selectedIPv6 = ValueNotifier({});
  final ValueNotifier<String> customIPv4 = ValueNotifier('');
  final ValueNotifier<String> customIPv6 = ValueNotifier('');

  final ValueNotifier<DnsPreset?> selectedPreset = ValueNotifier(null);

  final ValueNotifier<String?> selectedInterface = ValueNotifier(null);
  final ValueNotifier<List<String>> _interfaces = ValueNotifier([]);
  ValueListenable<List<String>> get interfaces => _interfaces;

  /// برای نمایش DNS فعلی همان اینترفیس انتخاب‌شده
  final ValueNotifier<List<String>> interfaceDnsPreview = ValueNotifier([]);

  /// بارگذاری لیست اینترفیس‌ها + انتخاب هوشمند اولیه
  Future<void> loadInterfaces() async {
    final list = await platformChanger.getAvailableInterfaces();
    _interfaces.value = list;

    // انتخاب خودکار بهترین اینترفیس
    final preferred = list.firstWhere(
      (e) =>
          e.toLowerCase().contains("ethernet") ||
          e.toLowerCase().contains("wi-fi"),
      orElse: () => list.isNotEmpty ? list.first : '',
    );

    if (preferred.isNotEmpty) {
      selectedInterface.value = preferred;
    }

    // وقتی اینترفیس عوض شد، پیش‌نمایش DNS فعلی‌اش هم بروز شود
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

  void selectPreset(DnsPreset? preset) {
    selectedPreset.value = preset;
    if (preset != null) {
      selectedIPv4.value = {...preset.ipv4};
      selectedIPv6.value = {...preset.ipv6};
    }
  }

  Future<void> applySelected() async {
    final ipv4 = [...selectedIPv4.value];
    final ipv6 = [...selectedIPv6.value];
    if (customIPv4.value.trim().isNotEmpty) ipv4.add(customIPv4.value.trim());
    if (customIPv6.value.trim().isNotEmpty) ipv6.add(customIPv6.value.trim());

    final iface = selectedInterface.value;
    if (iface == null || iface.isEmpty) return;

    await platformChanger.setDns(ipv4, ipv6, interface: iface);
  }

  /// گرفتن لیست DNS برای اینترفیس انتخاب‌شده (برای کارت‌های UI)
  Future<List<String>> getCurrentDns() async {
    return await platformChanger.getCurrentDns();
  }

  /// گرفتن DNSهای همه‌ی اینترفیس‌ها برای نمایش کلی
  Future<Map<String, List<String>>> getCurrentDnsPerInterface() async {
    final interfaces = _interfaces.value;
    if (interfaces.isEmpty) return {};
    return await platformChanger.getDnsPerInterface(interfaces);
  }
}
