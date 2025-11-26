/// Utilitários para manipulação de strings
class StringUtils {
  /// Trunca nome completo para exibir primeiro nome + até 2 sobrenomes.
  /// Remove preposições comuns (de, da, do, das, dos) do terceiro elemento.
  /// 
  /// Exemplos:
  /// - "Gustavo Henrique Rodrigues De Castro" → "Gustavo Henrique Rodrigues"
  /// - "Raquel de Oliveira" → "Raquel Oliveira"
  /// - "Felipe Barros Ratton" → "Felipe Barros Ratton"
  /// - "Maria da Silva Santos" → "Maria Silva"
  /// - "João" → "João"
  /// 
  /// [fullName] Nome completo do usuário
  static String truncateName(String fullName) {
    if (fullName.isEmpty) return fullName;
    
    final words = fullName.trim().split(RegExp(r'\s+'));
    
    // Se tem 1 ou 2 palavras, retorna tudo
    if (words.length <= 2) {
      return fullName;
    }
    
    // Se tem 3 palavras
    if (words.length == 3) {
      // Verifica se a segunda palavra é preposição
      final secondWord = words[1].toLowerCase();
      if (_isPreposition(secondWord)) {
        // Remove a preposição: "Raquel de Oliveira" → "Raquel Oliveira"
        return '${words[0]} ${words[2]}';
      }
      // Senão retorna tudo: "Felipe Barros Ratton" → "Felipe Barros Ratton"
      return fullName;
    }
    
    // Se tem 4+ palavras
    // Verifica se a terceira palavra é preposição
    final thirdWord = words[2].toLowerCase();
    if (_isPreposition(thirdWord)) {
      // Remove a preposição: "Gustavo Henrique de Castro" → "Gustavo Henrique Castro"
      // Mas pega só 2 sobrenomes: "Gustavo Henrique"
      return '${words[0]} ${words[1]}';
    }
    
    // Senão, retorna primeiro nome + 2 sobrenomes
    return words.take(3).join(' ');
  }
  
  /// Verifica se a palavra é uma preposição comum
  static bool _isPreposition(String word) {
    final prepositions = {'de', 'da', 'do', 'das', 'dos'};
    return prepositions.contains(word.toLowerCase());
  }
}
