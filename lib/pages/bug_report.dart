import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({Key? key}) : super(key: key);

  @override
  BugReportPageState createState() => BugReportPageState();
}

class BugReportPageState extends State<BugReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  String bugTitle = '';
  String bugDescription = '';
  String? operatingSystem;
  List<String> operatingSystems = ['Android', 'iOS', 'HarmonyOS'];
  PlatformFile? file;
  String? fileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final keyApplicationId = dotenv.env['KEY_APPLICATION_ID'].toString();
    final keyClientKey = dotenv.env['KEY_CLIENT_KEY'].toString();
    final keyParseServerUrl = dotenv.env['KEY_PARSE_SERVER_URL'].toString();
    WidgetsFlutterBinding.ensureInitialized();
    await Parse().initialize(keyApplicationId, keyParseServerUrl,
        clientKey: keyClientKey, debug: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, localization(context).bugReport),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization(context).bugTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Semantics(
                          label: localization(context).bugTitleLabel,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                            style: TextStyle(
                                fontSize: constraints.maxWidth * 0.04),
                            focusNode: _titleFocus,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return localization(context).enterTitle;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                bugTitle = value;
                              });
                            },
                            onFieldSubmitted: (_) {
                              _titleFocus.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_descriptionFocus);
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          localization(context).bugDescription,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Semantics(
                          label: localization(context).bugDescriptionLabel,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                            style: TextStyle(
                                fontSize: constraints.maxWidth * 0.04),
                            focusNode: _descriptionFocus,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return localization(context).enterDescription;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                bugDescription = value;
                              });
                            },
                            maxLines: 4,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          localization(context).operatingSystem,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Semantics(
                          label: localization(context).osLabel,
                          child: DropdownButtonFormField<String>(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            iconDisabledColor: Colors.grey,
                            iconEnabledColor: Colors.teal,
                            iconSize: MediaQuery.of(context).size.width * 0.08,
                            decoration: InputDecoration(
                              filled: true,
                              labelText: localization(context).selectOS,
                              labelStyle:
                                  Theme.of(context).textTheme.bodyMedium,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            value: operatingSystem,
                            items: operatingSystems.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.6,
                                  child: Text(
                                    value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.black,
                                          fontSize: constraints.maxWidth * 0.04,
                                          letterSpacing: 1,
                                        ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                operatingSystem = value.toString();
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return localization(context).selectOS;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Semantics(
                          label: localization(context).fileUploadLabel,
                          child: GestureDetector(
                            onTap: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(type: FileType.any);
                              if (result != null) {
                                setState(() {
                                  file = result.files.single;
                                  fileName = file!.name;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Tooltip(
                                  message:
                                      localization(context).fileUploadLabel,
                                  child: Icon(
                                    Icons.attach_file,
                                    semanticLabel:
                                        localization(context).uploadFile,
                                    size: MediaQuery.of(context).size.width *
                                        0.07,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(localization(context).uploadFile,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(fileName ?? localization(context).noFileSelected),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  sendReport(bugTitle, bugDescription,
                                      operatingSystem, file);
                                  operatingSystem = null;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(localization(context)
                                          .submittingReport),
                                    ),
                                  );
                                  _formKey.currentState!.reset();
                                  _titleFocus.unfocus();
                                  _descriptionFocus.unfocus();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(localization(context)
                                          .submissionFailed),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: constraints.maxWidth * 0.015),
                            ),
                            child: Text(
                              localization(context).submit,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: constraints.maxWidth * 0.05,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// TODO: Implement the localized message
Future<String> sendReport(String bugTitle, String bugDescription,
    String? operatingSystem, PlatformFile? file) async {
  String message = '';
  var bugReport = ParseObject('BugReport')
    ..set('title', bugTitle)
    ..set('description', bugDescription)
    ..set('operatingSystem', operatingSystem);

  if (file != null) {
    var fileToUpload = File(file.path!);
    var parseFile = ParseFile(fileToUpload);

    bugReport.set('file', parseFile);
  }

  var response = await bugReport.save();

  if (response.success) {
    message = 'Bug Report Saved Successfully';
  } else {
    message = 'Failed to Save Bug Report: ${response.error!.message}';
  }
  return message;
}
