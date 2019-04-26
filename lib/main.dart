  import 'package:flutter/material.dart';
  import 'dart:io';
  import 'package:oauth1/oauth1.dart' as oauth1;
  import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Open Tweet',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My Open Tweet Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
  const String apiKey = 'LLDeVY0ySvjoOVmJ2XgBItvTV';
  const String apiSecret = 'JmEpkWXXmY7BYoQor5AyR84BD2BiN47GIBUPXn3bopZqodJ0MV';
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _message = "";
  String _body = "User TimeLine";
  TextEditingController pinController = new TextEditingController();

  // define client credentials (consumer keys)

  oauth1.ClientCredentials clientCredentials = new oauth1.ClientCredentials(apiKey, apiSecret);
  // define platform (server)
  var platform = new oauth1.Platform(
      'https://api.twitter.com/oauth/request_token', // temporary credentials request
      'https://api.twitter.com/oauth/authorize',     // resource owner authorization
      'https://api.twitter.com/oauth/access_token',  // token credentials request
      oauth1.SignatureMethods.hmacSha1              // signature method
  );

  // create Authorization object with client credentials and platform definition
  oauth1.Authorization auth;
  oauth1.AuthorizationResponse _res;

  Future flatPressed () async {
    print('twitter pressed');




    auth = new oauth1.Authorization(clientCredentials, platform);

    // request temporary credentials (request tokens)
    auth.requestTemporaryCredentials('oob').then((res) {
      // redirect to authorization page
      _res = res;
      print("Open with your browser: ${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}");
      setState(() {
        _message = "${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}";
      });
    });

    print('twitter done');
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          shrinkWrap: true,
          children: <Widget>[
            Text(
              'You have pushed the (+) button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            Text('Hello world!'),
            new GestureDetector(
              child: Text(
                '$_message',
                style: Theme.of(context).textTheme.display1,),
                onLongPress: () {
                  Clipboard.setData(new ClipboardData(text: '$_message'));
                }
            ),
            new OutlineButton(onPressed: flatPressed, child: new Text('Twitter'),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),

            ),
            TextField(
              controller: pinController,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'PLEASE ENTER YOUR PIN',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            new RaisedButton(
              child: const Text('Connect with Twitter'),
              color: Theme.of(context).accentColor,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                // Perform some action
                print('raised button pressed!');

                 String verifier = pinController.text;

                // request token credentials (access tokens)
                return auth.requestTokenCredentials(_res.credentials, verifier).then((res) {
                // yeah, you got token credentials
                // create Client object
                var client = new oauth1.Client(platform.signatureMethod, clientCredentials, res.credentials);

                // now you can access to protected resources via client
                client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
                print(res.body);
                setState(() {
                  _body = res.body;
                });
                });

                // NOTE: you can get optional values from AuthorizationResponse object
                print("Your screen name is " + res.optionalParameters['screen_name']);
                setState(() {
                // This call to setState tells the Flutter framework that something has
                // changed in this State, which causes it to rerun the build method below
                // so that the display can reflect the updated values. If we changed
                // _counter without calling setState(), then the build method would not be
                // called again, and so nothing would appear to happen.
                _message = "Your screen name is " + res.optionalParameters['screen_name'];
                });
                });

                print('twitter done');

              },
            ),
            RichText(
              text: TextSpan(
                text: '$_body',
                style: DefaultTextStyle.of(context).style,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}
