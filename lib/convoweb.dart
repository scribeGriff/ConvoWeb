/* *********************************************************** *
 *   ConvoWeb: A signal processing web application in Dart     *
 *   https://github.com/scribeGriff/ConvoWeb                   *
 *   Library: ConvoWeb (c) 2012 scribeGriff                    *
 * *********************************************************** */

#library('convoweb');
#import('dart:html');
#import('dart:json');
#import('dart:math');

#source('utilities/html_dom.dart');
#source('utilities/axis_config_results.dart');
#source('utilities/date_time.dart');
#source('websocket/request_data_ws.dart');
#source('ui/tabbed_panel.dart');
#source('math/find_min_max.dart');
#source('math/logarithm.dart');
#source('math/row_vector.dart');
#source('visualization/axis_config.dart');
#source('visualization/plot2d.dart');

void main() {
  // Example retrieving data from server and plotting.
  // Websocket not currently working in build 12144.  Under investigation.
  String host = 'local';
  int port = 8080;
  var display = query('#console');
  var request = 'Send data request';
  Future reqData = requestDataWS(host, port, request, display);
  reqData.then((data) {
    List real = data["real"];
    List waveform = real.getRange(0, 500);
    var p1 = plot(waveform, style: 'line', color: 'green');
    p1
      ..grid()
      ..xlabel('time')
      ..ylabel('amplitude')
      ..title('Waveform Generator')
      ..date(true);
    });
}