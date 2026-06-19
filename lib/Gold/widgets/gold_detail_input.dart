import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class GoldDetailInputGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const GoldDetailInputGroup({
    super.key,
    this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            children: children, // Dividers removed here, handled by individual fields
          ),
        ),
      ],
    );
  }
}

class GoldDetailInputField extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final TextEditingController? controller;
  final bool isDate;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final bool showBottomBorder;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? suffixIcon;
  final Widget? prefix;
  final String? errorText;
  final int? maxLength;

  const GoldDetailInputField({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.controller,
    this.isDate = false,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.textAlign = TextAlign.end,
    this.showBottomBorder = true,
    this.inputFormatters,
    this.suffixIcon,
    this.prefix,
    this.errorText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTappable = onTap != null && controller == null;
    final IconData? resolvedIcon = suffixIcon ?? (isDate ? Icons.calendar_month_outlined : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: showBottomBorder
                    ? const Border(
                        bottom: BorderSide(
                          color: Color(0xFFF1F2F5), // Very light gray from image
                          width: 1.0,
                        ),
                      )
                    : null,
              ),
              child: isTappable
                  ? GestureDetector(
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                value ?? hint ?? '---',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  // color: value != null ? AppColors.textPrimary : AppColors.textHint,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (resolvedIcon != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                resolvedIcon,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : TextField(
                      controller: controller,
                      textAlign: textAlign,
                      readOnly: readOnly,
                      autofocus: false,
                      keyboardType: keyboardType,
                      inputFormatters: inputFormatters,
                      maxLength: maxLength,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        prefixIcon: prefix,
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        hintText: hint ?? '---',
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                        errorText: errorText,
                        errorStyle: const TextStyle(
                          fontSize: 9,
                          color: Colors.redAccent,
                        ),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}



