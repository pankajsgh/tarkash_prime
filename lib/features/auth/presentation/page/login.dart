import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sms_user_consent_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widget/otp_box_widget.dart';
import '../controller/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = AuthController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollToField(double height) {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }


  void getFinalOtp(String otp){
    print(otp);
    controller.setOtp(otp);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 700;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (keyboardHeight > 10) {
      _scrollToField(keyboardHeight);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F7FB),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            children: [
              // ============================================================
              // BACKGROUND
              // ============================================================

              _buildBackground(size),

              // ============================================================
              // CONTENT
              // ============================================================

              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 30 : 20,
                    vertical: isDesktop ? 35 : 24,
                  ),
                  child: Column(
                    children: [
                      // ----------------------------------------------------
                      // HEADER
                      // ----------------------------------------------------

                      _buildHeader(isDesktop),

                      SizedBox(
                        height: isDesktop ? 35 : 25,
                      ),

                      // ----------------------------------------------------
                      // LOGIN AREA
                      // ----------------------------------------------------

                      isDesktop
                          ? _buildDesktopLogin()
                          : _buildMobileLogin(),

                      const SizedBox(height: 25),

                      // ----------------------------------------------------
                      // FOOTER
                      // ----------------------------------------------------

                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


// ========================================================================
// BACKGROUND
// ========================================================================

  Widget _buildBackground(Size size) {
    return Stack(
      children: [
        // Main gradient area
        Container(
          height: size.height * .48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryAppColor,
                primaryAppColor.withValues(alpha: .88),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(45),
              bottomRight: Radius.circular(45),
            ),
          ),
        ),

        // Top-right circle
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .07),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Left circle
        Positioned(
          top: 120,
          left: -80,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .05),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Small decorative circle
        Positioned(
          top: 260,
          right: 80,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .04),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }


// ========================================================================
// HEADER
// ========================================================================

  Widget _buildHeader(bool isDesktop) {
    return Column(
      children: [
        // Logo
        Container(
          height: isDesktop ? 76 : 70,
          width: isDesktop ? 76 : 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: .22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.task_alt_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),

        const SizedBox(height: 16),

        // App name
        Text(
          appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 27 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: .2,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Smart Business Management',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: .82),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


// ========================================================================
// DESKTOP LOGIN
// ========================================================================

  Widget _buildDesktopLogin() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1050,
        ),
        child: SizedBox(
          height: 500,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .09),
                  blurRadius: 45,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // ==========================================================
                // LEFT SIDE
                // ==========================================================

                Expanded(
                  flex: 5,
                  child: _buildDesktopIllustration(),
                ),

                // ==========================================================
                // RIGHT SIDE
                // ==========================================================

                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 40,
                    ),
                    child: SingleChildScrollView(
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// ========================================================================
// DESKTOP ILLUSTRATION
// ========================================================================

  Widget _buildDesktopIllustration() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryAppColor,
            primaryAppColor.withValues(alpha: .78),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ============================================================
          // DECORATIVE CIRCLES
          // ============================================================

          Positioned(
            top: -70,
            right: -60,
            child: Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================

          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                SizedBox(
                  height: 230,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/img_login.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Manage your business smarter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Everything you need to manage your business '
                      'in one simple application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeature(
                      Icons.speed_rounded,
                      'Fast',
                    ),
                    const SizedBox(width: 20),
                    _buildFeature(
                      Icons.security_rounded,
                      'Secure',
                    ),
                    const SizedBox(width: 20),
                    _buildFeature(
                      Icons.business_rounded,
                      'Business',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


// ========================================================================
// FEATURE ITEM
// ========================================================================

  Widget _buildFeature(
      IconData icon,
      String title,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Colors.white.withValues(alpha: .9),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


// ========================================================================
// MOBILE LOGIN
// ========================================================================

  Widget _buildMobileLogin() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      padding: const EdgeInsets.fromLTRB(
        22,
        28,
        22,
        25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _buildLoginForm(),
    );
  }


// ========================================================================
// LOGIN FORM
// ========================================================================

  Widget _buildLoginForm() {
    final showOtp = controller.showOtp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ================================================================
        // TITLE
        // ================================================================

        Text(
          showOtp ? 'Verify your number' : 'Welcome back',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xff172033),
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          showOtp
              ? 'Enter the verification code sent to your mobile.'
              : 'Sign in using your registered mobile number.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff64748B),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 26),

        // ================================================================
        // MOBILE NUMBER
        // ================================================================

        if (!showOtp) ...[
          const Text(
            'Mobile number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff334155),
            ),
          ),

          const SizedBox(height: 8),

          CustomTextField(
            controller: controller.mobileController,
            hintText: 'Enter mobile number',
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            showCountryCode: true,
          ),
        ],

        // ================================================================
        // OTP
        // ================================================================

        if (showOtp) ...[
          _buildOtpSection(),
        ],

        const SizedBox(height: 24),

        // ================================================================
        // MAIN BUTTON
        // ================================================================

        _buildMainButton(),

        const SizedBox(height: 20),

        // ================================================================
        // SECURE LOGIN
        // ================================================================

        _buildSecureIndicator(),

        // ================================================================
        // CHANGE NUMBER
        // ================================================================

        if (showOtp) ...[
          const SizedBox(height: 18),
          Center(
            child: _buildChangeNumberButton(),
          ),
        ],
      ],
    );
  }


// ========================================================================
// OTP SECTION
// ========================================================================

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OTP information
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xffE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: primaryAppColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.sms_outlined,
                  size: 18,
                  color: primaryAppColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification code sent to',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff64748B),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '+91 ${controller.mobileController.text}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1E293B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: controller.isLoading
                    ? null
                    : () {
                  controller.sendOtp(context);
                },
                child: Text(
                  'Resend',
                  style: TextStyle(
                    color: primaryAppColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Enter verification code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff334155),
          ),
        ),

        const SizedBox(height: 10),

        // OTP boxes
        Center(
          child: OtpBoxWidget(
            index: 4,
            callBack: getFinalOtp,
            otp: controller.otp,
          ),
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              'Your OTP is securely encrypted',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }


// ========================================================================
// MAIN BUTTON
// ========================================================================

  Widget _buildMainButton() {
    final showOtp = controller.showOtp;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () {
          if (showOtp) {
            controller.verifyOtp(context);
          } else {
            controller.sendOtp(context);
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryAppColor,
          disabledBackgroundColor:
          primaryAppColor.withValues(alpha: .55),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              showOtp
                  ? 'Verify & Continue'
                  : 'Continue',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }


// ========================================================================
// SECURE INDICATOR
// ========================================================================

  Widget _buildSecureIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 15,
          color: Colors.green.shade600,
        ),

        const SizedBox(width: 6),

        Text(
          'Secure OTP authentication',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


// ========================================================================
// CHANGE MOBILE NUMBER
// ========================================================================

  Widget _buildChangeNumberButton() {
    return InkWell(
      onTap: controller.isLoading
          ? null
          : () {
        controller.changeNo();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 15,
              color: primaryAppColor,
            ),

            const SizedBox(width: 6),

            Text(
              'Change mobile number',
              style: TextStyle(
                color: primaryAppColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


// ========================================================================
// FOOTER
// ========================================================================

  Widget _buildFooter() {
    return Text(
      '© ${DateTime.now().year} $appName',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade500,
      ),
    );
  }


// Widget build(BuildContext context) {
  //   final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  //   if (keyboardHeight > 10) {
  //     _scrollToField(keyboardHeight);
  //   }
  //   return Scaffold(
  //     resizeToAvoidBottomInset: true,
  //     backgroundColor: const Color(0xffF5F7FF),
  //     body: AnimatedBuilder(
  //       animation: controller,
  //       builder: (context, _) {
  //         return Stack(
  //           children: [
  //             /// TOP GRADIENT BACKGROUND
  //             Container(
  //               height: MediaQuery.of(context).size.height * .42,
  //               decoration: BoxDecoration(
  //                 color: primaryAppColor,
  //                 borderRadius: BorderRadius.only(
  //                   bottomLeft: Radius.circular(40),
  //                   bottomRight: Radius.circular(40),
  //                 ),
  //               ),
  //             ),
  //
  //             /// CIRCLE EFFECTS
  //             Positioned(
  //               top: -40,
  //               right: -30,
  //               child: Container(
  //                 height: 160,
  //                 width: 160,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(.08),
  //                   shape: BoxShape.circle,
  //                 ),
  //               ),
  //             ),
  //
  //             Positioned(
  //               top: 90,
  //               left: -50,
  //               child: Container(
  //                 height: 140,
  //                 width: 140,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(.05),
  //                   shape: BoxShape.circle,
  //                 ),
  //               ),
  //             ),
  //
  //             SafeArea(
  //               child: SingleChildScrollView(
  //                 controller: _scrollController,
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 24,
  //                   vertical: 20,
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     const SizedBox(height: 20),
  //
  //                     /// LOGO
  //                     Container(
  //                       height: 90,
  //                       width: 90,
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withOpacity(.15),
  //                         borderRadius: BorderRadius.circular(28),
  //                         border: Border.all(
  //                           color: Colors.white.withValues(alpha: .2),
  //                         ),
  //                       ),
  //                       child: const Icon(
  //                         Icons.task_alt,
  //                         color: Colors.white,
  //                         size: 50,
  //                       ),
  //                     ),
  //
  //                     const SizedBox(height: 18),
  //
  //                     /// TITLE
  //                     const Text(
  //                       appName,
  //                       style: TextStyle(
  //                         fontSize: 28,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                         letterSpacing: .5,
  //                       ),
  //                     ),
  //
  //                     const SizedBox(height: 8),
  //
  //                     Text(
  //                       'Smart Business Management',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.white.withValues(alpha: .85),
  //                       ),
  //                     ),
  //
  //                     const SizedBox(height: 30),
  //
  //                     /// LOGIN CARD
  //                     if(MediaQuery.of(context).size.width>500)
  //                       Container(
  //                         width: MediaQuery.of(context).size.width,
  //                         height: 400,
  //                         child: Padding(
  //                           padding: EdgeInsets.symmetric(horizontal: 50),
  //                           child: Row(
  //                             children: [
  //                               // LEFT SIDE
  //                               Expanded(
  //                                 child: Container(
  //                                   height: 330,
  //                                   decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(32),
  //                                       color: Colors.white
  //                                   ),
  //                                   clipBehavior: Clip.antiAlias,
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.all(30.0),
  //                                     child: Image.asset(
  //                                       'assets/images/img_login.png',
  //                                       fit: BoxFit.contain,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //
  //                               const SizedBox(width: 50),
  //
  //                               // RIGHT SIDE
  //                               Expanded(
  //                                 child: Container(
  //                                   padding: const EdgeInsets.all(24),
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.white,
  //                                     borderRadius: BorderRadius.circular(32),
  //                                     boxShadow: [
  //                                       BoxShadow(
  //                                         color: Colors.black.withValues(alpha: .08),
  //                                         blurRadius: 30,
  //                                         offset: const Offset(0, 10),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.symmetric(horizontal: 60.0),
  //                                     child: Column(
  //                                       mainAxisSize: MainAxisSize.min,
  //                                       children: [
  //
  //                                         Text(
  //                                           "Welcome Back 👋",
  //                                           style: TextStyle(
  //                                             fontSize: 22,
  //                                             fontWeight: FontWeight.bold,
  //                                             color: Color(0xff1E293B),
  //                                           ),
  //                                         ),
  //
  //                                         const SizedBox(height: 8),
  //
  //                                         Text(
  //                                           "Login with mobile number",
  //                                           style: TextStyle(
  //                                             color: Colors.grey,
  //                                           ),
  //                                         ),
  //
  //                                         const SizedBox(height: 20),
  //
  //                                         if (!controller.showOtp)
  //                                           CustomTextField(
  //                                             controller: controller.mobileController,
  //                                             hintText: "Enter mobile number",
  //                                             prefixIcon: Icons.phone_android,
  //                                             keyboardType: TextInputType.phone,
  //                                             maxLength: 10,
  //                                             showCountryCode: true,
  //                                           ),
  //
  //                                         if (controller.showOtp)
  //                                           Column(
  //                                             children: [
  //                                               Row(
  //                                                 mainAxisAlignment:
  //                                                 MainAxisAlignment.spaceBetween,
  //                                                 children: [
  //                                                   Expanded(
  //                                                     child: Text(
  //                                                       "OTP sent to +91 ${controller.mobileController.text}",
  //                                                       style: const TextStyle(
  //                                                         fontSize: 12,
  //                                                         color: Colors.grey,
  //                                                       ),
  //                                                       overflow: TextOverflow.ellipsis,
  //                                                     ),
  //                                                   ),
  //
  //                                                   GestureDetector(
  //                                                     onTap: () {
  //                                                       controller.sendOtp(context);
  //                                                     },
  //                                                     child: Text(
  //                                                       "Resend",
  //                                                       style: TextStyle(
  //                                                         color: primaryAppColor,
  //                                                         fontWeight: FontWeight.w500,
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //
  //                                               const SizedBox(height: 12),
  //                                             ],
  //                                           ),
  //
  //                                         if (controller.showOtp)
  //                                           OtpBoxWidget(
  //                                             index: 4,
  //                                             callBack: getFinalOtp,
  //                                             otp: controller.otp,
  //                                           ),
  //
  //                                         const SizedBox(height: 12),
  //
  //                                         if (controller.showOtp)
  //                                           Row(
  //                                             children: [
  //                                               const Icon(
  //                                                 Icons.lock_outline,
  //                                                 size: 18,
  //                                                 color: Colors.grey,
  //                                               ),
  //
  //                                               const SizedBox(width: 8),
  //
  //                                               const Text(
  //                                                 "Enter OTP",
  //                                                 style: TextStyle(
  //                                                   fontSize: 12,
  //                                                   color: Colors.grey,
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //
  //                                         const SizedBox(height: 18),
  //
  //                                         SizedBox(
  //                                           width: double.infinity,
  //                                           height: 52,
  //                                           child: ElevatedButton(
  //                                             onPressed: controller.isLoading
  //                                                 ? null
  //                                                 : () {
  //                                               controller.showOtp
  //                                                   ? controller.verifyOtp(context)
  //                                                   : controller.sendOtp(context);
  //                                             },
  //                                             style: ElevatedButton.styleFrom(
  //                                               elevation: 0,
  //                                               backgroundColor: primaryAppColor,
  //                                               shape: RoundedRectangleBorder(
  //                                                 borderRadius: BorderRadius.circular(18),
  //                                               ),
  //                                             ),
  //                                             child: controller.isLoading
  //                                                 ? const SizedBox(
  //                                               height: 22,
  //                                               width: 22,
  //                                               child: CircularProgressIndicator(
  //                                                 strokeWidth: 2,
  //                                                 color: Colors.white,
  //                                               ),
  //                                             )
  //                                                 : Text(
  //                                               controller.showOtp
  //                                                   ? "Verify OTP"
  //                                                   : "Send OTP",
  //                                               style: const TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 16,
  //                                                 fontWeight: FontWeight.w600,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //
  //                                         const SizedBox(height: 30),
  //
  //                                         if (controller.showOtp)
  //                                           GestureDetector(
  //                                             onTap: () {
  //                                               controller.changeNo();
  //                                             },
  //                                             child: Text(
  //                                               "Change Mobile Number",
  //                                               style: TextStyle(
  //                                                 color: primaryAppColor,
  //                                                 fontWeight: FontWeight.w500,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ) else
  //                       Container(
  //                         padding: const EdgeInsets.all(24),
  //
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //
  //                           borderRadius: BorderRadius.circular(32),
  //
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black.withValues(alpha: .08),
  //
  //                               blurRadius: 30,
  //
  //                               offset: const Offset(0, 10),
  //                             ),
  //                           ],
  //                         ),
  //
  //                         child: Column(
  //                           children: [
  //                             /// TITLE
  //                             const Align(
  //                               alignment: Alignment.centerLeft,
  //                               child: Text(
  //                                 "Welcome Back 👋",
  //                                 style: TextStyle(
  //                                   fontSize: 22,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: Color(0xff1E293B),
  //                                 ),
  //                               ),
  //                             ),
  //
  //                             const SizedBox(height: 8),
  //
  //                             const Align(
  //                               alignment: Alignment.centerLeft,
  //                               child: Text(
  //                                 "Login with mobile number",
  //                                 style: TextStyle(color: Colors.grey),
  //                               ),
  //                             ),
  //
  //                             const SizedBox(height: 20),
  //
  //                             /// MOBILE FIELD
  //                             if (!controller.showOtp)
  //                               CustomTextField(
  //                                 controller: controller.mobileController,
  //
  //                                 hintText: "Enter mobile number",
  //
  //                                 prefixIcon: Icons.phone_android,
  //
  //                                 keyboardType: TextInputType.phone,
  //
  //                                 maxLength: 10,
  //
  //                                 showCountryCode: true,
  //                               ),
  //
  //                             /// OTP FIELD
  //                             if (controller.showOtp)
  //                               Column(
  //                                 children: [
  //
  //                                   Row(
  //                                     mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //
  //                                     children: [
  //                                       Text(
  //                                         "OTP sent to +91 ${controller.mobileController.text}",
  //
  //                                         style: const TextStyle(
  //                                           fontSize: 12,
  //
  //                                           color: Colors.grey,
  //                                         ),
  //                                       ),
  //
  //                                       GestureDetector(
  //                                         onTap: () {
  //                                           controller.sendOtp(context);
  //                                         },
  //
  //                                         child: Text(
  //                                           "Resend",
  //
  //                                           style: TextStyle(
  //                                             color: primaryAppColor,
  //
  //                                             fontWeight: FontWeight.w500,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   const SizedBox(height: 12),
  //                                 ],
  //                               ),
  //
  //                             if (controller.showOtp)
  //                               OtpBoxWidget(index: 4, callBack: getFinalOtp, otp: controller.otp),
  //                             const SizedBox(height: 12),
  //                             if (controller.showOtp)
  //                               Row(children: [
  //                                 Icon(Icons.lock_outline, size: 18, color: Colors.grey,),
  //                                 SizedBox(width: 8,),
  //                                 Text("Enter OTP", style: TextStyle(fontSize: 12, color: Colors.grey),)
  //                               ],),
  //
  //
  //                             const SizedBox(height: 18),
  //
  //                             /// BUTTON
  //                             SizedBox(
  //                               width: double.infinity,
  //
  //                               height: 52,
  //
  //                               child: ElevatedButton(
  //                                 onPressed: controller.isLoading
  //                                     ? null
  //                                     : () {
  //                                   controller.showOtp
  //                                       ? controller.verifyOtp(context)
  //                                       : controller.sendOtp(context);
  //                                 },
  //
  //                                 style: ElevatedButton.styleFrom(
  //                                   elevation: 0,
  //                                   backgroundColor: primaryAppColor,
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(18),
  //                                   ),
  //                                 ),
  //
  //                                 child: controller.isLoading
  //                                     ? const SizedBox(
  //                                   height: 22,
  //
  //                                   width: 22,
  //
  //                                   child: CircularProgressIndicator(
  //                                     strokeWidth: 2,
  //
  //                                     color: Colors.white,
  //                                   ),
  //                                 )
  //                                     : Text(
  //                                   controller.showOtp
  //                                       ? "Verify OTP"
  //                                       : "Send OTP",
  //
  //                                   style: const TextStyle(
  //                                     color: Colors.white,
  //
  //                                     fontSize: 16,
  //
  //                                     fontWeight: FontWeight.w600,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //
  //                             const SizedBox(height: 30),
  //
  //                             /// CHANGE MOBILE
  //                             if (controller.showOtp)
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   controller.changeNo();
  //                                 },
  //
  //                                 child: Text(
  //                                   "Change Mobile Number",
  //                                   style: TextStyle(
  //                                     color: primaryAppColor,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ),
  //                           ],
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hintText;

  final IconData prefixIcon;

  final Widget? suffixIcon;

  final bool obscureText;

  final int? maxLength;

  final bool showCountryCode;

  final TextInputType keyboardType;

  const CustomTextField({
    super.key,

    required this.controller,

    required this.hintText,

    required this.prefixIcon,

    this.suffixIcon,

    this.obscureText = false,

    this.maxLength,

    this.showCountryCode = false,

    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: TextField(
        controller: controller,

        obscureText: obscureText,

        maxLength: maxLength,

        keyboardType: keyboardType,

        decoration: InputDecoration(
          counterText: "",

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 18),

          /// PREFIX
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              const SizedBox(width: 14),

              Icon(prefixIcon, color: Colors.grey, size: 22),

              if (showCountryCode)
                Container(
                  margin: const EdgeInsets.only(left: 8),

                  child: const Text(
                    "+91",

                    style: TextStyle(
                      fontSize: 15,

                      fontWeight: FontWeight.w600,

                      color: Colors.black87,
                    ),
                  ),
                ),

              if (showCountryCode)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),

                  child: Text("|", style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),

          suffixIcon: suffixIcon,

          hintText: hintText,

          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

