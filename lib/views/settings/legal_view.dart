import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:dinar_echange/providers/app_provider.dart';

class LegalDocumentsScreen extends StatelessWidget {
  final LegalDocumentType documentType;

  const LegalDocumentsScreen({
    super.key,
    required this.documentType,
  });

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
        child: ChangeNotifierProvider<AppProvider>(
          create: (_) => AppProvider()..loadContent(documentType),
          child: Consumer<AppProvider>(
            builder: (context, legalProvider, child) {
              return Consumer<AppProvider>(
                builder: (context, appProvider, child) {
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
