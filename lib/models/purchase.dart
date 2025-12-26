class Purchase {
  final String id;
  final String planName;
  final String planCategory;
  final int quantity;
  final int pricePerUnit;
  final int totalPrice;
  final int tax;
  final int grandTotal;
  final String paymentMethod;
  final String status; // 'completed', 'pending', 'cancelled'
  final DateTime purchaseDate;
  final String invoiceNumber;

  Purchase({
    required this.id,
    required this.planName,
    required this.planCategory,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.tax,
    required this.grandTotal,
    required this.paymentMethod,
    required this.status,
    required this.purchaseDate,
    required this.invoiceNumber,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'planCategory': planCategory,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'tax': tax,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'status': status,
      'purchaseDate': purchaseDate.toIso8601String(),
      'invoiceNumber': invoiceNumber,
    };
  }

  // Create from JSON
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      planCategory: json['planCategory'] ?? '',
      quantity: json['quantity'] ?? 1,
      pricePerUnit: json['pricePerUnit'] ?? 0,
      totalPrice: json['totalPrice'] ?? 0,
      tax: json['tax'] ?? 0,
      grandTotal: json['grandTotal'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'Credit Card',
      status: json['status'] ?? 'completed',
      purchaseDate: DateTime.parse(json['purchaseDate'] ?? DateTime.now().toIso8601String()),
      invoiceNumber: json['invoiceNumber'] ?? '',
    );
  }
}
