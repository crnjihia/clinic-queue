// path: apps/mobile/lib/presentation/widgets/kenyan_clinic_tile.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class KenyanClinicTile extends StatelessWidget {
  final String title;
  final String subCounty;
  final bool hasActivePushAlerts;
  final VoidCallback? onTap;

  const KenyanClinicTile({
    super.key,
    required this.title,
    required this.subCounty,
    this.hasActivePushAlerts = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.local_hospital, color: AppColors.primaryTeal, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
          const SizedBox(width: 4),
          Text(subCounty, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
      trailing: hasActivePushAlerts
          ? Tooltip(
              message: 'Live SMS & Push alerts enabled',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, size: 16, color: Colors.green),
              ),
            )
          : null,
    );
  }
}

