import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
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
    await dotenv.load();
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization(context).bugTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextFormField(
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
                        FocusScope.of(context).requestFocus(_descriptionFocus);
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      localization(context).bugDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextFormField(
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
                    const SizedBox(height: 8.0),
                    Text(
                      localization(context).operatingSystem,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      iconDisabledColor: Colors.grey,
                      iconEnabledColor: Colors.teal,
                      iconSize: 24,
                      decoration: InputDecoration(
                        filled: true,
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
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
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
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform
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
                          Icon(
                            Icons.attach_file,
                            semanticLabel: localization(context).uploadFile,
                            size: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize,
                            applyTextScaling: true,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(localization(context).uploadFile,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(fileName ?? localization(context).noFileSelected),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  sendReport(bugTitle, bugDescription,
                                      operatingSystem, file);
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

void sendReport(String bugTitle, String bugDescription, String? operatingSystem,
    PlatformFile? file) async {
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
    print('Bug Report Saved Successfully');
  } else {
    print('Failed to Save Bug Report: ${response.error!.message}');
  }
}
