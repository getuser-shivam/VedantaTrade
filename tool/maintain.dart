import 'dart:async';
import 'dart:io';

Future<void> main(List<String> args) async {
  final workspace = _findWorkspaceRoot();

  if (args.isEmpty || args.first == 'help' || args.first == '--help') {
    _printUsage();
    return;
  }

  final runner = _MaintenanceRunner(workspace);
  final command = args.first;
  final commandArgs = args.sublist(1);

  switch (command) {
    case 'check':
      await runner.check();
      return;
    case 'fix':
      await runner.fix();
      return;
    case 'build':
      await runner.build(commandArgs);
      return;
    case 'all':
      await runner.fix();
      await runner.check();
      await runner.build(commandArgs);
      return;
    case 'git-status':
      await runner.gitStatus();
      return;
    case 'git-save':
      await runner.gitSave(commandArgs);
      return;
    case 'git-push':
      await runner.gitPush(commandArgs);
      return;
    default:
      stderr.writeln('Unknown command: $command');
      _printUsage();
      exitCode = 64;
  }
}

class _MaintenanceRunner {
  _MaintenanceRunner(this.workspace);

  final Directory workspace;

  String get _flutterCmd => Platform.isWindows ? 'flutter.bat' : 'flutter';
  String get _dartCmd => Platform.isWindows ? 'dart.exe' : 'dart';
  String get _gitCmd => Platform.isWindows ? 'git.exe' : 'git';

  Future<void> check() async {
    _section('Checking app');
    await _run(_flutterCmd, ['pub', 'get']);
    await _run(_flutterCmd, ['analyze']);

    if (_hasDirectory('test')) {
      await _run(_flutterCmd, ['test']);
    } else {
      stdout
          .writeln('No top-level test directory found. Skipping flutter test.');
    }
  }

  Future<void> fix() async {
    _section('Applying safe fixes');
    await _run(_flutterCmd, ['pub', 'get']);
    await _run(_dartCmd, ['format', 'lib', 'tool']);

    if (_hasDirectory('test')) {
      await _run(_dartCmd, ['format', 'test']);
    }

    await _run(_dartCmd, ['fix', '--apply']);
  }

  Future<void> build(List<String> args) async {
    final target = args.isEmpty ? 'apk' : args.first;
    final buildArgs = <String>['build'];

    switch (target) {
      case 'apk':
      case 'appbundle':
      case 'web':
      case 'windows':
      case 'linux':
      case 'macos':
      case 'ios':
        buildArgs.add(target);
        break;
      default:
        stderr.writeln(
          'Unsupported build target "$target". Use apk, appbundle, web, windows, linux, macos, or ios.',
        );
        exitCode = 64;
        return;
    }

    if (args.length > 1) {
      buildArgs.addAll(args.sublist(1));
    }

    _section('Building app');
    await _run(_flutterCmd, buildArgs);
  }

  Future<void> gitStatus() async {
    _section('GitHub / Git status');
    await _run(_gitCmd, ['remote', '-v']);
    await _run(_gitCmd, ['status', '--short', '--branch']);
    await _run(_gitCmd, ['log', '--oneline', '-5']);
  }

  Future<void> gitSave(List<String> args) async {
    if (args.isEmpty) {
      stderr.writeln('git-save requires a commit message.');
      stderr.writeln(
          'Example: dart run tool/maintain.dart git-save "Update catalog"');
      exitCode = 64;
      return;
    }

    final message = args.join(' ').trim();
    if (message.isEmpty) {
      stderr.writeln('Commit message cannot be empty.');
      exitCode = 64;
      return;
    }

    _section('Creating git commit');
    await _run(_gitCmd, ['status', '--short', '--branch']);
    await _run(_gitCmd, ['add', '-A']);
    await _run(_gitCmd, ['commit', '-m', message]);
  }

  Future<void> gitPush(List<String> args) async {
    final remote = args.isNotEmpty ? args[0] : 'origin';
    final branch = args.length > 1 ? args[1] : 'HEAD';

    _section('Pushing to GitHub');
    await _run(_gitCmd, ['push', remote, branch]);
  }

  Future<void> _run(String executable, List<String> arguments) async {
    stdout.writeln('\$ $executable ${arguments.join(' ')}');

    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workspace.path,
    );

    final stdoutFuture = stdout.addStream(process.stdout);
    final stderrFuture = stderr.addStream(process.stderr);
    final code = await process.exitCode;
    await Future.wait([stdoutFuture, stderrFuture]);

    if (code != 0) {
      throw ProcessException(executable, arguments, 'Command failed', code);
    }
  }

  bool _hasDirectory(String path) {
    return Directory('${workspace.path}${Platform.pathSeparator}$path')
        .existsSync();
  }

  void _section(String title) {
    stdout.writeln('');
    stdout.writeln('== $title ==');
  }
}

Directory _findWorkspaceRoot() {
  var current = Directory.current.absolute;

  while (true) {
    final pubspec =
        File('${current.path}${Platform.pathSeparator}pubspec.yaml');
    final gitDir = Directory('${current.path}${Platform.pathSeparator}.git');

    if (pubspec.existsSync() && gitDir.existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      return Directory.current.absolute;
    }

    current = parent;
  }
}

void _printUsage() {
  stdout.writeln('''
VedantaTrade maintenance CLI

Usage:
  dart run tool/maintain.dart <command> [arguments]

Commands:
  help
      Show this help output.

  check
      Run flutter pub get, flutter analyze, and flutter test when tests exist.

  fix
      Run flutter pub get, format the codebase, and apply dart fix suggestions.

  build [target] [extra flutter build args...]
      Build the app. Default target is apk.
      Supported targets: apk, appbundle, web, windows, linux, macos, ios
      Example:
        dart run tool/maintain.dart build web --release

  all [target] [extra flutter build args...]
      Run fix, check, and build in sequence.

  git-status
      Show git remotes, status, and recent commits for the GitHub repo.

  git-save <commit message>
      Stage all changes and create a git commit.

  git-push [remote] [branch]
      Push to GitHub. Defaults to: origin HEAD
''');
}
