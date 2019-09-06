import 'package:json_annotation/json_annotation.dart';
import 'package:knocky/models/slateDocument.dart';
import 'dart:convert';

part 'thread.g.dart';

@JsonSerializable()
class Thread {
  final int id;
  final int currentPage;
  final int iconId;
  final bool locked;
  final bool pinned;
  final int subforumId;
  final String subforumName;
  String title;
  final int totalPosts;
  @JsonKey(nullable: true)
  final DateTime readThreadLastSeen;
  @JsonKey(nullable: true)
  final DateTime subscriptionLastSeen;
  final List<ThreadPost> posts;
  final List<ThreadUser> user;
  final int userId;
  @JsonKey(defaultValue: 0)
  final int isSubscribedTo;
  final String threadBackgroundType;
  final String threadBackgroundUrl;

  Thread({
    this.currentPage,
    this.iconId,
    this.readThreadLastSeen,
    this.id,
    this.locked,
    this.pinned,
    this.title,
    this.totalPosts,
    this.subforumId,
    this.subforumName,
    this.posts,
    this.user,
    this.subscriptionLastSeen,
    this.isSubscribedTo,
    this.userId,
    this.threadBackgroundType,
    this.threadBackgroundUrl
  });

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadToJson(this);
}

@JsonSerializable()
class ThreadUser {
  final int usergroup;
  final String username;

  ThreadUser({this.usergroup, this.username});

  factory ThreadUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadUserFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadUserToJson(this);
}

@JsonSerializable()
class ThreadPost {
  final int id;
  final DateTime createdAt;
  @JsonKey(fromJson: _contentFromJson, toJson: _contentToJson)
  final SlateObject content;
  final ThreadPostUser user;
  final List<ThreadPostRatings> ratings;
  @JsonKey(nullable: true)
  final List<ThreadPostBan> bans;

  ThreadPost(
      {this.id,
      this.content,
      this.user,
      this.ratings,
      this.createdAt,
      this.bans});

  factory ThreadPost.fromJson(Map<String, dynamic> json) =>
      _$ThreadPostFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadPostToJson(this);

  ThreadPost.clone(ThreadPost post): this(id: post.id, content: SlateObject.fromJson(post.content.toJson()), user: post.user, ratings: post.ratings, createdAt: post.createdAt, bans: post.bans);
}

SlateObject _contentFromJson(String jsonString) {
  return SlateObject.fromJson(json.decode(jsonString));
}

Map _contentToJson(SlateObject slateObject) => slateObject.toJson();

@JsonSerializable()
class ThreadPostBan {
  final String banBannedBy;
  final DateTime banCreatedAt;
  final DateTime banExpiresAt;
  final int banPostId;
  final String banReason;

  ThreadPostBan({
    this.banBannedBy,
    this.banCreatedAt,
    this.banExpiresAt,
    this.banPostId,
    this.banReason,
  });

  factory ThreadPostBan.fromJson(Map<String, dynamic> json) =>
      _$ThreadPostBanFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadPostBanToJson(this);
}

@JsonSerializable()
class ThreadPostRatings {
  @JsonKey(name: 'rating_id')
  final String ratingId;
  final String rating;
  final int count;
  final List<String> users;

  ThreadPostRatings({
    this.ratingId,
    this.rating,
    this.count,
    this.users,
  });

  factory ThreadPostRatings.fromJson(Map<String, dynamic> json) =>
      _$ThreadPostRatingsFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadPostRatingsToJson(this);
}

@JsonSerializable()
class ThreadPostUser {
  final int id;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final String backgroundUrl;
  final bool isBanned;
  final int usergroup;
  final String username;

  ThreadPostUser(
      {this.id,
      this.avatarUrl,
      this.backgroundUrl,
      this.isBanned,
      this.usergroup,
      this.username});

  factory ThreadPostUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadPostUserFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadPostUserToJson(this);
}
