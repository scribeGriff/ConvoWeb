// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

part of convoweb;

/**
 * Class Plot2D plots data with canvas element in 2D
 * If xdata not specified, a vector is generated equivalent
 * to the size of ydata in units from 1 to ydata.length.
 * Current styles supported:
 * *data (default),
 * *points,
 * *line,
 * *linpts (line with points)
 * Variable r is the range which specifies how many subplots (1 - 4).
 * Variable i is the index of the subplot (1 - 4).
 * Supported methods are:
 *     grid(),
 *     xlabel(String xlabelName, [String labelColor]),
 *     ylabel(String ylabelName, [String labelColor]),
 *     title(String title, [String titleColor]),
 *     date([bool short])
 *     save()
 * Usage (given a List of numbers called real):
 *     var p1 = plot(real);
 *     p1.grid();
 *     p1.xlabel('Samples (n)');
 *     p1.ylabel('data');
 *     p1.title('Example of Plotting Sampled Data');
 *     p1.date();
 *     p1.save();
 *
 */

// Use plot as a wrapper to private class _Plot2D.
Plot2D plot(List ydata, {List xdata: null, String style: 'data',
  String color: 'black', int range: 1, int index: 1, bool large: true,
  String container: '#graph'}) {
  final gphSize = 600;
  final border = 100;
  final width = gphSize;
  final scalePlot = large ? 2 : range;
  final height = range == 1 ? gphSize : (gphSize * 1.5 / scalePlot).toInt();
  var graphContainer = query(container);
  CanvasElement plotCanvas = new CanvasElement();
    plotCanvas.attributes = ({
      "id": "plotCanvas$index",
      "class": "plotCanvas",
      "width": "$width",
      "height": "$height",
    });
  graphContainer.nodes.add(plotCanvas);
  CanvasRenderingContext2D context = plotCanvas.context2d;
  context.fillStyle = 'white';
  context.fillRect(0, 0, width, height);
  context.fillStyle = 'black';

  //If no xdata was passed, create a row vector
  //based on the length of ydata.
  if (xdata == null) xdata = vec(1, ydata.length);
  return new Plot2D(context, ydata, xdata, style, color, width, height);
}

class Plot2D {
  AxisConfigResults yAxisCfg;
  AxisConfigResults xAxisCfg;

  final border;
  final borderL;
  final borderT;
  final tickSize;
  final index;

  CanvasRenderingContext2D context;
  List xdata, ydata;
  String style, color;
  num width, height;
  num xmin, xmax, xdiv, xstep;
  num ymin, ymax, ydiv, ystep;

