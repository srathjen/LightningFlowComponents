/**
 * @description Task Service class
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	3-04-2020
 */
public class TaskService {

    private final static Id STAFF_TASK_RECORD_TYPE_ID = Constant_AC.STAFF_TASK_RT_ID;
    private static final String STATUS_COMPLETED = Constant_AC.TASK_STATUS_COMPLETED;
    private static final String STATUS_NOT_STARTED = Constant_AC.TASK_STATUS_NOT_STARTED;
    private static final String STATUS_IN_PROGRESS = Constant_AC.TASK_STATUS_IN_PROGRESS;
    private static final String PRIORITY_NORMAL = Constant_AC.TASK_PRIORITY_NORMAL;
    private static final String DESCRIPTION_RUSH_QUALIFIED = Constant_AC.TASK_DESCRIPTION_RUSH_QUALIFIED;
    private static final String SUBJECT_SEND_WELCOME_LETTER = Constant_AC.TASK_SUBJECT_SEND_WELCOME_LETTER;
    private static final String SUBJECT_RUSH_QUALIFIED = Constant_AC.TASK_SUBJECT_RUSH_QUALIFIED;
    private static final String SUBJECT_RUSH_MODIFIED_NO = Constant_AC.TASK_SUBJECT_RUSH_MODIFIED_NO;
    private static final String TASK_RT_STAFF_LABEL = Constant_AC.TASK_RT_STAFF_LABEL;
    private static final String WISH_BIRTHDAY_SUBJECT = 'Wish Child Birthday Reminder';

    public static Task buildSendWelcomeLetter(Contact contact) {
        return new Task(
            OwnerId = contact.OwnerId,
            SystemGeneratedTask__c = true,
            Subject = SUBJECT_SEND_WELCOME_LETTER,
            WhoId = contact.Id,
            Description = SUBJECT_SEND_WELCOME_LETTER,
            Status = STATUS_IN_PROGRESS,
            ActivityDate = System.today() + 10,
            RecordTypeId = STAFF_TASK_RECORD_TYPE_ID
        );
    }

    /**
     * Build Rush Task
     * @param contact
     * @return Task
     */
    public static Task buildRush(Contact contact) {
        return new Task(
            Description = DESCRIPTION_RUSH_QUALIFIED,
            Priority = PRIORITY_NORMAL,
            Status = STATUS_COMPLETED,
            Subject = SUBJECT_RUSH_QUALIFIED,
            OwnerId = Label.Salesforce_Support_User_Id,
            ActivityDate = System.today(),
            WhoId = contact.Id
        );
    }

    /**
     * Create Rush Task
     * @param leadList
     */
    public static void createRushTask(List<Lead> leadList) {
        List<Task> newTaskList = new List<Task>();
        for (Lead processLead : leadList) {
            Task newRushTask = new Task(
                Priority = PRIORITY_NORMAL,
                Status = STATUS_NOT_STARTED,
                Subject = SUBJECT_RUSH_MODIFIED_NO,
                OwnerId = processLead.OwnerId,
                ActivityDate = System.today() + 3,
                SystemGeneratedTask__c = true,
                WhoId = processLead.Id);
            newTaskList.add(newRushTask);
        }
        if (!newTaskList.isEmpty()) {
            insert newTaskList;
        }
    }

    /**
     * Create Lead Task
     * @param leadMap
     * @return Save Result
     */
    public static List<Database.SaveResult> createLeadTask(Set<Id> leadIds) {
        List<Task> newTaskList = new List<Task>();
        for (Lead newLead : [
            SELECT Id, Migrated_Record__c, OwnerId, Owner.UserRole.Name, Status,
                ChapterName__c,ChapterName__r.Name, PD_Condition_Description__c
            FROM Lead
            WHERE Id IN :leadIds
        ]) {
            Task newTask = new Task();
            if (newLead.Status == Constant_AC.LEAD_STATUS_INQUIRY) {
                newTask.Subject = Constant_AC.TASK_SUBJECT_NEW_INQUIRY_SUBMITTED;
                newTask.ActivityDate = Date.today().addDays(30);
            }
            if (newLead.Status == Constant_AC.LEAD_STATUS_REFERRED) {
                newTask.Subject = Constant_AC.TASK_SUBJECT_NEW_REFERRAL_SUBMITTED;
                newTask.ActivityDate = Date.today().addDays(10);
            }
            newTask.OwnerId = newLead.OwnerId;
            newTask.RecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
            newTask.WhoId = newLead.Id;
            newTask.Priority = Constant_AC.TASK_PRIORITY_NORMAL;
            newTask.SystemGeneratedTask__c = true;
            newTaskList.add(newTask);
        }
        if (!newTaskList.isEmpty()) {
            return Database.insert(newTaskList, false);
        }
        return new List<Database.SaveResult>();
    }

