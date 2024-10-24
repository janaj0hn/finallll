import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  // final Function(String id, String subId, Map<String, dynamic> detail) onEdit;

  SearchResultsScreen({
    required this.results,
    // required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Shisya_ID')),
              DataColumn(label: Text('Sishya Type')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Date Of Birth')),
              DataColumn(label: Text('Samasreyanam Date')),
              DataColumn(label: Text('Mobile 1')),
              DataColumn(label: Text('Actions')),
            ],
            rows: results.map((detail) {
              String subId = detail['subId'] ?? '';
              String id = detail['id'] ?? '';

              return DataRow(
                cells: [
                  DataCell(Text(subId)),
                  DataCell(Text(detail['SishyaType'] ?? '')),
                  DataCell(Text(detail['Name'] ?? '')),
                  DataCell(Text(detail['Date Of Birth'] ?? '')),
                  DataCell(Text(detail['Samasreyanam Date'] ?? '')),
                  DataCell(Text(detail['Mobile 1'] ?? '')),
                  DataCell(DropdownButton<String>(
                    hint: Text('Actions'),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'view',
                        child: Text('View'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value == 'edit') {
                        // onEdit(id, subId, detail);
                      } else if (value == 'view') {
                        // Handle view action here
                      }
                    },
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
