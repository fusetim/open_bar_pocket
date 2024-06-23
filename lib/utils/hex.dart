String toHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

List<int> fromHex(String hex) {
  return List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
}