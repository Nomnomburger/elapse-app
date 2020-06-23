import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elapse/game.dart';
import 'dart:developer';

void main() {
  runApp(MaterialApp(home: GameList()));
}

class GameList extends StatefulWidget {
  const GameList({Key key}) : super(key: key);
  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  Future<Tournament> futureTournament;

  matchType(game) {
    //gets the type of match
    if (game['round'] == 2) {
      return 'Q ';
    } else if (game['round'] == 6) {
      return 'R ';
    } else if (game['round'] == 3) {
      return 'QF ';
    } else if (game['round'] == 4) {
      return 'SF ';
    } else if (game['round'] == 5) {
      return 'F ';
    }
  }

  instanceModifier(game) {
    //removes .1 if type is Q
    if (game['round'] == 2) {
      return '';
    } else {
      return game['instance'].toString() + '.';
    }
  }

  Widget mainDataModifier(game) {
    //Changes the score to show field and time if match hasnt been played yet
    if (game['redscore'] == 0 && game['bluescore'] == 0) {
      return Row(children: <Widget>[
        Container(
          width: 60,
          child: Text(
            game['field'],
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            textAlign: TextAlign.left,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        Spacer(flex: 1),
        Container(
          width: 45,
          child: Text(
            game['scheduled'].toString().substring(11, 16),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            textAlign: TextAlign.right,
          ),
        ),
      ]);
    } else {
      return Row(children: <Widget>[
        Container(
          width: 35,
          child: Text(
            game['redscore'].toString(),
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.normal),
            textAlign: TextAlign.left,
          ),
        ),
        Spacer(flex: 1),
        Container(
          width: 35,
          child: Text(
            game['bluescore'].toString(),
            style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.right,
          ),
        ),
      ]);
    }
  }

  sizeChanger(game) {
    //changes size for the list if match not played
    if (game['redscore'] == 0 && game['bluescore'] == 0) {
      return 110.0;
    } else {
      return 80.0;
    }
  }

  Widget matchDivider(game) {
    // Removes divider if it's the first match
    if (game['matchnum'] == 1 && game['round'] == 2) {
      return Container(
        color: const Color.fromARGB(255, 245, 250, 249),
        height: 15,
      );
    } else {
      return Divider(
        color: const Color(0xE6E6E6FF),
        height: 20,
        thickness: 1,
        indent: 20,
        endIndent: 20,
      );
    }
  }

  Widget gameTemplate(game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          matchDivider(game),
          DefaultTextStyle(
            child: Row(
              children: <Widget>[
                Container(
                  width: 25,
                  child: Text(matchType(game), style: TextStyle(fontSize: 16)),
                ),
                Container(
                  width: 70,
                  child: Text(
                      instanceModifier(game) + game['matchnum'].toString(),
                      style: TextStyle(fontSize: 25)),
                ),
                Spacer(flex: 3),
                Container(
                  width: 60,
                  child: DefaultTextStyle(
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(game['red1'], textAlign: TextAlign.left),
                        Text(game['red2'], textAlign: TextAlign.left),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: sizeChanger(game),
                  child: mainDataModifier(game),
                ),
                Container(
                    width: 60,
                    child: DefaultTextStyle(
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(game['blue1'], textAlign: TextAlign.right),
                          Text(game['blue2'], textAlign: TextAlign.right),
                        ],
                      ),
                    ))
              ],
            ),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    futureTournament = fetchTournament('RE-VRC-19-8481');
  }

  @override
  Widget build(BuildContext context) {
    // https://stackoverflow.com/questions/52146850/how-to-use-futurebuilder-inside-sliverlist
    final appBarSliver = SliverAppBar(
      backgroundColor: const Color.fromARGB(255, 245, 250, 249),
      expandedHeight: 150.0,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          'Matches',
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
        ),
        titlePadding: EdgeInsetsDirectional.only(start: 20, bottom: 16),
      ),
      floating: false,
      pinned: true,
      elevation: 8,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Match Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
        color: const Color.fromARGB(255, 245, 250, 249),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 245, 250, 249),
            body: FutureBuilder<Tournament>(
              future: futureTournament,
              builder: (context, snapshot) {
                Widget matchListSliver;
                if (snapshot.hasData) {
                  //print(snapshot.data.matches[0]['division']);
                  matchListSliver = SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return gameTemplate(snapshot.data.matches[index]);
                    },
                    childCount: snapshot.data.matches.length,
                  ));
                } else if (snapshot.hasError) {
                  print('error');
                  return Text("${snapshot.error}");
                } else {
                  print('loading');
                  // By default, show a loading spinner.
                  matchListSliver = SliverFillRemaining(
                      child: Center(
                    child: Container(child: CircularProgressIndicator()),
                  ));
                }
                return RefreshIndicator(
                  child: CustomScrollView(
                    slivers: <Widget>[appBarSliver, matchListSliver],
                  ),
                  onRefresh: _getData,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getData() async {
    setState(() {
      futureTournament = fetchTournament('RE-VRC-19-8481');

      //show a snackbar to show that loading new matches is complete
      final reloadSnackBar = SnackBar(content: Text('Refreshed matches list'));
      Scaffold.of(context).showSnackBar(reloadSnackBar);
    });
  }
}