    /**
     * Close Lead Tasks
     * @param leadIds
     */
    public static void updateCompleted(Set<Id> leadIds) {
        List<Task> taskList = [
            SELECT Id,Status
            FROM Task
            WHERE WhoId IN :leadIds
            AND Status != :STATUS_COMPLETED
        ];
        List<Task> updateTask = new List<Task>();
        for (Task processTask : taskList) {
            processTask.Status = STATUS_COMPLETED;
            updateTask.add(processTask);
        }
        update updateTask;
    }

    /**
    * @description	Used to update Background Check Subject based on day difference.
    *
    * @param         List<Task> tasks
    *
    * @author        MST Solutions
    * @createdDate   unknown
    */
    public static void updateBGCTaskSubjectDays(List<Task> tasks) {
        if (tasks == null || tasks.isEmpty()) {
            return;
        }

        Map<Id,Task> bgExpiringTaskMap = new Map<Id,Task>();

        for (Task aTask : tasks) {
            if (aTask.Subject == Constant_AC.TASK_SUBJECT_BACKGROUND_CHECK_EXPIRING) {
                if (aTask.WhatId != null) {
                    bgExpiringTaskMap.put(aTask.WhatId, aTask);
                }
            }
        }

        if (bgExpiringTaskMap == null || bgExpiringTaskMap.isEmpty()) {
            return;
        }

        for (Background_check__c bgInfo : [
            SELECT Id, Date__c, Current__c, Volunteer__c, Volunteer__r.Name
            FROM Background_check__c
            WHERE Current__c = TRUE
            AND Date__c = NEXT_N_DAYS:30
            AND Id IN :bgExpiringTaskMap.keySet()
        ]) {
            if (bgExpiringTaskMap.containsKey(bgInfo.Id)) {
                if (bgInfo.Date__c.daysBetween(Date.today()) == -30) {
                    bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (30 Days)';
                } else if (bgInfo.Date__c.daysBetween(Date.today()) == -23) {
                    bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (23 Days)';
                } else if (bgInfo.Date__c.daysBetween(Date.today()) == -16) {
                    bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (16 Days)';
                } else if (bgInfo.Date__c.daysBetween(Date.today()) == -9) {
                    bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (9 Days)';
                } else if (bgInfo.Date__c.daysBetween(Date.today()) == -2) {
                    bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (2 Days)';
                }

                bgExpiringTaskMap.get(bgInfo.Id).ActivityDate = null;
            }
        }
    }

