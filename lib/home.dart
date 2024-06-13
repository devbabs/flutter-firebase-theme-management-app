import 'package:firebase_theme_take_home_project/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.title, required this.defaultThemes, required this.subscriberThemes});

  final String title;
  final List defaultThemes;
  final List subscriberThemes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Colors.white
        ),),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            Text("Hello LightForth!", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 5,),
            const Text("RE: Application for Mobile Engineer Role at LightForth."),
            const SizedBox(height: 5,),
            const Text("This Flutter application take-home project dynamically supports multiple themes using Firebase Remote Configuration and tracks user subscriptions using Firebase Realtime Database."),
            const SizedBox(height: 20,),
            Text("How to use:", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            )),
            const Text("Click any card for any theme below to apply the selected theme to the application."),
            const SizedBox(height: 20,),
            Text("NB: To use any of the subscriber themes, you need to be a subscribed user first.", style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Colors.red
            )),
            const SizedBox(height: 20,),
            ThemesList(title: "Default Themes:", themes: defaultThemes),
            ThemesList(title: "Subscriber Themes:", themes: subscriberThemes)
          ],
        ),
      ),
    );
  }
}

class ThemesList extends StatelessWidget {
  const ThemesList({super.key, required this.title, required this.themes});

  final String title;
  final List themes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          // color:
        ),),
        Wrap(
          children: [
            for (var theme in themes)
              ThemeCard(theme: theme)
          ],
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}

class ThemeCard extends StatelessWidget {
  const ThemeCard({super.key, required this.theme});

  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return GestureDetector(
      onTap: () {
        if (appState.currentTheme != null && theme['color'] == appState.currentTheme['color']) {
          return;
        }
        appState.setCurrentTheme(theme);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Theme changed to ${theme['label']}.", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.black
            )),
            backgroundColor: Color(int.parse(theme['color'])),
          ),
        );
      },
      child: Card(
        color: Color(int.parse(theme['color'])),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: Text(theme['label']),
          // child: Text(theme['label'], style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          //   color: Theme.of(context).colorScheme.onPrimary
          // )),
        ),
      )
    );
  }
}