import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_theme_take_home_project/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// We use a stateful widget here so we can track a user's subscription status in the widget state
class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.title,
    required this.defaultThemes,
    required this.subscriberThemes
  });

  final String title;
  final List defaultThemes;
  final List subscriberThemes;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Connecting to Firebase Realtime Database
  final FirebaseDatabase database = FirebaseDatabase.instance;

  dynamic activeSubscription;
  dynamic currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Interval timer to constantly update the current time and check for changes to the active subscription
    Timer.periodic(const Duration(seconds: 1), (timer) {
      dynamic newActiveSubscription;

      if(activeSubscription != null && DateTime.fromMillisecondsSinceEpoch(activeSubscription).isBefore(DateTime.now())) {
        newActiveSubscription = null;
        database.ref('subscription_expiry').remove();
      } else {
        newActiveSubscription = activeSubscription;
      }
      
      setState(() {
        currentTime = DateTime.now();
        activeSubscription = newActiveSubscription;
      });
    });

    // Get and listen to changes in the subscription expiry time on the firebase realtime database
    database.ref('subscription_expiry').onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists && event.snapshot.value != activeSubscription) {
        // Set active subscription in the widget state if the subscription expiry time is changed in the firebase realtime database
        setState(() {
          activeSubscription = event.snapshot.value;
        });
      } else if(!event.snapshot.exists) {
        // Remove active subscription from the widget state if the subscription expiry time is removed from the firebase realtime database
        setState(() {
          activeSubscription = null;
        });
      }
    });

    // Function to update subscription expiry time in the firebase realtime database, setting to 10 minutes
    void subscribeWithDuration() {
      var expiresAt = DateTime.now().add(const Duration(minutes: 10));

      database.ref('subscription_expiry').set(expiresAt.millisecondsSinceEpoch);
    }

    // Main home page scaffold, with appbar, body and Snackbar for alerts
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
            Center(
              child: Text("Subscription Status:", style: Theme.of(context).textTheme.titleLarge,),
            ),
            Center(
              child: activeSubscription != null && DateTime.fromMillisecondsSinceEpoch(activeSubscription).isAfter(DateTime.now()) ? Column(
                children: [
                  Text("Active", style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    color: Colors.green
                  ),),
                  Text("Expires at: ${DateFormat().format(DateTime.fromMillisecondsSinceEpoch(activeSubscription))}", style: Theme.of(context).textTheme.bodyLarge,),
                ],
              ) : Column(
                children: [
                  Text("Inactive", style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    color: Colors.red
                  ),),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shield),
                    onPressed: () {
                      // Subscribe to use subscriber themes
                      subscribeWithDuration();
                    },
                    label: Text("Click here to subscribe now", style: Theme.of(context).textTheme.bodyLarge,)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            ThemesList(title: "Default Themes:", themes: widget.defaultThemes),
            ThemesList(title: "Subscriber Themes:", themes: widget.subscriberThemes, requiresSubscription: true, activeSubscription: activeSubscription,),
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}

// Widget to show a list of themes and a title
class ThemesList extends StatelessWidget {
  const ThemesList({
    super.key,
    required this.title,
    required this.themes,
    this.requiresSubscription = false,
    this.activeSubscription
  });

  final String title;
  final List themes;
  final dynamic activeSubscription;
  final bool requiresSubscription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          // color:
        ),),
        if(requiresSubscription && activeSubscription == null)
          Column(
            children: [
              const SizedBox(height: 10,),
              Text("NB: To use any of the subscriber themes, you need to be a subscribed user first.", style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Colors.red
              )),
              const SizedBox(height: 10,),
            ],
          ),
        Wrap(
          children: [
            for (var theme in themes)
              ThemeCard(theme: theme, requiresSubscription: requiresSubscription, activeSubscription: activeSubscription,)
          ],
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}

// Widget to show a single theme card, with an action to apply the theme for that card
class ThemeCard extends StatelessWidget {
  const ThemeCard({super.key, required this.theme, this.requiresSubscription = false, this.activeSubscription});

  final dynamic theme;
  final dynamic activeSubscription;
  final bool requiresSubscription;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    void updateTheme() {      
      // Do nothing if the selected theme is already applied
      if (appState.currentTheme != null && theme['color'] == appState.currentTheme['color']) {
        return;
      }

      // Show an error message that lets user know subscription is needed to access a theme that requires subscription, when there is no active subscription.
      if(requiresSubscription && (activeSubscription == null || DateTime.fromMillisecondsSinceEpoch(activeSubscription).isBefore(DateTime.now()))) {

        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You need to be subscribed to use subscriber themes.", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white
            )),
            backgroundColor: Colors.black,
          ),
        );
      } else {
        // Set new selected theme
        appState.setCurrentTheme(theme);

        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Show message to let a user know selected theme has been applied.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Theme changed to ${theme['label']}.", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.black
            )),
            backgroundColor: Color(int.parse(theme['color'])),
          ),
        );
      }
    }

    // Gesturedetector that allows user tap on a theme to select
    return GestureDetector(
      onTap: () {
        updateTheme();
      },
      child: Card(
        color: Color(int.parse(theme['color'])),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: Text(theme['label']),
        ),
      )
    );
  }
}