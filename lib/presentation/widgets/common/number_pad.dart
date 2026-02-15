import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// 数字键盘组件
///
/// MD3 风格的自定义数字键盘，支持原地算术运算
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onValueChanged,
    this.onDelete,
    this.onClear,
    this.onSubmit,
    this.initialValue = '',
    this.enableHapticFeedback = true,
    this.showOperators = true,
    this.showDot = true,
  });

  final ValueChanged<String> onValueChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onClear;
  final VoidCallback? onSubmit;
  final String initialValue;
  final bool enableHapticFeedback;
  final bool showOperators;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    // 构建键盘行
    final rows = [
      // 第一行：清除 + 数字 7-9
      [
        const _KeyModel('C', type: _KeyType.clear),
        const _KeyModel('7', type: _KeyType.number),
        const _KeyModel('8', type: _KeyType.number),
        const _KeyModel('9', type: _KeyType.number),
      ],
      // 第二行：数字 4-6
      [
        const _KeyModel('4', type: _KeyType.number),
        const _KeyModel('5', type: _KeyType.number),
        const _KeyModel('6', type: _KeyType.number),
        if (showOperators) const _KeyModel('-', type: _KeyType.operator),
      ],
      // 第三行：数字 1-3
      [
        const _KeyModel('1', type: _KeyType.number),
        const _KeyModel('2', type: _KeyType.number),
        const _KeyModel('3', type: _KeyType.number),
        if (showOperators) const _KeyModel('+', type: _KeyType.operator),
      ],
      // 第四行：0 + 小数点 + 删除 + 确认
      [
        const _KeyModel('0', type: _KeyType.number, flex: 2),
        if (showDot) const _KeyModel('.', type: _KeyType.dot),
        const _KeyModel('⌫', type: _KeyType.delete),
        const _KeyModel('✓', type: _KeyType.submit),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < rows.length; i++)
              _buildNumberRow(context, rows[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(BuildContext context, List<_KeyModel> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: keys.map((keyModel) {
          return Expanded(
            flex: keyModel.flex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _NumberKey(
                model: keyModel,
                onTap: () => _handleKeyPress(context, keyModel),
                enableHapticFeedback: enableHapticFeedback,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleKeyPress(BuildContext context, _KeyModel keyModel) {
    // 触感反馈
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    switch (keyModel.type) {
      case _KeyType.number:
      case _KeyType.dot:
        onValueChanged(keyModel.value);
        break;
      case _KeyType.operator:
        if (showOperators) {
          onValueChanged(keyModel.value);
        }
        break;
      case _KeyType.clear:
        onClear?.call();
        break;
      case _KeyType.delete:
        onDelete?.call();
        break;
      case _KeyType.submit:
        onSubmit?.call();
        break;
    }
  }
}

/// 数字键盘按键
class _NumberKey extends StatefulWidget {
  const _NumberKey({
    required this.model,
    required this.onTap,
    required this.enableHapticFeedback,
  });

  final _KeyModel model;
  final VoidCallback onTap;
  final bool enableHapticFeedback;

  @override
  State<_NumberKey> createState() => _NumberKeyState();
}

class _NumberKeyState extends State<_NumberKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据按键类型选择样式
    Color backgroundColor;
    Color foregroundColor;
    double elevation;

    switch (widget.model.type) {
      case _KeyType.clear:
        backgroundColor = colorScheme.errorContainer.withValues(alpha: 0.3);
        foregroundColor = colorScheme.error;
        elevation = 0;
        break;
      case _KeyType.delete:
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurfaceVariant;
        elevation = 0;
        break;
      case _KeyType.submit:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        elevation = 1;
        break;
      case _KeyType.operator:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        elevation = 0;
        break;
      default:
        backgroundColor = colorScheme.surface;
        foregroundColor = colorScheme.onSurface;
        elevation = 0;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isPressed
            ? backgroundColor.withValues(alpha: 0.7)
            : backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isPressed && elevation > 0
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isPressed = true;
            });
            widget.onTap();
            Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _isPressed = false;
              });
            }
          });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              widget.model.value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 按键模型
class _KeyModel {
  const _KeyModel(
    this.value, {
    required this.type,
    this.flex = 1,
  });

  final String value;
  final _KeyType type;
  final int flex;
}

/// 按键类型
enum _KeyType {
  number,
  dot,
  operator,
  clear,
  delete,
  submit,
}

/// 数字键盘输入框（带显示和键盘）
class NumberPadInput extends StatefulWidget {
  const NumberPadInput({
    super.key,
    required this.label,
    this.hint,
    this.prefix = '',
    this.suffix = '',
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.enableHapticFeedback = true,
    this.showOperators = true,
  });

  final String label;
  final String? hint;
  final String prefix;
  final String suffix;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enableHapticFeedback;
  final bool showOperators;

  @override
  State<NumberPadInput> createState() => _NumberPadInputState();
}

class _NumberPadInputState extends State<NumberPadInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleValueChanged(String value) {
    _controller.text = value;
    widget.onChanged?.call(value);
  }

  void _handleDelete() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      _handleValueChanged(text.substring(0, text.length - 1));
    }
  }

  void _handleClear() {
    _handleValueChanged('');
  }

  void _handleSubmit() {
    widget.onSubmitted?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 显示区域
        _buildDisplay(context),

        // 数字键盘
        NumberPad(
          onValueChanged: _handleValueChanged,
          onDelete: _handleDelete,
          onClear: _handleClear,
          onSubmit: _handleSubmit,
          enableHapticFeedback: widget.enableHapticFeedback,
          showOperators: widget.showOperators,
        ),
      ],
    );
  }

  Widget _buildDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.prefix.isNotEmpty)
                Text(
                  widget.prefix,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  readOnly: true,
                  style: theme.textTheme.headlineLarge,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.suffix.isNotEmpty)
                Text(
                  widget.suffix,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
