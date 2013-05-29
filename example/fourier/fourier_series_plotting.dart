/* *********************************************************** *
 *   Example using a websocket to retrieve data from a server  *
 *   and plotting that data to a browser window with canvas.   *
 *   Use in conjunction with the example from ConvoLab at:     *
 *   https://github.com/scribeGriff/ConvoLab/blob/master/      *
 *       example/fourier/fourier_series_sound.dart             *
 * *********************************************************** */

import 'package:convoweb/convoweb.dart';
import 'package:convolab/convolab.dart';

import 'dart:html';
import 'dart:async';

void main() {
  // Example retrieving data from server and plotting.
  String host = 'local';
  int port = 8080;
  Element display = query('#console');
  String request = 'Send data request';
  //Request the data from the server using a Future.
  Future reqData = requestDataWS(host, port, request, display);
  //We now have the data so lets plot it.
  //If desired, create a row vector to use as the xdata.
  //For example, suppose we have 512 samples at 22050 samples/sec.
  //Supplying xdata is optional.
  var sndLength = 512;
  var sndRate = 22050;
  var sndSample = sndLength / sndRate * 1e3;
  List xvec = vec(0, sndSample, sndSample / (sndLength - 1));
  reqData.then((data) {
    //Get the keys.  This is primarily done to allow sorting.
    List keys = data.keys.toList();
    //Sort keys if there is more than 1.
    if (data.length > 1) {
      keys.sort((a, b) => a.compareTo(b));
    }
    //Create a list to hold all the plots.
    List plots = new List(keys.length);
    //Plot the data using the plot() library function.
    for (var i = 0; i < keys.length; i++) {
      List waveform = data[keys[i]]["real"].sublist(0, 500);
      plots[i] = plot(waveform, style1: 'line', color1: 'green',
          range: keys.length, index: i+1);
      plots[i]
        ..grid()
        ..xlabel('time (samples)')
        ..ylabel('amplitude')
        ..title(keys[i]);
    }
    //Put the time stamp after the last plot.
    plots[plots.length - 1].date(true);
    //Save all plots as PNG image;
    WindowBase myPlotWindow = saveAll(plots);
    //Now put the time stamp with the first plot.
    plots[0].date();
    //Save just the first plot as a PNG image;
    plots[0].save();
  });
}
