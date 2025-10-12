import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

Future<void> main(List<String> arguments) async {
  final runner = GexdCommandRunner();

  ProcessSignal.sigint.watch().listen((_) {
    stdout.writeln('\n🛑 Operation cancelled by user.');
    flushThenExit(ExitCode.software.code);
  });

  try {
    final code = await runner.run(arguments);
    await flushThenExit(code);
  } catch (e, st) {
    stderr.writeln('❌ Unhandled exception: $e');
    stderr.writeln(st);
    await flushThenExit(ExitCode.software.code);
  }
}

Future<void> flushThenExit(int status) async {
  await stdout.flush();
  await stderr.flush();
  exit(status);
}
