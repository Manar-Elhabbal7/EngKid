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
    this.fontSize = 28,
    this.iconSize = 30,
  });

  final String label;
  final IconData icon;
  final Color fill;
  final Color shadow;
  final Color foreground;

  /// Null makes the button disabled: dimmed and not tappable.
  final VoidCallback? onPressed;

  /// Label and icon sizes. Defaults match the big home-screen buttons.
  final double fontSize;
  final double iconSize;

  @override
  State<MenuPillButton> createState() => _MenuPillButtonState();
}

class _MenuPillButtonState extends State<MenuPillButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280, minHeight: 56),
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled
              ? (_) {
                  setState(() => _pressed = false);
                  HapticFeedback.mediumImpact();
                  onPressed();
                }
              : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.45,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              child: FittedBox(
                // Shrinks long labels to fit narrow screens; no effect when they fit.
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.foreground,
                      size: widget.iconSize,
                    ),
                    SizedBox(width: widget.iconSize / 3),
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.foreground,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
