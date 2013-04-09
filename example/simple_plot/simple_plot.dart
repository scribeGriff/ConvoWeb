import 'package:convoweb/convoweb.dart';
import 'package:convolab/convolab.dart';

import 'dart:html';

void main() {
  // Simple test of scatter plot.
  var xydata = [[3, 4], [6, 5], [12, 1], [9, -2], [0, 7.5], [7, 0], [1, 3.3]];

  // Create the x and y data.
  var xval = xydata.map((x) => x.elementAt(0)).toList();
  var yval = xydata.map((y) => y.elementAt(1)).toList();
  // Plot data as an xy plot of points.
  var scatter = plot(yval, xdata:xval, style:'points', color:'blue');
  scatter.grid();
  scatter.xlabel('sample x data');
  scatter.ylabel('sample y data');
  scatter.title('Example of Scatter Plot');
  scatter.date();
}

