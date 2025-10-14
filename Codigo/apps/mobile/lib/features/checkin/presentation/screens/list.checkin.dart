import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/checkin.repository.dart';
import '../../domain/checkin.dart';
import 'details.checkin.dart';
import '../widgets/shared_widgets.dart';

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

  // Instância direta do repositório
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Theme(
      data: SharedTheme.buildDarkTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header compartilhado
              SharedHeader(
                title: 'Check-ins: Code Rats',
                showRefreshButton: true,
                onRefresh: _loadCheckins,
              ),
              const SizedBox(height: 4),
              
              // Conteúdo principal
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const SharedBottomNav(),
        floatingActionButton: SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommitCheckinScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF7DCDC1),
            elevation: 0,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }



  // Método auxiliar para decidir o que mostrar no corpo da tela
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2BB6A5),
        ),
      );
    }
    
    if (_error != null) {
      return _buildErrorView();
    }
    
    if (_checkins.isEmpty) {
      return _buildEmptyView();
    }
    
    return _buildCheckinsList();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar check-ins',
              style: SharedTheme.buildDarkTheme().textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro: $_error',
              style: SharedTheme.buildDarkTheme().textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SharedStyledButton(
              text: 'Tentar novamente',
              onPressed: _loadCheckins,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: const Color(0xFF2BB6A5).withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum check-in encontrado',
              style: SharedTheme.buildDarkTheme().textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não possui check-ins registrados.',
              style: SharedTheme.buildDarkTheme().textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SharedStyledButton(
              text: 'Atualizar',
              onPressed: _loadCheckins,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posts estáticos baseados na imagem
          _PostCard(
            username: 'Nome Pessoa',
            title: 'Título da Atividade',
            description: 'Descrição da atividade aqui.',
            timeAgo: 'Há 2 dias',
            color: const Color(0xFF8B5A9F),
            isGradient: true,
            gradientColors: const [Color(0xFF4A0A77), Color(0xFF9A24DD)],
            likes: 23,
            comments: 3,
            points: 2,
            githubText: 'Visualizar atividade Github',
          ),
          const SizedBox(height: 16),
          
          _PostCard(
            username: 'Nome Pessoa',
            title: 'Título da Atividade',
            description: 'Descrição da atividade aqui.',
            timeAgo: 'Há 2 dias',
            color: const Color(0xFF25A18E),
            isGradient: true,
            gradientColors: const [Color(0xFF25A18E), Color(0x3325A18E)],
            likes: 15,
            comments: 2,
            points: 3,
            githubText: 'Visualizar atividade Github',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

}

// ======== WIDGETS CUSTOMIZADOS ========

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

// se não for usar, remover
/* class _CheckinTile extends StatelessWidget {
  const _CheckinTile({required this.checkin});
  final Checkin checkin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon do check-in
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2BB6A5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 24,
              color: Color(0xFF2BB6A5),
            ),
          ),
          const SizedBox(width: 16),
          
          // Informações do check-in
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkin.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(checkin.date),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de status
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF2BB6A5),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} - "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
} */



class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.username,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.color,
    required this.isGradient,
    this.gradientColors,
    required this.likes,
    required this.comments,
    required this.points,
    required this.githubText,
  });

  final String username;
  final String title;
  final String description;
  final String timeAgo;
  final Color color;
  final bool isGradient;
  final List<Color>? gradientColors;
  final int likes;
  final int comments;
  final int points;
  final String githubText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com avatar e nome
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[600],
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8), 
              Text(
                username,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Card colorido principal 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            height: 329,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isGradient 
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: gradientColors ?? [const Color(0xFF4A0A77), const Color(0xFF9A24DD)],
                  )
                : null,
              color: isGradient ? null : color,
              borderRadius: BorderRadius.circular(12),
            ),
          child: Stack(
            children: [
              // Footer GitHub com background opaco
              if (githubText.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000).withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          githubText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.code_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
        
        // Informações e stats
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats (likes, comentários, pontos) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 24, color: const Color(0xFFD9D9D9)),
                    const SizedBox(width: 4),
                    Text(
                      likes.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, size: 24, color: const Color(0xFFD9D9D9)),
                    const SizedBox(width: 4),
                    Text(
                      comments.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$points pnts',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFD9D9D9),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Título e descrição lado a lado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFD9D9D9),
                        fontWeight: FontWeight.bold, 
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFD9D9D9),
                          fontWeight: FontWeight.normal, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Tempo separado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  timeAgo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFACACAC), 
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Linha divisória
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[800],
            margin: const EdgeInsets.only(top: 8),
          ),
        ),
      ],
    );
  }
}



