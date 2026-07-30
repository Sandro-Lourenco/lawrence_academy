import 'package:flutter/material.dart';

import '../../../courses/presentation/pages/catalog_page.dart';

/// A busca autenticada usa o mesmo read model e os mesmos filtros do catálogo.
/// Assim os resultados não divergem do conteúdo realmente publicado.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => const CatalogPage();
}
