// lib/data/services/excel_export_service.dart
// Service for exporting activity history to Excel files

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../models/activity_history_item.dart';
import '../models/action_type.dart';
import 'activity_history_service.dart';
import 'user_service.dart';

/// Service for generating Excel exports of activity history
class ExcelExportService {
  /// Export a single user's activity history to an Excel file
  Future<String> exportHistory(
    List<ActivityHistoryItem> history,
    String userName,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Activity History'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90E2'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );

    final dataStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Left,
    );

    // Title
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('VOMAS Activity History - $userName')
      ..cellStyle = CellStyle(bold: true, fontSize: 14);

    // Export date
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue(
        'Exported on: ${DateTime.now().toString().substring(0, 19)}',
      )
      ..cellStyle = CellStyle(fontSize: 10);

    // Headers
    final headers = ['#', 'Name', 'Action', 'Measurements', 'Date', 'Time'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    // Data rows
    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      final rowIndex = i + 4;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(i + 1)
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(userName)
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(item.actionType.displayName)
        ..cellStyle = dataStyle;

      final measurementStr = item.measurements.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(measurementStr)
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = TextCellValue(item.formattedDate)
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        ..value = TextCellValue(item.formattedTime)
        ..cellStyle = dataStyle;
    }

    // Column widths
    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 35);
    sheet.setColumnWidth(3, 40);
    sheet.setColumnWidth(4, 18);
    sheet.setColumnWidth(5, 12);

    return _saveExcel(excel, 'VOMAS_${userName.replaceAll(' ', '_')}');
  }

  /// Export ALL users' history into a single Excel file
  Future<String> exportAllUsersHistory() async {
    final userService = UserService();
    final historyService = ActivityHistoryService();
    await userService.init();
    await historyService.init();

    final users = await userService.getUsers();
    if (users.isEmpty) throw Exception('No users found');

    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['All Users History'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90E2'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );

    final dataStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Left,
    );

    // Title
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('VOMAS Activity History - All Users')
      ..cellStyle = CellStyle(bold: true, fontSize: 14);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue(
        'Exported on: ${DateTime.now().toString().substring(0, 19)}',
      )
      ..cellStyle = CellStyle(fontSize: 10);

    // Headers
    final headers = ['#', 'Name', 'Action', 'Measurements', 'Date', 'Time'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    // Collect all users' history
    var rowCounter = 0;
    for (final user in users) {
      historyService.setUserId(user.id);
      final history = await historyService.getHistory();

      for (final item in history) {
        final rowIndex = rowCounter + 4;

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
          )
          ..value = IntCellValue(rowCounter + 1)
          ..cellStyle = dataStyle;

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
          )
          ..value = TextCellValue(user.name)
          ..cellStyle = dataStyle;

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
          )
          ..value = TextCellValue(item.actionType.displayName)
          ..cellStyle = dataStyle;

        final measurementStr = item.measurements.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
          )
          ..value = TextCellValue(measurementStr)
          ..cellStyle = dataStyle;

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
          )
          ..value = TextCellValue(item.formattedDate)
          ..cellStyle = dataStyle;

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
          )
          ..value = TextCellValue(item.formattedTime)
          ..cellStyle = dataStyle;

        rowCounter++;
      }
    }

    if (rowCounter == 0) throw Exception('No history found for any user');

    // Column widths
    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 35);
    sheet.setColumnWidth(3, 40);
    sheet.setColumnWidth(4, 18);
    sheet.setColumnWidth(5, 12);

    return _saveExcel(excel, 'VOMAS_All_Users');
  }

  /// Get save directory (app-scoped, no permissions needed)
  Future<String> _getSavePath() async {
    // On desktop: try system Downloads directory first
    if (!Platform.isAndroid && !Platform.isIOS) {
      try {
        final dir = await getDownloadsDirectory();
        if (dir != null) return dir.path;
      } catch (_) {}
    }

    // On mobile / fallback: use app documents directory
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Save Excel workbook to Downloads and return path
  Future<String> _saveExcel(Excel excel, String prefix) async {
    final savePath = await _getSavePath();
    final timestamp = DateTime.now()
        .toString()
        .substring(0, 10)
        .replaceAll('-', '');
    final fileName = '${prefix}_$timestamp.xlsx';
    final filePath = '$savePath/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    }

    throw Exception('Failed to generate Excel file');
  }

  /// Open the exported file with the system default app
  static Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }

  /// Share the exported file using the system share sheet
  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'VOMAS Activity History',
      text: 'Activity history exported from VOMAS',
    );
  }
}