  Plot2D(this.context, this.ydata, this.xdata, this.style, this.color,
      this.width, this.height)
      : border = 100,
        borderL = 80,
        borderT = 50,
        tickSize = 5,
        index = 0 {

    num tickPt;

    //Compute optimum divisions of axes.
    xAxisCfg = new AxisConfig().axes(xdata, width - border);
    yAxisCfg = new AxisConfig().axes(ydata, height - border);

    xmin = xAxisCfg.min;
    xmax = xAxisCfg.max;
    xdiv = xAxisCfg.div;
    xstep = xAxisCfg.step;
    ymin = yAxisCfg.min;
    ymax = yAxisCfg.max;
    ydiv = yAxisCfg.div;
    ystep = yAxisCfg.step;

    var
      offset = style == 'data' ? xdiv / xstep : xdiv,
      increment = style == 'data' ? 1 : xstep;

    //Draw the graph outline.
    context
      ..strokeStyle = "rgb(85, 98, 112)"    //"#556270"
      ..lineCap = "round"
      ..strokeRect(borderL, borderT, width - border, height - border, 2)
      ..lineWidth = 1;

    //Create tick marks on x axis.
    for (var i = borderL + offset; i < width - (border - borderL); i += offset) {
      context
        //bottom ticks
        ..beginPath()
        ..moveTo(i.toInt() + 0.5, height - borderT)
        ..lineTo(i.toInt() + 0.5, height - borderT - tickSize)
        ..stroke()
        //top ticks
        ..moveTo(i.toInt() + 0.5, borderT + tickSize)
        ..lineTo(i.toInt() + 0.5, borderT)
        ..stroke();
    }

    //Add labels to the x axis tick marks.
    context
      ..textAlign = 'center'
      ..font = '10pt Consolas';
    tickPt = xmin;
    if (xstep == xstep.toInt()) {
      for (var j = xmin; j <= xmax; j += increment) {
        context.fillText(j.toInt().toString(), borderL + ((j - xmin)/increment) * offset,
            height - borderT + (borderT / 3));
        tickPt += increment;
      }
    } else {
      // Need test cases for exponent, precision, fixed number labels.
      for (var j = xmin; j <= xmax; j += increment) {
        context.fillText(j.toString(), borderL + ((j - xmin)/increment) * offset,
            height - borderT + (borderT / 3));
        tickPt += increment;
      }
    }

    //Create tick marks on y axis.
    for (var i = height - borderT - ydiv; i > borderT; i -= ydiv) {
      context
        //left ticks
        ..moveTo(borderL, i.toInt() + 0.5)
        ..lineTo(borderL + tickSize, i.toInt() + 0.5)
        ..stroke()
        //right ticks
        ..moveTo(width - (border - borderL), i.toInt() + 0.5)
        ..lineTo(width - (border - borderL) - tickSize, i.toInt() + 0.5)
        ..stroke();
    }

    //Add labels to the y axis tics.
    context
      ..font = '10pt Consolas'
      ..textAlign = 'right';
    tickPt = ymin;
    if (ystep == ystep.toInt()) {
      for (var i = height - borderT; i > borderT - ydiv / 2; i -= ydiv) {
        context.fillText(tickPt.toInt().toString(), borderL - tickSize, i.toInt());
        tickPt += ystep;
      }
    } else {
      // Need test cases for exponent, precision, fixed number labels.
      var numDigits = 2;
      if (ymax < 0.01) numDigits = 3;
      for (var i = height - borderT; i > borderT - ydiv / 2; i -= ydiv) {
        context.fillText(tickPt.toStringAsFixed(numDigits), borderL - tickSize, i.toInt());
        tickPt += ystep;
      }
    }

    //Plot the data.
    context.strokeStyle = color;
    if (style == 'data') {
      context.lineWidth = 2;
      //Add the data.
      for (var j = 0; j < xdata.length; j++) {
        var i = borderL + (((xdata[j]) - xmin)/xstep * xdiv);
        context
          //sample data
          ..beginPath()
          ..moveTo(i.toInt(), height - borderT)
          ..lineTo(i.toInt(), height - borderT - (((ydata[j]) - ymin) / ystep * ydiv))
          ..stroke()
          //sample points
          ..beginPath()
          ..arc(i.toInt(), height - borderT - (((ydata[j]) - ymin) / ystep * ydiv),
              4, 0, 2 * PI, false)
          ..closePath()
          ..stroke();
      }
    } else if (style == 'points') {
      context.lineWidth = 3;
      for (var j = 0; j < xdata.length; j++) {
        var i = borderL + (((xdata[j]) - xmin)/xstep * xdiv);
        context
          //sample points
          ..beginPath()
          ..arc(i.toInt(), height - borderT - (((ydata[j]) - ymin) / ystep * ydiv),
              4, 0, 2 * PI, false)
          ..closePath()
          ..stroke();
      }
    } else if (style == 'line' || style == 'linpts') {
      var a, b, c, d;
      context
        ..lineWidth = 4
        ..beginPath()
        ..lineJoin = "round"
        ..moveTo(borderL + (((xdata[index]) - xmin) / xstep * xdiv),
            height - borderT - (((ydata[index]) - ymin) / ystep * ydiv));
      for (var j = 1; j < xdata.length - 2; j++) {
        a = borderL + ((xdata[j] - xmin) / xstep * xdiv);
        b = borderL + ((xdata[j + 1] - xmin) / xstep * xdiv);
        c = height - borderT - (((ydata[j]) - ymin) / ystep * ydiv);
        d = height - borderT - (((ydata[j + 1]) - ymin) / ystep * ydiv);
        context.quadraticCurveTo(a, c, (a + b) / 2, (c + d) / 2);
      }
      a = borderL + ((xdata[xdata.length - 2] - xmin) / xstep * xdiv);
      b = borderL + ((xdata[xdata.length - 1] - xmin) / xstep * xdiv);
      c = height - borderT - (((ydata[xdata.length - 2]) - ymin) / ystep * ydiv);
      d = height - borderT - (((ydata[xdata.length - 1]) - ymin) / ystep * ydiv);
      context
        ..quadraticCurveTo(a, c, b, d)
        ..stroke();

      if (style == 'linpts') {
        //Add sample points.
        for (var j = 0; j < xdata.length; j++) {
          var i = borderL + ((xdata[j] - xmin)/xstep * xdiv);
          context
            ..beginPath()
            ..arc(i.toInt(), height - borderT - (((ydata[j]) - ymin) / ystep * ydiv),
                4, 0, 2 * PI, false)
            ..closePath()
            ..fill();
        }
      }
    }
  }

