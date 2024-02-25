import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../helper/internet_connectivity.dart';
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
  ValueNotifier<bool?> internetConnectionStatus = ValueNotifier<bool?>(null);
  StreamSubscription<bool>? internetConnectionSubscription;
  bool? _hasInternet;

  @override
  void initState() {
    super.initState();
    initData();
    internetConnectionSubscription =
        hasInternetConnection().listen((hasInternet) {
      if (!hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization(context).noInternetConnection),
            action: SnackBarAction(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.wireless);
              },
              label: localization(context).settings,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    internetConnectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> initData() async {
    final keyApplicationId = dotenv.env['KEY_APPLICATION_ID'].toString();
    final keyClientKey = dotenv.env['KEY_CLIENT_KEY'].toString();
    final keyParseServerUrl = dotenv.env['KEY_PARSE_SERVER_URL'].toString();
    WidgetsFlutterBinding.ensureInitialized();
    await Parse().initialize(keyApplicationId, keyParseServerUrl,
        clientKey: keyClientKey, debug: true);
  }

  void attemptToSendReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      checkInitialInternetConnection().then((hasInternet) {
        _hasInternet = hasInternet;
        if (!hasInternet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization(context).noInternetConnection),
              action: SnackBarAction(
                onPressed: () {
                  AppSettings.openAppSettings(type: AppSettingsType.wireless);
                },
                label: localization(context).settings,
              ),
            ),
          );
        } else {
          setState(() {
            _isLoading = true;
          });
          sendReport(bugTitle, bugDescription, operatingSystem, file, context);
          _formKey.currentState!.reset();
          _titleFocus.unfocus();
          _descriptionFocus.unfocus();
          setState(() {
            _isLoading = false;
            file = null;
            fileName = null;
            operatingSystem = null;
          });
        }
      });
    }
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
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label: localization(context).bugTitleLabel,
                                child: TextFormField(
                                  focusNode: _titleFocus,
                                  decoration: InputDecoration(
                                    labelText: localization(context).bugTitle,
                                  ),
                                  style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.04),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localization(context).enterTitle;
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    bugTitle = value!;
                                  },
                                ),
                              ),
                              Semantics(
                                label:
                                    localization(context).bugDescriptionLabel,
                                child: TextFormField(
                                  focusNode: _descriptionFocus,
                                  decoration: InputDecoration(
                                    labelText:
                                        localization(context).bugDescription,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.teal),
                                    ),
                                  ),
                                  style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.04),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localization(context)
                                          .enterDescription;
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    bugDescription = value!;
                                  },
                                  maxLines: 5,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Semantics(
                                label: localization(context).osLabel,
                                child: DropdownButtonFormField<String>(
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  iconDisabledColor: Colors.grey,
                                  iconEnabledColor: Colors.teal,
                                  iconSize:
                                      MediaQuery.of(context).size.width * 0.08,
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
                                                fontSize:
                                                    constraints.maxWidth * 0.04,
                                                letterSpacing: 1,
                                              ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localization(context).selectOS;
                                    }
                                    return null;
                                  },
                                  onChanged: (newValue) {
                                    setState(() {
                                      operatingSystem = newValue;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Semantics(
                                label: localization(context).uploadFile,
                                child: GestureDetector(
                                  onTap: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles();

                                    if (result != null) {
                                      setState(() {
                                        file = result.files.first;
                                        fileName = file!.name;
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Tooltip(
                                        message: localization(context)
                                            .fileUploadLabel,
                                        child: Icon(
                                          Icons.attach_file,
                                          semanticLabel:
                                              localization(context).uploadFile,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(localization(context).uploadFile,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(fileName ??
                                  localization(context).noFileSelected),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: attemptToSendReport,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

void sendReport(String bugTitle, String bugDescription, String? operatingSystem,
    PlatformFile? file, BuildContext context) {
  var bugReport = ParseObject('BugReport')
    ..set('title', bugTitle)
    ..set('description', bugDescription)
    ..set('operatingSystem', operatingSystem);

  if (file != null) {
    var fileToUpload = File(file.path!);
    var parseFile = ParseFile(fileToUpload);

    bugReport.set('file', parseFile);
  }

  bugReport.save().then((response) {
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localization(context).bugReportSent),
            action: SnackBarAction(
              label: localization(context).ok,
              onPressed: () {},
            )),
      );
    }
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localization(context).submissionFailed),
      ),
    );
  });
}
