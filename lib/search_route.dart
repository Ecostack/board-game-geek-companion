import 'package:board_game/hot_api_board_game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'package:bgg_api/bgg_api.dart';

class SearchBarWidgetStateless extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: CupertinoSearchTextField(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchRoute())),
      ),
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  final Function(String text) onChanged;

  const SearchBarWidget({required this.onChanged});

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: CupertinoSearchTextField(
        onChanged: widget.onChanged,
      ),
    );
  }
}

class SearchRoute extends StatelessWidget {
  const SearchRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchWidget(),
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  Future<Iterable<BoardGameRef>>? futureSearchBoardGames;

  void search(String term) async {
    var bgg = Bgg();
    print(term);
    futureSearchBoardGames = bgg.searchBoardGames(term);
  }

  @override
  Widget build(BuildContext context) {
    var searchBarWidget = SearchBarWidget(onChanged: search);
    if(futureSearchBoardGames!= null) {
      return Column(
        children: [searchBarWidget,

          FutureBuilder<Iterable<BoardGameRef>>(
            future: futureSearchBoardGames,
            builder: (context, snapshot) {
              //print(snapshot);
              if (snapshot.hasData) {
                return SearchListView(items: snapshot.data!.toList());
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          )
        ],
      );
    }
    return Column(
        children: [searchBarWidget]
    );

  }
}


class SearchListView extends StatelessWidget {
  final List<BoardGameRef> items;

  SearchListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];

          return ListTile(
              contentPadding: EdgeInsets.all(10.0),
              subtitle: _title(item.yearPublished.toString()),
              title: _title(item.name??"No Name"));
        });
  }


  Widget _title(String text) {
    return Text(text);
  }
}

