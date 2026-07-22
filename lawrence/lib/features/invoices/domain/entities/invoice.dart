class Invoice {
  final String id;
  final double amountPaid;
  final String currency;
  final String status;
  final String? invoicePdf;
  final String? hostedInvoiceUrl;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.amountPaid,
    required this.currency,
    required this.status,
    this.invoicePdf,
    this.hostedInvoiceUrl,
    required this.createdAt,
  });
}
