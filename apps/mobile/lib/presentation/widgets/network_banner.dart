// path: apps/mobile/lib/presentation/widgets/network_banner.dart
import 'package:flutter/material.dart';

class NetworkBanner extends StatelessWidget {
  final bool isOffline;
  final String? message;

  const NetworkBanner({
    super.key,
    required this.isOffline,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.amber.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'Offline mode active. Showing cached queue data.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

