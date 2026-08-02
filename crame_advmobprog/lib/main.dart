import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The entry point of the application.
/// Wraps the application with a ChangeNotifierProvider to inject the ThemeModel globally.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
/// Listens to the global ThemeModel to rebuild the MaterialApp when the theme changes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeModel from the provider.
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      // Switch between dark and light themes based on the state in ThemeModel.
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const MainMenu(),
    );
  }
}

/// A navigation menu that provides access to the different state management examples.
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the Ephemeral State (local state) example.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              child: const Text('Ephemeral State (Counter)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the App State (global state) example.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHome()),
                );
              },
              child: const Text('App State (Theme Toggler)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A state model that manages the application's theme.
/// Uses ChangeNotifier to broadcast state changes to active listeners.
class ThemeModel with ChangeNotifier {
  /// A boolean indicating whether dark mode is enabled.
  bool _isDark = false;

  /// Public getter to access the current theme state.
  bool get isDark => _isDark;

  /// Toggles the theme state between dark and light mode.
  /// Calls notifyListeners() to trigger UI updates in dependent widgets.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// The main screen for the App State Example.
/// Demonstrates reading and updating global state managed by a Provider.
class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the global ThemeModel.
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App State Example'),
        actions: [
          // A switch widget that interacts with the global ThemeModel to toggle the theme.
          Switch(
            value: themeModel.isDark,
            onChanged: (_) => themeModel.toggleTheme(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Toggle the theme using the switch in the app bar.'),
      ),
    );
  }
}

/// Provides the MaterialApp structure for the Ephemeral State Example.
class StateManagementActivity extends StatelessWidget {
  const StateManagementActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

/// The main screen for the ephemeral (local) state example.
/// Extends StatefulWidget to manage its own internal state.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The state class for MyHomePage.
/// Holds the local state data that is only relevant to this specific widget.
class _MyHomePageState extends State<MyHomePage> {
  /// The integer variable holding the current counter value.
  int _counter = 0;

  /// Increments the counter and updates the UI.
  /// Calls setState() to notify the framework that the state has changed.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Builds the user interface for the counter screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral State Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}