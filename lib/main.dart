import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'model/Req.dart';

void main() {
  // News App
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ApiPage(),
  ));
}
var key = 'acdcde000d784b748d1ebe854792e79a';

Future<Req> fetchReq() async {
  final response = await http.get(
      'http://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=$key');

  if (response.statusCode == 200) {
    return Req.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failure!');
  }
}

class ApiPage extends StatefulWidget {
  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  Future<Req> futureReq;

  @override
  void initState() {
    super.initState();
    futureReq = fetchReq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder<Req>(
            future: futureReq,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.articles.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.articles[index].urlToImage != null &&
                        snapshot.data.articles[index].title != null) {
                      return Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: InkWell(
                                        onTap: () {
                                          // print(snapshot.data.articles[index].url);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => WebView(
                                                        initialUrl: snapshot
                                                            .data
                                                            .articles[index]
                                                            .url,
                                                        javascriptMode:
                                                            JavascriptMode
                                                                .unrestricted,
                                                      )));
                                        },
                                        child: Image.network(
                                          snapshot
                                              .data.articles[index].urlToImage,
                                          height: 200,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    snapshot.data.articles[index].title,
                                    maxLines: 4,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    snapshot.data.articles[index].description,
                                    maxLines: 6,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  )
                                ],
                              )));
                    }
                    return Text("");
                  },
                );
              } else if (snapshot.hasError) {
                return Text("Error Occurred");
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}
