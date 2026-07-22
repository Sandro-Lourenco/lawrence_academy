import '../entities/invoice.dart';
import '../repositories/invoice_repository_interface.dart';

class GetInvoicesUseCase {
  final InvoiceRepository _repository;

  GetInvoicesUseCase(this._repository);

  Future<List<Invoice>> execute() {
    return _repository.getInvoices();
  }
}
