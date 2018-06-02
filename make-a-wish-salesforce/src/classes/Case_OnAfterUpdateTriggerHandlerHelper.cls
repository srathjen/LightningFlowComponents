/*
Modification Log
1. 26/03/18 - Vignesh SM - IME 18 - Line No 242, 1845-1858, 247
*/
Public class Case_OnAfterUpdateTriggerHandlerHelper{
    
    Static Constant_AC  constant = new Constant_Ac();   
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    Static String volunteerOppWishRecordTypeId = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String chapterecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    Static String volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();  
    Static String wishGrantTaskRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String determinationChapterActionRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
    Set<Id> contactIds = new Set<Id>();
    Map<Id,contact> contactMap = new Map<Id,Contact>();
    Set<Id> newWishClearanceSet = new Set<Id>(); 
    Set<Id> newMedicalWishClearanceSet = new Set<Id>();
    
    /*******************************************************************************************
Related to STT-11 for populating survey email field on parent wish from the Wish Impact sub case.    
********************************************************************************************/
    public static void updateSurveyField(Map<Id, Case> surveyEmailMap, Set<Id> impactparentIdSet) {
        RecursiveTriggerHandler.allowToEditRecord = TRUE;
        String LogValue;
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        //try{
        for(Case parentCase : [SELECT  Id,Wish_Impact_Survey_Email__c,Survey_Sent__c FROM Case WHERE Id IN : impactparentIdSet Limit 50000]) {
            parentCaseMap.put(parentCase.Id, parentCase);
        }
        
        for(Case wishImpactCase : surveyEmailMap.Values()) {
            if(parentCaseMap.containsKey(wishImpactCase.ParentId)) {
                parentCaseMap.get(wishImpactCase.ParentId).Wish_Impact_Survey_Email__c = wishImpactCase.Survey_Email__c;
                parentCaseMap.get(wishImpactCase.ParentId).Survey_Sent__c = wishImpactCase.Survey_Sent__c;
                LogValue  = String.valueOf(wishImpactCase);
                LogValue =+ 'parentCaseNumber:'+parentCaseMap.get(wishImpactCase.ParentId).caseNumber+'wishImapcatSurveyEmail:'+parentCaseMap.get(wishImpactCase.ParentId).Wish_Impact_Survey_Email__c +'SurveySent:'+parentCaseMap.get(wishImpactCase.ParentId).Survey_Sent__c;
                
            }
        }
        if(parentCaseMap.size() > 0) {
            update parentCaseMap.values();
        }
        //}
        /*catch(Exception e){              
            for(Case currRec : surveyEmailMap.values()){
                system.debug('@@ Exception @@'+e);
                currRec.addError(e.getmessage());
            }
        }*/
    }
    
    
    /********************************************************************************************
Used to update parent case when form field updated in planning case     
***********************************************************************************************/
    public static void updateCaseFormTracking(Map<Id, Case> planningSurveyMap) {
        
        List<Case> parentCaseList = new List<Case>();
        //try {
        for(Case parentCase : [SELECT Id, Form_Tracking_Notes__c FROM Case WHERE Id IN : planningSurveyMap.KeySet() AND RecordTypeId =: parentWishRecordTypeId Limit 50000]) {
            Case updateParent = new Case();
            updateParent.Id = parentCase.Id;
            updateParent.Form_Tracking_Notes__c = planningSurveyMap.get(parentCase.Id).Form_Tracking_Notes__c;
            parentCaseList.add(updateParent);
        }
        
        if(parentCaseList.size() > 0) {
            update parentCaseList;
        } 
        /* } catch(Exception e){              
for(Case currRec : planningSurveyMap.values()){
system.debug('@@ Exception @@'+e);
currRec.addError(e.getmessage());
}
}*/
        
    }
    
    /********************************************************************************************
Delete all the system generated task when the wish assist is updated to true in parent case.     
***********************************************************************************************/
    public static void deleteWishAssitTask(Set<Id> parentIdSet,List<Case> newcaseList){
        String LogValue;
        List<Task> deleteTaskList = new List<Task>();
        //try{
        deleteTaskList = [SELECT Id,SystemGeneratedTask__c FROM Task WHERE whatId IN : parentIdSet AND  SystemGeneratedTask__c = True AND what.RecordTypeId =: parentWishRecordTypeId Limit 50000];
        if(deleteTaskList.size() > 0)
            DELETE deleteTaskList;
        /* }
catch(Exception e){
for(Case currCase : newcaseList){
system.debug('@@ Exception @@'+e);
currCase.addError(e.getMessage());
}
}*/
    }
    
    /**********************************************************************************************************
Used to update the related contact when the birthday field is changed in the case. 
**********************************************************************************************************/   
    public static void updateContactBirthDate(Map<Id, Case> birthdayDateUpdateMap, Set<Id> bdayWishChildSet) {
        Map<Id, Contact> wishChildMap = new Map<Id, Contact>();
        String LogValue;
        
        //try{
        for(Contact wishChildCon : [SELECT Id,BirthDate FROM Contact WHERE Id IN : bdayWishChildSet Limit 50000]) {            
            wishChildMap.put(wishChildCon.Id, wishChildCon);
        }
        
        for(Case parentWish : birthdayDateUpdateMap.values()) {
            
            if(wishChildMap.containsKey(parentWish.ContactId)) {
                wishChildMap.get(parentWish.ContactId).BirthDate = parentWish.Birthdate__c;
                LogValue = 'Current Case:-'+String.Valueof(parentWish);
                LogValue =+'Parent Case Birthdate:'+String.valueof(parentWish.Birthdate__c);
            }
        }
        
        if(wishChildMap.size() > 0) {
            update wishChildMap.values();
        }
        /* }
catch(Exception e){

for(Case currCase : birthdayDateUpdateMap.values()){
system.debug('@@ Exception @@'+e);
currCase.addError(e.getMessage());
}
}*/
    }
    
    /***********************************************************************************************************************   
Delete the unassigned volunteer opportunity when the case status is updated as any one of the following status.
Closed,Granted,Completed,DNQ,Hold,Inactive.
************************************************************************************************************************/    
    public static void deleteUnassignedVolunteerOpp(Set<Id> parentWishIdSet,List<Case> newcaseList){
        RecursiveTriggerHandler.blockCaseLockRecursive = False;
        List<Volunteer_Opportunity__c> deleteVolOppList = new List<Volunteer_Opportunity__c>();
        String LogValue;
        //try{
        deleteVolOppList= [SELECT Id,Volunteer_Name__c,Wish__c FROM Volunteer_Opportunity__c WHERE Wish__c IN : parentwishIdSet AND Volunteer_Name__c =: Null AND RecordTypeId =: volunteerOppWishRecordTypeId Limit 50000];
        if(deleteVolOppList.Size() > 0)
            Delete deleteVolOppList;
        /*}
        catch(Exception e){
            for(Case currCase : newcaseList){
                system.debug('@@ Exception @@'+e);
                currCase.addError(e.getMessage());
            }
        }*/
    }
    
    /***********************************************************************************************************************     
Close All System genareated open Task and Sub cases When the status is updtaed to "DNQ","Completed","Close"'.
************************************************************************************************************************/    
    Public static void closeAllOpenTask(Set<Id> parentWishIdSet,List<Case> newcaseList){
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        RecursiveTriggerHandler.allowToEditRecord = true;
        String LogValue;
        If(parentWishIdSet.size() > 0 ){
            List<Task> updateTaskList = new List<Task>();
            List<Case> caseList = new List<Case>();
            //try{
            for(Case dbCase : [SELECT Id,ParentId,Status,Parent.RecordTypeId FROM Case WHERE ParentId IN:parentWishIdSet AND Parent.RecordTypeId =: parentWishRecordTypeId Limit 50000]){
                If(parentWishIdSet.contains(dbCase.ParentId)){
                    dbCase.Hidden_Close_Sub_Case__c = true;
                    dbCase.status = 'Closed';
                    caseList.add(dbCase);
                }
            }
            for(Task dbOpenTask : [SELECT Id,WhatId,SystemGeneratedTask__c FROM Task WHERE WhatId IN: parentWishIdSet AND SystemGeneratedTask__c =: TRUE Limit 50000]){
                dbOpenTask.Status = 'Completed';
                updateTaskList.add(dbOpenTask);
            }
            
            if(updateTaskList.size() > 0)
                update updateTaskList;
            
            if(caseList.size() > 0) {
                update caseList;
            }
            RecursiveTriggerHandler.allowToEditRecord = false;     
            /*}
catch(Exception e){
for(case currCase : newcaseList){
system.debug('@@ Exception @@'+e);
currCase .addError(e.getMessage());
}
}*/
        }
    }
    
    /******************************************************************************
Update volunteer opportunity to closed status when related case is closed.
******************************************************************************/
    
    public static void closeVolOpp(Set<Id> caseIdSetForVolOpp,List<Case> newCaseList){
        
        List<Volunteer_Opportunity__c> closeVollOppList = new List<Volunteer_Opportunity__c>();
        Set<Id> recallApprovalSet = new Set<Id>();
        String LogValue;
        
        //try{
        for(Volunteer_Opportunity__c closeVolOpp : [SELECT Id, Wish__c,Status__c FROM Volunteer_Opportunity__c WHERE Wish__c IN : caseIdSetForVolOpp AND Wish__c != NULL AND Wish__r.RecordTypeId =: parentWishRecordTypeId Limit 50000]) {
            if(closeVolOpp.Status__c != 'Closed') {
                closeVolOpp.Status__c = 'Closed';
                closeVollOppList.add(closeVolOpp);
            }
            System.debug('>>>>>VolOppIt');
            recallApprovalSet.add(closeVolOpp.Id);
            LogValue = closeVolOpp.Status__c; 
        }
        if(recallApprovalSet.size() > 0) {
            recallVolOppApproval(recallApprovalSet);
        }
        if(closeVollOppList.size() > 0) {
            update closeVollOppList;
        }
        /*} catch(Exception e){
for(case currCase: newCaseList){
system.debug('@@ Exception @@'+e);
currCase.addError(e.getMessage());
}
}*/
    }
    
    /******************************************************************************
Update Lead status when diagnosis verification case status is updated.
******************************************************************************/ 
    public static void updateLeadStatus(set<string> updatedApprovedLeadInfoSet, set<string> updatedDnqLeadInfoSet,List<Case> newCaseList){
        list<Lead> UpadtedLeadListInfo = new list<Lead>();
        String LogValue;
        String message;
        Boolean showError;
        //try{
        //Removed Childs_Qualifying_Diagnosis__c in query as per IME-120
            for(Lead currentLead: [SELECT ID,Status,isConverted, FirstName, Qualifying_ICD__c, Qualifying_Diagnosis__c, I_am_Recognized_To_Practice_As_a__c,Part_A_Received__c,Any_medical_reason_for_moving_quickly__c,DOB__c FROM Lead Where (ID IN:updatedApprovedLeadInfoSet OR ID IN:updatedDnqLeadInfoSet) and isConverted =: False Limit 50000]){
                if(updatedApprovedLeadInfoSet.contains(currentLead.Id)){
                    if(currentLead.I_am_Recognized_To_Practice_As_a__c != Null && currentLead.Part_A_Received__c != Null && currentLead.Any_medical_reason_for_moving_quickly__c != Null && currentLead.DOB__c != Null){
                        currentLead.Status  = 'Qualified';
                        currentLead.Sub_Status__c = ''; //Added as per IME 18
                        LogValue = 'Status:'+currentLead.Status;
                        showError = false;
                    } else {
                        showError = true;
                        if(currentLead.FirstName == null){ 
                            if(message == '' || message == Null)
                                message = 'First Name';
                        } 
                        if(currentLead.DOB__c == null){
                            if(message == '' || message == Null)
                                message = 'DOB';
                            else
                                message = message+', '+'DOB';
                        }
                        //Removed Childs_Qualifying_Diagnosis__c as per IME-120
                        /*if(currentLead.Childs_Qualifying_Diagnosis__c == null){
                            if(message == '' || message == Null)
                                message = 'Child\'s Qualifying Diagnosis';
                            else
                                message= message+', '+'Child\'s Qualifying Diagnosis';
                        }*/
                        if(currentLead.Any_medical_reason_for_moving_quickly__c == null){
                            if(message == '' || message == Null)
                                message = 'Potential Rush';
                            else
                                message= message+', '+'Potential Rush'; 
                        }
                        if(currentLead.Part_A_Received__c == null){
                            if(message == '' || message == Null)
                                message = 'Diagnosis Verification Received';
                            else
                                message= message+', '+'Diagnosis Verification Received'; 
                        }
                        if(currentLead.I_am_Recognized_To_Practice_As_a__c == null){
                            if(message == '' || message == Null)
                                message = 'I Am Recognized To Practice As A';
                            else
                                message= message+', '+'I Am Recognized To Practice As A';
                        }
                    }                   
                }
                else if(updatedDnqLeadInfoSet.contains(currentLead.Id)){
                    currentLead.Status  = 'DNQ';
                    currentLead.Sub_Status__c = 'Medical';// Added 'Sub_Status__c' as per IME-18
                    currentLead.DNQ_Date__c = Date.Today();
                    showError = false;
                    LogValue = 'Status:'+currentLead.Status+'DNQDate:'+currentLead.DNQ_Date__c;
                }
                if(!String.isBlank(message)){
                    for(case currCase : newCaseList){
                        currCase.addError('Please provide values for following fields in Lead: '+message+'.');
                    }
                }                
                UpadtedLeadListInfo.add(currentLead);
            }
            if(UpadtedLeadListInfo.size()>0 && showError == false){
                Update UpadtedLeadListInfo;
            }
       /* }
        catch(Exception e){
            for(case currCase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currCase.addError(e.getMessage());
            }
        }*/
    }
    
    /******************************************************************************************************************************
This method is used to update the volunteer Opportunity for In Progress check box is true or false based on parent wish status.
********************************************************************************************************************************/
    public static void updateVolunteerOpp(Set<Id> volunteerOppCaseIdSet, boolean bool,List<Case> caseList){
        RecursiveTriggerHandler.blockCaseLockRecursive = False;
        List<Volunteer_Opportunity__c> updateVolOppList = new List<Volunteer_Opportunity__c>();
        String LogValue;
        //try{
            for(Volunteer_Opportunity__c currRec : [SELECT Id,Wish__c FROM Volunteer_Opportunity__c  WHERE Wish__c IN :volunteerOppCaseIdSet Limit 50000]){
                Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
                newVolOpp.Id = currRec.Id;
                if(bool == true){
                    newVolOpp.In_Progress__c = True;
                }
                else if(bool == false){
                    newVolOpp.In_Progress__c = false;
                }
                updateVolOppList.add(newVolOpp);
            }
            if(updateVolOppList.Size() > 0){
                Update updateVolOppList;
            }
        /*}
        catch(Exception e){
            for(case currcase : caseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /******************************************************************************************************************************
Update the HiddenGrantedDate in Contact when Wish is Granted.
********************************************************************************************************************************/
    public static void updateGrantedDate(List<case> wishGrantedIdList){
        List<Contact> updateContactList = new List<Contact>();
        String LogValue;
        //try{
            for(Case dbCase : wishGrantedIdList){
                Contact dbCont = new Contact();
                dbCont.id = dbCase.ContactId;
                dbCont.Hidden_Granted_Date__c= System.Today();
                LogValue = 'HiddenGrantedDate:'+dbCont.Hidden_Granted_Date__c;
                updateContactList.add(dbCont);
            }            
            if(updateContactList.size() > 0)
                update updateContactList;
        /*} 
        catch(Exception e){
            for(case currcase : wishGrantedIdList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /**************************************************************************************************************
This static method is used to update the parent case status when the budget form is Approved or Rejected.
**************************************************************************************************************/
    public static void matchBudgetData(Set<Id> approvedBudgetIdsSet, Map<Id, String> approvedBudgetStatus,List<Case> caseList) {
        List<Wish_Expense__c> wishExpenseUpdateList = new List<Wish_Expense__c>();
        Map<Id,Case> updateCaseMap = new Map<Id,Case>();
        List<Case> casebudgetapprovals = new List<Case>();
        Set<Id> approvedCaseIds = new Set<Id>();
        String budgetStatus='';
        String projectedStatus='';
        String caseApproveStatus;
        //try{
            for(Wish_Expense__c updateRecord : [SELECT Id, Wish_Expense_Approval_Status__c,Budget_Approval_Status__c, Projected_Approval_Status__c,  
                                                Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c, Actual_Cash__c,
                                                Actual_In_Kind__c,Case__c, Case__r.Budget_Approved_Date__c,Case__r.Status FROM Wish_Expense__c WHERE Case__c =: approvedBudgetStatus.keySet() Limit 50000]) {
                                                    caseApproveStatus = approvedBudgetStatus.get(updateRecord.Case__c) ;
                                                    
                                                    if(caseApproveStatus == 'Approved'){
                                                        if(updateRecord.Budget_Approval_Status__c == 'Submitted'){
                                                            updateRecord.Budget_Approval_Status__c = 'Approved';
                                                            budgetStatus='Approved';
                                                            if(updateRecord.Projected_Cash__c == 0) {
                                                                updateRecord.Projected_Cash__c = updateRecord.Budget_Cash__c;
                                                            }
                                                            if(updateRecord.Projected_In_Kind__c == 0) {
                                                                updateRecord.Projected_In_Kind__c = updateRecord.Budget_In_Kind__c;
                                                            }
                                                        }
                                                        if(updateRecord != Null)
                                                        {
                                                            Case updateCase = new Case();
                                                            updateCase.id = updateRecord.Case__c;
                                                            updateCase.Budget_Approved_Date__c = Date.Today();
                                                            updateCase.Status = 'Budget Approval - Approved';
                                                            updateCaseMap.put(updateRecord.Case__c,updateCase);
                                                            System.debug('Budget Approved Date '+updateCase.Budget_Approved_Date__c);
                                                            
                                                        }
                                                        if(updateRecord.Projected_Approval_Status__c == 'Submitted'){
                                                            updateRecord.Projected_Approval_Status__c = 'Approved';
                                                            projectedStatus= 'Approved';
                                                        }
                                                    }
                                                    wishExpenseUpdateList.add(updateRecord);
                                                    if(!approvedCaseIds.contains(updateRecord.Case__c)){
                                                        approvedCaseIds.add(updateRecord.Case__c);
                                                    }
                                                }
            if(wishExpenseUpdateList.size() > 0) {
                Update wishExpenseUpdateList;
            }
            if(updateCaseMap.size() >0)
                update updateCaseMap.values();
            
            if(budgetStatus=='Approved' || projectedStatus== 'Approved'){
                for(Id tempId : approvedCaseIds ){
                    Case approvedCase = new Case();
                    approvedCase.Id= tempId;
                    if(budgetStatus=='Approved')
                        approvedCase.Budget_Status__c=budgetStatus;
                    if(projectedStatus== 'Approved')
                        approvedCase.Projected_Status__c=projectedStatus; 
                    casebudgetapprovals.add(approvedCase);       
                }
                update casebudgetapprovals;
            }
        /*}
        catch(Exception e){
            for(case currcase : caseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /******************************************************************************************
When the case status is updated the corresponding lead status should be update.
******************************************************************************************/
    public static void UpdateLeadStatus(List<Case> caseList){
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<Lead> updateLeadList = new List<Lead>();
        //try{
            for(Case processdbcaseList : caseList){
                if(processdbcaseList.Status == 'Open' || processdbcaseList.Status == 'Escalated')
                    caseMap.Put(processdbcaseList.Lead__c,processdbcaseList);
            }
            
            if(caseMap.size() > 0){
                for(Lead dbLeads: [SELECT Id,Status,Sub_Status__c,IsConverted FROM Lead WHERE Id in: caseMap.KeySet() AND IsConverted = False LIMIT 50000]){
                    /*if(caseMap.get(dbLeads.Id).Status == 'Open') Removed as per IME 4
                    {
                        dbLeads.Sub_Status__c = 'Local';
                    }
                    
                    if(caseMap.get(dbLeads.Id).Status == 'Escalated')
                    {
                        dbLeads.Sub_Status__c = 'National';
                    }*/
                    updateLeadList.add(dbLeads);
                }
                
            }
            
            if(updateLeadList.size() > 0)
                update updateLeadList;
       /* }
        catch(Exception e){
            for(case currcase : caseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
        
    }
    /********************************************************************************************************************
1.If interview date is changed then the "Wish Determination" Task due dates are updated with new interview date.
********************************************************************************************************************/
    public static void updateDeterminationTaskDueDates(Map<Id,Date> dueDateMap,List<Case> newCaseList) {
        List<Task> updateDueDates = new List<Task>();
        Set<Id> checkInDupRecord = new Set<Id>();
        //try{
            for(Task closeTask : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : dueDateMap.keySet() AND Status != 'Completed' LIMIT 50000]) {
                
                if(closeTask.Status != 'Completed') {
                    if(closeTask.Subject == 'Procure Icebreaker Gift' || closeTask.Subject == 'Conduct initial wish visit') {
                        if(dueDateMap.get(closeTask.WhatId) != null ) {
                            closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId);
                        } else {
                            closeTask.ActivityDate = null;
                        }
                    }
                    if(closeTask.Subject == 'Confirm wish visit with wish family') {
                        if(dueDateMap.get(closeTask.WhatId) != null ) {
                            closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId).addDays(-2);
                        } else {
                            closeTask.ActivityDate = null;
                        }
                    }
                    if(closeTask.Subject == 'Complete/upload wish family packet') {
                        if(dueDateMap.get(closeTask.WhatId) != null ) {
                            closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 5;
                        } else {
                            closeTask.ActivityDate = null;
                        }
                    }
                    if(closeTask.Subject == 'Submit wish family packet to chapter approval') {
                        if(dueDateMap.get(closeTask.WhatId) != null ) {
                            closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 2;
                        } else {
                            closeTask.ActivityDate = null;
                        }
                    }
                    if(closeTask.Subject == 'Check in with the family every 30 days') {
                        if(dueDateMap.get(closeTask.WhatId) != null ) {
                            closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 30;
                        }
                    }
                } else if(closeTask.Status == 'Completed' && closeTask.Subject == 'Check in with the family every 30 days') {
                    checkInDupRecord.add(closeTask.Id);
                }
                updateDueDates.add(closeTask);
            }
            if(updateDueDates.size() > 0) {
                for(Integer i=0; i< updateDueDates.size(); i++) {
                    if(checkInDupRecord.contains(updateDueDates[i].Id)) {
                        updateDueDates.remove(i);
                    }
                }
                update updateDueDates;
            }
        /*}
        catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /*****************************************************************************************************************************************
This method is used to create and update interview Task when the InterviewDate field in parent case is updated.
******************************************************************************************************************************************/
    public static void inTerviewTask(Set<Id> interViewCloseTaskIdsSet, Set<Id> interViewOpenTaskIdsSet, Map<Id, Case> interviewTaskParentIdMap) {
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> updateTasks = new List<Task>();
        //Used to get case and its case team members
        //try{
            for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : interviewTaskParentIdMap.keySet() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor') ORDER BY CreatedDate DESC LIMIT 50000]) {
                if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                    caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
                } 
            }
            if(interViewCloseTaskIdsSet.size() > 0 ) {
                for(Task closeTask : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : interViewCloseTaskIdsSet AND Status != 'Completed' LIMIT 50000]) {
                    if(closeTask.Subject == 'Enter interview date') {
                        closeTask.Status = 'Completed';
                        updateTasks.add(closeTask);
                    }
                }
            }
            if(interViewOpenTaskIdsSet.size() > 0 ) {
                for(Id parentId : interViewOpenTaskIdsSet) {
                    Task newSubTask = new Task();
                    newSubTask.Subject = 'Enter interview date';
                    newSubTask.SystemGeneratedTask__c = true;
                    newSubTask.ActivityDate = System.Today() + 7;
                    newSubTask.WhatId = parentId;
                    newSubTask.IsVisibleInSelfService = true;
                    newSubTask.RecordTypeId = volunteerTaskRT;
                    if(interviewTaskParentIdMap.containsKey(parentId))  {
                        newSubTask.WhoId = interviewTaskParentIdMap.get(parentId).contactId;
                    }
                    if(caseTeamMemberMap.containsKey(parentId)) {
                        newSubTask.OwnerId = caseTeamMemberMap.get(parentId);
                    }
                    updateTasks.add(newSubTask);
                }
            }
            if(updateTasks.size() > 0) {
                upsert updateTasks;
            }
        /*}
        catch(Exception e){
            for(case currcase : interviewTaskParentIdMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /***********************************************************************************************************************************
This method is used to update interviewdate not set checkbox in determination case based on the parent case interview date field   
**************************************************************************************************************************************/
    public static void updateWishDeterminationInterviewDateNotSet(set<id> wishInterviewDateSet,List<Case> newCaseList){
        Constant_AC  constant = new Constant_Ac();    
        list<Case> updateInterviewDateNotSetCaseList = new list<Case>();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        //try{
            for(Case currentCase : [SELECT ID,Interview_Date_Not_Set__c,ParentId,RecordTypeId,Parent.Interview_date__c  
                                    FROM Case WHERE ParentId IN: wishInterviewDateSet AND RecordTypeId =: wishDeterminationRecordTypeId LIMIT 50000]){
                                        if(currentCase.Parent.Interview_date__c != Null)
                                            currentCase.Interview_Date_Not_Set__c = true;
                                        if(currentCase.Parent.Interview_date__c == Null)
                                            currentCase.Interview_Date_Not_Set__c = false;  
                                        updateInterviewDateNotSetCaseList.add(currentCase);
                                    }
            
            if(updateInterviewDateNotSetCaseList.size() > 0){
                update updateInterviewDateNotSetCaseList;
            }
        /*}
        catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    /*********************************************************************************************************************************** 
This method is called when the parent case End Date field is updated.
**************************************************************************************************************************************/
    public static void wishGrantedPresentationTask(Set<Id> interViewCloseTaskIdsSet, Set<Id> interViewOpenTaskIdsSet, Map<Id, Case> interviewTaskParentIdMap, Set<Id> presentationIdsSet, Set<Id> endDateIdSet, Set<Id> presentatationIdentifySet, List<Case> newCaseList) {
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        //Used to get case and its case team members
        Map<String,Chapter_Action_Track__c> wishGrantedTaskDetailsMap = new Map<String,Chapter_Action_Track__c>();
        //try{
            for(Chapter_Action_Track__c createSubTask : [SELECT Id, Task_Name__c, RecordType.Name, Due_Days__c, Sort_Order__c, Description__c FROM Chapter_Action_Track__c WHERE RecordTypeId =: wishGrantTaskRT LIMIT 50000]) {
                wishGrantedTaskDetailsMap.put(createSubTask.Task_Name__c, createSubTask);
            }
            for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : interviewTaskParentIdMap.keySet() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor') ORDER BY CreatedDate DESC LIMIT 50000]) {
                if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                    caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
                } 
            }
            List<Task> updateTasks = new List<Task>();
            if(interViewCloseTaskIdsSet.size() > 0 ) {
                for(Task closeTask : [SELECT Id,Task_Type__c, Status,Subject,RecordTypeId, WhatId FROM Task WHERE WhatId IN : interViewCloseTaskIdsSet AND Status != 'Completed' LIMIT 50000]) {
                    if(closeTask.Task_Type__c == 'Wish Granting') {
                        if(closeTask.Subject == 'Schedule Wish Presentation (add date, time, location name and address)' && presentationIdsSet.contains(closeTask.WhatId)) {
                            closeTask.Status = 'Completed';
                            updateTasks.add(closeTask);
                        } 
                        if(closeTask.Subject != 'Schedule Wish Presentation (add date, time, location name and address)' && closeTask.Subject != 'Secure in-kind donations for wish presentation') {
                            if(wishGrantedTaskDetailsMap.containsKey(closeTask.Subject)) {
                                Integer dueDateCalc = Integer.valueOf(wishGrantedTaskDetailsMap.get(closeTask.Subject).Due_Days__c);
                                if(interViewCloseTaskIdsSet.contains(closeTask.WhatId) && closeTask.Subject == 'Obtain itinerary and/or wish packet' && presentatationIdentifySet.contains(closeTask.WhatId)) {
                                    closeTask.ActivityDate = interviewTaskParentIdMap.get(closeTask.WhatId).Presentation_Date__c.addDays(-dueDateCalc);
                                    //closeTask.Status = 'Completed';
                                }
                                if(endDateIdSet.contains(closeTask.WhatId)) {
                                    closeTask.ActivityDate = interviewTaskParentIdMap.get(closeTask.WhatId).End_Date__c.addDays(-dueDateCalc);
                                }
                                updateTasks.add(closeTask);
                            }
                        }
                    } else {
                        if(closeTask.Subject == 'Wish Presentation not set' && presentationIdsSet.contains(closeTask.WhatId)) {
                            closeTask.Status = 'Completed';
                            updateTasks.add(closeTask);
                        } 
                    }
                }
            }
            if(interViewOpenTaskIdsSet.size() > 0 ) {
                for(Id parentId : interViewOpenTaskIdsSet) {
                    Task newSubTask = new Task();
                    newSubTask.Subject = 'Schedule Wish Presentation (add date, time, location name and address)';
                    if(interviewTaskParentIdMap.containsKey(parentId) && interviewTaskParentIdMap.get(parentId).Anticipated_Start_Date__c!= null) {
                        newSubTask.ActivityDate = interviewTaskParentIdMap.get(parentId).Anticipated_Start_Date__c- 30;
                    }
                    newSubTask.WhatId = parentId;
                    newSubTask.RecordTypeId = volunteerTaskRT;
                    newSubTask.IsVisibleInSelfService = true;
                    newSubTask.Task_Type__c = 'Wish Granting';
                    newSubTask.SystemGeneratedTask__c = true;
                    if(interviewTaskParentIdMap.containsKey(parentId))  {
                        newSubTask.WhoId = interviewTaskParentIdMap.get(parentId).contactId;
                    }
                    if(caseTeamMemberMap.containsKey(parentId)) {
                        newSubTask.OwnerId = caseTeamMemberMap.get(parentId);
                    }
                    updateTasks.add(newSubTask);
                }
                for(Task changeTaskDueDate : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : interViewOpenTaskIdsSet AND Status != 'Completed' AND Task_Type__c = 'Wish Granting' AND Subject = 'Obtain itinerary and/or wish packet' LIMIT 50000]) {
                    changeTaskDueDate.ActivityDate = null;
                    updateTasks.add(changeTaskDueDate);
                }
            }
            if(updateTasks.size() > 0) {
                upsert updateTasks;
            }
        //}
        /*catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /*************************************************************************************
This mehod is used to close the conceptApproval Task when the case status is updated.
****************************************************************************************/
    public static void autoCloseTask(Set<Id> conceptApprovalTaskParentIdSet,List<Case> newCaseList) {
        List<Task> closeTaskList = new List<Task>();
       // try{
            for(Task closeTask : [SELECT Id FROM Task WHERE Subject = 'Wish concept approval' AND WhatId IN : conceptApprovalTaskParentIdSet LIMIT 50000]) {
                closeTask.Status = 'Completed';
                closeTaskList.add(closeTask);
            }
            if(closeTaskList.size() > 0) {
                update closeTaskList;
            }
        //}
        /*catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    /****************************************************************************************************************
1.Used to create 2 volunteer oppotunity when the case status is changed to 'Ready to Assign'
2.Used to add case related chapter volunteer manager into case team with role name "Volunteer manager"
*****************************************************************************************************************/
    public static void createVolunteerOpportunity(Map<Id,Case> readyToAssignParentCaseMap, Set<Id> readtToAssignChapterIdSet){
        RecursiveTriggerHandler.isFirstTime = false;
        Map<Id,Chapter_Role__c> chapterRoleMap = new Map<Id,Chapter_Role__c>();
        Map<Id, String> caseTeamRoleNameMap = new Map<Id, String>();
        Map<String, Id> caseTeamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> accountVolunteerManagerMap = new Map<Id, Id>(); //Used to hold Chater Account Id & its Volunteer Manager Id
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        List<CaseTeamMember> readyToAssignCaseTeamMemberList = new List<CaseTeamMember>();
        //try{
            for(Chapter_Role__c currentChapterRole :[SELECT ID, Chapter_Name__c, Chapter_Name__r.Name, Role_Name__r.Name FROM Chapter_Role__c WHERE Role_Name__r.Name = 'Wish Granter' AND Chapter_Name__c IN : readtToAssignChapterIdSet LIMIT 50000]){
                chapterRoleMap.put(currentChapterRole.Chapter_Name__c, currentChapterRole);
            }
            for(Account chaterAccountInfo : [SELECT Id, Name, Volunteer_Manager__c, RecordTypeId FROM Account WHERE RecordTypeId =: chapterecordTypeId AND Id IN : readtToAssignChapterIdSet AND Volunteer_Manager__c != NULL LIMIT 50000]) {
                accountVolunteerManagerMap.put(chaterAccountInfo.Id, chaterAccountInfo.Volunteer_Manager__c);
            }
            for(CaseTeamRole caseTeamRoleInfo : [SELECT Id, Name FROM CaseTeamRole LIMIT 50000]) {
                caseTeamRoleNameMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name);
                caseTeamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
            }
            if(chapterRoleMap.size() > 0){
                for(Case currentCase : readyToAssignParentCaseMap.Values()){
                    for(Integer i=0 ;i<=1;i++){
                        if(chapterRoleMap.containsKey(currentCase.ChapterName__c)){
                            Volunteer_Opportunity__c volunteerOpp = new Volunteer_Opportunity__c();
                            volunteerOpp.Chapter_Role_Opportunity__c = chapterRoleMap.get(currentCase.ChapterName__c).Id;
                            volunteerOpp.Wish__c = currentCase.id;
                            volunteerOpp.RecordTypeId = volunteerOppWishRecordTypeId;
                            volunteerOpp.Is_Non_Viewable__c = True;
                            volunteerOpp.Chapter_Name__c = chapterRoleMap.get(currentCase.ChapterName__c).Chapter_Name__c;
                            volunteerOppList.add(volunteerOpp);
                        }
                    }
                }
                if(volunteerOppList.size()>0){
                    insert volunteerOppList;
                }
            }
            
            for(Case changeCaseOwner : readyToAssignParentCaseMap.values()) {
                CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                newCaseTeamMember.ParentId = changeCaseOwner.Id;
                if(caseTeamRoleIdMap.containsKey('Volunteer Manager')) {
                    newCaseTeamMember.TeamRoleId = caseTeamRoleIdMap.get('Volunteer Manager');
                }
                newCaseTeamMember.MemberId = changeCaseOwner.OwnerId;
                readyToAssignCaseTeamMemberList.add(newCaseTeamMember);
            }
       // }
        /*catch(Exception e){
            for(case currcase : readyToAssignParentCaseMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/
    }
    
    /*********************************************************************************************
Open all sub case when the status is changed from "DNQ", "Completed" and "Closed".
********************************************************************************************/
    Public static void UpdateSubCaseStatus(set<Id> ParentIdSet,List<Case> newCaseList){
        if(ParentIdSet.size() > 0){
            //try{
                List<Case> caseList = new List<Case>();
                for(Case dbCase : [SELECT Id,ParentId,Status FROM Case WHERE ParentId IN:ParentIdSet LIMIT 50000]){
                    If(ParentIdSet.contains(dbCase.ParentId)){
                        dbCase.status = 'Open';
                        dbCase.Hidden_Close_Sub_Case__c = true;
                        caseList.add(dbCase);
                    }
                }
                
                if(caseList.size() > 0)
                    update caseList;
           // }
            
           /* catch(Exception e){
                for(case currcase : newCaseList){
                    system.debug('@@ Exception @@'+e);
                    currcase.addError(e.getMessage());
                }
            } */  
        }
    }
    
    /********************************************************************************************
Used to update Case Team Role & to create new Case Team Member based on case Status.
*********************************************************************************************/
    public static void CreateAndUpdateUserCaseTeamRole(Map<Id, Case> updateVolunteerManagerCaseTeamMap, Set<Id>volunteerManagerIdSet, Set<Id>wishCoordinatorIdSet) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Map<Id,String> teamRoleNameMap = new Map<Id, String>();
        Map<String,Id> teamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> ownerManagerMap = new Map<Id, Id>();
        Set<Id> caseOwnerIdSet = new Set<Id>();
        //try{
            for(Case getOwner: updateVolunteerManagerCaseTeamMap.values()) {
                caseOwnerIdSet.add(getOwner.OwnerId);
            }
            for(User userManagerInfo : [SELECT Id, ManagerId FROM User WHERE Id IN : caseOwnerIdSet LIMIT 50000]) {
                ownerManagerMap.put(userManagerInfo.Id, userManagerInfo.ManagerId);
            }
            for(CaseTeamRole caseTeamRoleInfo : [SELECT Id, Name FROM CaseTeamRole LIMIT 50000]) {
                teamRoleNameMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name);
                teamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
            }
            
            if(updateVolunteerManagerCaseTeamMap.size() > 0) {
                List<CaseTeamMember> inActiveAndActiveVMUpsertList = new List<CaseTeamMember>();
                Map<Id, List<CaseTeamMember>> caseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
                Map<Id,Set<String>> dbCaseTeamMemberMap = new Map<Id, Set<String>>();
                Map<String, Id> activeCaseTeamMap = new Map<String, Id>();
                Map<String, Id> inActiveCaseTeamMap = new Map<String, Id>();
                Map<Id, Set<Id>> caseTeamMap = new Map<Id, Set<Id>>();
                
                for(CaseTeamMember caseTeamInfo : [SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name FROM CaseTeamMember WHERE (TeamRole.Name = 'Volunteer Manager' OR TeamRole.Name = 'Volunteer Manager (Inactive)' OR TeamRole.Name = 'Wish Coordinator (Inactive)' OR TeamRole.Name = 'Wish Coordinator' OR TeamRole.Name = 'Intake Manager') AND ParentId IN : updateVolunteerManagerCaseTeamMap.keySet() LIMIT 50000]) {
                    if(caseTeamInfo.TeamRole.Name == 'Volunteer Manager' || caseTeamInfo.TeamRole.Name == 'Wish Coordinator' ) {
                        activeCaseTeamMap.put(caseTeamInfo.ParentId+'-'+caseTeamInfo.MemberId,caseTeamInfo.MemberId);
                    } else if(caseTeamInfo.TeamRole.Name == 'Volunteer Manager (Inactive)' || caseTeamInfo.TeamRole.Name == 'Wish Coordinator (Inactive)') {
                        inActiveCaseTeamMap.put(caseTeamInfo.ParentId+'-'+caseTeamInfo.MemberId,caseTeamInfo.MemberId);
                    }
                    if(caseTeamMemberMap.containsKey(caseTeamInfo.ParentId)) {
                        caseTeamMemberMap.get(caseTeamInfo.ParentId).add(caseTeamInfo);
                        caseTeamMap.get(caseTeamInfo.ParentId).add(caseTeamInfo.MemberId);
                    } else {
                        caseTeamMemberMap.put(caseTeamInfo.ParentId, new List<CaseTeamMember>{caseTeamInfo});
                        caseTeamMap.put(caseTeamInfo.ParentId, new Set<Id>{caseTeamInfo.MemberId});
                    }
                }
                System.debug('caseTeamMemberMap>>>>>'+caseTeamMemberMap);
                for(Case updateTeamMember : updateVolunteerManagerCaseTeamMap.values()) {
                    if(caseTeamMemberMap.containsKey(updateTeamMember.Id)) {
                        if(caseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                            for(CaseTeamMember caseTeamMem : caseTeamMemberMap.get(updateTeamMember.Id)) {
                                System.debug('caseTeamMem>>>>'+caseTeamMem);
                                if(caseTeamMem.TeamRole.Name == 'Volunteer Manager' || caseTeamMem.TeamRole.Name == 'Wish Coordinator') {
                                    if(volunteerManagerIdSet.contains(caseTeamMem.ParentId) && caseTeamMem.TeamRole.Name == 'Volunteer Manager') {
                                        caseTeamMem.TeamRoleId = teamRoleIdMap.get(caseTeamMem.TeamRole.Name+' (Inactive)');
                                        inActiveAndActiveVMUpsertList.add(caseTeamMem);
                                    } else if(wishCoordinatorIdSet.contains(caseTeamMem.ParentId) && caseTeamMem.TeamRole.Name == 'Wish Coordinator') {
                                        caseTeamMem.TeamRoleId = teamRoleIdMap.get(caseTeamMem.TeamRole.Name+' (Inactive)');
                                        inActiveAndActiveVMUpsertList.add(caseTeamMem);
                                    }
                                } else if(caseTeamMem.TeamRole.Name == 'Volunteer Manager (Inactive)' || caseTeamMem.TeamRole.Name == 'Wish Coordinator (Inactive)') {
                                    if(inActiveCaseTeamMap.get(caseTeamMem.ParentId+'-'+caseTeamMem.MemberId) == updateTeamMember.OwnerId) {
                                        if(volunteerManagerIdSet.contains(caseTeamMem.ParentId) && caseTeamMem.TeamRole.Name == 'Volunteer Manager (Inactive)') {
                                            caseTeamMem.TeamRoleId = teamRoleIdMap.get(caseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                            inActiveAndActiveVMUpsertList.add(caseTeamMem);
                                        } else if(wishCoordinatorIdSet.contains(caseTeamMem.ParentId) && caseTeamMem.TeamRole.Name == 'Wish Coordinator (Inactive)') {
                                            caseTeamMem.TeamRoleId = teamRoleIdMap.get(caseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                            inActiveAndActiveVMUpsertList.add(caseTeamMem);
                                        }
                                    }
                                }
                            }
                        } else {
                            for(CaseTeamMember caseTeamMem : caseTeamMemberMap.get(updateTeamMember.Id)) {
                                if(caseTeamMem.TeamRole.Name == 'Volunteer Manager' && volunteerManagerIdSet.contains(caseTeamMem.ParentId)) {
                                    caseTeamMem.TeamRoleId = teamRoleIdMap.get(caseTeamMem.TeamRole.Name+' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(caseTeamMem);
                                } else if(caseTeamMem.TeamRole.Name == 'Wish Coordinator' && wishCoordinatorIdSet.contains(caseTeamMem.ParentId)) {
                                    
                                    caseTeamMem.TeamRoleId = teamRoleIdMap.get(caseTeamMem.TeamRole.Name+' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(caseTeamMem);
                                }
                            }
                            CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                            newCaseTeamMember.ParentId = updateTeamMember.Id; 
                            newCaseTeamMember.MemberId = updateTeamMember.OwnerId;
                            
                            if(volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                                if(teamRoleIdMap.containsKey('Volunteer Manager')) {
                                    newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Volunteer Manager');
                                    if(caseTeamMap.containsKey(updateTeamMember.Id) && !caseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                        inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                    }
                                }
                            } else if(wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                                if(teamRoleIdMap.containsKey('Wish Coordinator')) {
                                    newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                                    if(caseTeamMap.containsKey(updateTeamMember.Id) && !caseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                        inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                    }
                                    if(ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                        CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                        newCaseManagerTeamMember.ParentId = updateTeamMember.Id; 
                                        newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                        newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                                        if(caseTeamMap.containsKey(updateTeamMember.Id) && !caseTeamMap.get(updateTeamMember.Id).contains(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                            inActiveAndActiveVMUpsertList.add(newCaseManagerTeamMember);
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else {
                        CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                        newCaseTeamMember.ParentId = updateTeamMember.Id; 
                        newCaseTeamMember.MemberId = updateTeamMember.OwnerId;
                        if(volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                            if(teamRoleIdMap.containsKey('Volunteer Manager')) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Volunteer Manager');
                                inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                            }
                        } else if(wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                            if(teamRoleIdMap.containsKey('Wish Coordinator')) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                                inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                if(ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                    CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                    newCaseManagerTeamMember.ParentId = updateTeamMember.Id; 
                                    newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                    newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                                    inActiveAndActiveVMUpsertList.add(newCaseManagerTeamMember);
                                }
                            }
                        }
                    }
                }
                if(inActiveAndActiveVMUpsertList.size() > 0) {
                    upsert inActiveAndActiveVMUpsertList;
                }
            }
        //}
       /* catch(Exception e){
            for(case currcase : updateVolunteerManagerCaseTeamMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/  
    }
    /*****************************************************************************************
Used the change the access to case team member when their case team role is updated.
******************************************************************************************/
    public static void chageAccessPermission(Map<Id, Id> caseContactMap,List<Case> newCaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Map<Id, String> caseTeamRoleFilteredMap = new Map<Id, String>();
        Map<String, Id> caseTeamRoleMap = new Map<String, Id>();
        //try{
            for(CaseTeamRole caseTeamRoleInfo : [SELECT Id, Name FROM CaseTeamRole]) {
                if(caseTeamRoleInfo.Name.contains(' (Wish Closed)')) {
                    caseTeamRoleFilteredMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name.remove(' (Wish Closed)'));
                    
                } else {
                    caseTeamRoleMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
                    
                }
            }
            Map<Id,Case> parentCaseMap = new Map<Id,Case>([SELECT Id,ParentId,RecordTypeId FROM Case WHERE ParentId =: Null AND RecordTypeId =: parentWishRecordTypeId AND Id IN: caseContactMap.KeySet() LIMIT 50000]);
            Map<Id, List<CaseTeamMember>> caseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
            for(CaseTeamMember caseTeamMemberInfo : [SELECT Id, MemberId, TeamRoleId, ParentId FROM CaseTeamMember WHERE ParentId IN : caseContactMap.keySet() LIMIT 50000]) {
                if(caseTeamMemberMap.containsKey(caseTeamMemberInfo.ParentId)) {
                    caseTeamMemberMap.get(caseTeamMemberInfo.ParentId).add(caseTeamMemberInfo);
                    
                } else {
                    caseTeamMemberMap.put(caseTeamMemberInfo.ParentId, new List<CaseTeamMember> {caseTeamMemberInfo});
                    
                }
            }
            
            if(caseTeamMemberMap.size() > 0) {
                List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
                List<ContactShare> contactToShareList = new List<ContactShare>();
                for(Id caseId : caseContactMap.keySet()) {
                    
                    if(caseTeamMemberMap.containsKey(caseId)) {
                        
                        for(CaseTeamMember caseTeamRoleUpdate : caseTeamMemberMap.get(caseId)) {
                            if(caseTeamRoleFilteredMap.containsKey(caseTeamRoleUpdate.TeamRoleId)) {
                                
                                if(caseTeamRoleMap.containsKey(caseTeamRoleFilteredMap.get(caseTeamRoleUpdate.TeamRoleId))) {
                                    caseTeamRoleUpdate.TeamRoleId = caseTeamRoleMap.get(caseTeamRoleFilteredMap.get(caseTeamRoleUpdate.TeamRoleId));
                                    updateRoleList.add(caseTeamRoleUpdate);
                                    //Contact Share
                                    if(parentCaseMap.containsKey(caseId)){
                                        ContactShare shareContact = new ContactShare();
                                        shareContact.ContactAccessLevel = 'Read';
                                        shareContact.ContactId = caseContactMap.get(caseId);
                                        shareContact.UserOrGroupId = caseTeamRoleUpdate.MemberId;
                                        contactToShareList.add(shareContact); 
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                if(updateRoleList.size() > 0) 
                    update updateRoleList;
                
                if(contactToShareList.size() > 0) {
                    insert contactToShareList;
                }
            }
        //}
        /*catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */ 
    }
    /***************************************************************************************************
Used to create Activities for WishPlanning & Anticipation Wish.
****************************************************************************************************/
    public static void wishPlaningAnticipationTaskCreation(Map<Id, Case> wishPlanningAndGrantinTaskParentMap)
    {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Constant_AC  constant = new Constant_Ac();    
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id wishPlanningCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id chapterRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id staffTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
        Date todayDate;
        List<Task> planingAnticipationTaskList = new List<Task>();
        Integer monthCount = 0;
        Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
        Map<Id,Id> chapterCoordinatorMap = new Map<Id, Id>();
        Map<Id, Case> wishPlaningAnticipationSubCaseMap = new Map<id, Case>();
        //try{
            for(Case planningCaseInfo : [SELECT Id FROM Case WHERE ParentId IN : wishPlanningAndGrantinTaskParentMap.keySet() AND RecordTypeId =: wishPlanningCaseRecordTypeId LIMIT 50000]) {
                wishPlaningAnticipationSubCaseMap.put(planningCaseInfo.Id, planningCaseInfo);
            }
            
            for(Account chapterInfo : [SELECT Id, Wish_Co_ordinator__c FROM Account WHERE RecordTypeId =: chapterRecordTypeId LIMIT 50000]) {
                chapterCoordinatorMap.put(chapterInfo.Id, chapterInfo.Wish_Co_ordinator__c);
            }
            for(Chapter_Action_Track__c getTask : [SELECT Id, Task_Name__c, RecordType.Name,Chapter_Name__c, Weeks__c, Months__c ,Wish_type__c, Sort_Order__c 
                                                   FROM Chapter_Action_Track__c 
                                                   ORDER BY Sort_Order__c ASC LIMIT 50000]) 
            {
                if(chapterActionMap.containskey(getTask.Wish_type__c)) {
                    chapterActionMap.get(getTask.Wish_type__c).add(getTask);
                } else {
                    chapterActionMap.put(getTask.Wish_type__c, new List<Chapter_Action_Track__c>{getTask});
                }
            }
            
            for(Case currCase : wishPlanningAndGrantinTaskParentMap.values()) 
            {
                
                if(chapterActionMap.containsKey(currCase.Wish_type__c))
                {
                    for(Chapter_Action_Track__c currActionTrack : chapterActionMap.get(currCase.Wish_type__c))
                    { 
                        if(currActionTrack.Chapter_Name__c == currCase.ChapterName__c) {
                            Task newTask = new Task();
                            newTask.WhatId = currCase.Id;
                            newTask.Subject = currActionTrack.Task_Name__c;
                            newTask.SystemGeneratedTask__c = true;
                            newTask.WhoId = currCase.ContactId;
                            newTask.OwnerId = currCase.OwnerId;
                            newTask.RecordTypeId = staffTaskRT;
                            newTask.Task_Type__c = currActionTrack.RecordType.Name;
                            Integer months = Integer.valueOf(currActionTrack.Months__c);
                            Integer Weeks = Integer.valueOf(currActionTrack.Weeks__c);
                            Integer dayCalc;
                            if(months == Null) {
                                months = 0;
                            }
                            if(Weeks == Null) {
                                Weeks = 0;
                                dayCalc = 0;
                            } else {
                                dayCalc = Weeks * 7;
                            }
                            
                            if(currActionTrack.Months__c != null && currActionTrack.Months__c != 0 && currCase.Anticipated_Start_Date__c!= null) {
                                if(dayCalc != null) {
                                    todayDate = System.today().addDays(dayCalc);
                                } else {
                                    todayDate = System.today();  
                                }
                                if(currCase.Anticipated_Start_Date__c> todayDate.addmonths(months))
                                {
                                    newTask.ActivityDate = currCase.Anticipated_Start_Date__c.addMonths(-months).addDays(dayCalc);
                                }
                                else
                                {
                                    newTask.ActivityDate = Date.Today();
                                }
                            } else if((currActionTrack.Months__c == null || currActionTrack.Months__c == 0) && (currCase.Anticipated_Start_Date__c!= null)) {
                                if(dayCalc != null) {
                                    todayDate = System.today().addDays(dayCalc);
                                }
                                if(currCase.Anticipated_Start_Date__c> todayDate) {
                                    if(currActionTrack.Task_Name__c == 'Create Wish Receipt') {
                                        newTask.ActivityDate = currCase.Anticipated_Start_Date__c.addDays(dayCalc);
                                    } else {
                                        newTask.ActivityDate = currCase.Anticipated_Start_Date__c.addDays(-dayCalc);
                                    }
                                    
                                } else {
                                    newTask.ActivityDate = Date.Today();
                                }
                            } else {
                                
                            }
                            planingAnticipationTaskList.add(newTask);
                        } 
                    }
                } else if(chapterActionMap.containsKey('Other')) {
                    for(Chapter_Action_Track__c currActionTrack : chapterActionMap.get('Other'))
                    { 
                        if(currActionTrack.Chapter_Name__c == currCase.ChapterName__c) {
                            Task newTask = new Task();
                            newTask.WhatId = currCase.Id;
                            newTask.Subject = currActionTrack.Task_Name__c;
                            newTask.SystemGeneratedTask__c = true;
                            newTask.WhoId = currCase.ContactId;
                            newTask.OwnerId = currCase.OwnerId;
                            newTask.RecordTypeId = staffTaskRT;
                            newTask.Task_Type__c = currActionTrack.RecordType.Name;
                            Integer months = Integer.valueOf(currActionTrack.Months__c);
                            Integer Weeks = Integer.valueOf(currActionTrack.Weeks__c);
                            Integer dayCalc;
                            if(months == Null) {
                                months = 0;
                            }
                            if(Weeks == Null) {
                                Weeks = 0;
                                dayCalc = 0;
                            } else {
                                dayCalc = Weeks * 7;
                            }
                            
                            if(currActionTrack.Months__c != null && currActionTrack.Months__c != 0 && currCase.Anticipated_Start_Date__c!= null) {
                                if(dayCalc != null) {
                                    todayDate = System.today().addDays(dayCalc);
                                } else {
                                    todayDate = System.today();  
                                }
                                if(currCase.Anticipated_Start_Date__c> todayDate.addmonths(months))
                                {
                                    newTask.ActivityDate = currCase.Anticipated_Start_Date__c.addMonths(-months).addDays(dayCalc);
                                }
                                else
                                {
                                    newTask.ActivityDate = Date.Today();
                                }
                            } else if((currActionTrack.Months__c == null || currActionTrack.Months__c == 0) && (currCase.Anticipated_Start_Date__c!= null)) {
                                if(dayCalc != null) {
                                    todayDate = System.today().addDays(dayCalc);
                                }
                                if(currCase.Anticipated_Start_Date__c> todayDate) {
                                    if(currActionTrack.Task_Name__c == 'Create Wish Receipt') {
                                        newTask.ActivityDate = currCase.Anticipated_Start_Date__c.addDays(dayCalc);
                                    } else {
                                        newTask.ActivityDate = currCase.Anticipated_Start_Date__c.addDays(-dayCalc);
                                    }
                                } else {
                                    newTask.ActivityDate = Date.Today();
                                }
                            } else {
                                
                            }
                            planingAnticipationTaskList.add(newTask);
                        }
                    }
                }
            }
            if(planingAnticipationTaskList.size() > 0) {
                insert planingAnticipationTaskList;
            }
        //}
        /*catch(Exception e){
            for(case currcase : wishPlanningAndGrantinTaskParentMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/  
    }
    /******************************************************************************************************* 
This method is used to create wish planing and Granting task. when the parent case status is updated.
***********************************************************************************************************/
    public static void wishGrantedSubCaseTaskCreation(Map<Id, Case> parentWishMap) {      
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Map<Id, Date> parentMap = new Map<Id, Date>();
        Map<Id, Id> parentContactIdMap = new map<Id, Id>();
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> wishGrantedTaskList = new List<Task>();
        
        //try{
            for(Case parentCaseDetail : parentWishMap.values()) {
                parentMap.put(parentCaseDetail.Id, parentCaseDetail.Anticipated_Start_Date__c);
                parentContactIdMap.put(parentCaseDetail.Id, parentCaseDetail.ContactId);
            }
            
            //Used to get case and its case team members
            for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name  FROM CaseTeamMember WHERE ParentId IN : parentWishMap.keySet() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor') ORDER BY CreatedDate ASC LIMIT 50000]) {
                if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                    caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
                } 
            }
            
            //List<WishGrantedSubCaseTaskList__c> subTaskList = WishGrantedSubCaseTaskList__c.getAll().values();
            List<Chapter_Action_Track__c> subTaskList = [SELECT Id, Task_Name__c, RecordType.Name, Due_Days__c, Sort_Order__c, Description__c FROM Chapter_Action_Track__c WHERE RecordTypeId =: wishGrantTaskRT LIMIT 50000];
            if(subTaskList.size() > 0) {
                for(Case createTasks : parentWishMap.values()) {
                    for(Chapter_Action_Track__c createSubTask : subTaskList) {
                        Task newSubTask = new Task();
                        newSubTask.Subject = createSubTask.Task_Name__c;
                        if(parentMap.containsKey(createTasks.Id) && parentMap.get(createTasks.Id) != null) {
                            if(createSubTask.Task_Name__c == 'Schedule Wish Presentation (add date, time, location name and address)' || createSubTask.Task_Name__c == 'Secure in-kind donations for wish presentation') {
                                newSubTask.ActivityDate = parentMap.get(createTasks.Id) + Integer.valueOf(createSubTask.Due_Days__c);
                            } else {
                                
                            }
                        }
                        newSubTask.Description = createSubTask.Description__c;
                        newSubTask.WhatId = createTasks.Id;
                        newSubTask.IsVisibleInSelfService = true;
                        newSubTask.SystemGeneratedTask__c = true;
                        newSubTask.RecordTypeId = volunteerTaskRT;
                        newSubTask.Task_Type__c = createSubTask.RecordType.Name;
                        if(parentContactIdMap.containsKey(createTasks.Id)) {
                            newSubTask.WhoId = parentContactIdMap.get(createTasks.Id);
                        }
                        if(caseTeamMemberMap.containsKey(createTasks.Id)) {
                            newSubTask.OwnerId = caseTeamMemberMap.get(createTasks.Id);
                        }
                        wishGrantedTaskList.add(newSubTask);
                    }
                }
                if(wishGrantedTaskList.size() > 0) {
                    insert wishGrantedTaskList;
                }
            }
        //}
       /* catch(Exception e){
            for(case currcase : parentWishMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */
    }
    
    /***************************************************************************************
This method is used to update the child case owner when parent case owner is updated.
****************************************************************************************/
    public static void changeChildCasesOwner(Map<Id, Id> newCaseOwnerMap,List<Case> newCaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Case> childCaseList = new List<Case>();
        //try{
            for(Case childCase : [SELECT Id, OwnerId, ParentId FROM Case WHERE ParentId IN : newCaseOwnerMap.keySet() AND RecordTypeId !=: parentWishRecordTypeId LIMIT 50000]) {
                if(childCase.OwnerId != newCaseOwnerMap.get(childCase.ParentId)) {
                    childCase.OwnerId = newCaseOwnerMap.get(childCase.ParentId);
                    childCaseList.add(childCase);
                }
            }
            if(childCaseList.size() > 0) {
                update childCaseList;
            }
        //}
       /* catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */
    }
    
    /**************************************************************************************************
This method is used create wish clearance task when paren case Receive Date and End Date is changed.
*******************************************************************************************************/
    public static void wishClearanceTask(Map<Id, Case> wishClearanceMap, Set<Id> newWishClearanceSet, Set<Id> newMedicalSummarySet, Set<Id> newMedicalWishClearanceSet)
    {
        List<Task> taskToUpdateList = new List<Task>();
        Set<Task> newTaskSet = new Set<Task>();
        Map<String, Task> taskToUpdateMap = new Map<String, Task>();
        //try{
            for(Task checkClearanceTask : [SELECT Id, Subject, WhatId, OwnerId, ActivityDate FROM Task WHERE isClosed = false AND WhatId IN : wishClearanceMap.keySet() AND (Subject = 'New wish clearance needed' OR Subject = 'New medical summary needed'  OR Subject = 'New wish clearance needed') LIMIT 50000]) {
                taskToUpdateMap.put(checkClearanceTask.WhatId+'-'+checkClearanceTask.Subject, checkClearanceTask);
            }
            if(newWishClearanceSet.size() > 0) {
                for(Id newWishClearanceTask : newWishClearanceSet) {
                    if(taskToUpdateMap.containsKey(newWishClearanceTask+'-'+'New wish clearance needed')) {
                        taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed').ActivityDate = Date.today()+3;
                        taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed'));
                    } else {
                        Task newTask = new Task();
                        newTask.ActivityDate = Date.today() + 3;
                        newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
                        newTask.Subject = 'New wish clearance needed';
                        newTask.WhoId = wishClearanceMap.get(newWishClearanceTask).ContactId;
                        newTask.SystemGeneratedTask__c = TRUE;
                        newTask.WhatId = newWishClearanceTask;
                        taskToUpdateList.add(newTask);
                    }
                }
            }
            if(newMedicalSummarySet.size() > 0) {
                for(Id newWishClearanceTask : newMedicalSummarySet) {
                    if(taskToUpdateMap.containsKey(newWishClearanceTask+'-'+'New medical summary needed')) {
                        taskToUpdateMap.get(newWishClearanceTask+'-'+'New medical summary needed').ActivityDate = Date.today()+3;
                        taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask+'-'+'New medical summary needed'));
                    } else {
                        Task newTask = new Task();
                        newTask.ActivityDate = Date.today() + 3;
                        newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
                        newTask.Subject = 'New medical summary needed';
                        newTask.SystemGeneratedTask__c = TRUE;
                        newTask.WhoId = wishClearanceMap.get(newWishClearanceTask).ContactId;
                        newTask.WhatId = newWishClearanceTask;
                        taskToUpdateList.add(newTask);
                    }
                }
            }
            if(newMedicalWishClearanceSet.size() > 0) {
                for(Id newWishClearanceTask : newMedicalWishClearanceSet) {
                    if(taskToUpdateMap.containsKey(newWishClearanceTask+'-'+'New wish clearance needed')) {
                        taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed').ActivityDate = Date.today()+3;
                        taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed'));
                    } else {
                        Task newTask = new Task();
                        newTask.ActivityDate = Date.today() + 3;
                        newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
                        newTask.Subject = 'New wish clearance needed';
                        newTask.WhatId = newWishClearanceTask;
                        newTask.SystemGeneratedTask__c = TRUE;
                        newTask.WhoId = wishClearanceMap.get(newWishClearanceTask).ContactId;
                        taskToUpdateList.add(newTask);
                    }
                }
            }
            if(taskToUpdateList.size() > 0) {
                newTaskSet.addAll(taskToUpdateList);
                if(newTaskSet.size() > 0) {
                    taskToUpdateList.clear();
                    taskToUpdateList.addAll(newTaskSet);
                    if(taskToUpdateList.size() > 0) {
                        upsert taskToUpdateList;
                    }
                }
            } 
        //}
        /*catch(Exception e){
            for(case currcase : wishClearanceMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */
    }
    
    /********************************************************************************************************************************
//1.Used to create list of task for volunteers when the wish determination case is created.
//2.Based on "Wish Planning" recordtype, we are pulling the list of task which are stored under Chapter Action Track" object.
//3.Task are assigned to the volunteer user who got initially approved for the case with the "Wish Granter" role.
********************************************************************************************************************************/
    public static void wishDeterminationSubCaseTaskCreation(Map<Id, Case> parentWishInfoMap) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> wishDeterminationTaskList = new List<Task>();
        List<Task> birthDayTaskList = new List<Task>();
        Map<Id, Id> parentContactIdMap = new map<Id, Id>();
        //Used to get case and its case team members.
        //try{
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : parentWishInfoMap.Keyset() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor') ORDER BY CreatedDate ASC Limit 50000]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        for(Case parentCaseInfo : parentWishInfoMap.values()) {
            parentContactIdMap.put(parentCaseInfo.Id, parentCaseInfo.ContactId);
        }
        for(Task birthdayTaskInfo : [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE Subject = 'Wish Child Birthday Reminder' AND WhatId IN : parentWishInfoMap.keySet() AND isClosed = false Limit 50000]) {
            if(caseTeamMemberMap.containsKey(birthdayTaskInfo.WhatId)) {
                birthdayTaskInfo.OwnerId = caseTeamMemberMap.get(birthdayTaskInfo.WhatId);
                birthdayTaskInfo.RecordTypeId = volunteerTaskRT;
                birthDayTaskList.add(birthdayTaskInfo);
            }
        }   
        if(birthDayTaskList.size() > 0) {
            update birthDayTaskList;
        }
        //Used get all chapter action track for wish determination case
        List<Chapter_Action_Track__c> subTaskList = [SELECT Id, Task_Name__c,RecordType.Name, Description__c, Due_Days__c, Sort_Order__c FROM Chapter_Action_Track__c WHERE RecordtypeId =: determinationChapterActionRT Limit 50000];
        if(subTaskList.size() > 0) {
            for(Case createTasks : parentWishInfoMap.values()) {
                for(Chapter_Action_Track__c createSubTask : subTaskList) {
                    Task newSubTask = new Task();
                    newSubTask.Subject = createSubTask.Task_Name__c;
                    if(createSubTask.Due_Days__c != null) {
                        newSubTask.ActivityDate = Date.Today() + Integer.valueOf(createSubTask.Due_Days__c);
                    }
                    newSubTask.WhatId = createTasks.Id;
                    newSubTask.RecordTypeId = volunteerTaskRT;
                    newSubTask.IsVisibleInSelfService = true;
                    newSubTask.Task_Type__c = createSubTask.RecordType.Name;
                    newSubTask.WhoId = createTasks.ContactId;
                    newSubTask.Description = createSubTask.Description__c;
                    newSubTask.SystemGeneratedTask__c = true;
                    if(caseTeamMemberMap.containsKey(createTasks.Id)) {
                        newSubTask.OwnerId = caseTeamMemberMap.get(createTasks.Id);
                    }
                    wishDeterminationTaskList.add(newSubTask);
                }
            }
            if(wishDeterminationTaskList.size() > 0) {
                insert wishDeterminationTaskList;
            }
        }
        // }
        /*catch(Exception e){
            for(case currcase : parentWishInfoMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */
    }
    
    /********************************************************************************************************************************
This method is used to update the wish receipt field in parent case when Granting case is updated.
**********************************************************************************************************************************/
    public static void UpdateWishRecipetItems(Map<Id,String> wishReceiptMap,List<Case> newCaseList){
        list<Case> wishReceiptCaseList = new list<Case>();
        //try{
            if(wishReceiptMap.size() > 0){
                for(Case currentCase :[SELECT Id,Wish_Receipt_Items__c FROM Case WHERE ID IN: wishReceiptMap.keySet() LIMIT 50000]){
                    if(wishReceiptMap.containsKey(currentCase.id)){
                        currentCase.Wish_Receipt_Items__c = wishReceiptMap.get(currentCase.id);
                        wishReceiptCaseList.add(currentCase);
                    }
                }
            }
            if(wishReceiptCaseList.size() > 0){
                update wishReceiptCaseList;
            }
        //}
       /* catch(Exception e){
            for(case currcase : newCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/   
    }
    
    /****************************************************************************************************
Used to delete Wishplanning & Anticipation open activities if wish type is changed.
****************************************************************************************************/
    public static void deleteAnticipationTask(Map<Id, Case> caseIdsMap, Set<String> newWishTypeSet) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Task> deleteOpenAnticipationTask = new List<Task>();
        for(Task oldAnticipationTask : [SELECT Id FROM Task WHERE WhatId IN : caseIdsMap.keySet() AND Task_Type__c = 'Wish Planning' AND isClosed = false LIMIT 50000] ) {
            deleteOpenAnticipationTask.add(oldAnticipationTask);
        }
        if(deleteOpenAnticipationTask.size() > 0) {
            delete deleteOpenAnticipationTask;
        }
        Map<Id, Case> planningCaseMap = new Map<Id, Case>();
        for(Case getAnticipationCase : [SELECT Id, ParentId, RecordTypeId FROM Case WHERE RecordTypeId =: wishPlanningRecordTypeId AND isClosed = false AND ParentId IN : caseIdsMap.keySet() LIMIT 50000]) {
            planningCaseMap.put(getAnticipationCase.Id, getAnticipationCase);
        }
        if(planningCaseMap.size() > 0) {
            wishPlaningAnticipationTaskCreation(caseIdsMap);
        }
    }
    /******************************************************************************************************************
Used to update WishPlanning & Anticipation Open activities due dates if the anticipated date is updated.
*******************************************************************************************************************/
    public static void updateAnticipationTasks(Map<Id,Case> updateAniticipationTaskMap, Map<Id,Case> removeAniticipationTaskMap,set<string> wishTypes)
    {
        List<Task> taskListToUpdate = new List<Task>();
        integer months;
        Integer weeks;
        Integer dayCalc;
        Date todayDate;
        //try{        
            if(removeAniticipationTaskMap.size() > 0)
            {
                for(Task updateTask : [SELECT id,ActivityDate FROM Task WHERE Task_Type__c = 'Wish Planning' 
                                       AND whatId IN :removeAniticipationTaskMap.keySet() AND isClosed != True LIMIT 50000])
                {
                    Task toUpdate = new Task();
                    toUpdate.id = updateTask.id;
                    toUpdate.ActivityDate = Null;
                    taskListToUpdate.add(toUpdate);
                }
            } 
            
            if(updateAniticipationTaskMap.size() > 0)
            {
                
                Map<String,Chapter_Action_Track__c> chapterMap = new Map<String,Chapter_Action_Track__c>();
                
                for(Chapter_Action_Track__c getTask : [SELECT Id, Task_Name__c, Chapter_Name__c, Weeks__c, Months__c ,Wish_type__c, Sort_Order__c 
                                                       FROM Chapter_Action_Track__c 
                                                       ORDER BY Sort_Order__c ASC LIMIT 50000]) 
                {
                    chapterMap.put(getTask.Task_Name__c+'-'+getTask.Chapter_Name__c, getTask);
                }
                
                for(Task updateTask : [SELECT id,ActivityDate,WhatId,Subject FROM Task WHERE Task_Type__c = 'Wish Planning' 
                                       AND whatId IN :updateAniticipationTaskMap.keySet() AND isClosed != True LIMIT 50000])
                {
                    if(updateAniticipationTaskMap.containsKey(updateTask.whatId) && chapterMap.containsKey(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c))
                    { 
                        Task toUpdate = new Task();
                        toUpdate.id = updateTask.id;
                        if(chapterMap.containsKey(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c))
                        {
                            months = integer.valueOf(chapterMap.get(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c).months__c);
                            weeks = integer.valueOf(chapterMap.get(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c).Weeks__c);
                            
                            if(months == Null) {
                                months = 0;
                            }
                            if(Weeks == Null) {
                                Weeks = 0;
                                dayCalc = 0;
                            } else {
                                dayCalc = Weeks * 7;
                            }
                            if(months != null && months != 0) {
                                if(dayCalc != null) {
                                    todayDate = System.today().addDays(dayCalc);
                                } else {
                                    todayDate = System.today();  
                                }
                                
                                if(updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c > todayDate.addmonths(months))
                                {
                                    toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addMonths(-months).addDays(dayCalc);
                                }
                                else
                                {
                                    toUpdate.ActivityDate = Date.Today();
                                }
                            } else if(months == null || months == 0) {
                                if(dayCalc != null) {
                                    todayDate = System.today().addDays(dayCalc);
                                }
                                if(updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c > todayDate) {
                                    if(updateTask.Subject == 'Create Wish Receipt') {
                                        toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addDays(dayCalc);
                                    } else {
                                        toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addDays(-dayCalc);
                                    }
                                    
                                    
                                } else {
                                    toUpdate.ActivityDate = Date.Today();
                                }
                            }
                        }
                        
                        taskListToUpdate.add(toUpdate);
                    }
                }
            }
            for(Task getGrantTask : [SELECT Id, WhatId, RecordTypeId, Subject FROM Task WHERE WhatId IN : updateAniticipationTaskMap.keySet() AND (Subject = 'Schedule Wish Presentation (add date, time, location name and address)' OR Subject = 'Secure in-kind donations for wish presentation') AND RecordTypeId =: wishGrantRecordTypeId LIMIT 50000]) {
                getGrantTask.ActivityDate = updateAniticipationTaskMap.get(getGrantTask.whatId).Anticipated_Start_Date__c- 30;
                taskListToUpdate.add(getGrantTask);
            }
            if(taskListToUpdate.size() > 0) {
                update taskListToUpdate;
            }
        //}
        /*catch(Exception e){
            for(case currcase : updateAniticipationTaskMap.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */  
    }
    
    /*************************************************************************************************
To update the task as Abandoned.
**************************************************************************************************/
    public static void UpdateTasksAsAbondoned(Map<Id,Case> UpdateAllOpenTasks){
        List<Task> updateTasksList = new List<Task>();
        //try{
            for(Task currTask : [SELECT id,WhatId FROM TASK WHERE WhatId IN :UpdateAllOpenTasks.keyset() AND isClosed=false LIMIT 50000])
            {
                Task updateTask = new Task();
                updateTask.id = currTask.id;
                updateTask.Status = 'Abandoned';
                updateTasksList.add(updateTask);
            }
            if(updateTasksList.size() > 0)
                update updateTasksList;
        //}
        /*catch(Exception e){
            for(case currcase : UpdateAllOpenTasks.values()){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/  
    }
    
    /*************************************************************************************************
This method is used to send the attachment to the medical proff contact. - Commented as per IME 74
**************************************************************************************************/
    /*public static void sendEmailToNationalMACTeam(List<Case> diagnosisCaseList) {
        Set<Id> leadIdSet = new Set<Id>();
        Map<Id, List<Attachment>> docusignAttachmentMap = new Map<Id, List<Attachment>>();
        Map<Id, Id> caseLeadMap = new map<Id, Id>();
        Set<Id> parentAttachmentIdSet = new Set<Id>();
        List<Case> diagnosisVerificationList = new List<Case>();
        //try{
            for(Case diagnosisCase : diagnosisCaseList) {
                caseLeadMap.put(diagnosisCase.Id, diagnosisCase.Lead__c);
                leadIdSet.add(diagnosisCase.Lead__c);
                diagnosisVerificationList.add(diagnosisCase);
            }
            
            if(leadIdSet.Size() > 0) {
                System.debug('LeadSet>>>>'+leadIdSet);
                for(dsfs__DocuSign_Status__c docusignStatusCheck : [SELECT Id, dsfs__Envelope_Status__c, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Completed' AND dsfs__Lead__c IN :  leadIdSet]) {
                    parentAttachmentIdSet.add(docusignStatusCheck.Id);
                }
                System.debug('parentAttachmentIdSet>>>>'+parentAttachmentIdSet);
                if(parentAttachmentIdSet.Size() > 0) {
                    for(Attachment attachmentInfo : [select Name, ParentId, Body, BodyLength from Attachment where ParentId IN : parentAttachmentIdSet]) {
                        if(docusignAttachmentMap.containsKey(attachmentInfo.ParentId)) {
                            docusignAttachmentMap.get(attachmentInfo.ParentId).add(attachmentInfo);
                        } else {
                            docusignAttachmentMap.put(attachmentInfo.ParentId, new List<Attachment>{attachmentInfo});
                        }
                    }
                }
                
                if(diagnosisVerificationList.size() > 0) {
                    for(Case diagnosisVerificationCase : diagnosisVerificationList) {
                        SendEmailToMacTeam_AC.sendEmail(docusignAttachmentMap, 'National', diagnosisVerificationCase.Local_MCA_Team__c, diagnosisVerificationCase.MAC_Email__c, diagnosisVerificationCase.Id);
                    }
                }
            } 
        //}
        /*catch(Exception e){
            for(case currcase : diagnosisCaseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }
    }*/
    /*************************************************************************************************
Used to update the role for Volunteer user to Wish, when the parent wish is completed.
*************************************************************************************************/
    public static void revokeWishPermissionForVolunteers(Set<Id> parentWishIds, Set<Id> revokingContactIdSet,List<Case> caseList) {
        Map<String,Id> caseTeamRoleMap = new Map<String, Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<ContactShare> removeContactShareList = new List<ContactShare>();
        List<CaseTeamMember> updateTeamRole = new List<CaseTeamMember>();
        List<Case> childCaseList = new List<Case>();
        Set<Id> childWishIdsSet = new Set<Id>();
        Set<Id> memberIdSet = new Set<Id>();
        Set<Id> volunteerUsersSet = new Set<Id>();
        List<Case> closeCaseList = new List<Case>();
        RecursiveTriggerHandler.allowToEditRecord = True;
        //try{
            for(CaseTeamRole caseRole : [SELECT Id, Name FROM CaseTeamRole LIMIT 50000]) {
                if(caseRole.Name.contains('Wish Closed')) {
                    caseTeamRoleMap.put(caseRole.Name, caseRole.Id);
                }
            }
            for(Case childCase : [SELECT Id FROM Case WHERE ParentId IN : parentWishIds AND RecordTypeId !=: parentWishRecordTypeId LIMIT 50000]) {
                childWishIdsSet.add(childCase.Id);
                childCaseList.add(childCase);
            }
            List<CaseTeamMember> caseTeamMemberList = [SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId FROM CaseTeamMember WHERE (ParentId IN : parentWishIds OR ParentId IN : childWishIdsSet) LIMIT 50000];
            if(caseTeamMemberList.size() > 0) {
                for(CaseTeamMember getCaseTeamMember : caseTeamMemberList) {
                    memberIdSet.add(getCaseTeamMember.MemberId);
                }
                if(memberIdSet.size() > 0) {
                    for(User getVolunteerUser : [SELECT Id, ContactId FROM User WHERE ContactId != null AND Id IN : memberIdSet LIMIT 50000]) {
                        volunteerUsersSet.add(getVolunteerUser.Id);
                    }
                }
                
                for(CaseTeamMember getCaseTeamMember : [SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId FROM CaseTeamMember WHERE (ParentId IN : parentWishIds OR ParentId IN : childWishIdsSet) AND (Member.isActive = True) LIMIT 50000]) {
                    String roleName = getCaseTeamMember.TeamRole.Name + ' (Wish Closed)';
                    if(caseTeamRoleMap.size() > 0 && caseTeamRoleMap.containsKey(roleName) && volunteerUsersSet.contains(getCaseTeamMember.MemberId)) {
                        getCaseTeamMember.TeamRoleId = caseTeamRoleMap.get(roleName);
                    }
                    userIdSet.add(getCaseTeamMember.MemberId);
                    updateTeamRole.add(getCaseTeamMember);
                }
                if(updateTeamRole.size() > 0) {
                    update updateTeamRole;
                }
                
            }
            for(ContactShare conShare : [SELECT Id, UserOrGroupId, ContactId FROM ContactShare WHERE ContactId IN : revokingContactIdSet LIMIT 50000]) {
                System.debug('ContactId:'+conShare.ContactId);
                if(userIdSet.Contains(conShare.UserOrGroupId) && volunteerUsersSet.contains(conShare.UserOrGroupId)) {
                    removeContactShareList.add(conShare);
                }
            }
            if(removeContactShareList.size() > 0) {
                delete removeContactShareList;
            }
            if(childCaseList.size() > 0) {
                for(Case closeChildCase : childCaseList) {
                    closeChildCase.status = 'Closed';
                    closeChildCase.Hidden_Close_Sub_Case__c = true;
                    closeCaseList.add(closeChildCase);
                }
                if(closeCaseList.size() > 0) {
                    update closeCaseList;
                }
            }
        //}
       /* catch(Exception e){
            for(case currcase : caseList){
                currcase.addError(e.getMessage());
            }
        } */
    }
    
    /******************************************************************************************************
Change the Volunteer Opportunity Status as Completed when the wish wish status as completed or closed.
******************************************************************************************************/ 
    public static void updateVolunteerOpportunityStatus(Set<Id> caseId,List<Case> caseList){
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c >(); 
        Set<Id> recallApprovalSet = new Set<Id>();
        //try{
            for(Volunteer_Opportunity__c currRec:[SELECT id,Status__c,Wish__c,Wish__r.RecordTypeId from Volunteer_Opportunity__c where Wish__c IN:caseId AND Wish__c != Null AND Wish__r.RecordTypeId =: parentWishRecordTypeId LIMIT 50000]){
                if(currRec.Status__c != 'Completed') {
                    currRec.Status__c='Completed';
                    volunteerOppList.add(currRec);
                }
                recallApprovalSet.add(currRec.Id);
            }
            if(recallApprovalSet.size() > 0) {
                recallVolOppApproval(recallApprovalSet);
            }
            
            if(volunteerOppList.size() > 0 && volunteerOppList != Null){
                Update volunteerOppList;
            }
        //}
        /*catch(Exception e){
            for(case currcase : caseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        }*/  
    }
    
    /******************************************************************************************************
Updating Open Volunteer Opportunity's Inactive and Reason for Inactive field when case is closed. 
******************************************************************************************************/ 
    public static void updateVolunteerOpportunityasInactive(Set<Id> closedCaseIdSet,List<Case> caseList){
        List<Volunteer_Opportunity__c> updateVO_List = new List<Volunteer_Opportunity__c>();
        // try{
            for(Volunteer_Opportunity__c updateVO : [SELECT Id,Inactive__c,Reason_Inactive__c 
                                                     FROM Volunteer_Opportunity__c WHERE 
                                                     Wish__c IN :closedCaseIdSet AND Volunteer_Name__c = Null 
                                                     AND Inactive__c = FALSE AND Migrated_Record__c = false LIMIT 50000]){
                                                         updateVO.Inactive__c = True;
                                                         updateVO.Reason_Inactive__c ='inactivated';
                                                         updateVO_List.add(updateVO);   
                                                     }
            
            if(updateVO_List.Size() > 0)
                Update updateVO_List;
        //}
       /* catch(Exception e){
            for(case currcase : caseList){
                system.debug('@@ Exception @@'+e);
                currcase.addError(e.getMessage());
            }
        } */
    }
    
    /******************************************************************************************************
This method is used to update the wish granted count in contact record.
******************************************************************************************************/ 
    public static void grantedWishCount(set<Id> wishIdsSet){
        Constant_AC  constant = new Constant_Ac();    
        String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        
        Set<Id> volunteerIdsSet = new Set<Id>();
        
        for(Volunteer_Opportunity__c currentVolOpp : [SELECT ID,Wish__c,Wish__r.Status,Volunteer_Name__c,Status__c FROM Volunteer_Opportunity__c WHERE wish__c IN :wishIdsSet AND Volunteer_Name__c != Null LIMIT 50000]){
            volunteerIdsSet.add(currentVolOpp.Volunteer_Name__c);
        }
        
        if(volunteerIdsSet.size() > 0){
            VolOpportunity_OnAfter_Update_Helper.ActiveWishCount(volunteerIdsSet);
        }
        
    }
    
    
    /******************************************************************************************************
This method is used to recall the Volunteer Opportunity approval process
******************************************************************************************************/ 
    @future(callout = true)
    public static void recallVolOppApproval(Set<Id> pendingVollOppIdSet){
        String volOppIsString = '';
        for(String volId : pendingVollOppIdSet){
                volOppIsString += volId + ',';
        }
        VolunteerInterviewTask_AC.getApprovalRecal(volOppIsString.removeEnd(','));
    }
    
    
    /**********************************************************************************************************************************
This method is used to populate end date value in volunteer Opportunity record when the wish status is 'Granted' or 'Closed'
*************************************************************************************************************************************/
    
    public static void populateEndDate(set<Id> wishIdSet){
        if(wishIdSet.size() > 0){
           // try{
                List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
                for(Volunteer_Opportunity__c  dbVolunteerOppRec : [SELECT Id,Wish__c,Wish__r.status,Wish__r.End_Date__c,Wish__r.Closed_Date__c,Wish_Start_Date__c,Wish_End_Date__c,Status__c,Inactive__c FROM Volunteer_Opportunity__c WHERE Wish__c IN:wishIdSet AND Inactive__c =: false AND Status__c != 'Inactive' LIMIT 50000]){
                    if(dbVolunteerOppRec.Wish__r.status == 'Granted'){
                    dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.End_Date__c;
                    }
                    if(dbVolunteerOppRec.Wish__r.status == 'Closed' && dbVolunteerOppRec.Wish__r.Closed_Date__c != Null){
                    dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.Closed_Date__c;
                    }
                    /*if(dbVolunteerOppRec.Wish__r.status == 'Closed' && dbVolunteerOppRec.Wish__r.End_Date__c == Null){
                    dbVolunteerOppRec.Wish_End_Date__c = system.today();
                    }*/
                    volunteerOpportunityList.add(dbVolunteerOppRec);
                }
                update volunteerOpportunityList;
           // }
            /*catch(Exception ex){
                for(case currcase : [SELECT Id From Case WHERE Id IN:wishIdSet]){
                   
                    currcase.addError(ex.getMessage());
                }
            }*/
        }    
    }
    public static void updatewishClearanceForm(Map<Id,case> parentWishClearanceMap){
       // try{
            List<case> updatePlanningCaseList = new List<Case>();
            case updateCase;
            For(Case currCase : [SELECT Id,Wish_Safety_Authorization_Part_B_Form__c,ParentId FROM Case WHERE parentId IN :parentWishClearanceMap.keyset() AND RecordTypeId =:wishPlanningRecordTypeId  LIMIT 50000]){
                if(parentWishClearanceMap.ContainsKey(currCase.parentId)){
                    updateCase = new Case();
                    updateCase.Id = currCase.Id;
                    if(parentWishClearanceMap.get(currCase.parentId).Wish_Clearance_Needed__c == 'Yes')
                        updateCase.Wish_Safety_Authorization_Part_B_Form__c = True;
                    else
                        updateCase.Wish_Safety_Authorization_Part_B_Form__c = False;
                    updatePlanningCaseList.add(updateCase);
             }
          }
            if(updatePlanningCaseList.Size() > 0)
                Update updatePlanningCaseList;
        }
//}
    /*catch(Exception ex){
                for(case currcase : [SELECT Id From Case WHERE Id IN:parentWishClearanceMap.keyset()]){
                   
                    currcase.addError(ex.getMessage());
                }
      }*/
        
    //IME 18  - Method is used to update the lead sub status when case sub status is changed
    public static void updateCasetoLeadSubStatus(String leadStatus, Map<Id, String> subStatusMap){
        Set<Id> leadIds = subStatusMap.keySet();
        List<Lead> leadData = [SELECT Id, Status, Sub_Status__c FROM Lead WHERE Id in :leadIds LIMIT 50000];
        List<Lead> updateLeadList = new List<Lead>();
        
        for(Lead leadtoUpdate: leadData){
            leadtoUpdate.Status = leadStatus;
            leadtoUpdate.Sub_Status__c = subStatusMap.get(leadtoUpdate.Id);
            updateLeadList.add(leadtoUpdate);
        }
        if(updateLeadList.size() > 0){
            update updateLeadList;
        }
    }
}