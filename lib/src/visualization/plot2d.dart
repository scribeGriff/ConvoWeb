// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

part of convoweb;

/**
 * A small 2D plotting class for graphing data to an HTML canvas.
 *
 * If xdata not specified, a vector is generated equivalent
 * to the size of the first ydata supplied in units from 1 to ydata.length.
 *
 * Current styles supported:
 * *data (default)
 * *points
 * *curve
 * *curvepts (curve with points)
 * *line
 * *linepts (line with points)
 *
 * Variable r is the range which specifies how many subplots (1 - 4).
 * Variable i is the index of the subplot (1 - 4).
 * Both variables default to 1 for a single plot.
 *
 * Supported methods are:
 *     grid(),
 *     xlabel(String xlabelName, [String labelColor]),
 *     ylabel(String ylabelName, [String labelColor]),
 *     title(String title, [String titleColor]),
 *     date([bool short])
 *     legend()
 *     xmarker(num xval, [bool annotate])
 *     save()
 *
 * Usage (given up to four Lists of type num - ie, myData1, myData2):
 *     var p1 = plot(myData1, y2:myData2);
 *     p1
 *       ..grid();
 *       ..xlabel('Samples (n)');
 *       ..ylabel('data');
 *       ..title('Example of Plotting Sampled Data');
 *       ..date();
 *       ..legend(y1:'3x + 2', y2:'sin(2x)');
 *       ..xmarker(xval, true);
 *       ..save();
 *
 * Includes a top level function, saveAll() for saving a group of subplots.
 */

/**
 * Top level function plot() returns an instance of the Plot2D class.
 *
 * Only one parameter is required - a List representing the data to be plotted.
 *
 * Provides a number of named optional parameters:
 * *xdata: by default, the x axis is simply defined as the number of data
 *  points in y1, but the axis data points can be specified by providing a
 *  List for xdata.  All plots are plotted against this single x axis.
 * *y2 - y4: List representing additional data to be plotted on same axes.
 * *style: The default style is data, which plots the data as points with
 *  a line to the x axis.  Supported optional styles include points, curve,
 *  curvepts, line, linepts.
 * *color1 - color4: Sets the color for each set of data.
 * *range: The number of subplots.  Default is 1.
 * *index: Which subplot is currently being drawn.
 * *large: Default is true, but by setting this boolean value to false, will
 *  shrink the drawn size.
 * *container: The id of the container for the plots.  Default is #simPlotQuad.
 *
 * All plots are assigned a unique id of simPlot$index (ie, #simPlot1) and a
 * common class of simPlot (ie, .simPlot).
 */
Plot2D plot(List y1, {
    List xdata: null,
    List y2: null,
    List y3: null,
    List y4: null,
    String style1: 'data',
    String style2: null,
    String style3: null,
    String style4: null,
    String color1: 'black',
    String color2: 'green',
    String color3: 'blue',
    String color4: 'red',
    int range: 1,
    int index: 1,
    bool large: true,
    String container: '#simPlotQuad'}) {
  final int _gphSize = 600;
  final int _border = 80;
  final int _pwidth = _gphSize;
  final int _scalePlot = large ? 2 : range;
  final int _pheight = range == 1 ? _gphSize : (_gphSize * 1.5 / _scalePlot).toInt();
  var graphContainer = query(container);
  var _plotCanvas = new CanvasElement();
  _plotCanvas.attributes = ({
    "id": "simPlot$index",
    "class": "simPlot",
    "width": "$_pwidth",
    "height": "$_pheight",
  });
  graphContainer.nodes.add(_plotCanvas);
  CanvasRenderingContext2D _context = _plotCanvas.context2d;
  _context.fillStyle = 'white';
  _context.fillRect(0, 0, _pwidth, _pheight);
  _context.fillStyle = 'black';

  //If no xdata was passed, create a row vector
  //based on the length of y1.
  if (xdata == null) {
    xdata = new List.generate(y1.length, (var index) =>
        index + 1, growable:false);
  } else if (style1 == 'data') {
    xdata = new List.generate(y1.length, (var index) =>
        index + xdata[0], growable:false);
  }

  //Build a HashMap of the all the y axis data.
  var _ydata = new LinkedHashMap();
  _ydata["y1"] = y1;
  _ydata["y2"] = y2;
  _ydata["y3"] = y3;
  _ydata["y4"] = y4;

  //Build a HashMap of the all the y axis data.
  var _style = new LinkedHashMap();
  _style["y1"] = style1;
  _style["y2"] = style2 == null ? style1 : style2;
  _style["y3"] = style3 == null ? style1 : style3;
  _style["y4"] = style4 == null ? style1 : style4;

  //Build a HashMap of the corresponding colors for the plots.
  var _color = new LinkedHashMap();
  _color["y1"] = color1;
  _color["y2"] = color2;
  _color["y3"] = color3;
  _color["y4"] = color4;

  //Return the Plot2D object.
  return new Plot2D(_context, _ydata, xdata, _color, _style, _pwidth, _pheight);
}

