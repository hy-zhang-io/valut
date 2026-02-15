import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

/// 添加交易底部表单
class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({
    super.key,
    required this.isExpense,
    required this.onSaved,
  });

  final bool isExpense;
  final VoidCallback onSaved;

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _displayAmount = '0.00';

  void _onNumberTap(String number) {
    HapticFeedback.lightImpact();
    final current = _amountController.text;

    if (number == '.') {
      if (current.contains('.')) return;
      if (current.isEmpty) {
        _amountController.text = '0.';
      } else {
        _amountController.text = current + number;
      }
    } else if (number == 'backspace') {
      if (current.isNotEmpty) {
        _amountController.text = current.substring(0, current.length - 1);
      }
    } else {
      if (current.length >= 8) return;
      if (current.contains('.')) {
        final decimalIndex = current.indexOf('.');
        if (current.length - decimalIndex > 2) return;
      }
      _amountController.text = current + number;
    }

    setState(() {
      final amount = double.tryParse(_amountController.text) ?? 0;
      _displayAmount = amount.toStringAsFixed(2);
    });
  }

  void _selectCategory(int categoryId) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _showSnackBar('请输入金额');
      return;
    }
    if (_selectedCategoryId == null) {
      _showSnackBar('请选择分类');
      return;
    }

    final transaction = Transaction.withDate(
      amount: amount,
      type: widget.isExpense
          ? AppConstants.transactionTypeExpense
          : AppConstants.transactionTypeIncome,
      accountId: 1,
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);

    widget.onSaved();
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final categories = widget.isExpense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isExpense ? '记支出' : '记收入',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 可滚动内容区域
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 金额显示
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¥',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _displayAmount,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 日期选择
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outline),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 分类选择 - 每行4个
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _selectedCategoryId == category.id;
                        final categoryColor = Color(Category.categoryColors[category.color]);
                        return _CategoryGridItem(
                          category: category,
                          isSelected: isSelected,
                          categoryColor: categoryColor,
                          onTap: () => _selectCategory(category.id),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 备注输入
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: '添加备注...',
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 数字键盘 + 保存按钮区域
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _KeyboardWithSave(
                      onNumberTap: _onNumberTap,
                      onSave: _saveTransaction,
                      saveColor: color,
                    ),
                  ),

                  // 底部安全区域
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 分类网格项
class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({
    required this.category,
    required this.isSelected,
    required this.categoryColor,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? categoryColor : AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconData(category.icon, fontFamily: 'MaterialIcons'),
                size: 24,
                color: isSelected ? Colors.white : categoryColor,
              ),
              const SizedBox(height: 4),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 数字键盘 + 保存按钮
class _KeyboardWithSave extends StatelessWidget {
  const _KeyboardWithSave({
    required this.onNumberTap,
    required this.onSave,
    required this.saveColor,
  });

  final Function(String) onNumberTap;
  final VoidCallback onSave;
  final Color saveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧数字键盘
        Expanded(
          flex: 3,
          child: Column(
            children: [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['.', '0', 'backspace'],
            ].map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((number) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _NumberKey(
                          number: number,
                          onTap: () => onNumberTap(number),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
        // 右侧保存按钮
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Material(
              color: saveColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onSave,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 248, // 4行数字键的高度 (56*4 + 8*3)
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '保存',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 数字按键
class _NumberKey extends StatelessWidget {
  const _NumberKey({
    required this.number,
    required this.onTap,
  });

  final String number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          child: Center(
            child: number == 'backspace'
                ? const Icon(Icons.backspace_outlined)
                : Text(
                    number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
