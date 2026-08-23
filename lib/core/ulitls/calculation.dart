
double calculatePriceAfterDiscount({required double price, required double discount,}) {
  return price - (price * discount / 100);
}

double calculatePriceAfterText({required double price, required double discount,}) {
  return price + (price * discount / 100);
}

double textToDouble(String value) {
  if(value.isEmpty)
    {
      return 0;
    }
  return double.tryParse(value.trim()) ?? 0.0;
}

String getTaxByPrice({
  required double price,
  required String priceFrom,
  required String priceTo,
  required String tax,
}) {
  final from = double.tryParse(priceFrom) ?? 0.0;
  final to = double.tryParse(priceTo) ?? 0.0;

  if (price >= from && price <= to) {
    return tax;
  }

  return '0';
}

List<double> distributeProportionally(
{ required double totalAmount,
  required List<double> proportions,}
    ) {
  final total = proportions.fold<double>(
    0,
        (sum, value) => sum + value,
  );

  if (total == 0) {
    return List.filled(proportions.length, 0);
  }

  return proportions
      .map((value) => totalAmount * value / total)
      .toList();
}