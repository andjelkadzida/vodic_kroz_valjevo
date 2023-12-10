class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String scriptCode;
  final String countyCode;

  Language(this.id, this.flag, this.name, this.languageCode, this.scriptCode,
      this.countyCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, '🇷🇸', 'Srpski', 'sr', 'Latn', 'sr-RS'),
      Language(2, '🇷🇸', 'Српски', 'sr', 'Cyrl', 'sr-RS'),
      Language(3, '🇺🇸', 'English', 'en', 'en', 'en-US'),
      Language(4, '🇩🇪', 'Deutsch', 'de', 'de', 'de-DE')
    ];
  }
}
