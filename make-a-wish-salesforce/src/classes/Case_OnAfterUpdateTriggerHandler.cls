/*
Modification Log
1. 26/03/18 - Vignesh SM - IME 18 - Line No 92, 518-520, 385-392
*/
Public class Case_OnAfterUpdateTriggerHandler{
    
    static Constant_AC  constant = new Constant_Ac();   
    static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    static String volunteerOppWishRecordTypeId = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
    static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    static String chapterecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    static String volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
    static String wishGrantChapterActionRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    static String chapterAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    
    /********************************************************************************************************************** 
This method is used to get the case records new values and old values and those values are added into collections
then it will passed to the coressponding controller method.
*******************************************************************************************************************/
    Public static void onAfterUpdate(Map<Id,Case>newCaseMap,Map<Id,Case> oldCaseMap){
        Set<Id> contactIds = new Set<Id>();
        Map<Id,contact> contactMap = new Map<Id,Contact>();
        Set<Id> newWishClearanceSet = new Set<Id>(); 
        Set<Id> newMedicalWishClearanceSet = new Set<Id>();
        Map<Id, Case> birthdayDateUpdateMap = new Map<Id, Case>();
        Set<Id> bdayWishChildSet = new Set<Id>();
        Map<Id, Case> surveyEmailMap = new Map<Id, Case>();
        Set<Id> impactparentIdSet = new Set<Id>();
        Set<Id> caseParentIdSet = new Set<Id>();
        set<Id> closeTaskParentIdSet = new Set<Id>();
        Map<Id, Case> parentWishInfoMap = new Map<Id, Case>();
        Set<Id> TaskParentIdSet = new Set<Id>();
        Set<Id> caseIdSetForVolOpp = new Set<Id>();
        Map<Id, Case> wishPlanningAndGrantinTaskParentMap = new Map<Id, Case>();
        Map<Id,Case> updateVolunteerManagerCaseTeamMap = new Map<Id, Case>(); 
        Set<Id> volunteerManagerIdSet = new Set<Id>();
        Set<Id> wishCoordinatorIdSet = new Set<Id>();
        Map<Id, Id> caseContactMap = new Map<Id, Id>();
        Map<Id, Id> newCaseOwnerMap  = new Map<Id, Id>();
        Set<Id> volunteerCaseIdSet = new Set<Id>();
        Map<Id,Case> caseIdsMap = new Map<Id, Case>();
        Set<String> newWishTypeSet = new Set<String>();
        Map<Id, String> wishReceiptMap = new Map<Id, String>();
        List<Case> diagnosisVerificationCaseList = new List<Case>();
        Set<string> updatedApprovedLeadInfoSet = new Set<string>();
        Set<string> updatedDnqLeadInfoSet = new Set<string>();
        Map<Id,Case> UpdateAllOpenTasks = new Map<Id,Case>();
        Set<Id> interViewCloseTaskIdsSet = new Set<Id>();
        Map<Id, case> interviewTaskParentIdMap = new Map<Id, Case>();
        Map<Id, Date> dueDateMap = new Map<Id, Date>();
        Set<Id> interViewOpenTaskIdsSet = new Set<Id>();
        Set<Id> insertInterViewOpenTaskIdSet = new Set<Id>();
        Set<Id> caseTeamMemberParentIdSet = new Set<Id>();
        Set<Id> revokingContactIdSet = new Set<Id>();
        Set<Id> presentatationIdentifySet = new Set<Id>();
        Set<Id> presentationIdsSet = new Set<Id>();
        Set<Id> presentationCloseTaskIdsSet = new Set<Id>();
        Map<Id, case> presentationCloseTaskParentIdMap = new Map<Id, Case>();
        Set<Id> presentationOpenTaskIdsSet = new Set<Id>();
        Set<Id> endDateIdSet = new Set<Id>();
        Map<Id,Case> wishchildIdMap = new Map<Id,Case>();
        Set<Id> newMedicalSummarySet = new Set<Id>();
        Map<Id, Case> wishClearanceMap = new Map<Id, Case>();
        Set<Id> conceptApprovalParentIdSet = new Set<Id>();
        Set<Id> approvedBudgetIdsSet = new Set<Id>();
        Map<Id,String> approvedBudgetStatus = new Map<Id,String>();
        Set<Id> wishIdsSet = new Set<Id>();
        Set<Id> wishIds = new Set<Id>();
        Map<Id,Case> updateWishChildInfo = new Map<Id,Case>();
        List<Case> PartAWishList = new List<Case>();
        Map<Id, Case> removeAniticipationTaskMap = new Map<Id,Case>();
        Map<Id, Case> updateAniticipationTaskMap = new Map<Id,Case>();
        Set<String> wishTypes = new Set<String>();
        Set<Id> inprogressUnCheckCaseIdsSet = new Set<Id>();
        Map<Id,Case> readyToAssignParentCaseMap = new Map<Id,Case>(); 
        Set<Id> readtToAssignChapterIdSet = new Set<Id>();
        List<case> wishGrantedIdList = new List<case>();
        Set<Id> parentWishIdSet = new Set<Id>();
        Set<Id> closedCaseIdSet = new Set<Id>();
        Set<Id> completedCaseIdSet=new Set<Id>();
        List<Case> exceptionList = new List<Case>();
        Set<Id> wishGrantedSet = new Set<Id>();
        Set<Id> closedWishSet = new Set<Id>();
        List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
        Map<Id, Case> forTrackingMap = new Map<Id, Case>();
        Map<Id,Case> parentWishClearanceMap = new Map<Id,Case>();
        Map<Id, String> caseToLeadSubStatusUpdate  = new Map<Id, String>(); //IME 18
        
        for(Case caseMemberCheck : newCaseMap.values()) {
            if(caseMemberCheck.RecordTypeId == diagnosisVerificationRT ||caseMemberCheck.RecordTypeId == wishEffectRecordTypeId || caseMemberCheck.RecordTypeId == wishDeterminationRecordTypeId || caseMemberCheck.RecordTypeId == wishPlanningRecordTypeId
               || caseMemberCheck.RecordTypeId == wishAssistRecordTypeId || caseMemberCheck.RecordTypeId == parentWishRecordTypeId || caseMemberCheck.RecordTypeId == wishGrantRecordTypeId){
                   if(caseMemberCheck.Birthdate__c != oldCaseMap.get(caseMemberCheck.Id).Birthdate__c && caseMemberCheck.RecordTypeId == parentWishRecordTypeId ) {
                       birthdayDateUpdateMap.put(caseMemberCheck.Id, caseMemberCheck);
                       bdayWishChildSet.add(caseMemberCheck.ContactId);
                   }
                   
                   // Below four lines are related to STT-11 for poplating Survey email to parent case when Wish Impact subcase has value for Survey Email field.
                   if((caseMemberCheck.Survey_Email__c != oldCaseMap.get(caseMemberCheck.Id).Survey_Email__c || caseMemberCheck.Survey_Sent__c != oldCaseMap.get(caseMemberCheck.Id).Survey_Sent__c) && caseMemberCheck.RecordTypeId == wishEffectRecordTypeId && caseMemberCheck.ParentId != NULL) {
                       surveyEmailMap.put(caseMemberCheck.Id, caseMemberCheck);
                       impactparentIdSet.add(caseMemberCheck.ParentId);
                   }
                   
                   //Used to update parent case tracking note fields when the field is updated in Planning case
                   if(caseMemberCheck.Form_Tracking_Notes__c != oldCaseMap.get(caseMemberCheck.Id).Form_Tracking_Notes__c && caseMemberCheck.RecordTypeId == wishPlanningRecordTypeId && caseMemberCheck.ParentId != NULL) {
                       forTrackingMap.put(caseMemberCheck.ParentId, caseMemberCheck);
                   }                   
                   
                   // Used to Open all sub cases when the status from "DNQ","Completed" and "Closed".
                   if((caseMemberCheck.Status == 'Ready to Interview' || caseMemberCheck.Status == 'Wish Determined' || caseMemberCheck.Status == 'Wish Design' || caseMemberCheck.Status == 'Wish Scheduled' || caseMemberCheck.Status == 'Granted' || caseMemberCheck.Status == 'Qualified' || caseMemberCheck.Status == 'Ready to Assign') && 
                      (oldCaseMap.get(caseMemberCheck.Id).Status == 'DNQ' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed') && 
                      (caseMemberCheck.RecordTypeId == parentWishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true)){
                          caseParentIdSet.add(caseMemberCheck.id);
                      }
                   
                   if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Wish_Assist__c == True && oldCaseMap.get(caseMemberCheck.Id).Wish_Assist__c != True)
                       closeTaskParentIdSet.add(caseMemberCheck.Id);
                   
                   //Used to create wish determination type tasks when the status is updated to "Ready to Interview"
                   if((caseMemberCheck.Wish_Assist__c == False && ((oldCaseMap.get(caseMemberCheck.Id).Status == 'Ready to Assign' && caseMemberCheck.Status == 'Ready to Interview') || 
                                                                   (oldCaseMap.get(caseMemberCheck.Id).Status == 'DNQ' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed')) && 
                       (RecursiveTriggerHandler.blockCaseLockRecursive == true && caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && caseMemberCheck.Status == 'Ready to Interview'))) {
                           parentWishInfoMap.put(caseMemberCheck.Id, caseMemberCheck);
                       }
                   
                   //Used to close all the System genareated  task when the status is updated to "DNQ", "Closed", "Completed"'
                   if((caseMemberCheck.Status == 'DNQ' || caseMemberCheck.Status == 'Closed' || 
                       caseMemberCheck.Status == 'Completed') && (caseMemberCheck.RecordTypeId == parentWishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true) && (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status)) {
                           TaskParentIdSet.add(caseMemberCheck.Id);
                       } 
                   
                   if((caseMemberCheck.Status == 'DNQ' || caseMemberCheck.Status == 'Closed') && caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status) {
                       caseIdSetForVolOpp.add(caseMemberCheck.Id);
                   }
                   
                   if((caseMemberCheck.Status == 'Granted' || caseMemberCheck.Status == 'Closed') && caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && caseMemberCheck.RecordTypeId == parentWishRecordTypeId){
                       wishGrantedSet.add(caseMemberCheck.Id);
                   } 
                   
                   //Used to create wish planning and granting task
                   if(caseMemberCheck.Wish_Assist__c == False && (((caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status || caseMemberCheck.Sub_Status__c != oldCaseMap.get(caseMemberCheck.Id).Sub_Status__c) && (caseMemberCheck.RecordTypeId == parentWishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true))
                                                                  && ((oldCaseMap.get(caseMemberCheck.Id).Status == 'DNQ' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed') || (caseMemberCheck.Sub_Status__c == 'Within Policy' && caseMemberCheck.Status == 'Wish Determined'))) && 
                      (caseMemberCheck.Sub_Status__c == 'Within Policy' && caseMemberCheck.Status == 'Wish Determined')) {
                          wishPlanningAndGrantinTaskParentMap.put(caseMemberCheck.Id, caseMemberCheck);
                      }
                   
                   
                   if(caseMemberCheck.Status == 'Ready to Assign' && caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && RecursiveTriggerHandler.blockCaseLockRecursive == true && caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                       volunteerManagerIdSet.add(caseMemberCheck.Id);
                   } else if((caseMemberCheck.Status == 'Ready to Assign' || caseMemberCheck.Status == 'Ready to Interview') && caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId && RecursiveTriggerHandler.blockCaseLockRecursive == true && caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                       volunteerManagerIdSet.add(caseMemberCheck.Id);
                   }
                   
                   if(caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && caseMemberCheck.Status == 'Wish Determined' && RecursiveTriggerHandler.blockCaseLockRecursive == true && caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                       wishCoordinatorIdSet.add(caseMemberCheck.Id);
                   } else if((caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId && RecursiveTriggerHandler.blockCaseLockRecursive == true) && (caseMemberCheck.Status == 'Wish Determined' || caseMemberCheck.Status == 'Wish Design' || caseMemberCheck.Status == 'Wish Scheduled' || caseMemberCheck.Status == 'Budget Approval - Approved' || caseMemberCheck.Status == 'Budget Approval - Submitted') && caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                       wishCoordinatorIdSet.add(caseMemberCheck.Id);
                   }
                   
                   if((caseMemberCheck.Status != 'Closed' && caseMemberCheck.Status != 'Completed' && RecursiveTriggerHandler.blockCaseLockRecursive == true) && (oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed') && caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       caseContactMap.put(caseMemberCheck.Id, caseMemberCheck.ContactId);
                   }
                   if(caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId && caseMemberCheck.RecordTypeId == parentWishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true) {
                       newCaseOwnerMap.put(caseMemberCheck.Id, caseMemberCheck.OwnerId);
                   }
                   
                   if((caseMemberCheck.status == 'Wish Determined' || caseMemberCheck.status == 'Budget Approval - Submitted' || caseMemberCheck.status == 'Budget Approval - Approved' || caseMemberCheck.status == 'Wish Design' || caseMemberCheck.status == 'Wish Scheduled'  || caseMemberCheck.status == 'Granted') &&  
                      caseMemberCheck.RecordTypeid == parentWishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true && oldCaseMap.get(caseMemberCheck.id).status != 'Wish Determined' && oldCaseMap.get(caseMemberCheck.id).status != 'Budget Approval - Submitted' && 
                      oldCaseMap.get(caseMemberCheck.id).status != 'Budget Approval - Approved' && oldCaseMap.get(caseMemberCheck.id).status != 'Wish Design' && oldCaseMap.get(caseMemberCheck.id).status != 'Wish Scheduled' && oldCaseMap.get(caseMemberCheck.id).status != 'Granted'){
                          volunteerCaseIdSet.add(caseMemberCheck.Id);
                      }
                   
                   if(oldCaseMap.get(caseMemberCheck.Id).Wish_Type__c != caseMemberCheck.Wish_Type__c  && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                       caseIdsMap.put(caseMemberCheck.Id, caseMemberCheck);
                       newWishTypeSet.add(caseMemberCheck.Wish_Type__c);
                   }
                   
                   if(caseMemberCheck.RecordTypeId == wishGrantRecordTypeId && caseMemberCheck.Wish_Receipt_Items__c != Null && 
                      caseMemberCheck.Wish_Receipt_Items__c != oldCaseMap.get(caseMemberCheck.id).Wish_Receipt_Items__c){
                          wishReceiptMap.put(caseMemberCheck.ParentId,caseMemberCheck.Wish_Receipt_Items__c);
                      }
                   
                   /* Removing as per IME 4
                    if(caseMemberCheck.Status == 'Escalated' && caseMemberCheck.RecordTypeId == diagnosisVerificationRT && caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && caseMemberCheck.MAC_Email__c != Null) {
                    diagnosisVerificationCaseList.add(caseMemberCheck);
                    }*/
                   
                   //(caseMemberCheck.Status == 'Approved - Chapter Staff' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Approved - Chapter Staff') ||
                   //(caseMemberCheck.Status == 'Approved - Chapter Medical Advisor' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Approved - Chapter Medical Advisor') ||  - Removing as per IME 4
                   
                   //Modified as per IME 4
                   if((caseMemberCheck.Status == 'Approved - National Medical Review' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Approved - National Medical Review')||(caseMemberCheck.Status == 'Approved - National MAC Review' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Approved - National MAC Review') && 
                      CaseMemberCheck.RecordTypeid == diagnosisVerificationRT)
                   {
                       updatedApprovedLeadInfoSet.add(caseMemberCheck.Lead__c);
                   }//caseMemberCheck.Status == 'DNQ - Chapter Staff' || caseMemberCheck.Status == 'DNQ - Chapter Medical Advisor' || - Removing as per IME 4
                   else if((caseMemberCheck.Status == 'DNQ - National Medical Review'|| caseMemberCheck.Status == 'DNQ - National MAC Review')&& CaseMemberCheck.RecordTypeid == diagnosisVerificationRT && oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status){
                       updatedDnqLeadInfoSet.add(caseMemberCheck.Lead__c);
                   }
                
                   if(caseMemberCheck.Sub_Status__c == 'Abandoned' && oldCaseMap.get(caseMemberCheck.id).Sub_Status__c!= 'Abandoned' 
                      && caseMemberCheck.RecordTypeId == parentWishRecordTypeId && CaseMemberCheck.isClosed == True)
                   {
                       UpdateAllOpenTasks.put(caseMemberCheck.id,CaseMemberCheck);
                   }
                   
                   //1.Used to update "Wish Determination" task due date when "Interview Date" field is updated
                   //2.Used to Close & Open "Enter Interview" task based on interview date entered and cleard 
                   if(CaseMemberCheck.Interview_date__c != null && oldCaseMap.get(CaseMemberCheck.id).Interview_date__c == null && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                       interViewCloseTaskIdsSet.add(caseMemberCheck.Id);
                       interviewTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
                       dueDateMap.put(CaseMemberCheck.Id,CaseMemberCheck.Interview_date__c);
                   } else if(CaseMemberCheck.Interview_date__c == null && oldCaseMap.get(CaseMemberCheck.id).Interview_date__c != null && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                       dueDateMap.put(CaseMemberCheck.Id,CaseMemberCheck.Interview_date__c);
                       interViewOpenTaskIdsSet.add(caseMemberCheck.Id);
                       interviewTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
                       if(CaseMemberCheck.Wish_Assist__c == False)
                           insertInterViewOpenTaskIdSet.add(caseMemberCheck.Id);
                   } else if(CaseMemberCheck.Interview_date__c != null && oldCaseMap.get(CaseMemberCheck.id).Interview_date__c != null && oldCaseMap.get(CaseMemberCheck.id).Interview_date__c != CaseMemberCheck.Interview_date__c &&  CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                       dueDateMap.put(CaseMemberCheck.Id,CaseMemberCheck.Interview_date__c);
                   }
                   
                   //Used to remove the access for Volunteer user to Wish, when the parent wish is completed.
                   ////Used to update child cases if Parent Case Status is changed to 'Completed' or 'Closed'
                   if((CaseMemberCheck.Status == 'Completed' || CaseMemberCheck.Status == 'Closed' || CaseMemberCheck.Status == 'DNQ')  && (oldCaseMap.get(CaseMemberCheck.Id).Status != CaseMemberCheck.Status && CaseMemberCheck.RecordTypeId == parentWishRecordTypeId ) )
                   {
                       caseTeamMemberParentIdSet.add(CaseMemberCheck.Id);
                       revokingContactIdSet.add(CaseMemberCheck.ContactId);
                   }
                   
                   // Wish Granted task
                   if(CaseMemberCheck.Presentation_Date__c != null && oldCaseMap.get(CaseMemberCheck.id).Presentation_Date__c != CaseMemberCheck.Presentation_Date__c && CaseMemberCheck.RecordTypeId == wishGrantRecordTypeId)
                   {
                       presentatationIdentifySet.add(CaseMemberCheck.parentId);
                       presentationIdsSet.add(caseMemberCheck.ParentId);
                       presentationCloseTaskIdsSet.add(caseMemberCheck.ParentId);
                       presentationCloseTaskParentIdMap.put(caseMemberCheck.ParentId,caseMemberCheck);
                   } 
                   if(CaseMemberCheck.Presentation_Date__c == null && oldCaseMap.get(CaseMemberCheck.id).Presentation_Date__c != CaseMemberCheck.Presentation_Date__c && CaseMemberCheck.RecordTypeId == wishGrantRecordTypeId) {
                       presentatationIdentifySet.add(CaseMemberCheck.parentId);
                       presentationIdsSet.add(caseMemberCheck.ParentId);
                       if(caseMemberCheck.Wish_Assist__c == False)
                           presentationOpenTaskIdsSet.add(caseMemberCheck.ParentId);
                       presentationCloseTaskParentIdMap.put(caseMemberCheck.ParentId,caseMemberCheck);
                   }
                   
                   // Wish Granted task
                   if(CaseMemberCheck.End_Date__c != null && oldCaseMap.get(CaseMemberCheck.id).End_Date__c != CaseMemberCheck.End_Date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId)
                   {
                       endDateIdSet.add(caseMemberCheck.Id);
                       presentationCloseTaskIdsSet.add(caseMemberCheck.Id);
                       presentationCloseTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
                       
                   }
                   
                   //Update the Relationship object when the start date and end date is updated in parent case.
                   if(((oldCaseMap.get(CaseMemberCheck.id).End_Date__c != CaseMemberCheck.End_Date__c) || (CaseMemberCheck.Start_Date__c != oldCaseMap.get(CaseMemberCheck.Id).Start_Date__c)) &&  caseMemberCheck.ContactId != Null && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId)
                   {
                       wishchildIdMap.put(caseMemberCheck.ContactId,caseMemberCheck);
                   } 
                   //New medical summary needed
                   if((CaseMemberCheck.Start_Date__c != oldCaseMap.get(CaseMemberCheck.Id).Start_Date__c) && (CaseMemberCheck.Wish_Type__c == 'Cruise-Celebrity/Royal' || CaseMemberCheck.Wish_Type__c == 'Cruise-Disney' || CaseMemberCheck.Wish_Type__c == 'Cruise-Other'
                                                                                                              || CaseMemberCheck.Wish_Type__c == 'Travel-International' || CaseMemberCheck.Wish_Type__c == 'Travel-Hawai' || CaseMemberCheck.Wish_Type__c == 'Trailer/Camper'
                                                                                                              || CaseMemberCheck.Wish_Type__c == 'Travel-Other')&& CaseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                                                                                                                  if((CaseMemberCheck.Start_Date__c == null) || ((CaseMemberCheck.Start_Date__c != null) && (CaseMemberCheck.Child_s_Medical_Summary_received_date__c == null 
                                                                                                                                                                                                             || CaseMemberCheck.Child_s_Medical_Summary_received_date__c.daysBetween(CaseMemberCheck.Start_Date__c) > 30))) {
                                                                                                                                                                                                                 newMedicalSummarySet.add(CaseMemberCheck.Id);
                                                                                                                                                                                                                 wishClearanceMap.put(CaseMemberCheck.Id, CaseMemberCheck);
                                                                                                                                                                                                             }
                                                                                                              }
                   
                   //New wish clearance needed
                   if(CaseMemberCheck.End_Date__c != null && CaseMemberCheck.End_Date__c != oldCaseMap.get(CaseMemberCheck.Id).End_Date__c && CaseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       if((CaseMemberCheck.Wish_Clearance_Received_Date__c == null) || (Date.today().monthsBetween(CaseMemberCheck.Wish_Clearance_Received_Date__c) > 6)) {
                           newWishClearanceSet.add(CaseMemberCheck.Id);
                           wishClearanceMap.put(CaseMemberCheck.Id, CaseMemberCheck);
                       }
                       
                       if(CaseMemberCheck.Wish_Type__c == 'Celebrity-Domestic Travel' || CaseMemberCheck.Wish_Type__c == 'Celebrity-Local' || CaseMemberCheck.Wish_Type__c == 'Celebrity-International Travel'
                          || CaseMemberCheck.Wish_Type__c == 'Travel-International' || CaseMemberCheck.Wish_Type__c == 'Travel-Hawai' || CaseMemberCheck.Wish_Type__c == 'Trailer/Camper'
                          || CaseMemberCheck.Wish_Type__c == 'Travel-Other' && CaseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                              if((CaseMemberCheck.Child_s_Medical_Summary_received_date__c == null) || ((Date.today().monthsBetween(CaseMemberCheck.Child_s_Medical_Summary_received_date__c) > 6))) {
                                  newMedicalWishClearanceSet.add(CaseMemberCheck.Id);
                                  wishClearanceMap.put(CaseMemberCheck.Id, CaseMemberCheck);
                              }
                              
                          }
                   }
                   
                   if(CaseMemberCheck.End_Date__c == null && oldCaseMap.get(CaseMemberCheck.id).End_Date__c != CaseMemberCheck.End_Date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                       endDateIdSet.add(caseMemberCheck.Id);
                       if(CaseMemberCheck.Wish_Assist__c == False)
                           presentationOpenTaskIdsSet.add(caseMemberCheck.Id);
                       presentationCloseTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
                   }
                   
                   //For closing concept approval task when wish status set to Wish Determined within policy
                   if((CaseMemberCheck.Status == 'Wish Determined' && CaseMemberCheck.Sub_Status__c == 'Within Policy') && (CaseMemberCheck.Status != oldCaseMap.get(CaseMemberCheck.Id).Status || CaseMemberCheck.Sub_Status__c != oldCaseMap.get(CaseMemberCheck.Id).Sub_Status__c) && CaseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                       conceptApprovalParentIdSet.add(CaseMemberCheck.Id);
                   }
                   
                   if(caseMemberCheck.Budget_Approval_Status__c == 'Approved'  && caseMemberCheck.Budget_Approval_Status__c != oldCaseMap.get(caseMemberCheck.Id).Budget_Approval_Status__c && caseMemberCheck.RecordTypeId == wishPlanningRecordTypeId) {
                       approvedBudgetIdsSet.add(caseMemberCheck.ParentId);
                       approvedBudgetStatus.put(caseMemberCheck.ParentId, caseMemberCheck.Budget_Approval_Status__c);
                       system.debug('----Budgetapproved Status'+ caseMemberCheck.ParentId);
                   }
                   
                   if(CaseMemberCheck.Status == 'Granted' &&  (oldCaseMap.get(CaseMemberCheck.id).Status != 'Granted' && oldCaseMap.get(CaseMemberCheck.id).Status != 'Completed' && oldCaseMap.get(CaseMemberCheck.id).Status != 'DNQ' && oldCaseMap.get(CaseMemberCheck.id).Status != 'Closed' ) && parentWishRecordTypeId == CaseMemberCheck.RecordTypeid)
                   {
                       wishIds.add(CaseMemberCheck.id);
                   }
                   
                   if(caseMemberCheck.Update_Wish_Child_Form_Info__c == True && oldCaseMap.get(caseMemberCheck.id).Update_Wish_Child_Form_Info__c != True && parentWishRecordTypeId == CaseMemberCheck.RecordTypeid)
                   {
                       updateWishChildInfo.put(caseMemberCheck.id,caseMemberCheck);
                   } 
                   
                   if(caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && caseMemberCheck.RecordTypeId == diagnosisVerificationRT && caseMemberCheck.Lead__c != Null){
                       if(caseMemberCheck.Status == 'Open' || caseMemberCheck.Status == 'Escalated')
                           PartAWishList.add(caseMemberCheck);
                   }
                   
                   if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Anticipated_Start_Date__c== Null &&
                      oldCaseMap.get(caseMemberCheck.id).Anticipated_Start_Date__c != Null)
                   {
                       removeAniticipationTaskMap.put(caseMemberCheck.id,caseMemberCheck);
                   } 
                   else if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Anticipated_Start_Date__c!= Null
                           && caseMemberCheck.Anticipated_Start_Date__c!= oldCaseMap.get(caseMemberCheck.id).Anticipated_Start_Date__c)
                   {
                       updateAniticipationTaskMap.put(caseMemberCheck.id,caseMemberCheck);
                       wishTypes.add(caseMemberCheck.wish_type__c);
                   }
                   
                   if((caseMemberCheck.Status == 'DNQ' || caseMemberCheck.Status == 'Closed' || caseMemberCheck.Status == 'Completed' || caseMemberCheck.Status == 'Inactive' || caseMemberCheck.Status == 'Hold' || caseMemberCheck.Status =='Qualified' ||
                       caseMemberCheck.Status == 'Ready to Assign' || caseMemberCheck.Status == 'Ready to Interview')
                      && (caseMemberCheck.RecordTypeId == parentWishRecordTypeId  && oldCaseMap.get(caseMemberCheck.Id).Status != 'DNQ' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Closed' && 
                          oldCaseMap.get(caseMemberCheck.Id).Status != 'Completed' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Inactive' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Hold' &&
                          oldCaseMap.get(caseMemberCheck.Id).Status != 'Ready to Assign' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Ready to Interview' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Qualified')) {
                              inprogressUnCheckCaseIdsSet.add(caseMemberCheck.id);
                          }
                   
                   //For creating 2 volunteer opportunity record when the case status changed to "Ready to Assign" from "Qualified".
                   if((caseMemberCheck.Status == 'Ready to Assign') && oldCaseMap.get(caseMemberCheck.id).Status ==  'Qualified' && caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Wish_Assist__c == false){
                       if(RecursiveTriggerHandler.isFirstTime == true ) {
                           readyToAssignParentCaseMap.put(caseMemberCheck.Id,caseMemberCheck);
                           readtToAssignChapterIdSet.add(caseMemberCheck.ChapterName__c);
                       } 
                   }
                   
                   //if Status is 'Granted' then populate the hiddengranteddate in Contact
                   if(caseMemberCheck.Status == 'Granted' && oldCaseMap.get(caseMemberCheck.id).Status != 'Granted' && caseMemberCheck.ContactId != null && caseMemberCheck.RecordTypeId == parentWishRecordTypeId){
                       wishGrantedIdList.add(caseMemberCheck);
                   }
                   
                   //When the case is Updated as Granted,Completed,DNQ,Closed,Hold,Inactive statuses delete any volunteer opportunities that do not have a volunteer assigned
                   if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId && (caseMemberCheck.Status == 'Granted' || caseMemberCheck.Status == 'Completed' || caseMemberCheck.Status == 'DNQ' || 
                                                                                 caseMemberCheck.Status == 'Closed' || caseMemberCheck.Status == 'Hold'|| caseMemberCheck.Status == 'Inactive') && oldCaseMap.get(caseMemberCheck.id).Status != caseMemberCheck.Status  
                      && RecursiveTriggerHandler.blockCaseLockRecursive == true){
                          parentWishIdSet.add(caseMemberCheck.Id);
                      }
                   
                   if(caseMemberCheck.Status == 'Completed' && oldCaseMap.get(caseMemberCheck.id).Status != 'Completed' && caseMemberCheck.RecordTypeId == parentWishRecordTypeId){
                       completedCaseIdSet.add(caseMemberCheck.id);
                   }
                   if(oldCaseMap.get(caseMemberCheck.id).Status != 'Closed' && caseMemberCheck.Status == 'Closed' && caseMemberCheck.RecordTypeId == parentWishRecordTypeId){
                       closedCaseIdSet.add(caseMemberCheck.Id);
                   }
                   //This lines are related to WVC-1804 update the wish Clearance Form field in the Planning case.
                   if(caseMemberCheck.Wish_Clearance_Needed__c != oldCaseMap.get(caseMemberCheck.Id).Wish_Clearance_Needed__c && caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Wish_Clearance_Needed__c != Null){
                       parentWishClearanceMap.put(caseMemberCheck.Id,caseMemberCheck);
                   }
                   
                   exceptionList.add(caseMemberCheck);
               }
            /*Adding as per IME 18*/
            if(caseMemberCheck.RecordTypeId == diagnosisVerificationRT && 
               ((caseMemberCheck.Status =='New' && oldCaseMap.get(caseMemberCheck.Id).Status != 'New') ||
                (caseMemberCheck.Status =='Pending Clarification - MAC' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Pending Clarification - MAC') || 
                (caseMemberCheck.Status =='Pending Clarification - Chapter' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Pending Clarification - Chapter'))) {
                   caseToLeadSubStatusUpdate.put(caseMemberCheck.Lead__c, caseMemberCheck.Status);
            }
        } 
        
        if(wishGrantedSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.populateEndDate(wishGrantedSet);
        }
        
        if(surveyEmailMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.updateSurveyField(surveyEmailMap, impactparentIdSet);
        }
        if(closeTaskParentIdSet.Size() > 0 ){
            Case_OnAfterUpdateTriggerHandlerHelper.deleteWishAssitTask(closeTaskParentIdSet,exceptionList);
        }
        
        if(birthdayDateUpdateMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.updateContactBirthDate(birthdayDateUpdateMap,bdayWishChildSet);
        }
        if(wishReceiptMap.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.UpdateWishRecipetItems(wishReceiptMap,exceptionList);
        }
        if(TaskParentIdSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.closeAllOpenTask(TaskParentIdSet,exceptionList);
        }
        if(parentWishIdSet.Size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.deleteUnassignedVolunteerOpp(parentWishIdSet,exceptionList);
        }
        if(caseIdSetForVolOpp.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.closeVolOpp(caseIdSetForVolOpp,exceptionList);
        }
        if(updatedApprovedLeadInfoSet.size()>0 || updatedDnqLeadInfoSet.size()>0 ){
            Case_OnAfterUpdateTriggerHandlerHelper.updateLeadStatus(updatedApprovedLeadInfoSet,updatedDnqLeadInfoSet,exceptionList);
        }
        if(volunteerCaseIdSet.Size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpp(volunteerCaseIdSet,true,exceptionList);
        }
        if(inprogressUnCheckCaseIdsSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpp(inprogressUnCheckCaseIdsSet,false,exceptionList);
        }
        if(wishGrantedIdList.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.updateGrantedDate(wishGrantedIdList);
        }
        if(caseParentIdSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.UpdateSubCaseStatus(caseParentIdSet,exceptionList);
        }
        if(updateVolunteerManagerCaseTeamMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.CreateAndUpdateUserCaseTeamRole(updateVolunteerManagerCaseTeamMap, volunteerManagerIdSet, wishCoordinatorIdSet);
        }
        if(caseContactMap.size() > 0 ) {
            Case_OnAfterUpdateTriggerHandlerHelper.chageAccessPermission(caseContactMap,exceptionList);
        }
        if(wishPlanningAndGrantinTaskParentMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.wishPlaningAnticipationTaskCreation(wishPlanningAndGrantinTaskParentMap);
            Case_OnAfterUpdateTriggerHandlerHelper.wishGrantedSubCaseTaskCreation(wishPlanningAndGrantinTaskParentMap);
        }
        if(newCaseOwnerMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.changeChildCasesOwner(newCaseOwnerMap,exceptionList);
        }
        if(wishClearanceMap.size() > 0 && (newWishClearanceSet.Size() > 0 || newMedicalSummarySet.Size() > 0 || newMedicalWishClearanceSet.Size() > 0)) {
            Case_OnAfterUpdateTriggerHandlerHelper.wishClearanceTask(wishClearanceMap,newWishClearanceSet,newMedicalSummarySet,newMedicalWishClearanceSet);
        }
        if(parentWishInfoMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.wishDeterminationSubCaseTaskCreation(parentWishInfoMap);
        }
        if(caseIdsMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.deleteAnticipationTask(caseIdsMap,newWishTypeSet);
        }
        if(updateAniticipationTaskMap.size() > 0 || removeAniticipationTaskMap.size() >0)
        {
            Case_OnAfterUpdateTriggerHandlerHelper.updateAnticipationTasks(updateAniticipationTaskMap,removeAniticipationTaskMap,wishTypes);
        }
        if(UpdateAllOpenTasks.size() > 0)
        {
            Case_OnAfterUpdateTriggerHandlerHelper.UpdateTasksAsAbondoned(UpdateAllOpenTasks);
        }
        /*if(diagnosisVerificationCaseList.size() > 0 && RecursiveTriggerHandler.nationalEmailRecurrence == FALSE) {
            Case_OnAfterUpdateTriggerHandlerHelper.sendEmailToNationalMACTeam(diagnosisVerificationCaseList);
        }*/
        if(caseTeamMemberParentIdSet.size() > 0 && revokingContactIdSet.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.revokeWishPermissionForVolunteers(caseTeamMemberParentIdSet,revokingContactIdSet,exceptionList);
        }
        if(approvedBudgetIdsSet.size() > 0 && approvedBudgetStatus.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.matchBudgetData(approvedBudgetIdsSet,approvedBudgetStatus,exceptionList);
        }
        if(PartAWishList.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.UpdateLeadStatus(PartAWishList);
        }
        if(wishIds.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.grantedWishCount(wishIds);
        }
        if(updateWishChildInfo.size() > 0){
            WishChildFormValUpdate_AC.UpdateWishChildandWishFamily(updateWishChildInfo);
        }
        if(dueDateMap.size() > 0 ) {
            Case_OnAfterUpdateTriggerHandlerHelper.updateDeterminationTaskDueDates(dueDateMap,exceptionList);
        }
        if((interViewCloseTaskIdsSet.size() > 0 || insertInterViewOpenTaskIdSet.size() > 0) && interviewTaskParentIdMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.inTerviewTask(interViewCloseTaskIdsSet, insertInterViewOpenTaskIdSet, interviewTaskParentIdMap);
        }
        if(interViewCloseTaskIdsSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.updateWishDeterminationInterviewDateNotSet(interViewCloseTaskIdsSet,exceptionList);
        }
        if(interViewOpenTaskIdsSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.updateWishDeterminationInterviewDateNotSet(interViewOpenTaskIdsSet,exceptionList);
        }
        if((presentationCloseTaskIdsSet.size() > 0 || presentationOpenTaskIdsSet.size() > 0) && presentationCloseTaskParentIdMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.wishGrantedPresentationTask(presentationCloseTaskIdsSet, presentationOpenTaskIdsSet,presentationCloseTaskParentIdMap,presentationIdsSet,endDateIdSet,presentatationIdentifySet,exceptionList);
        }
        if(conceptApprovalParentIdSet.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.autoCloseTask(conceptApprovalParentIdSet,exceptionList);
        }
        if(completedCaseIdSet.size() > 0 && completedCaseIdSet != Null){
            Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityStatus(completedCaseIdSet,exceptionList);
        }
        if(readyToAssignParentCaseMap.size()>0 && readtToAssignChapterIdSet.size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.createVolunteerOpportunity(readyToAssignParentCaseMap, readtToAssignChapterIdSet);
        }
        if(closedCaseIdSet.Size() > 0){ 
            Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityasInactive(closedCaseIdSet,exceptionList);
        }
        if(forTrackingMap.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.updateCaseFormTracking(forTrackingMap);
        }
        //WVC-1804
        if(parentWishClearanceMap.Size() > 0){
            Case_OnAfterUpdateTriggerHandlerHelper.updatewishClearanceForm(parentWishClearanceMap);
        }
        //IME 18
        if(caseToLeadSubStatusUpdate.size() > 0){            
            Case_OnAfterUpdateTriggerHandlerHelper.updateCasetoLeadSubStatus('Eligibility Review', caseToLeadSubStatusUpdate);
        }        
    }
}