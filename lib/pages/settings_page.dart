import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Placeholder for currency selection dropdown
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0), // Add horizontal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const Text(
              'Dark mode',
              style: TextStyle(fontSize: 15),
            ),
            const Divider(
              thickness: 2,
            ),
            Switch(
              value: isDarkMode,
              onChanged: (val) {
                onThemeChanged(val);
              },
            ),
            const SizedBox(
              height: 50,
            ),
            // Additional settings UI...
            const Text('General', style: TextStyle(fontSize: 15)),
            const Divider(thickness: 2),
            // Add your additional settings widgets here...
            _buildRateUsRow(),
            _buildAboutUsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRateUsRow() {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions)),
        const Text(
          'Rate us',
        ),
      ],
    );
  }

  Widget _buildAboutUsRow(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationIcon: const FlutterLogo(),
                applicationName: 'Exchange Rate',
                applicationVersion: '0.0.1',
                applicationLegalese: '©2022 Your Company Name',
                children: const <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text('Additional information here'))
                ],
              );
            },
            icon: const Icon(Icons.info)),
        const Text(
          'About us',
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
