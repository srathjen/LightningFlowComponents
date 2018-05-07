/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated  then Task_OnBeforeUpdateHelper is called by Task_OnBeforeUpdateHandler
then it will call the corresponding methods in this class.
*******************************************************************************************************************/

Public class Task_OnBeforeUpdateHelper{
    
  Static  Constant_AC  constant = new Constant_Ac();
  Static String wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
  Static String  planningTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
  Static String determinationTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
  Static String volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
  Static String chapterRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
  Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
  Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
  Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();     
  Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();    
  Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
  Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
  Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    /******************************************************************************************************
    This method is used to prevent volunteer to close the task when the wish presentation date is not set.
    *******************************************************************************************************/
    public static void colseTaskValidation(List<Task> validationTaskList) {
        Set<Id> conceptTaskParentSet = new Set<Id>(); //Holds parent Id for Concept Task
        Set<Id> wishNotClosedParentIdSet = new Set<Id>(); //Holds parent Id for Wish Not Closed Task
        Set<Id> presentationParentIdSet = new Set<Id>(); //Holds parent Id for Presentation Close Task
        List<Task> conceptTask = new List<Task>(); // Holds Concept Task List 
        List<Task> wishPresentationTaskList = new List<Task>(); // Holds Presentation Date Task List 
        List<Task> wishNotClosedTaskList = new List<Task>(); // Holds Wish Not Closed Task List 
        Map<Id, Case> conceptApprovalMap = new Map<Id, Case>();
        Map<Id, Date> presentationCaseMap = new Map<Id, Date>();
        Set<Id> openCaseIdSet = new Set<Id>();
        
        
        //Used to split task based on subject
        for(Task checkSubject : validationTaskList) {
            if(checkSubject.subject == 'Wish concept approval') {
                conceptTaskParentSet.add(checkSubject.WhatId);
                conceptTask.add(checkSubject);
            } else if(checkSubject.subject == 'Wish Presentation not set') {
                wishPresentationTaskList.add(checkSubject);
                presentationParentIdSet.add(checkSubject.WhatId);
            } else if (checkSubject.subject == 'Wish not closed') {
                wishNotClosedParentIdSet.add(checkSubject.WhatId);
                wishNotClosedTaskList.add(checkSubject);
            }
        }
        
        if(conceptTaskParentSet.size() > 0) {
            for(Case conceptApprovalCheck : [SELECT Id, Status, Sub_Status__c FROM Case WHERE RecordTypeId =: parentWishRecordTypeId AND Id IN : conceptTaskParentSet]) {
                conceptApprovalMap.put(conceptApprovalCheck.Id, conceptApprovalCheck);
            }
            if(conceptApprovalMap.size() > 0) {
                for(Task throwError : conceptTask) {
                    if(conceptApprovalMap.containsKey(throwError.WhatId)) {
                        if(conceptApprovalMap.get(throwError.WhatId).Status != 'Wish Determined' && conceptApprovalMap.get(throwError.WhatId).Sub_Status__c != 'Within Policy') {
                            throwError.addError('Wish Determination is not within the policy');
                        }
                    }
                }
            }
        }
        
        if(presentationParentIdSet.size() > 0) {
            for(Case parentCasePresentationDateCheck : [SELECT Id, Presentation_Date__c, RecordTypeId, ParentId FROM Case WHERE ParentId IN : presentationParentIdSet AND Presentation_Date__c = null AND RecordTypeId =: wishGrantTaskRT]) {
                presentationCaseMap.put(parentCasePresentationDateCheck.ParentId, parentCasePresentationDateCheck.Presentation_Date__c);
            }
            
            if(presentationCaseMap.size() > 0) {
                for(Task presentationValidate : wishPresentationTaskList) {
                    if(presentationCaseMap.containsKey(presentationValidate.WhatId)) {
                        presentationValidate.addError('Please enter presentation date before closing this task');
                    }
                }
            }
        }
        
        if(wishNotClosedParentIdSet.size() > 0 ) {
            for(Case wishStatusCheck : [SELECT Id, Status, RecordTypeId FROM Case WHERE Id IN : wishNotClosedParentIdSet AND (Status != 'Completed' OR Status != 'Closed') AND RecordTypeId =: parentWishRecordTypeId]) {
                openCaseIdSet.add(wishStatusCheck.Id);
            }
            
            if(openCaseIdSet.size() > 0) {
                for(Task preventTaskClose : wishNotClosedTaskList) {
                    if(openCaseIdSet.contains(preventTaskClose.WhatId)) {
                        preventTaskClose.addError('Please close the wish before closing this task');
                    }
                }
            }
        }
     }
    /************************************************************************************************ 
    This method is used to fetch the values from associated contact of task and assign with the 
    corresponding task fields to merge with email template
    *************************************************************************************************/
    public static void updateTaskEmailMergeFields(Set<id> volunteerConatctIdsSet,list<Task> updatedTaskList){
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        
        if(volunteerConatctIdsSet.size() > 0 ){
            for(Contact getContactInfo : [SELECT ID, Name, Account.Name, Account.Phone, Account.Email__c FROM contact where id IN:volunteerConatctIdsSet]) {
                if(!contactInfoMap.containsKey(getContactInfo.Id)) {
                    contactInfoMap.put(getContactInfo.Id, getContactInfo);
                }
            }
            
        }
        for(Task currRec : updatedTaskList){
            if(currRec.WhoId != Null && contactInfoMap.containsKey(currRec.WhoId)){
                currRec.Account_Name__c = contactInfoMap.get(currRec.WhoId).Account.Name;
                currRec.Account_Phone__c = contactInfoMap.get(currRec.WhoId).Account.Phone;
                currRec.Account_Email__c = contactInfoMap.get(currRec.WhoId).Account.Email__c;
                currRec.Contact_Name_Hidden__c = contactInfoMap.get(currRec.WhoId).Name;
            }
        }
    }
  }