import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final delegate = BeamerDelegate(
      initialPath: '/first',
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [Location()],
      ),
    );

    return BeamerProvider(
      routerDelegate: delegate,
      child: MaterialApp.router(routeInformationParser: BeamerParser(), routerDelegate: delegate),
    );
  }
}

class Location extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/first/*'];

    @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(key: ValueKey('first'), child: FirstPage()),
      if (state.uri.pathSegments.contains('second'))
        BeamPage(
          key: ValueKey('second'),
          onPopPage: (context, delegate, state, page) {
            print('Triggered onPopPage');

            return BeamPage.pathSegmentPop(context, delegate, state, page);
          },
          child: SecondPage(),
        ),
    ];
  }

}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ElevatedButton(onPressed: () {
        Beamer.of(context).beamToNamed('/first/second');
      }, child: Text('Go to second')),),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('Never triggered');
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () {
                    // This doesn't trigger this page's `onPopPage`.
                    Beamer.of(context).beamBack();
                  }, child: Text('Go back with Beamer')),
                  ElevatedButton(onPressed: () {
                    // This triggers this page's `onPopPage`.
                    Navigator.of(context).pop();
                  }, child: Text('Go back with Navigator')),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}