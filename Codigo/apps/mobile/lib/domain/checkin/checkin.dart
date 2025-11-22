// ==============================
// Arquivo: features/checkin/domain/checkin.dart
// ==============================
//
// Pasta 'domain':
// Esta pasta contém tudo relacionado ao **núcleo da feature**, ou seja:
// - Modelos / entidades que representam o **domínio da aplicação**
// - Regras de negócio puras (que não dependem de UI, banco ou API)
// - Use Cases (opcional, mas recomendável em arquiteturas mais completas)
//
// O 'domain' é a camada mais independente da aplicação, garantindo
// que mudanças em UI ou dados não quebrem o núcleo da lógica.
//
// ==============================
// Modelo de domínio: Checkin
//
// Este modelo representa um **check-in** da aplicação.
// Podemos dizer que ele funciona como o "model" em uma arquitetura MVC.
// Ele **carrega todas as informações relevantes de um domínio específico**,
// ou seja, todos os dados que a camada de domínio precisa conhecer.
//
// Exemplo de campos:
// - id: identificador único do check-in
// - title: título ou descrição do check-in
// - date: data e hora do check-in

class Checkin {
  final String id;
  final String title;
  final DateTime date;

  // Construtor obrigatório, garantindo que todas as informações essenciais
  // estejam sempre presentes ao criar um Checkin
  Checkin({required this.id, required this.title, required this.date});
}

// ==============================
// Como usar este modelo:
//
// 1. No repositório (data):
// final checkins = await repository.fetchCheckins();
// checkins.map((json) => Checkin(...));
//
// 2. No Use Case (domain):
// final validCheckins = checkins.where((c) => c.date.isAfter(DateTime.now()));
//
// 3. Na apresentação (provider/UI):
// O modelo é usado para exibir dados na tela sem modificar sua lógica interna.
//
// Observações:
//
// - Este modelo deve **não conter lógica de UI** ou estado de tela.
// - Se houver validações específicas de negócio, elas podem ser implementadas
//   como métodos ou dentro de Use Cases.
// - Modelos no domain garantem **consistência e integridade dos dados** em toda a aplicação.
