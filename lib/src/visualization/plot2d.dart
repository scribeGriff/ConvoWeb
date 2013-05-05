// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

part of convoweb;

/**
 * A simple, 2D plotting class for plotting data to an HTML canvas.
 * If xdata not specified, a vector is generated equivalent
 * to the size of ydata in units from 1 to ydata.length.
 * Current styles supported:
 * *data (default)
 * *points
 * *curve
 * *curvepts
 * *line
 * *linepts (line with points)
 *
 * Variable r is the range which specifies how many subplots (1 - 4).
 * Variable i is the index of the subplot (1 - 4).
 * Supported methods are:
 *     grid(),
 *     xlabel(String xlabelName, [String labelColor]),
 *     ylabel(String ylabelName, [String labelColor]),
 *     title(String title, [String titleColor]),
 *     date([bool short])
 *     legend()
 *     xcursor()
 *     save()
 * Usage (given a List of numbers called real):
 *     var p1 = plot(real);
 *     p1.grid();
 *     p1.xlabel('Samples (n)');
 *     p1.ylabel('data');
 *     p1.title('Example of Plotting Sampled Data');
 *     p1.date();
 *     p1.legend();
 *     p1.xcursor();
 *     p1.save();
 *
 * Includes a top level function, saveAll() for saving a group of subplots.
 */

// Use plot as a wrapper to class Plot2D.
Plot2D plot(List y1, {
    List xdata: null,
    List y2: null,
    List y3: null,
    List y4: null,
    String style: 'data',
    String color1: 'black',
    String color2: 'green',
    String color3: 'blue',
    String color4: 'red',
    int range: 1,
    int index: 1,
    bool large: true,
    String container: '#graph'}) {
  final gphSize = 600;
  final border = 80;
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
  //based on the length of y1.
  if (xdata == null) {
    xdata = new List.generate(y1.length, (var index) =>
        index + 1, growable:false);
  }
  //Build a HashMap of the all the y axis data.
  LinkedHashMap ydata = new LinkedHashMap();
  ydata["y1"] = y1;
  ydata["y2"] = y2;
  ydata["y3"] = y3;
  ydata["y4"] = y4;
  //Build a HashMap of the corresponding colors for the plots.
  LinkedHashMap color = new LinkedHashMap();
  color["y1"] = color1;
  color["y2"] = color2;
  color["y3"] = color3;
  color["y4"] = color4;

  //Return the Plot2D object.
  return new Plot2D(context, ydata, xdata, color, style, width, height);
}

//Plot2D class configures the axes and plots the data.
class Plot2D {
  _AxisConfigResults yAxisCfg;
  _AxisConfigResults xAxisCfg;

  final border;
  final borderL;
  final borderT;
  final tickSize;
  final index;

  CanvasRenderingContext2D context;
  LinkedHashMap ydata, color;
  List xdata;
  String style;
  num width, height;
  num xmin, xmax, xdiv, xstep;
  num ymin, ymax, ydiv, ystep;
  var dataLength;
  var yWithData = 0;

