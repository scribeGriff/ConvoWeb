part of convoweb;

/* ********************************************************************* *
 *   Future requestDataWS()                                              *
 *   Library: ConvoWeb (c) 2012 scribeGriff                              *
 *   Connect to server through a websocket                               *
 *   Usage:                                                              *
 *     String host = 'local';                                            *
 *     int port = 8080;                                                  *
 *     var display = query('#console');                                  *
 *     var request = 'Send data request';                                *
 *     Future reqData = requestDataWS(host, port, request, display);     *
 *     reqData.then((data) {                                             *
 *       List real = data["real"];                                       *
 *       List imag = data["imag"];                                       *
 *       plot(real);                                                     *
 *     });                                                               *
 *                                                                       *
 * ********************************************************************* */

Future requestDataWS(String host, int port, var req, [Element display = null]) {
  Completer _c = new Completer();
  if (host == 'local') host = '127.0.0.1';
  WebSocket _ws = new WebSocket('ws://$host:$port/ws');

  if (display != null) {
    display.addHTML('Opening connection at $host:$port');
  }
  _ws.on.open.add((Event opn) {
    Date sent = new Date.fromMillisecondsSinceEpoch(opn.timeStamp);
    String request = JSON.stringify({"request": req, "date": '$sent'});
    _ws.send(request);
  });

  _ws.on.close.add((CloseEvent cls) {
    if (display != null) {
      if (cls.wasClean) {
        display.addHTML('Connection closed satisfactorily');
      } else {
        display.addHTML('Connection closed but an error occurred.');
      }
    }
  });

  _ws.on.error.add((ErrorEvent err) {
    if (display != null) {
      display.addHTML('There was an error with the connection: ${err.message}');
    }
    _c.complete(null);
  });

  _ws.on.message.add((MessageEvent msg) {
    var data = JSON.parse(msg.data);
    if (display != null) {
      display.addHTML('Successfully received data from the server. <br/>');
    }
    _ws.close(1000, 'Got the data.  Thanks!');
    _c.complete(data);
  });

  return _c.future;
}
