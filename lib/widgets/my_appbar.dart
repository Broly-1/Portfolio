import 'package:flutter/material.dart';
import 'package:hassankamran/Extensions/extensions.dart';

class MyAppbar extends StatelessWidget {
  const MyAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [NavigationIndicator(), Spacer(), AppMenus()]);
  }
}

class NavigationIndicator extends StatelessWidget {
  const NavigationIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('<< Your Name >>', style: context.textStyle.titleLgBold);
  }
}

class AppMenus extends StatelessWidget {
  const AppMenus({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              const Color.fromARGB(255, 230, 200, 200),
            ),
            foregroundColor: WidgetStateProperty.all<Color>(
              const Color.fromARGB(255, 148, 78, 78),
            ),
            overlayColor: WidgetStateProperty.all<Color>(
              const Color.fromARGB(255, 255, 230, 230),
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(8.0),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          child: Text('About', style: context.textStyle.bodyLgMedium),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Projects', style: context.textStyle.bodyLgMedium),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Resume', style: context.textStyle.bodyLgMedium),
        ),
        TextButton(
          onPressed: () {},
          child: Text('More...', style: context.textStyle.bodyLgMedium),
        ),
      ],
    );
  }
}
