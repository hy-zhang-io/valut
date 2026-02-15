import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/category.dart';

/// 分类颜色辅助类
class CategoryColors {
  CategoryColors._();

  static const List<Color> colors = [
    Color(0xFFEA4335), // Red
    Color(0xFFFBBC04), // Yellow
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFF7B4BDB), // Purple
    Color(0xFFFF6D01), // Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF78CAB), // Pink
    Color(0xFF8D6E63), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  static Color getColor(int colorIndex) {
    return colors[colorIndex % colors.length];
  }
}

/// 分类网格组件
///
/// 以 Chip 平铺方式展示分类，支持横向滑动
class CategoryGrid extends StatefulWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.iconSize = 32,
    this.showIncome = true,
    this.showExpense = true,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final double iconSize;
  final bool showIncome;
  final bool showExpense;

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据收支类型筛选分类
    final filteredCategories = widget.categories.where((category) {
      if (category.type == 0 && widget.showExpense) return true;
      if (category.type == 1 && widget.showIncome) return true;
      return false;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '选择分类',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),

        // 分类网格
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final category = filteredCategories[index];
              final isSelected =
                  category.id.toString() == widget.selectedCategoryId;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _CategoryChip(
                  category: category,
                  isSelected: isSelected,
                  iconSize: widget.iconSize,
                  onTap: () {
                    // 触感反馈
                    HapticFeedback.lightImpact();
                    widget.onCategorySelected(category.id.toString());
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 分类 Chip 组件
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.iconSize,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 获取分类颜色
    final categoryColor = CategoryColors.getColor(category.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.2)
              : categoryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? categoryColor
                : categoryColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Icon(
              IconData(category.icon, fontFamily: 'MaterialIcons'),
              size: iconSize,
              color: categoryColor,
            ),
            const SizedBox(height: 8),

            // 名称
            Text(
              category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? categoryColor
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类选择器（网格布局版本）
///
/// 使用网格布局展示分类，适合平板/桌面
class CategoryGridTablet extends StatelessWidget {
  const CategoryGridTablet({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.crossAxisCount = 4,
    this.showIncome = true,
    this.showExpense = true,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final int crossAxisCount;
  final bool showIncome;
  final bool showExpense;

  @override
  Widget build(BuildContext context) {
    // 根据收支类型筛选分类
    final filteredCategories = categories.where((category) {
      if (category.type == 0 && showExpense) return true;
      if (category.type == 1 && showIncome) return true;
      return false;
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final isSelected = category.id.toString() == selectedCategoryId;

        return _CategoryCard(
          category: category,
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.lightImpact();
            onCategorySelected(category.id.toString());
          },
        );
      },
    );
  }
}

/// 分类卡片（用于网格布局）
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categoryColor = CategoryColors.getColor(category.color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.15)
              : categoryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? categoryColor
                : categoryColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标容器
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(category.icon, fontFamily: 'MaterialIcons'),
                color: categoryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),

            // 名称
            Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? categoryColor
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 响应式分类网格
///
/// 根据屏幕尺寸自动选择横向滚动或网格布局
class ResponsiveCategoryGrid extends StatelessWidget {
  const ResponsiveCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.showIncome = true,
    this.showExpense = true,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final bool showIncome;
  final bool showExpense;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 平板/桌面使用网格布局，移动端使用横向滚动
    if (screenWidth >= 600) {
      return CategoryGridTablet(
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        onCategorySelected: onCategorySelected,
        crossAxisCount: screenWidth >= 1024 ? 6 : 4,
        showIncome: showIncome,
        showExpense: showExpense,
      );
    }

    return CategoryGrid(
      categories: categories,
      selectedCategoryId: selectedCategoryId,
      onCategorySelected: onCategorySelected,
      showIncome: showIncome,
      showExpense: showExpense,
    );
  }
}

/// 分类选择对话框
///
/// 用于选择分类的弹窗
class CategorySelectorDialog extends StatelessWidget {
  const CategorySelectorDialog({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    this.title = '选择分类',
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 分类网格
            Expanded(
              child: CategoryGridTablet(
                categories: categories,
                selectedCategoryId: selectedCategoryId,
                onCategorySelected: (categoryId) {
                  Navigator.of(context).pop(categoryId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 快速分类选择器（小型版本）
///
/// 用于空间有限的场景
class QuickCategorySelector extends StatelessWidget {
  const QuickCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.maxShow = 6,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final int maxShow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayCategories = categories.take(maxShow).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: displayCategories.map((category) {
        final isSelected = category.id.toString() == selectedCategoryId;
        final categoryColor = CategoryColors.getColor(category.color);

        return FilterChip(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (_) => onCategorySelected(category.id.toString()),
          selectedColor: categoryColor.withValues(alpha: 0.2),
          checkmarkColor: categoryColor,
          backgroundColor: categoryColor.withValues(alpha: 0.1),
          side: BorderSide(color: categoryColor.withValues(alpha: 0.3)),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? categoryColor : colorScheme.onSurfaceVariant,
          ),
        );
      }).toList(),
    );
  }
}
