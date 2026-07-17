import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const SoilAiApp());
}

class SoilAiApp extends StatelessWidget {
  const SoilAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soil AI - Geotechnical Lab Suite',
      debugShowCheckedModeBanner: false,
      
      // Setup premium dark slate and engineering blue theme
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1326), // Google Stitch Surface Dim
        primaryColor: const Color(0xFFADC6FF), // Google Stitch Primary
        
        // Color schema details
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFADC6FF), // primary blue-grey tint
          secondary: Color(0xFF4CD7F6), // secondary cyan tint
          tertiary: Color(0xFFFFB786),  // tertiary orange/peach tint
          surface: Color(0xFF171F33),   // surface-container
          onSurface: Color(0xFFDAE2FD),
          error: Color(0xFFEF4444),
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171F33),
          foregroundColor: Color(0xFFDAE2FD),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDAE2FD),
          ),
        ),

        // Card Theme
        cardTheme: const CardTheme(
          color: Color(0xFF171F33),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),

        // Form Fields Styling
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFFC2C6D6)),
          suffixStyle: TextStyle(color: Color(0xFF8C909F)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF424754)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFADC6FF), width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEF4444)),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),

        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      
      home: const DashboardScreen(),
    );
  }
}
