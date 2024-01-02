import 'package:flutter/material.dart';

import 'package:dinar_watch/shared/enums.dart';
import 'package:dinar_watch/widgets/error_message.dart';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeOption) onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeOption themeOption = ThemeOption.auto; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Theme', style: TextStyle(fontSize: 15)),
              const Divider(thickness: 2),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    child: SegmentedButton(
                      segments: const <ButtonSegment>[
                        ButtonSegment(
                            value: ThemeOption.auto,
                            label: Text('Auto'),
                            icon: Icon(Icons.brightness_auto)),
                        ButtonSegment(
                            value: ThemeOption.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.nights_stay)),
                        ButtonSegment(
                            value: ThemeOption.light,
                            label: Text('Light'),
                            icon: Icon(Icons.wb_sunny)),
                      ],
                      selected: {themeOption},
                      onSelectionChanged: (Set newSelection) {
                        setState(() {
                          themeOption = newSelection.first;
                          widget.onThemeChanged(themeOption);
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('General', style: TextStyle(fontSize: 15)),
              const Divider(thickness: 2),
              _buildRateUsRow(),
              _buildAboutUsRow(context),
              const ErrorMessage() // Testing...
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateUsRow() {
    return InkWell(
      onTap: () {},
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 24.0),
            SizedBox(width: 10),
            Text('Rate Us', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutUsRow(BuildContext context) {
    return InkWell(
      onTap: () => _showAboutDialog(context),
      child: const Padding(
        padding: EdgeInsets.all(8.0), // Adjust padding for better spacing
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 24.0), // Adjust icon size as needed
            SizedBox(width: 10), // Adjust width for spacing
            Text('About Us', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Dinar Watch'),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                      text:
                          'Dinar Watch offers real-time insights into the Algerian Dinar, focusing on the vibrant exchange landscape of Port Said in Algiers. Our platform provides a comprehensive view of currency fluctuations, aiding you in staying informed.\n\n'),
                  TextSpan(
                      text:
                          'While we aim for accuracy, due to the dynamic nature of the currency market, some variances might occur. We appreciate your understanding and trust in our service.\n\n'),
                  TextSpan(
                      text:
                          'Dinar Watch is committed to accessibility and user convenience, which is why we are working towards offering multilingual support. This feature will allow users from various regions to use our app in their preferred language.\n\n'),
                  TextSpan(
                      text:
                          'For inquiries or feedback, please contact us at: contact@dinarwatch.com\n\n'),
                  TextSpan(text: 'Thank you for choosing Dinar Watch.'),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
