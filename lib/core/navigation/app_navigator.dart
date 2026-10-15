import 'package:flutter/material.dart';

/// Key of the app's root navigator. Lets the auth state move the whole app
/// (sign-in, consent, follow-up ended, shell) from anywhere, including from a
/// session event that arrives while no screen is handling it.
final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app-root');
