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
            LawrenceSpacing.lg,
            horizontalPadding,
            LawrenceSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudentPageHeader(
                title: title,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
              ),
              const SizedBox(height: LawrenceSpacing.xl),
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

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      body: scrollable
          ? onRefresh == null
                ? scrollView
                : RefreshIndicator(
                    color: LawrenceColors.actionPrimary,
                    onRefresh: onRefresh!,
                    child: scrollView,
                  )
          : content,
    );
  }
}
