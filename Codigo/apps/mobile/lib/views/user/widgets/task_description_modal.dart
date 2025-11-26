import 'package:flutter/material.dart';

/// Simple placeholder modal used during registration flow.
/// The original file was missing; this minimal implementation
/// ensures builds succeed and can be expanded with real content.
class TaskDescriptionModal extends StatelessWidget {
  final BuildContext parentContext;

  const TaskDescriptionModal({Key? key, required this.parentContext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Descrição da tarefa'),
      content: const Text(
        'Aqui você pode descrever a tarefa ou informações adicionais para completar o cadastro.\n\n(Placeholder temporário)',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
