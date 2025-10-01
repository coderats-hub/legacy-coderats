import 'package:flutter/material.dart';
import '../../data/checkin.repository.dart';
import '../../domain/checkin.dart';
import '../../../../shared/app_button.dart';

// A tela foi convertida para StatefulWidget para gerenciar o próprio estado
class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  // Variáveis para controlar o estado da UI
  bool _isLoading = true;
  Object? _error;
  List<Checkin> _checkins = [];

  // Instância direta do repositório, já que não temos mais provider
  final _repository = CheckinRepository();

  // initState é chamado uma vez quando o widget é criado
  @override
  void initState() {
    super.initState();
    // A busca de dados é iniciada aqui
    _loadCheckins();
  }

  // Função para buscar os dados e atualizar o estado da tela
  Future<void> _loadCheckins() async {
    // Atualiza a UI para mostrar o estado de carregamento
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repository.fetchCheckins();
      // Em caso de sucesso, atualiza a UI com os dados
      if (mounted) { // Garante que o widget ainda está na árvore
        setState(() {
          _checkins = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Em caso de erro, atualiza a UI com a mensagem de erro
       if (mounted) { // Garante que o widget ainda está na árvore
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-ins')),
      // O corpo agora é construído por um método auxiliar
      body: _buildBody(),
      floatingActionButton: AppButton(
        text: 'Atualizar',
        // O botão agora chama a função local para recarregar
        onPressed: _loadCheckins,
      ),
    );
  }

  // Método auxiliar para decidir o que mostrar no corpo da tela
  Widget _buildBody() {
    if (_isLoading) {
      // Se está carregando, mostra o indicador de progresso
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      // Se deu erro, mostra a mensagem
      return Center(child: Text('Erro: $_error'));
    }
    // Se tem dados, mostra a lista
    return ListView.builder(
      itemCount: _checkins.length,
      itemBuilder: (context, index) {
        final checkin = _checkins[index];
        return ListTile(
          title: Text(checkin.title),
          subtitle: Text(checkin.date.toString()),
        );
      },
    );
  }
}

