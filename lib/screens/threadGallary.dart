import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/Download.dart';
import 'package:knocky/helpers/bbcodeparser.dart' as bbcodeparser;
import 'package:knocky/models/thread.dart';

class ThreadGalleryScreen extends StatefulWidget {
  Thread thread;

  ThreadGalleryScreen({this.thread});

  @override
  _ThreadGalleryScreenState createState() => _ThreadGalleryScreenState();
}

class _ThreadGalleryScreenState extends State<ThreadGalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> urls = new List();
  int _currentPage = 0;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    print(this.widget.thread.posts.length);

    // Get all image urls
    this.widget.thread.posts.forEach((post) {
      List<bbob.Node> nodes = bbcodeparser.BBCodeParser().parse(post.content);
      nodes.forEach((node) {
        if (node.runtimeType == bbob.Element) {
          var element = node as bbob.Element;
          if (element.tag == 'img') {
            print(element.textContent);
            this.urls.add(element.textContent);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 0, 0),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Thread Gallery"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: "Download image",
            onPressed: () async {},
          ),
          IconButton(
            icon: Icon(Icons.content_copy),
            tooltip: "Copy image link",
            onPressed: () async {
              Clipboard.setData(
                  new ClipboardData(text: this.urls[_currentPage]));
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text('Image link copied to clipboard'),
              ));
            },
          ),
        ],
      ),
      body: PageView.builder(
        physics: !_isZooming
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        controller: PageController(
          initialPage: 0,
        ),
        onPageChanged: (int newIndex) {
          setState(() {
            _currentPage = newIndex;
          });
        },
        itemCount: this.urls.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: ZoomableWidget(
              minScale: 1.0,
              maxScale: 2.0,
              zoomSteps: 3,
              enableFling: true,
              autoCenter: true,
              multiFingersPan: false,
              bounceBackBoundary: true,
              onZoomChanged: (double zoom) {
                if (zoom > 1.0 && !_isZooming) {
                  setState(() {
                    _isZooming = true;
                  });
                }

                if (zoom == 1.0 && _isZooming) {
                  setState(() {
                    _isZooming = false;
                  });
                }
              },
              // default factor is 1.0, use 0.0 to disable boundary
              panLimit: 1.0,
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: this.urls[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
