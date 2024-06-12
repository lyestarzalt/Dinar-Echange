import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_title => 'Dinar Échange';

  @override
  String get currencies_app_bar_title => 'Devises';

  @override
  String get settings_app_bar_title => 'Paramètres';

  @override
  String get convert_app_bar_title => 'Convertir';

  @override
  String get select_currency_app_bar_title => 'Sélectionnez la devise';

  @override
  String get trends_app_bar_title => 'Tendances';

  @override
  String get close_button => 'Fermer';

  @override
  String get auto_button => 'Auto';

  @override
  String get dark_button => 'Sombre';

  @override
  String get light_button => 'Lumière';

  @override
  String get languages_button => 'Langues';

  @override
  String get chose_language_title => 'Choisissez la langue';

  @override
  String get theme_title => 'Thème';

  @override
  String get general_title => 'Général';

  @override
  String get rate_us_button => 'Évaluez l\'application';

  @override
  String get about_body => 'Merci d\'utiliser Dinar Echange, votre outil de suivi des devises. Nous fournissons des mises à jour opportunes et nous efforçons d\'offrir des fonctionnalités conviviales qui soutiennent vos besoins de suivi financier.';

  @override
  String get about_app_button => 'À propos de l\'application';

  @override
  String get one_month_button => '1M';

  @override
  String get six_months_button => '6M';

  @override
  String get one_year_button => '1Y';

  @override
  String get two_years_button => '2Y';

  @override
  String get add_selected_currencies_tooltip => 'Ajouter les devises sélectionnées';

  @override
  String get no_currencies_message => 'Pas de devises';

  @override
  String get retry_button => 'Réessayer';

  @override
  String get errormessage_message => 'Impossible de charger les données. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get search_hint => 'Recherche';

  @override
  String get add_currencies_tooltip => 'Ajouter des devises';

  @override
  String get switch_tooltip => 'Échanger des devises';

  @override
  String get use_centime_tooltip => 'Utiliser des centimes';

  @override
  String get reorder_tooltip => 'Réorganiser les articles';

  @override
  String get pull_refresh_tooltip => 'Récupérer les dernières infos sur les devises';

  @override
  String get centime_symbol => 'centimes';

  @override
  String get dzd_symbol => 'DZD';

  @override
  String get centime_explanation => 'En Algérie, le terme \'centime\' est utilisé de manière informelle pour représenter de plus petites quantités de monnaie. Par exemple, lorsque l\'on dit que quelque chose coûte 1 million, cela signifie en réalité 10 000 DZD';

  @override
  String get why_centime_title => 'L\'utilisation du \'Centime';

  @override
  String currency_buy_sell_explanation(Object buy_rate, Object currency_code, Object sell_rate) {
    return 'Le taux d\'achat est le prix auquel vous pouvez acheter une devise, tandis que le taux de vente est le prix auquel vous pouvez la vendre. Par exemple, si vous voulez acheter 1 $currency_code, cela vous coûtera $buy_rate DZD, et si vous voulez vendre 1 Euro, vous recevrez $sell_rate DZD.';
  }

  @override
  String get terms_title => 'Conditions générales';

  @override
  String get continue_button => 'Continuer';

  @override
  String get decline_button => 'Refuser';

  @override
  String get privacy_title => 'Politique de confidentialité';

  @override
  String get legal_title => 'Légal';

  @override
  String get licenses => 'Licences';

  @override
  String get error_title => 'Un problème est survenu';

  @override
  String get error_message => 'Oups ! Quelque chose n\'a pas fonctionné comme prévu. Veuillez réessayer.';

  @override
  String get latest_updates_on => 'Dernières mises à jour le';

  @override
  String get parallel_market => 'Marché Parallèle';

  @override
  String get official_market => 'Marché Officiel';

  @override
  String get retry => 'Réessayer';
}
