import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/terms_provider.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  final void Function(bool) onUserDecision;
 

  const TermsAndConditionsScreen({
    Key? key,
    required this.onUserDecision,
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.terms_title),
      ),
      body: ChangeNotifierProvider<TermsProvider>(
        create: (_) => TermsProvider(),
        child: Consumer<TermsProvider>(
          builder: (context, termsProvider, child) {
            if (termsProvider.isLoading) {
              return const Center(child: LinearProgressIndicator());
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Html(data: termsProvider.htmlContent
                        , onLinkTap:(url, attributes, element) => print(url),
                        
                        
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: TextButton(
                              onPressed: () => onUserDecision(true),
                              style: TextButton.styleFrom(
                                  // Add button styling here
                                  ),
                              child: Text(localizations.continue_button),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: TextButton(
                              onPressed: () => onUserDecision(false),
                              style: TextButton.styleFrom(
                                  // Add button styling here
                                  ),
                              child: Text(localizations.decline_button),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