  //Method for adding a grid.
  void grid() {
    var offset = style == 'data' ? xdiv / xstep : xdiv;
    context.lineWidth = 1;
    for (var i = borderL + offset; i < width - (border - borderL); i += offset) {
      for (var j = height - borderT - ydiv; j > borderT; j -= ydiv) {
        context
          ..beginPath()
          ..arc(i.toInt() + 0.5, j.toInt() + 0.5, 1, 0, 2 * PI, false)
          ..closePath()
          ..fill();
      }
    }
  }

  //Method for adding a label to the x axis.
  void xlabel(String xlabelName, [String labelColor = 'rgb(85, 98, 112)']) {
    context
      ..strokeStyle = labelColor
      ..font = '12pt Candara'
      ..textAlign = 'center'
      ..fillText(xlabelName, ((width  + (2 * borderL) - border)/ 2),
          height - borderT / 10);
  }

  //Method for adding a label to the y axis.
  //TODO: This needs a way of detecting how much room is available
  //relative to the size of the tick labels.  If they take up too much
  //room (ie, numbers like 1.20e+12), then may need to place the y axis
  //label above the tick marks (ie, upper left corner).
  void ylabel(String ylabelName, [String labelColor = 'rgb(85, 98, 112)']) {
    var
      lblWidth = context.measureText(ylabelName),
      deltax = borderL / 4,
      deltay = height / 2;
    context
      ..strokeStyle = labelColor
      ..font = '12pt Candara'
      ..textAlign = 'center'
      ..save()
      ..translate(deltax, deltay)
      ..rotate(-PI / 2)
      ..translate(-deltax, -deltay)
      ..fillText(ylabelName, 0, height / 2)
      ..restore();
  }

  //Method for adding a title.
  void title(String title, [String titleColor = 'rgb(85, 98, 112)']) {
    context
      ..strokeStyle = titleColor
      ..textAlign = 'center'
      ..font = '16pt Candara'
      ..fillText(title, ((width  + (2 * borderL) - border)/ 2), borderT / 2);
  }

  //Method for adding a date stamp.
  void date([bool short = false]) {
    String dateTime = new TimeStamp().stamp(short);
    context
      ..textAlign = 'right'
      ..font = '10pt Candara'
      ..fillText(dateTime, width, height - tickSize);
  }

  //Method for saving a single plot as a PNG image.
  void save() {
    window.open(context.canvas.toDataUrl('image/png'), 'plotWindow');
  }
}

/*********************************************************************** *
 * Function saveAll(List plots) create a new canvas and adds all         *
 * the plot canvas from the list.  It then creates a new window which    *
 * contains a PNG image of all the plots to allow for saving.            *
 *                                                                       *
 * ********************************************************************* */
WindowBase saveAll(List plots, {num scale: 1.0}) {
  int width = (plots[0].context.canvas.width * scale).toInt();
  int height = (plots[0].context.canvas.height * scale).toInt();
  CanvasElement plotAllCanvas = new CanvasElement(width:width, height:height);
  final margin = 20;
  plotAllCanvas.attributes = ({
    "id": "plotAllCanvas",
    "class": "plotAllCanvas",
    "width": "$width",
    "height": "${plots.length * (height + margin)}",
  });
  CanvasRenderingContext2D contextAll = plotAllCanvas.context2d;
  for (var i = 0; i < plots.length; i++) {
    contextAll.drawImage(plots[i].context.canvas, 0, i * (height + margin));
  }
  return window.open(contextAll.canvas.toDataUrl('image/png'), 'plotAllWindow');
}
