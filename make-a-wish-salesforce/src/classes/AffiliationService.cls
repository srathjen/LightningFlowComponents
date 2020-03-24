/**
 * @description Affiliation Service, centralizes Affiliation business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/03/2020
 */
public class AffiliationService {

    private static final String TREATING_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
    private static final String BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
    private static final String ALT1_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
    private static final String ALT2_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
    private static final String CURRENT_TREATING_FACILITY = Constant_AC.ORG_AFFILIATION_TREATING_FACILITY_CURRENT;
    private static final String WISH_FAMILY_LABEL = Constant_AC.WISH_FAMILY_RT_LABEL;
    private static final String CONTACT_WISH_CHILD_LABEL = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
    private static final String TREATING_FACILITY_CURRENT = Constant_AC.ORG_AFFILIATION_TREATING_FACILITY_CURRENT;
    private static final String PREFIX_STRING_MAKE_A_WISH = 'Make-a-Wish ';

    private static final Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;
    private static final Id HOSPITAL_TREATMENT_ID = Constant_AC.HOSPITAL_TREATMENT_ID;

    /**
     * Build Medical Affiliations
     * @param convertedLead
     * @param medicalAccountMap
     * @return List of Affiliations
     */
    public static List<npe5__Affiliation__c> buildHospitalMedicalAffiliations(Lead convertedLead,
            Map<String, Account> medicalAccountMap) {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        if (convertedLead.Hidden_DV_form_Medical_professional_Type__c != null) {
            npe5__Affiliation__c newAff = new npe5__Affiliation__c();
            newAff.npe5__Contact__c = convertedLead.ConvertedContactId;
            newAff.Treating_Facility__c = CURRENT_TREATING_FACILITY;
            if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == ALT2_MED_PROFESSIONAL
                    && medicalAccountMap.containsKey(convertedLead.Alternate2HospitalTreatmentFacility__c)
                    && convertedLead.HiddenAlternate2MedProfessionalId__c == null) {
                if (medicalAccountMap.containsKey(convertedLead.Alternate2HospitalTreatmentFacility__c)) {
                    newAff.npe5__Organization__c = medicalAccountMap.get(convertedLead.Alternate2HospitalTreatmentFacility__c).Id;
                }
                affiliationList.add(newAff);
            } else if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == ALT1_MED_PROFESSIONAL
                    && medicalAccountMap.containsKey(convertedLead.Alternate1HospitalTreatmentFacility__c)
                    && convertedLead.HiddenAlternate1MedProfessionalId__c == null) {
                if (medicalAccountMap.containsKey(convertedLead.Alternate1HospitalTreatmentFacility__c)) {
                    newAff.npe5__Organization__c = medicalAccountMap.get(convertedLead.Alternate1HospitalTreatmentFacility__c).Id;
                }
                affiliationList.add(newAff);
            } else if ((convertedLead.Hidden_DV_form_Medical_professional_Type__c == BEST_CONTACT
                    || convertedLead.Hidden_DV_form_Medical_professional_Type__c == TREATING_MED_PROFESSIONAL)
                    && medicalAccountMap.containsKey(convertedLead.Hospital_Treatment_Facility_Treating__c)
                    && convertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
                if (medicalAccountMap.containsKey(convertedLead.Hospital_Treatment_Facility_Treating__c)) {
                    newAff.npe5__Organization__c = medicalAccountMap.get(convertedLead.Hospital_Treatment_Facility_Treating__c).Id;
                }
                affiliationList.add(newAff);
            }
        }
        return affiliationList;
    }

    /**
     * @description Build Affiliations from Lead
     * @param existingMedicalProfIdMap
     * @param wishChildContactMap
     * @return List of Affiliations
     */
    public static List<npe5__Affiliation__c> buildMedicalAndChildAffiliations(Map<Id, Lead> existingMedicalProfIdMap,
            Map<Id, Contact> wishChildContactMap) {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        String wishFamilyRtLabel = WISH_FAMILY_LABEL;
        if (!existingMedicalProfIdMap.isEmpty() || !wishChildContactMap.isEmpty()) {
            for (npe5__Affiliation__c affiliation : [
                    SELECT npe5__Organization__c, npe5__Organization__r.RecordTypeId, npe5__Contact__c, Constituent_Code__c
                    FROM npe5__Affiliation__c
                    WHERE (npe5__Organization__r.RecordTypeId = :HOSPITAL_TREATMENT_ID
                    OR Constituent_Code__c = :wishFamilyRtLabel)
            ]) {
                if (existingMedicalProfIdMap.containsKey(affiliation.npe5__Contact__c)
                        && affiliation.npe5__Organization__r.RecordTypeId == HOSPITAL_TREATMENT_ID) {
                    npe5__Affiliation__c newAff = new npe5__Affiliation__c();
                    newAff.npe5__Contact__c = existingMedicalProfIdMap.get(affiliation.npe5__Contact__c).ConvertedContactId;
                    newAff.Treating_Facility__c = TREATING_FACILITY_CURRENT;
                    newAff.npe5__Organization__c = affiliation.npe5__Organization__c;
                    affiliationList.add(newAff);
                }
                if (wishChildContactMap.containsKey(affiliation.npe5__Contact__c) && affiliation.Constituent_Code__c == wishFamilyRtLabel) {
                    affiliation.Constituent_Code__c = CONTACT_WISH_CHILD_LABEL;
                    affiliationList.add(affiliation);
                }
            }
        }
        return affiliationList;
    }

    /**
     * @description Whenever first Affiliation record has fallen under contact, assigning that record as primary.
     * @param affiliationList
     */
    public static void setStatusAndPrimary(List<npe5__Affiliation__c> affiliationList) {
        Set<Id> contactIds = new Set<Id>();
        Map<String, Integer> contactsMap = new Map<String, Integer>();
        Map<Id, Contact> getContactRecType = new Map<Id, Contact>();

        for (npe5__Affiliation__c currRec : affiliationList) {
            contactIds.add(currRec.npe5__Contact__c);
        }

        if (contactIds.size() > 0) {
            getContactRecType.putAll([
                    SELECT Id,RecordTypeId
                    FROM Contact
                    WHERE Id IN :contactIds
            ]);

            for (AggregateResult ar : [
                    SELECT npe5__Contact__c, COUNT(Id) cnt
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c IN :contactIds
                    GROUP BY npe5__Contact__c
            ]) {
                contactsMap.put(String.valueOf(ar.get('npe5__Contact__c')), Integer.valueOf(ar.get('cnt')));
            }
        }

        for (npe5__Affiliation__c currRec : affiliationList) {
            if (!(contactsMap.containsKey(currRec.npe5__Contact__c))) {
                currRec.npe5__Primary__c = true;
            }

            if (currRec.npe5__Contact__c != null && getContactRecType.containsKey(currRec.npe5__Contact__c)) {
                if (getContactRecType.get(currRec.npe5__Contact__c).RecordTypeId != VOLUNTEER_RECORD_TYPE_ID) {
                    currRec.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
                } else {
                    currRec.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
                }
            }
        }
    }

    /**
     * @description This is used to get affiliation's corresponding username and email to merge in active user welcome email template
     * @param beforeUpdateList
     * @param oldMapBeforeUpdate
     */
    public static void setHiddenUserFields(List<npe5__Affiliation__c> beforeUpdateList, Map<Id, npe5__Affiliation__c> oldMapBeforeUpdate) {
        if (RecursiveTriggerHandler.blockBeforeUpdate) {
            return;
        }
        Set<Id> contactIdsSet = new Set<Id>();
        Map<Id, User>volunteerUserMap = new Map<Id, User>();
        for (npe5__Affiliation__c currRec : beforeUpdateList) {
            if ((currRec.npe5__Status__c != null && currRec.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE)
                    && (oldMapBeforeUpdate.get(currRec.Id).npe5__Status__c != currRec.npe5__Status__c)) {
                contactIdsSet.add(currRec.npe5__Contact__c);
            }
        }
        if (contactIdsSet.isEmpty()) {
            return;
        }
        for (User currUser : [
                SELECT Id, Username, ContactId, Email
                FROM User
                WHERE ContactId IN :contactIdsSet
        ]) {
            if (contactIdsSet.contains(currUser.ContactId)) {
                volunteerUserMap.put(currUser.ContactId, currUser);
            }
        }

        for (npe5__Affiliation__c currRec : beforeUpdateList) {
            if ((currRec.npe5__Status__c != null && currRec.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE)
                    && (volunteerUserMap.containsKey(currRec.npe5__Contact__c))) {
                currRec.User_Name_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Username;
                currRec.User_Email_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Email;
            }
        }
    }

    /**
     * @description Add the user to the public group to access the approved In-Kind donor account record based on the affiliation record
     * @param upsertList
     */
    public static void addToPublicGroup(List<npe5__Affiliation__c> upsertList) {
        addToPublicGroup(upsertList, null);
    }

    /**
     * @description Add the user to the public group to access the approved In-Kind donor account record based on the affiliation record
     * @param upsertList
     * @param oldMapUpsert
     */
    public static void addToPublicGroup(List<npe5__Affiliation__c> upsertList, Map<Id, npe5__Affiliation__c> oldMapUpsert) {
        if (RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }
        Map<Id, npe5__Affiliation__c> affiliationMap = new Map<Id, npe5__Affiliation__c>();
        Set<Id> affiliationIds = new Set<Id>();
        Set<String> volunteerNameSet = new Set<String>();
        Set<String> chapterNameSet = new Set<String>();
        Set<Id> affiliationSet = new Set<Id>();
        Map<Id, String> affiliationRecMap = new Map<Id, String>();
        Boolean createUserGroup;

        for (npe5__Affiliation__c currRec : upsertList) {
            if (oldMapUpsert == null
                    || currRec.npe5__Status__c != oldMapUpsert.get(currRec.Id).npe5__Status__c || currRec.Constituent_Code__c != oldMapUpsert.get(currRec.Id).Constituent_Code__c) {
                affiliationMap.put(currRec.npe5__Contact__c, currRec);
                affiliationIds.add(currRec.npe5__Organization__c);
            }

            // Only runs on insert
            if (oldMapUpsert == null && currRec.npe5__Contact__c != null && currRec.npe5__Organization__c != null) {
                volunteerNameSet.add(currRec.npe5__Contact__c);
                chapterNameSet.add(currRec.npe5__Organization__c);
                affiliationSet.add(currRec.Id);
                affiliationRecMap.put(currRec.Id, String.valueOf(currRec));
            }
        }
        if (affiliationMap.size() > 0 && RecursiveTriggerHandler.isFirstTime == true) {
            updateContact(affiliationMap, affiliationIds, upsertList);
        }

        if (volunteerNameSet.size() > 0 && chapterNameSet.size() > 0 && affiliationSet.size() > 0) {
            for (Contact dbVolunteerContact : [
                    SELECT Id, RecordTypeId, Name
                    FROM Contact
                    WHERE Id IN :volunteerNameSet AND RecordTypeId = :VOLUNTEER_RECORD_TYPE_ID
            ]) {
                if (dbVolunteerContact.Id != null) {
                    createUserGroup = true;
                    break;
                }
            }
            if (createUserGroup == true) {
                insertGroupMember(volunteerNameSet, chapterNameSet, affiliationSet, affiliationRecMap);
            }
        }
    }

    /**
    * @description Used to add a user to chatter group based on their chapter when the volunteer become active.
    * @param volunteerContactIdsSet
    * @param affiliationsIdsSet
    * @param exceptionList
    */
    public static void addUserToChapterGroup(Set<Id> volunteerContactIdsSet, Set<Id> affiliationsIdsSet, List<npe5__Affiliation__c> exceptionList) {
        try {
            Map<Id, String> volunteerChaptersMap = new Map<Id, String>();
            Set<String> chapterNamesSet = new Set<String>();
            Map<Id, Id> volunteerUsersMap = new Map<Id, Id>();
            Map<String, Id> chatterGroupNameIdsMap = new Map<String, Id>();
            List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();

            for (npe5__Affiliation__c getChapters : [
                    SELECT Id, npe5__Organization__r.Name, npe5__Contact__c
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c IN :volunteerContactIdsSet AND Id IN :affiliationsIdsSet
            ]) {
                if (!chapterNamesSet.contains(getChapters.npe5__Organization__r.Name)) {
                    chapterNamesSet.add(String.valueOf(getChapters.npe5__Organization__r.Name).removeStart(PREFIX_STRING_MAKE_A_WISH));
                }
                volunteerChaptersMap.put(getChapters.npe5__Contact__c, String.valueOf(getChapters.npe5__Organization__r.Name).removeStart(PREFIX_STRING_MAKE_A_WISH));
            }

            // Used to get volunteer user id and volunteer contact id
            for (User relatedUsers : [
                    SELECT Id, ContactId
                    FROM User
                    WHERE ContactId IN :volunteerContactIdsSet
            ]) {
                volunteerUsersMap.put(relatedUsers.ContactId, relatedUsers.Id);
            }
            if (chapterNamesSet.size() > 0) {
                // Used to get the group name based on the chapter names
                for (CollaborationGroup collaborationGroup : [
                        SELECT Id, Name
                        FROM CollaborationGroup
                        WHERE Name IN :chapterNamesSet
                ]) {
                    chatterGroupNameIdsMap.put(collaborationGroup.Name, collaborationGroup.Id);
                }
            }
            Set<String> chatterGroupsMembersSet = new Set<String>();
            for (CollaborationGroupMember chatterGroupMemberExistCheck : [
                    SELECT Id, MemberId, CollaborationGroupId
                    FROM CollaborationGroupMember
                    WHERE MemberId IN :volunteerUsersMap.values()
            ]) {
                chatterGroupsMembersSet.add(chatterGroupMemberExistCheck.CollaborationGroupId + '-' + chatterGroupMemberExistCheck.MemberId);
            }
            //Used to check whether a user exists in the chatter group before adding the user to group
            for (Id volunteerContact : volunteerContactIdsSet) {
                if (volunteerChaptersMap.containsKey(volunteerContact) && chatterGroupNameIdsMap.containsKey(volunteerChaptersMap.get(volunteerContact)) && volunteerChaptersMap.containsKey(volunteerContact)) {
                    if (!chatterGroupsMembersSet.contains(chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)) + '-' + volunteerUsersMap.get(volunteerContact)) && volunteerUsersMap.containsKey(volunteerContact)) {
                        chatterGroupMembersList.add(new CollaborationGroupMember (CollaborationGroupId = chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)), MemberId = volunteerUsersMap.get(volunteerContact)));
                    }
                }
            }
            if (!Test.isRunningTest()) {
                insert chatterGroupMembersList;
            } else {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (npe5__Affiliation__c currRec : exceptionList) {
                ErrorMessage_AC.createDebugRec('AffiliationService', String.valueOf(currRec), String.valueOf(ex), 'addUserToChapterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (npe5__Affiliation__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * @description Add user to chatter group when a user becomes active to particular chapter
     * @param afterUpdateList
     * @param oldMapAfterUpdate
     */
    public static void addToChatterGroup(List<npe5__Affiliation__c> afterUpdateList, Map<Id, npe5__Affiliation__c> oldMapAfterUpdate) {
        if (RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }
        List<npe5__Affiliation__c> affiliationsList = new List<npe5__Affiliation__c>();
        Set<Id> affiliationsIdsSet = new Set<Id>();
        Set<Id> volunteerContactIdsSet = new Set<Id>();
        Set<Id> volunteerContactIdSet = new Set<Id>();
        Set<Id> activeVolunteerIdSet = new Set<Id>();
        for (npe5__Affiliation__c modifiedAffiliation : afterUpdateList) {
            if (modifiedAffiliation.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE
                    && oldMapAfterUpdate.get(modifiedAffiliation.Id).npe5__Status__c != modifiedAffiliation.npe5__Status__c) {
                volunteerContactIdsSet.add(modifiedAffiliation.npe5__Contact__c);
                affiliationsList.add(modifiedAffiliation);
                affiliationsIdsSet.add(modifiedAffiliation.Id);
            }
            if (modifiedAffiliation.npe5__Status__c != Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE
                    && oldMapAfterUpdate.get(modifiedAffiliation.Id).npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
                volunteerContactIdSet.add(modifiedAffiliation.npe5__Contact__c);
            }
            if (modifiedAffiliation.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE
                    && oldMapAfterUpdate.get(modifiedAffiliation.Id).npe5__Status__c != Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
                activeVolunteerIdSet.add(modifiedAffiliation.npe5__Contact__c);
            }
        }
        if (affiliationsList.size() > 0 && volunteerContactIdsSet.size() > 0 && affiliationsIdsSet.size() > 0) {
            addUserToChapterGroup(volunteerContactIdsSet, affiliationsIdsSet, afterUpdateList);
        }
        if (volunteerContactIdSet.size() > 0 && volunteerContactIdSet != null) {
            inactiveAffiliations(volunteerContactIdSet, afterUpdateList);
        }
        if (activeVolunteerIdSet.size() > 0) {
            activeAffiliations(activeVolunteerIdSet, afterUpdateList);
        }
    }

    /**
     * @description Used to remove a user from group based on their affiliation when the affiliation deleted.
     * @param volunteerNameSet
     * @param chapterNameSet
     * @param exceptionMap
     */
    @Future
    public static void removeMemberFromGroup(Set<String> volunteerNameSet, Set<String> chapterNameSet, Map<Id, String> exceptionMap) {
        try {
            Map<String, Id> publicGroupMap = new Map<String, Id>();
            Map<Id, Id> userMap = new Map<Id, Id>();
            Map<Id, String> groupNameMap = new Map<Id, String>();
            List<GroupMember> grpList = new List<GroupMember>();
            for (Account chapterName : [
                    SELECT Id, Name
                    FROM Account
                    WHERE Id IN :chapterNameSet
            ]) {
                String groupNameTrim = chapterName.Name.removeStart(PREFIX_STRING_MAKE_A_WISH);
                groupNameMap.put(chapterName.Id, groupNameTrim);
            }
            for (User currentUser : [
                    SELECT Id, ContactId
                    FROM User
                    WHERE ContactId IN :volunteerNameSet
            ]) {
                userMap.put(currentUser.ContactId, currentUser.Id);
            }

            for (GroupMember currentMember : [
                    SELECT Id, GroupId, UserOrGroupId
                    FROM GroupMember
                    WHERE GroupId IN :publicGroupMap.values() AND UserOrGroupId IN :userMap.values()
                    AND Group.Type = :Constant_AC.GROUP_TYPE_REGULAR AND Group.Name IN :groupNameMap.values()
            ]) {
                grpList.add(currentMember);
            }
            delete grpList;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AffiliationService', exceptionMap.get(currRec), String.valueOf(ex), 'removeMemberFromGroup', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    //used to update the status field in contact for reporting purpose
    private static void updateContact(Map<Id, npe5__Affiliation__c> contactMap, Set<Id> affiliationIds, List<npe5__Affiliation__c> exceptionList) {
        try {
            RecursiveTriggerHandler.isFirstTime = false;
            Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
            Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
            Id familyContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
            Id MedicalProfContactRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
            Id boardMemberRT = Constant_AC.BOARD_MEMBER_RT_ID;
            Id chapterRT = Constant_AC.CHAPTER_RT_ID;
            List<Contact> conList = [
                    SELECT Id, Hidden_Status__c, RecordTypeId, RecordType.Name
                    FROM Contact
                    WHERE Id IN :contactMap.keySet()
            ];
            Map<Id, Account> accountMap = new Map<Id, Account>([
                    SELECT Id, RecordTypeId
                    FROM Account
                    WHERE Id IN :affiliationIds
            ]);

            Map<String, Integer> recordTypeOrder = new Map<String, Integer>();
            recordTypeOrder.put(Constant_AC.BOARD_MEMBER_RT_LABEL, 1);
            recordTypeOrder.put(Constant_AC.VOLUNTEER_TASK_RT_LABEL, 2);
            recordTypeOrder.put(Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL, 3);
            recordTypeOrder.put(Constant_AC.CONTACT_WISH_CHILD_RT_LABEL, 4);
            recordTypeOrder.put(Constant_AC.WISH_FAMILY_RT_LABEL, 5);

            Map<Id, String> recordTypeNames = new Map<Id, String>();
            recordTypeNames.put(volunteerRecordTypeId, Constant_AC.VOLUNTEER_TASK_RT_LABEL);
            recordTypeNames.put(wishChildRecordTypeId, Constant_AC.CONTACT_WISH_CHILD_RT_LABEL);
            recordTypeNames.put(familyContactRecordTypeId, Constant_AC.WISH_FAMILY_RT_LABEL);
            recordTypeNames.put(MedicalProfContactRecordTypeId, Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL);
            recordTypeNames.put(boardMemberRT, Constant_AC.BOARD_MEMBER_RT_LABEL);

            Map<String, Id> recordTypes = new Map<String, Id>();
            for (Id recordTypeNameKey : recordTypeNames.keySet()) {
                recordTypes.put(recordTypeNames.get(recordTypeNameKey), recordTypeNameKey);
            }

            for (Contact currContact : conList) {
                npe5__Affiliation__c currAffiliation = contactMap.get(currContact.Id);
                currContact.Hidden_Status__c = currAffiliation.npe5__Status__c;

                if (currAffiliation.Constituent_Code__c != null && recordTypeNames.containsKey(currContact.RecordTypeId)
                        && currAffiliation.Constituent_Code__c != recordTypeNames.get(currContact.RecordTypeId)
                        && recordTypeOrder.get(currAffiliation.Constituent_Code__c) < recordTypeOrder.get(recordTypeNames.get(currContact.RecordTypeId))
                        && recordTypes.containsKey(currAffiliation.Constituent_Code__c) && accountMap.get(currAffiliation.npe5__Organization__c).RecordTypeId == chapterRT) {
                    currContact.RecordTypeId = recordTypes.get(currAffiliation.Constituent_Code__c);
                }
            }
            update conList;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (npe5__Affiliation__c currRec : exceptionList) {
                ErrorMessage_AC.createDebugRec('AccountService', String.valueOf(currRec), String.valueOf(ex), 'updateContact', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (npe5__Affiliation__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    private static void inactiveAffiliations(Set<Id> volunteerIdSet, List<npe5__Affiliation__c> exceptionList) {
        try {
            Set<Id> inactiveVolunteerIdSet = new Set<Id>();
            for (npe5__Affiliation__c currAff : [
                    SELECT Id, npe5__Status__c, npe5__Contact__c
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c IN :volunteerIdSet
            ]) {

                if (currAff.npe5__Status__c != Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
                    inactiveVolunteerIdSet.add(currAff.npe5__Contact__c);
                } else if (currAff.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE && inactiveVolunteerIdSet.contains(currAff.npe5__Contact__c)) {
                    inactiveVolunteerIdSet.remove(currAff.npe5__Contact__c);
                }
            }
            if (inactiveVolunteerIdSet.size() > 0) {
                updateBCandCOIVolunteerInactive(inactiveVolunteerIdSet, true, exceptionList);
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } catch (Exception ex) {
            for (npe5__Affiliation__c currRec : exceptionList) {
                ErrorMessage_AC.createDebugRec('AffiliationService', String.valueOf(currRec), String.valueOf(ex), 'inactiveAffiliations', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (npe5__Affiliation__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    private static void updateBCandCOIVolunteerInactive(Set<Id> inactiveVolunteerIdSet, Boolean isInactiveVolunteer, List<npe5__Affiliation__c> exceptionList) {
        try {
            List<Background_check__c> updateBCList = new List<Background_check__c>();
            List<Conflict_Of_Interest__c> updateCOIList = new List<Conflict_Of_Interest__c>();
            for (Background_check__c currBC : [
                    SELECT Id,Volunteer_is_Inactive__c
                    FROM Background_check__c
                    WHERE Volunteer__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
            ]) {
                currBC.Volunteer_is_Inactive__c = isInactiveVolunteer;
                updateBCList.add(currBC);
            }
            update updateBCList;
            for (Conflict_Of_Interest__c currCOI : [
                    SELECT Id,Volunteer_is_Inactive__c
                    FROM Conflict_Of_Interest__c
                    WHERE Volunteer_Contact__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
            ]) {
                currCOI.Volunteer_is_Inactive__c = isInactiveVolunteer;
                updateCOIList.add(currCOI);
            }
            update updateCOIList;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (npe5__Affiliation__c currRec : exceptionList) {
                ErrorMessage_AC.createDebugRec('AffiliationService', String.valueOf(currRec), String.valueOf(ex), 'updateBCandCOIVolunteerInactive', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (npe5__Affiliation__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }

        }
    }

    private static void activeAffiliations(Set<Id> volunteerIdsSet, List<npe5__Affiliation__c> exceptionList) {
        try {
            Set<Id> activeVolunteerIdSet = new Set<Id>();
            Set<Id> volunteerIdSet = new Set<Id>();
            for (npe5__Affiliation__c currAff : [
                    SELECT Id, npe5__Status__c, npe5__Contact__c
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c IN :volunteerIdsSet
            ]) {
                if (currAff.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
                    volunteerIdSet.add(currAff.npe5__Contact__c);
                }
            }
            if (volunteerIdSet.size() > 0) {
                for (User currUser : [
                        SELECT Id, ContactId
                        FROM User
                        WHERE ContactId IN :volunteerIdSet AND IsActive = TRUE
                ]) {
                    activeVolunteerIdSet.add(currUser.ContactId);
                }
                if (activeVolunteerIdSet.size() > 0) {
                    updateBCandCOIVolunteerInactive(activeVolunteerIdSet, false, exceptionList);
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (npe5__Affiliation__c currRec : exceptionList) {
                ErrorMessage_AC.createDebugRec('AffiliationService', String.valueOf(currRec), String.valueOf(ex), 'activeAffiliations', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (npe5__Affiliation__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    // Used to add a user to group based on their affiliation when the affiliation created.
    @Future
    private static void insertGroupMember(Set<String> volunteerNameSet, Set<String> chapterNameSet, Set<Id> affiliationSet, Map<Id, String> exceptionMap) {
        try {
            Map<Id, User> userMap = new Map<Id, User>();
            Map<Id, String> chapterNameMap = new Map<Id, String>();
            Map<String, Id> publicGroupMap = new Map<String, Id>();
            List<GroupMember> groupMemberList = new List<GroupMember>();
            if (volunteerNameSet.size() > 0) {
                for (User currentUser : [
                        SELECT Id, ContactId
                        FROM User
                        WHERE ContactId IN :volunteerNameSet
                ]) {
                    userMap.put(currentUser.ContactId, currentUser);
                }
            }
            if (chapterNameSet.size() > 0) {
                for (Account currentAccount : [
                        SELECT Id,Name
                        FROM Account
                        WHERE Id IN :chapterNameSet
                ]) {
                    String chapterNameTrim = currentAccount.Name.removeStart(PREFIX_STRING_MAKE_A_WISH);
                    chapterNameMap.put(currentAccount.Id, chapterNameTrim);
                }
            }
            for (Group currentGroup : [
                    SELECT Id, Name
                    FROM Group
                    WHERE Type = :Constant_AC.GROUP_TYPE_REGULAR
            ]) {
                publicGroupMap.put(currentGroup.Name, currentGroup.Id);
            }
            for (npe5__Affiliation__c currentRec : [
                    SELECT Id, Name, npe5__Organization__c, npe5__Contact__c
                    FROM npe5__Affiliation__c
                    WHERE Id IN :affiliationSet
            ]) {
                if (userMap.containsKey(currentRec.npe5__Contact__c) && chapterNameMap.containsKey(currentRec.npe5__Organization__c) && publicGroupMap.containsKey(chapterNameMap.get(currentRec.npe5__Organization__c))) {

                    GroupMember newGroupMem = new GroupMember();
                    newGroupMem.GroupId = publicGroupMap.get(chapterNameMap.get(currentRec.npe5__Organization__c));
                    newGroupMem.UserOrGroupId = userMap.get(currentRec.npe5__Contact__c).Id;
                    groupMemberList.add(newGroupMem);
                }
            }
            if (groupMemberList.size() > 0) {
                insert groupMemberList;
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AffiliationService', exceptionMap.get(currRec), String.valueOf(ex), 'insertGroupMember', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }
}