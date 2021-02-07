import 'package:flutter/material.dart';
import 'package:knocky_edge/models/thread.dart';
import 'package:knocky_edge/helpers/icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky_edge/widget/Thread/PostHeader.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky_edge/state/authentication.dart';
import 'package:knocky_edge/widget/Thread/RatePostContent.dart';
import 'package:knocky_edge/widget/Thread/ViewUsersOfRatingsContent.dart';
import 'package:knocky_edge/widget/Thread/PostBan.dart';
import 'package:knocky_edge/widget/Thread/PostContent.dart';

class ThreadPostItem extends StatefulWidget {
  final ThreadPost postDetails;
  final GlobalKey scaffoldKey;
  final Function onPostRated;
  final Function onPressReply;
  final Function onLongPressReply;
  final bool isOnReplyList;
  final Function onTapEditPost;
  final Thread thread;
  final bool useScroll;
  final int currentPage;

  ThreadPostItem(
      {this.postDetails,
      this.scaffoldKey,
      this.onPostRated,
      this.onPressReply,
      this.isOnReplyList = false,
      this.onLongPressReply,
      this.onTapEditPost,
      this.thread,
      this.currentPage,
      this.useScroll = false});

  @override
  _ThreadPostItemState createState() => _ThreadPostItemState();
}

class _ThreadPostItemState extends State<ThreadPostItem> {
  bool textSelectable = false;

  Widget buildRatings(List<ThreadPostRatings> ratings) {
    List<Widget> items = List();

    if (ratings != null) {
      ratings.sort((a, b) => b.count.compareTo(a.count));
      ratings.forEach((rating) {
        RatingistItem icon;
        try {
          icon = ratingsIconList.firstWhere((icon) => icon.id == rating.rating);
        } catch (e) {
          return;
        }
        if (icon != null) {
          items.add(
            Container(
              width: 22,
              margin: EdgeInsets.only(right: 5.0),
              child: Column(children: <Widget>[
                CachedNetworkImage(
                  imageUrl: icon.url,
                ),
                Text(rating.count.toString())
              ]),
            ),
          );
        } else {
          items.add(
            Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Column(
                  children: <Widget>[Text('?'), Text(rating.count.toString())]),
            ),
          );
        }
      });
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: items),
    );
  }

  void onPressSpoiler(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new SelectableText(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onPressRatePost(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (BuildContext bContext) {
          return RatePostContent(
            buildContext: context,
            postId: widget.postDetails.id,
            onPostRated: widget.onPostRated,
            thread: widget.thread,
          );
        });
  }

  void onPressViewRatings(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (BuildContext bContext) {
          return ViewUsersOfRatingsContent(
            buildContext: context,
            ratings: widget.postDetails.ratings,
          );
        });
  }

  List<Widget> otherUserButton(BuildContext context) {
    return [
      FlatButton(
        child: Text('Rate'),
        onPressed: () => onPressRatePost(context),
      ),
      GestureDetector(
        onLongPress: () => widget.onLongPressReply(widget.postDetails),
        child: FlatButton(
          child: Text(!this.widget.isOnReplyList ? 'Reply' : 'Unreply'),
          onPressed: () => widget.onPressReply(widget.postDetails),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        ),
      ),
    ];
  }

  List<Widget> ownPostButtons(BuildContext context) {
    return [
      FlatButton(
        child: Text('Edit'),
        onPressed: () {
          if (widget.postDetails.content is String) {
            widget.onTapEditPost(widget.postDetails);
          } else {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'This post was made with the old Slate Editor, and the app does not support that anymore.'),
              ),
            );
          }
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .isLoggedIn;
    final int ownUserId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .userId;

    // Handler post footer stuff
    List<Widget> footer = List();

    footer.add(
      Expanded(
        child: GestureDetector(
          onTap: widget.postDetails.ratings != null
              ? () => onPressViewRatings(context)
              : null,
          child: Container(
            padding: EdgeInsets.all(0),
            child: buildRatings(widget.postDetails.ratings),
          ),
        ),
      ),
    );

    if (isLoggedIn && widget.postDetails.user.id != ownUserId)
      footer.addAll(otherUserButton(context));

    if (isLoggedIn && widget.postDetails.user.id == ownUserId)
      footer.addAll(ownPostButtons(context));

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: 64.0, top: 10.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PostHeader(
                        userGroup: widget.postDetails.user.usergroup,
                        userId: widget.postDetails.user.id,
                        username: widget.postDetails.user.username,
                        avatarUrl: widget.postDetails.user.avatarUrl,
                        backgroundUrl: widget.postDetails.user.backgroundUrl,
                        threadPost: widget.postDetails,
                        context: context,
                        thread: widget.thread,
                        currentPage: widget.currentPage,
                        textSelectable: this.textSelectable,
                        onTextSelectableChanged: (newVal) {
                          setState(() {
                            textSelectable = newVal;
                          });
                        }),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: SingleChildScrollView(
                  child: PostContent(
                      postDetails: widget.postDetails,
                      textSelectable: this.textSelectable,
                      content: widget.postDetails.content,
                      onTapSpoiler: (text) {
                        onPressSpoiler(context, text);
                      },
                      scaffoldKey: this.widget.scaffoldKey),
                ),
              ),
            ),
            Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color.fromRGBO(45, 45, 48, 1)
                  : Color.fromRGBO(230, 230, 230, 1),
              padding:
                  EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.postDetails.bans != null)
                    Column(
                      children: widget.postDetails.bans
                          .map(
                            (ban) => PostBan(
                              ban: ban,
                            ),
                          )
                          .toList(),
                    ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: footer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
