import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/subscriptionController.dart';
import 'package:knocky/dialogs/confirmDialog.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/jumpToPageDialog.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class SubscriptionListItem extends ThreadListItem {
  final ThreadAlert threadAlert;
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  SubscriptionListItem({@required this.threadAlert})
      : super(threadDetails: threadAlert);

  @override
  List getTagWidgets(BuildContext context) {
    return [
      if (threadAlert.unreadPostCount > 0)
        unreadPostsButton(context, threadAlert.unreadPostCount)
    ];
  }

  @override
  List<WidgetSpan> getDetailIcons(BuildContext context) {
    return [...lockedIcon()];
  }

  void showJumpDialog() async {
    int page = await Get.dialog(
      JumpToPageDialog(
        minValue: 1,
        maxValue: PostsPerPage.totalPagesFromPosts(threadDetails.postCount),
        value: 1,
      ),
    );

    if (page != null)
      Get.to(() => ThreadScreen(id: threadDetails.id, page: page));
  }

  Widget longPressBottomSheetContent() {
    return Container(
      color: Get.theme.bottomAppBarColor,
      child: Wrap(
        children: <Widget>[
          ListTile(
              leading: FaIcon(FontAwesomeIcons.bellSlash),
              title: Text('Unsubscribe'),
              onTap: () async {
                Get.back();

                bool confirmResult = await Get.dialog(ConfirmDialog(
                  content: "Do you want to unsubscribe?",
                ));

                if (!confirmResult) return;

                SnackbarController snackbarController = KnockySnackbar.normal(
                  "Unsubscribing...",
                  "Unsubscribing thread...",
                  isDismissible: false,
                  showProgressIndicator: true,
                );

                await KnockoutAPI().deleteThreadAlert(threadDetails.id);
                snackbarController.close();
                subscriptionController.fetch();

                KnockySnackbar.success("Unsubscribed thread");
              }),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.redo),
            title: Text('Go to page'),
            onTap: () {
              Get.back();
              showJumpDialog();
            },
          ),
        ],
      ),
    );
  }

  @override
  void onLongPressItem(BuildContext context) {
    Get.bottomSheet(
      longPressBottomSheetContent(),
      enterBottomSheetDuration: Duration(milliseconds: 150),
      exitBottomSheetDuration: Duration(milliseconds: 150),
    );
  }
}
