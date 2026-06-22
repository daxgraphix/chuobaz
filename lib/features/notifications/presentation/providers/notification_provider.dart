import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/notification_repository.dart';

final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository(ref.watch(supabaseClientProvider)));

class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotificationModel>>> {
  final NotificationRepository _repo;
  final String? _userId;

  NotificationsNotifier(this._repo, this._userId) : super(const AsyncValue.loading()) {
    load();
    if (_userId != null) {
      _repo.subscribe(_userId, (notif) {
        final current = state.valueOrNull ?? [];
        state = AsyncValue.data([notif, ...current]);
      });
    }
  }

  Future<void> load() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    final result = await _repo.getNotifications(_userId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (list) => AsyncValue.data(list),
    );
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data([
      for (final n in current)
        if (n.id == id)
          AppNotificationModel(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              body: n.body,
              targetId: n.targetId,
              targetType: n.targetType,
              isRead: true,
              createdAt: n.createdAt)
        else
          n
    ]);
  }

  Future<void> markAllRead() async {
    if (_userId == null) return;
    await _repo.markAllRead(_userId);
    await load();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotificationModel>>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider), userId);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});
