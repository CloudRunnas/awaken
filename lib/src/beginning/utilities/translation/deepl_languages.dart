class DeeplLanguage {
  final String code;
  final String name;
  final String flag;

  const DeeplLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });
}

const kDeeplTargetLanguages = <DeeplLanguage>[
  DeeplLanguage(code: 'DE', name: 'Deutsch', flag: '🇩🇪'),
  DeeplLanguage(code: 'EN-GB', name: 'Englisch (UK)', flag: '🇬🇧'),
  DeeplLanguage(code: 'EN-US', name: 'Englisch (US)', flag: '🇺🇸'),
  DeeplLanguage(code: 'FR', name: 'Französisch', flag: '🇫🇷'),
  DeeplLanguage(code: 'ES', name: 'Spanisch', flag: '🇪🇸'),
  DeeplLanguage(code: 'IT', name: 'Italienisch', flag: '🇮🇹'),
  DeeplLanguage(code: 'PT-PT', name: 'Portugiesisch', flag: '🇵🇹'),
  DeeplLanguage(code: 'PT-BR', name: 'Portugiesisch (BR)', flag: '🇧🇷'),
  DeeplLanguage(code: 'NL', name: 'Niederländisch', flag: '🇳🇱'),
  DeeplLanguage(code: 'PL', name: 'Polnisch', flag: '🇵🇱'),
  DeeplLanguage(code: 'RU', name: 'Russisch', flag: '🇷🇺'),
  DeeplLanguage(code: 'JA', name: 'Japanisch', flag: '🇯🇵'),
  DeeplLanguage(code: 'ZH', name: 'Chinesisch', flag: '🇨🇳'),
  DeeplLanguage(code: 'KO', name: 'Koreanisch', flag: '🇰🇷'),
  DeeplLanguage(code: 'SV', name: 'Schwedisch', flag: '🇸🇪'),
  DeeplLanguage(code: 'DA', name: 'Dänisch', flag: '🇩🇰'),
  DeeplLanguage(code: 'NB', name: 'Norwegisch', flag: '🇳🇴'),
  DeeplLanguage(code: 'CS', name: 'Tschechisch', flag: '🇨🇿'),
  DeeplLanguage(code: 'HU', name: 'Ungarisch', flag: '🇭🇺'),
  DeeplLanguage(code: 'TR', name: 'Türkisch', flag: '🇹🇷'),
];

DeeplLanguage deeplLanguageByCode(String code) {
  return kDeeplTargetLanguages.firstWhere(
    (lang) => lang.code == code,
    orElse: () => kDeeplTargetLanguages.first,
  );
}
