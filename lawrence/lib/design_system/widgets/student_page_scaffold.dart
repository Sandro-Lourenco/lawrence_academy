import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';
import 'student_page_header.dart';

class StudentPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;
  final double maxContentWidth;
  final bool scrollable;
  final Future<void> Function()? onRefresh;
  final bool showHeader;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const StudentPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.maxContentWidth = 1280,
    this.scrollable = true,
    this.onRefresh,
    this.showHeader = true,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < LawrenceBreakpoints.mobileWide
        ? LawrenceSpacing.md
        : LawrenceSpacing.lg;

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            width >= LawrenceBreakpoints.desktop
                ? LawrenceSpacing.xxxl
                : LawrenceSpacing.xl,
            horizontalPadding,
            LawrenceSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader) ...[
                StudentPageHeader(
                  title: title,
                  subtitle: subtitle,
                  leading: leading,
                  actions: actions,
                ),
                const SizedBox(height: LawrenceSpacing.xl),
              ],
              body,
            ],
          ),
        ),
      ),
    );

    final scrollView = SingleChildScrollView(
      physics: onRefresh == null
          ? const ClampingScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      child: content,
    );

    final pageBody = scrollable
        ? onRefresh == null
              ? scrollView
              : RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: onRefresh!,
                  child: scrollView,
                )
        : content;

    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: pageBody,
    );
  }
}
