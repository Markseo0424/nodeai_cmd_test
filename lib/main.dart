import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:process_run/shell.dart';

Future getData(url, data) async {
  //Response response = await get(Uri.parse(url));

  var body = json.encode(data);

  Response response = await post(Uri.parse(url),
    body: {'name':body});
  return response.body;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String outText = "";
  String errText = "";

  StreamController<String> controller = StreamController<String>.broadcast();
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController_dir = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() async {
    if(_counter == 0) {
      // Process.run('flask', ['run'],
      //     workingDirectory: 'C:\\Users\\marks\\Documents\\PyCharm\\flask_tuto',
      //     runInShell: true);
    }
    else {
      Map data = {
        'value' : _counter.toString()
      };
      var response = await getData('http://127.0.0.1:5000/post', data);

      //var decodedData = jsonDecode(data);
      //print(decodedData);
    }

    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                await Process.run("mkdir", ["pysupport"],
                    runInShell: true);
                await Process.run("python", ["-m", "venv", ".venv"], workingDirectory: "./pysupport",
                    runInShell: true);

                var env = await getEnvironment();

                var response = await Process.run("pip", ["install", "numpy"], workingDirectory: "./pysupport", environment: env,
                    runInShell: true);

              },
              child: Text("create environment"),
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _textEditingController_dir,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Dir',
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _textEditingController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Command',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                print(_textEditingController.text);
                String command = _textEditingController.text;
                List<String> commandSplit = command.split(" ");
                String commandHead = commandSplit.removeAt(0);

                var env = await getEnvironment();

                var response = await Process.run(commandHead, commandSplit,workingDirectory: _textEditingController_dir.text, environment: env,
                    runInShell: true);

                setState(() {
                  outText = response.outText;
                  errText = response.errText;
                });
              },
              child: Text("execute"),
            ),
            Text(outText),
            Text(errText),
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<Map<String, String>> getEnvironment() async {
  var isPromptDeclared = await Process.run("if", ["defined","PROMPT","echo","1"], workingDirectory: "./pysupport",
      runInShell: true);
  var promptResponse = await Process.run("echo", ["%PROMPT%"], workingDirectory: "./pysupport",
      runInShell: true);

  String prompt = isPromptDeclared.outText == "1"? promptResponse.outText : "\$P\$G";

  var isOldVirtualPromptDeclared = await Process.run("if", ["defined","_OLD_VIRTUAL_PROMPT","echo","1"], workingDirectory: "./pysupport",
      runInShell: true);
  if(isOldVirtualPromptDeclared.outText == "1") {
    var oldVirtualPromptResponse = await Process.run("echo", ["%_OLD_VIRTUAL_PROMPT%"],workingDirectory: "./pysupport",
        runInShell: true);
    prompt = oldVirtualPromptResponse.outText;
  }

  String oldVirtualPrompt = prompt;
  prompt = "(.venv) $prompt";
  String virtualEnvPrompt = "(.venv)";

  var isPythonHomeDeclared = await Process.run("if", ["defined","PYTHONHOME","echo","1"], workingDirectory: "./pysupport",
      runInShell: true);
  var pythonHomeResponse = await Process.run("echo", ["%PYTHONHOME%"], workingDirectory: "./pysupport",
      runInShell: true);
  var oldPythonHomeResponse = await Process.run("echo", ["%_OLD_VIRTUAL_PYTHONHOME%"], workingDirectory: "./pysupport",
      runInShell: true);

  String oldVirtualPythonHome = isPythonHomeDeclared.outText=="1"? pythonHomeResponse.outText : oldPythonHomeResponse.outText;
  String pythonHome = "";

  var envResponse = await Process.run("cd", [],workingDirectory: "./pysupport",
      runInShell: true);

  var isOldVirtualPathDeclared = await Process.run("if", ["defined","_OLD_VIRTUAL_PATH","echo","1"], workingDirectory: "./pysupport",
      runInShell: true);
  var oldVirtualPathResponse = await Process.run("echo", ["%_OLD_VIRTUAL_PATH%"],workingDirectory: "./pysupport",
      runInShell: true);
  var pathResponse = await Process.run("echo", ["%PATH%"],workingDirectory: "./pysupport",
      runInShell: true);

  String path = isOldVirtualPathDeclared.outText == "1"? oldVirtualPathResponse.outText : pathResponse.outText;
  String oldVirtualPath = isOldVirtualPathDeclared.outText == "1"? oldVirtualPathResponse.outText : pathResponse.outText;

  String virtualEnv = "${envResponse.outText}\\.venv";

  path = "$virtualEnv\\Scripts;$path";

  Map<String,String> env = {
    "VIRTUAL_ENV" : virtualEnv,
    "PROMPT" : prompt,
    "_OLD_VIRTUAL_PROMPT" : oldVirtualPrompt,
    "PYTHONHOME" : pythonHome,
    "_OLD_VIRTUAL_PYTHONHOME" : oldVirtualPythonHome,
    "PATH" : path,
    "_OLD_VIRTUAL_PATH" : oldVirtualPath,
    "VIRTUAL_ENV_PROMPT" : virtualEnvPrompt
  };

  return env;
}

Future<void> createEnvironment(List<String> installCommands) async {
  await Process.run("mkdir", ["pysupport"],
      runInShell: true);
  await Process.run("python", ["-m", "venv", ".venv"], workingDirectory: "./pysupport",
      runInShell: true);

  var env = await getEnvironment();

  for(int i = 0; i < installCommands.length; i++) {
    List<String> commandSplit = installCommands[i].split(" ");
    String commandHead = commandSplit.removeAt(0);
    await Process.run(
        commandHead, commandSplit, workingDirectory: "./pysupport",
        environment: env,
        runInShell: true);
  }
}