import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../data/models/category_mapping.dart';
import '../../../data/repositories/database_service.dart';
import '../../providers/category_provider.dart';

/// 分类映射管理页面 - 卡片列表式交互
/// 
/// 采用更友好的卡片列表设计，每个外部分类显示为一行卡片，
/// 直观展示映射状态和已映射的内部分类
class CategoryMappingScreen extends ConsumerStatefulWidget {
  const CategoryMappingScreen({super.key});

  @override
  ConsumerState<CategoryMappingScreen> createState() => _CategoryMappingScreenState();
}

class _CategoryMappingScreenState extends ConsumerState<CategoryMappingScreen> {
  String _selectedSource = 'alipay';
  List<CategoryMapping> _mappings = [];
  List<Category> _categories = [];
  List<String> _externalCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final db = DatabaseService.instance;
    final mappingService = CategoryMappingService();
    mappingService.initialize(db.isar);

    // 初始化默认映射
    await mappingService.initDefaultAlipayMappings();
    await mappingService.initDefaultWechatMappings();

    // 加载映射
    final mappings = await mappingService.getMappingsBySource(_selectedSource);

    // 从provider获取分类（支出+收入）
    final expenseCats = ref.read(expenseCategoriesProvider);
    final incomeCats = ref.read(incomeCategoriesProvider);
    final categories = [...expenseCats, ...incomeCats];

    // 获取外部分类列表
    final externalCats = _getExternalCategories();

    setState(() {
      _mappings = mappings;
      _categories = categories;
      _externalCategories = externalCats;
      _isLoading = false;
    });
  }

  List<String> _getExternalCategories() {
    // 预设的外部分类
    if (_selectedSource == 'alipay') {
      return [
        '交通出行',
        '哈啰单车',
        '美团',
        '饿了么',
        '淘宝天猫',
        '生活缴费',
        '转账充值',
        '滴滴出行',
        '共享单车',
        '餐饮美食',
        '休闲娱乐',
        '医疗健康',
      ];
    } else {
      return [
        '商户消费',
        '二维码收款',
        '转账',
        '红包',
        '生活缴费',
        '交通出行',
        '餐饮美食',
      ];
    }
  }

  Category? _getMappedCategory(String externalCategory) {
    final mapping = _mappings.firstWhere(
      (m) => m.externalCategory == externalCategory,
      orElse: () => CategoryMapping(
        externalCategory: '',
        internalCategoryId: -1,
        sourceType: '',
      ),
    );
    if (mapping.id <= 0) return null;
    
    try {
      return _categories.firstWhere((c) => c.id == mapping.internalCategoryId);
    } catch (_) {
      return null;
    }
  }

  CategoryMapping? _getMapping(String externalCategory) {
    try {
      return _mappings.firstWhere((m) => m.externalCategory == externalCategory);
    } catch (_) {
      return null;
    }
  }

  Future<void> _createMapping(String external, int internalId) async {
    final mappingService = CategoryMappingService();
    mappingService.initialize(DatabaseService.instance.isar);

    final newMapping = CategoryMapping(
      externalCategory: external,
      internalCategoryId: internalId,
      sourceType: _selectedSource,
      description: '用户自定义',
    );

    await mappingService.saveMapping(newMapping);
    HapticFeedback.mediumImpact();
    await _loadData();
  }

  Future<void> _updateMapping(CategoryMapping mapping, int newInternalId) async {
    final mappingService = CategoryMappingService();
    mappingService.initialize(DatabaseService.instance.isar);

    final updatedMapping = CategoryMapping(
      id: mapping.id,
      externalCategory: mapping.externalCategory,
      internalCategoryId: newInternalId,
      sourceType: mapping.sourceType,
      description: mapping.description,
    );

    await mappingService.saveMapping(updatedMapping);
    HapticFeedback.mediumImpact();
    await _loadData();
  }

  Future<void> _deleteMapping(int mappingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除映射'),
        content: const Text('确定要删除这个映射关系吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.expenseColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final mappingService = CategoryMappingService();
      mappingService.initialize(DatabaseService.instance.isar);
      await mappingService.deleteMapping(mappingId);
      HapticFeedback.lightImpact();
      await _loadData();
    }
  }

  Future<void> _addExternalCategory() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加外部分类'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入外部分类名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _externalCategories.add(result);
      });
    }
  }

  void _showCategorySelector(String externalCategory) {
    final currentMapping = _getMapping(externalCategory);
    final currentCategory = _getMappedCategory(externalCategory);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategorySelectorSheet(
        externalCategory: externalCategory,
        categories: _categories,
        currentCategory: currentCategory,
        onSelect: (category) async {
          Navigator.of(context).pop();
          if (currentMapping != null) {
            await _updateMapping(currentMapping, category.id);
          } else {
            await _createMapping(externalCategory, category.id);
          }
        },
        onClear: currentMapping != null
            ? () async {
                Navigator.of(context).pop();
                await _deleteMapping(currentMapping.id);
              }
            : null,
      ),
    );
  }

  List<String> get _filteredCategories {
    if (_searchQuery.isEmpty) return _externalCategories;
    return _externalCategories
        .where((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mappedCount = _mappings.length;
    final totalCount = _externalCategories.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类映射管理'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addExternalCategory,
            icon: const Icon(Icons.add),
            tooltip: '添加外部分类',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 来源选择
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'alipay',
                        label: Text('支付宝'),
                        icon: Icon(Icons.payment),
                      ),
                      ButtonSegment(
                        value: 'wechat',
                        label: Text('微信'),
                        icon: Icon(Icons.chat),
                      ),
                    ],
                    selected: {_selectedSource},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedSource = selected.first;
                        _searchQuery = '';
                      });
                      _loadData();
                    },
                  ),
                ),

                // 搜索框
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: '搜索外部分类...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () => setState(() => _searchQuery = ''),
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 说明卡片
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '点击卡片选择映射的内部分类，左滑可删除已有映射',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 统计信息
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '已建立映射: $mappedCount/$totalCount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          '搜索结果: ${_filteredCategories.length}个',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 映射列表
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final external = _filteredCategories[index];
                            final mappedCategory = _getMappedCategory(external);
                            final mapping = _getMapping(external);

                            return _MappingCard(
                              externalCategory: external,
                              mappedCategory: mappedCategory,
                              onTap: () => _showCategorySelector(external),
                              onDelete: mapping != null
                                  ? () => _deleteMapping(mapping.id)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? '暂无外部分类' : '未找到匹配的分类',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 映射卡片组件
class _MappingCard extends StatelessWidget {
  const _MappingCard({
    required this.externalCategory,
    this.mappedCategory,
    required this.onTap,
    this.onDelete,
  });

  final String externalCategory;
  final Category? mappedCategory;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMapped = mappedCategory != null;
    final categoryColor = isMapped
        ? Color(Category.categoryColors[mappedCategory!.color % Category.categoryColors.length])
        : AppTheme.onSurfaceVariant;

    // 使用 Dismissible 支持左滑删除
    Widget card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMapped ? categoryColor.withValues(alpha: 0.3) : AppTheme.outline,
          width: isMapped ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 外部分类图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.label_outline,
                  color: AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // 外部分类名称
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      externalCategory,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 映射状态
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMapped ? categoryColor : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isMapped ? '已映射' : '未映射',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isMapped ? categoryColor : Colors.grey,
                            fontWeight: isMapped ? FontWeight.w500 : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 映射的内部分类
              if (isMapped) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconData(mappedCategory!.icon, fontFamily: 'MaterialIcons'),
                        size: 16,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mappedCategory!.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '选择分类',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppTheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );

    // 如果有映射，支持左滑删除
    if (isMapped && onDelete != null) {
      card = Dismissible(
        key: ValueKey(externalCategory),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('删除映射'),
              content: Text('确定要删除 "$externalCategory" 的映射吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.expenseColor,
                  ),
                  child: const Text('删除'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => onDelete!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.expenseColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
        child: card,
      );
    }

    return card;
  }
}

