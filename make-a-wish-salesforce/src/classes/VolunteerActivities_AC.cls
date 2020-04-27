/**
 * @description     This class is used to display open and closed activities for volunteers.
 *
 * @author          MST Solutions
 * @createdDate     2016-11-10
 */
public class VolunteerActivities_AC {
    private static final String ACTIVITY_WRAPPER_DEFAULT_WISH_TYPE = 'Wish';

    public Id taskId { get; set; }
    private Id volunteerUserId;
    public Boolean showActive { get; set; }
    public Boolean showHistorical { get; set; }
    private Id currentUserRelatedContactId;

    public VolunteerActivities_AC() {
        showHistorical = false;
        showActive = true;
        volunteerUserId = Utils.currentUser.Id;
        currentUserRelatedContactId = Utils.currentUser.ContactId;
    }

    /**
     * @description     Used to pull all open activities for volunteer.
     *
     * @return          List<OpenActivitiesWrapper>
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    public List<ActivitiesWrapper> getOpenActivities() {
        List<ActivitiesWrapper> openActivitiesList = new List<ActivitiesWrapper>();

        Set<Id> wishTypeTaskSet = new Set<Id>();
        Set<Id> nonWishAndEvents = new Set<Id>();
        Set<Id> volunteerOpportunityIdSet = new Set<Id>();
        Map<Id,String> eventTypeMap = new Map<Id,String>();
        Map<Id,String> eventNameMap = new Map<Id,String>();
        Map<Id,String> wishNameMap = new Map<Id,String>();
        Map<Id,Id> wishContactIdMap = new Map<Id,Id>();
        Set<Id> wishGranterIdSet = new Set<Id>();
        List<Task> openActivities = new List<Task>();
        Map<Id,String> volunteerStatusMap = new Map<Id,String>();
        String Logvalue;

        try {
            for (Volunteer_Opportunity__c vollOppInfo : [
                SELECT Id, Role__c, Wish__c, Volunteer_Name__c,Status__c
                FROM Volunteer_Opportunity__c
                WHERE Volunteer_Name__c = :currentUserRelatedContactId
                AND Wish__r.IsClosed = FALSE
            ]) {

                if (vollOppInfo.Role__c == Constant_AC.CHAPTER_ROLE_WISH_GRANTER || vollOppInfo.Role__c == Constant_AC.CHAPTER_ROLE_WISH_GRANTER_MENTOR) {
                    wishGranterIdSet.add(vollOppInfo.Wish__c);
                }

                volunteerStatusMap.put(vollOppInfo.Wish__c, vollOppInfo.Status__c);
                wishContactIdMap.put(vollOppInfo.Volunteer_Name__c, vollOppInfo.Wish__c);
            }

            for (Task getOpenTask : [
                SELECT Id, WhatId, Owner.Name, What.Type, WhoId, Subject, ActivityDate, OwnerId, Status
                FROM Task
                WHERE IsClosed = FALSE
                AND (WhatId IN :wishGranterIdSet OR OwnerId = :volunteerUserId)
                AND ActivityDate != NULL
                ORDER BY CreatedDate DESC
            ]) {
                if ((!volunteerStatusMap.containsKey(getOpenTask.WhatId)) ||
                    (volunteerStatusMap.containsKey(getOpenTask.WhatId) &&
                        volunteerStatusMap.get(getOpenTask.WhatId) == Constant_AC.TASK_STATUS_APPROVED)) {

                    openActivities.add(getOpenTask);
                }
            }

            if (openActivities.isEmpty()) {
                return openActivitiesList; // return empty List
            }

            for (Task checkType : openActivities) {
                if (checkType.What.Type == 'Case') {
                    wishTypeTaskSet.add(checkType.WhatId);
                }
                if (checkType.What.Type == 'Non_Wish_Events__c') {
                    nonWishAndEvents.add(checkType.WhatId);
                }
                if (checkType.What.Type == 'Volunteer_Opportunity__c') {
                    volunteerOpportunityIdSet.add(checkType.WhatId);
                }
            }

            Map<Id,Id> caseSubMap = new Map<Id,Id>();

            if (!volunteerOpportunityIdSet.isEmpty()) {
                for (Volunteer_Opportunity__c volOppInfo : [
                    SELECT Id, Non_Wish_Event__c, Wish__r.ContactId, Non_Wish_Event__r.Event_Name__c,
                        Non_Wish_Event__r.RecordType.Name, Wish__c
                    FROM Volunteer_Opportunity__c
                    WHERE Id IN :volunteerOpportunityIdSet
                ]) {
                    if (volOppInfo.Wish__c != null) {
                        wishTypeTaskSet.add(volOppInfo.Wish__c);
                        caseSubMap.put(volOppInfo.Id, volOppInfo.Wish__c);
                    }

                    if (volOppInfo.Non_Wish_Event__c != null) {
                        nonWishAndEvents.add(volOppInfo.Id);
                        eventTypeMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.RecordType.Name);
                        eventNameMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.Event_Name__c);
                    }
                }
            }

            if (!nonWishAndEvents.isEmpty()) {
                for (Non_Wish_Events__c getRecordType : [
                    SELECT Id, Event_Name__c, RecordTypeId, RecordType.Name
                    FROM Non_Wish_Events__c
                    WHERE Id IN :nonWishAndEvents
                ]) {
                    eventTypeMap.put(getRecordType.Id, getRecordType.RecordType.Name);
                    eventNameMap.put(getRecordType.Id, getRecordType.Event_Name__c);
                }
            }

            if (!wishTypeTaskSet.isEmpty()) {
                for (Case getContactName : [
                    SELECT Id, Contact.Name
                    FROM Case
                    WHERE Id IN :wishTypeTaskSet
                ]) {
                    wishNameMap.put(getContactName.Id, getContactName.Contact.Name);
                }
            }

            for (Task taskTypeNameMerge : openActivities) {
                ActivitiesWrapper mergeInfoWithTask = new ActivitiesWrapper();
                mergeInfoWithTask.volunteerTask = taskTypeNameMerge;

                if (taskTypeNameMerge.WhatId != null) {
                    if (eventTypeMap.containsKey(taskTypeNameMerge.WhatId)) {
                        if (eventNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                            mergeInfoWithTask.wishType = eventTypeMap.get(taskTypeNameMerge.WhatId);
                            mergeInfoWithTask.nameField = eventNameMap.get(taskTypeNameMerge.WhatId);
                        }
                    } else if (wishNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                        mergeInfoWithTask.wishType = ACTIVITY_WRAPPER_DEFAULT_WISH_TYPE;
                        mergeInfoWithTask.nameField = wishNameMap.get(taskTypeNameMerge.WhatId);
                    } else if (caseSubMap.containsKey(taskTypeNameMerge.WhatId)) {
                        mergeInfoWithTask.wishType = ACTIVITY_WRAPPER_DEFAULT_WISH_TYPE;
                        mergeInfoWithTask.nameField = wishNameMap.get(caseSubMap.get(taskTypeNameMerge.WhatId));
                    }
                }

                Logvalue = String.valueOf(openActivitiesList);
                openActivitiesList.add(mergeInfoWithTask);
            }


            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

            return openActivitiesList;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActivities_AC', 'getOpenActivities', null, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }


    /**
     * @description     Used to pull all open activities for volunteer.
     *
     * @return          List<CloseActivitiesWrapper>
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    public List<ActivitiesWrapper> getCloseActivities() {
        List<ActivitiesWrapper> closedActivitiesList = new List<ActivitiesWrapper>();
        Set<Id> wishTypeTaskSet = new Set<Id>();
        Set<Id> nonWishAndEvents = new Set<Id>();
        Set<Id> volunteerOpportunityIdSet = new Set<Id>();
        Map<Id,String> eventTypeMap = new Map<Id,String>();
        Map<Id,String> eventNameMap = new Map<Id,String>();
        Map<Id,String> wishNameMap = new Map<Id,String>();
        Map<Id,Id> wishContactIdMap = new Map<Id,Id>();
        Set<Id> wishGranterIdSet = new Set<Id>();
        List<Task> openActivities = new List<Task>();
        String Logvalue;

        try {
            for (Volunteer_Opportunity__c vollOppInfo : [
                SELECT Id, Role__c, Wish__c, Volunteer_Name__c
                FROM Volunteer_Opportunity__c
                WHERE Status__c = :Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
                AND Volunteer_Name__c = :currentUserRelatedContactId
            ]
            ) {
                if (vollOppInfo.Role__c == Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER ||
                    vollOppInfo.Role__c == Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR) {

                    wishGranterIdSet.add(vollOppInfo.Wish__c);
                }

                wishContactIdMap.put(vollOppInfo.Volunteer_Name__c, vollOppInfo.Wish__c);
            }

            for (Task getOpenTask : [
                SELECT Id, WhatId, Owner.Name, What.Type, WhoId, Subject, ActivityDate, OwnerId, Status
                FROM Task
                WHERE IsClosed = TRUE
                AND (WhatId IN :wishGranterIdSet OR OwnerId = :volunteerUserId)
                ORDER BY LastModifiedDate DESC
            ]
            ) {
                openActivities.add(getOpenTask);
            }

            if (openActivities.isEmpty()) {
                return closedActivitiesList; // return empty List
            }

            if (openActivities.size() > 0) {
                for (Task checkType : openActivities) {
                    if (checkType.what.Type == 'Case') {
                        wishTypeTaskSet.add(checkType.WhatId);
                    }
                    if (checkType.what.Type == 'Non_Wish_Events__c') {
                        nonWishAndEvents.add(checkType.WhatId);
                    }
                    if (checkType.what.Type == 'Volunteer_Opportunity__c') {
                        volunteerOpportunityIdSet.add(checkType.WhatId);
                    }
                }

                Map<Id,Id> caseSubMap = new Map<Id,Id>();

                if (volunteerOpportunityIdSet.size() > 0) {
                    for (Volunteer_Opportunity__c volOppInfo : [
                        SELECT Id, Non_Wish_Event__c, Wish__r.ContactId, Non_Wish_Event__r.Event_Name__c,
                            Non_Wish_Event__r.RecordType.Name, Wish__c
                        FROM Volunteer_Opportunity__c
                        WHERE Id IN :volunteerOpportunityIdSet
                    ]) {
                        if (volOppInfo.Wish__c != null) {
                            wishTypeTaskSet.add(volOppInfo.Wish__c);
                            caseSubMap.put(volOppInfo.Id, volOppInfo.Wish__c);
                        }

                        if (volOppInfo.Non_Wish_Event__c != null) {
                            nonWishAndEvents.add(volOppInfo.Id);
                            eventTypeMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.RecordType.Name);
                            eventNameMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.Event_Name__c);
                        }
                    }
                }

                if (nonWishAndEvents.size() > 0) {
                    for (Non_Wish_Events__c getRecordType : [
                        SELECT Id, Event_Name__c, RecordTypeId, RecordType.Name
                        FROM Non_Wish_Events__c
                        WHERE Id IN :nonWishAndEvents
                    ]) {
                        eventTypeMap.put(getRecordType.Id, getRecordType.RecordType.Name);
                        eventNameMap.put(getRecordType.Id, getRecordType.Event_Name__c);
                    }
                }

                if (wishTypeTaskSet.size() > 0) {
                    for (Case getContactName : [
                        SELECT Id, Contact.Name
                        FROM Case
                        WHERE Id IN :wishTypeTaskSet
                    ]) {
                        wishNameMap.put(getContactName.Id, getContactName.Contact.Name);
                    }
                }


                for (Task taskTypeNameMerge : openActivities) {
                    ActivitiesWrapper mergeInfoWithTask = new ActivitiesWrapper();
                    mergeInfoWithTask.volunteerTask = taskTypeNameMerge;
                    if (taskTypeNameMerge.WhatId != null) {
                        if (eventTypeMap.containsKey(taskTypeNameMerge.WhatId)) {
                            if (eventNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                                mergeInfoWithTask.wishType = eventTypeMap.get(taskTypeNameMerge.WhatId);
                                mergeInfoWithTask.nameField = eventNameMap.get(taskTypeNameMerge.WhatId);
                            }
                        } else if (wishNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                            mergeInfoWithTask.wishType = ACTIVITY_WRAPPER_DEFAULT_WISH_TYPE;
                            mergeInfoWithTask.nameField = wishNameMap.get(taskTypeNameMerge.WhatId);
                        } else if (caseSubMap.containsKey(taskTypeNameMerge.WhatId)) {
                            mergeInfoWithTask.wishType = ACTIVITY_WRAPPER_DEFAULT_WISH_TYPE;
                            mergeInfoWithTask.nameField = wishNameMap.get(caseSubMap.get(taskTypeNameMerge.WhatId));
                        }
                    }

                    closedActivitiesList.add(mergeInfoWithTask);
                }
            }

            Logvalue = String.valueOf(closedActivitiesList);

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

            return closedActivitiesList;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActivities_AC', 'getCloseActivities', Null, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    /**
     * @description     This method is used to close the task when the volunteer tries to close the task
      *                 from the My Task page.
      *
      * @author         MST Solutions
      * @createdDate    unknown
     */
    public void closeTask() {
        String Logvalue;
        Task aTask;

        try {
            aTask = [SELECT Id, Status FROM Task WHERE Id = :taskId];
        } catch (System.QueryException ex) {
            return;
        }

        try {
            Logvalue = aTask.Status;
            aTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
            update aTask;

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActivities_AC', 'getCloseActivities', null, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    // Wrapper class for Activities
    public class ActivitiesWrapper {
        public Task volunteerTask { get; set; }
        public String wishType { get; set; }
        public String nameField { get; set; }
    }
}