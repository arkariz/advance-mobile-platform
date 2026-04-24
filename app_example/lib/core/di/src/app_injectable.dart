import 'package:injectable/injectable.dart';

@InjectableInit(
  initializerName: r'$appInjectableInit',
  preferRelativeImports: true,
  asExtension: true,
  generateForDir: ['lib'],
)
// ignore: unused_element
void _appInjectableInit() {}