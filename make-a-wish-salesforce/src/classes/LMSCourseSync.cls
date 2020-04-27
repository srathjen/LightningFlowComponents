//Created by : MST 
//Description : This Webservice will be called by the buttom 'Get LMS Details' in the Class offering object for 'Virtual - Self Placed' record type. This class will make a call out the 
//LMS system with the given course id to validate the  given course is avaible in the LMS.
global class LMSCourseSync {

    private static final String HTML_ENCODED_SPACE = '%20';

    /**
     * @description This method has two parameters one is course id another one is courseoffering id
     *
     * @param courseID
     * @param courseOfferingId
     *
     * @return
     */
    webService static String getLMSCourseInfo(String courseID, String courseOfferingId) {
        Class_Offering__c currCourseOffering;
        LMSCourse course;
        LMS_Credentials__c lMSCredential = LMS_Credentials__c.getValues('LMS Integration');
        if (courseID.length() == 0) {
            return Label.LMS_Error_Missing_Course_Id;
        }
        if (lMSCredential != null) {
            String[] courseIds = courseID.split(' ');
            String courseParameter;
            courseParameter = courseIds[0];
            if (!courseIds.isEmpty()) {
                for (Integer i = 1; i < courseIds.size(); i++) {
                    courseParameter = courseParameter + HTML_ENCODED_SPACE + courseIds[i];
                }
            }
            HttpRequest request = new HttpRequest();
            request = LMSHttpRequest.createLMSHttpRequest(lMSCredential, lMSCredential.CourseEndpoint__c + courseParameter, 'GET');
            Http http = new Http();
            HttpResponse response;
            try {
                response = http.send(request);
                System.debug('the response is ++ ' + response);
            } catch (Exception ex) {
                System.debug('ex' + ex.getMessage());
                return Label.LMS_Error_Exception;
            }
            if (response.getStatusCode() == 200) {
                course = LMSCourse.parse(response.getBody());
                if (course != null) {
                    currCourseOffering = [
                            SELECT Id, Course_Name__c, Description__c
                            FROM Class_Offering__c
                            WHERE Id = :courseOfferingId
                    ];

                    if (currCourseOffering.Course_Name__c != course.name || currCourseOffering.Description__c != course.summary) {
                        currCourseOffering.Course_Name__c = course.name;
                        currCourseOffering.Description__c = course.summary;
                        try {
                            update currCourseOffering;
                        } catch (Exception ex) {
                            System.debug('ex' + ex.getMessage());
                            return Label.LMS_Error_Exception;
                        }
                    }
                }
            } else {
                return Label.LMS_Error_Invalid_Course_Id;
            }
            return Label.LMS_Success_Valid_Course_Id;
        } else {
            return Label.LMS_Error_Exception;
        }
    }
}