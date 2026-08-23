import 'package:flutter/material.dart';

import '../routes/routes.dart';
import '../vars/global_vars.dart';

Widget buildLogo(BuildContext context) {
  return InkWell(
    onTap: (){
      if(GlobalVars.globalRoutes != "dashboard")
      {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.dashboard,
              (route) => false,
        );
        GlobalVars.globalRoutes = "dashboard";
      }
    },
    child: Container(
      width: 200,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 31,
            width: 31,
            decoration: BoxDecoration(
              color: const Color(0xff0D7894),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            'Globuzy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff126B8C),
            ),
          ),

          const Text(
            'Prime',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff25364A),
            ),
          ),
        ],
      ),
    ),
  );
}