    /**
     * @description     Used to update COI Subject based on day difference.
     *
     * @param           List<Task> tasks
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    public static void updateCOITaskSubjectDays(List<Task> tasks) {
        if (tasks == null || tasks.isEmpty()) {
            return;
        }

        Map<Id,Task> coiExpiringTaskMap = new Map<Id,Task>();

        for (Task aTask : tasks) {
            if (aTask.Subject == Constant_AC.TASK_SUBJECT_COI_EXPIRING) {
                if (aTask.WhatId != null) {
                    coiExpiringTaskMap.put(aTask.WhatId, aTask);
                }
            }
        }

        if (coiExpiringTaskMap == null || coiExpiringTaskMap.isEmpty()) {
            return;
        }

        for (Conflict_Of_Interest__c coiInfo : [
            SELECT Id, Expiration_Date__c, Current__c, Volunteer_Contact__c, Volunteer_Contact__r.Name
            FROM Conflict_Of_Interest__c
            WHERE Current__c = TRUE
            AND Expiration_Date__c = NEXT_N_DAYS:30
            AND Id IN :coiExpiringTaskMap.keySet()
        ]) {
            if (coiExpiringTaskMap.containsKey(coiInfo.Id)) {
                if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -30) {
                    coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (30 Days)';
                } else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -23) {
                    coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (23 Days)';
                } else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -16) {
                    coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (16 Days)';
                } else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -9) {
                    coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (9 Days)';
                } else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -2) {
                    coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (2 Days)';
                }

                coiExpiringTaskMap.get(coiInfo.Id).ActivityDate = null;
            }
        }
    }

    /**
     * @description     This method is used to fetch the values from associated contact of task and assign with the
     *                  corresponding task fields to merge with email template.
     *
     * @param           List<Task> tasks
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    public static void updateTaskEmailMergeFields(List<Task> tasks) {
        if (tasks == null || tasks.isEmpty()) {
            return;
        }

        Set<Id> volunteerContactIdsSet = new Set<Id>();
        List<Task> updatedTaskList = new List<Task>();

        for (Task aTask : tasks) {
            if (aTask.WhoId != null) {
                volunteerContactIdsSet.add(aTask.WhoId);
                updatedTaskList.add(aTask);
            }
        }

        if (volunteerContactIdsSet == null || volunteerContactIdsSet.isEmpty()) {
            return;
        }

        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();

        if (volunteerContactIdsSet.size() > 0) {
            for (Contact getContactInfo : [
                SELECT Id, Name, Account.Name, Account.Phone, Account.Email__c
                FROM Contact
                WHERE Id IN :volunteerContactIdsSet
            ]) {
                if (!contactInfoMap.containsKey(getContactInfo.Id)) {
                    contactInfoMap.put(getContactInfo.Id, getContactInfo);
                }
            }
        }

        Contact contact;
        for (Task currRec : updatedTaskList) {
            if (currRec.WhoId != null && contactInfoMap.containsKey(currRec.WhoId)) {
                contact = contactInfoMap.get(currRec.WhoId);

                currRec.Account_Name__c = contact.Account.Name;
                currRec.Account_Phone__c = contact.Account.Phone;
                currRec.Account_Email__c = contact.Account.Email__c;
                currRec.Contact_Name_Hidden__c = contact.Name;
            }
        }
    }

    /**
     * @description     This method is used to assign the 'Birthday Remainder Task' to primary volunteer.
     *
     * @param           List<Task> tasksList
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    public static void birthdayTaskPrimaryVolunteerAssign(List<Task> tasksList) {
        if (tasksList == null || tasksList.isEmpty()) {
            return;
        }

        Set<Id> taskRelatedContactIdsSet = new Set<Id>();
        List<Task> birthdayTasksList = new List<Task>();

        for (Task aTask : tasksList) {
            if (aTask.Subject == Constant_AC.TASK_SUBJECT_BIRTHDAY_REMINDER) {
                birthdayTasksList.add(aTask);
                taskRelatedContactIdsSet.add(aTask.WhatId);
            }
        }

        if (birthdayTasksList.isEmpty()) {
            return;
        }

        Set<Id> caseIdsSet = new Set<Id>();
        Map<Id,Id> caseContactIdsMap = new Map<Id,Id>();
        Map<Id,Id> taskRelatedCaseIdsMap = new Map<Id,Id>();

        for (Case caseDetails : [
            SELECT Id, ContactId
            FROM Case
            WHERE Id IN :taskRelatedContactIdsSet
        ]) {
            caseIdsSet.add(caseDetails.Id);
            caseContactIdsMap.put(caseDetails.Id, caseDetails.ContactId);
            taskRelatedCaseIdsMap.put(caseDetails.Id, caseDetails.ContactId);
        }

        if (caseIdsSet.isEmpty()) {
            return;
        }

        Map<Id,Id> caseTeamMembersMap = new Map<Id,Id>();

        for (CaseTeamMember memberDetails : [
            SELECT Id, MemberId, ParentId
            FROM CaseTeamMember
            WHERE ParentId IN :caseIdsSet AND TeamRole.Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER
            ORDER BY CreatedDate ASC
        ]) {
            if (!caseTeamMembersMap.containsKey(memberDetails.ParentId)) {
                caseTeamMembersMap.put(memberDetails.ParentId, memberDetails.MemberId);
            }
        }

        if (caseTeamMembersMap.isEmpty()) {
            return;
        }

        for (Task assignTaskOwner : birthdayTasksList) {
            if (caseTeamMembersMap.containsKey(assignTaskOwner.WhatId)) {
                assignTaskOwner.OwnerId = caseTeamMembersMap.get(assignTaskOwner.WhatId);
            }
            if (taskRelatedCaseIdsMap.containsKey(assignTaskOwner.WhatId)) {
                assignTaskOwner.WhoId = taskRelatedCaseIdsMap.get(assignTaskOwner.WhatId);
            }
        }
    }

    /**
     * @description 	This method is used to prevent volunteer to close the task when the wish presentation date is not set.
     *
     * @param 			List<Task> tasks
     *
     * @author			MST Solutions
     * @createdDate		unknown
     */
    public static void closeTaskValidation(List<Task> tasks, Map<Id,Task> oldTasksMap) {
        if (tasks == null || tasks.isEmpty()) {
            return;
        }

        List<Task> validationTaskList = new List<Task>();

        for (Task aTask : tasks) {
            if (aTask.Status == Constant_AC.TASK_STATUS_COMPLETED && oldTasksMap.get(aTask.Id).Status != aTask.Status) {
                validationTaskList.add(aTask);
            }
        }

        if (validationTaskList.isEmpty()) {
            return;
        }

        Set<Id> conceptTaskParentSet = new Set<Id>();
        Set<Id> wishNotClosedParentIdSet = new Set<Id>();
        Set<Id> presentationParentIdSet = new Set<Id>();
        List<Task> conceptTask = new List<Task>();
        List<Task> wishPresentationTaskList = new List<Task>();
        List<Task> wishNotClosedTaskList = new List<Task>();
        Map<Id,Case> conceptApprovalMap = new Map<Id,Case>();
        Set<Id> openCaseIdSet = new Set<Id>();

        for (Task checkSubject : validationTaskList) {
            if (checkSubject.Subject == Constant_AC.TASK_SUBJECT_WISH_CONCEPT_APPROVAL) {
                conceptTaskParentSet.add(checkSubject.WhatId);
                conceptTask.add(checkSubject);
            } else if (checkSubject.Subject == Constant_AC.TASK_SUBJECT_WISH_PRESENTATION_NOT_SET) {
                wishPresentationTaskList.add(checkSubject);
                presentationParentIdSet.add(checkSubject.WhatId);
            } else if (checkSubject.Subject == Constant_AC.TASK_SUBJECT_WISH_NOT_CLOSED) {
                wishNotClosedParentIdSet.add(checkSubject.WhatId);
                wishNotClosedTaskList.add(checkSubject);
            }
        }

        if (conceptTaskParentSet.size() > 0) {
            for (Case conceptApprovalCheck : [
                SELECT Id, Status, Sub_Status__c
                FROM Case
                WHERE RecordTypeId = :Constant_AC.WISH_RT_ID
                AND Id IN :conceptTaskParentSet
            ]) {
                conceptApprovalMap.put(conceptApprovalCheck.Id, conceptApprovalCheck);
            }
            if (conceptApprovalMap.size() > 0) {
                for (Task throwError : conceptTask) {
                    if (conceptApprovalMap.containsKey(throwError.WhatId)) {
                        if (conceptApprovalMap.get(throwError.WhatId).Status != Constant_AC.CASE_STATUS_WISH_DETERMINED) {
                            throwError.addError(Label.TaskTrigger_Determination_Not_Policy);
                        }
                    }
                }
            }
        }

        if (wishNotClosedParentIdSet.size() > 0) {
            for (Case wishStatusCheck : [
                SELECT Id, Status, RecordTypeId
                FROM Case
                WHERE Id IN :wishNotClosedParentIdSet
                AND (Status != :Constant_AC.CASE_STATUS_COMPLETED
                OR Status != :Constant_AC.CASE_STATUS_CLOSED)
                AND RecordTypeId = :Constant_AC.WISH_RT_ID
            ]) {
                openCaseIdSet.add(wishStatusCheck.Id);
            }

            if (openCaseIdSet.size() > 0) {
                for (Task preventTaskClose : wishNotClosedTaskList) {
                    if (openCaseIdSet.contains(preventTaskClose.WhatId)) {
                        preventTaskClose.addError(Label.TaskTrigger_Close_Wish_Before_Task);
                    }
                }
            }
        }
    }