  Plot2D(this.context, this.ydata, this.xdata, this.color, this.style,
      this.width, this.height)
      : border = 100,
        borderL = 80,
        borderT = 50,
        tickSize = 5,
        index = 0 {

    var tickPt;
    var first = true;
    var miny, maxy;
    var minx, maxx;

    //Compute y axis min and max.
    for (var value in ydata.values) {
      if (value != null) {
        if (value.isEmpty) {
          throw new ArgumentError("Empty data lists are not supported.");
        } else if (first) {
          miny = value.fold(value.first, min);
          maxy = value.fold(value.first, max);
          first = false;
        } else {
          var tempMin = value.fold(value.first, min);
          if (tempMin < miny) miny = tempMin;
          var tempMax = value.fold(value.first, max);
          if (tempMax > maxy) maxy = tempMax;
        }
      }
    }

    //Compute x axis min and max.
    minx = xdata.fold(xdata.first, min);
    maxx = xdata.fold(xdata.first, max);

    //Compute optimum divisions of axes.
    xAxisCfg = new _AxisConfig().axes(minx, maxx, width - border);
    yAxisCfg = new _AxisConfig().axes(miny, maxy, height - border);

    //Define and initialize the plot parameters.
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
        context.fillText(j.toInt().toString(), borderL + ((j - xmin)/increment)
            * offset, height - borderT + (borderT / 3));
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
        context.fillText(tickPt.toStringAsFixed(numDigits), borderL - tickSize,
            i.toInt());
        tickPt += ystep;
      }
    }

    //Plot the data.
    for (var waveform in ydata.keys) {
      if (ydata[waveform] != null) {
        yWithData++;
        if (ydata[waveform].length > xdata.length) {
          dataLength = xdata.length;
        } else {
          dataLength = ydata[waveform].length;
        }
        if (style == 'data') {
          context.lineWidth = 2;
          _drawData(color[waveform], ydata[waveform]);
        } else if (style == 'points') {
          context.lineWidth = 3;
          _drawPoints(color[waveform], ydata[waveform]);
        } else if (style == 'curve' || style == 'curvepts') {
          context.lineWidth = 4;
          _drawCurve(color[waveform], ydata[waveform]);
        } else if (style == 'line' || style == 'linepts') {
          context.lineWidth = 3;
          _drawLine(color[waveform], ydata[waveform]);
        }
      }
    }
  }

  /// Private methods for drawing plots.
  // Drawing the data plots - style = 'data'.
  void _drawData(var dataColor, var yvals) {
    //Add sample data and points.
    context.strokeStyle = dataColor;
    for (var j = 0; j < dataLength; j++) {
      var i = borderL + (((xdata[j]) - xmin)/xstep * xdiv);
      context
        ..beginPath()
        ..moveTo(i.toInt(), height - borderT)
        ..lineTo(i.toInt(), height - borderT - (((yvals[j]) - ymin) / ystep * ydiv))
        ..stroke()
        ..beginPath()
        ..arc(i.toInt(), height - borderT - (((yvals[j]) - ymin) / ystep * ydiv),
            4, 0, 2 * PI, false)
        ..closePath()
        ..stroke();
    }
  }

  // Drawing the points plots - style = 'points'.
  void _drawPoints(var dataColor, var yvals) {
    //Add sample points.
    context.strokeStyle = dataColor;
    for (var j = 0; j < dataLength; j++) {
      var i = borderL + (((xdata[j]) - xmin) / xstep * xdiv);
      context
        ..beginPath()
        ..arc(i.toInt(), height - borderT - (((yvals[j]) - ymin)
            / ystep * ydiv), 4, 0, 2 * PI, false)
        ..closePath()
        ..stroke();
    }
  }

  // Drawing the curve plots - style = 'curve' or 'curvepts'.
  void _drawCurve(var dataColor, var yvals) {
    var a, b, c, d;
    context
      ..strokeStyle = dataColor
      ..beginPath()
      ..lineJoin = "round"
      ..moveTo(borderL + (((xdata[index]) - xmin) / xstep * xdiv),
          height - borderT - (((yvals[index]) - ymin) / ystep *
                            ydiv));
    for (var j = 1; j < dataLength - 2; j++) {
      a = borderL + ((xdata[j] - xmin) / xstep * xdiv);
      b = borderL + ((xdata[j + 1] - xmin) / xstep * xdiv);
      c = height - borderT - (((yvals[j]) - ymin) / ystep * ydiv);
      d = height - borderT - (((yvals[j + 1]) - ymin) / ystep *
          ydiv);
      context.quadraticCurveTo(a, c, (a + b) / 2, (c + d) / 2);
    }
    a = borderL + ((xdata[dataLength - 2] - xmin) / xstep * xdiv);
    b = borderL + ((xdata[dataLength - 1] - xmin) / xstep * xdiv);
    c = height - borderT - (((yvals[dataLength - 2]) - ymin)
        / ystep * ydiv);
    d = height - borderT - (((yvals[dataLength - 1]) - ymin)
        / ystep * ydiv);
    context
      ..quadraticCurveTo(a, c, b, d)
      ..stroke();

    if (style == 'curvepts') {
      //Add sample points.
      context.fillStyle = dataColor;
      for (var j = 0; j < dataLength; j++) {
        var i = borderL + ((xdata[j] - xmin) / xstep * xdiv);
        context
          ..beginPath()
          ..arc(i.toInt(), height - borderT - (((yvals[j]) - ymin) /
              ystep * ydiv), 4, 0, 2 * PI, false)
          ..closePath()
          ..fill();
      }
    }
  }

  // Drawing the line plots - style = 'line' or 'linepts'.
  void _drawLine(var dataColor, var yvals) {
    //Add sample data.
    context
    ..strokeStyle = dataColor
    ..beginPath()
    ..lineJoin = "round"
    ..moveTo(borderL + (((xdata[index]) - xmin) / xstep * xdiv),
        height - borderT - (((yvals[index]) - ymin) / ystep * ydiv));
    for (var j = 1; j < dataLength; j++) {
      var i = borderL + (((xdata[j]) - xmin)/xstep * xdiv);
      context
        ..lineTo(i.toInt(), height - borderT - (((yvals[j]) - ymin) / ystep * ydiv))
        ..stroke();
    }
    if (style == 'linepts') {
      //Add sample points.
      context.fillStyle = dataColor;
      for (var j = 0; j < dataLength; j++) {
        var i = borderL + (((xdata[j]) - xmin)/xstep * xdiv);
        context
        ..beginPath()
        ..arc(i.toInt(), height - borderT - (((yvals[j]) - ymin) / ystep * ydiv),
            4, 0, 2 * PI, false)
        ..closePath()
        ..fill();
      }
    }
  }

  /// Public methods for customizing plot.
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
  void xlabel(String xlabelName, {String color:'rgb(85, 98, 112)',
      String font:'12pt Candara'}) {
    context
      ..fillStyle = color
      ..font = font
      ..textAlign = 'center'
      ..fillText(xlabelName, ((width  + (2 * borderL) - border)/ 2),
          height - borderT / 10);
  }

  //Method for adding a label to the y axis.
  //TODO: This needs a way of detecting how much room is available
  //relative to the size of the tick labels.  If they take up too much
  //room (ie, numbers like 1.20e+12), then may need to place the y axis
  //label above the tick marks (ie, upper left corner).
  void ylabel(String ylabelName, {String color:'rgb(85, 98, 112)',
      String font:'12pt Candara'}) {
    var
      lblWidth = context.measureText(ylabelName),
      deltax = borderL / 4,
      deltay = height / 2;
    context
      ..fillStyle = color
      ..font = font
      ..textAlign = 'center'
      ..save()
      ..translate(deltax, deltay)
      ..rotate(-PI / 2)
      ..translate(-deltax, -deltay)
      ..fillText(ylabelName, 0, height / 2)
      ..restore();
  }

  //Method for adding a title.
  void title(String title, {String color:'rgb(85, 98, 112)',
      String font:'16pt Candara'}) {
    context
      ..fillStyle = color
      ..textAlign = 'center'
      ..font = font
      ..fillText(title, ((width  + (2 * borderL) - border)/ 2), borderT / 2);
  }

  //Method for adding a date stamp.
  void date([bool short = false]) {
    String dateTime = new TimeStamp().stamp(short);
    context
      ..fillStyle = 'rgb(85, 98, 112)'
      ..textAlign = 'right'
      ..font = '10pt Candara'
      ..fillText(dateTime, width, height - tickSize);
  }

  // Method for adding a legend.
  void legend({String y1: 'y1', String y2: 'y2', String y3: 'y3',
      String y4: 'y4'}) {
    context
      ..font = "italic bold 14px consolas"
      ..textAlign = 'left';
    LinkedHashMap llabel = new LinkedHashMap();
    llabel["y1"] = y1;
    llabel["y2"] = y2;
    llabel["y3"] = y3;
    llabel["y4"] = y4;
    var yWidths = [context.measureText(y1).width,
                   context.measureText(y2).width,
                   context.measureText(y3).width,
                   context.measureText(y4).width];
    var legendWidth = 20 + yWidths.fold(yWidths.first, max);
    var legendHeight = 20 + (yWithData * height) ~/ (8 * ydata.length);
    var legendBorder = 10;
    var legendX = width + borderL - border - legendWidth - legendBorder;
    var legendY = borderT + legendBorder;
    var yOffset = (legendHeight - 20) ~/ yWithData;
    context
      ..fillStyle = 'white'
      ..fillRect(legendX, legendY, legendWidth, legendHeight)
      ..strokeStyle = "rgb(85, 98, 112)"    //"#556270"
      ..lineCap = "round"
      ..strokeRect(legendX, legendY, legendWidth, legendHeight, 2)
      ..lineWidth = 1;
    for (var waveform in ydata.keys) {
      if (ydata[waveform] != null) {
        context
          ..fillStyle = color[waveform]
          ..fillText(llabel[waveform], 10 + legendX, legendY + yOffset,
              legendWidth);
        yOffset += legendHeight ~/ yWithData;
      }
    }
  }

  // Method for adding a cursor along the x axis.
  void xcursor(num xval, [annotate = false]) {
    var xindex = xdata.indexOf(xval);
    context
      ..font = "italic bold 16px consolas"
      ..textAlign = 'left'
      ..strokeStyle = 'rgb(85, 98, 112)'
      ..lineWidth = 2
      ..beginPath()
      ..moveTo(borderL + ((xval - xmin) / xstep * xdiv), height - borderT)
      ..lineTo(borderL + ((xval - xmin) / xstep * xdiv), borderT)
      ..stroke();
    if (annotate) {
      for (var waveform in ydata.keys) {
        if (ydata[waveform] != null) {
          var dataLength = ydata[waveform].length;
          if (xindex < dataLength && xindex != -1) {
            var
              dataPoint = ydata[waveform][xindex],
              value = dataPoint.toString(),
              valWidth = 10 + context.measureText(value).width,
              valHeight = 5 + height ~/ 32,
              valX = borderL + ((xval - xmin) / xstep * xdiv),
              valY = height - borderT - ((dataPoint - ymin) / ystep * ydiv);
            if (xindex < dataLength ~/ 2) {
              context
                ..fillStyle = 'rgba(255, 255, 255, 0.85)'
                ..fillRect(5 + valX, 10 + valY - valHeight, valWidth, valHeight)
                ..strokeStyle = 'rgba(85, 98, 112, 0.9)'   //"#556270"
                ..lineCap = "round"
                ..strokeRect(5 + valX, 10 + valY - valHeight, valWidth,
                    valHeight, 1)
                ..fillStyle = color[waveform]
                ..fillText(value, 10 + borderL + ((xval - xmin) / xstep * xdiv),
                    5 + height - borderT - ((dataPoint - ymin) / ystep * ydiv));
            } else {
              context
                ..fillStyle = 'rgba(255, 255, 255, 0.85)'
                ..fillRect(valX - valWidth - 5, 10 + valY - valHeight,
                    valWidth, valHeight)
                ..strokeStyle = 'rgba(85, 98, 112, 0.9)'   //"#556270"
                ..lineCap = "round"
                ..strokeRect(valX - valWidth - 5, 10 + valY - valHeight,
                    valWidth, valHeight, 1)
                ..fillStyle = color[waveform]
                ..fillText(value, borderL + ((xval - xmin) / xstep * xdiv) - valWidth,
                    5 + height - borderT - ((dataPoint - ymin) / ystep * ydiv));
            }
          }
        }
      }
    }
  }

  //Method for saving a single plot as a PNG image.
  void save() {
    window.open(context.canvas.toDataUrl('image/png'), 'plotWindow');
  }
}

