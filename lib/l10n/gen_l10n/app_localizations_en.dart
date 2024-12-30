import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Dinar Echange';

  @override
  String get currencies_app_bar_title => 'Currencies';

  @override
  String get settings_app_bar_title => 'Settings';

  @override
  String get convert_app_bar_title => 'Convert';

  @override
  String get select_currency_app_bar_title => 'Select Currency';

  @override
  String get trends_app_bar_title => 'Trends';

  @override
  String get close_button => 'Close';

  @override
  String get auto_button => 'Auto';

  @override
  String get dark_button => 'Dark';

  @override
  String get light_button => 'Light';

  @override
  String get languages_button => 'Languages';

  @override
  String get chose_language_title => 'Choose Language';

  @override
  String get theme_title => 'Theme';

  @override
  String get general_title => 'General';

  @override
  String get rate_us_button => 'Rate the App';

  @override
  String get about_body => 'Thank you for choosing Dinar Echange. This app shares updates and features to help you track currency changes.';

  @override
  String get about_app_button => 'About the App';

  @override
  String get one_month_button => '1M';

  @override
  String get six_months_button => '6M';

  @override
  String get one_year_button => '1Y';

  @override
  String get two_years_button => '2Y';

  @override
  String get add_selected_currencies_tooltip => 'Add Selected Currencies';

  @override
  String get no_currencies_message => 'No currencies';

  @override
  String get errormessage_message => 'Unable to load the data. Check your connection and try again.';

  @override
  String get search_hint => 'Search';

  @override
  String get add_currencies_tooltip => 'Add Currencies';

  @override
  String get switch_tooltip => 'Swap currencies';

  @override
  String get use_centime_tooltip => 'Use centimes';

  @override
  String get reorder_tooltip => 'Reorder items';

  @override
  String get pull_refresh_tooltip => 'Fetch latest currency info';

  @override
  String get centime_symbol => 'centimes';

  @override
  String get dzd_symbol => 'DZD';

  @override
  String get centime_explanation => 'In Algeria, \'centime\' is used informally for all amounts, whether large or small. For example, if you hear something costs 5 million, that usually refers to 50,000 DZD.';

  @override
  String get why_centime_title => 'The Usage of \'Centime';

  @override
  String currency_buy_sell_explanation(Object buy_rate, Object currency_code, Object sell_rate) {
    return 'The buy rate is the price at which you can purchase a currency, while the sell rate is what you can sell it for. For example, to buy 1 $currency_code, it costs $buy_rate DZD, and to sell 1 $currency_code, you\'ll receive $sell_rate DZD.';
  }

  @override
  String get terms_title => 'Terms and Conditions';

  @override
  String get continue_button => 'Continue';

  @override
  String get decline_button => 'Decline';

  @override
  String get privacy_title => 'Privacy Policy';

  @override
  String get legal_title => 'Legal';

  @override
  String get licenses => 'Licenses';

  @override
  String get latest_updates_on => 'Latest updates on';

  @override
  String get parallel_market => 'Alternative Market';

  @override
  String get official_market => 'Main Market';

  @override
  String get retry => 'Retry';

  @override
  String get error_title => 'Something Went Wrong';

  @override
  String get error_message => 'Oops! Something didn\'t go as planned. Please try again.';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get confirm_delete_title => 'Confirm Deletion';

  @override
  String get confirm_delete_message => 'Are you sure you want to delete this currency?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';
}
