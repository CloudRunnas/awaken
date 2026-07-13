/*-------------------------------------------------------------------------------------------------------
* Copyright © 2020, Shaan Faydh
*  
* The Phoenix Project is free software licensed under GPL v3.0.
* You can redistribute and/or modify it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
* 
* The Phoenix Project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
* See the GNU General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with The Phoenix Project.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------------------------*/

import 'package:phoenix/src/beginning/utilities/audio_handlers/background.dart';
import 'package:phoenix/src/beginning/utilities/constants.dart';
import 'package:phoenix/src/beginning/pages/settings/settings_pages/privacy.dart';
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/utilities/init.dart';
import 'package:phoenix/src/beginning/utilities/provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phoenix/firebase_options.dart';
import 'src/beginning/begin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await cacheImages();
  await dataInit();
  await fetchSongs();
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerTask(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: "Phoenix Music",
      androidNotificationIcon: "drawable/phoenix_awaken",
      androidNotificationChannelDescription: "Phoenix Music Notification",
    ),
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MaterialApp(
      theme: themeOfApp,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<Leprovider>(create: (_) => Leprovider()),
          ChangeNotifierProvider<MrMan>(
            create: (_) => MrMan(),
          ),
          ChangeNotifierProvider<Seek>(create: (_) => Seek()),
        ],
        child: permissionGiven ? const Begin() : const Privacy(),
      ),
    ),
  );
}
