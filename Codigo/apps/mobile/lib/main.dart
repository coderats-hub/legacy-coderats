import 'package:flutter/material.dart';
import 'shared/theme/app.theme.dart';
import 'shared/components/buttonPrimary.dart';
import 'shared/components/textfield.dart';
import 'features/groups/presentation/screens/create_groups.screen.dart';
import 'features/groups/presentation/screens/scoring_mode_groups.screen.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Demo',
      theme: AppTheme.dark(), // usa seu tema escuro
      home: const DemoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('UI Kit • Demo')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toast(context, 'FAB pressionado'),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Inputs =====
            Text('Inputs', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            AppTextField(
              label: 'Nome do Grupo',
              hintText: 'Insira o nome do seu grupo',
              required: true,
              icon: Icons.group,
              controller: _nameCtrl,
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Descrição',
              hintText: 'Fale brevemente sobre o seu grupo',
              maxLines: 3,
              controller: _descCtrl,
            ),
            const SizedBox(height: 16),

            const AppTextField(
              label: 'Campo Desabilitado',
              hintText: 'Não editável',
              enabled: false,
              icon: Icons.lock,
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outline),
            const SizedBox(height: 24),

            // ===== Botões =====
            Text('Buttons', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // Row 1: primário / secundário
            Row(
              children: [
                Expanded(
                  child: AppButtonPrimary(
                    type: AppButtonPrimaryType.primary,
                    text: 'Primário',
                    icon: Icons.check,
                    onPressed: () => _toast(context, 'Primary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButtonPrimary(
                    type: AppButtonPrimaryType.secondary,
                    text: 'Secundário',
                    icon: Icons.star,
                    onPressed: () => _toast(context, 'Secondary'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: terciário / erro
            Row(
              children: [
                Expanded(
                  child: AppButtonPrimary(
                    type: AppButtonPrimaryType.tertiary,
                    text: 'Terciário',
                    icon: Icons.auto_awesome,
                    onPressed: () => _toast(context, 'Tertiary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButtonPrimary(
                    type: AppButtonPrimaryType.error,
                    text: 'Erro',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () => _toast(context, 'Error'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Disabled (com e sem ícone)
            Row(
              children: [
                Expanded(
                  child: AppButtonPrimary(
                    type: AppButtonPrimaryType.primary,
                    text: 'Desabilitado',
                    disabled: true,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButtonPrimary(
                    type: AppButtonPrimaryType.secondary,
                    text: 'Sem Ícone',
                    onPressed: () => _toast(context, 'Sem ícone'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            
            // ===== Navegação =====
            Text('Navegação', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            
            AppButtonPrimary(
              type: AppButtonPrimaryType.primary,
              text: 'Criar Grupo',
              icon: Icons.group_add,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            AppButtonPrimary(
              type: AppButtonPrimaryType.secondary,
              text: 'Método Avaliativo',
              icon: Icons.assessment,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ScoringModeGroupsScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            // Exemplo de uso das cores do tema fora dos componentes
            Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Box com tertiaryContainer',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: cs.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
