/*
 * @description     Case After Update trigger helper methods.
 *
 * @author          MST Solutions
 * @createdDate     unknown
*/
public class Case_OnAfterUpdateTriggerHandlerHelper {
    private static final Id WISH_RECORDTYPE_ID = Constant_AC.WISH_RT_ID;
    private static final Id WISH_VOLUNTEER_OPPORTUNITY_RECORDTYPE_ID = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
    private static final Id CHAPTER_RECORDTYPE_ID = Constant_AC.CHAPTER_RT_ID;

    static Set<Id> contactIds = new Set<Id>();
    static Map<Id, Contact> contactMap = new Map<Id, Contact>();

    /*
     * @description 		Map of Lead labels by SObjectFields.
     *
     * @author				Chris Shinnimin, Traction on Demand
     * @date				2020-03-30
    */
    private static final Set<Schema.SObjectField> LEAD_FIELDS_TO_LABEL_MAP = new Set<Schema.SObjectField>{
        Lead.DOB__c,
        Lead.Any_medical_reason_for_moving_quickly__c,
        Lead.Part_A_Received__c,
        Lead.I_am_Recognized_To_Practice_As_a__c
    };
    private static Map<Schema.SObjectField, String> mapOfLeadLabelsByFields {
        get {
            if (mapOfLeadLabelsByFields == null) {
                mapOfLeadLabelsByFields = new Map<Schema.SObjectField, String>();

                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

                for (Schema.SObjectField field : LEAD_FIELDS_TO_LABEL_MAP) {
                    mapOfLeadLabelsByFields.put(field, fieldMap.get(String.valueOf(field)).getDescribe().getLabel());
                }
            }

            return mapOfLeadLabelsByFields;
        }
        set;
    }

