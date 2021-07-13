import 'package:xml/xml.dart';

class HotApiBoardGame {
  final String id;
  final String rank;
  final String thumbnail;
  final String name;
  final String yearpublished;

  HotApiBoardGame({
    required this.rank,
    required this.id,
    required this.thumbnail,
    required this.name,
    required this.yearpublished,
  });

  factory HotApiBoardGame.fromXMLNode(XmlNode node) {
    print(node);
    return HotApiBoardGame(
      id: node.getAttribute("id")!,
      rank: node.getAttribute("rank")!,
      thumbnail: node.findElements("thumbnail").first.getAttribute("value")!,
      name: node.findElements("name").first.getAttribute("value")!,
      yearpublished:
          node.findElements("yearpublished").first.getAttribute("value")!,
    );
  }
}
