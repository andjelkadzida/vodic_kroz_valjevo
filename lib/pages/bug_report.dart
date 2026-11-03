import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../helper/bug_report_device_info.dart';
import '../helper/connection_problem_view.dart';
import '../helper/internet_connectivity.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/custom_app_bar.dart';

typedef BugReportSender = Future<void> Function(
  String title,
  String description,
  String? operatingSystem,
  PlatformFile? file, {
  required String? deviceModel,
  required String? operatingSystemVersion,
});

typedef BugReportFilePicker = Future<FilePickerResult?> Function();

Future<FilePickerResult?> _pickBugReportFile() =>
    FilePicker.platform.pickFiles();

class BugReportPage extends StatefulWidget {
  const BugReportPage({
    Key? key,
    this.sender = sendBugReport,
    this.deviceInfoLoader = loadBugReportDeviceInfo,
    this.filePicker = _pickBugReportFile,
  }) : super(key: key);

  final BugReportSender sender;
  final BugReportDeviceInfoLoader deviceInfoLoader;
  final BugReportFilePicker filePicker;

  @override
  State<BugReportPage> createState() => BugReportPageState();
}

class BugReportPageState extends State<BugReportPage> {
  static const _accentColor = Color(0xFF0B1420);
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _operatingSystemController = TextEditingController();
  final _deviceModelController = TextEditingController();
  final _operatingSystemVersionController = TextEditingController();
  final _deviceInfoTimeoutOrCancel = Completer<BugReportDeviceInfo?>();
  late final Future<void> _deviceInfoFuture;
  late final String? _operatingSystem;
  Timer? _deviceInfoTimer;
  String _title = '';
  String _description = '';
  PlatformFile? _file;
  bool _isLoading = false;
  bool _isDeviceInfoLoading = true;
  bool _deviceInfoUnavailable = false;

  @override
  void initState() {
    super.initState();
    _operatingSystem = detectBugReportOperatingSystem();
    _operatingSystemController.text = _operatingSystem ?? '';
    _deviceInfoTimer = Timer(const Duration(seconds: 5), () {
      if (!_deviceInfoTimeoutOrCancel.isCompleted) {
        _deviceInfoTimeoutOrCancel.completeError(
          TimeoutException('Device information detection timed out.'),
        );
      }
    });
    _deviceInfoFuture = _loadDeviceInfo();
  }