/**
 * Configures the axes and draws the data to the canvas.
 */
class Plot2D {
  _AxisConfigResults _yAxisCfg;
  _AxisConfigResults _xAxisCfg;

  final _border = 100;
  final _borderL = 80;
  final _borderT = 50;
  final _tickSize = 5;
  final _index = 0;

  final CanvasRenderingContext2D _context;
  final LinkedHashMap _ydata, _color, _style;
  final List _xdata;
  //final String _style;
  final num _pwidth, _pheight;
  num _xmin, _xmax, _xdiv, _xstep;
  num _ymin, _ymax, _ydiv, _ystep;
  var _dataLength;
  var _yWithData = 0;

  Plot2D(this._context, this._ydata, this._xdata, this._color, this._style,
      this._pwidth, this._pheight) {

    var _tickPt;
    var _first = true;
    var _miny, _maxy;
    var _minx, _maxx;

    //Compute y axis min and max.
    for (var value in _ydata.values) {
      if (value != null) {
        if (value.isEmpty) {
          throw new ArgumentError("Empty data lists are not supported.");
        } else if (_first) {
          _miny = value.fold(value.first, min);
          _maxy = value.fold(value.first, max);
          _first = false;
        } else {
          var _tempMin = value.fold(value.first, min);
          if (_tempMin < _miny) _miny = _tempMin;
          var _tempMax = value.fold(value.first, max);
          if (_tempMax > _maxy) _maxy = _tempMax;
        }
      }
    }

    //Compute x axis min and max.
    _minx = _xdata.fold(_xdata.first, min);
    _maxx = _xdata.fold(_xdata.first, max);

    //Compute optimum divisions of axes.
    _xAxisCfg = new _AxisConfig().axes(_minx, _maxx, _pwidth - _border);
    _yAxisCfg = new _AxisConfig().axes(_miny, _maxy, _pheight - _border);

    //Define and initialize the plot parameters.
    _xmin = _xAxisCfg.min;
    _xmax = _xAxisCfg.max;
    _xdiv = _xAxisCfg.div;
    _xstep = _xAxisCfg.step;
    _ymin = _yAxisCfg.min;
    _ymax = _yAxisCfg.max;
    _ydiv = _yAxisCfg.div;
    _ystep = _yAxisCfg.step;
    var
      _offset = _style == 'data' ? _xdiv / _xstep : _xdiv,
      _increment = _style == 'data' ? 1 : _xstep;

    //Draw the graph outline.
    _context
      ..strokeStyle = "rgb(85, 98, 112)"    //"#556270"
      ..lineCap = "round"
      ..strokeRect(_borderL, _borderT, _pwidth - _border, _pheight - _border, 2)
      ..lineWidth = 1;

    //Create tick marks on x axis.
    for (var i = _borderL + _offset; i < _pwidth - (_border - _borderL); i += _offset) {
      _context
        //bottom ticks
        ..beginPath()
        ..moveTo(i.toInt() + 0.5, _pheight - _borderT)
        ..lineTo(i.toInt() + 0.5, _pheight - _borderT - _tickSize)
        ..stroke()
        //top ticks
        ..moveTo(i.toInt() + 0.5, _borderT + _tickSize)
        ..lineTo(i.toInt() + 0.5, _borderT)
        ..stroke();
    }

    //Add labels to the x axis tick marks.
    _context
      ..textAlign = 'center'
      ..font = '10pt Consolas';
    _tickPt = _xmin;
    //if (_xstep == _xstep.toInt()) {
    if (_increment == _increment.toInt()) {
      for (var j = _xmin; j <= _xmax; j += _increment) {
        _context.fillText(j.toInt().toString(), _borderL + ((j - _xmin)/_increment)
            * _offset, _pheight - _borderT + (_borderT / 3));
        _tickPt += _increment;
      }
    } else {
      // TODO: exponent, precision, fixed number labels.
      var numDigits = 2;
      if (_xmax < 0.01) numDigits = 3;
      for (var j = _xmin; j <= _xmax; j += _increment) {
        _context.fillText(j.toStringAsFixed(numDigits), _borderL + ((j - _xmin)/_increment) * _offset,
            _pheight - _borderT + (_borderT / 3));
        _tickPt += _increment;
      }
    }

    //Create tick marks on y axis.
    for (var i = _pheight - _borderT - _ydiv; i > _borderT; i -= _ydiv) {
      _context
        //left ticks
        ..moveTo(_borderL, i.toInt() + 0.5)
        ..lineTo(_borderL + _tickSize, i.toInt() + 0.5)
        ..stroke()
        //right ticks
        ..moveTo(_pwidth - (_border - _borderL), i.toInt() + 0.5)
        ..lineTo(_pwidth - (_border - _borderL) - _tickSize, i.toInt() + 0.5)
        ..stroke();
    }

    //Add labels to the y axis tics.
    _context
      ..font = '10pt Consolas'
      ..textAlign = 'right';
    _tickPt = _ymin;
    if (_ystep == _ystep.toInt()) {
      for (var i = _pheight - _borderT; i > _borderT - _ydiv / 2; i -= _ydiv) {
        _context.fillText(_tickPt.toInt().toString(), _borderL - _tickSize, i.toInt());
        _tickPt += _ystep;
      }
    } else {
      // Need test cases for exponent, precision, fixed number labels.
      var numDigits = 2;
      if (_ymax < 0.01) numDigits = 3;
      for (var i = _pheight - _borderT; i > _borderT - _ydiv / 2; i -= _ydiv) {
        _context.fillText(_tickPt.toStringAsFixed(numDigits), _borderL - _tickSize,
            i.toInt());
        _tickPt += _ystep;
      }
    }

    //Plot the data.
    for (var waveform in _ydata.keys) {
      if (_ydata[waveform] != null) {
        _yWithData++;
        if (_ydata[waveform].length > _xdata.length) {
          _dataLength = _xdata.length;
        } else {
          _dataLength = _ydata[waveform].length;
        }
        if (_style[waveform] == 'data') {
          _context.lineWidth = 2;
          _drawData(_color[waveform], _ydata[waveform]);
        } else if (_style[waveform] == 'points') {
          _context.lineWidth = 3;
          _drawPoints(_color[waveform], _ydata[waveform]);
        } else if (_style[waveform] == 'curve' || _style[waveform] == 'curvepts') {
          _context.lineWidth = 4;
          _drawCurve(_color[waveform], _ydata[waveform], _style[waveform]);
        } else if (_style[waveform] == 'line' || _style[waveform] == 'linepts') {
          _context.lineWidth = 3;
          _drawLine(_color[waveform], _ydata[waveform], _style[waveform]);
        }
      }
    }
  }

