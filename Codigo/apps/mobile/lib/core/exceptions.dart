// ==============================
// Arquivo: core/exceptions.dart
// ==============================
//
// Esta pasta 'core' contém utilitários e classes que são usados 
// em todo o aplicativo, independentemente da feature. 
// Por exemplo: exceções globais, configurações, constantes, funções, etc.
//
// Este arquivo 'exceptions.dart' define uma exceção personalizada 
// que pode ser usada em qualquer lugar do app para padronizar erros.

// Define uma exceção personalizada chamada 'AppException'
class AppException implements Exception {
  // Mensagem de erro que será exibida ou logada
  final String message;

  // Construtor que recebe a mensagem de erro
  AppException(this.message);
}

// ==============================
// Como usar essa exceção:
//
// Exemplo 1: lançando uma exceção dentro de um repositório
// if (response.statusCode != 200) {
//   throw AppException('Falha ao buscar dados da API');
// }
//
// Exemplo 2: capturando e tratando a exceção no provider
// try {
//   await repository.fetchData();
// } catch (e) {
//   if (e is AppException) {
//     // Aqui você pode mostrar uma mensagem na UI
//     print(e.message);
//   }
// }
//
// Dica: usar exceções personalizadas ajuda a manter um padrão
// e facilita depuração e tratamento de erros em todo o app.
