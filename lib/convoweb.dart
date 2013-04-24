// Copyright (c) 2013, scribeGriff (Richard Griffith)
// https://github.com/scribeGriff/ConvoWeb
// All rights reserved.  Please see the LICENSE.md file.

/**
 *  Client side library for use with ConvoLab.
 */

library convoweb;

import 'package:convolab/convolab.dart';

import 'dart:html';
import 'dart:json' as json;
import 'dart:math';
import 'dart:async';
import 'dart:collection';

part 'src/utilities/axis_config_results.dart';
part 'src/utilities/date_time.dart';

part 'src/websocket/request_data_ws.dart';

part 'src/ui/tabbed_panel.dart';

part 'src/visualization/axis_config.dart';
part 'src/visualization/plot2d.dart';