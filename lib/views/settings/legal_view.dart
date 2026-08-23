import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_html/flutter_html.dart';

import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/services/http_service.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:dinar_echange/utils/logging.dart';

class LegalDocumentsScreen extends StatefulWidget {
  final LegalDocumentType documentType;

  const LegalDocumentsScreen({super.key, required this.documentType});

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  String? _html;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final path = widget.documentType == LegalDocumentType.terms
        ? 'terms_and_conditions.html'
        : 'privacy_policy.html';
    String content;
    try {
      content = await HttpService().getLegalHtml(path);
    } catch (e, stack) {
      AppLogger.logError('Failed to fetch $path', error: e, stackTrace: stack);
      content = await rootBundle.loadString('assets/$path');
    }
    // Widget may have been popped while the load was in flight.
    if (!mounted) return;
    setState(() {
      _html = content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = widget.documentType == LegalDocumentType.terms
        ? l10n.terms_title
        : l10n.privacy_title;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Html(
                    data: _html ?? '',
                    style: {
                      'html': Style(
                        backgroundColor: theme.scaffoldBackgroundColor,
                        color: theme.textTheme.bodyLarge?.color ??
                            theme.colorScheme.onSurface,
                      ),
                      'body': Style(
                        color: theme.textTheme.bodyLarge?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
