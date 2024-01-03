# cmd_test
using
```process_run: ^0.13.3```
process run package is used to get 'outText'.
Alternatively can use stdout of Process.

this code makes .venv python virtual environment, and install numpy on it.

## cmd example
```dart
await Process.run("python", ["-m", "venv", ".venv"], workingDirectory: "./pysupport",
      runInShell: true);
```
this code runs ```python -m venv .venv```

## run in virtual environment
using ```env``` parameter, code can run in virtual environment.
function getting virtual environment is defined as ```getEnvironment()``` at m```main.dart```.
### example
```dart
var env = await getEnvironment();

await Process.run(
        commandHead, commandSplit, workingDirectory: "./pysupport",
        environment: env,
        runInShell: true);
```
