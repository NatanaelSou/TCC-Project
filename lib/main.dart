// lib/main.dart
//
// package
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

// Serviços e Estado
import 'services/api_service.dart';
import 'screens/home_page.dart';
import 'user_state.dart';

// Ponto de entrada
// inicialização do app
void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserState())],
      child: MyApp(),
    ),
  );
  ApiService.getUsers().then((res) => print(res));
}

// App Principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Flutter + Node.js + mySQL',
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 730, name: MOBILE),
          const Breakpoint(start: 731, end: 1130, name: TABLET),
        ],
      ),
      theme: ThemeData(
        drawerTheme: DrawerThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      home: HomePage(),
    );
  }
}
