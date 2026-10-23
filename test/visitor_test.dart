import 'package:flutter_test/flutter_test.dart';
import 'package:security_manager/models/visitor_model.dart';

void main() {
  group('Visitor Models Test', () {
    test('Visitor fromJson & toJson', () {
      final json = {
        "id": 186,
        "name": "Jane Doe",
        "mobile_no": "9876543210",
        "whatsapp_no": "9876543210",
        "visitor_type": "other",
        "purpose_of_visit": "Maintenance work in library",
        "visit_date": "2026-09-01",
        "visit_time": "14:22:27",
        "marked_via": "manual",
        "visit_type_detail": "normal",
        "is_location_verified": true,
        "created_by": "Drake Fuentes",
        "associated_students": []
      };

      final visitor = Visitor.fromJson(json);
      expect(visitor.id, 186);
      expect(visitor.name, "Jane Doe");
      expect(visitor.mobileNo, "9876543210");
      expect(visitor.whatsappNo, "9876543210");
      expect(visitor.visitorType, "other");
      expect(visitor.purposeOfVisit, "Maintenance work in library");
      expect(visitor.isLocationVerified, true);
      expect(visitor.createdBy, "Drake Fuentes");
    });

    test('CreateVisitorRequestModel toJson', () {
      final request = CreateVisitorRequestModel(
        name: "Jane Doe",
        mobileNo: "9876543210",
        whatsappNo: "9876543210",
        visitorType: "other",
        purposeOfVisit: "Maintenance work in library",
        visitType: "normal",
        latitude: 30.7046,
        longitude: 76.7179,
      );

      final json = request.toJson();
      expect(json['name'], 'Jane Doe');
      expect(json['mobile_no'], '9876543210');
      expect(json['whatsapp_no'], '9876543210');
      expect(json['visitor_type'], 'other');
      expect(json['purpose_of_visit'], 'Maintenance work in library');
      expect(json['visit_type'], 'normal');
      expect(json['latitude'], 30.7046);
      expect(json['longitude'], 76.7179);
    });

    test('CreateVisitorResponseModel fromJson', () {
      final responseJson = {
        "success": true,
        "message": "Visitor check-in entry created successfully.",
        "data": {
          "id": 186,
          "name": "Jane Doe",
          "mobile_no": "9876543210",
          "whatsapp_no": "9876543210",
          "visitor_type": "other",
          "purpose_of_visit": "Maintenance work in library",
          "visit_date": "2026-09-01",
          "visit_time": "14:22:27",
          "marked_via": "manual",
          "visit_type_detail": "normal",
          "is_location_verified": true,
          "created_by": "Drake Fuentes",
          "associated_students": []
        }
      };

      final response = CreateVisitorResponseModel.fromJson(responseJson);
      expect(response.success, true);
      expect(response.message, "Visitor check-in entry created successfully.");
      expect(response.data?.name, "Jane Doe");
      expect(response.data?.createdBy, "Drake Fuentes");
    });
  });
}