/// 分类选择器底部弹窗
class _CategorySelectorSheet extends StatelessWidget {
  const _CategorySelectorSheet({
    required this.externalCategory,
    required this.categories,
    this.currentCategory,
    required this.onSelect,
    this.onClear,
  });

  final String externalCategory;
  final List<Category> categories;
  final Category? currentCategory;
  final ValueChanged<Category> onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 分离支出和收入分类
    final expenseCategories = categories.where((c) => c.isExpense).toList();
    final incomeCategories = categories.where((c) => c.isIncome).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '选择映射分类',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    externalCategory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 分类列表
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 支出分类
                  _buildCategorySection(
                    context,
                    title: '支出分类',
                    categories: expenseCategories,
                    currentCategory: currentCategory,
                    onSelect: onSelect,
                  ),
                  const SizedBox(height: 24),
                  // 收入分类
                  _buildCategorySection(
                    context,
                    title: '收入分类',
                    categories: incomeCategories,
                    currentCategory: currentCategory,
                    onSelect: onSelect,
                  ),
                ],
              ),
            ),
          ),

          // 底部按钮
          if (onClear != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('删除映射'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.expenseColor,
                    side: BorderSide(color: AppTheme.expenseColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required List<Category> categories,
    required Category? currentCategory,
    required ValueChanged<Category> onSelect,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final color = Color(Category.categoryColors[category.color % Category.categoryColors.length]);
            final isSelected = currentCategory?.id == category.id;

            return InkWell(
              onTap: () => onSelect(category),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconData(category.icon, fontFamily: 'MaterialIcons'),
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check, size: 16, color: color),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
