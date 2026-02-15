import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/category_grid.dart';
import '../../widgets/common/amount_input.dart';

/// Add transaction bottom sheet - Record new transactions
class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends ConsumerState<AddTransactionBottomSheet> {
  int _transactionType = AppConstants.transactionTypeExpense;
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final categories = ref.watch(categoriesByTypeProvider(_transactionType));

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text('记一笔', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              child: Column(
                children: [
                  // Type Selector
                  _buildTypeSelector(context, colorScheme),

                  // Category Selector (only for expense/income)
                  if (_transactionType != AppConstants.transactionTypeTransfer)
                    _buildCategorySelector(context, categories),

                  // Account Selector (hidden - uses first account by default)
                  // _buildAccountSelector(context, colorScheme, accounts),

                  // Date Input
                  _buildDateInput(context, colorScheme),

                  // Amount Input
                  _buildAmountInput(context, colorScheme),

                  // Note Input
                  _buildNoteInput(context, colorScheme),

                  // Save Button
                  _buildSaveButton(context, colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(
            value: AppConstants.transactionTypeExpense,
            label: Text('支出'),
            icon: Icon(Icons.arrow_upward, size: 18),
          ),
          ButtonSegment(
            value: AppConstants.transactionTypeIncome,
            label: Text('收入'),
            icon: Icon(Icons.arrow_downward, size: 18),
          ),
          ButtonSegment(
            value: AppConstants.transactionTypeTransfer,
            label: Text('转账'),
            icon: Icon(Icons.swap_horiz, size: 18),
          ),
        ],
        selected: {_transactionType},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            _transactionType = newSelection.first;
            _selectedCategoryId = null; // Reset category when type changes
          });
        },
      ),
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    List<Category> categories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择分类',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          CategoryGrid(
            categories: categories,
            selectedCategoryId: _selectedCategoryId?.toString() ?? '',
            onCategorySelected: (categoryId) {
              final id = int.tryParse(categoryId);
              if (id != null) {
                setState(() {
                  _selectedCategoryId = id;
                });
              }
            },
            showIncome: _transactionType == AppConstants.transactionTypeIncome,
            showExpense:
                _transactionType == AppConstants.transactionTypeExpense,
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: '日期',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _formatDate(_selectedDate),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AmountInput(
        value: _amountController.text,
        onChanged: (value) {
          _amountController.text = value;
          setState(() {});
        },
        prefix: '¥',
        hint: '0.00',
        enabled: true,
        textAlign: TextAlign.end,
        enableHapticFeedback: true,
      ),
    );
  }

  Widget _buildNoteInput(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: TextField(
        controller: _noteController,
        decoration: const InputDecoration(
          hintText: '添加备注...',
          prefixIcon: Icon(Icons.note_outlined),
        ),
        maxLength: AppConstants.maxNoteLength,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      child: FilledButton(
        onPressed: _canSave() ? _saveTransaction : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
        ),
        child: const Text('保存'),
      ),
    );
  }

  bool _canSave() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      return false;
    }
    if (_transactionType != AppConstants.transactionTypeTransfer &&
        _selectedCategoryId == null) {
      return false;
    }
    return true;
  }

  void _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    // Get accounts and use the first one if none is selected
    final accounts = ref.read(accountNotifierProvider);
    final accountId =
        _selectedAccountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    if (accountId == null) return;

    // 生成手工交易ID
    final transactionId = await ref
        .read(transactionNotifierProvider.notifier)
        .generateManualTransactionId(_selectedDate);

    final transaction = Transaction.withDate(
      amount: _transactionType == AppConstants.transactionTypeExpense
          ? -amount
          : amount,
      type: _transactionType,
      accountId: accountId,
      categoryId: _selectedCategoryId,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: _selectedDate,
      externalTransactionId: transactionId,
      dataSource: 'manual',
    );

    await ref
        .read(transactionNotifierProvider.notifier)
        .addTransaction(transaction);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('zh', 'CN'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