  @override
  void dispose() {
    _deviceInfoTimer?.cancel();
    if (!_deviceInfoTimeoutOrCancel.isCompleted) {
      _deviceInfoTimeoutOrCancel.complete(null);
    }
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _operatingSystemController.dispose();
    _deviceModelController.dispose();
    _operatingSystemVersionController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final info = await Future.any<BugReportDeviceInfo?>([
        widget.deviceInfoLoader(),
        _deviceInfoTimeoutOrCancel.future,
      ]);
      if (!mounted || info == null) return;
      final deviceModel = info.deviceModel.trim();
      final operatingSystemVersion = info.operatingSystemVersion.trim();
      final incomplete = deviceModel.isEmpty || operatingSystemVersion.isEmpty;
      if (incomplete) debugPrint('Device information was incomplete.');
      setState(() {
        _deviceModelController.text = deviceModel;
        _operatingSystemVersionController.text = operatingSystemVersion;
        _isDeviceInfoLoading = false;
        _deviceInfoUnavailable = incomplete;
      });
    } on PlatformException catch (error) {
      _handleDeviceInfoFailure(error);
    } on MissingPluginException catch (error) {
      _handleDeviceInfoFailure(error);
    } on UnsupportedError catch (error) {
      _handleDeviceInfoFailure(error);
    } on TimeoutException catch (error) {
      _handleDeviceInfoFailure(error);
    } on FormatException catch (error) {
      _handleDeviceInfoFailure(error);
    } finally {
      _deviceInfoTimer?.cancel();
    }
  }

  void _handleDeviceInfoFailure(Object error) {
    debugPrint('Device information unavailable: ${error.runtimeType}');
    if (!mounted) return;
    setState(() {
      _isDeviceInfoLoading = false;
      _deviceInfoUnavailable = true;
    });
  }

  static Widget _buildValidationError(BuildContext context, String error) =>
      Text(error);

  Future<void> _submit() async {
    if (_isLoading) return;
    final form = _formKey.currentState;
    if (form == null) return;
    if (_isDeviceInfoLoading &&
        _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await _deviceInfoFuture;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      if (!mounted) return;
    }
    if (!form.validate()) {
      if (_titleController.text.isEmpty) {
        _titleFocus.requestFocus();
      } else if (_descriptionController.text.isEmpty) {
        _descriptionFocus.requestFocus();
      }
      return;
    }
    form.save();
    final deviceModel = _deviceModelController.text.trim();
    final operatingSystemVersion =
        _operatingSystemVersionController.text.trim();
    setState(() => _isLoading = true);
    try {
      final hasConnection = await checkInitialInternetConnection();
      if (!mounted) return;
      if (!hasConnection) {
        unawaited(showConnectionProblemDialog(context, disconnected: true));
        return;
      }

      await widget.sender(
        _title,
        _description,
        _operatingSystem,
        _file,
        deviceModel: deviceModel.isEmpty ? null : deviceModel,
        operatingSystemVersion:
            operatingSystemVersion.isEmpty ? null : operatingSystemVersion,
      );
      if (!mounted) return;
      form.reset();
      _operatingSystemController.text = _operatingSystem ?? '';
      _deviceModelController.text = deviceModel;
      _operatingSystemVersionController.text = operatingSystemVersion;
      _titleFocus.unfocus();
      _descriptionFocus.unfocus();
      setState(() {
        _file = null;
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
      final result = await widget.filePicker();
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

  InputDecoration _inputDecoration({String? hintText, bool readOnly = false}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF637084)),
    );
    return InputDecoration(
      filled: true,
      fillColor: readOnly ? const Color(0xFFF2F4F7) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: _accentColor, width: 2),
      ),
      hintText: hintText,
      hintStyle: Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(color: const Color(0xFF344054)),
    );
  }

  Widget _labeledField({
    required String label,
    required String semanticsLabel,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(label: semanticsLabel, child: child),
      ],
    );
  }

  Widget _readOnlyField(String label, TextEditingController controller) {
    final unavailable = !_isDeviceInfoLoading && controller.text.isEmpty;
    return _labeledField(
      label: label,
      semanticsLabel: label,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        maxLines: null,
        decoration: _inputDecoration(
          readOnly: true,
          hintText:
              unavailable ? localization(context).deviceInfoNotAvailable : null,
        ),
      ),
    );
  }

  Widget _reportSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD4DCE4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: Icon(icon, color: _accentColor)),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    final messages = localization(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.bug_report_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  messages.bugReportIntro,
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _reportSection(
          icon: Icons.edit_note_outlined,
          title: messages.bugReportDetails,
          children: [
            _labeledField(
              label: messages.bugTitle,
              semanticsLabel: messages.bugTitleLabel,
              child: TextFormField(
                focusNode: _titleFocus,
                controller: _titleController,
                decoration: _inputDecoration(),
                errorBuilder: _buildValidationError,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.isEmpty ? messages.enterTitle : null,
                onSaved: (value) => _title = value!,
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              label: messages.bugDescription,
              semanticsLabel: messages.bugDescriptionLabel,
              child: TextFormField(
                focusNode: _descriptionFocus,
                controller: _descriptionController,
                decoration: _inputDecoration(),
                errorBuilder: _buildValidationError,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.isEmpty
                    ? messages.enterDescription
                    : null,
                onSaved: (value) => _description = value!,
                maxLines: 5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _reportSection(
          icon: Icons.devices_outlined,
          title: messages.bugReportDeviceDetails,
          children: [
            Text(messages.bugReportDeviceNote, style: textTheme.bodyMedium),
            if (_isDeviceInfoLoading) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(messages.loading),
              ),
            ] else if (_deviceInfoUnavailable || _operatingSystem == null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  messages.deviceInfoUnavailable,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _readOnlyField(
                messages.operatingSystem, _operatingSystemController),
            const SizedBox(height: 16),
            _readOnlyField(messages.deviceModel, _deviceModelController),
            const SizedBox(height: 16),
            _readOnlyField(
                messages.osVersion, _operatingSystemVersionController),
          ],
        ),
        const SizedBox(height: 16),
        _reportSection(
          icon: Icons.attach_file,
          title: messages.bugReportAttachment,
          children: [
            OutlinedButton(
              onPressed: _pickFile,
              style: OutlinedButton.styleFrom(
                foregroundColor: _accentColor,
                minimumSize: const Size(48, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: Semantics(
                label: messages.fileUploadLabel,
                child: ExcludeSemantics(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      const Icon(Icons.upload_file),
                      Text(messages.uploadFile, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                _file?.name ?? messages.noFileSelected,
                style: textTheme.bodyMedium,
              ),
            ),
            if (_file != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _file = null),
                style: TextButton.styleFrom(
                  foregroundColor: _accentColor,
                  minimumSize: const Size(48, 48),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    const Icon(Icons.close),
                    Text(messages.removeAttachment,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Icon(Icons.send_outlined),
              Text(messages.submit, textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).bugReport,
        _accentColor,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        unselectedColor: _accentColor,
      ),
      backgroundColor: const Color(0xFFF4F6F8),
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
                          child: _buildReportForm(),
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
  PlatformFile? file, {
  required String? deviceModel,
  required String? operatingSystemVersion,
}) async {
  final path = file?.path;
  if (file != null && (path == null || path.isEmpty)) {
    throw const FormatException('The selected file has no local path.');
  }
  final model = deviceModel?.trim();
  final version = operatingSystemVersion?.trim();
  final system = operatingSystem?.trim();
  if ((system != null && system.isEmpty) ||
      (model != null && model.isEmpty) ||
      (version != null && version.isEmpty)) {
    throw ArgumentError('Device details cannot be blank when provided.');
  }
  final bugReport = ParseObject('BugReport')
    ..set('title', title)
    ..set('description', description);
  if (system != null) bugReport.set('operatingSystem', system);
  if (model != null) bugReport.set('deviceModel', model);
  if (version != null) bugReport.set('operatingSystemVersion', version);
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
