/***********************************************************************
Description : Sharing the records to Chatper Staff with Read & Write permission 
for their corresponding chapter records.


Modification Log
----------------
SonarQube    Pavithra G 04/11/2018
************************************************************************/

public class ChapterStaffRecordSharing_AC {

    private static final String DEBUG_REC_TYPE = 'Error';

    /**
     * @param leadMap
     */
    public static void LeadSharing(Map<String, List<Lead>> leadMap) {
        try {
            Map<String, String> ChapterRoleMap = findChapterRole(leadMap.keySet());
            Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
            List<LeadShare> leadsToShare = new List<LeadShare>();
            for (String currChapter : leadMap.keySet()) {
                if (ChapterRoleMap.containsKey(currChapter) && userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Lead currLead : leadMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            LeadShare currSharing = new LeadShare();
                            currSharing.LeadId = currLead.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.LeadAccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.LeadShare.RowCause.Manual;
                            leadsToShare.add(currSharing);
                        }
                    }
                }
            }
            insert leadsToShare;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception ex) {
            for (String currChapter : leadMap.keySet()) {
                for (Lead currRec : leadMap.get(currChapter)) {
                    ErrorMessage_AC.createDebugRec('ChapterStaffRecordSharing_AC', String.valueOf(currRec), String.valueOf(ex), 'LeadSharing', currRec.Id, ex.getStackTraceString(), DEBUG_REC_TYPE);
                    if (!Test.isRunningTest()) {
                        currRec.addError(Label.Debug_log_error_message);
                    }
                }
            }
        }
    }

    /**
     * @param contactMap
     */
    public static void ContactSharing(Map<String, List<Contact>> contactMap) {
        try {
            Map<String, String> ChapterRoleMap = findChapterRole(contactMap.keySet());
            Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
            List<ContactShare> contactsToShare = new List<ContactShare>();
            for (String currChapter : contactMap.keySet()) {
                if (ChapterRoleMap.containsKey(currChapter)) {
                    if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                        for (Contact currCon : contactMap.get(currChapter)) {
                            for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                                if (currCon.OwnerId != currUser.Id) {
                                    ContactShare currSharing = new ContactShare();
                                    currSharing.ContactId = currCon.Id;
                                    currSharing.UserOrGroupId = currUser.Id;
                                    currSharing.ContactAccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                                    currSharing.RowCause = Schema.ContactShare.RowCause.Manual;
                                    contactsToShare.add(currSharing);
                                }
                            }
                        }
                    }
                }
            }
            Database.insert(contactsToShare, false);
            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception ex) {
            for (String currChapter : contactMap.keySet()) {
                for (Contact currRec : contactMap.get(currChapter)) {
                    ErrorMessage_AC.createDebugRec('ChapterStaffRecordSharing_AC', String.valueOf(currRec), String.valueOf(ex), 'ContactSharing', currRec.Id, ex.getStackTraceString(), DEBUG_REC_TYPE);
                    if (!Test.isRunningTest()) {
                        currRec.addError(Label.Debug_log_error_message);
                    }
                }
            }
        }
    }

    /**
     * @param accountMap
     */
    public static void AccountSharing(Map<String, List<Account>> accountMap) {
        try {
            Map<String, String> ChapterRoleMap = findChapterRole(accountMap.keySet());
            Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
            List<AccountShare> accountsToShare = new List<AccountShare>();
            for (String currChapter : accountMap.keySet()) {
                if (ChapterRoleMap.containsKey(currChapter)) {
                    if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                        for (Account currAcc : accountMap.get(currChapter)) {
                            for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                                AccountShare currSharing = new AccountShare();
                                currSharing.AccountId = currAcc.Id;
                                currSharing.UserOrGroupId = currUser.Id;
                                currSharing.AccountAccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                                currSharing.OpportunityAccessLevel = Constant_AC.RECORD_SHARE_READ;
                                currSharing.CaseAccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                                currSharing.ContactAccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                                currSharing.RowCause = Schema.AccountShare.RowCause.Manual;
                                accountsToShare.add(currSharing);
                            }
                        }
                    }
                }
            }
            Database.insert(accountsToShare, false);
            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception ex) {
            for (String currChapter : accountMap.keySet()) {
                for (Account currRec : accountMap.get(currChapter)) {
                    ErrorMessage_AC.createDebugRec('ChapterStaffRecordSharing_AC', String.valueOf(currRec), String.valueOf(ex), 'AccountSharing', currRec.Id, ex.getStackTraceString(), DEBUG_REC_TYPE);
                    if (!Test.isRunningTest()) {
                        currRec.addError(Label.Debug_log_error_message);
                    }
                }
            }
        }
    }

    /**
     * @param bgcRecordMap
     */
    public static void BGCRecordSharing(Map<String, List<Background_check__c>> bgcRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(bgcRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Background_check__Share> bgcToShare = new List<Background_check__Share>();
        for (String currChapter : bgcRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Background_check__c currBGC : bgcRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Background_check__Share currSharing = new Background_check__Share();
                            currSharing.ParentId = currBGC.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.Background_check__Share.RowCause.Manual;
                            bgcToShare.add(currSharing);
                        }
                    }
                }
            }
        }
        insert bgcToShare;
    }

    /**
     * @param coiRecordMap
     *
     * @return
     */
    public static List<Conflict_Of_Interest__Share> COIRecordSharing(Map<String, List<Conflict_Of_Interest__c>> coiRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(coiRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Conflict_Of_Interest__Share> coiToShare = new List<Conflict_Of_Interest__Share>();
        for (String currChapter : coiRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Conflict_Of_Interest__c currCOI : coiRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Conflict_Of_Interest__Share currSharing = new Conflict_Of_Interest__Share();
                            currSharing.ParentId = currCOI.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.Conflict_Of_Interest__Share.RowCause.Manual;
                            coiToShare.add(currSharing);
                        }
                    }
                }
            }
        }
        insert coiToShare;
        return coiToShare;
    }

    /**
     * @param broadRecordMap
     */
    public static void broadRecordSharing(Map<String, List<Broadcast__c>> broadRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(broadRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Broadcast__Share> broadcastToShare = new List<Broadcast__Share>();
        for (String currChapter : broadRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Broadcast__c currBroadcast : broadRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Broadcast__Share currSharing = new Broadcast__Share();
                            currSharing.ParentId = currBroadcast .Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_READ;
                            currSharing.RowCause = Schema.Broadcast__Share.RowCause.Manual;
                            broadcastToShare.add(currSharing);
                        }
                    }
                }
            }
        }
        insert broadcastToShare;
    }

    /**
     * @param chapterActionRecordMap
     */
    public static void chapterActionTrackSharing(Map<String, List<Chapter_Action_Track__c>> chapterActionRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(chapterActionRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Chapter_Action_Track__Share> chapterActionToShareList = new List<Chapter_Action_Track__Share>();
        for (String currChapter : chapterActionRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Chapter_Action_Track__c currRec : chapterActionRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Chapter_Action_Track__Share currSharing = new Chapter_Action_Track__Share();
                            currSharing.ParentId = currRec.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_READ;
                            currSharing.RowCause = Schema.Chapter_Action_Track__Share.RowCause.Manual;
                            chapterActionToShareList.add(currSharing);
                        }
                    }
                }
            }
        }
        insert chapterActionToShareList;
    }

    /**
     * @param chapterRoleRecordMap
     */
    public static void chapterRoleSharing(Map<String, List<Chapter_Role__c>> chapterRoleRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(chapterRoleRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Chapter_Role__Share> chapterRoleToShareList = new List<Chapter_Role__Share>();
        for (String currChapter : chapterRoleRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Chapter_Role__c currRec : chapterRoleRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Chapter_Role__Share currSharing = new Chapter_Role__Share();
                            currSharing.ParentId = currRec.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.Chapter_Role__Share.RowCause.Manual;
                            chapterRoleToShareList.add(currSharing);
                        }
                    }
                }
            }
        }
        insert chapterRoleToShareList;
    }

    /**
     * @param chapterRoleOTRecordMap
     */
    public static void chapterRoleOTSharing(Map<String, List<Chapter_Role_O_T__c>> chapterRoleOTRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(chapterRoleOTRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Chapter_Role_O_T__Share> chapterRoleOTToShareList = new List<Chapter_Role_O_T__Share>();
        for (String currChapter : chapterRoleOTRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Chapter_Role_O_T__c currRec : chapterRoleOTRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Chapter_Role_O_T__Share currSharing = new Chapter_Role_O_T__Share();
                            currSharing.ParentId = currRec.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.Chapter_Role_O_T__Share.RowCause.Manual;
                            chapterRoleOTToShareList.add(currSharing);
                        }
                    }
                }
            }
        }
        insert chapterRoleOTToShareList;
    }

    /**
     * @param classOfferingRecordMap
     */
    public static void classOfferingSharing(Map<String, List<Class_Offering__c>> classOfferingRecordMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(classOfferingRecordMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Class_Offering__Share> classOfferingShareList = new List<Class_Offering__Share>();
        for (String currChapter : classOfferingRecordMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Class_Offering__c currRec : classOfferingRecordMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Class_Offering__Share currSharing = new Class_Offering__Share();
                            currSharing.ParentId = currRec.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.Class_Offering__Share.RowCause.Manual;
                            classOfferingShareList.add(currSharing);
                        }
                    }
                }
            }

        }
        insert classOfferingShareList;
    }

    /**
     * @param volunteerOppRecordsMap
     */
    public static void volunteerOpportunitySharing(Map<String, List<Volunteer_Opportunity__c>> volunteerOppRecordsMap) {
        Map<String, String> ChapterRoleMap = findChapterRole(volunteerOppRecordsMap.keySet());
        Map<String, List<User>> userMap = userRecMap(ChapterRoleMap.values());
        List<Volunteer_Opportunity__Share> volunteerOppShareList = new List<Volunteer_Opportunity__Share>();
        for (String currChapter : volunteerOppRecordsMap.keySet()) {
            if (ChapterRoleMap.containsKey(currChapter)) {
                if (userMap.containsKey(ChapterRoleMap.get(currChapter))) {
                    for (Volunteer_Opportunity__c currRec : volunteerOppRecordsMap.get(currChapter)) {
                        for (User currUser : userMap.get(ChapterRoleMap.get(currChapter))) {
                            Volunteer_Opportunity__Share currSharing = new Volunteer_Opportunity__Share();
                            currSharing.ParentId = currRec.Id;
                            currSharing.UserOrGroupId = currUser.Id;
                            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
                            currSharing.RowCause = Schema.Volunteer_Opportunity__Share.RowCause.Manual;
                            volunteerOppShareList.add(currSharing);
                        }
                    }
                }
            }
        }
        insert volunteerOppShareList;
    }

    public static List<ContactShare> createContactSharing(Map<Id, Set<Id>> wishUserMap, Map<Id, Case> wishRelatedContactMap,
            Map<Id, Id> volunteerUserMap) {
        List<ContactShare> contactToShareList = new List<ContactShare>();
        if(wishUserMap.isEmpty()){
            return contactToShareList;
        }
        for (Id caseId : wishUserMap.keySet()) {
            if (wishUserMap.containsKey(caseId)) {
                for (Id userId : wishUserMap.get(caseId)) {
                    ContactShare shareContact = new ContactShare();
                    shareContact.ContactAccessLevel = 'Edit';
                    if (wishRelatedContactMap.containsKey(caseId)
                            && wishRelatedContactMap.get(caseId) != null) {
                        shareContact.ContactId = wishRelatedContactMap.get(caseId).ContactId;
                    }
                    if (volunteerUserMap.containsKey(userId)
                            && volunteerUserMap.get(userId) != null) {
                        shareContact.UserOrGroupId = volunteerUserMap.get(userId);
                        contactToShareList.add(shareContact);
                    }
                }
            }
        }
        insert contactToShareList;
        return contactToShareList;
    }

    /**
     * @param usersRole
     *
     * @return
     */
    public static Map<String, List<User>> userRecMap(List<String> usersRole) {
        if (usersRole.isEmpty()) {
            return new Map<String, List<User>>();
        }
        Map<String, List<User>> userMap = new Map<String, List<User>>();
        for (User currUser : [
                SELECT Id, UserRole.Name
                FROM User
                WHERE UserRole.Name IN :usersRole AND IsActive = TRUE
        ]) {
            if (userMap.containsKey(currUser.UserRole.Name)) {
                userMap.get(currUser.UserRole.Name).add(currUser);
            } else {
                userMap.put(currUser.UserRole.Name, new List<User>{
                        currUser
                });
            }
        }
        return userMap;
    }

    /**
     * @param chaptersSet
     *
     * @return Map of Chapter Name to Role Name
     */
    public static Map<String, String> findChapterRole(Set<String> chaptersSet) {
        if (chaptersSet.isEmpty()) {
            return new Map<String, String>();
        }
        Map<String, String> ChapterRoleMap = new Map<String, String>();
        for (Chapter_Vs_Role__c currChapterRole : [
                SELECT Chapter_Name__c, Role_Name__c
                FROM Chapter_Vs_Role__c
                WHERE Chapter_Name__c IN :chaptersSet
        ]) {
            ChapterRoleMap.put(currChapterRole.Chapter_Name__c, currChapterRole.Role_Name__c);
        }
        return ChapterRoleMap;
    }

    /**
     * This method is used to get the chapter name and user role name based on current record chapter.
     *
     * @param chapterIdSet Set of chater Id's
     *
     * @return Map of Chapter Name to Chapter's Id
     */
    public static Map<Id, String> getChapterName(Set<Id> chapterIdSet) {
        if (chapterIdSet.isEmpty()) {
            return new Map<Id, String>();
        }
        Map<String, Id> chapterNameMap = new Map<String, Id>();
        Map<Id, String> chapterIdUserRoleMap = new Map<Id, String>();
        for (Account currAcc : [
                SELECT Id,Name
                FROM Account
                WHERE Id IN :chapterIdSet
        ]) {
            chapterNameMap.put(currAcc.Name, currAcc.Id);
        }
        Map<String, String> chapterRoleNameMap = findChapterRole(chapterNameMap.keySet());
        for (String chapterName : chapterRoleNameMap.keySet()) {
            chapterIdUserRoleMap.put(chapterNameMap.get(chapterName), chapterRoleNameMap.get(chapterName));
        }
        return chapterIdUserRoleMap;
    }
    
    /**
    * Returns map of zip codes and chapter association
    * @param zipcodeList
    * @return zipcodeChapterMap
    */
    public static Map<String, Id> getChapterByZipcode(List<String> zipcodeList) {
        if(zipcodeList.isEmpty()) {
            return new Map<String, Id>();
        }
        Map<String, Id> zipcodeChapterMap = new Map<String, Id>();
        for(Zip_code__c zip : [SELECT Name, Office__r.Chapter__c FROM Zip_code__c WHERE Name IN :zipcodeList]) {
            zipcodeChapterMap.put(zip.Name, zip.Office__r.Chapter__c);
        }
        return zipcodeChapterMap;
    }
    
    /**
    * Returns map of chapter accounts and its name
    * @param accountIdSet
    * @return chapterNameMap
    */
    public static Map<Id, Account> getChapterNameById(Set<Id> accountIdSet) {
        if(accountIdSet.isEmpty()) {
            return new Map<Id, Account>();
        }
        Map<Id, Account> chapterNameMap = new Map<Id, Account>([
            SELECT Id, Name 
            FROM Account 
            WHERE Id IN :accountIdSet
        ]);
        return chapterNameMap;
    }
    
    /**
    * Returns map of chapter accounts and its intake manager
    * @param chapterIds
    * @param accountOwnerMap
    */
    public static Map<Id, Account> getAccountOwner(Set<Id> chapterIds) {
        if(chapterIds.isEmpty()) {
            return new Map<Id, Account>();
        }
        Map<Id, Account> accountOwnerMap = new Map<Id, Account>([
            SELECT Id, Intake_Manager__c
            FROM Account
            WHERE Id IN :chapterIds
            AND Intake_Manager__c != null
        ]);
        return accountOwnerMap;
    }
}