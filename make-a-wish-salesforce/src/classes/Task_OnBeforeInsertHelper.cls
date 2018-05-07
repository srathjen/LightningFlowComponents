/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is inserted then Task_OnBeforeInsertHelper is called by Task_OnBeforeInsertHandler calss 
then it will call the corresponding methods in this class.
*******************************************************************************************************************/

Public class Task_OnBeforeInsertHelper{
    Static Constant_AC  constant = new Constant_Ac();
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
    
    /*****************************************************************************************************
     The reparentChildCaseToParentCase() is used to update the Task parent Id from Subcase to parent case.
     *****************************************************************************************************/ 
    public static void reparentChildCaseToParentCase(Map<Id, List<Task>> reparentChildCaseTaskMap){
        Id supUserId = Label.Salesforce_Support_User_Id;
        Map<Id, Case> childParentMap = new Map<Id, Case>();
        String LogValue;
        
            for(Case childCase : [SELECT Id, ParentId, Parent.ContactId,RecordTypeId FROM Case WHERE Id IN : reparentChildCaseTaskMap.keySet() AND ParentId != NULL]) {
                if(childCase.RecordTypeId == wishEffectRecordTypeId || childCase.RecordTypeId == wishDeterminationRecordTypeId || childCase.RecordTypeId == wishPlanningRecordTypeId 
                   || childCase.RecordTypeId == wishGrantRecordTypeId){
                       childParentMap.put(childCase.Id, childCase);
                   }
            }
            if(childParentMap.size() > 0){
                for(Id reparentId : reparentChildCaseTaskMap.keySet()) {
                    if(reparentChildCaseTaskMap.containsKey(reparentId)) {
                        for(Task reParentTask : reparentChildCaseTaskMap.get(reparentId)) {
                            if(childParentMap.containsKey(reParentTask.WhatId)) {
                                reParentTask.WhatId = childParentMap.get(reParentTask.WhatId).ParentId;
                                reParentTask.OwnerId = supUserId;
                                LogValue = 'WhatId:'+reParentTask.WhatId+'OwnerId:'+reParentTask.OwnerId;
                            }
                        }
                    }
                }
            }
      }
      /*********************************************************************
     Used to update Background Check Subject based on day difference.
     ***********************************************************************/
    public static void updateBGCTaskSubjectDays(Map<Id, Task> bgExpiringTaskMap) {
         
         for(Background_check__c bgInfo : [SELECT id, Date__c, Current__c, Volunteer__c, Volunteer__r.Name FROM Background_check__c WHERE Current__c = True AND Date__c = NEXT_N_DAYS:30 AND Id IN : bgExpiringTaskMap.keySet()]) {
                if(bgExpiringTaskMap.containsKey(bgInfo.Id)) {
                    if(bgInfo.Date__c.daysBetween(Date.today()) == -30) {
                        bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (30 Days)';
                    } else if(bgInfo.Date__c.daysBetween(Date.today()) == -23) {
                        bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (23 Days)';
                    } else if(bgInfo.Date__c.daysBetween(Date.today()) == -16) {
                        bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (16 Days)';
                    } else if(bgInfo.Date__c.daysBetween(Date.today()) == -9) {
                        bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (9 Days)';
                    } else if(bgInfo.Date__c.daysBetween(Date.today()) == -2) {
                        bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (2 Days)';
                    }
                    bgExpiringTaskMap.get(bgInfo.Id).ActivityDate = NULL;
                }
            }
        }
     /**********************************************************************
      Used to update COI Subject based on day difference.
      **********************************************************************/
    public static void updateCOITaskSubjectDays(Map<Id, Task> coiExpiringTaskMap) {
        
            for(Conflict_Of_Interest__c coiInfo : [SELECT id, Expiration_Date__c, Current__c, Volunteer_Contact__c, Volunteer_Contact__r.Name FROM Conflict_Of_Interest__c WHERE Current__c = True AND Expiration_Date__c = NEXT_N_DAYS:30 AND Id IN : coiExpiringTaskMap.keySet()]) {
                if(coiExpiringTaskMap.containsKey(coiInfo.Id)) {
                    if(coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -30) {
                        coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (30 Days)';
                    } else if(coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -23) {
                        coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (23 Days)';
                    } else if(coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -16) {
                        coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (16 Days)';
                    } else if(coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -9) {
                        coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (9 Days)';
                    } else if(coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -2) {
                        coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (2 Days)';
                    }
                    coiExpiringTaskMap.get(coiInfo.Id).ActivityDate = NULL;
                    }
            }
     }
    /***************************************************
     Used to update contact to the given task.
    ***************************************************/
    public static void UpdateContactToTask(List<Task> matchContactTaskList, Set<Id> taskParentIdSet) {
        Map<Id, Id> caseContactInfoMap = new Map<Id, Id>();
        Map<Id,Id> plainingParentInfoMap = new Map<Id, Id>();
        
           for(Case parentCaseInfo : [SELECT Id, ContactId, parentId, parent.ContactId, RecordTypeId FROM Case WHERE Id IN : taskParentIdSet]) {
                if(parentCaseInfo.RecordTypeId == parentWishRecordTypeId) {
                    caseContactInfoMap.put(parentCaseInfo.Id, parentCaseInfo.ContactId);
                } else if(parentCaseInfo.RecordTypeId == wishPlanningRecordTypeId) {
                    caseContactInfoMap.put(parentCaseInfo.parentId, parentCaseInfo.parent.ContactId);
                    plainingParentInfoMap.put(parentCaseInfo.Id, parentCaseInfo.parentId);
                }
            }
            for(Task mapContactInfo : matchContactTaskList) {
                if(caseContactInfoMap.containsKey(mapContactInfo.WhatId) && mapContactInfo.Subject != 'Budget needs to be revised' && mapContactInfo.Subject != 'Budget is approved' && mapContactInfo.Subject != 'Case ET : Budget Approval Request') {
                    mapContactInfo.WhoId = caseContactInfoMap.get(mapContactInfo.WhatId);
                } else if(mapContactInfo.Subject == 'Budget needs to be revised' || mapContactInfo.Subject == 'Budget is approved' || mapContactInfo.Subject == 'Case ET : Budget Approval Request') {
                    if(plainingParentInfoMap.containsKey(mapContactInfo.WhatId)) {
                        if(caseContactInfoMap.containsKey(plainingParentInfoMap.get(mapContactInfo.WhatId))) {
                            mapContactInfo.WhoId = caseContactInfoMap.get(plainingParentInfoMap.get(mapContactInfo.WhatId));
                            mapContactInfo.WhatId = plainingParentInfoMap.get(mapContactInfo.WhatId);
                        }
                        
                    }
                }
            }
        } 
    /*******************************************************************************************    
    This method is used to fetch the values from associated contact of task and assign with the 
    corresponding task fields to merge with email template.
    ********************************************************************************************/    
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
    /*******************************************************************************************     
    This method is used to assign the 'Birthday Remainder Task' to primary volunteer.
    ********************************************************************************************/    
    public static void BirthdayTaskPrimaryVolunteerAssign(List<Task> birthdayTasksList, Set<Id> taskRelatedContactIdsSet) {
        Set<Id> caseIdsSet = new Set<Id>();
        Map<Id,Id> caseContactIdsMap = new map<Id,Id>();
        Map<Id,Id> taskRelatedCaseIdsMap = new Map<Id,Id>();
        String LogValue; 
        
            for(Case caseDetails : [SELECT Id, ContactId FROM Case WHERE Id IN : taskRelatedContactIdsSet]) {
                caseIdsSet.add(caseDetails.Id);
                caseContactIdsMap.put(caseDetails.Id, caseDetails.ContactId);
                taskRelatedCaseIdsMap.put(caseDetails.Id, caseDetails.contactId);
            }
            if(caseIdsSet.size()>0) {
                Map<Id,Id> caseTeamMembersMap = new Map<Id,Id>();
                for(CaseTeamMember memberDetails : [SELECT Id, MemberId, ParentId FROM CaseTeamMember WHERE ParentId IN : caseIdsSet AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate ASC]) {
                    if(!caseTeamMembersMap.containsKey(memberDetails.ParentId)) {
                        caseTeamMembersMap.put(memberDetails.ParentId,memberDetails.MemberId);
                    }
                }
                if(caseTeamMembersMap.size()>0) {
                    for(Task assignTaskOwner : birthdayTasksList) {
                        if(caseTeamMembersMap.containsKey(assignTaskOwner.whatId)) {
                            assignTaskOwner.OwnerId= caseTeamMembersMap.get(assignTaskOwner.whatId);
                        }
                        if(taskRelatedCaseIdsMap.containsKey(assignTaskOwner.whatId)) {
                            assignTaskOwner.whoId= taskRelatedCaseIdsMap.get(assignTaskOwner.whatId);
                        }
                        LogValue ='OwnerId:'+assignTaskOwner.OwnerId+'WhoId:'+assignTaskOwner.whoId;
                    }
                }
            }
        }
}