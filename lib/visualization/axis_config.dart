/* ************************************************************ *
 *  Calculate optimum tick, min and max                         *
 *  Library: ConvoWeb (c) 2012 scribeGriff                      *
 *  To configure an axis:                                       *
 *  AxisConfigResults axisCfg = new AxisConfig().axes(data);    *
 *  create a canvas element to draw to                          *
 *  DrawGraph graph = new Graph(data, axisCfg,, index, range);  *
 *  axisTic = axisCfg.tic;                                      *
 *  axisMin = axisCfg.min;                                      *
 *  axisMax = axisCfg.max;                                      *
 *  axisStep = axisCfg.step;                                    *
 * ************************************************************ */

class AxisConfig {

  AxisConfigResults axes(List data, int distance) {
    //Target a major division of around 50 pixels
    int numDivs = (distance/50).floor().toInt();
    //Compute the minimum clean range based on the data
    num range = idealRange(data);
    //Compute the spacing of the major divisions
    num divSp = idealTicks(range, numDivs);
    //Update the number of divisions to be a nice multiple
    num minsc = ((findMin(data)/divSp).floor())*divSp;
    num maxsc = ((findMax(data)/divSp).ceil())*divSp;
    if (minsc == maxsc) {
      minsc = 0.5 * minsc;
      maxsc = 1.5 * maxsc;
    }
    //Update actual distance of each major division
    num delDiv = distance * divSp/(maxsc - minsc);
    return new AxisConfigResults(delDiv, minsc, maxsc, divSp);
  }

  num idealRange(List data) {
    num ideal;
    num range = findMax(data) - findMin(data);
    if (range == 0) {
      if (data[0] == 0) {
        range = 1;
      } else {
        range = data[0];
      }
    }
    num exponent = (log10(range)).floor();
    num fraction = range/pow(10, exponent);

    if(fraction <= 1) {
      ideal = 1;
    } else if(fraction <= 2) {
      ideal = 2;
    } else if(fraction <= 5) {
      ideal = 5;
    } else ideal = 10;
    return ideal * pow(10, exponent);
  }

  num idealTicks(num delta, int maxNumTics) {
    num range = delta/maxNumTics;
    int exponent = (log10(range)).floor().toInt();
    range *= pow(10.0, -exponent);
    if (range > 5.0) range = 10.0;
    else if (range > 2.0) range = 5.0;
    else if (range > 1.0) range = 2.0;
    range *= pow(10.0, exponent);
    return range;
  }
}
