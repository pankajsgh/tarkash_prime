
class Party {
  final String id;
  final String customerCode;
  final String userType;
  final String partyType;
  final String partyTypeName;
  final String company;
  final String printName;
  final String name;
  final String mobile;
  final String gstNo;
  final String status;
  final String address;
  final String pincode;
  final City? city;
  final String discount;
  final StateModel? state;
  Transport? transport;
  Agency? agency;
  String mrp;
  String wholesale;
  String retail;
  final List<BrandItem> brandList;
  final List<CategoryMargin> categoryMargins;

  Party({
    required this.id,
    required this.customerCode,
    required this.userType,
    this.partyTypeName = '',
    required this.company,
    required this.printName,
    required this.name,
    required this.mobile,
    required this.gstNo,
    required this.status,
    required this.address,
    required this.pincode,
    required this.discount,
    required this.partyType,
    this.city,
    this.state,
    this.transport,
    this.agency,
    this.brandList = const [],
    this.categoryMargins = const [],
    this.mrp = '',
    this.retail = '',
    this.wholesale = '',
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id']?.toString() ?? '',
      customerCode: json['Customer_Code']?.toString() ?? '',
      userType: json['UserType']?.toString() ?? '',
      partyType: json['PartyType']?.toString() ?? '',
      partyTypeName: json['PartyTypeName']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      printName: json['printName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      gstNo: json['GSTNo']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      address: json['Address']?.toString() ?? '',
      pincode: json['Pincode']?.toString() ?? '',
      discount: json['Discount']?.toString() ?? '',
      city: City.fromJson(
        Map<String, dynamic>.from(
          json['City'] is Map ? json['City'] : {},
        ),
      ),
      state: StateModel.fromJson(
        Map<String, dynamic>.from(
          json['State'] is Map ? json['State'] : {},
        ),
      ),
      transport: Transport.fromJson(
        Map<String, dynamic>.from(
          json['Transport'] is Map ? json['Transport'] : {},
        ),
      ),
      agency: Agency.fromJson(
        Map<String, dynamic>.from(
          json['Agency'] is Map ? json['Agency'] : {},
        ),
      ),
      mrp: json['mrp']?.toString() ?? '',
      wholesale: json['wholesale']?.toString() ?? '',
      retail: json['retail']?.toString() ?? '',
      brandList: (json['BrandList'] as List?)
          ?.map((e) => BrandItem.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList() ??
          [],
      categoryMargins: (json['CategoryMargins'] as List?)
          ?.map((e) => CategoryMargin.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Customer_Code': customerCode,
      'UserType': userType,
      'PartyType': partyType,
      'PartyTypeName': partyTypeName,
      'company': company,
      'printName': printName,
      'name': name,
      'mobile': mobile,
      'GSTNo': gstNo,
      'status': status,
      'Address': address,
      'Discount': discount,
      'Pincode': pincode,
      'mrp': mrp,
      'wholesale': wholesale,
      'retail': retail,
      'City': city?.toJson(),
      'State': state?.toJson(),
      'Transport': transport?.toJson(),
      'Agency': agency?.toJson(),
      'BrandList': brandList.map((e) => e.toJson()).toList(),
      'CategoryMargins':
      categoryMargins.map((e) => e.toJson()).toList(),
    };
  }
}

class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class StateModel {
  final String id;
  final String name;

  StateModel({
    required this.id,
    required this.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Transport {
  final String id;
  final String name;

  Transport({
    required this.id,
    required this.name,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Agency {
  final String id;
  final String name;

  Agency({
    required this.id,
    required this.name,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id']?.toString() ?? '',
      name: json['Agent']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Agent': name,
    };
  }
}

class BrandItem {
  final String id;
  final String brand;

  BrandItem({
    required this.id,
    required this.brand,
  });

  factory BrandItem.fromJson(Map<String, dynamic> json) {
    return BrandItem(
      id: json['id']?.toString() ?? '',
      brand: json['Brand']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Brand': brand,
    };
  }
}

class CategoryMargin {
  final String id;
  final String partyId;
  final String categoryId;
  final String mrp;
  final String wholesale;
  final String retail;

  CategoryMargin({
    required this.id,
    required this.partyId,
    required this.categoryId,
    required this.mrp,
    required this.wholesale,
    required this.retail,
  });

  factory CategoryMargin.fromJson(Map<String, dynamic> json) {
    return CategoryMargin(
      id: json['id']?.toString() ?? '',
      partyId: json['party_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      mrp: json['mrp']?.toString() ?? '',
      wholesale: json['wholesale']?.toString() ?? '',
      retail: json['retail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'party_id': partyId,
      'category_id': categoryId,
      'mrp': mrp,
      'wholesale': wholesale,
      'retail': retail,
    };
  }
}