    /*
     * @description     Delete all the system generated tasks when the wish assist is updated to true in parent Case.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void deleteWishAssistTask(Set<Id> parentIdSet, List<Case> newCaseList) {
        List<Task> deleteTaskList = new List<Task>();

        deleteTaskList = [
            SELECT Id, SystemGeneratedTask__c
            FROM Task
            WHERE WhatId IN :parentIdSet
            AND SystemGeneratedTask__c = TRUE
            AND What.RecordTypeId = :WISH_RECORDTYPE_ID
            LIMIT 50000
        ];

        if (deleteTaskList.size() > 0) {
            delete deleteTaskList;
        }
    }

    /*
     * @description     Delete the unassigned volunteer opportunities when the Case status is updated.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void deleteUnassignedVolunteerOpp(Set<Id> parentWishIdSet, List<Case> newCaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Volunteer_Opportunity__c> deleteVolOppList = new List<Volunteer_Opportunity__c>();

        deleteVolOppList = [
            SELECT Id,Volunteer_Name__c,Wish__c
            FROM Volunteer_Opportunity__c
            WHERE Wish__c IN :parentWishIdSet
            AND Volunteer_Name__c = :NULL
            AND RecordTypeId = :WISH_VOLUNTEER_OPPORTUNITY_RECORDTYPE_ID
            LIMIT 50000
        ];

        if (deleteVolOppList.size() > 0) {
            delete deleteVolOppList;
        }
    }

    /*
     * @description     Update volunteer opportunity to closed status when related Case is closed.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void closeVolOpp(Set<Id> CaseIdSetForVolOpp, List<Case> newCaseList) {
        List<Volunteer_Opportunity__c> closeVollOppList = new List<Volunteer_Opportunity__c>();
        Set<Id> recallApprovalSet = new Set<Id>();

        for (Volunteer_Opportunity__c closeVolOpp : [
            SELECT Id, Wish__c,Status__c
            FROM Volunteer_Opportunity__c
            WHERE Wish__c IN :CaseIdSetForVolOpp
            AND Wish__c != NULL
            AND Wish__r.RecordTypeId = :WISH_RECORDTYPE_ID
            LIMIT 50000
        ]) {
            if (closeVolOpp.Status__c != Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_CLOSED) {
                closeVolOpp.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_CLOSED;
                closeVollOppList.add(closeVolOpp);
            }

            recallApprovalSet.add(closeVolOpp.Id);
        }

        if (recallApprovalSet.size() > 0) {
            recallVolOppApproval(recallApprovalSet);
        }

        if (closeVollOppList.size() > 0) {
            update closeVollOppList;
        }
    }

    /*
     * @description     Update Lead status when diagnosis verification Case status is updated.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateLeadStatus(Set<String> updatedApprovedLeadInfoSet, Set<String> updatedDnqLeadInfoSet, List<Case> newCaseList) {
        List<Lead> updatedLeadList = new List<Lead>();
        String message = '';
        Boolean showError;

        for (Lead currentLead : [
            SELECT Id,
                Status, IsConverted, FirstName, Qualifying_ICD__c, Qualifying_Diagnosis__c,
                I_am_Recognized_To_Practice_As_a__c, Part_A_Received__c,
                Any_medical_reason_for_moving_quickly__c, DOB__c
            FROM Lead
            WHERE (Id IN :updatedApprovedLeadInfoSet OR Id IN :updatedDnqLeadInfoSet)
            AND IsConverted = :FALSE
            LIMIT 50000
        ]) {
            if (updatedApprovedLeadInfoSet.contains(currentLead.Id)) {
                if (currentLead.I_am_Recognized_To_Practice_As_a__c != null
                    && currentLead.Part_A_Received__c != null
                    && currentLead.Any_medical_reason_for_moving_quickly__c != null
                    && currentLead.DOB__c != null) {

                    currentLead.Status = Constant_AC.LEAD_STATUS_QUALIFIED;
                    currentLead.Sub_Status__c = '';
                    showError = false;
                } else {
                    showError = true;

                    if (currentLead.DOB__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += mapOfLeadLabelsByFields.get(Lead.DOB__c);
                    }

                    if (currentLead.Any_medical_reason_for_moving_quickly__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += mapOfLeadLabelsByFields.get(Lead.Any_medical_reason_for_moving_quickly__c);
                    }

                    if (currentLead.Part_A_Received__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += ', ' + mapOfLeadLabelsByFields.get(Lead.Part_A_Received__c);
                    }

                    if (currentLead.I_am_Recognized_To_Practice_As_a__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += ', ' + mapOfLeadLabelsByFields.get(Lead.I_am_Recognized_To_Practice_As_a__c);
                    }
                }
            } else if (updatedDnqLeadInfoSet.contains(currentLead.Id)) {
                currentLead.Status = Constant_AC.LEAD_STATUS_DNQ;
                currentLead.Sub_Status__c = Label.Wish_Lead_Status_Medical_Reviewed;
                currentLead.DNQ_Date__c = Date.today();
                showError = false;
            }

            if (!String.isBlank(message)) {
                for (Case currCase : newCaseList) {
                    currCase.addError(Label.CaseTrigger_Provide_Values + ' ' + message + '.');
                }
            }

            updatedLeadList.add(currentLead);
        }

        if (updatedLeadList.size() > 0 && showError == false) {
            update updatedLeadList;
        }
    }

    /*
     * @description     This method is used to update the volunteer opportunity In Progress checkbox based on parent wish status.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateVolunteerOpp(Set<Id> volunteerOppCaseIdSet, Boolean bool, List<Case> CaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Volunteer_Opportunity__c> updateVolOppList = new List<Volunteer_Opportunity__c>();

        for (Volunteer_Opportunity__c currRec : [
            SELECT Id, Wish__c
            FROM Volunteer_Opportunity__c
            WHERE Wish__c IN :volunteerOppCaseIdSet
            LIMIT 50000
        ]) {
            Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
            newVolOpp.Id = currRec.Id;

            if (bool == true) {
                newVolOpp.In_Progress__c = true;
            } else if (bool == false) {
                newVolOpp.In_Progress__c = false;
            }

            updateVolOppList.add(newVolOpp);
        }

        if (updateVolOppList.size() > 0) {
            update updateVolOppList;
        }
    }

    /*
     * @description     Update the HiddenGrantedDate in Contact when wish is granted.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateGrantedDate(List<Case> wishGrantedIdList) {
        List<Contact> updateContactList = new List<Contact>();

        for (Case dbCase : wishGrantedIdList) {
            Contact dbCont = new Contact();
            dbCont.Id = dbCase.ContactId;
            dbCont.Hidden_Granted_Date__c = System.today();
            updateContactList.add(dbCont);
        }

        if (updateContactList.size() > 0) {
            update updateContactList;
        }
    }

    /*
     * @description     When the Case status is updated, update the the corresponding Lead status.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateLeadStatus(List<Case> caseList) {
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Lead> updateLeadList = new List<Lead>();

        for (Case processedCaseList : caseList) {
            if (processedCaseList.Status == Constant_AC.CASE_STATUS_OPEN || processedCaseList.Status == Constant_AC.CASE_STATUS_ESCALATED) {
                caseMap.put(processedCaseList.Lead__c, processedCaseList);
            }
        }

        if (caseMap.size() > 0) {
            for (Lead dbLeads : [
                SELECT Id, Status, Sub_Status__c, IsConverted
                FROM Lead
                WHERE Id IN :caseMap.keySet() AND IsConverted = FALSE
                LIMIT 50000
            ]) {
                updateLeadList.add(dbLeads);
            }

        }

        if (updateLeadList.size() > 0) {
            update updateLeadList;
        }
    }

    /*
     * @description     Used to create two volunteer opportunities when the Case status is changed to 'Ready to Assign'
     *                  and to add Case related chapter volunteer manager into Case team with role name 'Volunteer manager'
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void createVolunteerOpportunity(Map<Id, Case> readyToAssignParentCaseMap, Set<Id> readyToAssignChapterIdSet) {
        RecursiveTriggerHandler.isFirstTime = false;
        Map<Id, Chapter_Role__c> chapterRoleMap = new Map<Id, Chapter_Role__c>();
        Map<Id, String> CaseTeamRoleNameMap = new Map<Id, String>();
        Map<String, Id> CaseTeamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> accountVolunteerManagerMap = new Map<Id, Id>(); // used to hold Chapter Account Id and its Volunteer Manager Id
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        List<CaseTeamMember> readyToAssignCaseTeamMemberList = new List<CaseTeamMember>();

        for (Chapter_Role__c currentChapterRole : [
            SELECT ID, Chapter_Name__c, Chapter_Name__r.Name, Role_Name__r.Name
            FROM Chapter_Role__c
            WHERE Role_Name__r.Name = :Constant_AC.CHAPTER_ROLE_WISH_GRANTER
            AND Chapter_Name__c IN :readyToAssignChapterIdSet
            LIMIT 50000
        ]) {
            chapterRoleMap.put(currentChapterRole.Chapter_Name__c, currentChapterRole);
        }

        for (Account chapterAccountInfo : [
            SELECT Id, Name, Volunteer_Manager__c, RecordTypeId
            FROM Account
            WHERE RecordTypeId = :CHAPTER_RECORDTYPE_ID AND Id IN :readyToAssignChapterIdSet AND Volunteer_Manager__c != NULL
            LIMIT 50000
        ]) {
            accountVolunteerManagerMap.put(chapterAccountInfo.Id, chapterAccountInfo.Volunteer_Manager__c);
        }

        for (CaseTeamRole caseTeamRoleInfo : [
            SELECT Id, Name
            FROM CaseTeamRole
            LIMIT 50000
        ]) {
            CaseTeamRoleNameMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name);
            CaseTeamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
        }

        if (chapterRoleMap.size() > 0) {
            for (Case currentCase : readyToAssignParentCaseMap.values()) {
                for (Integer i = 0; i <= 1; i++) { // create TWO volunteer opportunities
                    if (chapterRoleMap.containsKey(currentCase.ChapterName__c)) {
                        Volunteer_Opportunity__c volunteerOpp = new Volunteer_Opportunity__c();

                        volunteerOpp.Chapter_Role_Opportunity__c = chapterRoleMap.get(currentCase.ChapterName__c).Id;
                        volunteerOpp.Wish__c = currentCase.Id;
                        volunteerOpp.RecordTypeId = WISH_VOLUNTEER_OPPORTUNITY_RECORDTYPE_ID;
                        volunteerOpp.Is_Non_Viewable__c = true;
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
            if (CaseTeamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER)) {
                newCaseTeamMember.TeamRoleId = CaseTeamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER);
            }

            newCaseTeamMember.MemberId = changeCaseOwner.OwnerId;
            readyToAssignCaseTeamMemberList.add(newCaseTeamMember);
        }
    }

    /*
     * @description     Used to update Case Team Role and to create new Case Team Member based on Case Status.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void createAndUpdateUserCaseTeamRole(Map<Id, Case> updateVolunteerManagerCaseTeamMap, Set<Id> volunteerManagerIdSet, Set<Id> wishCoordinatorIdSet) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;

        Map<Id, String> teamRoleNameMap = new Map<Id, String>();
        Map<String, Id> teamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> ownerManagerMap = new Map<Id, Id>();
        Set<Id> caseOwnerIdSet = new Set<Id>();

        for (Case getOwner : updateVolunteerManagerCaseTeamMap.values()) {
            caseOwnerIdSet.add(getOwner.OwnerId);
        }

        for (User userManagerInfo : [
            SELECT Id, ManagerId
            FROM User
            WHERE Id IN :caseOwnerIdSet
            LIMIT 50000
        ]) {
            ownerManagerMap.put(userManagerInfo.Id, userManagerInfo.ManagerId);
        }

        for (CaseTeamRole caseTeamRoleInfo : [
            SELECT Id, Name
            FROM CaseTeamRole
            LIMIT 50000
        ]) {
            teamRoleNameMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name);
            teamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
        }

        if (updateVolunteerManagerCaseTeamMap.size() > 0) {
            List<CaseTeamMember> inActiveAndActiveVMUpsertList = new List<CaseTeamMember>();
            Map<Id, List<CaseTeamMember>> CaseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
            Map<String, Id> activeCaseTeamMap = new Map<String, Id>();
            Map<String, Id> inActiveCaseTeamMap = new Map<String, Id>();
            Map<Id, Set<Id>> CaseTeamMap = new Map<Id, Set<Id>>();

            Set<String> teamRoles = new Set<String>{
                Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER,
                Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE,
                Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE,
                Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR,
                Constant_AC.CASE_TEAM_ROLE_INTAKE_MANAGER
            };

            for (CaseTeamMember CaseTeamInfo : [
                SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name
                FROM CaseTeamMember
                WHERE TeamRole.Name IN :teamRoles
                AND ParentId IN :updateVolunteerManagerCaseTeamMap.keySet()
                LIMIT 50000
            ]) {
                if (CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER ||
                    CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR) {

                    activeCaseTeamMap.put(CaseTeamInfo.ParentId + '-' + CaseTeamInfo.MemberId, CaseTeamInfo.MemberId);
                } else if (CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE ||
                    CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE) {

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
                            if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER ||
                                CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR) {

                                if (volunteerManagerIdSet.contains(CaseTeamMem.ParentId) &&
                                    CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER) {

                                    CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                } else if (wishCoordinatorIdSet.contains(CaseTeamMem.ParentId) &&
                                    CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR) {

                                    CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                }
                            } else if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE ||
                                CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE) {

                                if (inActiveCaseTeamMap.get(CaseTeamMem.ParentId + '-' + CaseTeamMem.MemberId) == updateTeamMember.OwnerId) {
                                    if (volunteerManagerIdSet.contains(CaseTeamMem.ParentId) &&
                                        CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE) {

                                        CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                        inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                    } else if (wishCoordinatorIdSet.contains(CaseTeamMem.ParentId) &&
                                        CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE) {

                                        CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                        inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                    }
                                }
                            }
                        }
                    } else {
                        for (CaseTeamMember CaseTeamMem : CaseTeamMemberMap.get(updateTeamMember.Id)) {
                            if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER &&
                                volunteerManagerIdSet.contains(CaseTeamMem.ParentId)) {

                                CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                            } else if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR &&
                                wishCoordinatorIdSet.contains(CaseTeamMem.ParentId)) {

                                CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                            }
                        }

                        CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                        newCaseTeamMember.ParentId = updateTeamMember.Id;
                        newCaseTeamMember.MemberId = updateTeamMember.OwnerId;

                        if (volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                            if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER)) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER);
                                if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                    inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                }
                            }
                        } else if (wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                            if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR)) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
                                if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                    inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                }
                                if (ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                    CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                    newCaseManagerTeamMember.ParentId = updateTeamMember.Id;
                                    newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                    newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
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
                        if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER)) {
                            newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER);
                            inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                        }
                    } else if (wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                        if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR)) {
                            newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
                            inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                            if (ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                newCaseManagerTeamMember.ParentId = updateTeamMember.Id;
                                newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
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
    }

    /*
     * @description     Used the change the access to Case team member when their Case team role is updated.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void changeAccessPermission(Map<Id, Id> CaseContactMap, List<Case> newCaseList) {
        RecursiveTriggerHandler.blockCaseLockRecursive = false;

        Map<Id, String> CaseTeamRoleFilteredMap = new Map<Id, String>();
        Map<String, Id> CaseTeamRoleMap = new Map<String, Id>();

        for (CaseTeamRole caseTeamRoleInfo : [
            SELECT Id, Name
            FROM CaseTeamRole
        ]) {
            if (caseTeamRoleInfo.Name.contains(' (Wish Closed)')) {
                CaseTeamRoleFilteredMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name.remove(' (Wish Closed)'));
            } else {
                CaseTeamRoleMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
            }
        }

        Map<Id, Case> parentCaseMap = new Map<Id, Case>([
            SELECT Id,ParentId,RecordTypeId
            FROM Case
            WHERE ParentId = :NULL
            AND RecordTypeId = :WISH_RECORDTYPE_ID
            AND Id IN:CaseContactMap.keySet()
            LIMIT 50000
        ]);

        Map<Id, List<CaseTeamMember>> caseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
        for (CaseTeamMember caseTeamMemberInfo : [
            SELECT Id, MemberId, TeamRoleId, ParentId
            FROM CaseTeamMember
            WHERE ParentId IN :CaseContactMap.keySet()
            LIMIT 50000
        ]) {
            if (caseTeamMemberMap.containsKey(caseTeamMemberInfo.ParentId)) {
                caseTeamMemberMap.get(caseTeamMemberInfo.ParentId).add(caseTeamMemberInfo);
            } else {
                caseTeamMemberMap.put(caseTeamMemberInfo.ParentId, new List<CaseTeamMember>{
                    caseTeamMemberInfo
                });
            }
        }

        if (caseTeamMemberMap.size() > 0) {
            List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
            List<ContactShare> contactToShareList = new List<ContactShare>();

            for (Id CaseId : CaseContactMap.keySet()) {
                if (caseTeamMemberMap.containsKey(CaseId)) {
                    for (CaseTeamMember CaseTeamRoleUpdate : caseTeamMemberMap.get(CaseId)) {
                        if (CaseTeamRoleFilteredMap.containsKey(CaseTeamRoleUpdate.TeamRoleId)) {
                            if (CaseTeamRoleMap.containsKey(CaseTeamRoleFilteredMap.get(CaseTeamRoleUpdate.TeamRoleId))) {
                                CaseTeamRoleUpdate.TeamRoleId = CaseTeamRoleMap.get(CaseTeamRoleFilteredMap.get(CaseTeamRoleUpdate.TeamRoleId));

                                updateRoleList.add(CaseTeamRoleUpdate);

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

            if (updateRoleList.size() > 0) {
                update updateRoleList;
            }

            if (contactToShareList.size() > 0) {
                insert contactToShareList;
            }
        }
    }

    /*
     * @description     Used to update the role for volunteer User to wish, when the parent wish is completed.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void revokeWishPermissionForVolunteers(Set<Id> parentWishIds, Set<Id> revokingContactIdSet) {
        RecursiveTriggerHandler.allowToEditRecord = true;

        Map<String, Id> CaseTeamRoleMap = new Map<String, Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<ContactShare> removeContactShareList = new List<ContactShare>();
        List<CaseTeamMember> updateTeamRole = new List<CaseTeamMember>();
        Set<Id> memberIdSet = new Set<Id>();
        Set<Id> volunteerUsersSet = new Set<Id>();

        for (CaseTeamRole CaseRole : [
            SELECT Id, Name
            FROM CaseTeamRole
            LIMIT 50000
        ]) {
            if (CaseRole.Name.contains('Wish Closed')) {
                CaseTeamRoleMap.put(CaseRole.Name, CaseRole.Id);
            }
        }

        List<CaseTeamMember> caseTeamMemberList = [
            SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId
            FROM CaseTeamMember
            WHERE (ParentId IN :parentWishIds)
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
    }

    /*
     * @description     Change the Volunteer Opportunity Status as Completed when the wish status is completed or closed.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateVolunteerOpportunityStatus(Set<Id> CaseId, List<Case> CaseList) {
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c >();
        Set<Id> recallApprovalSet = new Set<Id>();

        for (Volunteer_Opportunity__c currRec : [
            SELECT Id, Status__c, Wish__c, Wish__r.RecordTypeId
            FROM Volunteer_Opportunity__c
            WHERE Wish__c IN:CaseId
            AND Wish__c != NULL
            AND Wish__r.RecordTypeId = :WISH_RECORDTYPE_ID
            LIMIT 50000
        ]) {
            if (currRec.Status__c != Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED) {
                currRec.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED;
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
    }

    /*
     * @description     Updating Open Volunteer Opportunity Inactive and Reason for Inactive field when Case is closed.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateVolunteerOpportunityasInactive(Set<Id> closedCaseIdSet, List<Case> CaseList) {
        List<Volunteer_Opportunity__c> updateVO_List = new List<Volunteer_Opportunity__c>();

        for (Volunteer_Opportunity__c updateVO : [
            SELECT Id, Inactive__c, Reason_Inactive__c
            FROM Volunteer_Opportunity__c
            WHERE Wish__c IN :closedCaseIdSet
            AND Volunteer_Name__c = NULL
            AND Inactive__c = FALSE
            AND Migrated_Record__c = FALSE
            LIMIT 50000
        ]) {
            updateVO.Inactive__c = true;
            updateVO.Reason_Inactive__c = 'inactivated';
            updateVO_List.add(updateVO);
        }

        if (updateVO_List.size() > 0) {
            update updateVO_List;
        }
    }

    /*
     * @description     This method is used to update the wish granted count in Contact record.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
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

    /*
     * @description     This method is used to recall the Volunteer Opportunity approval process.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void recallVolOppApproval(Set<Id> pendingVollOppIdSet) {
        String volOppIsString = '';

        for (String volId : pendingVollOppIdSet) {
            volOppIsString += volId + ',';
        }

        VolunteerInterviewTask_AC.getApprovalRecal(volOppIsString.removeEnd(','));
    }

    /*
     * @description     This method is used to populate end date value in volunteer Opportunity record
     *                  when the wish status is 'Granted' or 'Closed'.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void populateEndDate(Set<Id> wishIdSet) {
        if (wishIdSet.size() == 0) {
            return;
        }

        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();

        for (Volunteer_Opportunity__c dbVolunteerOppRec : [
            SELECT Id, Wish__c, Wish__r.Status, Wish__r.End_Date__c, Wish__r.Closed_Date__c,
                Wish_Start_Date__c, Wish_End_Date__c, Status__c, Inactive__c
            FROM Volunteer_Opportunity__c
            WHERE Wish__c IN :wishIdSet
            AND Inactive__c = :FALSE
            AND Status__c != :Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE
            LIMIT 50000
        ]) {
            if (dbVolunteerOppRec.Wish__r.Status == Constant_AC.CASE_STATUS_GRANTED) {
                dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.End_Date__c;
            }

            if (dbVolunteerOppRec.Wish__r.Status == Constant_AC.CASE_STATUS_CLOSED
                && dbVolunteerOppRec.Wish__r.Closed_Date__c != null) {

                dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.Closed_Date__c;
            }

            volunteerOpportunityList.add(dbVolunteerOppRec);
        }

        update volunteerOpportunityList;
    }

    /*
     * @description     Update wish clearance form.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
    public static void updateWishClearanceForm(Map<Id, Case> parentWishClearanceMap) {
        List<Case> updatePlanningCaseList = new List<Case>();
        Case updateCase;

        for (Case currCase : [
            SELECT Id, Wish_Safety_Authorization_Part_B_Form__c, ParentId
            FROM Case
            WHERE Id IN :parentWishClearanceMap.keySet()
            AND RecordTypeId = :WISH_RECORDTYPE_ID
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

        if (updatePlanningCaseList.size() > 0) {
            update updatePlanningCaseList;
        }
    }

    /*
     * @description     Update Case to Lead substatus.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
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