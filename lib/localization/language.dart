class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String scriptCode;

  Language(this.id, this.flag, this.name, this.languageCode, this.scriptCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, '🇷🇸', 'Srpski', 'sr', 'Latn'),
      Language(2, '🇷🇸', 'Српски', 'sr', 'Cyrl'),
      Language(3, '🇺🇸', 'English', 'en', 'en'),
      Language(4, '🇩🇪', 'Deutsch', 'de', 'de')
    ];
  }
}
