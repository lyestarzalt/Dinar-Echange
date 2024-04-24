import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/legal_provider.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:dinar_echange/providers/theme_provider.dart';

class LegalDocumentsScreen extends StatelessWidget {
  final LegalDocumentType documentType;

  const LegalDocumentsScreen({
    Key? key,
    required this.documentType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    String title = documentType == LegalDocumentType.terms
        ? localizations.terms_title
        : localizations.privacy_title;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Directionality(
              textDirection: TextDirection.ltr,

        child: ChangeNotifierProvider<LegalProvider>(
          create: (_) => LegalProvider()..loadContent(documentType),
          child: Consumer<LegalProvider>(
            builder: (context, legalProvider, child) {
              return Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
  
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: legalProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Html(
                              data: legalProvider.htmlContent,
                              style: {
                                "html": Style(
                                                         backgroundColor:
                                      theme.scaffoldBackgroundColor,

                                  color: theme.textTheme.bodyLarge!.color ??
                                      Colors.black,
                                ),
                                "body": Style(
                                  color: theme.textTheme.bodyLarge?.color ??
                                      Colors.black,
                                ),
                               
                              },
                            ),
                          ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
