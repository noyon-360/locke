import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/pin_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LockeApp());
}

class LockeApp extends StatelessWidget {
  const LockeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locke',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Lk.bg,
        colorScheme: const ColorScheme.dark(
          surface: Lk.surface,
          primary: Lk.accent,
          onPrimary: Lk.accentInk,
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Lk.accent,
          selectionColor: Lk.accentSoft,
          selectionHandleColor: Lk.accent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
      ),
      home: const PinSetupScreen(),
    );
  }
}
