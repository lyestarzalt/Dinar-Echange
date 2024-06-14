import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_title => 'دينار إيشانج';

  @override
  String get currencies_app_bar_title => 'العملات';

  @override
  String get settings_app_bar_title => 'إعدادات';

  @override
  String get convert_app_bar_title => 'تحويل';

  @override
  String get select_currency_app_bar_title => 'اختر العملة';

  @override
  String get trends_app_bar_title => 'اتجاهات';

  @override
  String get close_button => 'إغلاق';

  @override
  String get auto_button => 'تلقائي';

  @override
  String get dark_button => 'مظلم';

  @override
  String get light_button => 'مضيء';

  @override
  String get languages_button => 'اللغات';

  @override
  String get chose_language_title => 'اختر اللغة';

  @override
  String get theme_title => 'المظهر';

  @override
  String get general_title => 'عام';

  @override
  String get rate_us_button => 'قيّم التطبيق';

  @override
  String get about_body => 'شكرًا لاستخدامك Dinar Echange، أداتك لمراقبة العملات. نحن نقدم تحديثات في الوقت المناسب ونسعى جاهدًا لتقديم ميزات سهلة الاستخدام تدعم احتياجاتك المالية.';

  @override
  String get about_app_button => 'حول التطبيق';

  @override
  String get one_month_button => '1ش';

  @override
  String get six_months_button => '6ش';

  @override
  String get one_year_button => '1س';

  @override
  String get two_years_button => '2س';

  @override
  String get add_selected_currencies_tooltip => 'أضف العملات المختارة';

  @override
  String get no_currencies_message => 'لا توجد عملات';

  @override
  String get errormessage_message => 'تعذر تحميل البيانات. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';

  @override
  String get search_hint => 'بحث';

  @override
  String get add_currencies_tooltip => 'إضافة العملات';

  @override
  String get switch_tooltip => 'تبديل العملات';

  @override
  String get use_centime_tooltip => 'استخدام السنتيم';

  @override
  String get reorder_tooltip => 'إعادة ترتيب العناصر';

  @override
  String get pull_refresh_tooltip => 'جلب أحدث معلومات العملة';

  @override
  String get centime_symbol => 'سنتيم';

  @override
  String get dzd_symbol => 'دج';

  @override
  String get centime_explanation => 'في الجزائر، يُستخدم مصطلح \'سنتيم\' غير الرسمي لتمثيل مبالغ أقل من العملة. على سبيل المثال، عندما يُقال أن شيئًا ما يكلف مليون، فإن ذلك يعني أنه بقيمة 10,000 دج.';

  @override
  String get why_centime_title => 'استخدام \'السنتيم';

  @override
  String currency_buy_sell_explanation(Object buy_rate, Object currency_code, Object sell_rate) {
    return 'سعر الشراء هو السعر الذي يمكنك به شراء عملة، بينما سعر البيع هو السعر الذي يمكنك به بيعها. على سبيل المثال، إذا أردت شراء 1 $currency_code، فسيكلفك ذلك $buy_rate دج، وإذا أردت بيع 1 $currency_code، ستتلقى $sell_rate دج.';
  }

  @override
  String get terms_title => 'شروط وأحكام';

  @override
  String get continue_button => 'استمر';

  @override
  String get decline_button => 'رفض';

  @override
  String get privacy_title => 'سياسة الخصوصية';

  @override
  String get legal_title => 'قانوني';

  @override
  String get licenses => 'رخص';

  @override
  String get latest_updates_on => 'آخر التحديثات في';

  @override
  String get parallel_market => 'السوق الموازي';

  @override
  String get official_market => 'السوق الرسمي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get error_title => 'حدث خطأ ما';

  @override
  String get error_message => 'أوه! لم تسر الأمور كما كان مخططًا لها. يرجى المحاولة مرة أخرى.';

  @override
  String get buy => 'شراء';

  @override
  String get sell => 'بيع';
}
