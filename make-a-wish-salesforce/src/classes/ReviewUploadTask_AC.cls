/**
 * @description     REST Resource (API Endpoint) to return "Review Volunteer Upload" Tasks.
 *
 * @author          unknown
 * @createdDate     unknown
 */
@RestResource(UrlMapping='/uploadTask/*')
global without sharing class ReviewUploadTask_AC {
    /**
     * @description     GET endpoint to return "Review Volunteer Upload" Tasks.
     *
     * @return          List<Task>
     *
     * @author          unknown
     * @createdDate     unknown
     */
    @HttpGet
    global static List<Task> getUploadInterviewTask() {
        String[] uriKeys = RestContext.request.requestURI.split('/');
        String contactId = uriKeys.get(uriKeys.size() - 1);
        List<Task> taskList = new List<Task>();

        taskList = [
            SELECT Id, WhatId, Subject
            FROM Task
            WHERE WhatId = :contactId
            AND Subject = :Constant_AC.TASK_SUBJECT_REVIEW_VOLUNTEER_UPLOAD
            AND RecordTypeId = :Constant_AC.STAFF_TASK_RT_ID
            AND CreatedDate = TODAY
        ];

        return taskList;
    }
}