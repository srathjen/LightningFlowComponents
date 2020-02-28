/*
Modification Log
1. 26/03/18 - Vignesh SM - IME 18 - Line No 242, 1845-1858, 247
*/
public class Case_OnAfterUpdateTriggerHandlerHelper {

    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to instantiate the unused attributes below.
     */
    private static final Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
    private static final Id volunteerOppWishRecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
    private static final Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
    static Set<Id> contactIds = new Set<Id>();
    static Map<Id, Contact> contactMap = new Map<Id, Contact>();
//  static Set<Id> newWishClearanceSet = new Set<Id>();
//  static Set<Id> newMedicalWishClearanceSet = new Set<Id>();
    private static final String CASE_STATUS_CLOSED = Constant_AC.CASE_STATUS_CLOSED;
    private static final String CASE_SUB_STATUS_DNQ_MEDICAL = Constant_AC.CASE_SUB_STATUS_DNQ_MEDICAL;

    /*******************************************************************************************
Related to STT-11 for populating survey email field on parent wish from the Wish Impact sub Case.
********************************************************************************************/
    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to update as there is no longer the concept of parent case.
     */
//  public static void updateSurveyField(Map<Id, Case> surveyEmailMap, Set<Id> impactparentIdSet) {
//      RecursiveTriggerHandler.allowToEditRecord = true;
//      String LogValue;
//      Map<Id, Case> parentCaseMap = new Map<Id, Case>();
//      //try{
//      for (Case parentCase : [
//              SELECT Id,Wish_Impact_Survey_Email__c,Survey_Sent__c
//              FROM Case
//              WHERE Id IN :impactparentIdSet
//              LIMIT 50000
//      ]) {
//          parentCaseMap.put(parentCase.Id, parentCase);
//      }
//
//      for (Case wishImpactCase : surveyEmailMap.values()) {
//          if (parentCaseMap.containsKey(wishImpactCase.ParentId)) {
//              parentCaseMap.get(wishImpactCase.ParentId).Wish_Impact_Survey_Email__c = wishImpactCase.Survey_Email__c;
//              parentCaseMap.get(wishImpactCase.ParentId).Survey_Sent__c = wishImpactCase.Survey_Sent__c;
//              LogValue = String.valueOf(wishImpactCase);
//              LogValue = +'parentCaseNumber:'
//                      + parentCaseMap.get(wishImpactCase.ParentId).CaseNumber
//                      + 'wishImapcatSurveyEmail:'
//                      + parentCaseMap.get(wishImpactCase.ParentId).Wish_Impact_Survey_Email__c
//                      + 'SurveySent:' + parentCaseMap.get(wishImpactCase.ParentId).Survey_Sent__c;
//
//          }
//      }
//      if (parentCaseMap.size() > 0) {
//          update parentCaseMap.values();
//      }
//      //}
//      /*catch(Exception e){
//          for(Case currRec : surveyEmailMap.values()){
//              currRec.addError(e.getmessage());
//          }
//      }*/
//  }

    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to update as there is no longer the concept of parent case.
     */
    /********************************************************************************************
Used to update parent Case when form field updated in planning Case
***********************************************************************************************/
//  public static void updateCaseFormTracking(Map<Id, Case> planningSurveyMap) {
//
//      List<Case> parentCaseList = new List<Case>();
//      //try {
//      for (Case parentCase : [
//              SELECT Id, Form_Tracking_Notes__c
//              FROM Case
//              WHERE Id IN :planningSurveyMap.keySet()
//              AND RecordTypeId = :wishRecordTypeId
//              LIMIT 50000
//      ]) {
//          Case updateParent = new Case();
//          updateParent.Id = parentCase.Id;
//          updateParent.Form_Tracking_Notes__c = planningSurveyMap.get(parentCase.Id).Form_Tracking_Notes__c;
//          parentCaseList.add(updateParent);
//      }
//
//      if (parentCaseList.size() > 0) {
//          update parentCaseList;
//      }
//      /* } catch(Exception e){
//for(Case currRec : planningSurveyMap.values()){
//currRec.addError(e.getmessage());
//}
//}*/
//
//  }

    /********************************************************************************************
Delete all the system generated task when the wish assist is updated to true in parent Case.
***********************************************************************************************/
    public static void deleteWishAssitTask(Set<Id> parentIdSet, List<Case> newCaseList) {
        String LogValue;
        List<Task> deleteTaskList = new List<Task>();
        //try{
        deleteTaskList = [
                SELECT Id,SystemGeneratedTask__c
                FROM Task
                WHERE WhatId IN :parentIdSet
                AND SystemGeneratedTask__c = TRUE
                AND What.RecordTypeId = :wishRecordTypeId
                LIMIT 50000
        ];
        if (deleteTaskList.size() > 0)
            delete deleteTaskList;
        /* }
catch(Exception e){
for(Case currCase : newCaseList){
currCase.addError(e.getMessage());
}
}*/
    }

    /**********************************************************************************************************
Used to update the related contact when the birthday field is changed in the Case.
**********************************************************************************************************/
    public static void updateContactBirthDate(Map<Id, Case> birthdayDateUpdateMap, Set<Id> bdayWishChildSet) {
        //Map<Id, Contact> wishChildMap = new Map<Id, Contact>();
        //String LogValue;

        //try{
        /*for (Contact wishChildCon : [
                SELECT Id,Birthdate
                FROM Contact
                WHERE Id IN :bdayWishChildSet
                LIMIT 50000
        ]) {
            wishChildMap.put(wishChildCon.Id, wishChildCon);
        }

        for (Case parentWish : birthdayDateUpdateMap.values()) {

            if (wishChildMap.containsKey(parentWish.ContactId)) {
                wishChildMap.get(parentWish.ContactId).birthDate = parentWish.Birthdate__c;
                LogValue = 'Current Case:-' + String.valueof(parentWish);
                LogValue = +'Parent Case Birthdate:' + String.valueof(parentWish.Birthdate__c);
            }
        }

        if (wishChildMap.size() > 0) {
            update wishChildMap.values();
        }*/
        /* }
catch(Exception e){

for(Case currCase : birthdayDateUpdateMap.values()){
currCase.addError(e.getMessage());
}
}*/
    }

    /***********************************************************************************************************************
Delete the unassigned volunteer opportunity when the Case status is updated as any one of the following status.
Closed,Granted,Completed,DNQ,Hold,Inactive.
************************************************************************************************************************/
    public static void deleteUnassignedVolunteerOpp(Set<Id> parentWishIdSet, List<Case> newCaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Volunteer_Opportunity__c> deleteVolOppList = new List<Volunteer_Opportunity__c>();
        String LogValue;
        //try{
        deleteVolOppList = [
                SELECT Id,Volunteer_Name__c,Wish__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :parentWishIdSet
                AND Volunteer_Name__c = :NULL
                AND RecordTypeId = :volunteerOppWishRecordTypeId
                LIMIT 50000
        ];
        if (deleteVolOppList.size() > 0)
            delete deleteVolOppList;
        /*}
        catch(Exception e){
            for(Case currCase : newCaseList){
                currCase.addError(e.getMessage());
            }
        }*/
    }

    /***********************************************************************************************************************
Close All System genareated open Task and Sub Cases When the status is updtaed to "DNQ","Completed","Close"'.
************************************************************************************************************************/
    /**
     * JIRA: WLP-428
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to update as there is no longer the concept of parent case.
     */
    /**
     * JIRA: WLP-428
     * Condition only used to call update tasks,
     * the tasks is deprecated as part of WLP-467
     */
    public static void closeAllOpenTask(Set<Id> parentWishIdSet, List<Case> newCaseList) {
        /*RecursiveTriggerHandler.blockCaseLockRecursive = false;
        RecursiveTriggerHandler.allowToEditRecord = true;
        String LogValue;
        If (parentWishIdSet.size() > 0) {
            List<Task> updateTaskList = new List<Task>();
            List<Case> CaseList = new List<Case>();
            //try{
            for (Case dbCase : [
                    SELECT Id,ParentId,Status,Parent.RecordTypeId
                    FROM Case
                    WHERE ParentId IN:parentWishIdSet
                    AND Parent.RecordTypeId = :wishRecordTypeId
                    LIMIT 50000
            ]) {
                If (parentWishIdSet.contains(dbCase.ParentId)) {
                    dbCase.Hidden_Close_Sub_Case__c = true;
                    dbCase.status = 'Closed';
                    CaseList.add(dbCase);
                }
            }
            for (Task dbOpenTask : [
                    SELECT Id,WhatId,SystemGeneratedTask__c
                    FROM Task
                    WHERE WhatId IN:parentWishIdSet AND SystemGeneratedTask__c = :TRUE
                    LIMIT 50000
            ]) {
                dbOpenTask.Status = 'Completed';
                updateTaskList.add(dbOpenTask);
            }

            if (updateTaskList.size() > 0)
                update updateTaskList;

            if (CaseList.size() > 0) {
                update CaseList;
            }
            RecursiveTriggerHandler.allowToEditRecord = false;*/
        /*}
catch(Exception e){
for(Case currCase : newCaseList){
currCase .addError(e.getMessage());
}
}*/
        //}
    }

    /******************************************************************************
Update volunteer opportunity to closed status when related Case is closed.
******************************************************************************/

    public static void closeVolOpp(Set<Id> CaseIdSetForVolOpp, List<Case> newCaseList) {

        List<Volunteer_Opportunity__c> closeVollOppList = new List<Volunteer_Opportunity__c>();
        Set<Id> recallApprovalSet = new Set<Id>();
        String LogValue;

        //try{
        for (Volunteer_Opportunity__c closeVolOpp : [
                SELECT Id, Wish__c,Status__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :CaseIdSetForVolOpp
                AND Wish__c != NULL
                AND Wish__r.RecordTypeId = :wishRecordTypeId
                LIMIT 50000
        ]) {
            if (closeVolOpp.Status__c != 'Closed') {
                closeVolOpp.Status__c = 'Closed';
                closeVollOppList.add(closeVolOpp);
            }
            recallApprovalSet.add(closeVolOpp.Id);
            LogValue = closeVolOpp.Status__c;
        }
        if (recallApprovalSet.size() > 0) {
            recallVolOppApproval(recallApprovalSet);
        }
        if (closeVollOppList.size() > 0) {
            update closeVollOppList;
        }
        /*} catch(Exception e){
for(Case currCase: newCaseList){
currCase.addError(e.getMessage());
}
}*/
    }

