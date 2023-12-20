import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinar_watch/pages/home_screen.dart'; // Update this import based on your project structure
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/models/currency.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Duration of the fade-in animation
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _loadDataAndNavigate();
        }
      });

    _animationController.forward();
  }
  Future<void> _loadDataAndNavigate() async {
    // Load theme preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    ThemeMode themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Fetch data from Firestore
    List<Currency> currencies = await MainRepository().getDailyCurrencies();

    // Navigate to MainScreen
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) =>
          MainScreen(initialThemeMode: themeMode, currencies: currencies),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        child: FadeTransition(
          opacity: _animation, // Apply the fade animation
          child: Image.asset('assets/logo.png'), // Your logo
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
