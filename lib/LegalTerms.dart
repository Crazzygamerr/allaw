import 'dart:io';

import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:allaw/widgets/ASearch.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:allaw/widgets/AExpansionTile.dart';

class LegalTerms extends StatefulWidget {
	@override
	_LegalTermsState createState() => _LegalTermsState();
}

class _LegalTermsState extends State<LegalTerms>{

	late Sheet sheet;
	bool loading = true;
	String searchTerm = "";

	@override
	void initState() {
		super.initState();
		getTerms();
	}

	getTerms() async {
		String dir = (await getApplicationDocumentsDirectory()).path;
		
		FirebaseStorage storage = FirebaseStorage.instance;
		Reference? ref;
		File xlsxFile = File('$dir/Legal Terms.xlsx');
		
		await storage.ref().listAll().then((value) {
			ref = value.items.singleWhere((element) => element.name == "Legal Terms.xlsx");
		});
		await storage.ref(ref!.fullPath).writeToFile(xlsxFile);

		List<int> bytes = xlsxFile.readAsBytesSync();
		var excel = Excel.decodeBytes(bytes);

		sheet = excel.tables["Sheet1"]!;
		setState(() {
			loading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			child: Column(
				children: [
					
					ASearchWidget(
						onChanged: (String s) {
						setState(() {
							searchTerm = s;
						});
						}
					),
					
					Expanded(
						child: Padding(
							padding: aPaddingLTRB(10, 10, 10, 10),
							child: Container(
								decoration: aBoxDecor15B(),
								child: (!loading)?ClipRRect(
									borderRadius: BorderRadius.circular(15),
									child: Scrollbar(
										child: ListView.builder(
										itemCount: sheet.rows.length,
										itemBuilder: (context, index) {
											bool b0 = sheet.rows[index][0].toString().toLowerCase().contains(searchTerm.toLowerCase());
											bool b1 = sheet.rows[index][1].toString().toLowerCase().contains(searchTerm.toLowerCase());
											
											return (b0 | b1)?Container(
												decoration: aBoxDecorBottom(),
												child: AExpansionTile(
													iconColor: Colors.black,
													title: Container(
														padding: aPaddingLTRB(20, 20, 10, 20),
														child: Text(
															sheet.rows[index][0]?.value,
														),
												),
												children: [
													Container(
														padding: aPaddingLTRB(10, 0, 10, 10),
														alignment: Alignment.centerLeft,
														child: Text(
															sheet.rows[index][1]?.value,
														),
													),
												],
												//isExpanded:
											),
											):Container();
										},
										),
									),
								) : Center(
									child: CircularProgressIndicator(),
								),
							),
						),
					),
				],
			),
		);
	}

}
