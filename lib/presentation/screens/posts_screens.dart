import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/load_error_view.dart';
import '../widgets/spec_ui.dart';

/// "نصائح أخصائيتك" — `GET /me/posts?page=N`, in the server's order (pinned
/// first, then newest), 20 a page, the next page loaded near the end.
/// Bodies are plain text: never read as HTML or links.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late final PostsRepository _repository =
      context.read<AppDependencies>().posts;
  final ScrollController _scroll = ScrollController();

  final List<Post> _posts = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _loadMore();
    });
    _refresh();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _page = 0;
    _hasMore = true;
    await _loadMore(replace: true);
  }

  Future<void> _loadMore({bool replace = false}) async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _failure = null;
    });
    final result = await _repository.getPage(_page + 1);
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.when(
        success: (page) {
          if (replace) _posts.clear();
          final known = _posts.map((p) => p.id).toSet();
          _posts.addAll(page.posts.where((p) => !known.contains(p.id)));
          _page = page.page;
          _hasMore = page.hasMore && page.posts.isNotEmpty;
        },
        failure: (failure) => _failure = failure,
      );
    });
  }

  Future<void> _open(Post post) async {
    await Navigator.of(context).push(AppPageRoute(
        builder: (_) => PostDetailScreen(postId: post.id, initial: post)));
    if (!mounted) return;
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i >= 0) setState(() => _posts[i] = _posts[i].markedRead());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Widget body;
    if (_posts.isEmpty && _loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_posts.isEmpty && _failure != null) {
      body = LoadErrorView(
          message: loadFailureMessage(context, _failure), onRetry: _refresh);
    } else if (_posts.isEmpty) {
      body = Center(
        child: SpecEmptyState(
            icon: Icons.lightbulb_outline_rounded, title: l10n.postsEmpty),
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => i == _posts.length
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()))
              : _PostCard(post: _posts[i], onTap: () => _open(_posts[i])),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.postsTitle),
      body: SafeArea(child: body),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final published = post.publishedAt;
    return SpecCard(
      onTap: onTap,
      highlighted: !post.isRead,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (post.pinned) ...[
                Icon(Icons.push_pin_rounded,
                    size: 16,
                    color: AppColors.primary,
                    semanticLabel: l10n.postsPinned),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(post.title,
                    style: AppTextStyles.cardTitle.copyWith(height: 1.4)),
              ),
            ],
          ),
          if (post.body.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(post.body.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textSecondary, height: 1.5)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (!post.isRead) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(l10n.postsNew,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryInk, fontWeight: FontWeight.w700)),
                if (published != null)
                  const Text(' • ', style: AppTextStyles.tiny),
              ],
              if (published != null)
                Text(relativeDayLabel(context, published),
                    style: AppTextStyles.tiny),
            ],
          ),
        ],
      ),
    );
  }
}

/// One post — `GET /me/posts/{id}`. `read` is sent once on opening (safe to
/// repeat). Blank lines in the body are kept. A 404 (withdrawn, or no longer
/// for this patient) says so and goes back.
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId, this.initial});

  final int postId;

  /// The list's copy, shown while the full post loads.
  final Post? initial;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostsRepository _repository =
      context.read<AppDependencies>().posts;
  late Post? _post = widget.initial;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _repository.getPost(widget.postId);
    if (!mounted) return;
    final failure = result.failureOrNull;
    if (failure is NotFoundFailure) {
      showSpecSnack(context, context.l10n.postUnavailable);
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _post = result.valueOrNull ?? _post;
      _failure = failure;
    });
    if (failure == null && _post?.isRead == false) {
      await _repository.markRead(widget.postId);
      if (mounted) context.read<PostsUnreadCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final post = _post;
    final Widget body;
    if (post == null) {
      body = _failure == null
          ? const Center(child: CircularProgressIndicator())
          : LoadErrorView(
              message: loadFailureMessage(context, _failure), onRetry: _load);
    } else {
      final published = post.publishedAt;
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          SpecCard(
            child: SpecColumn(
              children: [
                Row(
                  children: [
                    const SpecIconTile(Icons.lightbulb_outline_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        [
                          l10n.postFromNutritionist,
                          if (published != null)
                            relativeDayLabel(context, published),
                        ].join(' • '),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    if (post.pinned)
                      const Icon(Icons.push_pin_rounded,
                          size: 18, color: AppColors.primary),
                  ],
                ),
                Semantics(
                  header: true,
                  child: Text(post.title,
                      style:
                          AppTextStyles.sectionHeading.copyWith(height: 1.4)),
                ),
                // Plain text with its blank lines; selectable for copying.
                SelectableText(post.body,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w400, height: 1.7)),
              ],
            ),
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.postsTitle),
      body: SafeArea(child: body),
    );
  }
}
