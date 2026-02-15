# 数据导出功能实施计划

## 需求分析
1. 支持导出 CSV 和 JSON 格式
2. 可选择导出时间范围（全部或自定义）
3. 导出文件压缩为 ZIP，使用6位随机数字密码加密
4. 导出记录保存7天，包含时间范围和密码
5. 自动清理超过7天的导出记录

## 实施步骤

### 步骤1: 添加依赖
文件: `pubspec.yaml`
- 添加 archive 包（ZIP压缩和加密）
- 添加 path_provider 包（已存在，用于获取存储路径）
- 添加 share_plus 包（分享文件）

### 步骤2: 创建导出服务
文件: `lib/data/services/export_service.dart`
- 导出CSV功能
- 导出JSON功能
- ZIP压缩加密功能
- 生成6位随机密码

### 步骤3: 创建导出记录模型
文件: `lib/data/models/export_record.dart`
- 导出记录实体类
- 包含：id, 导出时间, 格式类型, 时间范围, 密码, 文件路径

### 步骤4: 创建导出记录Provider
文件: `lib/presentation/providers/export_provider.dart`
- 管理导出记录状态
- 自动清理过期记录
- 添加/查询导出记录

### 步骤5: 创建设置页面中的导出UI
文件: `lib/presentation/screens/settings/export_screen.dart`
- 导出格式选择
- 时间范围选择
- 导出按钮
- 导出记录列表（近7天）

### 步骤6: 更新设置页面
文件: `lib/presentation/screens/settings/settings_screen.dart`
- 添加导出数据入口

### 步骤7: 在数据库服务中注册导出记录模型
文件: `lib/data/repositories/database_service.dart`
- 添加 ExportRecordSchema

## 数据流
1. 用户选择导出格式和时间范围
2. 查询数据库获取交易记录
3. 生成CSV或JSON文件
4. 生成6位随机密码
5. 压缩并加密为ZIP文件
6. 保存导出记录到数据库
7. 清理7天前的记录
8. 分享/保存ZIP文件
