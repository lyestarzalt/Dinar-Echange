import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  final void Function(bool) onUserDecision;

  const TermsAndConditionsScreen({Key? key, required this.onUserDecision}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.terms_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  buildSection(context, localizations.terms_introduction_title, localizations.terms_introduction_content),
                  buildSection(context, localizations.terms_ip_rights_title, localizations.terms_ip_rights_content),
                  buildSection(context, localizations.terms_use_title, localizations.terms_use_content),
                  buildSection(context, localizations.terms_liability_title, localizations.terms_liability_content),
                  buildSection(context, localizations.terms_compliance_title, localizations.terms_compliance_content),
                  buildSection(context, localizations.terms_acceptance_title, localizations.terms_acceptance_content),
                  buildSection(context, localizations.terms_contact_title, localizations.terms_contact_content),
                  buildSection(context, localizations.terms_modifications_title, localizations.terms_modifications_content),
                  Text(localizations.terms_last_updated.replaceFirst('{year}', DateTime.now().year.toString())),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ElevatedButton(
                      onPressed: () => onUserDecision(true),
                      child: Text(localizations.continue_button),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ElevatedButton(
                      onPressed: () => onUserDecision(false),
                      style: ElevatedButton.styleFrom(
                      ),
                      child: Text(localizations.decline_button),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(title, style: Theme.of(context).textTheme.headlineMedium),
       const SizedBox(height: 8),
        Text(content),
        const SizedBox(height: 16),
      ],
    );
  }
}