  /// Private methods for drawing plots.
  // Drawing the data plots - style = 'data'.
  void _drawData(var dataColor, var yvals) {
    //Add sample data and points.
    _context.strokeStyle = dataColor;
    for (var j = 0; j < _dataLength; j++) {
      var i = _borderL + (((_xdata[j]) - _xmin)/_xstep * _xdiv);
      _context
        ..beginPath()
        ..moveTo(i.toInt(), _pheight - _borderT)
        ..lineTo(i.toInt(), _pheight - _borderT - (((yvals[j]) - _ymin) / _ystep * _ydiv))
        ..stroke()
        ..beginPath()
        ..arc(i.toInt(), _pheight - _borderT - (((yvals[j]) - _ymin) / _ystep * _ydiv),
            4, 0, 2 * PI, false)
        ..closePath()
        ..stroke();
    }
  }

  // Drawing the points plots - style = 'points'.
  void _drawPoints(var dataColor, var yvals) {
    //Add sample points.
    _context.strokeStyle = dataColor;
    for (var j = 0; j < _dataLength; j++) {
      var i = _borderL + (((_xdata[j]) - _xmin) / _xstep * _xdiv);
      _context
        ..beginPath()
        ..arc(i.toInt(), _pheight - _borderT - (((yvals[j]) - _ymin)
            / _ystep * _ydiv), 4, 0, 2 * PI, false)
        ..closePath()
        ..stroke();
    }
  }

