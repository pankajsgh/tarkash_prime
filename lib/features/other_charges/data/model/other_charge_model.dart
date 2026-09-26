class OtherChargeModel {
  final String id;
  final String chargeName;
  final String chargeType;
  final String chargeNature;
  final String printName;
  final String defaultValue;
  final String calculationType;
  final String appliedOn;
  final String distributionMethod;
  final String taxTreatment;
  final String hsn;
  final String hsnTax;
  final String allowManualChange;
  final String isActive;
  final String createdAt;
  final String updatedAt;

  OtherChargeModel({
    required this.id,
    required this.chargeName,
    required this.chargeType,
    required this.chargeNature,
    required this.printName,
    required this.defaultValue,
    required this.calculationType,
    required this.appliedOn,
    required this.distributionMethod,
    required this.taxTreatment,
    required this.hsn,
    required this.hsnTax,
    required this.allowManualChange,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OtherChargeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OtherChargeModel(
      id: json['id']?.toString() ?? '',

      chargeName:
      json['charge_name']?.toString() ?? '',

      chargeType:
      json['charge_type']?.toString() ?? '',

      chargeNature:
      json['charge_nature']?.toString() ?? '',

      printName:
      json['print_name']?.toString() ?? '',

      defaultValue:
      json['default_value']?.toString() ?? '',

      calculationType:
      json['calculation_type']?.toString() ?? '',

      appliedOn:
      json['applied_on']?.toString() ?? '',

      distributionMethod:
      json['distribution_method']?.toString() ?? '',

      taxTreatment:
      json['tax_treatment']?.toString() ?? '',

      hsn:
      json['hsn']?.toString() ?? '',
      hsnTax:
      json['hsn_tax']?.toString() ?? '',

      allowManualChange:
      json['allow_manual_change']?.toString() ?? '',

      isActive:
      json['is_active']?.toString() ?? '',

      createdAt:
      json['created_at']?.toString() ?? '',

      updatedAt:
      json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'charge_name': chargeName,
      'charge_type': chargeType,
      'charge_nature': chargeNature,
      'print_name': printName,
      'default_value': defaultValue,
      'calculation_type': calculationType,
      'applied_on': appliedOn,
      'distribution_method': distributionMethod,
      'tax_treatment': taxTreatment,
      'hsn': hsn,
      'allow_manual_change': allowManualChange,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}