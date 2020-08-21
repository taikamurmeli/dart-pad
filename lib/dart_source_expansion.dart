// TODO: filter out those that can't possibly match function syntax (check if unnecessary parentheses can be applied)
const keywords = [
  // Cannot have parenthesis after: 'class','false','async','import','static',
  // 'show','as','enum','final','true'

  // Unchecked
  'in',
  'export','sync','extends','is','this','extension','library',
  'throw','break','external','mixin','case','factory','new','try',
  'null','typedef','on','var','const',
  'finally','operator','void','continue','part','covariant',
  'rethrow','with','default','get','return','yield','deferred','hide','set',
  'do','implements','toString',
  // Can have parenthesis after:
  'catch','else','switch','await','super','for','while','if','assert',
];


String _asyncAllFunctions(String dartSource) {

  final asyncedFunctions = [];

  // Make all non-async functions async and add them to foundFunctions
  var source = dartSource.replaceAllMapped(
      RegExp(r'(\b[\w<>]+)?\s*\b((\w+)\s*\(.*\))\s*{', multiLine: true), (match) {
    if (keywords.contains(match.group(3))) {
      return match.group(0);
    }
    asyncedFunctions.add(match.group(3));
    final typeDef = match.group(1) != null ?
    'Future<${match.group(1)}> ' : '';
    return '$typeDef${match.group(2)} async {';
  });

  // add await for any asynced functions
  asyncedFunctions.forEach((functionName) {
    source = source.replaceAllMapped(
        RegExp('\\b($functionName\\(.*\\))(?! async {)', multiLine: true), (match) {
      return 'await ${match.group(1)}';
    });
  });

  return source;
}

String expandDartSourceToAsyncSleep(String dartSource) {
    var source = _asyncAllFunctions(dartSource);
    const sleepFunc = 'await Future.delayed(Duration(milliseconds: 1), () => null);';

    const importRegex = '\\bimport\\s*["\'].+["\']\\s*';
}

String expandDartSourceToHandleInput(String dartSource) {
  const inputHandlerImports = "import 'dart:html';";
  const inputSimulationCode = '''
var stdin = SpoofInput() as dynamic;

class SpoofInput {
  var inputText = "";
  var promptDiv = new DivElement()
    ..id='prompt';
  final promptInput = new TextInputElement()
    ..placeholder='Kirjoita tekstiä tähän'
    ..id='prompt-input';

  @override
  noSuchMethod(invocation) =>
  print('stdin.\${invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '')} ei ole käytettävissä dartpadissa');

  handleInput(event) {
    if (event.keyCode == KeyCode.ENTER) {
      inputText = promptInput.value;
      promptDiv.remove();
    }
  }

  sleep(s) {
    final duration = Duration(seconds: s);
    return new Future.delayed(duration, () => s);
  }

  readLineSync() async {
    addInputElement();
    while (true) {
      if (querySelector('#prompt-input') == null) break;
      await sleep(1);
    }
    return inputText;
  }

  addInputElement() {
    promptDiv.style.padding = '8px';
    promptInput.style.width = '98%';

    document.body.append(promptDiv);
    promptDiv.append(promptInput);
    promptInput.onKeyPress.listen(handleInput);
    promptInput.select();
  }
}
''';

  // Add required inputs for input simulation
  var source = inputHandlerImports + dartSource;

  // add await for stdin calls
  source = source.replaceAllMapped(
      RegExp(r'\b(stdin\.)', multiLine: true), (match) {
    return 'await ${match.group(1)}';
  });

  source = _asyncAllFunctions(source);


  // Add input simulation code to dart source
  return source + inputSimulationCode;
}
