import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';

class ConnectionStatusBadge extends StatelessWidget {
  final bool showLabel;
  const ConnectionStatusBadge({Key? key, this.showLabel = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isOnline = provider.isServerOnline;

    final dotColor = isOnline ? AppTheme.accentLeaf : AppTheme.alertRed;
    final labelText = isOnline ? 'Backend Online' : 'Backend Offline';

    return GestureDetector(
      onTap: () {
        provider.checkConnection();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOnline
                  ? 'Connected to ${provider.baseUrl}'
                  : 'Cannot reach server at ${provider.baseUrl}. Check Settings.',
            ),
            backgroundColor: isOnline ? AppTheme.primaryGreen : AppTheme.alertRed,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: dotColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dotColor.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dotColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
