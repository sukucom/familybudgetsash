import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SashKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  const SashKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildSpecialRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _KeyButton(
        label: key,
        onPressed: () => onKeyPressed(key),
      )).toList(),
    );
  }

  Widget _buildSpecialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _KeyButton(label: '.', onPressed: () => onKeyPressed('.')),
        _KeyButton(label: '0', onPressed: () => onKeyPressed('0')),
        _KeyButton(
          label: 'DEL',
          icon: Icons.backspace_outlined,
          onPressed: onDelete,
          isSpecial: true,
        ),
        _KeyButton(
          label: 'DONE',
          icon: Icons.check_circle,
          onPressed: onDone,
          isAction: true,
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isSpecial;
  final bool isAction;

  const _KeyButton({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isSpecial = false,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 75,
        height: 60,
        decoration: BoxDecoration(
          color: isAction 
              ? Theme.of(context).primaryColor 
              : (isSpecial ? Colors.white10 : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 28)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
      ),
    );
  }
}
