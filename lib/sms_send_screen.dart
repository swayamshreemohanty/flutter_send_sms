import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:send_sms/utility/show_snak_bar.dart';
import 'package:telephony/telephony.dart';

class SMSsendScreen extends StatefulWidget {
  const SMSsendScreen({Key? key}) : super(key: key);

  @override
  State<SMSsendScreen> createState() => _SMSsendScreenState();
}

class _SMSsendScreenState extends State<SMSsendScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneNumberController = TextEditingController();
  final _customSMSController = TextEditingController();
  final Telephony smsService = Telephony.instance;

  void showRequestStatus(SendStatus status) {
    switch (status) {
      case SendStatus.SENT:
        ShowSnackBar.showSnackBar(context, ShowSnackBar.sent,
            backGroundColor: Colors.red);
        return;
      case SendStatus.DELIVERED:
        ShowSnackBar.showSnackBar(context, ShowSnackBar.delivered);
        return;
      default:
        ShowSnackBar.showSnackBar(context, ShowSnackBar.failed);
        return;
    }
  }

  Future<void> sendDirectSmS() async {
    try {
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();
      if (isValid) {
        _formKey.currentState!.save();
        //to vibrate the phone
        await HapticFeedback.lightImpact();

        final permissionsGranted =
            await smsService.requestPhoneAndSmsPermissions ?? false;

        if (permissionsGranted) {
          await smsService.sendSms(
            to: _phoneNumberController.text.trim(),
            message: _customSMSController.text.trim(),
            statusListener: (SendStatus status) {
              showRequestStatus(status);
            },
          );
        } else {
          // ignore: use_build_context_synchronously
          ShowSnackBar.showSnackBar(context, 'SMS permission is not allowed');
        }
        return;
      } else {
        await HapticFeedback.heavyImpact();
        return;
      }
    } catch (e) {
      ShowSnackBar.showSnackBar(context, 'Error occured while sending SMS.');
    }
  }

  Future<void> sendViaSmSApp() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      //to vibrate the phone
      await HapticFeedback.lightImpact();
      final permissionsGranted =
          await smsService.requestPhoneAndSmsPermissions ?? false;
      if (permissionsGranted) {
        await smsService.sendSmsByDefaultApp(
          to: _phoneNumberController.text.trim(),
          message: _customSMSController.text.trim(),
        );
      } else {
        // ignore: use_build_context_synchronously
        ShowSnackBar.showSnackBar(context, 'SMS permission is not allowed');
      }
      return;
    } else {
      await HapticFeedback.heavyImpact();
      return;
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _customSMSController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send SMS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneNumberController,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Field can't be empty";
                      }
                      return null;
                    },
                    onSaved: (String? phoneNumber) {},
                    decoration: InputDecoration(
                      hintText: 'Enter recipient number with country code...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _customSMSController,
                    keyboardType: TextInputType.text,
                    maxLines: 4,
                    maxLength: 160,
                    onSaved: (String? phoneNumber) {},
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SendSMSButton(
                  onPressed: sendDirectSmS,
                  buttonName: 'Send Directly',
                ),
                const SizedBox(width: 20),
                SendSMSButton(
                  onPressed: sendViaSmSApp,
                  buttonName: 'Via SMS APP',
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SendSMSButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonName;
  const SendSMSButton({
    Key? key,
    required this.onPressed,
    required this.buttonName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: ElevatedButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 5,
            ),
            child: Text(
              buttonName,
            ),
          ),
        ),
      );
}
