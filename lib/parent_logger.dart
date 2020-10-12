import 'dart:html' hide Document, Console;


class ParentLogger {
  final _iFrameId;

  ParentLogger(this._iFrameId);

  Map _logMessage(type, action) {
    return {
      'log': {
        'type': type,
        'action': action
      },
      'frameId': _iFrameId
    };
  }

  void logCodeExecution() {
    window.parent.postMessage(_logMessage('button click', 'execute'), '*');
  }

  void logCodeFormat() {
    window.parent.postMessage(_logMessage('button click', 'format'), '*');
  }
}
