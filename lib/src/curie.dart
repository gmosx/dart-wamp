part of wamp;

class CurieCodec {
  Map<String, String> map = new Map();

  CurieCodec();

  void addPrefix(String prefix, String expansion) {
    map[prefix] = expansion;
  }

  /**
   * Encode the given URI to CURIE. If no appropriate prefix mapping
   * is available, return original URI.
   */
  String encode(String uri) {
    return uri; // TODO
  }

  /**
   * Decode given CURIE to full URI. Returns the original CURIE if it cannot be
   * decoded.
   */
  String decode(String curie) {
    return curie; // TODO
  }
}
