// lib/data/services/excel_export_service.dart
// Service for exporting activity history to Excel files with session data

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

    // Headers: S.No, Name, Action, Shoulder, Elbow, Wrist, Time, Duration
    final headers = [
      'S.No',
      'Name',
      'Action',
      'Shoulder',
      'Elbow',
      'Wrist',
      'Time',
      'Duration',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    // Data rows — each data point as a row, grouped by session
    var rowIndex = 4;
    for (var sessionIdx = 0; sessionIdx < history.length; sessionIdx++) {
      final item = history[sessionIdx];
      final sessionNum = sessionIdx + 1;

      if (item.dataPoints.isEmpty) {
        // Session with no data points — show one summary row
        _writeSessionRow(
          sheet: sheet,
          rowIndex: rowIndex,
          sessionNum: sessionNum,
          userName: userName,
          actionName: item.actionType.displayName,
          showSessionInfo: true,
          shoulder: '',
          elbow: '',
          wrist: '',
          time: _formatTime(item.timestamp),
          duration: item.formattedDuration,
          dataStyle: dataStyle,
        );
        rowIndex++;
      } else {
        // Session with data points — one row per data point
        final midIndex = item.dataPoints.length ~/ 2;

        for (var dpIdx = 0; dpIdx < item.dataPoints.length; dpIdx++) {
          final dp = item.dataPoints[dpIdx];
          final isMiddleRow = dpIdx == midIndex;
          final isLastRow = dpIdx == item.dataPoints.length - 1;

          _writeSessionRow(
            sheet: sheet,
            rowIndex: rowIndex,
            sessionNum: isMiddleRow ? sessionNum : null,
            userName: userName,
            actionName: isMiddleRow ? item.actionType.displayName : null,
            showSessionInfo: isMiddleRow,
            shoulder:
                'angle:${dp.shoulderAngle.toStringAsFixed(1)} speed:${dp.shoulderSpeed.toStringAsFixed(1)}',
            elbow:
                'angle:${dp.elbowAngle.toStringAsFixed(1)} speed:${dp.elbowSpeed.toStringAsFixed(1)}',
            wrist:
                'angle:${dp.wristAngle.toStringAsFixed(1)} speed:${dp.wristSpeed.toStringAsFixed(1)}',
            time: _formatTimeWithSeconds(dp.recordedAt),
            duration: isLastRow ? item.formattedDuration : null,
            dataStyle: dataStyle,
          );
          rowIndex++;
        }
      }

      // Add blank row between sessions for visual separation
      if (sessionIdx < history.length - 1) {
        rowIndex++;
      }
    }

    // Column widths
    sheet.setColumnWidth(0, 8); // S.No
    sheet.setColumnWidth(1, 15); // Name
    sheet.setColumnWidth(2, 35); // Action
    sheet.setColumnWidth(3, 30); // Shoulder
    sheet.setColumnWidth(4, 30); // Elbow
    sheet.setColumnWidth(5, 30); // Wrist
    sheet.setColumnWidth(6, 15); // Time
    sheet.setColumnWidth(7, 15); // Duration

    return _saveExcel(excel, 'VOMAS_${userName.replaceAll(' ', '_')}');
  }

  /// Write a single row to the session data sheet
  void _writeSessionRow({
    required Sheet sheet,
    required int rowIndex,
    required int? sessionNum,
    required String userName,
    required String? actionName,
    required bool showSessionInfo,
    required String shoulder,
    required String elbow,
    required String wrist,
    required String time,
    required String? duration,
    required CellStyle dataStyle,
  }) {
    // S.No — only on the middle row of each session
    if (sessionNum != null) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(sessionNum)
        ..cellStyle = dataStyle;
    }

    // Name — every row
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
      ..value = TextCellValue(userName)
      ..cellStyle = dataStyle;

    // Action — only on the middle row of each session
    if (actionName != null) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(actionName)
        ..cellStyle = dataStyle;
    }

    // Shoulder
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
      ..value = TextCellValue(shoulder)
      ..cellStyle = dataStyle;

    // Elbow
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
      ..value = TextCellValue(elbow)
      ..cellStyle = dataStyle;

    // Wrist
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
      ..value = TextCellValue(wrist)
      ..cellStyle = dataStyle;

    // Time
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
      ..value = TextCellValue(time)
      ..cellStyle = dataStyle;

    // Duration — only on last row of each session
    if (duration != null) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
        ..value = TextCellValue(duration)
        ..cellStyle = dataStyle;
    }
  }

  /// Format time as "h:mm PM"
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  /// Format time with seconds as "h:mm:ss PM"
  String _formatTimeWithSeconds(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute:$second $period';
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
    final headers = [
      'S.No',
      'Name',
      'Action',
      'Shoulder',
      'Elbow',
      'Wrist',
      'Time',
      'Duration',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    // Collect all users' history
    var rowIndex = 4;
    var sessionCounter = 0;

    for (final user in users) {
      historyService.setUserId(user.id);
      final history = await historyService.getHistory();

      for (var sessionIdx = 0; sessionIdx < history.length; sessionIdx++) {
        final item = history[sessionIdx];
        sessionCounter++;

        if (item.dataPoints.isEmpty) {
          _writeSessionRow(
            sheet: sheet,
            rowIndex: rowIndex,
            sessionNum: sessionCounter,
            userName: user.name,
            actionName: item.actionType.displayName,
            showSessionInfo: true,
            shoulder: '',
            elbow: '',
            wrist: '',
            time: _formatTime(item.timestamp),
            duration: item.formattedDuration,
            dataStyle: dataStyle,
          );
          rowIndex++;
        } else {
          final midIndex = item.dataPoints.length ~/ 2;

          for (var dpIdx = 0; dpIdx < item.dataPoints.length; dpIdx++) {
            final dp = item.dataPoints[dpIdx];
            final isMiddleRow = dpIdx == midIndex;
            final isLastRow = dpIdx == item.dataPoints.length - 1;

            _writeSessionRow(
              sheet: sheet,
              rowIndex: rowIndex,
              sessionNum: isMiddleRow ? sessionCounter : null,
              userName: user.name,
              actionName: isMiddleRow ? item.actionType.displayName : null,
              showSessionInfo: isMiddleRow,
              shoulder:
                  'angle:${dp.shoulderAngle.toStringAsFixed(1)} speed:${dp.shoulderSpeed.toStringAsFixed(1)}',
              elbow:
                  'angle:${dp.elbowAngle.toStringAsFixed(1)} speed:${dp.elbowSpeed.toStringAsFixed(1)}',
              wrist:
                  'angle:${dp.wristAngle.toStringAsFixed(1)} speed:${dp.wristSpeed.toStringAsFixed(1)}',
              time: _formatTimeWithSeconds(dp.recordedAt),
              duration: isLastRow ? item.formattedDuration : null,
              dataStyle: dataStyle,
            );
            rowIndex++;
          }
        }

        // Blank row between sessions
        rowIndex++;
      }
    }

    if (sessionCounter == 0) throw Exception('No history found for any user');

    // Column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 35);
    sheet.setColumnWidth(3, 30);
    sheet.setColumnWidth(4, 30);
    sheet.setColumnWidth(5, 30);
    sheet.setColumnWidth(6, 15);
    sheet.setColumnWidth(7, 15);

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
