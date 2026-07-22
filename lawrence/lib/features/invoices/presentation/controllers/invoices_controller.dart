import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/invoice.dart';
import '../providers/invoices_providers.dart';

class InvoicesController extends AutoDisposeAsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() async {
    return _fetchInvoices();
  }

  Future<List<Invoice>> _fetchInvoices() async {
    final useCase = ref.watch(getInvoicesUseCaseProvider);
    return useCase.execute();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchInvoices());
  }
}

final invoicesControllerProvider =
    AsyncNotifierProvider.autoDispose<InvoicesController, List<Invoice>>(
      InvoicesController.new,
    );
