import 'package:flutter/material.dart';

/// Course "Responsive Layouts" notes: treat as **tablet/desktop** when there is
/// room for master–detail: landscape-ish AND width at least 720 logical pixels.
///
/// Use this to pick between a [Row] (list + details) vs a single-pane phone flow.
bool shouldShowMasterDetailSideBySide(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final width = size.width;
  final height = size.height;
  return width > height && width > 720;
}
