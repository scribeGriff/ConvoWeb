/* *********************************************************** *
 *   ConvoWeb: A signal processing web application in Dart     *
 *   https://github.com/scribeGriff/ConvoWeb                   *
 *   Library: ConvoWeb (c) 2012 scribeGriff                    *
 * *********************************************************** */

#library ('convoweb');

#import ('dart:html');
#import ('dart:json');
#import ('dart:math');

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
  String host = 'local';
  int port = 8080;
  var display = query('#console');
  var request = 'Send data request';
  //Request the data from the server using a Future.
  Future reqData = requestDataWS(host, port, request, display);
  //We now have the data so lets plot it.
  reqData.then((data) {
    //Get the keys.  This is primarily done to allow sorting.
    var keys = data.getKeys();
    //Sort keys if there is more than 1.
    if (data.length > 1) {
      keys.sort((a, b) => a.compareTo(b));
    }
    //Create a list to hold all the plots.
    var plots = new List(keys.length);
    //Plot the data using the plot() library function.
    for (var i = 0; i < keys.length; i++) {
      List waveform = data[keys[i]]["real"].getRange(0, 500);
      plots[i] = plot(waveform, style: 'line', color: 'green',
          range: keys.length, index: i+1);
      plots[i]
        ..grid()
        ..xlabel('time (samples)')
        ..ylabel('amplitude')
        ..title(keys[i]);
    }
    //Put the time stamp after the last plot.
    plots[keys.length - 1].date(true);
    //Save last plot as a PNG image;
    plots[keys.length - 1].save();
    //Save all plots as PNG image;
    var myPlotWindow = saveAll(plots);
  });
}