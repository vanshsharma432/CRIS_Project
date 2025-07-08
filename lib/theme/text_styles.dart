import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class ATextStyles {
  // Titles
  static TextStyle cardTitle = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AColors.textPrimary,
  );

  static TextStyle headingLarge = GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AColors.textPrimary,
  );

  static TextStyle headingMedium = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AColors.textPrimary,
  );

  // Body texts
  static TextStyle bodySmall = GoogleFonts.nunitoSans(
    fontSize: 12,
    color: AColors.textSecondary,
  );

  static TextStyle bodyText = GoogleFonts.nunitoSans(
    fontSize: 14,
    color: AColors.textSecondary,
  );

  // Labels & Captions
  static TextStyle labelText = GoogleFonts.nunitoSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AColors.gray,
  );

  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 12,
    color: AColors.gray,
  );

  // Status indicators
  static TextStyle statusConfirmed = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static TextStyle statusPending = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.orange,
  );
  static const bodyBold = TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
  static const TextStyle tableCell = TextStyle(
    color: AColors.darkText,
    fontSize: 14,
  );

  static const TextStyle passengerLabel = TextStyle(
    fontSize: 10,
    color: AColors.gray,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle passengerValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AColors.primary,
  );

  static const TextStyle tableHeader = TextStyle(
    fontWeight: FontWeight.bold,
    color: AColors.black87,
  );

  static const TextStyle footerHint = TextStyle(
    fontSize: 12,
    color: Colors.grey,
    fontStyle: FontStyle.italic,
  );

  //filters
  static const heading = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AColors.darkText);
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: 0.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

}
