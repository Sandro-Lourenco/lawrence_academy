import '../../../../core/network/network_client.dart';
import '../models/invoice_model.dart';

class InvoiceRemoteDataSource {
  final NetworkClient _networkClient;

  InvoiceRemoteDataSource(this._networkClient);

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _networkClient.get('/api/v1/invoices');
    final data = response.data['data'] as List;
    return data.map((json) => InvoiceModel.fromJson(json)).toList();
  }

  Future<InvoiceModel> getInvoice(String id) async {
    final response = await _networkClient.get('/api/v1/invoices/$id');
    return InvoiceModel.fromJson(response.data['data']);
  }
}
