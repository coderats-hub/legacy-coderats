import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_widgets.dart';

class CommitCheckinScreen extends StatefulWidget {
  const CommitCheckinScreen({super.key});

  @override
  State<CommitCheckinScreen> createState() => _CommitCheckinScreenState();
}

class _CommitCheckinScreenState extends State<CommitCheckinScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<CommitItem> _commits = [
    CommitItem(title: 'Título do commit aqui', isSelected: false),
    CommitItem(title: 'Título do commit', isSelected: false),
    CommitItem(title: 'Exemplo de commit já utilizado', isSelected: false, isUsed: true),
    CommitItem(title: 'Título do commit', isSelected: false),
  ];
  
  int _selectedCommitsCount = 0;
  bool _hasImage = false;

  @override
  void initState() {
    super.initState();
    // Listener para atualizar o botão quando o título muda
    _titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCommit(int index) {
    if (_commits[index].isUsed) return;
    
    setState(() {
      _commits[index].isSelected = !_commits[index].isSelected;
      _selectedCommitsCount = _commits.where((commit) => commit.isSelected).length;
    });
  }

  void _selectImage() {
    setState(() {
      _hasImage = true;
    });
    // TODO: Implementar seleção de imagem
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SharedTheme.buildDarkTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header compartilhado
              const SharedHeader(
                title: 'Code Rats',
                showRefreshButton: false,
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
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Seção de upload de imagem
          _buildImageUploadSection(),
          
          const SizedBox(height: 24),
          
          // Campo de título
          _buildTitleField(),
          
          const SizedBox(height: 20),
          
          // Campo de descrição
          _buildDescriptionField(),
          
          const SizedBox(height: 24),
          
          // Seção de seleção de commits
          _buildCommitsSection(),
          
          const SizedBox(height: 40),
          
          // Botão de envio
          _buildSubmitButton(),
          
          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicione uma foto à sua atividade',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: _hasImage 
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF3A3A3A),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Color(0xFF7DCDC1),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque para adicionar imagem',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFACACAC),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Título ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: '*',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFEB8462),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        TextField(
          controller: _titleController,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Insira o título da sua atividade',
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFFACACAC),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF7DCDC1),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Insira uma descrição para sua atividade',
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFFACACAC),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF7DCDC1),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecionar commits',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        
        if (_selectedCommitsCount == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Color(0xFFEB8462),
                ),
                const SizedBox(width: 6),
                Text(
                  'Selecione pelo menos 1 commit',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFEB8462),
                  ),
                ),
              ],
            ),
          ),
        
        // Lista de commits
        Column(
          children: _commits.asMap().entries.map((entry) {
            int index = entry.key;
            CommitItem commit = entry.value;
            
            return _buildCommitItem(commit, index);
          }).toList(),
        ),
        
        const SizedBox(height: 8),
        
        // Botão carregar mais
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: Implementar carregar mais commits
            },
            child: Text(
              'Carregar mais +',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitItem(CommitItem commit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: commit.isUsed 
          ? const Color(0xFF1A1A1A) 
          : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: commit.isSelected 
            ? const Color(0xFF7DCDC1)
            : Colors.white.withOpacity(0.2),
          width: commit.isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          onTap: () => _toggleCommit(index),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              commit.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: commit.isUsed 
                  ? const Color(0xFF666666) 
                  : const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: commit.isUsed 
              ? const Icon(
                  Icons.check_box,
                  color: Color(0xFF666666),
                  size: 24,
                )
              : Checkbox(
                  value: commit.isSelected,
                  onChanged: (value) => _toggleCommit(index),
                  activeColor: const Color(0xFF7DCDC1),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _titleController.text.isNotEmpty && _selectedCommitsCount > 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: SharedStyledButton(
          text: 'Fazer Check-in',
          onPressed: canSubmit ? _submitCheckin : () {},
          backgroundColor: const Color(0xFF25A18E),

        ),
      ),
    );
  }

  void _submitCheckin() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, insira um título para a atividade',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCommitsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione pelo menos um commit',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implementar envio do checkin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Check-in criado com sucesso!',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF7DCDC1),
      ),
    );

    // Voltar para a tela anterior
    Navigator.of(context).pop();
  }
}

// ======== MODELS ========

class CommitItem {
  final String title;
  bool isSelected;
  final bool isUsed;

  CommitItem({
    required this.title,
    this.isSelected = false,
    this.isUsed = false,
  });
}