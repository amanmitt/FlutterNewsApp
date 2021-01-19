import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  // News App
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ApiPage(),
  ));
}

Future<Req> fetchReq() async {
  final response = await http.get(
      'http://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=acdcde000d784b748d1ebe854792e79a');

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
  WebViewController _controller;

  @override
  void initState() {
    super.initState();
    futureReq = fetchReq();

    //  WebView.platform = SurfaceAndroidWebView();
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

class Req {
  String status;
  int totalResults;
  List<Articles> articles;

  Req({this.status, this.totalResults, this.articles});

  Req.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalResults = json['totalResults'];
    if (json['articles'] != null) {
      articles = new List<Articles>();
      json['articles'].forEach((v) {
        articles.add(new Articles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['totalResults'] = this.totalResults;
    if (this.articles != null) {
      data['articles'] = this.articles.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Articles {
  Source source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;

  Articles(
      {this.source,
      this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedAt,
      this.content});

  Articles.fromJson(Map<String, dynamic> json) {
    source =
        json['source'] != null ? new Source.fromJson(json['source']) : null;
    author = json['author'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    urlToImage = json['urlToImage'];
    publishedAt = json['publishedAt'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.source != null) {
      data['source'] = this.source.toJson();
    }
    data['author'] = this.author;
    data['title'] = this.title;
    data['description'] = this.description;
    data['url'] = this.url;
    data['urlToImage'] = this.urlToImage;
    data['publishedAt'] = this.publishedAt;
    data['content'] = this.content;
    return data;
  }
}

class Source {
  String id;
  String name;

  Source({this.id, this.name});

  Source.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
