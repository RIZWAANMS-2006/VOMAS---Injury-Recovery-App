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

    _setupHeaders(sheet, 'VOMAS Activity History - $userName');
    _fillData(sheet, history, userName, 4);

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

    _setupHeaders(sheet, 'VOMAS Activity History - All Users');

    var rowIndex = 4;
    var sessionCounter = 0;

    for (final user in users) {
      historyService.setUserId(user.id);
      final history = await historyService.getHistory();
      
      if (history.isNotEmpty) {
        sessionCounter++;
        rowIndex = _fillData(sheet, history, user.name, rowIndex);
      }
    }

    if (sessionCounter == 0) throw Exception('No history found for any user');

    return _saveExcel(excel, 'VOMAS_All_Users');
  }

  void _setupHeaders(Sheet sheet, String title) {
    final titleStyle = CellStyle(bold: true, fontSize: 14);
    final dateStyle = CellStyle(fontSize: 10);
    
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90E2'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );
    
    final subHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#D3E2F4'),
      fontColorHex: ExcelColor.fromHexString('#000000'),
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
    );

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue(title)
      ..cellStyle = titleStyle;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('Exported on: ${DateTime.now().toString().substring(0, 19)}')
      ..cellStyle = dateStyle;

    // Header Line 1
    final baseHeaders = ['S.No', 'Name', 'Time', 'Duration'];
    for (var i = 0; i < baseHeaders.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2))
        ..value = TextCellValue(baseHeaders[i])
        ..cellStyle = headerStyle;
    }

    int colIndex = 4;
    for (var action in ActionType.values) {
      // Main action header
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 2))
        ..value = TextCellValue(action.displayName)
        ..cellStyle = headerStyle;
        
      // Second header line (Shoulder, Elbow, Wrist)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 3))
        ..value = TextCellValue('Shoulder (A/S)')
        ..cellStyle = subHeaderStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex + 1, rowIndex: 3))
        ..value = TextCellValue('Elbow (A/S)')
        ..cellStyle = subHeaderStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex + 2, rowIndex: 3))
        ..value = TextCellValue('Wrist (A/S)')
        ..cellStyle = subHeaderStyle;

      sheet.setColumnWidth(colIndex, 15);
      sheet.setColumnWidth(colIndex + 1, 15);
      sheet.setColumnWidth(colIndex + 2, 15);
      colIndex += 3;
    }
    
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
  }

  int _fillData(Sheet sheet, List<ActivityHistoryItem> history, String userName, int startRow) {
    final dataStyle = CellStyle(fontSize: 11, horizontalAlign: HorizontalAlign.Left);
    final actionIndexByName = {
      for (var i = 0; i < ActionType.values.length; i++)
        ActionType.values[i].displayName: i,
    };
    var rowIndex = startRow;
    
    for (var sessionIdx = 0; sessionIdx < history.length; sessionIdx++) {
      final item = history[sessionIdx];
      final sessionNum = sessionIdx + 1;
      
      if (item.dataPoints.isEmpty) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          ..value = IntCellValue(sessionNum)
          ..cellStyle = dataStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          ..value = TextCellValue(userName)
          ..cellStyle = dataStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          ..value = TextCellValue(_formatTime(item.timestamp))
          ..cellStyle = dataStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          ..value = TextCellValue(item.formattedDuration)
          ..cellStyle = dataStyle;
        rowIndex++;
      } else {
        final actionEntries = item.dataPoints.entries.toList();
        final maxLength = actionEntries.fold(
          0,
          (maxValue, entry) =>
              entry.value.length > maxValue ? entry.value.length : maxValue,
        );

        for (var dpIdx = 0; dpIdx < maxLength; dpIdx++) {
          final dpForTime = actionEntries
              .map((entry) => entry.value)
              .firstWhere(
                (list) => dpIdx < list.length,
                orElse: () => const <SessionDataPoint>[],
              );
          final recordedAt = dpForTime.isNotEmpty
              ? dpForTime[dpIdx].recordedAt
              : item.timestamp;
          final isFirstRow = dpIdx == 0;
          final isLastRow = dpIdx == maxLength - 1;

          if (isFirstRow) {
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
              ..value = IntCellValue(sessionNum)
              ..cellStyle = dataStyle;
          }
          
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            ..value = TextCellValue(userName)
            ..cellStyle = dataStyle;
            
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            ..value = TextCellValue(_formatTimeWithSeconds(recordedAt))
            ..cellStyle = dataStyle;
            
          if (isLastRow) {
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
              ..value = TextCellValue(item.formattedDuration)
              ..cellStyle = dataStyle;
          }

          for (final entry in actionEntries) {
            final actionIndex = actionIndexByName[entry.key];
            if (actionIndex == null) continue;
            if (dpIdx >= entry.value.length) continue;

            final dp = entry.value[dpIdx];
            final actionOffset = 4 + (actionIndex * 3);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: actionOffset, rowIndex: rowIndex))
              ..value = TextCellValue('${dp.shoulder.angle.toStringAsFixed(1)} / ${dp.shoulder.speed.toStringAsFixed(1)}')
              ..cellStyle = dataStyle;
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: actionOffset + 1, rowIndex: rowIndex))
              ..value = TextCellValue('${dp.elbow.angle.toStringAsFixed(1)} / ${dp.elbow.speed.toStringAsFixed(1)}')
              ..cellStyle = dataStyle;
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: actionOffset + 2, rowIndex: rowIndex))
              ..value = TextCellValue('${dp.wrist.angle.toStringAsFixed(1)} / ${dp.wrist.speed.toStringAsFixed(1)}')
              ..cellStyle = dataStyle;
          }

          rowIndex++;
        }
      }
      // Empty row to separate sessions
      rowIndex++;
    }
    return rowIndex;
  }

  String _formatTime(DateTime dt) {
    var hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    hour = hour == 0 ? 12 : hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatTimeWithSeconds(DateTime dt) {
    var hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    hour = hour == 0 ? 12 : hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  Future<String> _getSavePath() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      try {
        final dir = await getDownloadsDirectory();
        if (dir != null) return dir.path;
      } catch (_) {}
    }
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> _saveExcel(Excel excel, String prefix) async {
    final savePath = await _getSavePath();
    final timestamp = DateTime.now().toString().substring(0, 10).replaceAll('-', '');
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

  static Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }

  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'VOMAS Activity History',
      text: 'Activity history exported from VOMAS',
    );
  }
}