    /**
     * @description		This method is used to fetch the values from associated contact of task and assign with the
     * 					corresponding task fields to merge with email template.
     *
     * @param 			List<Task> tasks
     *
     * @author 			MST Solutions
     * @createdDate		unknown
     */
    public static void updateTaskEmailMergeFields(List<Task> tasks, Map<Id,Task> oldTasksMap) {
        if (tasks == null || tasks.isEmpty()) {
            return;
        }

        List<Task> updateTaskList = new List<Task>();
        Set<Id> contactIdSet = new Set<Id>();

        String taskWhoId;
        for (Task aTask : tasks) {
            taskWhoId = aTask.WhoId;

            if (aTask.WhoId != null && taskWhoId.startsWith('003') && oldTasksMap.get(aTask.Id).WhoId != aTask.WhoId) {
                contactIdSet.add(aTask.WhoId);
                updateTaskList.add(aTask);
            }
        }

        if (contactIdSet.isEmpty()) {
            return;
        }

        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();

        if (contactIdSet.size() > 0) {
            for (Contact getContactInfo : [
                SELECT Id, Name, Account.Name, Account.Phone, Account.Email__c
                FROM Contact
                WHERE Id IN:contactIdSet
            ]) {
                if (!contactInfoMap.containsKey(getContactInfo.Id)) {
                    contactInfoMap.put(getContactInfo.Id, getContactInfo);
                }
            }
        }

        for (Task currRec : updateTaskList) {
            if (currRec.WhoId != null && contactInfoMap.containsKey(currRec.WhoId)) {
                currRec.Account_Name__c = contactInfoMap.get(currRec.WhoId).Account.Name;
                currRec.Account_Phone__c = contactInfoMap.get(currRec.WhoId).Account.Phone;
                currRec.Account_Email__c = contactInfoMap.get(currRec.WhoId).Account.Email__c;
                currRec.Contact_Name_Hidden__c = contactInfoMap.get(currRec.WhoId).Name;
            }
        }
    }

