import 'package:flutter/material.dart';

// Brand colors (single source of truth)
const Color kPrimary = Color(0xff1aa260);
const Color kBlue = Color(0xff4285F4);
const Color kRed = Color(0xffde5246);

// Alpha helpers (avoids deprecated withOpacity)
int a(double o) => (o * 255).round().clamp(0, 255);
Color alpha(Color c, double o) => c.withAlpha(a(o));
