import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
  String? deviceModel;
  String? operatingSystemVersion;
  bool _isLoading = false;
  ValueNotifier<bool?> internetConnectionStatus = ValueNotifier<bool?>(null);
  StreamSubscription<bool>? internetConnectionSubscription;
  TextEditingController? deviceModelController = TextEditingController();
  TextEditingController? operatingSystemVersionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
    // Set operating system to the current platform
    operatingSystem = getOperatingSystem();
    getDeviceInfo();
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

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        operatingSystemVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        operatingSystemVersion = iosInfo.systemVersion;
    }
    deviceModelController!.text = deviceModel!;
    operatingSystemVersionController!.text = operatingSystemVersion!;
  }

  void attemptToSendReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      deviceModel = deviceModelController!.text;
      operatingSystemVersion = operatingSystemVersionController!.text;
      checkInitialInternetConnection().then((bool? hasInternet) {
        if (!hasInternet!) {
          var screenWidth = MediaQuery.of(context).size.width;
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                width: max(50, screenWidth),
                content: Text(
                  localization(context).noInternetConnection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                ),
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
          sendReport(bugTitle, bugDescription, operatingSystem, deviceModel, operatingSystemVersion, file, context);
          _formKey.currentState!.reset();
          _titleFocus.unfocus();
          _descriptionFocus.unfocus();
          setState(() {
            _isLoading = false;
            file = null;
            fileName = null;
            operatingSystem = getOperatingSystem();
          });
        }
      });
    }
  }

  // Return current user's operating system
  String getOperatingSystem() {
    if (Platform.isAndroid) {
      operatingSystem = 'Android';
    } else if (Platform.isIOS) {
      operatingSystem = 'iOS';
    } else {
      operatingSystem = null;
    }
    return operatingSystem!;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).bugReport,
        const Color.fromRGBO(11, 20, 32, 1),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        unselectedColor: Color.fromRGBO(11, 20, 32, 1),
      ),
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                semanticsLabel: localization(context).loading,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(screenSize.width * 0.04),
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
                                    fontSize: constraints.maxWidth * 0.04,
                                  ),
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
                                          BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.04,
                                  ),
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
                              Semantics(
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      controller: deviceModelController,
                                      decoration: InputDecoration(
                                        labelText: localization(context).deviceModel,
                                      ),
                                      enabled: false,
                                      style: TextStyle(fontSize: screenSize.width * 0.04),
                                    ),
                                    TextFormField(
                                      controller: operatingSystemVersionController,
                                      decoration: InputDecoration(
                                        labelText: localization(context).osVersion,
                                      ),
                                      enabled: false,
                                      style: TextStyle(fontSize: screenSize.width * 0.04),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              Semantics(
                                label: localization(context).osLabel,
                                child: DropdownButtonFormField<String>(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: screenSize.width * 0.08,
                                    semanticLabel:
                                        localization(context).selectOSLabel,
                                  ),
                                  iconDisabledColor: Colors.grey,
                                  iconEnabledColor: Colors.black,
                                  iconSize: screenSize.width * 0.08,
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
                                        color: Colors.black,
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
                                          semanticsLabel: value,
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
                              SizedBox(height: screenSize.height * 0.02),
                              Semantics(
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
                                        child: SizedBox(
                                          width: max(
                                            50,
                                            screenSize.width * 0.05,
                                          ),
                                          height:
                                              max(50, screenSize.height * 0.05),
                                          child: Icon(
                                            Icons.attach_file,
                                            size: screenSize.width * 0.07,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenSize.width * 0.02),
                                      Text(localization(context).uploadFile,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: screenSize.width * 0.04,
                              ),
                              Text(fileName ??
                                  localization(context).noFileSelected),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: attemptToSendReport,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(11, 20, 32, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenSize.height * 0.01,
                                    ),
                                  ),
                                  child: Text(
                                    localization(context).submit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: screenSize.width * 0.05,
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

void sendReport(String bugTitle, String bugDescription, String? operatingSystem, String? deviceModel, String? operatingSystemVersion,
    PlatformFile? file, BuildContext context) {
  var screenWidth = MediaQuery.of(context).size.width;
  var bugReport = ParseObject('BugReport')
    ..set('title', bugTitle)
    ..set('description', bugDescription)
    ..set('operatingSystem', operatingSystem)
    ..set('deviceModel', deviceModel)
    ..set('operatingSystemVersion', operatingSystemVersion);

  if (file != null) {
    var fileToUpload = File(file.path!);
    var parseFile = ParseFile(fileToUpload);

    bugReport.set('file', parseFile);
  }

  bugReport.save().then((response) {
    if (response.success) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            width: max(50, screenWidth),
            content: Text(
              localization(context).bugReportSent,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white,
                  ),
            ),
            action: SnackBarAction(
              label: localization(context).ok,
              onPressed: () {},
            ),
          ),
        );
    }
  }).catchError((error) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          width: max(50, screenWidth),
          content: Text(
            localization(context).submissionFailed,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
          ),
          action: SnackBarAction(
            label: localization(context).ok,
            onPressed: () {},
          ),
        ),
      );
  });
}