  // Drawing the curve plots - style = 'curve' or 'curvepts'.
  void _drawCurve(var dataColor, var yvals, var style) {
    var a, b, c, d;
    _context
      ..strokeStyle = dataColor
      ..beginPath()
      ..lineJoin = "round"
      ..moveTo(_borderL + (((_xdata[_index]) - _xmin) / _xstep * _xdiv),
          _pheight - _borderT - (((yvals[_index]) - _ymin) / _ystep *
                            _ydiv));
    for (var j = 1; j < _dataLength - 2; j++) {
      a = _borderL + ((_xdata[j] - _xmin) / _xstep * _xdiv);
      b = _borderL + ((_xdata[j + 1] - _xmin) / _xstep * _xdiv);
      c = _pheight - _borderT - (((yvals[j]) - _ymin) / _ystep * _ydiv);
      d = _pheight - _borderT - (((yvals[j + 1]) - _ymin) / _ystep *
          _ydiv);
      _context.quadraticCurveTo(a, c, (a + b) / 2, (c + d) / 2);
    }
    a = _borderL + ((_xdata[_dataLength - 2] - _xmin) / _xstep * _xdiv);
    b = _borderL + ((_xdata[_dataLength - 1] - _xmin) / _xstep * _xdiv);
    c = _pheight - _borderT - (((yvals[_dataLength - 2]) - _ymin)
        / _ystep * _ydiv);
    d = _pheight - _borderT - (((yvals[_dataLength - 1]) - _ymin)
        / _ystep * _ydiv);
    _context
      ..quadraticCurveTo(a, c, b, d)
      ..stroke();

    if (style == 'curvepts') {
      //Add sample points.
      _context.fillStyle = dataColor;
      for (var j = 0; j < _dataLength; j++) {
        var i = _borderL + ((_xdata[j] - _xmin) / _xstep * _xdiv);
        _context
          ..beginPath()
          ..arc(i.toInt(), _pheight - _borderT - (((yvals[j]) - _ymin) /
              _ystep * _ydiv), 4, 0, 2 * PI, false)
          ..closePath()
          ..fill();
      }
    }
  }

  // Drawing the line plots - style = 'line' or 'linepts'.
  void _drawLine(var dataColor, var yvals, var style) {
    //Add sample data.
    _context
    ..strokeStyle = dataColor
    ..beginPath()
    ..lineJoin = "round"
    ..moveTo(_borderL + (((_xdata[_index]) - _xmin) / _xstep * _xdiv),
        _pheight - _borderT - (((yvals[_index]) - _ymin) / _ystep * _ydiv));
    for (var j = 1; j < _dataLength; j++) {
      var i = _borderL + (((_xdata[j]) - _xmin)/_xstep * _xdiv);
      _context
        ..lineTo(i.toInt(), _pheight - _borderT - (((yvals[j]) - _ymin) / _ystep * _ydiv))
        ..stroke();
    }
    if (style == 'linepts') {
      //Add sample points.
      _context.fillStyle = dataColor;
      for (var j = 0; j < _dataLength; j++) {
        var i = _borderL + (((_xdata[j]) - _xmin)/_xstep * _xdiv);
        _context
        ..beginPath()
        ..arc(i.toInt(), _pheight - _borderT - (((yvals[j]) - _ymin) / _ystep * _ydiv),
            4, 0, 2 * PI, false)
        ..closePath()
        ..fill();
      }
    }
  }

  // Public methods for customizing plot.

