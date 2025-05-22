class DnsPreset {
  final String label;
  final List<String> ipv4;
  final List<String> ipv6;

  DnsPreset({required this.label, required this.ipv4, required this.ipv6});

  factory DnsPreset.fromJson(Map<String, dynamic> json) {
    return DnsPreset(
      label: json['label'],
      ipv4: List<String>.from(json['ipv4']),
      ipv6: List<String>.from(json['ipv6']),
    );
  }
}
