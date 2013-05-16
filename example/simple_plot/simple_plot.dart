// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

library simplot_example;

import 'package:convoweb/convoweb.dart';
import 'package:convolab/convolab.dart';
import 'dart:html';
import 'dart:math';

void main() {
  var allPlots = new List();
  var randNum = new Random();

  // Plot #1: Scatter plot example.
  var fat_calories = [[9, 260],
                      [13, 320],
                      [21, 420],
                      [30, 530],
                      [31, 560],
                      [31, 550],
                      [34, 590],
                      [25, 500],
                      [28, 560],
                      [20, 440],
                      [5, 300]];
  // Best fit line for the above data: y = 11.7313x + 193.852
  // Create the x and y scatter data.
  var xscatter = fat_calories.map((x) => x.elementAt(0)).toList();
  var yscatter = fat_calories.map((y) => y.elementAt(1)).toList();
  var bestFit = xscatter.map((x) => (11.7313 * x) + 193.852).toList();

  // Plot data as an xy plot of points.
  var myScatter = plot(yscatter, xdata:xscatter, style1:'points', color1:'#3C3D36',
      y2:bestFit, style2:'line', color2: '#90AB76', range:4, index:1);
  myScatter
    ..grid()
    ..xlabel('total fat (g)', color: '#3C3D36')
    ..ylabel('total calories', color: '#3C3D36')
    ..legend(l1: 'Calories from fat', l2: 'best fit: 11.7x + 193', top:false)
    ..title('Correlation of Fat and Calories in Fast Food', color: 'black');
  // Add scatter plot to the allPlots array.
  allPlots.add(myScatter);

  //Plot #2: Plotting sample data with a line graph of uneven lengths.
  var yrand1 = new List.generate(15, (var index) => randNum.nextInt(12), growable:false);
  var yrand2 = new List.generate(12, (var index) => randNum.nextInt(12), growable:false);
  var ydiff = new List(yrand2.length);
  for (var i = 0; i < yrand2.length; i++) {
    ydiff[i] = ((yrand1[i] - yrand2[i]).abs());
  }

  var resistance = [77.98, 104.23, 107.9, 74.61, 73.54, 91.63, 100.54, 85.19,
                    81.46, 87.64, 69.26, 90.86, 100.15, 95.24, 72.26, 74.86,
                    84.68, 93.61, 102.54, 103.18, 94.03, 87.13, 85.03, 66.59,
                    82.45, 81.66, 81.4, 81.58, 84.71];

  var inductance = [97.993, 136.77, 142.215, 93.1, 90.956, 117.34, 131.299,
                    108.633, 103.196, 112.219, 85.533, 116.96, 130.688,
                    123.414, 89.781, 93.508, 107.893, 121.004, 134.263, 135.15,
                    121.547, 111.277, 108.154, 81.526, 104.312, 103.11, 102.674,
                    102.915, 107.367];

  var capacitance = [88.52, 123.02, 114.13, 79.69, 78.06, 98.84, 100.09, 79.69,
                     75.69, 82.13, 63.36, 85.74, 97.07, 93.29, 74.33, 74.98,
                     78.84, 103.8, 109.18, 111.45, 107.04, 94.02, 93.01, 67.72,
                     89.42, 83.06, 79.6, 83.1, 87.73];

  var myLines = plot(resistance, y2:inductance, y3:capacitance, range:4, index:2);
  myLines
    ..grid()
    ..xlabel('Network (n)')
    ..ylabel('Impedance')
    ..title('RLC Impedance Values for 29 Path Network')
    ..legend(l1:'R (mOhms)', l2:'L (10^-2 nH)', l3: 'C (10^-3 pF)')
    ..xmarker(20, true)
    ..xmarker(4, true);
  allPlots.add(myLines);

  var xdata = new List.generate(11, (var index) => index * 0.1, growable:false);
  var ydata = [];
  xdata.forEach((element) => ydata.add(pow(element, 2)));
  var testplot = plot(ydata, xdata:xdata, style1:'points', range:4, index:3);

  var testplot2 = plot(yrand1, range:4, index:4);
  //WindowBase myPlotWindow = saveAll(allPlots);
}
