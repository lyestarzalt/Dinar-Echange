import 'package:flutter/material.dart';

enum ThemeOption { auto, dark, light }

class SettingsPage extends StatefulWidget {
  final Function(ThemeOption) onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeOption themeOption = ThemeOption.auto; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            actions: [],
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Settings'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        child: SegmentedButton<ThemeOption>(
                          segments: const <ButtonSegment<ThemeOption>>[
                            ButtonSegment<ThemeOption>(
                                value: ThemeOption.auto,
                                label: Text('Auto'),
                                icon: Icon(Icons.brightness_auto)),
                            ButtonSegment<ThemeOption>(
                                value: ThemeOption.dark,
                                label: Text('Dark'),
                                icon: Icon(Icons.nights_stay)),
                            ButtonSegment<ThemeOption>(
                                value: ThemeOption.light,
                                label: Text('Light'),
                                icon: Icon(Icons.wb_sunny)),
                          ],
                          selected: <ThemeOption>{themeOption},
                          onSelectionChanged: (Set<ThemeOption> newSelection) {
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
                  // Add more settings options here...
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateUsRow() {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.star)),
        const Text('Rate Us', style: TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _buildAboutUsRow(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showAboutDialog(context),
          icon: const Icon(Icons.info_outline),
        ),
        const Text('About Us', style: TextStyle(fontSize: 15)),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Dinar Watch'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Dinar Watch offers real-time insights into the Algerian Dinar, focusing on the vibrant exchange landscape of Port Said in Algiers. Our platform provides a comprehensive view of currency fluctuations, aiding you in staying informed.'),
                SizedBox(height: 16),
                Text(
                    'While we aim for accuracy, due to the dynamic nature of the currency market, some variances might occur. We appreciate your understanding and trust in our service.'),
                SizedBox(height: 16),
                Text(
                    'Dinar Watch is committed to accessibility and user convenience, which is why we are working towards offering multilingual support. This feature will allow users from various regions to use our app in their preferred language.'),
                SizedBox(height: 16),
                Text(
                    'For inquiries or feedback, please contact us at: contact@dinarwatch.com'),
                SizedBox(height: 16),
                Text('Thank you for choosing Dinar Watch.'),
              ],
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
