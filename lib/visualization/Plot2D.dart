/* ********************************************************************* *
 *   Class Plot2D                                                        *
 *   Library: ConvoWeb (c) 2012 scribeGriff                              *
 *   Plot data with canvas element in 2D                                 *
 *   If xdata not specified, a vector is generated equivalent            *
 *   to the size of ydata in units from 1 to ydata.length.               *
 *   Current styles supported:                                           *
 *       data (default),                                                 *
 *       line,                                                           *
 *       linpts (line with points)                                       *
 *   Variable r is the range which specifies how many subplots (1 - 3).  *
 *   Variable i is the index of the subplot (1 - 3).                     *
 *   Supported methods are:                                              *
 *       grid(),                                                         *
 *       xlabel(String xlabelName, [String labelColor]),                 *
 *       ylabel(String ylabelName, [String labelColor]),                 *
 *       title(String title, [String titleColor]),                       *
 *       date()                                                          *
 *   Usage (given a List of numbers called real):                        *
 *       var p1 = plot(real);                                            *
 *       p1.grid();                                                      *
 *       p1.xlabel('Samples (n)');                                       *
 *       p1.ylabel('data');                                              *
 *       p1.title('Example of Plotting Sampled Data');                   *
 *       p1.date();                                                      *
 *                                                                       *
 * ********************************************************************* */

// Use plot as a wrapper to private class _Plot2D.
Plot2D plot(List ydata, [List xdata = null, String style = 'data',
    int r = 1, int i = 1]) {
  final int gphSize = 600;
  final int border = 100;
  int width = gphSize;
  int height = r == 1 ? gphSize : (gphSize * 1.5 / r).toInt();
  var graphContainer = query('#graph');
  CanvasElement plotCanvas = new CanvasElement();
  plotCanvas.attributes = ({
    "id": "plotCanvas$i",
    "class": "plotCanvas",
    "width": width,
    "height": height,
  });
  graphContainer.nodes.add(plotCanvas);
  CanvasRenderingContext2D context = plotCanvas.context2d;

  if (xdata == null) xdata = vec(1, ydata.length);
  return new Plot2D(context, ydata, xdata, style, width, height);
}

class Plot2D {
  AxisConfigResults yAxisCfg;
  AxisConfigResults xAxisCfg;

  final border = 100;
  final borderL = 50;
  final borderT = 50;
  final tickSize = 5;

  CanvasRenderingContext2D context;
  List xdata, ydata;
  String style;
  num width, height;
  num xmin, xmax, xdiv, xstep;
  num ymin, ymax, ydiv, ystep;

  int index;

