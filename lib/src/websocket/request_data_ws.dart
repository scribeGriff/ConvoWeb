// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

part of convoweb;

/**
 *   Future requestDataWS() connects to server through a websocket.
 *   Usage:
 *     String host = 'local';
 *     int port = 8080;
 *     var display = query('#console');
 *     var request = 'Send data request';
 *     Future reqData = requestDataWS(host, port, request, display);
 *     reqData.then((data) {
 *       List real = data["real"];
 *       List imag = data["imag"];
 *       plot(real);
 *     });
 *
 */

Future requestDataWS(String host, int port, var req, [Element display = null]) {
  Completer _c = new Completer();
  if (host == 'local') host = '127.0.0.1';
  WebSocket _ws = new WebSocket('ws://$host:$port/ws');

  if (display != null) {
    display.appendHtml('Opening connection at $host:$port<br/>');
  }
  _ws.onOpen.listen((Event opn) {
    DateTime sent = new DateTime.fromMillisecondsSinceEpoch(opn.timeStamp);
    String request = json.stringify({"request": req, "date": '$sent'});
    _ws.send(request);
  });

  _ws.onClose.listen((CloseEvent cls) {
    if (display != null) {
      if (cls.wasClean) {
        display.appendHtml('Connection closed satisfactorily.<br/>');
      } else {
        display.appendHtml('Connection closed but an error occurred.<br/>');
      }
    }
  });

  _ws.onError.listen((ErrorEvent err) {
    if (display != null) {
      display.appendHtml('There was an error with the connection: ${err.message}<br/>');
    }
    _c.complete(null);
  });

  _ws.onMessage.listen((MessageEvent msg) {
    var data = json.parse(msg.data);
    if (display != null) {
      display.appendHtml('Successfully received data from the server. <br/>');
    }
    _ws.close(1000, 'Got the data.  Thanks!');
    _c.complete(data);
  });

  return _c.future;
}
