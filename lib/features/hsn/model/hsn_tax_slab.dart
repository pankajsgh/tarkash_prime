class HsnTaxSlabModel {
  double priceFrom;
  double priceTo;
  double tax;
  String slabsDate;

  HsnTaxSlabModel({
    required this.priceFrom,
    required this.priceTo,
    required this.tax,
    required this.slabsDate,
  });

  factory HsnTaxSlabModel.fromJson(Map<String, dynamic> json) {
    return HsnTaxSlabModel(
      priceFrom: double.tryParse(
        json['PriceFrom'].toString(),
      ) ??
          0,
      priceTo: double.tryParse(
        json['PriceTo'].toString(),
      ) ??
          0,
      tax: double.tryParse(
        json['Tax'].toString(),
      ) ??
          0,
      slabsDate: json['SlabsDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'PriceFrom': priceFrom.toString(),
    'PriceTo': priceTo.toString(),
    'Tax': tax.toString(),
    'SlabsDate': slabsDate,
  };
}

class HsnModelItem {
  final String id;
  String hsncode;
  List<HsnTaxSlabModel> hsnTaxSlabs;

  HsnModelItem({
    required this.id,
    required this.hsncode,
    List<HsnTaxSlabModel>? hsnTaxSlabs,
  }) : hsnTaxSlabs = hsnTaxSlabs ?? [];

  factory HsnModelItem.fromJson(Map<String, dynamic> json) {
    final slabs = json['HSNTaxSlab'] as List? ?? [];

    return HsnModelItem(
      id: json['id']?.toString() ?? '',
      hsncode: json['hsncode']?.toString() ?? '',
      hsnTaxSlabs: slabs
          .map(
            (item) => HsnTaxSlabModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hsncode': hsncode,
    'HSNTaxSlab':
    hsnTaxSlabs.map((slab) => slab.toJson()).toList(),
  };
}