  Plot2D(this.context, this.ydata, this.xdata, this.style, this.width, this.height)
      : index = 0 {

    num tickPt;

    //Compute optimum divisions of axes.
    xAxisCfg = new AxisConfig().axes(xdata, height - border);
    yAxisCfg = new AxisConfig().axes(ydata, height - border);

    xmin = xAxisCfg.min;
    xmax = xAxisCfg.max;
    xdiv = xAxisCfg.div;
    xstep = xAxisCfg.step;
    ymin = yAxisCfg.min;
    ymax = yAxisCfg.max;
    ydiv = yAxisCfg.div;
    ystep = yAxisCfg.step;

    var offset = style == 'data' ? xdiv / xstep : xdiv;
    var increment = style == 'data' ? 1 : xstep;

    //Draw the graph outline.
    context.strokeStyle = "rgb(85, 98, 112)";    //"#556270"
    context.lineCap = "round";
    context.strokeRect(borderL, borderT, width - border, height - border, 2);

    //Create tick marks on x axis.
    context.lineWidth = 1;
    for (var i = borderL + offset; i < width - (border - borderL); i += offset) {
      //bottom ticks
      context.beginPath();
      context.moveTo(i.toInt() + 0.5, height - borderT);
      context.lineTo(i.toInt() + 0.5, height - borderT - tickSize);
      context.stroke();
      //top ticks
      context.moveTo(i.toInt() + 0.5, borderT + tickSize);
      context.lineTo(i.toInt() + 0.5, borderT);
      context.stroke();
    }

    //Add labels to the x axis tick marks.
    tickPt = xmin;
    context.textAlign = 'center';
    context.font = '10pt Consolas';
    for (var i = borderL + 0.0; i <= width - (border - borderL); i += offset) {
      context.fillText(tickPt.toInt().toString(), i.toInt(),
          height - borderT + (borderT / 3));
      tickPt += increment;
    }

    //Create tick marks on y axis.
    for (var i = height - borderT - ydiv; i > borderT; i -= ydiv) {
      //left ticks
      context.moveTo(borderL, i.toInt() + 0.5);
      context.lineTo(borderL + tickSize, i.toInt() + 0.5);
      context.stroke();
      //right ticks
      context.moveTo(width - (border - borderL), i.toInt() + 0.5);
      context.lineTo(width - (border - borderL) - tickSize, i.toInt() + 0.5);
      context.stroke();
    }

    //Add labels to the y axis tics.
    context.font = '10pt Consolas';
    context.textAlign = 'right';
    tickPt = ymin;
    if (ymin == ymin.toInt()) {
      for (var i = height - borderT; i > borderT - ydiv; i -= ydiv) {
        context.fillText(tickPt.toInt().toString(), 45, i.toInt());
        tickPt += ystep;
      }
    } // Need test cases for exponent, precision, fixed number labels.


    //Plot the data.
    context.lineWidth = 2;
    if (style == 'data') {
      //Add the data.
      for (var i = borderL + offset; i < width - (border - borderL); i += offset) {
        //sample data
        context.beginPath();
        context.moveTo(i.toInt(), height - borderT);
        context.lineTo(i.toInt(), height - borderT -
            (((ydata[index]) - ymin)/ystep * ydiv));
        context.stroke();
        //sample points
        context.beginPath();
        context.arc(i.toInt(), height - borderT -
            (((ydata[index]) - ymin)/ystep * ydiv), 4, 0, 2 * PI, false);
        context.closePath();
        context.stroke();
        index++;
      }
    } else if (style == 'line' || style == 'linpts') {
      context.beginPath();
      context.lineJoin = "round";
      context.moveTo(borderL + (((xdata[index]) - xmin)/xstep * xdiv),
          height - borderT - (((ydata[index]) - ymin)/ystep * ydiv));
      index++;
      for (var i = borderL + (((xdata[index]) - xmin)/xstep * xdiv);
          i < width - (border - borderL); i += xdiv / xstep) {
        //sample data
        context.lineTo(i.toInt(), height - borderT -
            (((ydata[index]) - ymin)/ystep * ydiv));
        context.stroke();
        index++;
      }
      if (style == 'linpts') {
        index = 0;
        for (var i = borderL + (((xdata[index]) - xmin)/xstep * xdiv);
            i < width - (border - borderL); i += xdiv / xstep) {
          context.beginPath();
          context.arc(i.toInt(), height - borderT -
              (((ydata[index]) - ymin)/ystep * ydiv), 4, 0, 2 * PI, false);
          context.closePath();
          context.fill();
          index++;
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
        context.beginPath();
        context.arc(i.toInt() + 0.5, j.toInt() + 0.5, 1, 0, 2 * PI, false);
        context.closePath();
        context.fill();
      }
    }
  }

  //Method for adding a label to the x axis.
  void xlabel(String xlabelName, [String labelColor = 'rgb(85, 98, 112)']) {
    context.strokeStyle = labelColor;
    context.font = '12pt Candara';
    context.textAlign = 'center';
    context.fillText(xlabelName, width / 2, height - borderT / 10);
  }

  //Method for adding a label to the y axis.
  //TODO: This needs a way of detecting how much room is available
  //relative to the size of the tick labels.  If they take up too much
  //room (ie, numbers like 1.20e+12), then may need to place the y axis
  //label above the tick marks (ie, upper left corner).
  void ylabel(String ylabelName, [String labelColor = 'rgb(85, 98, 112)']) {
    context.strokeStyle = labelColor;
    context.font = '12pt Candara';
    context.textAlign = 'center';
    var lblWidth = context.measureText(ylabelName);
    context.save();
    var deltax = lblWidth.width / 2;
    var deltay = (height / 2) + tickSize;
    context.translate(deltax, deltay);
    context.rotate(-PI / 2);
    context.translate(-deltax, -deltay);
    context.fillText(ylabelName, 0, height / 2);
    context.restore();
  }

  //Method for adding a title.
  void title(String title, [String titleColor = 'rgb(85, 98, 112)']) {
    context.strokeStyle = titleColor;
    context.textAlign = 'center';
    context.font = '16pt Candara';
    context.fillText(title, width / 2, borderT / 2);
  }

  //Method for adding a date stamp.
  void date([bool short = false]) {
    String dateTime = new DateTime().stamp(short);
    context.textAlign = 'right';
    context.font = '10pt Candara';
    context.fillText(dateTime, width, height - tickSize);
  }
}
