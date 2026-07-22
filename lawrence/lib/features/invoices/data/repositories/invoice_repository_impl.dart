import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository_interface.dart';
import '../datasources/invoice_remote_datasource.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource _remoteDataSource;

  InvoiceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Invoice>> getInvoices() {
    return _remoteDataSource.getInvoices();
  }

  @override
  Future<Invoice> getInvoice(String id) {
    return _remoteDataSource.getInvoice(id);
  }
}
