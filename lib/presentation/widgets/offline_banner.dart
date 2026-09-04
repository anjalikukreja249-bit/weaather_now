import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/connectivity_helper.dart';

/// Streams connectivity state and shows a banner when the device is offline.
final _isOnlineProvider = StreamProvider<bool>((ref) {
  final helper = ConnectivityHelper(Connectivity());
  return helper.onConnectivityChanged;
});

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(_isOnlineProvider);

    return isOnlineAsync.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        return MaterialBanner(
          backgroundColor: Colors.orange.shade100,
          leading: const Icon(Icons.wifi_off, color: Colors.orange),
          content: const Text(
            'You are offline. Showing cached data.',
            style: TextStyle(color: Colors.orange),
          ),
          actions: const [SizedBox.shrink()],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
