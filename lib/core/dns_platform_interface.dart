abstract class DnsPlatformInterface {
  Future<List<String>> getCurrentDns();
  Future<bool> setDns(List<String> ipv4, List<String> ipv6);
}
