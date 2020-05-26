/**
 * @description This class is the test class for LMSOrientationRegistrationRequest
 *
 * @author MST
 */
@IsTest
public class LMSOrientationRegistrationRequest_Test {
    // To parse the JSON to LMSOrientationRegistrationRequest
    @IsTest
    static void jsonTOLMSOrientationRegistrationRequest() {
        String json = '{' +
                '                "user_login": "user@test.com",' +
                '                "course_code": "wish101",' +
                '                "status": "dropped"' +
                ' }' +
                '';
        LMSOrientationRegistrationRequest lMSOrientationRegistrationRequestobj = new LMSOrientationRegistrationRequest();
        Test.startTest();
        lMSOrientationRegistrationRequestobj = LMSOrientationRegistrationRequest.parse(json);
        System.assert(lMSOrientationRegistrationRequestobj != null);
        System.assertEquals(lMSOrientationRegistrationRequestobj.course_code, 'wish101');
        System.assertEquals(lMSOrientationRegistrationRequestobj.user_login, 'user@test.com');
        System.assertEquals(lMSOrientationRegistrationRequestobj.status, 'dropped');
        Test.stopTest();
    }
}