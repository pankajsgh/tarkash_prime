
class TeamMember {
  final String id;
  final String roleId;
  final String employeeCode;
  final String name;
  final String loginMobile;
  final String rateTypeAccess;
  final String address;
  final String remarks;
  final String status;
  final String storeId;
  final String createdAt;
  final String updatedAt;
  final String mobile;
  final String otp;
  final String deviceId;
  final String designation;
  final String department;
  final String level;
  final String role;
  final String salary;
  final String ipLoginStatus;
  final String roleName;

  const TeamMember({
    required this.id,
    required this.roleId,
    required this.employeeCode,
    required this.name,
    required this.loginMobile,
    required this.rateTypeAccess,
    required this.address,
    required this.remarks,
    required this.status,
    required this.storeId,
    required this.createdAt,
    required this.updatedAt,
    required this.mobile,
    required this.otp,
    required this.deviceId,
    required this.designation,
    required this.department,
    required this.level,
    required this.role,
    required this.salary,
    required this.ipLoginStatus,
    required this.roleName,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    String value(String key) => json[key]?.toString() ?? '';

    return TeamMember(
      id: value('id'),
      roleId: value('role_id'),
      employeeCode: value('employee_code'),
      name: value('name'),
      loginMobile: value('login_mobile'),
      rateTypeAccess: value('rate_type_access'),
      address: value('address'),
      remarks: value('remarks'),
      status: value('status'),
      storeId: value('store_id'),
      createdAt: value('created_at'),
      updatedAt: value('updated_at'),
      mobile: value('mobile'),
      otp: value('otp'),
      deviceId: value('device_id'),
      designation: value('designation'),
      department: value('department'),
      level: value('level'),
      role: value('role'),
      salary: value('salary'),
      ipLoginStatus: value('ip_login_status'),
      roleName: value('role_name'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'employee_code': employeeCode,
      'name': name,
      'login_mobile': loginMobile,
      'rate_type_access': rateTypeAccess,
      'address': address,
      'remarks': remarks,
      'status': status,
      'store_id': storeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'mobile': mobile,
      'otp': otp,
      'device_id': deviceId,
      'designation': designation,
      'department': department,
      'level': level,
      'role': role,
      'salary': salary,
      'ip_login_status': ipLoginStatus,
      'role_name': roleName,
    };
  }
}
