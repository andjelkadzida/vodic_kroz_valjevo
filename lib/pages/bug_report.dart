import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../helper/connection_problem_view.dart';
import '../helper/internet_connectivity.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';

typedef BugReportSender = Future<void> Function(
  String title,
  String description,
  String? operatingSystem,
  PlatformFile? file,
);

class BugReportPage extends StatefulWidget {
  const BugReportPage({Key? key, this.sender = sendBugReport})
      : super(key: key);

  final BugReportSender sender;

  @override
  State<BugReportPage> createState() => BugReportPageState();
}

class BugReportPageState extends State<BugReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _operatingSystemFocus = FocusNode();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _operatingSystems = const ['Android', 'iOS', 'HarmonyOS'];
  String _title = '';
  String _description = '';
  String? _operatingSystem;
  PlatformFile? _file;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _operatingSystem = _currentOperatingSystem();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _operatingSystemFocus.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _currentOperatingSystem() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      if (_titleController.text.isEmpty) {
        _titleFocus.requestFocus();
      } else if (_descriptionController.text.isEmpty) {
        _descriptionFocus.requestFocus();
      } else {
        _operatingSystemFocus.requestFocus();
      }
      return;
    }
    form.save();
    setState(() => _isLoading = true);
    try {
      final hasConnection = await checkInitialInternetConnection();
      if (!mounted) return;
      if (!hasConnection) {
        unawaited(showConnectionProblemDialog(context, disconnected: true));
        return;
      }

      await widget.sender(_title, _description, _operatingSystem, _file);
      if (!mounted) return;
      form.reset();
      _titleFocus.unfocus();
      _descriptionFocus.unfocus();
      setState(() {
        _file = null;
        _operatingSystem = _currentOperatingSystem();
      });
      HapticFeedback.mediumImpact();
      _showMessage(localization(context).bugReportSent);
    } catch (error) {
      debugPrint('Bug report submission failed: ${error.runtimeType}');
      if (!mounted) return;
      if (isPossibleConnectionFailure(error)) {
        try {
          final connected = await checkInitialInternetConnection();
          if (!mounted) return;
          unawaited(
              showConnectionProblemDialog(context, disconnected: !connected));
        } catch (connectivityError) {
          debugPrint(
              'Connectivity check failed: ${connectivityError.runtimeType}');
          if (mounted) {
            unawaited(
                showConnectionProblemDialog(context, disconnected: false));
          }
        }
      } else {
        _showMessage(localization(context).submissionFailed);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (!mounted || result == null) return;
      if (result.files.isEmpty) {
        throw StateError('The file picker returned no file.');
      }
      setState(() => _file = result.files.first);
    } catch (error) {
      debugPrint('File selection failed: ${error.runtimeType}');
      if (mounted) _showMessage(localization(context).submissionFailed);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          content: Text(message),
          action: SnackBarAction(
            label: localization(context).ok,
            onPressed: () {},
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: SafeArea(
              top: false,
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final padding =
                      (constraints.maxWidth * 0.04).clamp(12.0, 24.0);
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ExcludeSemantics(
                                child: Text(
                                  localization(context).bugTitle,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              Semantics(
                                label: localization(context).bugTitleLabel,
                                child: TextFormField(
                                  focusNode: _titleFocus,
                                  controller: _titleController,
                                  decoration:
                                      const InputDecoration(errorMaxLines: 5),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? localization(context).enterTitle
                                          : null,
                                  onSaved: (value) => _title = value!,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ExcludeSemantics(
                                child: Text(
                                  localization(context).bugDescription,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              Semantics(
                                label:
                                    localization(context).bugDescriptionLabel,
                                child: TextFormField(
                                  focusNode: _descriptionFocus,
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    errorMaxLines: 5,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  validator: (value) => value == null ||
                                          value.isEmpty
                                      ? localization(context).enterDescription
                                      : null,
                                  onSaved: (value) => _description = value!,
                                  maxLines: 5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ExcludeSemantics(
                                child: Text(
                                  localization(context).selectOS,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              Semantics(
                                label: localization(context).osLabel,
                                child: DropdownButtonFormField<String>(
                                  focusNode: _operatingSystemFocus,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    semanticLabel:
                                        localization(context).selectOSLabel,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    errorMaxLines: 5,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  initialValue: _operatingSystem,
                                  items: _operatingSystems
                                      .map((value) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? localization(context).selectOS
                                          : null,
                                  onChanged: (value) =>
                                      setState(() => _operatingSystem = value),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Semantics(
                                button: true,
                                label: localization(context).fileUploadLabel,
                                child: InkWell(
                                  onTap: _pickFile,
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minHeight: 48),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Wrap(
                                        spacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          const Icon(Icons.attach_file),
                                          Text(
                                              localization(context).uploadFile),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(_file?.name ??
                                  localization(context).noFileSelected),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(11, 20, 32, 1),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(48, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(localization(context).submit),
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
          ),
          if (_isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: localization(context).loading,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> sendBugReport(
  String title,
  String description,
  String? operatingSystem,
  PlatformFile? file,
) async {
  final path = file?.path;
  if (file != null && (path == null || path.isEmpty)) {
    throw const FormatException('The selected file has no local path.');
  }
  final bugReport = ParseObject('BugReport')
    ..set('title', title)
    ..set('description', description)
    ..set('operatingSystem', operatingSystem);
  if (file != null) {
    bugReport.set('file', ParseFile(File(path!)));
  }
  final response = await bugReport.save();
  if (!response.success) {
    throw BugReportException(response.error?.code);
  }
}

class BugReportException implements Exception, PossibleConnectionFailure {
  const BugReportException(this.code);

  final int? code;

  @override
  bool get mayBeConnectionFailure =>
      code == null ||
      code == ParseError.otherCause ||
      code == ParseError.connectionFailed;

  @override
  String toString() => 'Bug report submission failed (code: $code).';
}
