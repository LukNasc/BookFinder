import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../models/books.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _entries = <dynamic>[];
  String _search = 'all';

  Future<Book> fetchBook(String search) async {
    final response =
        await http.get('https://api.itbook.store/1.0/search/$search');

    if (response.statusCode == 200) {
      var result = Book.fromJson(json.decode(response.body));
      setState(() {
        _entries = result.books;
      });
      return result;
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text("Book Finder"),
      ),
      child: SafeArea(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                CupertinoTextField(
                  placeholder: "Search you book",
                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                ),
                FutureBuilder<Book>(
                  future: fetchBook(_search),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                          padding: EdgeInsets.only(top: 20),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {
                                var url = _entries[index]['url'];
                                if (await canLaunch(url)) {
                                  await launch(url, forceWebView: true);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: Container(
                                  height: 50,
                                  child: Row(children: <Widget>[
                                    Image(
                                      image: NetworkImage(
                                          "${_entries[index]['image']}"),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          "${_entries[index]['price']}",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 40,
                                    ),
                                    Container(
                                      width: 200,
                                      child: Text(
                                        "${_entries[index]['title']}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    )
                                  ])),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount: _entries != null ? _entries.length : 0);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CupertinoActivityIndicator();
                  },
                ),
              ],
            )),
      ),
    );
  }
}
