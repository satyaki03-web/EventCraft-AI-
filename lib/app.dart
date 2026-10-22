import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/checklist_controller.dart';
import 'state/chat_controller.dart';
import 'state/plan_controller.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/input_screen.dart';

/// Root MaterialApp widget configuring themes, providers, and routes.
class EventCraftApp extends StatelessWidget {
  const EventCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlanController()..init()),
        ChangeNotifierProvider(create: (_) => ChecklistController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: MaterialApp(
        title: 'EventCraft AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFDFBF7),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF782F40),
            primary: const Color(0xFF782F40),
            secondary: const Color(0xFFE85942),
            surface: const Color(0xFFFFFFFF),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF782F40),
            foregroundColor: Color(0xFFFFFFFF),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E0E1)),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.light,
        initialRoute: '/input',
        routes: {
          '/input': (context) => const InputScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
