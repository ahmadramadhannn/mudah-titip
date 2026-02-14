import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffixText;
  final int min;
  final int? max;
  final ValueChanged<int>? onChanged;
  final String? Function(String?)? validator;

  const QuantitySelector({
    super.key,
    required this.controller,
    required this.label,
    this.suffixText,
    this.min = 0,
    this.max,
    this.onChanged,
    this.validator,
  });

  void _increment() {
    final current = int.tryParse(controller.text) ?? 0;
    if (max == null || current < max!) {
      final newValue = current + 1;
      controller.text = newValue.toString();
      onChanged?.call(newValue);
    }
  }

  void _decrement() {
    final current = int.tryParse(controller.text) ?? 0;
    if (current > min) {
      final newValue = current - 1;
      controller.text = newValue.toString();
      onChanged?.call(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButton(
              icon: Icons.remove,
              onPressed: _decrement,
              isLeft: true,
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixText: suffixText,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppColors.neutral300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final val = int.tryParse(value);
                  if (val != null) {
                    onChanged?.call(val);
                  }
                },
                validator: validator,
              ),
            ),
            _buildButton(icon: Icons.add, onPressed: _increment, isLeft: false),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 48, // Match TextFormField default height roughly
        width: 48,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(8) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(8) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(8) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