  /**
   * Adds a grid to a plot.
   *
   * Uses the same spacing as the x and y tick marks.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.grid();
   */
  void grid() {
    var _offset = _style == 'data' ? _xdiv / _xstep : _xdiv;
    _context.lineWidth = 1;
    for (var i = _borderL + _offset; i < _pwidth - (_border - _borderL); i += _offset) {
      for (var j = _pheight - _borderT - _ydiv; j > _borderT; j -= _ydiv) {
        _context
          ..beginPath()
          ..arc(i.toInt() + 0.5, j.toInt() + 0.5, 1, 0, 2 * PI, false)
          ..closePath()
          ..fill();
      }
    }
  }

  /**
   * Adds a label to the x axis.
   *
   * The xlabelName is a required String value.  Method also accepts
   * two optional named parameters, a String value for the color of the label,
   * and a String value for the label font.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.xlabel('samples(n)', color:'red', font:'8pt Arial');
   */
  void xlabel(String xlabelName, {String color:'rgb(85, 98, 112)',
      String font:'12pt Candara'}) {
    _context
      ..fillStyle = color
      ..font = font
      ..textAlign = 'center'
      ..fillText(xlabelName, ((_pwidth  + (2 * _borderL) - _border)/ 2),
          _pheight - _borderT / 10);
  }

  /**
   * Adds a label to the y axis.
   *
   * The ylabelName is a required String value.  Method also accepts
   * two optional named parameters, a String value for the color of the label,
   * and a String value for the label font.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.ylabel('data(x1e3)', color:'#ccc', font:'16pt Helvetica');
   *
   * For y values with a large number of signicant digits, it is recommended
   * that you scale the data prior to plotting.  It is currently an issue
   * to build in the scaling and allow different number notation.  But
   * currently, large number of significant digits will likely cause the
   * ylabel to draw over the top of the yaxis tick values.
   */

  //Method for adding a label to the y axis.
  //TODO: This needs a way of detecting how much room is available
  //relative to the size of the tick labels.  If they take up too much
  //room (ie, numbers like 1.20e+12), then may need to place the y axis
  //label above the tick marks (ie, upper left corner).
  void ylabel(String ylabelName, {String color:'rgb(85, 98, 112)',
      String font:'12pt Candara'}) {
    var
      _lblWidth = _context.measureText(ylabelName),
      _deltax = _borderL / 4,
      _deltay = _pheight / 2;
    _context
      ..fillStyle = color
      ..font = font
      ..textAlign = 'center'
      ..save()
      ..translate(_deltax, _deltay)
      ..rotate(-PI / 2)
      ..translate(-_deltax, -_deltay)
      ..fillText(ylabelName, 0, _pheight / 2)
      ..restore();
  }

  /**
   * Adds a title to the current plot.
   *
   * The title is a required String value.  The method also accepts
   * two optional named parameters, a String value for the color of the label,
   * and a String value for the label font.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.title('A Sample Plot', color:'rgba(42, 42, 88, 0.5)',
   *         font:'14pt Caslon');
   */
  void title(String title, {String color:'rgb(85, 98, 112)',
      String font:'16pt Candara'}) {
    _context
      ..fillStyle = color
      ..textAlign = 'center'
      ..font = font
      ..fillText(title, ((_pwidth  + (2 * _borderL) - _border)/ 2), _borderT / 2);
  }

  /**
   * Adds a date stamp to the current plot.
   *
   * The date stamp can be in either a "short" form or a "long" (default) form.
   * *long: 9:56pm Tue 16-Oct-2012
   * *short: 9:56pm 10/16/2012
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.date(true);
   */
  void date([bool short = false]) {
    String _dateTime = new TimeStamp().stamp(short);
    _context
      ..fillStyle = 'rgb(85, 98, 112)'
      ..textAlign = 'right'
      ..font = '10pt Candara'
      ..fillText(_dateTime, _pwidth, _pheight - _tickSize);
  }

