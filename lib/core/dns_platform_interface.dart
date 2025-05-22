abstract class DnsPlatformInterface {
  Future<List<String>> getCurrentDns();
  Future<List<String>> getAvailableInterfaces();

  Future<bool> setDns(
    List<String> ipv4,
    List<String> ipv6, {
    required String interface,
  });
}