    /******************************************************************************
Update Lead status when diagnosis verification Case status is updated.
******************************************************************************/
    public static void updateLeadStatus(set<string> updatedApprovedLeadInfoSet, set<string> updatedDnqLeadInfoSet, List<Case> newCaseList) {
        list<Lead> UpadtedLeadListInfo = new list<Lead>();
        String LogValue;
        String message;
        Boolean showError;
        //try{
        //Removed Childs_Qualifying_Diagnosis__c in query as per IME-120
        for (Lead currentLead : [
                SELECT ID,Status,isConverted, FirstName, Qualifying_ICD__c, Qualifying_Diagnosis__c, I_am_Recognized_To_Practice_As_a__c,Part_A_Received__c,Any_medical_reason_for_moving_quickly__c,DOB__c
                FROM Lead
                WHERE (ID IN:updatedApprovedLeadInfoSet OR ID IN:updatedDnqLeadInfoSet) and isConverted = :false
                LIMIT 50000
        ]) {
            // Commented as per IME-318
            if (updatedApprovedLeadInfoSet.contains(currentLead.Id)) {
                if (currentLead.I_am_Recognized_To_Practice_As_a__c != null
                        && currentLead.Part_A_Received__c != Null
                        && currentLead.Any_medical_reason_for_moving_quickly__c != Null && currentLead.DOB__c != Null) {
                    currentLead.Status = 'Qualified';
                    currentLead.Sub_Status__c = ''; //Added as per IME 18
                    LogValue = 'Status:' + currentLead.Status;
                    showError = false;
                } else {
                    showError = true;
                    /* FirstName is a required field in the backend and therefore can never be null
                    if (currentLead.FirstName == null) {
                        if (message == '' || message == null)
                            message = 'First Name';
                    }*/
                    if (currentLead.DOB__c == null) {
                        if (message == '' || message == null)
                            message = 'DOB'; else message = message + ', ' + 'DOB';
                    }
                    if (currentLead.Any_medical_reason_for_moving_quickly__c == null) {
                        if (message == '' || message == null)
                            message = 'Potential Rush'; else message = message + ', ' + 'Potential Rush';
                    }
                    if (currentLead.Part_A_Received__c == null) {
                        if (message == '' || message == null)
                            message = 'Diagnosis Verification Received'; else message = message + ', ' + 'Diagnosis Verification Received';
                    }
                    if (currentLead.I_am_Recognized_To_Practice_As_a__c == null) {
                        if (message == '' || message == null)
                            message = 'I Am Recognized To Practice As A'; else message = message + ', ' + 'I Am Recognized To Practice As A';
                    }
                }
            }
            /**
            * WLP-428
            * Deprecating DNQ, replacing with Closed
            * Changing Sub Status Medical to DNQ - Medical
            */
            /**
            * SIW-404
            * Revert, lead status DNQ was replaced with Closed, substatus Medical was replaced with DNQ - Medical
            */
            else if (updatedDnqLeadInfoSet.contains(currentLead.Id)) {
                currentLead.Status = 'DNQ';
//SIW-524 hotfix                currentLead.Sub_Status__c = 'Medical';
                currentLead.Sub_Status__c = Label.Wish_Lead_Status_Medical_Reviewed;//Added custom label to remove hardcoded value
                // Added 'Sub_Status__c' as per IME-18
//              currentLead.Status = CASE_STATUS_CLOSED;
//              currentLead.Sub_Status__c = CASE_SUB_STATUS_DNQ_MEDICAL;
                currentLead.DNQ_Date__c = Date.today();
                showError = false;
                LogValue = 'Status:' + currentLead.Status + 'DNQDate:' + currentLead.DNQ_Date__c;
            }
            if (!String.isBlank(message)) {
                for (Case currCase : newCaseList) {
                    currCase.addError('Please provide values for following fields in Lead: ' + message + '.');
                }
            }
            UpadtedLeadListInfo.add(currentLead);
        }
        if (UpadtedLeadListInfo.size() > 0 && showError == false) {
            update UpadtedLeadListInfo;
        }
        /* }
         catch(Exception e){
             for(Case currCase : newCaseList){
                 currCase.addError(e.getMessage());
             }
         }*/
    }

    /******************************************************************************************************************************
This method is used to update the volunteer Opportunity for In Progress check box is true or false based on parent wish status.
********************************************************************************************************************************/
    public static void updateVolunteerOpp(Set<Id> volunteerOppCaseIdSet, boolean bool, List<Case> CaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = False;
        List<Volunteer_Opportunity__c> updateVolOppList = new List<Volunteer_Opportunity__c>();
        String LogValue;
        //try{
        for (Volunteer_Opportunity__c currRec : [
                SELECT Id,Wish__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :volunteerOppCaseIdSet
                LIMIT 50000
        ]) {
            Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
            newVolOpp.Id = currRec.Id;
            if (bool == true) {
                newVolOpp.In_Progress__c = True;
            } else if (bool == false) {
                newVolOpp.In_Progress__c = false;
            }
            updateVolOppList.add(newVolOpp);
        }
        if (updateVolOppList.Size() > 0) {
            Update updateVolOppList;
        }
        /*}
        catch(Exception e){
            for(Case currCase : CaseList){
                currCase.addError(e.getMessage());
            }
        }*/
    }

    /******************************************************************************************************************************
Update the HiddenGrantedDate in Contact when Wish is Granted.
********************************************************************************************************************************/
    public static void updateGrantedDate(List<Case> wishGrantedIdList) {
        List<Contact> updateContactList = new List<Contact>();
        String LogValue;
        //try{
        for (Case dbCase : wishGrantedIdList) {
            Contact dbCont = new Contact();
            dbCont.id = dbCase.ContactId;
            dbCont.Hidden_Granted_Date__c = System.Today();
            LogValue = 'HiddenGrantedDate:' + dbCont.Hidden_Granted_Date__c;
            updateContactList.add(dbCont);
        }
        if (updateContactList.size() > 0)
            update updateContactList;
        /*}
        catch(Exception e){
            for(Case currCase : wishGrantedIdList){
                currCase.addError(e.getMessage());
            }
        }*/
    }

    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Parameters approvedBudgetIdsSet and CaseList passed
     * but never used within the method, removing the parameters
     */
    /**************************************************************************************************************
This static method is used to update the parent Case status when the budget form is Approved or Rejected.
**************************************************************************************************************/
    /**
     * JIRA: WLP-447
     * Author: Mitali Nahar
     * Update: Commented out as per changes in the data model for wish budgets
     */
    /*public static void matchBudgetData(Map<Id, String> approvedBudgetStatus) {
        List<Wish_Expense__c> wishExpenseUpdateList = new List<Wish_Expense__c>();
        Map<Id, Case> updateCaseMap = new Map<Id, Case>();
        List<Case> Casebudgetapprovals = new List<Case>();
        Set<Id> approvedCaseIds = new Set<Id>();
        String budgetStatus = '';
        String projectedStatus = '';
        String CaseApproveStatus;
        //try{
        for (Wish_Expense__c updateRecord : [
                SELECT Id, Wish_Expense_Approval_Status__c,Budget_Approval_Status__c, Projected_Approval_Status__c,
                        Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c, Actual_Cash__c,
                        Actual_In_Kind__c,Case__c, Case__r.Budget_Approved_Date__c,Case__r.Status
                FROM Wish_Expense__c
                WHERE Case__c = :approvedBudgetStatus.keySet()
                LIMIT 50000
        ]) {
            CaseApproveStatus = approvedBudgetStatus.get(updateRecord.Case__c) ;

            if (CaseApproveStatus == 'Approved') {
                if (updateRecord.Budget_Approval_Status__c == 'Submitted') {
                    updateRecord.Budget_Approval_Status__c = 'Approved';
                    budgetStatus = 'Approved';
                    if (updateRecord.Projected_Cash__c == 0) {
                        updateRecord.Projected_Cash__c = updateRecord.Budget_Cash__c;
                    }
                    if (updateRecord.Projected_In_Kind__c == 0) {
                        updateRecord.Projected_In_Kind__c = updateRecord.Budget_In_Kind__c;
                    }
                }
                if (updateRecord != Null) {
                    Case updateCase = new Case();
                    updateCase.id = updateRecord.Case__c;
                    updateCase.Budget_Approved_Date__c = Date.Today();
                    updateCase.Status = 'Budget Approval - Approved';
                    updateCaseMap.put(updateRecord.Case__c, updateCase);
                }
                if (updateRecord.Projected_Approval_Status__c == 'Submitted') {
                    updateRecord.Projected_Approval_Status__c = 'Approved';
                    projectedStatus = 'Approved';
                }
            }
            wishExpenseUpdateList.add(updateRecord);
            if (!approvedCaseIds.contains(updateRecord.Case__c)) {
                approvedCaseIds.add(updateRecord.Case__c);
            }
        }
        if (wishExpenseUpdateList.size() > 0) {
            Update wishExpenseUpdateList;
        }
        if (updateCaseMap.size() > 0)
            update updateCaseMap.values();

        if (budgetStatus == 'Approved' || projectedStatus == 'Approved') {
            for (Id tempId : approvedCaseIds) {
                Case approvedCase = new Case();
                approvedCase.Id = tempId;
                if (budgetStatus == 'Approved')
                    approvedCase.Budget_Status__c = budgetStatus;
                if (projectedStatus == 'Approved')
                    approvedCase.Projected_Status__c = projectedStatus;
                Casebudgetapprovals.add(approvedCase);
            }
            update Casebudgetapprovals;
        }
        }
        catch(Exception e){
            for(Case currCase : CaseList){
                currCase.addError(e.getMessage());
            }
        }
    }*/

    /******************************************************************************************
When the Case status is updated the corresponding lead status should be update.
******************************************************************************************/
    public static void UpdateLeadStatus(List<Case> CaseList) {
        Map<Id, Case> CaseMap = new Map<Id, Case>();
        List<Lead> updateLeadList = new List<Lead>();
        //try{
        for (Case processdbCaseList : CaseList) {
            if (processdbCaseList.Status == 'Open' || processdbCaseList.Status == 'Escalated')
                CaseMap.Put(processdbCaseList.Lead__c, processdbCaseList);
        }

        if (CaseMap.size() > 0) {
            for (Lead dbLeads : [
                    SELECT Id,Status,Sub_Status__c,IsConverted
                    FROM Lead
                    WHERE Id in:CaseMap.KeySet() AND IsConverted = False
                    LIMIT 50000
            ]) {
                /*if(CaseMap.get(dbLeads.Id).Status == 'Open') Removed as per IME 4
                {
                    dbLeads.Sub_Status__c = 'Local';
                }

                if(CaseMap.get(dbLeads.Id).Status == 'Escalated')
                {
                    dbLeads.Sub_Status__c = 'National';
                }*/
                updateLeadList.add(dbLeads);
            }

        }

        if (updateLeadList.size() > 0)
            update updateLeadList;
        /* }
         catch(Exception e){
             for(Case currCase : CaseList){
                 currCase.addError(e.getMessage());
             }
         }*/

    }
    /********************************************************************************************************************
1.If interview date is changed then the "Wish Determination" Task due dates are updated with new interview date.
********************************************************************************************************************/
    /**
     * WLP-428
     * Method only used to update tasks,
     * the tasks is deprecated as part of WLP-467
     */
    public static void updateDeterminationTaskDueDates(Map<Id, Date> dueDateMap, List<Case> newCaseList) {
//      List<Task> updateDueDates = new List<Task>();
//      Set<Id> checkInDupRecord = new Set<Id>();
//      //try{
//      for (Task closeTask : [
//              SELECT Id, Status,Subject, WhatId
//              FROM Task
//              WHERE WhatId IN :dueDateMap.keySet() AND Status != 'Completed'
//              LIMIT 50000
//      ]) {
//
//          if (closeTask.Status != 'Completed') {
//              if (closeTask.Subject == 'Procure Icebreaker Gift' || closeTask.Subject == 'Conduct initial wish visit') {
//                  if (dueDateMap.get(closeTask.WhatId) != null) {
//                      closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId);
//                  } else {
//                      closeTask.ActivityDate = null;
//                  }
//              }
//              if (closeTask.Subject == 'Confirm wish visit with wish family') {
//                  if (dueDateMap.get(closeTask.WhatId) != null) {
//                      closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId).addDays(-2);
//                  } else {
//                      closeTask.ActivityDate = null;
//                  }
//              }
//              if (closeTask.Subject == 'Complete/upload wish family packet') {
//                  if (dueDateMap.get(closeTask.WhatId) != null) {
//                      closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 5;
//                  } else {
//                      closeTask.ActivityDate = null;
//                  }
//              }
//              if (closeTask.Subject == 'Submit wish family packet to chapter approval') {
//                  if (dueDateMap.get(closeTask.WhatId) != null) {
//                      closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 2;
//                  } else {
//                      closeTask.ActivityDate = null;
//                  }
//              }
//              if (closeTask.Subject == 'Check in with the family every 30 days') {
//                  if (dueDateMap.get(closeTask.WhatId) != null) {
//                      closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 30;
//                  }
//              }
//          } else if (closeTask.Status == 'Completed' && closeTask.Subject == 'Check in with the family every 30 days') {
//              checkInDupRecord.add(closeTask.Id);
//          }
//          updateDueDates.add(closeTask);
//      }
//      if (updateDueDates.size() > 0) {
//          for (Integer i = 0; i < updateDueDates.size(); i++) {
//              if (checkInDupRecord.contains(updateDueDates[i].Id)) {
//                  updateDueDates.remove(i);
//              }
//          }
//          update updateDueDates;
//      }
//      /*}
//      catch(Exception e){
//          for(Case currCase : newCaseList){
//              currCase.addError(e.getMessage());
//          }
//      }*/
    }

