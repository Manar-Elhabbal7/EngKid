import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuPillButton extends StatefulWidget {
  const MenuPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.fill,
    required this.shadow,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color fill;
  final Color shadow;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  State<MenuPillButton> createState() => _MenuPillButtonState();
}

class _MenuPillButtonState extends State<MenuPillButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280, minHeight: 56),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) {
            setState(() => _pressed = false);
            HapticFeedback.mediumImpact();
            widget.onPressed();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(widget.fill, Colors.white, 0.18)!,
                  widget.fill,
                  widget.shadow,
                ],
              ),
              border: Border.all(
                color: Color.lerp(widget.fill, Colors.white, 0.45)!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.shadow.withValues(alpha: 0.7),
                  offset: Offset(0, _pressed ? 2 : 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.foreground, size: 30),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: widget.foreground,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