  /**
   * Adds a legend to the current plot.
   * All parameters are optional.  In its simpliest form, the legend uses
   * the default labels for each graph in the plot (up to 4 graphs per plot).
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.legend();
   *
   * This method also allows for the specification of names for each graph.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.legend(y1:'y = 3x - 2', y2:'cosh(x)');
   *
   */
  void legend({String l1: 'y1', String l2: 'y2', String l3: 'y3',
      String l4: 'y4', bool top: true}) {
    _context
      ..font = "italic bold 14px consolas"
      ..textAlign = 'left';
    LinkedHashMap llabel = new LinkedHashMap();
    llabel["y1"] = l1;
    llabel["y2"] = l2;
    llabel["y3"] = l3;
    llabel["y4"] = l4;
    var _yWidths = [_context.measureText(l1).width,
                    _context.measureText(l2).width,
                    _context.measureText(l3).width,
                    _context.measureText(l4).width];
    var
      _legendWidth = 20 + _yWidths.fold(_yWidths.first, max),
      _legendHeight = 20 + (_yWithData * _pheight) ~/ (8 * _ydata.length),
      _legendBorder = 10,
      _legendX = _pwidth + _borderL - _border - _legendWidth - _legendBorder,
      _legendY = top == true ? _borderT + _legendBorder : _pheight - _legendBorder - _legendHeight - _borderT,
      //_legendY = _borderT + _legendBorder,
      _yOffset = (_legendHeight - 15) ~/ _yWithData;
    _context
      ..fillStyle = 'white'
      ..fillRect(_legendX, _legendY, _legendWidth, _legendHeight)
      ..strokeStyle = "rgb(85, 98, 112)"    //"#556270"
      ..lineCap = "round"
      ..strokeRect(_legendX, _legendY, _legendWidth, _legendHeight, 2)
      ..lineWidth = 1;
    for (var waveform in _ydata.keys) {
      if (_ydata[waveform] != null) {
        _context
          ..fillStyle = _color[waveform]
          ..fillText(llabel[waveform], 10 + _legendX, _legendY + _yOffset,
              _legendWidth);
        _yOffset += _legendHeight ~/ _yWithData;
      }
    }
  }

  /**
   * Adds a marker to the x axis of the current plot at position x = xval.
   *
   * The method requires an x value to be provided.  If the value of x specified
   * is not a data point (ie, indexOf(xval) returns -1), the marker is not added
   * (ie, the marker x position is not interpolated between data points).
   *
   * An optional boolean variable indicates if the marker points corresponding
   * to y axis values should be annotating on the plot.  This parameter is
   * disabled by default.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.xmarker(data[4], true);
   */
  void xmarker(num xval, [bool annotate = false]) {
    var _xindex = _xdata.indexOf(xval);
    _context
      ..font = "italic bold 16px consolas"
      ..textAlign = 'left'
      ..strokeStyle = 'rgb(85, 98, 112)'
      ..lineWidth = 2
      ..beginPath()
      ..moveTo(_borderL + ((xval - _xmin) / _xstep * _xdiv), _pheight - _borderT)
      ..lineTo(_borderL + ((xval - _xmin) / _xstep * _xdiv), _borderT)
      ..stroke();
    if (annotate) {
      for (var waveform in _ydata.keys) {
        if (_ydata[waveform] != null) {
          var _dataLength = _ydata[waveform].length;
          if (_xindex < _dataLength && _xindex != -1) {
            var
              _dataPoint = _ydata[waveform][_xindex],
              _value = _dataPoint.toString(),
              _valWidth = 10 + _context.measureText(_value).width,
              _valHeight = 5 + _pheight ~/ 32,
              _valX = _borderL + ((xval - _xmin) / _xstep * _xdiv),
              _valY = _pheight - _borderT - ((_dataPoint - _ymin) / _ystep * _ydiv);
            if (_xindex < _dataLength ~/ 2) {
              _context
                ..fillStyle = 'rgba(255, 255, 255, 0.85)'
                ..fillRect(5 + _valX, 10 + _valY - _valHeight, _valWidth, _valHeight)
                ..strokeStyle = 'rgba(85, 98, 112, 0.9)'   //"#556270"
                ..lineCap = "round"
                ..strokeRect(5 + _valX, 10 + _valY - _valHeight, _valWidth,
                    _valHeight, 1)
                ..fillStyle = _color[waveform]
                ..fillText(_value, 10 + _borderL + ((xval - _xmin) / _xstep * _xdiv),
                    5 + _pheight - _borderT - ((_dataPoint - _ymin) / _ystep * _ydiv));
            } else {
              _context
                ..fillStyle = 'rgba(255, 255, 255, 0.85)'
                ..fillRect(_valX - _valWidth - 5, 10 + _valY - _valHeight,
                    _valWidth, _valHeight)
                ..strokeStyle = 'rgba(85, 98, 112, 0.9)'   //"#556270"
                ..lineCap = "round"
                ..strokeRect(_valX - _valWidth - 5, 10 + _valY - _valHeight,
                    _valWidth, _valHeight, 1)
                ..fillStyle = _color[waveform]
                ..fillText(_value, _borderL + ((xval - _xmin) / _xstep * _xdiv) - _valWidth,
                    5 + _pheight - _borderT - ((_dataPoint - _ymin) / _ystep * _ydiv));
            }
          }
        }
      }
    }
  }