    /*****************************************************************************************************************************************
This method is used to create and update interview Task when the InterviewDate field in parent Case is updated.
******************************************************************************************************************************************/
    public static void inTerviewTask(Set<Id> interViewCloseTaskIdsSet, Set<Id> interViewOpenTaskIdsSet, Map<Id, Case> interviewTaskParentIdMap) {
        /*WLP-467 remove automated task creation */
//      Map<Id, Id> CaseTeamMemberMap = new Map<Id, Id>();
//      List<Task> updateTasks = new List<Task>();
//      //Used to get Case and its Case team members
//      //try{
//      for (CaseTeamMember CaseTeamMem : [
//              SELECT Id, ParentId, MemberId, TeamRoleId
//              FROM CaseTeamMember
//              WHERE ParentId IN :interviewTaskParentIdMap.keySet() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor')
//              ORDER BY CreatedDate DESC
//              LIMIT 50000
//      ]) {
//          if (!CaseTeamMemberMap.containsKey(CaseTeamMem.ParentId)) {
//              CaseTeamMemberMap.put(CaseTeamMem.ParentId, CaseTeamMem.MemberId);
//          }
//      }
//      if (interViewCloseTaskIdsSet.size() > 0) {
//          for (Task closeTask : [
//                  SELECT Id, Status,Subject, WhatId
//                  FROM Task
//                  WHERE WhatId IN :interViewCloseTaskIdsSet AND Status != 'Completed'
//                  LIMIT 50000
//          ]) {
//              if (closeTask.Subject == 'Enter interview date') {
//                  closeTask.Status = 'Completed';
//                  updateTasks.add(closeTask);
//              }
//          }
//      }
//      if (interViewOpenTaskIdsSet.size() > 0) {
//          for (Id parentId : interViewOpenTaskIdsSet) {
//              Task newSubTask = new Task();
//              newSubTask.Subject = 'Enter interview date';
//              newSubTask.SystemGeneratedTask__c = true;
//              newSubTask.ActivityDate = System.Today() + 7;
//              newSubTask.WhatId = parentId;
//              newSubTask.IsVisibleInSelfService = true;
//              newSubTask.RecordTypeId = volunteerTaskRT;
//              if (interviewTaskParentIdMap.containsKey(parentId)) {
//                  newSubTask.WhoId = interviewTaskParentIdMap.get(parentId).contactId;
//              }
//              if (CaseTeamMemberMap.containsKey(parentId)) {
//                  newSubTask.OwnerId = CaseTeamMemberMap.get(parentId);
//              }
//              updateTasks.add(newSubTask);
//          }
//      }
//      if (updateTasks.size() > 0) {
//          upsert updateTasks;
//      }
//      /*}
//      catch(Exception e){
//          for(Case currCase : interviewTaskParentIdMap.values()){
//              currCase.addError(e.getMessage());
//          }
//      }*/
    }

    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * updating the interview date on the Wish Case itself.
     */
    /***********************************************************************************************************************************
This method is used to update interview date not set checkbox in determination Case based on the parent Case interview date field
**************************************************************************************************************************************/
    public static void updateWishDeterminationInterviewDateNotSet(Set<Id> wishInterviewDateSet, List<Case> newCaseList) {
        //List<Case> updateInterviewDateNotSetCaseList = new List<Case>();
        //try{
        /*for (Case currentCase : [
                SELECT Id,Interview_Date_Not_Set__c,RecordTypeId,Parent.Interview_date__c
                FROM Case
                WHERE Id IN:wishInterviewDateSet AND RecordTypeId = :wishRecordTypeId
                LIMIT 50000
        ]) {
            if (currentCase.Parent.Interview_date__c != null)
                currentCase.Interview_Date_Not_Set__c = true;
            if (currentCase.Parent.Interview_date__c == null)
                currentCase.Interview_Date_Not_Set__c = false;
            updateInterviewDateNotSetCaseList.add(currentCase);
        }

        if (updateInterviewDateNotSetCaseList.size() > 0) {
            update updateInterviewDateNotSetCaseList;
        }*/
        /*}
        catch(Exception e){
            for(Case currCase : newCaseList){
                currCase.addError(e.getMessage());
            }
        }*/
    }
    /***********************************************************************************************************************************
This method is called when the parent Case End Date field is updated.
**************************************************************************************************************************************/
    public static void wishGrantedPresentationTask(Set<Id> interViewCloseTaskIdsSet, Set<Id> interViewOpenTaskIdsSet, Map<Id, Case> interviewTaskParentIdMap, Set<Id> presentationIdsSet, Set<Id> endDateIdSet, Set<Id> presentatationIdentifySet, List<Case> newCaseList) {
        /*WLP-467 remove automated task creation */
//        Map<Id, Id> CaseTeamMemberMap = new Map<Id, Id>();
//      //Used to get Case and its Case team members
//      Map<String, Chapter_Action_Track__c> wishGrantedTaskDetailsMap = new Map<String, Chapter_Action_Track__c>();
//      //try{
//      for (Chapter_Action_Track__c createSubTask : [
//              SELECT Id, Task_Name__c, RecordType.Name, Due_Days__c, Sort_Order__c, Description__c
//              FROM Chapter_Action_Track__c
//              WHERE RecordTypeId = :wishGrantTaskRT
//              LIMIT 50000
//      ]) {
//          wishGrantedTaskDetailsMap.put(createSubTask.Task_Name__c, createSubTask);
//      }
//      for (CaseTeamMember CaseTeamMem : [
//              SELECT Id, ParentId, MemberId, TeamRoleId
//              FROM CaseTeamMember
//              WHERE ParentId IN :interviewTaskParentIdMap.keySet() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor')
//              ORDER BY CreatedDate DESC
//              LIMIT 50000
//      ]) {
//          if (!CaseTeamMemberMap.containsKey(CaseTeamMem.ParentId)) {
//              CaseTeamMemberMap.put(CaseTeamMem.ParentId, CaseTeamMem.MemberId);
//          }
//      }
//      List<Task> updateTasks = new List<Task>();
//      if (interViewCloseTaskIdsSet.size() > 0) {
//          for (Task closeTask : [
//                  SELECT Id,Task_Type__c, Status,Subject,RecordTypeId, WhatId
//                  FROM Task
//                  WHERE WhatId IN :interViewCloseTaskIdsSet AND Status != 'Completed'
//                  LIMIT 50000
//          ]) {
//              if (closeTask.Task_Type__c == 'Wish Granting') {
//                  if (closeTask.Subject == 'Schedule Wish Presentation (add date, time, location name and address)' && presentationIdsSet.contains(closeTask.WhatId)) {
//                      closeTask.Status = 'Completed';
//                      updateTasks.add(closeTask);
//                  }
//                  if (closeTask.Subject != 'Schedule Wish Presentation (add date, time, location name and address)' && closeTask.Subject != 'Secure in-kind donations for wish presentation') {
//                      if (wishGrantedTaskDetailsMap.containsKey(closeTask.Subject)) {
//                          Integer dueDateCalc = Integer.valueOf(wishGrantedTaskDetailsMap.get(closeTask.Subject).Due_Days__c);
//                          if (interViewCloseTaskIdsSet.contains(closeTask.WhatId) && closeTask.Subject == 'Obtain itinerary and/or wish packet' && presentatationIdentifySet.contains(closeTask.WhatId)) {
//                              closeTask.ActivityDate = interviewTaskParentIdMap.get(closeTask.WhatId).Presentation_Date__c.addDays(-dueDateCalc);
//                              //closeTask.Status = 'Completed';
//                          }
//                          if (endDateIdSet.contains(closeTask.WhatId)) {
//                              closeTask.ActivityDate = interviewTaskParentIdMap.get(closeTask.WhatId).End_Date__c.addDays(-dueDateCalc);
//                          }
//                          updateTasks.add(closeTask);
//                      }
//                  }
//              } else {
//                  if (closeTask.Subject == 'Wish Presentation not set' && presentationIdsSet.contains(closeTask.WhatId)) {
//                      closeTask.Status = 'Completed';
//                      updateTasks.add(closeTask);
//                  }
//              }
//          }
//      }
//      if (interViewOpenTaskIdsSet.size() > 0) {
//          for (Id parentId : interViewOpenTaskIdsSet) {
//              Task newSubTask = new Task();
//              newSubTask.Subject = 'Schedule Wish Presentation (add date, time, location name and address)';
//              if (interviewTaskParentIdMap.containsKey(parentId) && interviewTaskParentIdMap.get(parentId).Start_Date__c != null) {
//                  newSubTask.ActivityDate = interviewTaskParentIdMap.get(parentId).Start_Date__c - 30;
//              }
//              newSubTask.WhatId = parentId;
//              newSubTask.RecordTypeId = volunteerTaskRT;
//              newSubTask.IsVisibleInSelfService = true;
//              newSubTask.Task_Type__c = 'Wish Granting';
//              newSubTask.SystemGeneratedTask__c = true;
//              if (interviewTaskParentIdMap.containsKey(parentId)) {
//                  newSubTask.WhoId = interviewTaskParentIdMap.get(parentId).contactId;
//              }
//              if (CaseTeamMemberMap.containsKey(parentId)) {
//                  newSubTask.OwnerId = CaseTeamMemberMap.get(parentId);
//              }
//              updateTasks.add(newSubTask);
//          }
//          for (Task changeTaskDueDate : [
//                  SELECT Id, Status,Subject, WhatId
//                  FROM Task
//                  WHERE WhatId IN :interViewOpenTaskIdsSet AND Status != 'Completed' AND Task_Type__c = 'Wish Granting' AND Subject = 'Obtain itinerary and/or wish packet'
//                  LIMIT 50000
//          ]) {
//              changeTaskDueDate.ActivityDate = null;
//              updateTasks.add(changeTaskDueDate);
//          }
//      }
//      if (updateTasks.size() > 0) {
//          upsert updateTasks;
//      }
//      //}
//      /*catch(Exception e){
//          for(Case currCase : newCaseList){
//              currCase.addError(e.getMessage());
//          }
//      }*/
    }

