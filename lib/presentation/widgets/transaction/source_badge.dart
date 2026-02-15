import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Data source badge widget
/// Shows a small badge indicating where the transaction came from (Alipay, WeChat, etc.)
class DataSourceBadge extends StatelessWidget {
  const DataSourceBadge({
    super.key,
    required this.source,
  });

  final String? source;

  @override
  Widget build(BuildContext context) {
    // Only show badge for imported transactions (not manual)
    if (source == null || source == 'manual' || source == '手工记账') {
      return const SizedBox.shrink();
    }

    final badgeConfig = _getBadgeConfig(source!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeConfig.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: badgeConfig.color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeConfig.icon,
            size: 10,
            color: badgeConfig.color,
          ),
          const SizedBox(width: 3),
          Text(
            badgeConfig.label,
            style: TextStyle(
              fontSize: 10,
              color: badgeConfig.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getBadgeConfig(String source) {
    // 检查是否是带设备ID前缀的格式（如 "AB12_支付宝"）
    final devicePrefixPattern = RegExp(r'^([A-Fa-f0-9]{4})_(.+)$');
    final match = devicePrefixPattern.firstMatch(source);

    String actualSource;
    String? deviceIdPrefix;

    if (match != null) {
      deviceIdPrefix = match.group(1);
      actualSource = match.group(2)!;
    } else {
      actualSource = source;
    }

    _BadgeConfig baseConfig;

    switch (actualSource) {
      case '支付宝':
      case 'alipay':
        baseConfig = _BadgeConfig(
          label: deviceIdPrefix != null ? '${deviceIdPrefix}_支付宝' : '支付宝',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF1677FF),
        );
        break;
      case '微信':
      case 'wechat':
        baseConfig = _BadgeConfig(
          label: deviceIdPrefix != null ? '${deviceIdPrefix}_微信' : '微信',
          icon: Icons.chat_bubble,
          color: const Color(0xFF07C160),
        );
        break;
      case '手工记账':
        baseConfig = _BadgeConfig(
          label: deviceIdPrefix != null ? '${deviceIdPrefix}_手工记账' : '手工记账',
          icon: Icons.edit,
          color: AppTheme.onSurfaceVariant,
        );
        break;
      default:
        baseConfig = _BadgeConfig(
          label: deviceIdPrefix != null ? '${deviceIdPrefix}_导入' : '导入',
          icon: Icons.file_upload,
          color: AppTheme.onSurfaceVariant,
        );
    }

    return baseConfig;
  }
}

class _BadgeConfig {
  const _BadgeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
