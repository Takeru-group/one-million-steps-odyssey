import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_million_steps_odyssey/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'theme/color_schemes.dart';
import 'pages/initial_page.dart';
import 'pages/main_page.dart';
import 'utils/app_init_service.dart';
import 'utils/background_fetch_service.dart';

final localeNotifier = ValueNotifier<Locale?>(null); 
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system); 

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessEvent event) async {
  String taskId = event.taskId;
  bool isTimeout = event.timeout;
  if (isTimeout) {
    print("⏰ [BackgroundFetch-Headless] タイムアウト: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('🚀 [BackgroundFetch-Headless] イベント受信: $taskId');
  await BackgroundFetchService.executeBackgroundStepCheck();
  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⭕️ Firestore のオフラインキャッシュを有効化
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await AppInitService.initSilentServices();
  await MobileAds.instance.initialize();
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['a591a333b1c965189bedc6e28ca522ff'],
    ),
  );

  await BackgroundFetchService.initialize();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, currentThemeMode, child) {
            return MaterialApp(
              title: 'One Million Steps Odyssey',
              debugShowCheckedModeBanner: false,
              
              themeMode: currentThemeMode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightColorScheme,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkColorScheme,
              ),

              locale: currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FirebaseUILocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ja'),
                Locale('en'),
              ],

              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasData) {
                    return const MainPage();
                  }
                  return const InitialPage();
                },
              ),
            );
          },
        );
      },
    );
  }
}