    /*************************************************************************************
This mehod is used to close the conceptApproval Task when the Case status is updated.
****************************************************************************************/
    /**
     * WLP-428
     * Method only used to update tasks,
     * the tasks is deprecated as part of WLP-467
     */
//  public static void autoCloseTask(Set<Id> conceptApprovalTaskParentIdSet, List<Case> newCaseList) {
//      List<Task> closeTaskList = new List<Task>();
//      // try{
//      for (Task closeTask : [
//              SELECT Id
//              FROM Task
//              WHERE Subject = 'Wish concept approval' AND WhatId IN :conceptApprovalTaskParentIdSet
//              LIMIT 50000
//      ]) {
//          closeTask.Status = 'Completed';
//          closeTaskList.add(closeTask);
//      }
//      if (closeTaskList.size() > 0) {
//          update closeTaskList;
//      }
//      //}
//      /*catch(Exception e){
//          for(Case currCase : newCaseList){
//              currCase.addError(e.getMessage());
//          }
//      }*/
//  }
    /****************************************************************************************************************
1.Used to create 2 volunteer oppotunity when the Case status is changed to 'Ready to Assign'
2.Used to add Case related chapter volunteer manager into Case team with role name "Volunteer manager"
*****************************************************************************************************************/
    public static void createVolunteerOpportunity(Map<Id, Case> readyToAssignParentCaseMap, Set<Id> readtToAssignChapterIdSet) {
        RecursiveTriggerHandler.isFirstTime = false;
        Map<Id, Chapter_Role__c> chapterRoleMap = new Map<Id, Chapter_Role__c>();
        Map<Id, String> CaseTeamRoleNameMap = new Map<Id, String>();
        Map<String, Id> CaseTeamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> accountVolunteerManagerMap = new Map<Id, Id>(); //Used to hold Chater Account Id & its Volunteer Manager Id
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        List<CaseTeamMember> readyToAssignCaseTeamMemberList = new List<CaseTeamMember>();
        //try{
        for (Chapter_Role__c currentChapterRole : [
                SELECT ID, Chapter_Name__c, Chapter_Name__r.Name, Role_Name__r.Name
                FROM Chapter_Role__c
                WHERE Role_Name__r.Name = 'Wish Granter' AND Chapter_Name__c IN :readtToAssignChapterIdSet
                LIMIT 50000
        ]) {
            chapterRoleMap.put(currentChapterRole.Chapter_Name__c, currentChapterRole);
        }
        for (Account chaterAccountInfo : [
                SELECT Id, Name, Volunteer_Manager__c, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :chapterRecordTypeId AND Id IN :readtToAssignChapterIdSet AND Volunteer_Manager__c != NULL
                LIMIT 50000
        ]) {
            accountVolunteerManagerMap.put(chaterAccountInfo.Id, chaterAccountInfo.Volunteer_Manager__c);
        }
        for (CaseTeamRole CaseTeamRoleInfo : [
                SELECT Id, Name
                FROM CaseTeamRole
                LIMIT 50000
        ]) {
            CaseTeamRoleNameMap.put(CaseTeamRoleInfo.Id, CaseTeamRoleInfo.Name);
            CaseTeamRoleIdMap.put(CaseTeamRoleInfo.Name, CaseTeamRoleInfo.Id);
        }
        if (chapterRoleMap.size() > 0) {
            for (Case currentCase : readyToAssignParentCaseMap.Values()) {
                for (Integer i = 0; i <= 1; i++) {
                    if (chapterRoleMap.containsKey(currentCase.ChapterName__c)) {
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
            if (volunteerOppList.size() > 0) {
                insert volunteerOppList;
            }
        }

        for (Case changeCaseOwner : readyToAssignParentCaseMap.values()) {
            CaseTeamMember newCaseTeamMember = new CaseTeamMember();
            newCaseTeamMember.ParentId = changeCaseOwner.Id;
            if (CaseTeamRoleIdMap.containsKey('Volunteer Manager')) {
                newCaseTeamMember.TeamRoleId = CaseTeamRoleIdMap.get('Volunteer Manager');
            }
            newCaseTeamMember.MemberId = changeCaseOwner.OwnerId;
            readyToAssignCaseTeamMemberList.add(newCaseTeamMember);
        }
        // }
        /*catch(Exception e){
            for(Case currCase : readyToAssignParentCaseMap.values()){
                currCase.addError(e.getMessage());
            }
        }*/
    }

    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to update as there is no longer the concept of parent case.
     */
    /*********************************************************************************************
Open all sub Case when the status is changed from "DNQ", "Completed" and "Closed".
********************************************************************************************/
    Public static void UpdateSubCaseStatus(set<Id> ParentIdSet, List<Case> newCaseList) {
//      if (ParentIdSet.size() > 0) {
//          //try{
//          List<Case> CaseList = new List<Case>();
//          for (Case dbCase : [
//                  SELECT Id,ParentId,Status
//                  FROM Case
//                  WHERE ParentId IN:ParentIdSet
//                  LIMIT 50000
//          ]) {
//              If (ParentIdSet.contains(dbCase.ParentId)) {
//                  dbCase.status = 'Open';
//                  dbCase.Hidden_Close_Sub_Case__c = true;
//                  CaseList.add(dbCase);
//              }
//          }
//
//          if (CaseList.size() > 0)
//              update CaseList;
//          // }
//
//          /* catch(Exception e){
//               for(Case currCase : newCaseList){
//                   currCase.addError(e.getMessage());
//               }
//           } */
//      }
    }

    /********************************************************************************************
Used to update Case Team Role & to create new Case Team Member based on Case Status.
*********************************************************************************************/
    public static void CreateAndUpdateUserCaseTeamRole(Map<Id, Case> updateVolunteerManagerCaseTeamMap, Set<Id>volunteerManagerIdSet, Set<Id>wishCoordinatorIdSet) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Map<Id, String> teamRoleNameMap = new Map<Id, String>();
        Map<String, Id> teamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> ownerManagerMap = new Map<Id, Id>();
        Set<Id> CaseOwnerIdSet = new Set<Id>();
        //try{
        for (Case getOwner : updateVolunteerManagerCaseTeamMap.values()) {
            CaseOwnerIdSet.add(getOwner.OwnerId);
        }
        for (User userManagerInfo : [
                SELECT Id, ManagerId
                FROM User
                WHERE Id IN :CaseOwnerIdSet
                LIMIT 50000
        ]) {
            ownerManagerMap.put(userManagerInfo.Id, userManagerInfo.ManagerId);
        }
        for (CaseTeamRole CaseTeamRoleInfo : [
                SELECT Id, Name
                FROM CaseTeamRole
                LIMIT 50000
        ]) {
            teamRoleNameMap.put(CaseTeamRoleInfo.Id, CaseTeamRoleInfo.Name);
            teamRoleIdMap.put(CaseTeamRoleInfo.Name, CaseTeamRoleInfo.Id);
        }

        if (updateVolunteerManagerCaseTeamMap.size() > 0) {
            List<CaseTeamMember> inActiveAndActiveVMUpsertList = new List<CaseTeamMember>();
            Map<Id, List<CaseTeamMember>> CaseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
            Map<Id, Set<String>> dbCaseTeamMemberMap = new Map<Id, Set<String>>();
            Map<String, Id> activeCaseTeamMap = new Map<String, Id>();
            Map<String, Id> inActiveCaseTeamMap = new Map<String, Id>();
            Map<Id, Set<Id>> CaseTeamMap = new Map<Id, Set<Id>>();

            for (CaseTeamMember CaseTeamInfo : [
                    SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name
                    FROM CaseTeamMember
                    WHERE (TeamRole.Name = 'Volunteer Manager' OR TeamRole.Name = 'Volunteer Manager (Inactive)' OR TeamRole.Name = 'Wish Coordinator (Inactive)' OR TeamRole.Name = 'Wish Coordinator' OR TeamRole.Name = 'Intake Manager') AND ParentId IN :updateVolunteerManagerCaseTeamMap.keySet()
                    LIMIT 50000
            ]) {
                if (CaseTeamInfo.TeamRole.Name == 'Volunteer Manager' || CaseTeamInfo.TeamRole.Name == 'Wish Coordinator') {
                    activeCaseTeamMap.put(CaseTeamInfo.ParentId + '-' + CaseTeamInfo.MemberId, CaseTeamInfo.MemberId);
                } else if (CaseTeamInfo.TeamRole.Name == 'Volunteer Manager (Inactive)' || CaseTeamInfo.TeamRole.Name == 'Wish Coordinator (Inactive)') {
                    inActiveCaseTeamMap.put(CaseTeamInfo.ParentId + '-' + CaseTeamInfo.MemberId, CaseTeamInfo.MemberId);
                }
                if (CaseTeamMemberMap.containsKey(CaseTeamInfo.ParentId)) {
                    CaseTeamMemberMap.get(CaseTeamInfo.ParentId).add(CaseTeamInfo);
                    CaseTeamMap.get(CaseTeamInfo.ParentId).add(CaseTeamInfo.MemberId);
                } else {
                    CaseTeamMemberMap.put(CaseTeamInfo.ParentId, new List<CaseTeamMember>{
                            CaseTeamInfo
                    });
                    CaseTeamMap.put(CaseTeamInfo.ParentId, new Set<Id>{
                            CaseTeamInfo.MemberId
                    });
                }
            }
            for (Case updateTeamMember : updateVolunteerManagerCaseTeamMap.values()) {
                if (CaseTeamMemberMap.containsKey(updateTeamMember.Id)) {
                    if (CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                        for (CaseTeamMember CaseTeamMem : CaseTeamMemberMap.get(updateTeamMember.Id)) {
                            if (CaseTeamMem.TeamRole.Name == 'Volunteer Manager' || CaseTeamMem.TeamRole.Name == 'Wish Coordinator') {
                                if (volunteerManagerIdSet.contains(CaseTeamMem.ParentId) && CaseTeamMem.TeamRole.Name == 'Volunteer Manager') {
                                    CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                } else if (wishCoordinatorIdSet.contains(CaseTeamMem.ParentId) && CaseTeamMem.TeamRole.Name == 'Wish Coordinator') {
                                    CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                }
                            } else if (CaseTeamMem.TeamRole.Name == 'Volunteer Manager (Inactive)' || CaseTeamMem.TeamRole.Name == 'Wish Coordinator (Inactive)') {
                                if (inActiveCaseTeamMap.get(CaseTeamMem.ParentId + '-' + CaseTeamMem.MemberId) == updateTeamMember.OwnerId) {
                                    if (volunteerManagerIdSet.contains(CaseTeamMem.ParentId) && CaseTeamMem.TeamRole.Name == 'Volunteer Manager (Inactive)') {
                                        CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                        inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                    } else if (wishCoordinatorIdSet.contains(CaseTeamMem.ParentId) && CaseTeamMem.TeamRole.Name == 'Wish Coordinator (Inactive)') {
                                        CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                        inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                    }
                                }
                            }
                        }
                    } else {
                        for (CaseTeamMember CaseTeamMem : CaseTeamMemberMap.get(updateTeamMember.Id)) {
                            if (CaseTeamMem.TeamRole.Name == 'Volunteer Manager' && volunteerManagerIdSet.contains(CaseTeamMem.ParentId)) {
                                CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                            } else if (CaseTeamMem.TeamRole.Name == 'Wish Coordinator' && wishCoordinatorIdSet.contains(CaseTeamMem.ParentId)) {

                                CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                            }
                        }
                        CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                        newCaseTeamMember.ParentId = updateTeamMember.Id;
                        newCaseTeamMember.MemberId = updateTeamMember.OwnerId;

                        if (volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                            if (teamRoleIdMap.containsKey('Volunteer Manager')) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Volunteer Manager');
                                if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                    inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                }
                            }
                        } else if (wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                            if (teamRoleIdMap.containsKey('Wish Coordinator')) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                                if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                    inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                }
                                if (ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                    CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                    newCaseManagerTeamMember.ParentId = updateTeamMember.Id;
                                    newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                    newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                                    if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(ownerManagerMap.get(updateTeamMember.OwnerId))) {
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
                    if (volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                        if (teamRoleIdMap.containsKey('Volunteer Manager')) {
                            newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Volunteer Manager');
                            inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                        }
                    } else if (wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                        if (teamRoleIdMap.containsKey('Wish Coordinator')) {
                            newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Wish Coordinator');
                            inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                            if (ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
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
            if (inActiveAndActiveVMUpsertList.size() > 0) {
                upsert inActiveAndActiveVMUpsertList;
            }
        }
        //}
        /* catch(Exception e){
             for(Case currCase : updateVolunteerManagerCaseTeamMap.values()){
                 currCase.addError(e.getMessage());
             }
         }*/
    }
    /*****************************************************************************************
Used the change the access to Case team member when their Case team role is updated.
******************************************************************************************/
    public static void changeAccessPermission(Map<Id, Id> CaseContactMap, List<Case> newCaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Map<Id, String> CaseTeamRoleFilteredMap = new Map<Id, String>();
        Map<String, Id> CaseTeamRoleMap = new Map<String, Id>();
        //try{
        for (CaseTeamRole CaseTeamRoleInfo : [
                SELECT Id, Name
                FROM CaseTeamRole
        ]) {
            if (CaseTeamRoleInfo.Name.contains(' (Wish Closed)')) {
                CaseTeamRoleFilteredMap.put(CaseTeamRoleInfo.Id, CaseTeamRoleInfo.Name.remove(' (Wish Closed)'));

            } else {
                CaseTeamRoleMap.put(CaseTeamRoleInfo.Name, CaseTeamRoleInfo.Id);

            }
        }
        Map<Id, Case> parentCaseMap = new Map<Id, Case>([
                SELECT Id,ParentId,RecordTypeId
                FROM Case
                WHERE ParentId = :Null
                AND RecordTypeId = :wishRecordTypeId
                AND Id IN:CaseContactMap.KeySet()
                LIMIT 50000
        ]);
        Map<Id, List<CaseTeamMember>> CaseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
        for (CaseTeamMember CaseTeamMemberInfo : [
                SELECT Id, MemberId, TeamRoleId, ParentId
                FROM CaseTeamMember
                WHERE ParentId IN :CaseContactMap.keySet()
                LIMIT 50000
        ]) {
            if (CaseTeamMemberMap.containsKey(CaseTeamMemberInfo.ParentId)) {
                CaseTeamMemberMap.get(CaseTeamMemberInfo.ParentId).add(CaseTeamMemberInfo);

            } else {
                CaseTeamMemberMap.put(CaseTeamMemberInfo.ParentId, new List<CaseTeamMember>{
                        CaseTeamMemberInfo
                });

            }
        }

        if (CaseTeamMemberMap.size() > 0) {
            List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
            List<ContactShare> contactToShareList = new List<ContactShare>();
            for (Id CaseId : CaseContactMap.keySet()) {

                if (CaseTeamMemberMap.containsKey(CaseId)) {

                    for (CaseTeamMember CaseTeamRoleUpdate : CaseTeamMemberMap.get(CaseId)) {
                        if (CaseTeamRoleFilteredMap.containsKey(CaseTeamRoleUpdate.TeamRoleId)) {

                            if (CaseTeamRoleMap.containsKey(CaseTeamRoleFilteredMap.get(CaseTeamRoleUpdate.TeamRoleId))) {
                                CaseTeamRoleUpdate.TeamRoleId = CaseTeamRoleMap.get(CaseTeamRoleFilteredMap.get(CaseTeamRoleUpdate.TeamRoleId));
                                updateRoleList.add(CaseTeamRoleUpdate);
                                //Contact Share
                                if (parentCaseMap.containsKey(CaseId)) {
                                    ContactShare shareContact = new ContactShare();
                                    shareContact.ContactAccessLevel = 'Read';
                                    shareContact.ContactId = CaseContactMap.get(CaseId);
                                    shareContact.UserOrGroupId = CaseTeamRoleUpdate.MemberId;
                                    contactToShareList.add(shareContact);
                                }

                            }
                        }
                    }
                }
            }
            if (updateRoleList.size() > 0)
                update updateRoleList;

            if (contactToShareList.size() > 0) {
                insert contactToShareList;
            }
        }
        //}
        /*catch(Exception e){
            for(Case currCase : newCaseList){
                currCase.addError(e.getMessage());
            }
        } */
    }

    /***************************************************************************************************
Used to create Activities for WishPlanning & Anticipation Wish.
****************************************************************************************************/
    /*WLP-467 remove automated task creation */
//  public static void wishPlaningAnticipationTaskCreation(Map<Id, Case> wishPlanningAndGrantinTaskParentMap) {
//      RecursiveTriggerHandler.blockCaseLockRecursive = false;
//      Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
//      Id staffTaskRT = Constant_AC.STAFF_TASK_RT_ID;
//      Date todayDate;
//      List<Task> planingAnticipationTaskList = new List<Task>();
//      Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
//      Map<Id, Id> chapterCoordinatorMap = new Map<Id, Id>();
//      /**
//       * JIRA: WLP-286
//       * Author: Gustavo Mayer
//       * Update: Unused map
//       */
////        Map<Id, Case> wishPlaningAnticipationSubCaseMap = new Map<id, Case>();
////        Integer monthCount = 0;
//      //try{
////        for (Case planningCaseInfo : [
////                SELECT Id
////                FROM Case
////                WHERE ParentId IN :wishPlanningAndGrantinTaskParentMap.keySet() AND RecordTypeId = :wishRecordTypeId
////                LIMIT 50000
////        ]) {
////            wishPlaningAnticipationSubCaseMap.put(planningCaseInfo.Id, planningCaseInfo);
////        }
//
//      for (Account chapterInfo : [
//              SELECT Id, Wish_Co_ordinator__c
//              FROM Account
//              WHERE RecordTypeId = :chapterRecordTypeId
//              LIMIT 50000
//      ]) {
//          chapterCoordinatorMap.put(chapterInfo.Id, chapterInfo.Wish_Co_ordinator__c);
//      }
//      for (Chapter_Action_Track__c getTask : [
//              SELECT Id, Task_Name__c, RecordType.Name,Chapter_Name__c, Weeks__c, Months__c,Wish_type__c, Sort_Order__c
//              FROM Chapter_Action_Track__c
//              ORDER BY Sort_Order__c ASC
//              LIMIT 50000
//      ]) {
//          if (chapterActionMap.containskey(getTask.Wish_type__c)) {
//              chapterActionMap.get(getTask.Wish_type__c).add(getTask);
//          } else {
//              chapterActionMap.put(getTask.Wish_type__c, new List<Chapter_Action_Track__c>{
//                      getTask
//              });
//          }
//      }
//
//      for (Case currCase : wishPlanningAndGrantinTaskParentMap.values()) {
//
//          if (chapterActionMap.containsKey(currCase.Wish_type__c)) {
//              for (Chapter_Action_Track__c currActionTrack : chapterActionMap.get(currCase.Wish_type__c)) {
//                  if (currActionTrack.Chapter_Name__c == currCase.ChapterName__c) {
//                      Task newTask = new Task();
//                      newTask.WhatId = currCase.Id;
//                      newTask.Subject = currActionTrack.Task_Name__c;
//                      newTask.SystemGeneratedTask__c = true;
//                      newTask.WhoId = currCase.ContactId;
//                      newTask.OwnerId = currCase.OwnerId;
//                      newTask.RecordTypeId = staffTaskRT;
//                      newTask.Task_Type__c = currActionTrack.RecordType.Name;
//                      Integer months = Integer.valueOf(currActionTrack.Months__c);
//                      Integer Weeks = Integer.valueOf(currActionTrack.Weeks__c);
//                      Integer dayCalc;
//                      if (months == Null) {
//                          months = 0;
//                      }
//                      if (Weeks == Null) {
//                          Weeks = 0;
//                          dayCalc = 0;
//                      } else {
//                          dayCalc = Weeks * 7;
//                      }
//
//                      if (currActionTrack.Months__c != null && currActionTrack.Months__c != 0 && currCase.Start_Date__c != null) {
//                          if (dayCalc != null) {
//                              todayDate = System.today().addDays(dayCalc);
//                          } else {
//                              todayDate = System.today();
//                          }
//                          if (currCase.Start_Date__c > todayDate.addmonths(months)) {
//                              newTask.ActivityDate = currCase.Start_Date__c.addMonths(-months).addDays(dayCalc);
//                          } else {
//                              newTask.ActivityDate = Date.Today();
//                          }
//                      } else if ((currActionTrack.Months__c == null || currActionTrack.Months__c == 0) && (currCase.Start_Date__c != null)) {
//                          if (dayCalc != null) {
//                              todayDate = System.today().addDays(dayCalc);
//                          }
//                          if (currCase.Start_Date__c > todayDate) {
//                              if (currActionTrack.Task_Name__c == 'Create Wish Receipt') {
//                                  newTask.ActivityDate = currCase.Start_Date__c.addDays(dayCalc);
//                              } else {
//                                  newTask.ActivityDate = currCase.Start_Date__c.addDays(-dayCalc);
//                              }
//
//                          } else {
//                              newTask.ActivityDate = Date.Today();
//                          }
//                      } else {
//
//                      }
//                      planingAnticipationTaskList.add(newTask);
//                  }
//              }
//          } else if (chapterActionMap.containsKey('Other')) {
//              for (Chapter_Action_Track__c currActionTrack : chapterActionMap.get('Other')) {
//                  if (currActionTrack.Chapter_Name__c == currCase.ChapterName__c) {
//                      Task newTask = new Task();
//                      newTask.WhatId = currCase.Id;
//                      newTask.Subject = currActionTrack.Task_Name__c;
//                      newTask.SystemGeneratedTask__c = true;
//                      newTask.WhoId = currCase.ContactId;
//                      newTask.OwnerId = currCase.OwnerId;
//                      newTask.RecordTypeId = staffTaskRT;
//                      newTask.Task_Type__c = currActionTrack.RecordType.Name;
//                      Integer months = Integer.valueOf(currActionTrack.Months__c);
//                      Integer Weeks = Integer.valueOf(currActionTrack.Weeks__c);
//                      Integer dayCalc;
//                      if (months == Null) {
//                          months = 0;
//                      }
//                      if (Weeks == Null) {
//                          Weeks = 0;
//                          dayCalc = 0;
//                      } else {
//                          dayCalc = Weeks * 7;
//                      }
//
//                      if (currActionTrack.Months__c != null && currActionTrack.Months__c != 0 && currCase.Start_Date__c != null) {
//                          if (dayCalc != null) {
//                              todayDate = System.today().addDays(dayCalc);
//                          } else {
//                              todayDate = System.today();
//                          }
//                          if (currCase.Start_Date__c > todayDate.addmonths(months)) {
//                              newTask.ActivityDate = currCase.Start_Date__c.addMonths(-months).addDays(dayCalc);
//                          } else {
//                              newTask.ActivityDate = Date.Today();
//                          }
//                      } else if ((currActionTrack.Months__c == null || currActionTrack.Months__c == 0) && (currCase.Start_Date__c != null)) {
//                          if (dayCalc != null) {
//                              todayDate = System.today().addDays(dayCalc);
//                          }
//                          if (currCase.Start_Date__c > todayDate) {
//                              if (currActionTrack.Task_Name__c == 'Create Wish Receipt') {
//                                  newTask.ActivityDate = currCase.Start_Date__c.addDays(dayCalc);
//                              } else {
//                                  newTask.ActivityDate = currCase.Start_Date__c.addDays(-dayCalc);
//                              }
//                          } else {
//                              newTask.ActivityDate = Date.Today();
//                          }
//                      } else {
//
//                      }
//                      planingAnticipationTaskList.add(newTask);
//                  }
//              }
//          }
//      }
//      if (planingAnticipationTaskList.size() > 0) {
//          insert planingAnticipationTaskList;
//      }
//      //}
//      /*catch(Exception e){
//          for(Case currCase : wishPlanningAndGrantinTaskParentMap.values()){
//              currCase.addError(e.getMessage());
//          }
//      }*/
//  }
    /*******************************************************************************************************
This method is used to create wish planing and Granting task. when the parent Case status is updated.
***********************************************************************************************************/
    /*WLP-467 remove automated task creation */
//    public static void wishGrantedSubCaseTaskCreation(Map<Id, Case> parentWishMap) {
//      RecursiveTriggerHandler.blockCaseLockRecursive = false;
//      Map<Id, Date> parentMap = new Map<Id, Date>();
//      Map<Id, Id> parentContactIdMap = new map<Id, Id>();
//      Map<Id, Id> CaseTeamMemberMap = new Map<Id, Id>();
//      List<Task> wishGrantedTaskList = new List<Task>();
//
//      //try{
//      for (Case parentCaseDetail : parentWishMap.values()) {
//          parentMap.put(parentCaseDetail.Id, parentCaseDetail.Start_Date__c);
//          parentContactIdMap.put(parentCaseDetail.Id, parentCaseDetail.ContactId);
//      }
//
//      //Used to get Case and its Case team members
//      for (CaseTeamMember CaseTeamMem : [
//              SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name
//              FROM CaseTeamMember
//              WHERE ParentId IN :parentWishMap.keySet() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor')
//              ORDER BY CreatedDate ASC
//              LIMIT 50000
//      ]) {
//          if (!CaseTeamMemberMap.containsKey(CaseTeamMem.ParentId)) {
//              CaseTeamMemberMap.put(CaseTeamMem.ParentId, CaseTeamMem.MemberId);
//          }
//      }
//
//      //List<WishGrantedSubCaseTaskList__c> subTaskList = WishGrantedSubCaseTaskList__c.getAll().values();
//      List<Chapter_Action_Track__c> subTaskList = [
//              SELECT Id, Task_Name__c, RecordType.Name, Due_Days__c, Sort_Order__c, Description__c
//              FROM Chapter_Action_Track__c
//              WHERE RecordTypeId = :wishGrantTaskRT
//              LIMIT 50000
//      ];
//      if (subTaskList.size() > 0) {
//          for (Case createTasks : parentWishMap.values()) {
//              for (Chapter_Action_Track__c createSubTask : subTaskList) {
//                  Task newSubTask = new Task();
//                  newSubTask.Subject = createSubTask.Task_Name__c;
//                  if (parentMap.containsKey(createTasks.Id) && parentMap.get(createTasks.Id) != null) {
//                      if (createSubTask.Task_Name__c == 'Schedule Wish Presentation (add date, time, location name and address)' || createSubTask.Task_Name__c == 'Secure in-kind donations for wish presentation') {
//                          newSubTask.ActivityDate = parentMap.get(createTasks.Id) + Integer.valueOf(createSubTask.Due_Days__c);
//                      } else {
//
//                      }
//                  }
//                  newSubTask.Description = createSubTask.Description__c;
//                  newSubTask.WhatId = createTasks.Id;
//                  newSubTask.IsVisibleInSelfService = true;
//                  newSubTask.SystemGeneratedTask__c = true;
//                  newSubTask.RecordTypeId = volunteerTaskRT;
//                  newSubTask.Task_Type__c = createSubTask.RecordType.Name;
//                  if (parentContactIdMap.containsKey(createTasks.Id)) {
//                      newSubTask.WhoId = parentContactIdMap.get(createTasks.Id);
//                  }
//                  if (CaseTeamMemberMap.containsKey(createTasks.Id)) {
//                      newSubTask.OwnerId = CaseTeamMemberMap.get(createTasks.Id);
//                  }
//                  wishGrantedTaskList.add(newSubTask);
//              }
//          }
//          if (wishGrantedTaskList.size() > 0) {
//              insert wishGrantedTaskList;
//          }
//      }
//      //}
//      /* catch(Exception e){
//           for(Case currCase : parentWishMap.values()){
//               currCase.addError(e.getMessage());
//           }
//       } */
//  }

    /***************************************************************************************
This method is used to update the child Case owner when parent Case owner is updated.
****************************************************************************************/
    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to update as there is no longer the concept of parent case.
     */
//  public static void changeChildCasesOwner(Map<Id, Id> newCaseOwnerMap, List<Case> newCaseList) {
//      RecursiveTriggerHandler.blockCaseLockRecursive = false;
//      List<Case> childCaseList = new List<Case>();
//      //try{
//      for (Case childCase : [
//              SELECT Id, OwnerId, ParentId
//              FROM Case
//              WHERE ParentId IN :newCaseOwnerMap.keySet()
//              AND RecordTypeId != :wishRecordTypeId
//              LIMIT 50000
//      ]) {
//          if (childCase.OwnerId != newCaseOwnerMap.get(childCase.ParentId)) {
//              childCase.OwnerId = newCaseOwnerMap.get(childCase.ParentId);
//              childCaseList.add(childCase);
//          }
//      }
//      if (childCaseList.size() > 0) {
//          update childCaseList;
//      }
//      //}
//      /* catch(Exception e){
//           for(Case currCase : newCaseList){
//               currCase.addError(e.getMessage());
//           }
//       } */
//  }

    /**************************************************************************************************
This method is used create wish clearance task when paren Case Receive Date and End Date is changed.
*******************************************************************************************************/
    /*WLP-467 remove automated task creation */
//    public static void wishClearanceTask(Map<Id, Case> wishClearanceMap, Set<Id> newWishClearanceSet, Set<Id> newMedicalSummarySet, Set<Id> newMedicalWishClearanceSet) {
//      List<Task> taskToUpdateList = new List<Task>();
//      Set<Task> newTaskSet = new Set<Task>();
//      Map<String, Task> taskToUpdateMap = new Map<String, Task>();
//      //try{
//      for (Task checkClearanceTask : [
//              SELECT Id, Subject, WhatId, OwnerId, ActivityDate
//              FROM Task
//              WHERE isClosed = false AND WhatId IN :wishClearanceMap.keySet() AND (Subject = 'New wish clearance needed' OR Subject = 'New medical summary needed' OR Subject = 'New wish clearance needed')
//              LIMIT 50000
//      ]) {
//          taskToUpdateMap.put(checkClearanceTask.WhatId + '-' + checkClearanceTask.Subject, checkClearanceTask);
//      }
//      if (newWishClearanceSet.size() > 0) {
//          for (Id newWishClearanceTask : newWishClearanceSet) {
//              if (taskToUpdateMap.containsKey(newWishClearanceTask + '-' + 'New wish clearance needed')) {
//                  taskToUpdateMap.get(newWishClearanceTask + '-' + 'New wish clearance needed').ActivityDate = Date.today() + 3;
//                  taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask + '-' + 'New wish clearance needed'));
//              } else {
//                  Task newTask = new Task();
//                  newTask.ActivityDate = Date.today() + 3;
//                  newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
//                  newTask.Subject = 'New wish clearance needed';
//                  newTask.WhoId = wishClearanceMap.get(newWishClearanceTask).ContactId;
//                  newTask.SystemGeneratedTask__c = TRUE;
//                  newTask.WhatId = newWishClearanceTask;
//                  taskToUpdateList.add(newTask);
//              }
//          }
//      }
//      if (newMedicalSummarySet.size() > 0) {
//          for (Id newWishClearanceTask : newMedicalSummarySet) {
//              if (taskToUpdateMap.containsKey(newWishClearanceTask + '-' + 'New medical summary needed')) {
//                  taskToUpdateMap.get(newWishClearanceTask + '-' + 'New medical summary needed').ActivityDate = Date.today() + 3;
//                  taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask + '-' + 'New medical summary needed'));
//              } else {
//                  Task newTask = new Task();
//                  newTask.ActivityDate = Date.today() + 3;
//                  newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
//                  newTask.Subject = 'New medical summary needed';
//                  newTask.SystemGeneratedTask__c = TRUE;
//                  newTask.WhoId = wishClearanceMap.get(newWishClearanceTask).ContactId;
//                  newTask.WhatId = newWishClearanceTask;
//                  taskToUpdateList.add(newTask);
//              }
//          }
//      }
//      if (newMedicalWishClearanceSet.size() > 0) {
//          for (Id newWishClearanceTask : newMedicalWishClearanceSet) {
//              if (taskToUpdateMap.containsKey(newWishClearanceTask + '-' + 'New wish clearance needed')) {
//                  taskToUpdateMap.get(newWishClearanceTask + '-' + 'New wish clearance needed').ActivityDate = Date.today() + 3;
//                  taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask + '-' + 'New wish clearance needed'));
//              } else {
//                  Task newTask = new Task();
//                  newTask.ActivityDate = Date.today() + 3;
//                  newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
//                  newTask.Subject = 'New wish clearance needed';
//                  newTask.WhatId = newWishClearanceTask;
//                  newTask.SystemGeneratedTask__c = TRUE;
//                  newTask.WhoId = wishClearanceMap.get(newWishClearanceTask).ContactId;
//                  taskToUpdateList.add(newTask);
//              }
//          }
//      }
//      if (taskToUpdateList.size() > 0) {
//          newTaskSet.addAll(taskToUpdateList);
//          if (newTaskSet.size() > 0) {
//              taskToUpdateList.clear();
//              taskToUpdateList.addAll(newTaskSet);
//              if (taskToUpdateList.size() > 0) {
//                  upsert taskToUpdateList;
//              }
//          }
//      }
//      //}
//      /*catch(Exception e){
//          for(Case currCase : wishClearanceMap.values()){
//              currCase.addError(e.getMessage());
//          }
//      } */
//  }

    /********************************************************************************************************************************
    //1.Used to create list of task for volunteers when the wish determination Case is created.
    //2.Based on "Wish Planning" recordtype, we are pulling the list of task which are stored under Chapter Action Track" object.
    //3.Task are assigned to the volunteer user who got initially approved for the Case with the "Wish Granter" role.
    ********************************************************************************************************************************/
    /*WLP-467 remove automated task creation */
//    public static void wishDeterminationSubCaseTaskCreation(Map<Id, Case> parentWishInfoMap) {
//      RecursiveTriggerHandler.blockCaseLockRecursive = false;
//      Map<Id, Id> CaseTeamMemberMap = new Map<Id, Id>();
//      List<Task> wishDeterminationTaskList = new List<Task>();
//      List<Task> birthDayTaskList = new List<Task>();
//      Map<Id, Id> parentContactIdMap = new map<Id, Id>();
//      //Used to get Case and its Case team members.
//      //try{
//      for (CaseTeamMember CaseTeamMem : [
//              SELECT Id, ParentId, MemberId, TeamRoleId
//              FROM CaseTeamMember
//              WHERE ParentId IN :parentWishInfoMap.Keyset() AND (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter Mentor')
//              ORDER BY CreatedDate ASC
//              LIMIT 50000
//      ]) {
//          if (!CaseTeamMemberMap.containsKey(CaseTeamMem.ParentId)) {
//              CaseTeamMemberMap.put(CaseTeamMem.ParentId, CaseTeamMem.MemberId);
//          }
//      }
//      for (Case parentCaseInfo : parentWishInfoMap.values()) {
//          parentContactIdMap.put(parentCaseInfo.Id, parentCaseInfo.ContactId);
//      }
//      for (Task birthdayTaskInfo : [
//              SELECT Id, WhatId, Subject, OwnerId
//              FROM Task
//              WHERE Subject = 'Wish Child Birthday Reminder' AND WhatId IN :parentWishInfoMap.keySet() AND isClosed = false
//              LIMIT 50000
//      ]) {
//          // if(CaseTeamMemberMap.containsKey(birthdayTaskInfo.WhatId)) {
//          birthdayTaskInfo.OwnerId = CaseTeamMemberMap.get(birthdayTaskInfo.WhatId);
//          birthdayTaskInfo.RecordTypeId = volunteerTaskRT;
//          birthDayTaskList.add(birthdayTaskInfo);
//          // }
//      }
//      if (birthDayTaskList.size() > 0) {
//          update birthDayTaskList;
//      }
//      //Used get all chapter action track for wish determination Case
//      List<Chapter_Action_Track__c> subTaskList = [
//              SELECT Id, Task_Name__c,RecordType.Name, Description__c, Due_Days__c, Sort_Order__c
//              FROM Chapter_Action_Track__c
//              WHERE RecordtypeId = :determinationChapterActionRT
//              LIMIT 50000
//      ];
//      if (subTaskList.size() > 0) {
//          for (Case createTasks : parentWishInfoMap.values()) {
//              for (Chapter_Action_Track__c createSubTask : subTaskList) {
//                  Task newSubTask = new Task();
//                  // If(CaseTeamMemberMap.ContainsKey(createTasks.Id)){
//                  newSubTask.Subject = createSubTask.Task_Name__c;
//                  if (createSubTask.Due_Days__c != null) {
//                      newSubTask.ActivityDate = Date.Today() + Integer.valueOf(createSubTask.Due_Days__c);
//                  }
//                  newSubTask.WhatId = createTasks.Id;
//                  newSubTask.RecordTypeId = volunteerTaskRT;
//                  newSubTask.IsVisibleInSelfService = true;
//                  newSubTask.Task_Type__c = createSubTask.RecordType.Name;
//                  newSubTask.WhoId = createTasks.ContactId;
//                  newSubTask.Description = createSubTask.Description__c;
//                  newSubTask.SystemGeneratedTask__c = true;
//                  if (CaseTeamMemberMap.containsKey(createTasks.Id)) {
//                      newSubTask.OwnerId = CaseTeamMemberMap.get(createTasks.Id);
//                  }
//                  wishDeterminationTaskList.add(newSubTask);
//                  // }
//              }
//          }
//          if (wishDeterminationTaskList.size() > 0) {
//              insert wishDeterminationTaskList;
//          }
//      }
//      // }
//      /*catch(Exception e){
//          for(Case currCase : parentWishInfoMap.values()){
//              currCase.addError(e.getMessage());
//          }
//      } */
//  }

    /**
     * JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Sub case conversion to the single Wish Case,
     * no need to update as there is no longer the concept of parent case.
     */
    /********************************************************************************************************************************
This method is used to update the wish receipt field in parent Case when Granting Case is updated.
**********************************************************************************************************************************/
//  public static void UpdateWishRecipetItems(Map<Id, String> wishReceiptMap, List<Case> newCaseList) {
//      list<Case> wishReceiptCaseList = new list<Case>();
//      //try{
//      if (wishReceiptMap.size() > 0) {
//          for (Case currentCase : [
//                  SELECT Id,Wish_Receipt_Items__c
//                  FROM Case
//                  WHERE ID IN:wishReceiptMap.keySet()
//                  LIMIT 50000
//          ]) {
//              if (wishReceiptMap.containsKey(currentCase.id)) {
//                  currentCase.Wish_Receipt_Items__c = wishReceiptMap.get(currentCase.id);
//                  wishReceiptCaseList.add(currentCase);
//              }
//          }
//      }
//      if (wishReceiptCaseList.size() > 0) {
//          update wishReceiptCaseList;
//      }
//      //}
//      /* catch(Exception e){
//           for(Case currCase : newCaseList){
//               currCase.addError(e.getMessage());
//           }
//       }*/
//  }

    /****************************************************************************************************
Used to delete Wishplanning & Anticipation open activities if wish type is changed.
****************************************************************************************************/
    /**
     * WLP-428
     * Method only used to update tasks,
     * the tasks is deprecated as part of WLP-467
     */
    public static void deleteAnticipationTask(Map<Id, Case> caseIdsMap, Set<String> newWishTypeSet) {
//      RecursiveTriggerHandler.blockCaseLockRecursive = false;
//      List<Task> deleteOpenAnticipationTask = new List<Task>();
//      for (Task oldAnticipationTask : [
//              SELECT Id
//              FROM Task
//              WHERE WhatId IN :caseIdsMap.keySet()
//              AND Task_Type__c = 'Wish Planning'
//              AND IsClosed = FALSE
//              LIMIT 50000
//      ]) {
//          deleteOpenAnticipationTask.add(oldAnticipationTask);
//      }
//      if (deleteOpenAnticipationTask.size() > 0) {
//          delete deleteOpenAnticipationTask;
//      }
        /**
         * JIRA: WLP-286
         * Author: Gustavo Mayer
         * Update: Sub case conversion to the single Wish Case,
         * changing to reference Id Wish and remove query on ParentId
         */
//      Map<Id, Case> planningCaseMap = new Map<Id, Case>();
//      for (Case getAnticipationCase : [
//              SELECT Id, ParentId, RecordTypeId
//              FROM Case
//              WHERE RecordTypeId = :wishRecordTypeId
//              AND IsClosed = FALSE
//              AND Id IN :CaseIdsMap.keySet()
//              LIMIT 50000
//      ]) {
//          planningCaseMap.put(getAnticipationCase.Id, getAnticipationCase);
//      }
//      if (planningCaseMap.size() > 0) {
        /*WLP-467 remove automated task creation*/
//      wishPlaningAnticipationTaskCreation(caseIdsMap);
//      }
    }

    /******************************************************************************************************************
    Used to update WishPlanning & Anticipation Open activities due dates if the anticipated date is updated.
    *******************************************************************************************************************/
    /**
     * WLP-428
     * Method only used to update tasks,
     * the tasks is deprecated as part of WLP-467
     */
    public static void updateAnticipationTasks(Map<Id, Case> updateAniticipationTaskMap,
            Map<Id, Case> removeAniticipationTaskMap, Set<String> wishTypes) {
//      List<Task> taskListToUpdate = new List<Task>();
//      Integer months;
//      Integer weeks;
//      Integer dayCalc;
//      Date todayDate;
//      //try{
//      if (removeAniticipationTaskMap.size() > 0) {
//          for (Task updateTask : [
//                  SELECT Id, ActivityDate
//                  FROM Task
//                  WHERE Task_Type__c = 'Wish Planning'
//                  AND WhatId IN :removeAniticipationTaskMap.keySet()
//                  AND IsClosed != TRUE
//                  LIMIT 50000
//          ]) {
//              Task toUpdate = new Task();
//              toUpdate.Id = updateTask.Id;
//              toUpdate.ActivityDate = Null;
//              taskListToUpdate.add(toUpdate);
//          }
//      }
//
//      if (updateAniticipationTaskMap.size() > 0) {
//
//          Map<String, Chapter_Action_Track__c> chapterMap = new Map<String, Chapter_Action_Track__c>();
//
//          for (Chapter_Action_Track__c getTask : [
//                  SELECT Id, Task_Name__c, Chapter_Name__c, Weeks__c, Months__c,Wish_type__c, Sort_Order__c
//                  FROM Chapter_Action_Track__c
//                  ORDER BY Sort_Order__c ASC
//                  LIMIT 50000
//          ]) {
//              chapterMap.put(getTask.Task_Name__c + '-' + getTask.Chapter_Name__c, getTask);
//          }
//
//          for (Task updateTask : [
//                  SELECT Id,ActivityDate,WhatId,Subject
//                  FROM Task
//                  WHERE Task_Type__c = 'Wish Planning'
//                  AND WhatId IN :updateAniticipationTaskMap.keySet()
//                  AND IsClosed != TRUE
//                  LIMIT 50000
//          ]) {
//              if (updateAniticipationTaskMap.containsKey(updateTask.whatId) && chapterMap.containsKey(updateTask.Subject + '-' + updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c)) {
//                  Task toUpdate = new Task();
//                  toUpdate.Id = updateTask.Id;
//                  if (chapterMap.containsKey(updateTask.Subject + '-' + updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c)) {
//                      months = Integer.valueOf(chapterMap.get(updateTask.Subject + '-' + updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c).months__c);
//                      weeks = Integer.valueOf(chapterMap.get(updateTask.Subject + '-' + updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c).Weeks__c);
//
//                      if (months == Null) {
//                          months = 0;
//                      }
//                      if (Weeks == Null) {
//                          Weeks = 0;
//                          dayCalc = 0;
//                      } else {
//                          dayCalc = Weeks * 7;
//                      }
//                      if (months != null && months != 0) {
//                          if (dayCalc != null) {
//                              todayDate = System.today().addDays(dayCalc);
//                          } else {
//                              todayDate = System.today();
//                          }
//
//                          if (updateAniticipationTaskMap.get(updateTask.whatId).Start_Date__c > todayDate.addmonths(months)) {
//                              toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Start_Date__c.addMonths(-months).addDays(dayCalc);
//                          } else {
//                              toUpdate.ActivityDate = Date.Today();
//                          }
//                      } else if (months == null || months == 0) {
//                          if (dayCalc != null) {
//                              todayDate = System.today().addDays(dayCalc);
//                          }
//                          if (updateAniticipationTaskMap.get(updateTask.whatId).Start_Date__c > todayDate) {
//                              if (updateTask.Subject == 'Create Wish Receipt') {
//                                  toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Start_Date__c.addDays(dayCalc);
//                              } else {
//                                  toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Start_Date__c.addDays(-dayCalc);
//                              }
//
//                          } else {
//                              toUpdate.ActivityDate = Date.Today();
//                          }
//                      }
//                  }
//
//                  taskListToUpdate.add(toUpdate);
//              }
//          }
//      }
//
//      for (Task getGrantTask : [
//              SELECT Id, WhatId, RecordTypeId, Subject
//              FROM Task
//              WHERE WhatId IN :updateAniticipationTaskMap.keySet()
//              AND (Subject = 'Schedule Wish Presentation (add date, time, location name and address)'
//              OR Subject = 'Secure in-kind donations for wish presentation')
//              AND RecordTypeId = :wishRecordTypeId
//              LIMIT 50000
//      ]) {
//          getGrantTask.ActivityDate = updateAniticipationTaskMap.get(getGrantTask.whatId).Start_Date__c - 30;
//          taskListToUpdate.add(getGrantTask);
//      }
//      if (taskListToUpdate.size() > 0) {
//          update taskListToUpdate;
//      }
//      //}
//      /*catch(Exception e){
//          for(Case currCase : updateAniticipationTaskMap.values()){
//              currCase.addError(e.getMessage());
//          }
//      } */
    }

    /*************************************************************************************************
To update the task as Abandoned.
**************************************************************************************************/
    /**
     * WLP-428
     * Method only used to update tasks,
     * the tasks is deprecated as part of WLP-467
     */
    public static void UpdateTasksAsAbondoned(Map<Id, Case> UpdateAllOpenTasks) {
//      List<Task> updateTasksList = new List<Task>();
//      //try{
//      for (Task currTask : [
//              SELECT id,WhatId
//              FROM TASK
//              WHERE WhatId IN :UpdateAllOpenTasks.keyset() AND isClosed = false
//              LIMIT 50000
//      ]) {
//          Task updateTask = new Task();
//          updateTask.id = currTask.id;
//          updateTask.Status = 'Abandoned';
//          updateTasksList.add(updateTask);
//      }
//      if (updateTasksList.size() > 0)
//          update updateTasksList;
//      //}
//      /*catch(Exception e){
//          for(Case currCase : UpdateAllOpenTasks.values()){
//              currCase.addError(e.getMessage());
//          }
//      }*/
    }

    /*************************************************************************************************
This method is used to send the attachment to the medical proff contact. - Commented as per IME 74
**************************************************************************************************/
    /*public static void sendEmailToNationalMACTeam(List<Case> diagnosisCaseList) {
        Set<Id> leadIdSet = new Set<Id>();
        Map<Id, List<Attachment>> docusignAttachmentMap = new Map<Id, List<Attachment>>();
        Map<Id, Id> CaseLeadMap = new map<Id, Id>();
        Set<Id> parentAttachmentIdSet = new Set<Id>();
        List<Case> diagnosisVerificationList = new List<Case>();
        //try{
            for(Case diagnosisCase : diagnosisCaseList) {
                CaseLeadMap.put(diagnosisCase.Id, diagnosisCase.Lead__c);
                leadIdSet.add(diagnosisCase.Lead__c);
                diagnosisVerificationList.add(diagnosisCase);
            }

            if(leadIdSet.Size() > 0) {
                for(dsfs__DocuSign_Status__c docusignStatusCheck : [SELECT Id, dsfs__Envelope_Status__c, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Completed' AND dsfs__Lead__c IN :  leadIdSet]) {
                    parentAttachmentIdSet.add(docusignStatusCheck.Id);
                }
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
            for(Case currCase : diagnosisCaseList){
                currCase.addError(e.getMessage());
            }
        }
    }*/

    /*************************************************************************************************
Used to update the role for Volunteer user to Wish, when the parent wish is completed.
*************************************************************************************************/
    public static void revokeWishPermissionForVolunteers(Set<Id> parentWishIds, Set<Id> revokingContactIdSet) {
        Map<String, Id> CaseTeamRoleMap = new Map<String, Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<ContactShare> removeContactShareList = new List<ContactShare>();
        List<CaseTeamMember> updateTeamRole = new List<CaseTeamMember>();
        List<Case> childCaseList = new List<Case>();
//      Set<Id> childWishIdsSet = new Set<Id>();
        Set<Id> memberIdSet = new Set<Id>();
        Set<Id> volunteerUsersSet = new Set<Id>();
        List<Case> closeCaseList = new List<Case>();
        RecursiveTriggerHandler.allowToEditRecord = True;
        //try{
        for (CaseTeamRole CaseRole : [
                SELECT Id, Name
                FROM CaseTeamRole
                LIMIT 50000
        ]) {
            if (CaseRole.Name.contains('Wish Closed')) {
                CaseTeamRoleMap.put(CaseRole.Name, CaseRole.Id);
            }
        }
        /**
         * JIRA: WLP-286
         * Author: Gustavo Mayer
         * Update: Sub case conversion to the single Wish Case,
         * no need to find the child case as there is no longer the concept of parent case.
         */
//      for (Case childCase : [
//              SELECT Id
//              FROM Case
//              WHERE ParentId IN :parentWishIds
//              AND RecordTypeId != :wishRecordTypeId
//              LIMIT 50000
//      ]) {
//          childWishIdsSet.add(childCase.Id);
//          childCaseList.add(childCase);
//      }

        /**
         * JIRA: WLP-286
         * Author: Gustavo Mayer
         * Update: Sub case conversion to the single Wish Case,
         * no need to find the child case as there is no longer the concept of parent case.
         */
        List<CaseTeamMember> caseTeamMemberList = [
                SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId
                FROM CaseTeamMember
                WHERE (ParentId IN :parentWishIds)
//              OR ParentId IN :childWishIdsSet)
                LIMIT 50000
        ];
        if (caseTeamMemberList.size() > 0) {
            for (CaseTeamMember getCaseTeamMember : caseTeamMemberList) {
                memberIdSet.add(getCaseTeamMember.MemberId);
            }
            if (memberIdSet.size() > 0) {
                for (User getVolunteerUser : [
                        SELECT Id, ContactId
                        FROM User
                        WHERE ContactId != NULL
                        AND Id IN :memberIdSet
                        LIMIT 50000
                ]) {
                    volunteerUsersSet.add(getVolunteerUser.Id);
                }
            }

            /**
             * JIRA: WLP-286
             * Author: Gustavo Mayer
             * Update: Sub case conversion to the single Wish Case,
             * no need to find the child case as there is no longer the concept of parent case.
             */
            for (CaseTeamMember getCaseTeamMember : [
                    SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId
                    FROM CaseTeamMember
                    WHERE (ParentId IN :parentWishIds)
//                  OR ParentId IN :childWishIdsSet)
                    AND (Member.IsActive = TRUE)
                    LIMIT 50000
            ]) {
                String roleName = getCaseTeamMember.TeamRole.Name + ' (Wish Closed)';
                if (CaseTeamRoleMap.size() > 0 && CaseTeamRoleMap.containsKey(roleName) && volunteerUsersSet.contains(getCaseTeamMember.MemberId)) {
                    getCaseTeamMember.TeamRoleId = CaseTeamRoleMap.get(roleName);
                }
                userIdSet.add(getCaseTeamMember.MemberId);
                updateTeamRole.add(getCaseTeamMember);
            }
            if (updateTeamRole.size() > 0) {
                update updateTeamRole;
            }
        }
        for (ContactShare conShare : [
                SELECT Id, UserOrGroupId, ContactId
                FROM ContactShare
                WHERE ContactId IN :revokingContactIdSet
                LIMIT 50000
        ]) {
            if (userIdSet.contains(conShare.UserOrGroupId) && volunteerUsersSet.contains(conShare.UserOrGroupId)) {
                removeContactShareList.add(conShare);
            }
        }
        if (removeContactShareList.size() > 0) {
            delete removeContactShareList;
        }

        /**
         * JIRA: WLP-286
         * Author: Gustavo Mayer
         * Update: Sub case conversion to the single Wish Case,
         * no need to update the child case as there is no longer the concept of parent case.
         */
//      if (childCaseList.size() > 0) {
//          for (Case closeChildCase : childCaseList) {
//              closeChildCase.status = 'Closed';
//              closeChildCase.Hidden_Close_Sub_Case__c = true;
//              closeCaseList.add(closeChildCase);
//          }
//          if (closeCaseList.size() > 0) {
//              update closeCaseList;
//          }
//      }
        //}
        /* catch(Exception e){
             for(Case currCase : CaseList){
                 currCase.addError(e.getMessage());
             }
         } */
    }

    /******************************************************************************************************
Change the Volunteer Opportunity Status as Completed when the wish wish status as completed or closed.
******************************************************************************************************/
    public static void updateVolunteerOpportunityStatus(Set<Id> CaseId, List<Case> CaseList) {
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c >();
        Set<Id> recallApprovalSet = new Set<Id>();
        //try{
        for (Volunteer_Opportunity__c currRec : [
                SELECT Id, Status__c, Wish__c, Wish__r.RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN:CaseId
                AND Wish__c != NULL
                AND Wish__r.RecordTypeId = :wishRecordTypeId
                LIMIT 50000
        ]) {
            if (currRec.Status__c != 'Completed') {
                currRec.Status__c = 'Completed';
                volunteerOppList.add(currRec);
            }
            recallApprovalSet.add(currRec.Id);
        }
        if (recallApprovalSet.size() > 0) {
            recallVolOppApproval(recallApprovalSet);
        }

        if (volunteerOppList.size() > 0 && volunteerOppList != null) {
            update volunteerOppList;
        }
        //}
        /*catch(Exception e){
            for(Case currCase : CaseList){
                currCase.addError(e.getMessage());
            }
        }*/
    }

    /******************************************************************************************************
Updating Open Volunteer Opportunity's Inactive and Reason for Inactive field when Case is closed.
******************************************************************************************************/
    public static void updateVolunteerOpportunityasInactive(Set<Id> closedCaseIdSet, List<Case> CaseList) {
        List<Volunteer_Opportunity__c> updateVO_List = new List<Volunteer_Opportunity__c>();
        // try{
        for (Volunteer_Opportunity__c updateVO : [
                SELECT Id,Inactive__c,Reason_Inactive__c
                FROM Volunteer_Opportunity__c
                WHERE
                Wish__c IN :closedCaseIdSet AND Volunteer_Name__c = NULL
                AND Inactive__c = FALSE AND Migrated_Record__c = FALSE
                LIMIT 50000
        ]) {
            updateVO.Inactive__c = true;
            updateVO.Reason_Inactive__c = 'inactivated';
            updateVO_List.add(updateVO);
        }

        if (updateVO_List.size() > 0)
            update updateVO_List;
        //}
        /* catch(Exception e){
             for(Case currCase : CaseList){
                 currCase.addError(e.getMessage());
             }
         } */
    }

    /******************************************************************************************************
This method is used to update the wish granted count in contact record.
******************************************************************************************************/
    public static void grantedWishCount(Set<Id> wishIdsSet) {
        Set<Id> volunteerIdsSet = new Set<Id>();

        for (Volunteer_Opportunity__c currentVolOpp : [
                SELECT Id, Wish__c,Wish__r.Status, Volunteer_Name__c, Status__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :wishIdsSet AND Volunteer_Name__c != NULL
                LIMIT 50000
        ]) {
            volunteerIdsSet.add(currentVolOpp.Volunteer_Name__c);
        }

        if (volunteerIdsSet.size() > 0) {
            VolOpportunity_OnAfter_Update_Helper.ActiveWishCount(volunteerIdsSet);
        }

    }

    /******************************************************************************************************
This method is used to recall the Volunteer Opportunity approval process
******************************************************************************************************/
    /**
     * WLP-491
     * Future method cannot blocking Volunteer Approval Process
     */
//  @future(callout = true)
    public static void recallVolOppApproval(Set<Id> pendingVollOppIdSet) {
        String volOppIsString = '';
        for (String volId : pendingVollOppIdSet) {
            volOppIsString += volId + ',';
        }
        VolunteerInterviewTask_AC.getApprovalRecal(volOppIsString.removeEnd(','));
    }

    /**********************************************************************************************************************************
This method is used to populate end date value in volunteer Opportunity record when the wish status is 'Granted' or 'Closed'
*************************************************************************************************************************************/
    public static void populateEndDate(Set<Id> wishIdSet) {
        if (wishIdSet.size() > 0) {
            // try{
            List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
            for (Volunteer_Opportunity__c dbVolunteerOppRec : [
                    SELECT Id,Wish__c, Wish__r.Status, Wish__r.End_Date__c, Wish__r.Closed_Date__c,
                            Wish_Start_Date__c, Wish_End_Date__c, Status__c, Inactive__c
                    FROM Volunteer_Opportunity__c
                    WHERE Wish__c IN:wishIdSet AND Inactive__c = :FALSE AND Status__c != 'Inactive'
                    LIMIT 50000
            ]) {
                if (dbVolunteerOppRec.Wish__r.Status == 'Granted') {
                    dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.End_Date__c;
                }
                if (dbVolunteerOppRec.Wish__r.Status == 'Closed' && dbVolunteerOppRec.Wish__r.Closed_Date__c != null) {
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
                for(Case currCase : [SELECT Id From Case WHERE Id IN:wishIdSet]){

                    currCase.addError(ex.getMessage());
                }
            }*/
        }
    }

    public static void updateWishClearanceForm(Map<Id, Case> parentWishClearanceMap) {
        // try{
        List<Case> updatePlanningCaseList = new List<Case>();
        Case updateCase;
        for (Case currCase : [
                SELECT Id,Wish_Safety_Authorization_Part_B_Form__c,ParentId
                FROM Case
                WHERE Id IN :parentWishClearanceMap.keySet()
                AND RecordTypeId = :wishRecordTypeId
                LIMIT 50000
        ]) {
            if (parentWishClearanceMap.containsKey(currCase.ParentId)) {
                updateCase = new Case();
                updateCase.Id = currCase.Id;
                if (parentWishClearanceMap.get(currCase.ParentId).Wish_Clearance_Needed__c == 'Yes') {
                    updateCase.Wish_Safety_Authorization_Part_B_Form__c = true;
                } else {
                    updateCase.Wish_Safety_Authorization_Part_B_Form__c = false;
                }
                updatePlanningCaseList.add(updateCase);
            }
        }
        if (updatePlanningCaseList.size() > 0)
            update updatePlanningCaseList;
    }
    /*catch(Exception ex){
                for(Case currCase : [SELECT Id From Case WHERE Id IN:parentWishClearanceMap.keyset()]){

                    currCase.addError(ex.getMessage());
                }
      }*/
    //IME 18  - Method is used to update the lead sub status when Case sub status is changed
    public static void updateCaseToLeadSubStatus(String leadStatus, Map<Id, String> subStatusMap) {
        Set<Id> leadIds = subStatusMap.keySet();
        List<Lead> leadData = [
                SELECT Id, Status, Sub_Status__c
                FROM Lead
                WHERE Id IN :leadIds
                LIMIT 50000
        ];
        List<Lead> updateLeadList = new List<Lead>();

        for (Lead leadtoUpdate : leadData) {
            leadtoUpdate.Status = leadStatus;
            leadtoUpdate.Sub_Status__c = subStatusMap.get(leadtoUpdate.Id);
            updateLeadList.add(leadtoUpdate);
        }
        if (updateLeadList.size() > 0) {
            update updateLeadList;
        }
    }
}
