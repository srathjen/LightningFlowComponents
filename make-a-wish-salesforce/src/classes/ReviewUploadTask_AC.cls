@RestResource (urlMapping='/uploadTask/*')
global without sharing class ReviewUploadTask_AC {
    
    @HttpGet
    global static List<Task> getUploadInterviewTask()
    {
        String[] uriKeys = RestContext.request.requestURI.split('/');
        String contactId = uriKeys.get(uriKeys.size()-1);
        List<Task> taskList = new List<Task>();
        Id  staffTaskRT = Constant_AC.STAFF_TASK_RT_ID;
        taskList = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId =: contactId AND Subject = 'Review Volunteer Upload' AND RecordTypeId = : staffTaskRT AND CreatedDate = TODAY ]; 
        return taskList;                          
    }

}