import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:security_manager/api_service/event_service.dart';
import 'package:security_manager/models/active_event_model.dart';
import 'package:security_manager/models/create_event_pass_model.dart';
import 'package:security_manager/models/student_search_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';
import 'package:security_manager/view/screens/crop_image_screen.dart';

class CreateEventPassController extends GetxController {
  final EventService _service = EventService();

  final RxBool isLoadingEvents = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<ActiveEventModel> activeEvents = <ActiveEventModel>[].obs;
  final Rxn<ActiveEventModel> selectedEvent = Rxn<ActiveEventModel>();

  final Rxn<StudentSearchModel> selectedStudent = Rxn<StudentSearchModel>();

  // Attendees list
  final RxList<WalkInAttendeeItem> attendees = <WalkInAttendeeItem>[].obs;

  // Options
  final RxBool autoApprove = true.obs;
  final RxBool autoCheckin = true.obs;

  final TextEditingController gateNameController =
      TextEditingController(text: 'main gate');
  final TextEditingController remarksController =
      TextEditingController(text: 'Walk-in entry issued at gate');

  @override
  void onInit() {
    super.onInit();
    fetchActiveEvents();
    // Default 1 attendee
    addAttendee();
  }

  @override
  void onClose() {
    gateNameController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  void addAttendee() {
    if (attendees.length >= 2) {
      App.showSnackBar(
        title: 'Attendee Limit Reached',
        message: 'Maximum 2 attendees are allowed per pass.',
        isWarning: true,
      );
      return;
    }

    final newIndex = attendees.length;
    final defaultType = newIndex == 0 ? 'father' : 'mother';
    attendees.add(WalkInAttendeeItem(
      personType: defaultType,
      name: '',
      mobileNo: '',
      whatsappNo: '',
      aadhaarNumber: '',
    ));
    if (selectedStudent.value != null) {
      applyPersonTypeData(newIndex, defaultType);
    }
  }

  void removeAttendee(int index) {
    if (attendees.length > 1) {
      attendees.removeAt(index);
    }
  }

  void applyPersonTypeData(int index, String personType) {
    if (index >= attendees.length) return;
    final att = attendees[index];
    att.personType = personType;

    if (selectedStudent.value == null) {
      att.isAutoFilled = false;
      attendees.refresh();
      return;
    }

    final student = selectedStudent.value!;
    final pType = personType.toLowerCase();

    if (pType == 'father' && student.fatherName.isNotEmpty) {
      att.name = student.fatherName;
      att.mobileNo = student.fatherMobile;
      att.whatsappNo = student.whatsappNo.isNotEmpty ? student.whatsappNo : student.fatherMobile;
      att.aadhaarNumber = student.fatherAadhaar ?? '';
      att.existingPhotoPath = student.fatherPhotoPath;
      att.photoUrl = student.fatherPhotoUrl;
      att.isAutoFilled = true;
    } else if (pType == 'mother' && student.motherName.isNotEmpty) {
      att.name = student.motherName;
      att.mobileNo = student.motherMobile.isNotEmpty ? student.motherMobile : student.fatherMobile;
      att.whatsappNo = student.whatsappNo.isNotEmpty ? student.whatsappNo : att.mobileNo;
      att.aadhaarNumber = student.motherAadhaar ?? '';
      att.existingPhotoPath = student.motherPhotoPath;
      att.photoUrl = student.motherPhotoUrl;
      att.isAutoFilled = true;
    } else if (pType == 'student' && student.studentName.isNotEmpty) {
      att.name = student.studentName;
      att.mobileNo = student.fatherMobile.isNotEmpty ? student.fatherMobile : student.whatsappNo;
      att.whatsappNo = student.whatsappNo;
      att.aadhaarNumber = student.studentAadhaar ?? '';
      att.existingPhotoPath = student.studentPhotoPath;
      att.photoUrl = student.studentPhotoUrl;
      att.isAutoFilled = true;
    } else {
      if (att.isAutoFilled) {
        att.name = '';
        att.mobileNo = '';
        att.whatsappNo = '';
        att.aadhaarNumber = '';
        att.existingPhotoPath = null;
        att.photoUrl = null;
      }
      att.isAutoFilled = false;
    }

    attendees.refresh();
  }

  void selectStudent(StudentSearchModel student) {
    selectedStudent.value = student;

    // Apply data for all existing attendees
    for (int i = 0; i < attendees.length; i++) {
      applyPersonTypeData(i, attendees[i].personType);
    }
  }

  Future<void> pickAttendeePhoto(int index, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null || image.path.isEmpty) return;

      final pType = attendees[index].personType;
      final croppedPath = await Get.to<String?>(() => CropImageScreen(
            imagePath: image.path,
            personType: pType,
          ));

      if (croppedPath != null && croppedPath.isNotEmpty) {
        attendees[index].photoFilePath = croppedPath;
      } else {
        attendees[index].photoFilePath = image.path;
      }

      attendees.refresh();
    } catch (e) {
      App.showSnackBar(
        title: 'Image Selection',
        message: 'Could not select image. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> fetchActiveEvents() async {
    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) return;

    isLoadingEvents.value = true;
    try {
      final response = await _service.getActiveEvents(token);
      if (response.success && response.data.isNotEmpty) {
        activeEvents.assignAll(response.data);
        selectedEvent.value = response.data.first;
      }
    } catch (_) {
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<bool> submitIssueWalkInPass() async {
    if (selectedEvent.value == null) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'Please select an event.',
        isError: true,
      );
      return false;
    }

    if (selectedStudent.value == null) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'Please search and select a student.',
        isError: true,
      );
      return false;
    }

    if (attendees.isEmpty) {
      App.showSnackBar(
        title: 'Validation Error',
        message: 'At least 1 attendee is required.',
        isError: true,
      );
      return false;
    }

    for (int i = 0; i < attendees.length; i++) {
      final att = attendees[i];
      if (att.name.trim().isEmpty) {
        App.showSnackBar(
          title: 'Validation Error',
          message: 'Attendee #${i + 1} name is required.',
          isError: true,
        );
        return false;
      }

      final cleanMobile = att.mobileNo.replaceAll(' ', '').trim();
      if (cleanMobile.isEmpty || cleanMobile.length != 10) {
        App.showSnackBar(
          title: 'Validation Error',
          message: 'Attendee #${i + 1} mobile number must be 10 digits.',
          isError: true,
        );
        return false;
      }

      final cleanAadhaar = att.aadhaarNumber.replaceAll(' ', '').trim();
      if (cleanAadhaar.isNotEmpty && cleanAadhaar.length != 12) {
        App.showSnackBar(
          title: 'Validation Error',
          message: 'Attendee #${i + 1} Aadhaar number must be 12 digits.',
          isError: true,
        );
        return false;
      }
    }

    String token = AuthController.authToken;
    if (token.isEmpty) {
      final savedToken = await TokenManager.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        AuthController.authToken = savedToken;
        token = savedToken;
      }
    }

    if (token.isEmpty) {
      App.showSnackBar(
        title: 'Session Expired',
        message: 'Please login again.',
        isError: true,
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      final request = IssueWalkInPassRequestModel(
        eventId: selectedEvent.value!.id,
        studentId: selectedStudent.value!.id,
        autoApprove: autoApprove.value,
        autoCheckin: autoCheckin.value,
        gateName: gateNameController.text.trim(),
        remarks: remarksController.text.trim(),
        attendees: attendees.toList(),
      );

      final response = await _service.issueWalkInPass(
        token: token,
        request: request,
      );

      if (response.success) {
        App.showSnackBar(
          title: 'Pass Issued',
          message: response.message.isNotEmpty
              ? response.message
              : 'Pass (${response.passNumber ?? ''}) successfully issued.',
          isError: false,
        );
        return true;
      } else {
        App.showSnackBar(
          title: 'Pass Status',
          message: response.message.isNotEmpty
              ? response.message
              : 'Pass creation status returned false.',
          isWarning: true,
        );
        return false;
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