    /**
     * @param tasks
     * @param oldTasksMap
     */
    public static void dateTimeValidations(List<Task> tasks, Map<Id,Task> oldTasksMap) {
        if (tasks == null || tasks.isEmpty()) {
            return;
        }

        for (Task newTask : tasks) {
            if (newTask.Confirmed_Date__c != null && newTask.Confirmed_Time__c == null) {
                newTask.addError(Label.TaskTrigger_Enter_Confirmed_Time);
            }

            if (newTask.Confirmed_Date__c == null && newTask.Confirmed_Time__c != null) {
                newTask.addError(Label.TaskTrigger_Enter_Confirmed_Date);
            }

            if (newTask.Confirmed_Date__c != null && newTask.Confirmed_Date__c < Date.today()
                && newTask.Confirmed_Date__c != oldTasksMap.get(newTask.Id).Confirmed_Date__c) {

                newTask.addError(Label.TaskTrigger_Confirm_Date_Greater_Than_Today);
            }

            if (newTask.Confirmed_Date__c != null && newTask.Venue__c == null) {
                newTask.addError(Label.TaskTrigger_Please_Enter_Venue);
            }
        }
    }

    /**
     * @description     This method is used to update the volunteer record for tracing the last engagement date.
     *
     * @param           List<Task> newTasks
     * @param           Map<Id,Task> oldTasksMap
     *
     * @author          MST Solutions
     * @createdDate     unknown
     **/
    public static void updateVolunteerRecord(List<Task> newTasks, Map<Id,Task> oldTasksMap) {
        if (newTasks == null || newTasks.isEmpty()) {
            return;
        }

        Map<Id,Task> taskMap = new Map<Id,Task>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();

        for (Task newTask : newTasks) {
            if (newTask.Status == Constant_AC.TASK_STATUS_COMPLETED &&
                oldTasksMap.get(newTask.id).Status != Constant_AC.TASK_STATUS_COMPLETED) {

                if (newTask.WhatId != null) {
                    if (String.valueOf(newTask.WhatId).startsWith('500')) {
                        taskMap.put(newTask.Id, newTask);
                        ownerIds.add(newTask.OwnerId);
                        caseIds.add(newTask.WhatId);
                    }
                }
            }
        }

        if (caseIds.isEmpty()) {
            return;
        }

        Map<Id,User> volunteerMap = new Map<Id,User>();
        Map<Id,Set<Id>> caseTeamMemberMap = new Map<Id,Set<Id>>();
        Map<Id,Contact> updateContactMap = new Map<Id,Contact>();

        for (CaseTeamMember caseTeamMember : [
            SELECT Id, ParentId, MemberId, Parent.RecordTypeId
            FROM CaseTeamMember
            WHERE ParentId = :caseIds
            AND TeamRole.Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER
            AND Parent.RecordTypeId = :Constant_AC.WISH_RT_ID
        ]) {
            ownerIds.add(caseTeamMember.MemberId);

            if (!caseTeamMemberMap.containsKey(caseTeamMember.ParentId)) {
                caseTeamMemberMap.put(caseTeamMember.ParentId, new Set<Id>{
                    caseTeamMember.MemberId
                });
            } else {
                caseTeamMemberMap.get(caseTeamMember.ParentId).add(caseTeamMember.MemberId);
            }
        }

        if (ownerIds.isEmpty()) {
            return;
        }

        for (User currVol : [
            SELECT Id,ContactId,Contact.Date_of_last_engagement__c
            FROM User
            WHERE Id IN :ownerIds
            AND Profile.Id = :Label.Active_Volunteer_Profile
        ]) {
            volunteerMap.put(currVol.id, currVol);
        }

        for (Task currTask : taskMap.values()) {
            if (caseTeamMemberMap.containsKey(currTask.WhatId)) {
                for (Id currId : caseTeamMemberMap.get(currTask.WhatId)) {
                    if (volunteerMap.containsKey(currId)) {
                        if (volunteerMap.get(currId).Contact.Date_of_last_engagement__c == null
                            || volunteerMap.get(currId).Contact.Date_of_last_engagement__c < Date.today()) {

                            Contact updateContact = new Contact();
                            updateContact.Id = volunteerMap.get(currId).ContactId;
                            updateContact.Date_of_last_engagement__c = Date.today();

                            if (updateContactMap.containsKey(updateContact.Id)) {
                                continue;
                            }

                            updateContactMap.put(updateContact.Id, updateContact);
                        }
                    }
                }
            }
        }

        update updateContactMap.values();
    }

