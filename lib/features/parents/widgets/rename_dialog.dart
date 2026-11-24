import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';

/// Asks for a new player name. Pops with the typed name, or null on cancel.
class RenameDialog extends StatefulWidget {
  const RenameDialog({super.key, required this.current});

  final String current;

  static Future<String?> show(BuildContext context, String current) {
    return showDialog<String>(
      context: context,
      builder: (_) => RenameDialog(current: current),
    );
  }

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late final _name = TextEditingController(text: widget.current);

  bool get _canSave => ProfilesNotifier.cleanName(_name.text) != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_canSave) Navigator.of(context).pop(_name.text);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: HalloweenColors.castlePurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Rename player', style: text.headlineMedium),
      content: TextField(
        controller: _name,
        autofocus: true,
        maxLength: ProfilesNotifier.maxNameLength,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _save(),
        style: text.bodyLarge?.copyWith(color: HalloweenColors.deepPurple),
        decoration: InputDecoration(
          filled: true,
          fillColor: HalloweenColors.cream,
          counterStyle: const TextStyle(color: HalloweenColors.cream),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            minimumSize: const Size(96, 48),
            foregroundColor: HalloweenColors.cream,
            textStyle: text.titleLarge,
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave ? _save : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 48),
            backgroundColor: HalloweenColors.orange,
            textStyle: text.titleLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
