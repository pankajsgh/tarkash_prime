import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';


class OtpBoxWidget extends StatefulWidget {
  final int index;
  final Function callBack;
  List<String>  otp;
  OtpBoxWidget({super.key, required this.index, required this.callBack, required this.otp});

  @override
  State<OtpBoxWidget> createState() => _OtpBoxWidgetState();
}

class _OtpBoxWidgetState extends State<OtpBoxWidget> {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();

    controllers =
        List.generate(widget.index, (_) => TextEditingController());

    focusNodes =
        List.generate(widget.index, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OtpBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.otp.isNotEmpty)
      {
        for(var i=0; i<widget.otp.length; i++)
          {
            controllers[i].text = widget.otp[i];
          }
      }


    // Compare old and new values
  }


  @override
  Widget build(BuildContext context) {

    return Center(
      child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: List.generate(controllers.length, (index){return  Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 52,
                height: 52,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                      if (controllers[index].text.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(
                          focusNodes[index - 1],
                        );
                        controllers[index - 1].clear();
                      }
                    }
                  },
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    onTap: () {
                      controllers[index].selection = TextSelection.fromPosition(
                        TextPosition(offset: controllers[index].text.length),
                      );},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),

                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                        borderSide:
                        BorderSide(
                          color: primaryAppColor,
                          width: 1.5,
                        ),
                      ),
                    ),

                    onChanged: (value) {
                      String otp = controllers.map((e) => e.text).join();
                      widget.callBack(otp);

                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).requestFocus(focusNodes[index + 1],);
                      }
                    },
                  ),
                ),
              ) );})
      ),
    );
  }
}
