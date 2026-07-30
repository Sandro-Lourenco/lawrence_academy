import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';

class LessonContentBlock {
  const LessonContentBlock({
    required this.id,
    required this.type,
    required this.content,
    this.orderIndex = 0,
  });

  final String id;
  final String type;
  final Map<String, dynamic> content;
  final int orderIndex;

  factory LessonContentBlock.fromJson(Map<String, dynamic> json) {
    return LessonContentBlock(
      id: json['id']?.toString() ?? '',
      type: (json['block_type'] ?? json['type'])?.toString() ?? 'text',
      content: Map<String, dynamic>.from(
        json['content'] as Map? ?? const <String, dynamic>{},
      ),
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class LessonContentRenderer extends StatelessWidget {
  const LessonContentRenderer({
    super.key,
    required this.blocks,
    this.isPreview = false,
  });

  final List<LessonContentBlock> blocks;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(LawrenceSpacing.lg),
          child: Text('Nenhum conteúdo complementar disponível nesta aula.'),
        ),
      );
    }
    final ordered = [...blocks]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return Semantics(
      container: true,
      label: 'Conteúdo da aula',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final block in ordered) ...[
            _BlockView(block: block, isPreview: isPreview),
            const SizedBox(height: LawrenceSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.isPreview});

  final LessonContentBlock block;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final content = block.content;
    final title = content['title']?.toString().trim() ?? '';
    final text = content['text']?.toString().trim() ?? '';
    switch (block.type) {
      case 'heading':
        return Text(
          title.isNotEmpty ? title : text,
          style: Theme.of(context).textTheme.headlineSmall,
        );
      case 'text':
        return SelectableText(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        );
      case 'notice':
      case 'tip':
      case 'summary':
        return _Callout(
          icon: block.type == 'tip'
              ? Icons.lightbulb_outline
              : block.type == 'summary'
              ? Icons.summarize_outlined
              : Icons.info_outline,
          title: title.isNotEmpty
              ? title
              : block.type == 'tip'
              ? 'Dica'
              : block.type == 'summary'
              ? 'Resumo'
              : 'Aviso',
          text: text,
        );
      case 'learn_more':
        return _LearnMore(content: content);
      case 'image':
      case 'gallery':
        return _ImageBlock(content: content);
      case 'activity':
        return _ActivityBlock(content: content, isPreview: isPreview);
      case 'video':
      case 'audio':
        return _MediaBlock(type: block.type, content: content);
      case 'pdf':
      case 'download':
      case 'material':
        return _DownloadBlock(type: block.type, content: content);
      default:
        return _Callout(
          icon: Icons.extension_outlined,
          title: title.isNotEmpty ? title : 'Conteúdo',
          text: text,
        );
    }
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(LawrenceSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LawrenceColors.primary),
          const SizedBox(width: LawrenceSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (text.isNotEmpty) ...[
                  const SizedBox(height: LawrenceSpacing.sm),
                  SelectableText(text),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LearnMore extends StatelessWidget {
  const _LearnMore({required this.content});

  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final title = content['title']?.toString().trim();
    final text = content['text']?.toString().trim() ?? '';
    return Card(
      color: LawrenceColors.primary.withValues(alpha: .08),
      child: ExpansionTile(
        leading: const Icon(Icons.auto_stories_outlined),
        title: Text(title?.isNotEmpty == true ? title! : 'Saiba mais'),
        subtitle: const Text('Conteúdo complementar'),
        childrenPadding: const EdgeInsets.fromLTRB(
          LawrenceSpacing.lg,
          0,
          LawrenceSpacing.lg,
          LawrenceSpacing.lg,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (text.isNotEmpty) SelectableText(text),
          if (_safeUri(content['url']) case final uri?) ...[
            const SizedBox(height: LawrenceSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () =>
                    launchUrl(uri, mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  content['button_label']?.toString().trim().isNotEmpty == true
                      ? content['button_label'].toString()
                      : 'Abrir referência externa',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock({required this.content});

  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final uri = _safeUri(content['url']);
    final alt = content['alt_text']?.toString().trim() ?? '';
    final caption = content['caption']?.toString().trim() ?? '';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (uri != null)
            Semantics(
              image: true,
              label: alt,
              child: Image.network(
                uri.toString(),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const _MediaUnavailable(),
              ),
            )
          else
            const _MediaUnavailable(),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(LawrenceSpacing.md),
              child: Text(caption),
            ),
        ],
      ),
    );
  }
}

class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.type, required this.content});

  final String type;
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) => _Callout(
    icon: type == 'audio' ? Icons.audiotrack : Icons.play_circle_outline,
    title: content['title']?.toString().trim().isNotEmpty == true
        ? content['title'].toString()
        : type == 'audio'
        ? 'Áudio'
        : 'Vídeo complementar',
    text: content['filename']?.toString() ?? 'Mídia protegida da aula',
  );
}

class _DownloadBlock extends StatelessWidget {
  const _DownloadBlock({required this.type, required this.content});

  final String type;
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final uri = _safeUri(content['url']);
    return Card(
      child: ListTile(
        leading: Icon(
          type == 'pdf' ? Icons.picture_as_pdf_outlined : Icons.download,
        ),
        title: Text(
          content['title']?.toString().trim().isNotEmpty == true
              ? content['title'].toString()
              : content['filename']?.toString() ?? 'Material da aula',
        ),
        subtitle: const Text('Arquivo complementar'),
        trailing: const Icon(Icons.open_in_new),
        enabled: uri != null,
        onTap: uri == null
            ? null
            : () => launchUrl(uri, mode: LaunchMode.externalApplication),
      ),
    );
  }
}

class _ActivityBlock extends StatelessWidget {
  const _ActivityBlock({required this.content, required this.isPreview});

  final Map<String, dynamic> content;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final items = (content['items'] as List? ?? const [])
        .map((item) => item.toString())
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Atividade', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: LawrenceSpacing.sm),
            Text(
              content['question']?.toString() ?? 'Atividade sem enunciado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final item in items)
              RadioListTile<String>(
                value: item,
                groupValue: null,
                onChanged: isPreview ? (_) {} : null,
                title: Text(item),
              ),
            if (isPreview)
              const Text(
                'Modo de prévia: respostas e envios não são registrados.',
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaUnavailable extends StatelessWidget {
  const _MediaUnavailable();

  @override
  Widget build(BuildContext context) => const AspectRatio(
    aspectRatio: 16 / 9,
    child: ColoredBox(
      color: LawrenceColors.surfaceBlack,
      child: Center(
        child: Text(
          'Mídia indisponível para prévia',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    ),
  );
}

Uri? _safeUri(Object? value) {
  final uri = Uri.tryParse(value?.toString() ?? '');
  return uri != null && uri.scheme == 'https' ? uri : null;
}
