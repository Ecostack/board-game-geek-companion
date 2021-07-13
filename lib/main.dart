import 'package:board_game/hot_api_board_game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'search_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: TabBarScaffold());
  }
}
//
// class SearchBarWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: CupertinoSearchTextField(
//
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const SearchRoute()),
//         ),
//       ),
//     );
//   }
// }

class TabBarScaffold extends StatefulWidget {
  @override
  _TabBarScaffoldState createState() => _TabBarScaffoldState();
}

class _TabBarScaffoldState extends State<TabBarScaffold> {
  late final List<Widget> _pages = <Widget>[
    HomeWidget(),
    HotPageWidget(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to Flutter")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_sharp),
            label: 'Hotpage',
          ),
        ],
      ),
    );
  }
}

class HotPageListView extends StatelessWidget {
  final List<HotApiBoardGame> items;

  HotPageListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];

          return ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: _thumbnail(item),
              subtitle: _title(item.yearpublished),
              title: _title(item.name));
        });
  }

  Widget _thumbnail(HotApiBoardGame item) {
    return Container(
        constraints: BoxConstraints.tightFor(width: 100.0),
        child: Image.network(
          item.thumbnail,
          fit: BoxFit.fitWidth,
        ));
  }

  Widget _title(String text) {
    return Text(text);
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SearchBarWidgetStateless()
        ],
      ),
    );
  }
}

class HotPageWidget extends StatefulWidget {
  @override
  _HotPageWidget createState() => _HotPageWidget();
}

class _HotPageWidget extends State<HotPageWidget> {
  late Future<Iterable<HotApiBoardGame>> futureHotPage;

  Future<http.Response> fetchHotPage() {
    return http
        .get(Uri.parse('https://boardgamegeek.com/xmlapi2/hot?type=boardgame'));
  }

  Future<Iterable<HotApiBoardGame>> fetchAndParseHotPage() async {
    var hotPageXML = await fetchHotPage();
    print(hotPageXML);
    if (hotPageXML.statusCode == 200) {
      print(hotPageXML.body);
      final document = XmlDocument.parse(hotPageXML.body);
      final items = document.findAllElements("item");
      return items.map((e) => HotApiBoardGame.fromXMLNode(e));
    }
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load hot page');
  }

  @override
  void initState() {
    // TODO: implement initState

    futureHotPage = fetchAndParseHotPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Iterable<HotApiBoardGame>>(
      future: futureHotPage,
      builder: (context, snapshot) {
        print(snapshot);
        if (snapshot.hasData) {
          return HotPageListView(items: snapshot.data!.toList());
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }
}
