class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String scriptCode;

  Language(this.id, this.flag, this.name, this.languageCode, this.scriptCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, '๐ท๐ธ', 'Srpski', 'sr', 'Latn'),
      Language(2, '๐ท๐ธ', 'ะกัะฟัะบะธ', 'sr', 'Cyrl'),
      Language(3, '๐บ๐ธ', 'English', 'en', 'en'),
      Language(4, '๐ฉ๐ช', 'Deutsch', 'de', 'de')
    ];
  }
}
