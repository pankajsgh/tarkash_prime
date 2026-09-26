class PartyModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<Party> partyList;

  PartyModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.partyList,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      partyList: (json['PartyList'] as List?)
          ?.map((e) => Party.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'PartyList': partyList.map((e) => e.toJson()).toList(),
    };
  }
}

class Party {
  final String id;
  final String customerCode;
  final String userType;
  final String company;
  final String name;
  final String mobile;
  final String gstNo;
  final String status;
  final String address;
  final String pincode;
  final City city;
  final StateModel state;
  final Transport transport;
  final Agency agency;
  final List<BrandItem> brandList;


  Party({
    required this.id,
    required this.customerCode,
    required this.userType,
    required this.company,
    required this.name,
    required this.mobile,
    required this.gstNo,
    required this.status,
    required this.address,
    required this.pincode,
    required this.city,
    required this.state,
    required this.transport,
    required this.agency,
    required this.brandList
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id']?.toString() ?? '',
      customerCode: json['Customer_Code']?.toString() ?? '',
      userType: json['UserType']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      gstNo: json['GSTNo']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      address: json['Address']?.toString() ?? '',
      pincode: json['Pincode']?.toString() ?? '',
      city: City.fromJson(json['City'] ?? {}),
      state: StateModel.fromJson(json['State'] ?? {}),
      transport: Transport.fromJson(json['Transport'] ?? {}),
      agency: Agency.fromJson(json['Agency'] ?? {}),
      brandList: (json['BrandList'] as List?)
          ?.map((e) => BrandItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Customer_Code': customerCode,
      'UserType': userType,
      'company': company,
      'name': name,
      'mobile': mobile,
      'GSTNo': gstNo,
      'status': status,
      'Address': address,
      'Pincode': pincode,
      'City': city.toJson(),
      'State': state.toJson(),
      'Transport': transport.toJson(),
      'Agency': agency.toJson(),
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
      name: json['Agent']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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
      brand: json['Brand']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Brand': brand,
    };
  }
}