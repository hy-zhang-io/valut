import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 金额输入组件
///
/// 支持原地算术运算（如 50+20），自动计算结果
class AmountInput extends StatefulWidget {
  const AmountInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.prefix = '¥',
    this.hint = '0.00',
    this.enabled = true,
    this.textAlign = TextAlign.end,
    this.enableHapticFeedback = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String prefix;
  final String hint;
  final bool enabled;
  final TextAlign textAlign;
  final bool enableHapticFeedback;

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  // ignore: unused_field
  String _displayValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _updateDisplayValue(widget.value);

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final input = _controller.text;
    // 处理算术运算
    if (_containsOperator(input)) {
      _calculateAndDisplay(input);
    } else {
      _updateDisplayValue(input);
    }
  }

  bool _containsOperator(String text) {
    return text.contains('+') ||
        text.contains('-') ||
        text.contains('*') ||
        text.contains('/');
  }

  void _calculateAndDisplay(String expression) {
    try {
      // 简单的算术运算解析
      final result = _evaluateExpression(expression);
      if (result != null) {
        _updateDisplayValue(result.toString());
        widget.onChanged(result.toString());
      }
    } catch (e) {
      // 表达式无效，保持原样显示
      _updateDisplayValue(expression);
    }
  }

  double? _evaluateExpression(String expression) {
    // 解析并计算简单的加减乘除表达式
    // 只支持数字和运算符
    final sanitized = expression.replaceAll(' ', '');
    if (sanitized.isEmpty) return 0.0;

    // 解析数字和运算符
    final numbers = sanitized.split(RegExp(r'[+\-*/]'));
    final operators = sanitized.replaceAll(RegExp(r'[0-9.]'), '').split('');

    if (numbers.isEmpty || numbers.every((n) => n.isEmpty)) return null;

    double result = double.parse(numbers.first);
    int opIndex = 0;

    for (int i = 1; i < numbers.length && opIndex < operators.length; i++) {
      if (numbers[i].isEmpty) continue;
      final nextNum = double.parse(numbers[i]);
      final operator = operators[opIndex];

      switch (operator) {
        case '+':
          result += nextNum;
          break;
        case '-':
          result -= nextNum;
          break;
        case '*':
          result *= nextNum;
          break;
        case '/':
          if (nextNum != 0) {
            result /= nextNum;
          }
          break;
      }
      opIndex++;
    }

    return result;
  }

  void _updateDisplayValue(String value) {
    setState(() {
      _displayValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 前缀
          if (widget.prefix.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                widget.prefix,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: widget.enabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),

          // 输入区域
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              textAlign: widget.textAlign,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: widget.enabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_AmountInputFormatter()],
            ),
          ),

          // 清除按钮
          if (_controller.text.isNotEmpty && widget.enabled)
            GestureDetector(
              onTap: () {
                if (widget.enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                _controller.clear();
                widget.onChanged('');
                setState(() {
                  _displayValue = '';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.cancel,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 金额输入格式化器
///
/// 确保输入的是有效的数字格式
class _AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许数字、小数点和运算符
    final sanitized = newValue.text.replaceAll(RegExp(r'[^0-9.+\-*/]'), '');

    // 确保只有一个小数点
    final parts = sanitized.split('.');
    String result = parts.first;
    if (parts.length > 1) {
      result += '.${parts.sublist(1).join()}';
    }

    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// 快捷金额输入按钮
///
/// 提供常用金额的快捷输入
class QuickAmountButtons extends StatelessWidget {
  const QuickAmountButtons({
    super.key,
    required this.onAmountSelected,
    this.amounts = const [10, 20, 50, 100, 200, 500],
  });

  final ValueChanged<double> onAmountSelected;
  final List<double> amounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((amount) {
        return ActionChip(
          label: Text(_formatAmount(amount)),
          onPressed: () => onAmountSelected(amount),
          backgroundColor: colorScheme.surfaceContainerHighest,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        );
      }).toList(),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}w';
    }
    return amount.toStringAsFixed(0);
  }
}

/// 完整的金额输入面板
///
/// 包含显示区域、快捷按钮和数字键盘
class AmountInputPanel extends StatefulWidget {
  const AmountInputPanel({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    this.onSubmitted,
    this.enableOperators = true,
    this.quickAmounts = const [10, 20, 50, 100],
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enableOperators;
  final List<double> quickAmounts;

  @override
  State<AmountInputPanel> createState() => _AmountInputPanelState();
}

class _AmountInputPanelState extends State<AmountInputPanel> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 显示区域
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                '¥',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: theme.textTheme.displayLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 快捷金额按钮
        if (widget.quickAmounts.isNotEmpty)
          QuickAmountButtons(
            onAmountSelected: (amount) {
              _controller.text = amount.toString();
              widget.onChanged(_controller.text);
            },
            amounts: widget.quickAmounts,
          ),

        const SizedBox(height: 16),

        // 运算符提示
        if (widget.enableOperators)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OperatorChip(label: '+', onTap: () => _insertOperator('+')),
                const SizedBox(width: 8),
                _OperatorChip(label: '-', onTap: () => _insertOperator('-')),
                const SizedBox(width: 8),
                _OperatorChip(label: '×', onTap: () => _insertOperator('*')),
                const SizedBox(width: 8),
                _OperatorChip(label: '÷', onTap: () => _insertOperator('/')),
              ],
            ),
          ),
      ],
    );
  }

  void _insertOperator(String op) {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;

    final newText =
        text.substring(0, cursorPos) + op + text.substring(cursorPos);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + 1),
    );
    widget.onChanged(newText);
  }
}

/// 运算符按钮
class _OperatorChip extends StatelessWidget {
  const _OperatorChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
