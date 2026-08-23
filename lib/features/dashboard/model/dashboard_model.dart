class DashboardModel {
  final int? code;
  final bool? error;
  final String? msg;
  final String? ipStatus;
  final String? id;
  final String? name;
  final String? role;
  final String? roleId;
  final String? image;
  final String? status;
  final String? appVersion;
  final PlaceOfSupply? placeOfSupply;
  final OverdueSaleBills? overdueSaleBills;
  final Purchase? purchase;
  final Overdue90DaysBills? overdue90DaysBills;
  final Customer? customer;
  final Supplier? supplier;

  DashboardModel({
    this.code,
    this.error,
    this.msg,
    this.ipStatus,
    this.id,
    this.name,
    this.role,
    this.roleId,
    this.image,
    this.status,
    this.appVersion,
    this.placeOfSupply,
    this.overdueSaleBills,
    this.purchase,
    this.overdue90DaysBills,
    this.customer,
    this.supplier,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      code: json['code'],
      error: json['error'],
      msg: json['msg'],
      ipStatus: json['Ipstatus'],
      id: json['id'],
      name: json['name'],
      role: json['role'],
      roleId: json['role_id'],
      image: json['Image'],
      status: json['status'],
      appVersion: json['App_Version'],
      placeOfSupply: json['PlaceofSupply'] != null
          ? PlaceOfSupply.fromJson(json['PlaceofSupply'])
          : null,
      overdueSaleBills: json['OverdueSaleBills'] != null
          ? OverdueSaleBills.fromJson(json['OverdueSaleBills'])
          : null,
      purchase: json['Purchase'] != null
          ? Purchase.fromJson(json['Purchase'])
          : null,
      overdue90DaysBills: json['90DaysOverdueBills'] != null
          ? Overdue90DaysBills.fromJson(json['90DaysOverdueBills'])
          : null,
      customer: json['Customer'] != null
          ? Customer.fromJson(json['Customer'])
          : null,
      supplier: json['Supplier'] != null
          ? Supplier.fromJson(json['Supplier'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'msg': msg,
      'Ipstatus': ipStatus,
      'id': id,
      'name': name,
      'role': role,
      'role_id': roleId,
      'Image': image,
      'status': status,
      'App_Version': appVersion,
      'PlaceofSupply': placeOfSupply?.toJson(),
      'OverdueSaleBills': overdueSaleBills?.toJson(),
      'Purchase': purchase?.toJson(),
      '90DaysOverdueBills': overdue90DaysBills?.toJson(),
      'Customer': customer?.toJson(),
      'Supplier': supplier?.toJson(),
    };
  }
}

// =====================================================
// PLACE OF SUPPLY
// =====================================================

class PlaceOfSupply {
  final String? id;
  final String? name;

  PlaceOfSupply({
    this.id,
    this.name,
  });

  factory PlaceOfSupply.fromJson(Map<String, dynamic> json) {
    return PlaceOfSupply(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// =====================================================
// OVERDUE SALE BILLS
// =====================================================

class OverdueSaleBills {
  final BillData? days15;
  final BillData? days30;
  final BillData? days45;
  final BillData? days60;
  final BillData? days75;
  final BillData? days90;

  OverdueSaleBills({
    this.days15,
    this.days30,
    this.days45,
    this.days60,
    this.days75,
    this.days90,
  });

  factory OverdueSaleBills.fromJson(Map<String, dynamic> json) {
    return OverdueSaleBills(
      days15: json['15Days'] != null
          ? BillData.fromJson(json['15Days'])
          : null,
      days30: json['30Days'] != null
          ? BillData.fromJson(json['30Days'])
          : null,
      days45: json['45Days'] != null
          ? BillData.fromJson(json['45Days'])
          : null,
      days60: json['60Days'] != null
          ? BillData.fromJson(json['60Days'])
          : null,
      days75: json['75Days'] != null
          ? BillData.fromJson(json['75Days'])
          : null,
      days90: json['90Days'] != null
          ? BillData.fromJson(json['90Days'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '15Days': days15?.toJson(),
      '30Days': days30?.toJson(),
      '45Days': days45?.toJson(),
      '60Days': days60?.toJson(),
      '75Days': days75?.toJson(),
      '90Days': days90?.toJson(),
    };
  }
}

// =====================================================
// COMMON BILL DATA
// =====================================================

class BillData {
  final String? bills;
  final String? amount;

  BillData({
    this.bills,
    this.amount,
  });

  factory BillData.fromJson(Map<String, dynamic> json) {
    return BillData(
      bills: json['Bills'],
      amount: json['Amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Bills': bills,
      'Amount': amount,
    };
  }
}

// =====================================================
// PURCHASE
// =====================================================

class Purchase {
  final BillData? challan;
  final BillData? bills;
  final BillData? voucher;
  final BillData? purchaseReturn;

  Purchase({
    this.challan,
    this.bills,
    this.voucher,
    this.purchaseReturn,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      challan: json['Challan'] != null
          ? BillData.fromJson(json['Challan'])
          : null,
      bills: json['Bills'] != null
          ? BillData.fromJson(json['Bills'])
          : null,
      voucher: json['Voucher'] != null
          ? BillData.fromJson(json['Voucher'])
          : null,
      purchaseReturn: json['PurchaseReturn'] != null
          ? BillData.fromJson(json['PurchaseReturn'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Challan': challan?.toJson(),
      'Bills': bills?.toJson(),
      'Voucher': voucher?.toJson(),
      'PurchaseReturn': purchaseReturn?.toJson(),
    };
  }
}

// =====================================================
// 90 DAYS OVERDUE
// =====================================================

class Overdue90DaysBills {
  final String? totalParty;
  final String? totalBills;
  final String? totalAmount;

  Overdue90DaysBills({
    this.totalParty,
    this.totalBills,
    this.totalAmount,
  });

  factory Overdue90DaysBills.fromJson(Map<String, dynamic> json) {
    return Overdue90DaysBills(
      totalParty: json['TotalParty'],
      totalBills: json['TotalBills'],
      totalAmount: json['TotalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalParty': totalParty,
      'TotalBills': totalBills,
      'TotalAmount': totalAmount,
    };
  }
}

// =====================================================
// CUSTOMER
// =====================================================

class Customer {
  final String? pending;
  final String? active;
  final String? inactive;

  Customer({
    this.pending,
    this.active,
    this.inactive,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      pending: json['Pending'],
      active: json['Active'],
      inactive: json['Inactive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pending': pending,
      'Active': active,
      'Inactive': inactive,
    };
  }
}

// =====================================================
// SUPPLIER
// =====================================================

class Supplier {
  final String? pending;
  final String? active;
  final String? inactive;

  Supplier({
    this.pending,
    this.active,
    this.inactive,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      pending: json['Pending'],
      active: json['Active'],
      inactive: json['Inactive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pending': pending,
      'Active': active,
      'Inactive': inactive,
    };
  }
}