  /**
   * Saves an individual plot by creating a PNG image in a new browser window.
   *
   * Usage:
   *     var myPlot = plot(data);
   *     myPlot.save();
   */
  void save() {
    window.open(_context.canvas.toDataUrl('image/png'), 'plotWindow');
  }
}

/**
 * Draws all plots to a new canvas and opens a new window to allow for saving.
 *
 * Accepts 3 parameters, two of which are optional named parameters:
 * *List plots: A list of the plots that are to be printed.
 * *num scale (optional): Scales size of each canvas to be plotted (default = 1).
 * *bool quad: Determines arrangement of multiplot canvases. If quad is true
 *   (default), plots are arranged in a 2 x n/2 matrix.  Otherwise, they are
 *   arranged vertically in a a 1 x n matrix.
 *
 *  Usage:
 *     var allPlots = new List();
 *     var myScatter = plot(yval, xdata:xval, style:'points', color1:'red',
 *         range:2, index:1, container:"#quad");
 *     myScatter
 *       ..grid()
 *       ..xlabel('sample x data')
 *       ..ylabel('sample y data')
 *       ..title('Example of Scatter Plot');
 *     allPlots.add(myScatter);
 *
 *     var myLines = plot(yval, y2:xval, y3:yShort, style:'linepts', range:2,
 *         index:2, container:"#myContainer");
 *     myLines
 *       ..grid()
 *       ..xlabel('Samples (n)')
 *       ..ylabel('data')
 *       ..title('Example of Plotting Sampled Data')
 *       ..date()
 *       ..legend()
 *       ..xmarker(yShort[2], true)
 *       ..xmarker(4, true);
 *     allPlots.add(myLines);
 *
 *     WindowBase myPlotWindow = saveAll(allPlots);
 *
 */
WindowBase saveAll(List plots, {num scale: 1.0, bool quad: true}) {
  // Set a fixed border around each plot.
  final _margin = 20;
  final _cwidth = (plots[0].context.canvas.width * scale).toInt();
  final _cheight = (plots[0].context.canvas.height * scale).toInt();
  final _widthAll = quad ? 2 * (_cwidth + _margin) : _cwidth;
  final _heightAll = quad ? (plots.length / 2).ceil() * (_cheight + _margin) :
      plots.length * (_cheight + _margin);
  CanvasElement _plotAllCanvas = new CanvasElement(width:_cwidth, height:_cheight);

  // Set the attributes of the canvas element based on all plot sizes.
  _plotAllCanvas.attributes = ({
    "id": "simPlotAllCanvas",
    "class": "simPlotAll",
    "width": "$_widthAll",
    "height": "$_heightAll"
  });
  CanvasRenderingContext2D _contextAll = _plotAllCanvas.context2d;
  if (quad) {
    for (var i = 0; i < plots.length; i++) {
      _contextAll.drawImage(plots[i].context.canvas, (i % 2) * (_cwidth + _margin),
          (i / 2).floor() * (_cheight + _margin));
    }
  } else {
    for (var i = 0; i < plots.length; i++) {
      _contextAll.drawImage(plots[i].context.canvas, 0, i * (_cheight + _margin));
    }
  }
  return window.open(_contextAll.canvas.toDataUrl('image/png'), 'plotAllWindow');
}