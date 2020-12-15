import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:knocky_edge/helpers/hiveHelper.dart';
import 'package:knocky_edge/screens/forum.dart';
import 'package:knocky_edge/state/appState.dart';
import 'package:knocky_edge/state/authentication.dart';
import 'package:knocky_edge/state/subscriptions.dart';
import 'package:knocky_edge/themes/DarkTheme.dart';
import 'package:scoped_model/scoped_model.dart';

Future<void> main() async {
  Widget rv;

  // Init dotenv
  await DotEnv().load('assets/.env');

  // Init hive
  await AppHiveBox.initHive();
  Box box = await AppHiveBox.getBox();

  // Setup default values
  if (await box.get('showNSFWThreads') == null) {
    await box.put('showNSFWThreads', false);
  }

  if (await box.get('useInlineYoutubePlayer') == null) {
    await box.put('useInlineYoutubePlayer', true);
  }

  if (await box.get('env') == null) {
    await box.put('env', 'knockout');
  }

  rv = new DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => darkTheme(),
      themedWidgetBuilder: (context, theme) {
        if (theme.brightness == Brightness.dark) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.grey[900],
              systemNavigationBarIconBrightness: Brightness.light));
        }

        return MaterialApp(title: 'Knocky', theme: theme, home: ForumScreen());
      });

  rv =
      ScopedModel<AuthenticationModel>(model: AuthenticationModel(), child: rv);
  rv = ScopedModel<SubscriptionModel>(model: SubscriptionModel(), child: rv);
  rv = ScopedModel<AppStateModel>(model: AppStateModel(), child: rv);

  runApp(rv);
}
