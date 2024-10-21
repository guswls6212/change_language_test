import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale(Platform.localeName.split('_')[0]);
  AppLocalizations? _appLocalizations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocale());
  }

  _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode =
        prefs.getString('languageCode') ?? _locale.languageCode;
    setState(() {
      _locale = Locale(languageCode);
      _appLocalizations = lookupAppLocalizations(_locale);
    });
  }

  _setLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
      _appLocalizations = lookupAppLocalizations(_locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate, // 추가
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        const Locale('en', 'US'),
        const Locale('ja', 'JP'),
      ],
      home: FutureBuilder(
        future: Future.delayed(Duration.zero,
            () => _appLocalizations), // _appLocalizations가 초기화될 때까지 기다립니다.
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen(
              appLocalizations: snapshot.data as AppLocalizations,
              setLocale: _setLocale,
            );
          } else {
            return CircularProgressIndicator(); // 또는 다른 로딩 표시
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;

  HomeScreen({required this.appLocalizations, required this.setLocale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppLocalizations _appLocalizations;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _appLocalizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hello), // AppLocalizations 사용
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // widget.appLocalizations.hello,
              _appLocalizations.hello,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      appLocalizations: widget.appLocalizations,
                      setLocale: widget.setLocale,
                    ),
                  ),
                );
              },
              child: Text(widget.appLocalizations.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;

  SettingsScreen({required this.appLocalizations, required this.setLocale});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations _appLocalizations;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _appLocalizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appLocalizations.settings),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_appLocalizations
                .currentLanguage(_appLocalizations.localeName)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.setLocale(Locale('ko', 'KR'));
                setState(() {}); // setState 호출 추가
              },
              child: Text('한국어'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.setLocale(Locale('en', 'US'));
                setState(() {}); // setState 호출 추가
              },
              child: Text('English'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.setLocale(Locale('ja', 'JP'));
                setState(() {}); // setState 호출 추가
              },
              child: Text('日本語'),
            ),
          ],
        ),
      ),
    );
  }
}
