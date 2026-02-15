import 'package:isar/isar.dart';

part 'category_mapping.g.dart';

/// 外部账单分类与内部分类的映射关系
@collection
class CategoryMapping {
  CategoryMapping({
    this.id = Isar.autoIncrement,
    required this.externalCategory,
    required this.internalCategoryId,
    required this.sourceType, // 'alipay', 'wechat', 'manual'
    this.description,
  });

  final Id id;

  /// 外部账单分类名称（如：交通出行、美团等）
  final String externalCategory;

  /// 映射到的内部分类ID
  final int internalCategoryId;

  /// 数据来源类型：alipay(支付宝), wechat(微信), manual(手动)
  final String sourceType;

  /// 描述/备注
  final String? description;

  /// 是否是系统预设映射
  bool get isSystemPreset => id <= 100;

  @override
  String toString() {
    return 'CategoryMapping{id: $id, external: $externalCategory, internalId: $internalCategoryId, source: $sourceType}';
  }
}

/// 分类映射服务
class CategoryMappingService {
  static final CategoryMappingService _instance = CategoryMappingService._internal();
  factory CategoryMappingService() => _instance;
  CategoryMappingService._internal();

  Isar? _isar;

  void initialize(Isar isar) {
    _isar = isar;
  }

  /// 获取所有映射
  Future<List<CategoryMapping>> getAllMappings() async {
    if (_isar == null) return [];
    return await _isar!.categoryMappings.where().idGreaterThan(0).findAll();
  }

  /// 根据数据来源获取映射
  Future<List<CategoryMapping>> getMappingsBySource(String sourceType) async {
    if (_isar == null) return [];
    return await _isar!.categoryMappings
        .filter()
        .sourceTypeEqualTo(sourceType)
        .findAll();
  }

  /// 根据外部分类查找映射
  Future<CategoryMapping?> findMapping(String externalCategory, String sourceType) async {
    if (_isar == null) return null;
    return await _isar!.categoryMappings
        .filter()
        .externalCategoryEqualTo(externalCategory)
        .sourceTypeEqualTo(sourceType)
        .findFirst();
  }

  /// 添加或更新映射
  Future<void> saveMapping(CategoryMapping mapping) async {
    if (_isar == null) return;
    await _isar!.writeTxn(() async {
      await _isar!.categoryMappings.put(mapping);
    });
  }

  /// 删除映射
  Future<void> deleteMapping(int id) async {
    if (_isar == null) return;
    await _isar!.writeTxn(() async {
      await _isar!.categoryMappings.delete(id);
    });
  }

  /// 根据外部分类获取内部分类ID
  Future<int?> getInternalCategoryId(String externalCategory, String sourceType) async {
    final mapping = await findMapping(externalCategory, sourceType);
    return mapping?.internalCategoryId;
  }

  /// 初始化默认映射（支付宝）
  Future<void> initDefaultAlipayMappings() async {
    if (_isar == null) return;

    // 内部分类ID参考 category.dart:
    // 1-日常花销, 2-房租/还款, 3-保费缴纳, 4-兴趣爱好, 5-孩子花费,
    // 6-生活缴费, 7-交通通勤, 8-医疗支出, 9-养宠物, 10-人情送礼, 999-自定义
    // 收入: 101-工资, 102-奖金, 104-兼职, 105-礼金, 106-其他

    final defaultMappings = [
      // 交通出行 -> 交通通勤 (7)
      CategoryMapping(
        externalCategory: '交通出行',
        internalCategoryId: 7,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 哈啰单车 -> 交通通勤 (7)
      CategoryMapping(
        externalCategory: '哈啰单车',
        internalCategoryId: 7,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 滴滴出行 -> 交通通勤 (7)
      CategoryMapping(
        externalCategory: '滴滴出行',
        internalCategoryId: 7,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 共享单车 -> 交通通勤 (7)
      CategoryMapping(
        externalCategory: '共享单车',
        internalCategoryId: 7,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 美团 -> 日常花销 (1)
      CategoryMapping(
        externalCategory: '美团',
        internalCategoryId: 1,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 饿了么 -> 日常花销 (1)
      CategoryMapping(
        externalCategory: '饿了么',
        internalCategoryId: 1,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 餐饮美食 -> 日常花销 (1)
      CategoryMapping(
        externalCategory: '餐饮美食',
        internalCategoryId: 1,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 淘宝天猫 -> 日常花销 (1)
      CategoryMapping(
        externalCategory: '淘宝天猫',
        internalCategoryId: 1,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 生活缴费 -> 生活缴费 (6)
      CategoryMapping(
        externalCategory: '生活缴费',
        internalCategoryId: 6,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 休闲娱乐 -> 兴趣爱好 (4)
      CategoryMapping(
        externalCategory: '休闲娱乐',
        internalCategoryId: 4,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 医疗健康 -> 医疗支出 (8)
      CategoryMapping(
        externalCategory: '医疗健康',
        internalCategoryId: 8,
        sourceType: 'alipay',
        description: '默认映射',
      ),
      // 转账充值 -> 自定义 (999)
      CategoryMapping(
        externalCategory: '转账充值',
        internalCategoryId: 999,
        sourceType: 'alipay',
        description: '不计入收支',
      ),
    ];

    for (final mapping in defaultMappings) {
      final existing = await findMapping(mapping.externalCategory, mapping.sourceType);
      if (existing == null) {
        await saveMapping(mapping);
      }
    }
  }

  /// 初始化默认映射（微信）
  Future<void> initDefaultWechatMappings() async {
    if (_isar == null) return;

    final defaultMappings = [
      // 商户消费 -> 日常花销 (1)
      CategoryMapping(
        externalCategory: '商户消费',
        internalCategoryId: 1,
        sourceType: 'wechat',
        description: '默认映射',
      ),
      // 餐饮美食 -> 日常花销 (1)
      CategoryMapping(
        externalCategory: '餐饮美食',
        internalCategoryId: 1,
        sourceType: 'wechat',
        description: '默认映射',
      ),
      // 交通出行 -> 交通通勤 (7)
      CategoryMapping(
        externalCategory: '交通出行',
        internalCategoryId: 7,
        sourceType: 'wechat',
        description: '默认映射',
      ),
      // 生活缴费 -> 生活缴费 (6)
      CategoryMapping(
        externalCategory: '生活缴费',
        internalCategoryId: 6,
        sourceType: 'wechat',
        description: '默认映射',
      ),
      // 二维码收款 -> 其他收入 (106)
      CategoryMapping(
        externalCategory: '二维码收款',
        internalCategoryId: 106,
        sourceType: 'wechat',
        description: '收入类型',
      ),
      // 红包 -> 礼金 (105)
      CategoryMapping(
        externalCategory: '红包',
        internalCategoryId: 105,
        sourceType: 'wechat',
        description: '默认映射',
      ),
      // 转账 -> 自定义 (999)
      CategoryMapping(
        externalCategory: '转账',
        internalCategoryId: 999,
        sourceType: 'wechat',
        description: '不计入收支',
      ),
    ];

    for (final mapping in defaultMappings) {
      final existing = await findMapping(mapping.externalCategory, mapping.sourceType);
      if (existing == null) {
        await saveMapping(mapping);
      }
    }
  }
}
