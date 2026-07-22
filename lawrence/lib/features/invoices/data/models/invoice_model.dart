import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.amountPaid,
    required super.currency,
    required super.status,
    super.invoicePdf,
    super.hostedInvoiceUrl,
    required super.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      amountPaid: (json['amount_paid'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'BRL',
      status: json['status'] ?? 'unknown',
      invoicePdf: json['invoice_pdf'],
      hostedInvoiceUrl: json['hosted_invoice_url'],
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : DateTime.now(),
    );
  }
}
