import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider(_query));
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Search posts, people, communities...', border: InputBorder.none),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: _query.isEmpty
          ? const EmptyState(icon: Icons.search, title: 'Search ChuoBaz', subtitle: 'Find posts, people, communities, resources, and listings')
          : resultsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('$e')),
              data: (results) {
                if (results.isEmpty) {
                  return const EmptyState(icon: Icons.search_off_rounded, title: 'No results found');
                }
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (results.posts.isNotEmpty) _Section(
                      title: 'Posts',
                      items: results.posts.map((p) => ListTile(
                        title: Text(p['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        leading: const Icon(Icons.article_outlined),
                        onTap: () => context.push('/posts/${p['id']}'),
                      )).toList(),
                    ),
                    if (results.users.isNotEmpty) _Section(
                      title: 'People',
                      items: results.users.map((u) => ListTile(
                        title: Text(u['display_name'] ?? u['username'] ?? ''),
                        subtitle: Text('@${u['username']}'),
                        leading: const Icon(Icons.person_outline),
                        onTap: () => context.push('/profile/${u['id']}'),
                      )).toList(),
                    ),
                    if (results.communities.isNotEmpty) _Section(
                      title: 'Communities',
                      items: results.communities.map((c) => ListTile(
                        title: Text(c['name'] ?? ''),
                        leading: const Icon(Icons.groups_outlined),
                        onTap: () => context.push('/communities/${c['id']}'),
                      )).toList(),
                    ),
                    if (results.resources.isNotEmpty) _Section(
                      title: 'Academic Resources',
                      items: results.resources.map((r) => ListTile(
                        title: Text(r['title'] ?? ''),
                        subtitle: Text(r['course_code'] ?? ''),
                        leading: const Icon(Icons.menu_book_outlined),
                        onTap: () => context.push('/academic/${r['id']}'),
                      )).toList(),
                    ),
                    if (results.listings.isNotEmpty) _Section(
                      title: 'Marketplace',
                      items: results.listings.map((l) => ListTile(
                        title: Text(l['title'] ?? ''),
                        subtitle: Text('TZS ${l['price']}'),
                        leading: const Icon(Icons.storefront_outlined),
                        onTap: () => context.push('/marketplace/${l['id']}'),
                      )).toList(),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(8, 12, 8, 4), child: Text(title, style: AppTextStyles.h3)),
        ...items,
      ],
    );
  }
}
