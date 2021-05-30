import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/styles.dart';

class WarningMessager extends StatelessWidget {
  static RichText configServerWarningText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "Setup desktop app to sync photos and notes.",
        style: Styles.normalBodyText,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).pushNamed(
              AuthPage.routeName,
            );
          },
      ),
    );
  }

  static RichText configUnknownServerReachable(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "Try to connect to desktop app...",
        style: Styles.normalBodyText,
      ),
    );
  }

  static RichText configServerUnreachable(BuildContext context) {
    return RichText(
      text: TextSpan(
        text:
            "Failed to connect to desktop app. Check Wi-Fi connection and setup server key again.",
        style: Styles.normalBodyText,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).pushNamed(
              AuthPage.routeName,
            );
          },
      ),
    );
  }

  final RichText text;
  final VoidCallback dismiss;
  final VoidCallback forward;

  WarningMessager(this.text, {this.dismiss, this.forward});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        border: Border.all(width: 1, color: Styles.warningColor),
        color: Styles.warningColor,
      ),
      child: Column(children: [
        Row(
          children: [
            Expanded(
              child: text,
            ),
            ...(forward == null
                ? []
                : [
                    InkWell(
                      onTap: forward,
                      child: Icon(AppIcons.right_open, size: 12),
                    )
                  ]),
            ...(dismiss == null
                ? []
                : [
                    InkWell(
                      onTap: dismiss,
                      child: Icon(AppIcons.cancel, size: 12),
                    )
                  ]),
          ],
        ),
      ]),
    );
  }
}
