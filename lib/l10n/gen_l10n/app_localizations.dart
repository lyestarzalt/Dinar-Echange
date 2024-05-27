import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)!`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// The app's name as shown in system contexts like the home screen or app switcher.
  ///
  /// In en, this message translates to:
  /// **'Dinar Echange'**
  String get app_title;

  /// A list of all available currencies in the app.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies_app_bar_title;

  /// Section to customize app preferences and configurations.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_app_bar_title;

  /// Option to convert values between dzd and currencies.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert_app_bar_title;

  /// Option for users to choose their preferred currency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get select_currency_app_bar_title;

  /// Page displaying the latest trends and movements in different currencies.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends_app_bar_title;

  /// Button or option to close the app or a specific section within the app.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_button;

  /// Option for automatic settings or operations within the app.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto_button;

  /// Option to enable a dark color scheme for the app's interface.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark_button;

  /// Option to enable a light color scheme for the app's interface.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light_button;

  /// List of available languages
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages_button;

  /// Option to select a language
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chose_language_title;

  /// Option for visual theme customization.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme_title;

  /// Overall settings or information for the app.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general_title;

  /// Invitation to rate the app.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rate_us_button;

  /// App's detailed description
  ///
  /// In en, this message translates to:
  /// **'Thank you for using Dinar Echange, your tool for currency monitoring. We provide timely updates and strive to offer user-friendly features that support your financial tracking needs.'**
  String get about_body;

  /// About the App
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get about_app_button;

  /// Short time filter for viewing currency data over the past month.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get one_month_button;

  /// Short time filter for viewing currency data over the past six months.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get six_months_button;

  /// Short time filter for viewing currency data over the past year.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get one_year_button;

  /// Short time filter for viewing currency data over the past two years.
  ///
  /// In en, this message translates to:
  /// **'2Y'**
  String get two_years_button;

  /// Option to add selected currencies to the list|
  ///
  /// In en, this message translates to:
  /// **'Add Selected Currencies'**
  String get add_selected_currencies_tooltip;

  /// Title for an error message dialog.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong.'**
  String get error_message_title;

  /// Error message indicating an issue in retrieving currency data.
  ///
  /// In en, this message translates to:
  /// **'Error fetching currencies'**
  String get error_fetching_currencies_message;

  /// Message for no currency data.
  ///
  /// In en, this message translates to:
  /// **'No currencies'**
  String get no_currencies_message;

  /// Button to attempt a previous action again (e.g., refreshing data or reconnecting).
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry_button;

  /// Detailed text explaining the error.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the data. Please check your connection and try again.'**
  String get errormessage_message;

  /// Option to search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_hint;

  /// Option to add currencies
  ///
  /// In en, this message translates to:
  /// **'Add Currencies'**
  String get add_currencies_tooltip;

  /// Option to switch from buy to sell
  ///
  /// In en, this message translates to:
  /// **'Swap currencies'**
  String get switch_tooltip;

  /// Option to switch to centime as counting method
  ///
  /// In en, this message translates to:
  /// **'Use centimes'**
  String get use_centime_tooltip;

  /// Option to reorder the items in the list
  ///
  /// In en, this message translates to:
  /// **'Reorder items'**
  String get reorder_tooltip;

  /// Option to fetch latest currencies information
  ///
  /// In en, this message translates to:
  /// **'Fetch latest currency info'**
  String get pull_refresh_tooltip;

  /// Algerian centime
  ///
  /// In en, this message translates to:
  /// **'centimes'**
  String get centime_symbol;

  /// Algerian dinar
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get dzd_symbol;

  /// Explanation of the term 'centime' in Algeria
  ///
  /// In en, this message translates to:
  /// **'In Algerian society, \'centime\' is informally used to simplify discussions about money. For example, if you hear something costs 1 million, it means it\'s 10,000 DZD'**
  String get centime_explanation;

  /// Title for centime use
  ///
  /// In en, this message translates to:
  /// **'The Usage of \'Centime'**
  String get why_centime_title;

  /// Detailed explanation of the difference between buy and sell
  ///
  /// In en, this message translates to:
  /// **'The buy rate is the price at which you can purchase a currency, while the sell rate is what you can sell it for. For example, if you want to buy 1 Euro, it costs 235.00 in your currency, and if you want to sell 1 Euro, you\'ll receive 237.00'**
  String get currency_buy_sell_explanation;

  /// Brief tooltip for currency buy and sell values
  ///
  /// In en, this message translates to:
  /// **'Explains the buying and selling rates of currencies.'**
  String get currency_buy_sell_tooltip;

  /// Title for the terms and conditions page
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_title;

  /// Button to proceed or accept conditions
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button;

  /// Button to reject conditions or navigate back
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline_button;

  /// Title for the privacy policy page
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_title;

  /// Title for the legal section in the settings
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal_title;

  /// Word for licenses
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Latest updates on
  ///
  /// In en, this message translates to:
  /// **'Latest updates on'**
  String get latest_updates_on;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