/**
 * Function saveAll(List plots) create a new canvas and adds all
 * the plot canvas from the list.  It then creates a new window which
 * contains a PNG image of all the plots to allow for saving.
 *
 */
WindowBase saveAll(List plots, {num scale: 1.0, bool quad: true}) {
  // Set a fixed border around each plot.
  final margin = 20;
  final width = (plots[0].context.canvas.width * scale).toInt();
  final height = (plots[0].context.canvas.height * scale).toInt();
  final widthAll = quad ? 2 * (width + margin) : width;
  final heightAll = quad ? (plots.length / 2).ceil() * (height + margin) :
      plots.length * (height + margin);
  CanvasElement plotAllCanvas = new CanvasElement(width:width, height:height);

  // Set the attributes of the canvas element based on all plot sizes.
  plotAllCanvas.attributes = ({
    "id": "plotAllCanvas",
    "class": "plotAllCanvas",
    "width": "$widthAll",
    "height": "$heightAll"
  });
  CanvasRenderingContext2D contextAll = plotAllCanvas.context2d;
  if (quad) {
    for (var i = 0; i < plots.length; i++) {
      contextAll.drawImage(plots[i].context.canvas, (i % 2) * (width + margin),
          (i / 2).floor() * (height + margin));
    }
  } else {
    for (var i = 0; i < plots.length; i++) {
      contextAll.drawImage(plots[i].context.canvas, 0, i * (height + margin));
    }
  }
  return window.open(contextAll.canvas.toDataUrl('image/png'), 'plotAllWindow');
}