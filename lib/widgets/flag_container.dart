import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a country flag.
///
/// Prefers a bundled asset (assets/flags/{code}.png) when the URL is a
/// `flagcdn.com/w80/…` link — every currency in the app resolves to one
/// of those. Falls back to the network for any other URL (via
/// CachedNetworkImage), and to a quiet placeholder when the image is
/// missing or the network is unreachable.
///
/// The `DecorationImage` + `CachedNetworkImageProvider` combo the old
/// widget used had no error handler, so failures bubbled to Flutter's
/// global error handler on every rebuild — 30+ exceptions per reload
/// when offline. This widget catches them locally.
class FlagContainer extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const FlagContainer({
    super.key,
    this.imageUrl,
    this.width = 50.0,
    this.height = 40.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(1)),
  });

  static final _flagcdnPattern =
      RegExp(r'^https?://flagcdn\.com/w\d+/([a-z]{2,3})\.png$');

  /// If `url` points at `flagcdn.com/wNN/{code}.png`, return {code};
  /// null otherwise.
  static String? _codeFromUrl(String url) {
    final match = _flagcdnPattern.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _placeholder(context);

    if (url == 'DZD') {
      return Image.asset(
        'assets/dz_flag.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }

    final code = _codeFromUrl(url);
    if (code != null) {
      return Image.asset(
        'assets/flags/$code.png',
        fit: BoxFit.cover,
        // Fall back to the network if a code isn't bundled (rare — we
        // ship the full flagcdn catalogue minus one).
        errorBuilder: (_, _, _) => _networkImage(context, url),
      );
    }
    return _networkImage(context, url);
  }

  Widget _networkImage(BuildContext context, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 120),
      placeholder: (_, _) => _placeholder(context),
      errorWidget: (_, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(color: scheme.surfaceContainerHighest);
  }
}