    public static List<Task> updateOwner(Map<Id,Set<Id>> inActiveOwnersMap,
        Map<Id,Id> activeVolunteerMap, Map<Id,Case> caseOwnerMap, Map<Id,Id> contactUserMap) {
        List<Task> taskOwnerUpdateList = new List<Task>();
        if (inActiveOwnersMap.isEmpty()) {
            return taskOwnerUpdateList;
        }
        for (Task task : [
            SELECT Id, OwnerId, Task_Type__c, WhatId
            FROM Task
            WHERE WhatId IN :inActiveOwnersMap.keySet()
            AND IsClosed = FALSE
        ]) {
            if (inActiveOwnersMap.containsKey(task.WhatId)) {
                if (inActiveOwnersMap.get(task.WhatId).contains(contactUserMap.get(task.OwnerId))) {
                    if (activeVolunteerMap.containsKey(task.WhatId) && task.Task_Type__c != null) {
                        task.OwnerId = activeVolunteerMap.get(task.WhatId);
                        taskOwnerUpdateList.add(task);
                    } else {
                        task.OwnerId = caseOwnerMap.get(task.WhatId).OwnerId;
                        taskOwnerUpdateList.add(task);
                    }
                }
            }
        }
        update taskOwnerUpdateList;
        return taskOwnerUpdateList;
    }

