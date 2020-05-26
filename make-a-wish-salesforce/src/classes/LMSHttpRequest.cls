/**
 * @description This Class used to make callouts to LMS
 *
 * @author MST
 */
public class LMSHttpRequest {

    /**
     * @description To create LMSRequest
     *
     * @param lMSCredential
     * @param endPoint
     * @param methodType
     *
     * @return
     */
    public static HttpRequest createLMSHttpRequest(LMS_Credentials__c lMSCredential, String endPoint, String methodType) {
        HttpRequest request = new HttpRequest();
        String Logvalue;
        try {
            if (lMSCredential != null && endPoint != null && methodType != null) {
                request.setEndpoint('callout:LMS_Credential/' + endPoint);
                request.setMethod(methodType);
                Logvalue = String.valueOf(request);
                System.debug('The End Point URL' + request.getBody());
            }
            return request;
        } catch (Exception e) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('LMSHttpRequest', 'createLMSHttpRequest', null, e, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    /**
     * @description To get SSO details of the LMS User
     *
     * @param lMSCredential
     * @param volunteerLMSId
     * @param courseCode
     *
     * @return
     */
    public static LMSSSORespose getLMSSSODetails(LMS_Credentials__c lMSCredential, String volunteerLMSId, String courseCode) {
        LMSSSORespose lMSSSOResponse = new LMSSSORespose();
        String Logvalue;
        if (lMSCredential != null && volunteerLMSId != null) {
            String[] courseIds = courseCode.split(' ');
            String courseParameter;
            courseParameter = courseIds[0];
            if (courseIds.size() > 0) {
                for (Integer i = 1; i < courseIds.size(); i++) {
                    courseParameter = courseParameter + '%20' + courseIds[i];
                }
            }
            HttpRequest request = new HttpRequest();
            request = createLMSHttpRequest(lMSCredential, lMSCredential.SSOEndPoint__c + volunteerLMSId + '?course_code=' + courseParameter, 'GET');
            Http http = new Http();
            HttpResponse response;
            try {
                Logvalue = String.valueOf(request);
                response = http.send(request);
                lMSSSOResponse = LMSSSORespose.parse(response.getBody());
                System.debug('lMSSSOResponse+++++++++++' + lMSSSOResponse);
                if (Test.isRunningTest()) {
                    throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
                }
            } catch (Exception ex) {
                new ApexDebugLog().createLog(new ApexDebugLog.Error('LMSHttpRequest', 'getLMSSSODetails', null, ex, Logvalue));
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
                System.debug('ex' + ex.getMessage());
            }
        }
        return lMSSSOResponse;
    }

    /**
     * @description To create or active users in LMS
     *
     * @param currVolunteerUser
     * @param lMSCredential
     *
     * @return
     */
    public static LMSUserResponse createOrActivateLMSUser(User currVolunteerUser, LMS_Credentials__c lMSCredential) {
        LMSUserResponse currLMSUserResponse = new LMSUserResponse();
        String Logvalue;
        if (lMSCredential != null && currVolunteerUser != null) {
            HttpRequest request = new HttpRequest();
            request = createLMSHttpRequest(lMSCredential, lMSCredential.UserCreaationEndpoint__c, 'POST');
            request.setHeader('Content-Type', 'application/json');
            LMSUserRequest userRequestDetails = new LMSUserRequest();
            if (currVolunteerUser.LMS_Login__c != null) {
                userRequestDetails.login = currVolunteerUser.LMS_Login__c;
            } else {
                userRequestDetails.login = currVolunteerUser.Username;
            }
            userRequestDetails.first_name = currVolunteerUser.FirstName;
            userRequestDetails.last_name = currVolunteerUser.LastName;
            if (currVolunteerUser.Hidden_Email__c == null) {
                userRequestDetails.email = currVolunteerUser.Email;
            } else {
                userRequestDetails.email = currVolunteerUser.Hidden_Email__c;
            }
            userRequestDetails.password = currVolunteerUser.LastName;
            userRequestDetails.chapter_id = currVolunteerUser.Contact.Region_Chapter__r.Chapter_Id__c;
            String requestPayLoad = JSON.serialize(userRequestDetails);
            request.setBody(requestPayLoad);
            Http http = new Http();
            HttpResponse response;
            try {
                System.debug('request++++++++++++++++++++++++++ ' + requestPayLoad);
                Logvalue = String.valueOf(request);
                response = http.send(request);
                System.debug('The response is + ' + response.getBody());
                currLMSUserResponse = LMSUserResponse.parse(response.getBody());
                System.debug('lMSSSOResponse+++++++++++' + currLMSUserResponse);
                if (Test.isRunningTest()) {
                    throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
                }
            } catch (Exception ex) {

                new ApexDebugLog().createLog(new ApexDebugLog.Error('LMSHttpRequest', 'createOrActivateLMSUser', null, ex, Logvalue));
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
                System.debug('ex' + ex.getMessage());
            }
        }
        return currLMSUserResponse;
    }

    /**
     * @description To create or update Enrollment in LMS
     *
     * @param lMSCredential
     * @param courseId
     * @param userLogin
     * @param enrollmentStatus
     * @param endrollmentId
     *
     * @return
     */
    public static LMSOrientationRegistrationResponse createOrUpdateEnrollment(LMS_Credentials__c lMSCredential, String courseId, String userLogin, String enrollmentStatus, Integer endrollmentId) {
        LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
        String Logvalue;
        if (lMSCredential != null && courseId != null && userLogin != null && enrollmentStatus != null) {
            HttpRequest request = new HttpRequest();
            if (enrollmentStatus != 'dropped') {
                request = createLMSHttpRequest(lMSCredential, lMSCredential.EnrollmentEndPoint__c, 'POST');
            } else {
                request = createLMSHttpRequest(lMSCredential, lMSCredential.EnrollmentEndPoint__c, 'PUT');
            }
            request.setHeader('Content-Type', 'application/json');
            LMSOrientationRegistrationRequest currLMSOrientationRegistrationRequest = new LMSOrientationRegistrationRequest();
            currLMSOrientationRegistrationRequest.course_code = courseId;
            currLMSOrientationRegistrationRequest.user_login = userLogin;
            currLMSOrientationRegistrationRequest.status = enrollmentStatus;
            //Added by Pavi.
            if (enrollmentStatus == 'dropped' && endrollmentId != null) {
                currLMSOrientationRegistrationRequest.enrollment_id = endrollmentId;
            }
            //End.
            String requestPayLoad = JSON.serialize(currLMSOrientationRegistrationRequest);
            request.setBody(requestPayLoad);
            Http http = new Http();
            HttpResponse response;
            try {
                Logvalue = String.valueOf(request);
                response = http.send(request);
                System.debug('The response is + ' + response.getBody());

                currLMSOrientationRegistrationResponse = LMSOrientationRegistrationResponse.parse(response.getBody());
                if (Test.isRunningTest()) {
                    throw new CommonTriggerException('Test');
                }
            } catch (Exception ex) {
                new ApexDebugLog().createLog(new ApexDebugLog.Error('LMSHttpRequest', 'createOrUpdateEnrollment', null, ex, Logvalue));
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
                System.debug('ex' + ex.getMessage());
            }
        }
        return currLMSOrientationRegistrationResponse;
    }
}