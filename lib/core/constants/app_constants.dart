
import 'package:flutter/material.dart';
const String appName = 'Business Prime';
const String copyRightText = 'Copyright © 2026-27 Gobuzy.com';
const String symbolRupee = '\u{20B9}';
const String symbolDash = '\u{2013}';

const String logOutTitle = 'Log Out';
const String logOutTitleDes = 'Do you want to Log Out';

const String titleWelcomeBack = 'Welcome Back';
const String titleVerification = 'Verification';
const String titleAvailableColor = 'Available Color & Size';

const String errorInvalidMobile = 'Please Enter Valid 10 Digit Mobile Number';
const String errorInvalidOTP = 'Please Enter Valid 4 Digit OTP';
const String errorInternet = 'Please Check your Internet Connection';

const String textLogin = 'Login';

const scanErrorMsg = '🚨 यह बारकोड गलत लगा है ❌ कृपया इस प्रोडक्ट को फोटो, कलर, साइज, स्टॉक से मिलान करके नया बारकोड चिपकाएं।';
const scanErrorMsgStockZero = '🚨 इस बारकोड का स्टॉक समाप्त हो गया है। ❌ स्टॉक से मिलान करके नया बारकोड स्कैन करें।';

const String pageStateLoading = 'pageStateLoading';
const String pageStateSuccess = 'pageStateSuccess';
const String pageStateError = 'pageStateError';
const String pageStateEmpty = 'pageStateEmpty';
const String pageStateInternetError = 'pageStateInternetError';

const selectFromText = 'Transform From';
const selectToText = 'Transform To';

const String textB2B = 'B2B';
const String textB2C = 'B2C';
const String textSet = 'Set';
const String textRS = 'RS';
const String textSelectLocation = 'Select Location';
const String textSelectSalesman = 'Select Salesman';
const String textSelectStore = 'Select Store';
const String textSelectBackmen = 'Select BackMen';
const String textFollow = 'Followup';
const String textRate = 'RATE';
const String errorEmptyCart = 'Cart is Empty';

const String developerPage = 'https://www.gobuzy.com/';

const String accessPackingUpdate = 'PackingUpdate';
const String accessPackingItemDelete = 'PackingItemDelete';

final List<Map<String, dynamic>> categories = [
  {"title": "Design", "icon": Icons.design_services_rounded},
  {"title": "Graphic Design", "icon": Icons.image_rounded},
  {"title": "UI/UX Design", "icon": Icons.brush_rounded},
  {"title": "Web Design", "icon": Icons.web_rounded},
  {"title": "Mobile App", "icon": Icons.phone_android_rounded},
  {"title": "Frontend Development", "icon": Icons.web_asset_rounded},
  {"title": "Backend Development", "icon": Icons.code_rounded},
  {"title": "API Development", "icon": Icons.api_rounded},
  {"title": "API Integration", "icon": Icons.link_rounded},
  {"title": "Database", "icon": Icons.storage_rounded},
  {"title": "Database Optimization", "icon": Icons.dns_rounded},
  {"title": "Cloud Deployment", "icon": Icons.cloud_done_rounded},
  {"title": "DevOps", "icon": Icons.settings_applications_rounded},
  {"title": "CI/CD", "icon": Icons.sync_rounded},
  {"title": "Bug Fix", "icon": Icons.bug_report_rounded},
  {"title": "Testing", "icon": Icons.fact_check_rounded},
  {"title": "QA Testing", "icon": Icons.rule_rounded},
  {"title": "Performance", "icon": Icons.speed_rounded},
  {"title": "Security", "icon": Icons.security_rounded},
  {"title": "Documentation", "icon": Icons.description_rounded},
  {"title": "Research", "icon": Icons.search_rounded},
  {"title": "Planning", "icon": Icons.event_note_rounded},
  {"title": "Project Management", "icon": Icons.assignment_rounded},
  {"title": "Task Management", "icon": Icons.checklist_rounded},
  {"title": "Meeting", "icon": Icons.groups_rounded},
  {"title": "Training", "icon": Icons.school_rounded},
  {"title": "Presentation", "icon": Icons.slideshow_rounded},
  {"title": "Marketing", "icon": Icons.campaign_rounded},
  {"title": "Digital Marketing", "icon": Icons.trending_up_rounded},
  {"title": "Social Media", "icon": Icons.share_rounded},
  {"title": "SEO", "icon": Icons.travel_explore_rounded},
  {"title": "Advertising", "icon": Icons.ads_click_rounded},
  {"title": "Content Writing", "icon": Icons.edit},
  {"title": "Customer Support", "icon": Icons.support_agent_rounded},
  {"title": "Customer Feedback", "icon": Icons.feedback_rounded},
  {"title": "Sales", "icon": Icons.sell_rounded},
  {"title": "Lead Generation", "icon": Icons.person_add_alt_1_rounded},
  {"title": "Finance", "icon": Icons.account_balance_wallet_rounded},
  {"title": "Accounting", "icon": Icons.calculate_rounded},
  {"title": "Invoice", "icon": Icons.receipt_long_rounded},
  {"title": "Payment", "icon": Icons.payments_rounded},
  {"title": "Purchase", "icon": Icons.shopping_cart_rounded},
  {"title": "Inventory", "icon": Icons.inventory_2_rounded},
  {"title": "Warehouse", "icon": Icons.warehouse_rounded},
  {"title": "Logistics", "icon": Icons.local_shipping_rounded},
  {"title": "Delivery", "icon": Icons.delivery_dining_rounded},
  {"title": "Manufacturing", "icon": Icons.precision_manufacturing_rounded},
  {"title": "Production", "icon": Icons.factory_rounded},
  {"title": "Maintenance", "icon": Icons.build_rounded},
  {"title": "IT Support", "icon": Icons.computer_rounded},
  {"title": "Networking", "icon": Icons.router_rounded},
  {"title": "Server", "icon": Icons.storage_rounded},
  {"title": "Backup", "icon": Icons.backup_rounded},
  {"title": "Human Resources", "icon": Icons.people_alt_rounded},
  {"title": "Recruitment", "icon": Icons.person_search_rounded},
  {"title": "Attendance", "icon": Icons.fact_check_rounded},
  {"title": "Payroll", "icon": Icons.request_quote_rounded},
  {"title": "Legal", "icon": Icons.gavel_rounded},
  {"title": "Compliance", "icon": Icons.verified_user_rounded},
  {"title": "Healthcare", "icon": Icons.local_hospital_rounded},
  {"title": "Education", "icon": Icons.menu_book_rounded},
  {"title": "Travel", "icon": Icons.flight_rounded},
  {"title": "Event", "icon": Icons.event_rounded},
  {"title": "Communication", "icon": Icons.chat_rounded},
  {"title": "Email", "icon": Icons.email_rounded},
  {"title": "Call", "icon": Icons.call_rounded},
  {"title": "Analytics", "icon": Icons.analytics_rounded},
  {"title": "Reports", "icon": Icons.bar_chart_rounded},
  {"title": "Dashboard", "icon": Icons.dashboard_rounded},
  {"title": "Review", "icon": Icons.rate_review_rounded},
  {"title": "Approval", "icon": Icons.approval_rounded},
  {"title": "General", "icon": Icons.folder_rounded},
];
