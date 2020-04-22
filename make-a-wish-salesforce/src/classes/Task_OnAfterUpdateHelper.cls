/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated then Task_OnAfterUpdateHelper is called by Task_OnAfterUpdateHandler
then it will call the corresponding methods from Task_OnAfterUpdateHandler.

Modification Log
------------------
   WVC-2205 kanagaraj A //Line 172 previously the affilliation status was "Declained". Now we have updated as "Not Approved"
   SIW-191   bmaclaughlin // Line 100 Create Map to hold list values
******************************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class Task_OnAfterUpdateHelper {

    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
    private final static Id volunteerTaskRT = Constant_AC.VOLUNTEER_TASK_RT_ID;

    /**
     * Check volunteer followup task.
     *
     * @param followUpTaskMap
     **/
    public static void checkFollowUpTask(Map<Id, Task> followUpTaskMap) {
        Set<Id> openTaskIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        for (CaseTeamMember caseTeamMem : [
                SELECT ParentId,MemberId,TeamRoleId,TeamRole.Name,Parent.RecordTypeId
                FROM CaseTeamMember
                WHERE TeamRole.Name = 'Wish Granter'
                AND ParentId IN :followUpTaskMap.keySet()
                AND Parent.RecordTypeId = :wishRecordTypeId
        ]) {
            ownerIdSet.add(caseTeamMem.MemberId);
        }

        for (Task existingTask : [
                SELECT Id, WhatId, OwnerId
                FROM Task
                WHERE WhatId IN :followUpTaskMap.keySet()
                AND IsClosed = false
                AND OwnerId IN :ownerIdSet
        ]) {
            openTaskIdSet.add(existingTask.WhatId);
        }
        for (Task checkOpenTask : followUpTaskMap.values()) {
            if (openTaskIdSet.contains(checkOpenTask.WhatId)) {
                checkOpenTask.addError('Please close other follow up task before closing this task');
            }
        }
    }

    /**
     * This method is used to update the volunteer record for tracing the last engagement date.
     *
     * @param taskMap
     * @param ownerIds
     * @param caseIds
     **/
    public static void updateVolunteerRecord(Map<Id, Task> taskMap, Set<Id> ownerIds, Set<Id> caseIds) {
        Map<Id, User> volunteerMap = new Map<Id, User>();
        Map<Id, Set<Id>> caseTeamMemberMap = new Map<Id, Set<Id>>();
        List<Contact> updateContactList = new List<Contact>();
        for (CaseTeamMember currMemb : [
                SELECT id,ParentId,MemberId,Parent.RecordTypeId
                FROM CaseTeamMember
                WHERE ParentId = :caseIds
                AND TeamRole.Name = 'Wish Granter'
                AND Parent.RecordTypeId = :wishRecordTypeId
        ]) {
            ownerIds.add(currMemb.MemberId);
            if (!caseTeamMemberMap.containsKey(currMemb.ParentId)) {
                caseTeamMemberMap.put(currMemb.ParentId, new set<Id>{
                        currMemb.MemberId
                });

            } else {
                caseTeamMemberMap.get(currMemb.ParentId).add(currMemb.memberid);
            }
        }

        for (User currVol : [
                SELECT Id,ContactId,Contact.Date_of_last_engagement__c
                FROM User
                WHERE Id IN :ownerIds AND Profile.Id = :label.Active_Volunteer_Profile
        ]) {
            volunteerMap.put(currVol.id, currVol);
        }

        for (Task currTask : taskMap.values()) {

            if (caseTeamMemberMap.containsKey(currTask.whatId)) {
                for (Id currId : caseTeamMemberMap.get(currTask.whatId)) {
                    if (volunteerMap.containsKey(currId)) {
                        if (volunteerMap.get(currId).Contact.Date_of_last_engagement__c == Null
                                || volunteerMap.get(currId).Contact.Date_of_last_engagement__c < Date.Today()) {
                            Contact updateContact = new Contact();
                            updateContact.id = volunteerMap.get(currId).ContactId;
                            updateContact.Date_of_last_engagement__c = Date.Today();
                            updateContactList.add(updateContact);
                        }
                    }
                }
            }
        }
        //SIW-191 4/25 Create Map to hold list values
        map<id, Contact> Contactmap = new map<id, Contact>();
        Contactmap.putall(updateContactList);
        if (Contactmap.size() > 0) {
            update Contactmap.values();
        }
        //  if(updateContactList.size() > 0)
        //      update updateContactList;
    }

    /**
     * Volunteer wish granted task check.
     *
     * @param wishGrantTaskWhatIdSet
     **/
    public static void checkWishGrantTask(Set<Id> wishGrantTaskWhatIdSet) {
        /*List<Case> wishGrankClosedWishList = new List<Case>();
        Map<Id, Case> parentWishMap = new Map<Id, Case>([
                SELECT Id, isWishGrantTasksClosed__c
                FROM Case
                WHERE Id IN :wishGrantTaskWhatIdSet AND RecordTypeId = :wishRecordTypeId AND IsClosed = FALSE
        ]);
        Set<Id> childTaskExistParentIdSet = new Set<Id>();

        for (AggregateResult agg : [
                SELECT count(Id) recCount, WhatId parentWishId
                FROM Task
                WHERE WhatId IN :wishGrantTaskWhatIdSet AND isClosed = FALSE
                GROUP BY WhatId
        ]) {

            if (parentWishMap.containsKey((ID) agg.get('parentWishId'))) {
                childTaskExistParentIdSet.add(parentWishMap.get((ID) agg.get('parentWishId')).Id);
            }
        }
        if (parentWishMap.size() > 0) {
            for (Id parentWishId : parentWishMap.keySet()) {
                if (!childTaskExistParentIdSet.contains(parentWishId)) {
                    if (parentWishMap.containsKey(parentWishId)) {
                        parentWishMap.get(parentWishId).isWishGrantTasksClosed__c = true;
                        wishGrankClosedWishList.add(parentWishMap.get(parentWishId));
                    }
                }
            }
        }
        if (wishGrankClosedWishList.size() > 0) {
            update wishGrankClosedWishList;
        }*/
    }

    /**
     * This methode is used to create a Checkin with famil task for every 30 days after the previous task is completed untill the case is completed.
     *
     * @param createCheckinTaskList
     * @param checkinTaskIdSet
     **/
    public static void createCheckinRecurrenceTask(List<Task> createCheckinTaskList, Set<Id> checkinTaskIdSet) {
        /*List<Task> newRecTaskList = new List<Task>();
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        List<Case> updateCheckinDate = new List<Case>();

        for (Case checkinTaskCase : [
                SELECT Id,CheckedInFamily__c,Status,ParentId
                FROM Case
                WHERE RecordTypeId = :wishRecordTypeId AND Id IN :checkinTaskIdSet
        ]) {
            parentCaseMap.put(checkinTaskCase.Id, checkinTaskCase);
        }
        for (Task recCheckinTask : createCheckinTaskList) {
            if ((parentCaseMap.containsKey(recCheckinTask.WhatId)
                    && (parentCaseMap.get(recCheckinTask.WhatId).Status != 'Granted'
                    && parentCaseMap.get(recCheckinTask.WhatId).Status != 'Completed'
                    && parentCaseMap.get(recCheckinTask.WhatId).Status != 'Closed'
                    && parentCaseMap.get(recCheckinTask.WhatId).Status != 'DNQ'
                    && parentCaseMap.get(recCheckinTask.WhatId).Status != 'Hold'))) {
                Task newSubTask = new Task();
                newSubTask.Subject = recCheckinTask.Subject;
                newSubTask.ActivityDate = System.Today() + 30;
                newSubTask.WhatId = recCheckinTask.WhatId;
                newSubTask.Task_Type__c = recCheckinTask.Task_Type__c;
                newSubTask.WhoId = recCheckinTask.WhoId;
                newSubTask.SystemGeneratedTask__c = true;
                newSubTask.RecordTypeId = volunteerTaskRT;
                if (recCheckinTask.OwnerId != Null) {
                    newSubTask.OwnerId = recCheckinTask.OwnerId;
                }
                newRecTaskList.add(newSubTask);
                updateCheckinDate.add(parentCaseMap.get(recCheckinTask.WhatId));
            }
        }
        if (newRecTaskList.size() > 0) {
            insert newRecTaskList;
        }
        if (updateCheckinDate.size() > 0) {
            update updateCheckinDate;
        }*/
    }

    /**
     * This method is used to update the Affiliation status to 'Not Approved' when the task status is 'Declined'.
     *
     * @param volunteerContactSet
     **/
    public static void UpdateAffiliationStatusAsDeclined(Set<Id> volunteerContactSet) {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for (npe5__Affiliation__c dbAffiliationRec : [
                SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__c IN :volunteerContactSet
                AND npe5__Status__c != 'Active'
        ]) {
            dbAffiliationRec.npe5__Status__c = 'Not Approved';
            affiliationList.add(dbAffiliationRec);
        }
        if (affiliationList.size() > 0) {
            update affiliationList;
        }
    }
    /**
     * Used to update Affiliation Status when the created task is declined.
     *
     * @param volunteerContactSet
     **/
    public static void UpdateAffiliationStatus(Set<Id> volunteerContactSet) {
        List<npe5__Affiliation__c> updateAffliationList = new List<npe5__Affiliation__c>();
        Set<Id> activeContactIdsSet = new Set<Id>();
        Id triainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
        Set<Id> orientationTrainingId = new Set<Id>();
        Map<String, Set<String>> volunteerChapterRoleMap = new Map<String, Set<String>>();
        Set<Id> chapterRolesSet = new Set<Id>();
        Set<Id> volunteerProsProfileSet = new Set<Id>();
        Set<Id> volunteerActiveProfileSet = new Set<Id>();
        List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
        List<Volunteer_Roles__c> volunteerRoleList = new List<Volunteer_Roles__C>();
        Map<String, Conflict_Of_Interest__c> coiMap = new Map<String, Conflict_Of_Interest__c>();
        Set<String> chapterRoleOandTsSet = new Set<String>();
        set<Id> volunteerBCIdSet = new Set<Id>();

        for (Conflict_Of_Interest__c currCOI : [
                SELECT id, Volunteer_Contact__c, Expiration_Date__c
                FROM Conflict_Of_Interest__c
                WHERE Volunteer_Contact__c IN :volunteerContactSet
                AND Expiration_Date__c > :Date.Today()
                LIMIT 50000
        ]) {
            coiMap.put(currCOI.Volunteer_Contact__c, currCOI);
        }
        for (Volunteer_Roles__c currRole : [
                SELECT Id,Name,Status__c,Hidden_Previous_Status__c,Chapter_Role__c,Volunteer_Name__c,
                        Chapter_Role__r.Background_Check_Required__c, Chapter_Role__r.COI_Required__c
                FROM Volunteer_Roles__c
                WHERE Volunteer_Name__c IN :coiMap.keySet()
                AND Status__c != 'Not Approved'
                AND Status__c != 'Former'
                AND Status__c != :VOLUNTEER_ROLE_STATUS_ACTIVE
                LIMIT 50000
        ]) {
            volunteerRoleList.add(currRole);
            chapterRolesSet.add(currRole.Chapter_Role__c);
            /**
             * JIRA: WLP-422
             * Author: Gustavo Mayer
             * Update: Adding the new field COI Required to the condition
             * to change Volunteer_Roles__c to Active.
             */
            If (currRole.Chapter_Role__r.Background_Check_Required__c && currRole.Chapter_Role__r.COI_Required__c) {
                volunteerBCIdSet.add(currRole.Chapter_Role__c);
            }
        }
        for (Chapter_Role_O_T__c currChapterRole : [
                SELECT Id,Name,Orientation_Training__c,Orientation_Training__r.RecordTypeId,Required__c,Chapter_Role__c
                FROM Chapter_Role_O_T__c
                WHERE Chapter_Role__c IN :chapterRolesSet
                AND Required__c = TRUE
                AND Orientation_Training__r.RecordTypeId = :triainingRecordTypeId
                LIMIT 50000
        ]) {
            chapterRoleOandTsSet.add(currChapterRole.Chapter_Role__c);
        }
        /*if(volunteerChapterRoleMap.containsKey(currRole.Volunteer_Name__c))
            volunteerChapterRoleMap.get(currRole.Volunteer_Name__c).add(currRole.Chapter_Role__c);
        else
            volunteerChapterRoleMap.put(currRole.Volunteer_Name__c, new Set<String>{currRole.Chapter_Role__c});

       */
        /**************** WVC - 2199 ***************/
        If (volunteerRoleList.Size() > 0) {
            for (Volunteer_Roles__c currRole : volunteerRoleList) {
                If (!chapterRoleOandTsSet.contains(currRole.Chapter_Role__c)
                        && (!volunteerBCIdSet.contains(currRole.Chapter_Role__c))) {
                    Volunteer_Roles__c updateRole = new Volunteer_Roles__c();
                    updateRole.Id = currRole.Id;
                    /* If(currRole.Status__c == 'Out of Compliance' && (currRole.Hidden_Previous_Status__c != Null || currRole.Hidden_Previous_Status__c != '') && currRole.Chapter_Role__r.Background_Check_Required__c == True){
                         updateRole.Status__c = currRole.Hidden_Previous_Status__c;
                         updateRole.Hidden_Previous_Status__c = '';
                     }*/
                    updateRole.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
                    volunteerActiveProfileSet.add(currRole.Volunteer_Name__c);
                    updateVolunteerRoleList.add(updateRole);
                }
            }
        }
        /***** END WVC-2199 *****************/
        //}

        /**** Comment WVC-2205 ************/
        /* Set<String> chapterRoleOandTsSet = new Set<String>();


         for(Chapter_Role_O_T__c currChapterRole : [SELECT Id,Name,Orientation_Training__c,Orientation_Training__r.RecordTypeId,Required__c,Chapter_Role__c FROM Chapter_Role_O_T__c WHERE Chapter_Role__c IN :chapterRolesSet AND Required__c = TRUE AND Orientation_Training__r.RecordTypeId =:triainingRecordTypeId])
         {
             chapterRoleOandTsSet.add(currChapterRole.Chapter_Role__c);
         }

         for(Conflict_Of_Interest__c currCOI : [SELECT  id, Volunteer_Contact__c, Expiration_Date__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c IN :approvedVolunteerIds AND Expiration_Date__c > : Date.Today()])
         {
             coiMap.put(currCOI.Volunteer_Contact__c, currCOI);
         }

         for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : approvedVolunteerIds AND npe5__Status__c != 'Active'])
         {

             If(!volunteerActiveProfileSet.contains(dbAffiliationRec.npe5__Contact__c)){
             npe5__Affiliation__c currAffiliation = new npe5__Affiliation__c();
             if(coiMap.containsKey(dbAffiliationRec.npe5__Contact__c))
             {
                 currAffiliation.npe5__Status__c = 'Active';
             }
             else
             {
                 currAffiliation.npe5__Status__c = 'Pending';
             }
             currAffiliation.id = dbAffiliationRec.id;
             if(volunteerChapterRoleMap.containsKey(dbAffiliationRec.npe5__Contact__c)){
                 for(String currChapterRole : volunteerChapterRoleMap.get(dbAffiliationRec.npe5__Contact__c))
                 {
                     if(chapterRoleOandTsSet.contains(currChapterRole))
                     {
                         currAffiliation.npe5__Status__c = 'Pending';
                     }

                 }
             }

             if(currAffiliation.npe5__Status__c == 'Active')
                 activeContactIdsSet.add(dbAffiliationRec.npe5__Contact__c);
             updateAffliationList.add(currAffiliation);
         }
         }*/
        /***************** WVC-2205 commnented lines Ended ************/

        update updateVolunteerRoleList;
        if (volunteerActiveProfileSet.size() > 0) {
            VolunteerOTService.updateUserFuture(volunteerActiveProfileSet);
        }

    }

    /**
     * For creating sneakpeek task for chapter staff
     *
     * @param flightBookTaskMap
     * @param budgetBookTaskMap
     * @param passportRequestMap
     **/
    public static void sneakPeekTask(Map<Id, Task> flightBookTaskMap, Map<Id, Task> budgetBookTaskMap, Map<Id, Task> passportRequestMap) {
        List<Task> updateTaskList = new List<Task>();
        if (flightBookTaskMap.size() > 0) {
            for (Task sneakPeek : [
                    SELECT Id, ActivityDate
                    FROM Task
                    WHERE WhatId IN :flightBookTaskMap.keySet()
                    AND isClosed = false
                    AND Subject = 'Sneak Peek Letter'
            ]) {
                if (sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(7);
                } else {
                    sneakPeek.ActivityDate = System.today() + 7;
                }

                updateTaskList.add(sneakPeek);
            }
        }
        if (budgetBookTaskMap.size() > 0) {
            for (Task sneakPeek : [
                    SELECT Id, ActivityDate
                    FROM Task
                    WHERE WhatId IN :budgetBookTaskMap.keySet()
                    AND isClosed = false
                    AND (Subject = 'Request Passports from family' OR Subject = 'Passports Requested from family')
            ]) {
                if (sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(7);
                } else {
                    sneakPeek.ActivityDate = System.today() + 7;
                }
                updateTaskList.add(sneakPeek);
            }
        }
        if (passportRequestMap.size() > 0) {
            for (Task sneakPeek : [
                    SELECT Id, ActivityDate
                    FROM Task
                    WHERE WhatId IN :passportRequestMap.keySet()
                    AND isClosed = false
                    AND Subject = 'Cruise request form'
            ]) {
                if (sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(14);
                } else {
                    sneakPeek.ActivityDate = System.today() + 14;
                }
                updateTaskList.add(sneakPeek);
            }
        }
        if (updateTaskList.size() > 0) {
            update updateTaskList;
        }
    }

    /**
     * Below method is for sprint 12 ticket
     *
     * @param closeTaskList
     * @param closeTaskParentIdsSet
     **/
    public static void autoCloseTask(List<Task> closeTaskList, Set<Id> closeTaskParentIdsSet) {
        closeTaskParentIdsSet.remove(null);
        Set<Id> caseTeamMemberSet = new Set<Id>();
        for (CaseTeamMember caseTeamMem : [
                SELECT ParentId, MemberId, TeamRoleId, TeamRole.Name
                FROM CaseTeamMember
                WHERE TeamRole.Name = 'Wish Granter' AND ParentId IN :closeTaskParentIdsSet
        ]) {
            caseTeamMemberSet.add(caseTeamMem.MemberId);
        }

        if (closeTaskParentIdsSet.size() > 0) {
            Map<Id, Integer> taskCount = new Map<Id, Integer>();
            for (AggregateResult aggr : [
                    SELECT Count(Id) recCount, WhatId parentRecId
                    FROM Task
                    WHERE WhatId IN :closeTaskParentIdsSet
                    AND Subject != 'Volunteer wish follow-up activities not complete'
                    AND status != 'Completed' AND OwnerId IN :caseTeamMemberSet
                    GROUP BY WhatId
            ]) {
                taskCount.put((Id) aggr.get('parentRecId'), (Integer) aggr.get('recCount'));
            }
            Set<Id> closeFolowupTaskIdSet = new Set<Id>();
            for (Id parentId : closeTaskParentIdsSet) {
                if (!taskCount.containsKey(parentId)) {
                    closeFolowupTaskIdSet.add(parentId);
                }
            }

            if (closeFolowupTaskIdSet.size() > 0) {
                List<Task> closeFolowUpTaskList = new List<Task>();
                for (Task closeFollowUpTask : [
                        SELECT Id
                        FROM Task
                        WHERE WhatId IN :closeFolowupTaskIdSet
                        AND Subject = 'Volunteer wish follow-up activities not complete'
                ]) {
                    closeFollowUpTask.Status = 'Completed';
                    closeFolowUpTaskList.add(closeFollowUpTask);
                }
                if (closeFolowUpTaskList.size() > 0) {
                    update closeFolowUpTaskList;
                }
            }
        }
    }

    /**
     * Update the Lead Closed Date.
     *
     * @param leadIdList
     **/
    public static void updateLeadCloseDate(List<Id> leadIdList) {
        List<Lead> updateLeadList = new List<Lead>();
        for (Lead currLead : [
                SELECT Id,Closed_Date__C
                FROM Lead
                WHERE Id IN :leadIdList
        ]) {
            currLead.Closed_Date__c = System.Today();
            updateLeadList.add(currLead);
        }
        if (updateLeadList.Size() > 0) {
            Update updateLeadList;
        }
    }
}