    /**
     * @description     For creating sneakpeek task for chapter staff
     *
     * @param           List<Task> newTasks
     * @param           Map<Id,Task> oldTasksMap
     *
     * @author          MST Solutions
     * @createdDate     unknown
    **/
    public static void sneakPeekTask(List<Task> newTasks, Map<Id,Task> oldTasksMap) {
        if (newTasks == null || newTasks.isEmpty()) {
            return;
        }

        Map<Id,Task> flightBookTaskMap = new Map<Id,Task>();
        Map<Id,Task> budgetBookTaskMap = new Map<Id,Task>();
        Map<Id,Task> passportRequestMap = new Map<Id,Task>();

        for (Task newTask : newTasks) {
            if (newTask.Status == Constant_AC.TASK_STATUS_COMPLETED && oldTasksMap.get(newTask.Id).Status != newTask.Status) {
                if (newTask.Subject == Constant_AC.TASK_SUBJECT_FLIGHTS_BOOKED) {
                    flightBookTaskMap.put(newTask.WhatId, newTask);
                }

                if (newTask.Subject == Constant_AC.TASK_SUBJECT_BUDGET) {
                    budgetBookTaskMap.put(newTask.WhatId, newTask);
                }

                if (newTask.Subject == Constant_AC.TASK_SUBJECT_REQUEST_PASSPORTS) {
                    passportRequestMap.put(newTask.WhatId, newTask);
                }
            }
        }

        List<Task> updateTaskList = new List<Task>();

        if (flightBookTaskMap.size() > 0) {
            for (Task sneakPeek : [
                SELECT Id, ActivityDate
                FROM Task
                WHERE WhatId IN :flightBookTaskMap.keySet()
                AND IsClosed = FALSE
                AND Subject = :Constant_AC.TASK_SUBJECT_SNEAK_PEEK_LETTER
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
                AND IsClosed = FALSE
                AND (Subject = :Constant_AC.TASK_SUBJECT_REQUEST_PASSPORTS
                OR Subject = :Constant_AC.TASK_SUBJECT_PASSPORTS_REQUESTED)
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
                AND IsClosed = FALSE
                AND Subject = :Constant_AC.TASK_SUBJECT_CRUISE_REQUEST_FORM
            ]) {
                if (sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(14);
                } else {
                    sneakPeek.ActivityDate = System.today() + 14;
                }

                updateTaskList.add(sneakPeek);
            }
        }

        update updateTaskList;
    }

    /**
     * @description     Update the Lead Closed Date.
     *
     * @param           List<Task> newTasks
     * @param           Map<Id,Task> oldTasksMap
     *
     * @author          MST Solutions
     * @createdDate     unknown
    **/
    public static void updateLeadCloseDate(List<Task> newTasks, Map<Id,Task> oldTasksMap) {
        if (newTasks == null || newTasks.isEmpty()) {
            return;
        }

        Set<Id> leadIds = new Set<Id>();

        for (Task newTask : newTasks) {
            if (newTask.Status == Constant_AC.TASK_STATUS_COMPLETED &&
                oldTasksMap.get(newTask.Id).Status != newTask.Status &&
                newTask.Subject == Constant_AC.TASK_SUBJECT_REFERRAL_DNQ) {

                if (newTask.WhoId != null) {
                    leadIds.add(newTask.WhoId);
                }
            }
        }

        if (leadIds.isEmpty()) {
            return;
        }

        List<Lead> updateLeadList = new List<Lead>();
        for (Lead currLead : [
            SELECT Id, Closed_Date__c
            FROM Lead
            WHERE Id IN :leadIds
        ]) {
            currLead.Closed_Date__c = System.today();
            updateLeadList.add(currLead);
        }

        update updateLeadList;
    }

    public static List<Task> updateBirthday(Map<Id,Id> volunteerMap, Map<Id,Id> contactUserInfoMap) {
        List<Task> tasks = new List<Task>();
        for (Task birthdayTaskInfo : [
            SELECT Id, WhatId, Subject, OwnerId
            FROM Task
            WHERE Subject = :WISH_BIRTHDAY_SUBJECT
            AND WhatId IN :volunteerMap.keySet()
            AND IsClosed = FALSE
            AND RecordType.Name = :TASK_RT_STAFF_LABEL
        ]) {
            if (volunteerMap.containsKey(birthdayTaskInfo.WhatId)) {
                if (contactUserInfoMap.containsKey(volunteerMap.get(birthdayTaskInfo.WhatId))) {
                    birthdayTaskInfo.OwnerId = contactUserInfoMap.get(volunteerMap.get(birthdayTaskInfo.WhatId));
                }
            }
            birthdayTaskInfo.RecordTypeId = Constant_AC.VOLUNTEER_TASK_RT_ID;
            tasks.add(birthdayTaskInfo);
        }
        update tasks;
        return tasks;
    }
}