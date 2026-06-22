import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import 'app_shell.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';

import '../../features/feed/presentation/screens/home_feed_screen.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../features/posts/presentation/screens/post_detail_screen.dart';
import '../../features/posts/presentation/screens/edit_post_screen.dart';

import '../../features/communities/presentation/screens/communities_list_screen.dart';
import '../../features/communities/presentation/screens/community_detail_screen.dart';
import '../../features/communities/presentation/screens/community_search_screen.dart';

import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/marketplace/presentation/screens/listing_detail_screen.dart';
import '../../features/marketplace/presentation/screens/create_listing_screen.dart';

import '../../features/academic/presentation/screens/academic_hub_screen.dart';
import '../../features/academic/presentation/screens/resource_detail_screen.dart';
import '../../features/academic/presentation/screens/upload_resource_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/messaging/presentation/screens/conversations_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/moderation/presentation/screens/report_screen.dart';
import '../../features/moderation/presentation/screens/moderation_dashboard_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/user_management_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: false,
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final isAuthRoute = ['/login', '/register', '/forgot-password', '/verify-email']
          .any((p) => state.matchedLocation.startsWith(p));
      if (authState.isLoading) return null;
      if (!authState.isAuthenticated && !isAuthRoute) return '/login';
      if (authState.isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeFeedScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/communities',
              builder: (_, __) => const CommunitiesListScreen(),
              routes: [
                GoRoute(path: 'search', builder: (_, __) => const CommunitySearchScreen()),
                GoRoute(path: ':id', builder: (_, state) => CommunityDetailScreen(communityId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/marketplace',
              builder: (_, __) => const MarketplaceScreen(),
              routes: [
                GoRoute(path: 'create', builder: (_, __) => const CreateListingScreen()),
                GoRoute(path: ':id', builder: (_, state) => ListingDetailScreen(listingId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/academic',
              builder: (_, __) => const AcademicHubScreen(),
              routes: [
                GoRoute(path: 'upload', builder: (_, __) => const UploadResourceScreen()),
                GoRoute(path: ':id', builder: (_, state) => ResourceDetailScreen(resourceId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen(), routes: [
              GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
            ]),
          ]),
        ],
      ),

      GoRoute(path: '/profile/:id', builder: (_, state) => ProfileScreen(userId: state.pathParameters['id'])),
      GoRoute(
        path: '/create-post',
        builder: (_, state) => CreatePostScreen(communityId: state.uri.queryParameters['communityId']),
      ),
      GoRoute(path: '/posts/:id', builder: (_, state) => PostDetailScreen(postId: state.pathParameters['id']!)),
      GoRoute(path: '/posts/:id/edit', builder: (_, state) => EditPostScreen(postId: state.pathParameters['id']!)),

      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/messages', builder: (_, __) => const ConversationsScreen()),
      GoRoute(
        path: '/messages/:id',
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
          otherUsername: state.uri.queryParameters['otherUsername'],
        ),
      ),
      GoRoute(
        path: '/report',
        builder: (_, state) => ReportScreen(
          targetId: state.uri.queryParameters['targetId']!,
          targetType: state.uri.queryParameters['targetType'] ?? 'post',
        ),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

      // Moderator / Admin-only routes. Access is also enforced via Supabase
      // RLS server-side — these client checks are a UX convenience only.
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          final role = authState.user?.role;
          if (role == null || !role.canModerate) return '/home';
          return null;
        },
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/moderation',
        redirect: (context, state) {
          final role = authState.user?.role;
          if (role == null || !role.canModerate) return '/home';
          return null;
        },
        builder: (_, __) => const ModerationDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        redirect: (context, state) {
          if (authState.user?.role != UserRole.superAdmin) return '/home';
          return null;
        },
        builder: (_, __) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        redirect: (context, state) {
          if (authState.user?.role != UserRole.superAdmin) return '/home';
          return null;
        },
        builder: (_, __) => const UserManagementScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});

/// Bridges Riverpod's AuthState stream into a Listenable so GoRouter
/// re-evaluates `redirect` whenever auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
