/**
 * @description Test class for Background Check Service
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/19/2020
 */
@isTest
private class BackgroundCheckServiceTest {
    
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static String AFFILIATION_STATUS_INACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
    private final static String AFFILIATION_STATUS_NOT_APPROVED = Constant_AC.ORG_AFFILIATION_STATUS_NOT_APPROVED;
    private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
    private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static String BACKGROUND_CHECK_STATUS_MANUAL = Constant_AC.BACKGROUND_CHECK_STATUS_MANUAL;
    private final static String BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE = Constant_AC.BACKGROUND_CHECK_STATUS_FIRST_ADVANTAGE;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
    private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
    private final static String TASK_SUBJECT_REVIEW_BACKGROUND_CHECK = Constant_AC.TASK_SUBJECT_REVIEW_BACKGROUND_CHECK;
    
    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RT_ID;
        insert accounts;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
        Contact contact1 = contactList.get(0);
        contact1.FirstName = 'Joe';
        contact1.LastName = 'Marco';
        contact1.Email = 'Test.Mawa@gmail.com';
        contact1.RecordTypeId = VOLUNTEER_RT_ID;
        contact1.AccountId = accounts.get(0).Id;
        insert contactList;
        
        List<Background_check__c> backgroundCheckList = TestDataFactory.createBackgroundCheck(3);
        Background_check__c check1 = backgroundCheckList.get(0);
        check1.Current__c = true;
        check1.Status__c = BACKGROUND_CHECK_STATUS_MANUAL;
        check1.Date_Completed__c = Date.today();
        check1.Date__c = Date.today().addDays(7);
        check1.Volunteer__c = contactList.get(0).Id;
        Background_check__c check2 = backgroundCheckList.get(1);
        check2.Current__c = true;
        check2.Volunteer__c = contactList.get(0).Id;
        Background_check__c check3 = backgroundCheckList.get(2);
        check3.Volunteer__c = contactList.get(0).Id;
        check3.Status__c = BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE;
        insert backgroundCheckList;
        
        List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(1);
        npe5__Affiliation__c affiliation1 = affiliationList.get(0);
        affiliation1.npe5__Contact__c = contact1.Id;
        affiliation1.npe5__Status__c = AFFILIATION_STATUS_INACTIVE;
        affiliation1.npe5__Organization__c = account1.Id;
        insert affiliationList;
        
        List<Conflict_Of_Interest__c> conflictList = TestDataFactory.createConflictOfInterest(1);
        Conflict_Of_Interest__c conflict1 = conflictList.get(0);
        conflict1.Volunteer_Contact__c = contact1.Id;
        conflict1.Expiration_Date__c = Date.today().addDays(30);
        insert conflictList;
        
        List<Role__c> roleList = TestDataFactory.createRole(1, true);
        Role__c role1 = roleList.get(0);
        role1.Name = 'Wish Granter';
        insert roleList;
        
        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(1);
        Chapter_Role__c chapterRole1 = chapterRoleList.get(0);
        chapterRole1.Chapter_Name__c = account1.Id;
        chapterRole1.Role_Name__c = role1.Id;
        chapterRole1.Background_Check_Required__c = true;
        insert chapterRoleList;
        
        List<Volunteer_Roles__c> volunteerRolesList = TestDataFactory.createVolunteerRole(1);
        Volunteer_Roles__c volRole1 = volunteerRolesList.get(0);
        volRole1.Volunteer_Name__c = contact1.Id;
        volRole1.Chapter_Role__c = chapterRole1.Id;
        volRole1.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
        volRole1.Hidden_Previous_Status__c = VOLUNTEER_ROLE_STATUS_FORMER;
        insert volunteerRolesList;
        
        List<Orientation_Training__c> orientationTrainingList = TestDataFactory.createOrientationTraining(1);
        Orientation_Training__c orientationTraining1 = orientationTrainingList.get(0);
        orientationTraining1.Chapter_Name__c = account1.Id;
        insert orientationTrainingList;
        
        List<Chapter_Role_O_T__c> chapterOrientationTrainingList = TestDataFactory.createChapterRoleOrientationAndTraining(1);
        Chapter_Role_O_T__c chapterOrientationTraining1 = chapterOrientationTrainingList.get(0);
        chapterOrientationTraining1.Chapter_Role__c = chapterRole1.Id;
        chapterOrientationTraining1.Orientation_Training__c = orientationTraining1.Id;
        chapterOrientationTraining1.Required__c = true;
        insert chapterOrientationTrainingList;
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest 
    private static void validateUpdateHiddenEmailAndOwner(){
        Test.startTest();
        Contact contact = [SELECT Id 
                           FROM Contact 
                           WHERE Name = 'Joe Marco' 
                           LIMIT 1];
        Set<Id> contactId = new Set<Id>();
        contactId.add(contact.Id);
        List<Background_check__c> backgroundCheckList = [SELECT Id, OwnerId, Volunteer__c, 
                                                         Hidden_Volunteer_Contact_Email__c 
                                                         FROM Background_check__c];
        List<Background_check__c> updatedBackgroundCheckList = BackgroundCheckService.updateHiddenEmailAndOwner(contactId, backgroundCheckList);
        Test.stopTest();
        System.assert(updatedBackgroundCheckList[0].Hidden_Volunteer_Contact_Email__c != null);
    }
    
    @isTest
    private static void validateDeactivateBackgroundCheck() {
        Test.startTest();
        List<Background_check__c> backgroundCheckList = [SELECT Id, Current__c, Volunteer__c
                                                         FROM Background_check__c 
                                                         WHERE Current__c = true 
                                                         AND Volunteer__r.Name = 'Joe Marco' 
                                                         ORDER BY CreatedDate DESC];
        System.assert(backgroundCheckList.size() > 1);
        Map<Id, Id> backgroundCheckVolunteerMap = new Map<Id, Id>();
        backgroundCheckVolunteerMap.put(backgroundCheckList[0].Id, backgroundCheckList[0].Volunteer__c);
        BackgroundCheckService.deactivateBackgroundCheck(backgroundCheckVolunteerMap);
        Test.stopTest();
        List<Background_check__c> backgroundCheckUpdated = [SELECT Id, Current__c, Volunteer__c
                                                            FROM Background_check__c 
                                                            WHERE Current__c = true 
                                                            AND Volunteer__r.Name = 'Joe Marco'];
        System.assert(backgroundCheckUpdated.size() == 1);
    }
    
    @isTest
    private static void validateUpdateVolunteerExpirationDate() {
        Test.startTest();
        Contact contact = [SELECT Id 
                           FROM Contact 
                           WHERE Name = 'Joe Marco'];
        List<Background_check__c> backgroundCheckList = [SELECT Id, Current__c, Date__c, Volunteer__c 
                                                         FROM Background_check__c 
                                                         WHERE Current__c = true 
                                                         AND Date__c != null 
                                                         AND Volunteer__c = :contact.Id];
        
        BackgroundCheckService.updateVolunteerExpirationDate(backgroundCheckList);
        Test.stopTest();
        Contact contactUpdated = [SELECT Id, 
                                  B_C_Expiration_Date__c 
                                  FROM Contact WHERE Id = :contact.Id];
        System.assert(contactUpdated.B_C_Expiration_Date__c != null);
    }
    
    @isTest
    private static void validateUpdateAffiliationStatusNotApproved() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id 
                                                            FROM Contact 
                                                            WHERE Name = 'Joe Marco']);
        List<Background_check__c> backgroundCheckList = [SELECT Id, Status__c, Volunteer__c
                                                         FROM Background_check__c 
                                                         WHERE Volunteer__c IN :contactMap.keySet() 
                                                         AND Status__c != :BACKGROUND_CHECK_STATUS_REJECTED];
        Map<Id, Background_check__c> oldBackgroundCheckMap = new Map<Id, Background_check__c>();
        for(Background_check__c bc: backgroundCheckList) {
            Background_check__c oldbc = new Background_check__c(Id = bc.Id);
            oldbc.Status__c = bc.Status__c;
            oldBackgroundCheckMap.put(oldbc.Id, oldbc);
            bc.Status__c = BACKGROUND_CHECK_STATUS_REJECTED;
        }
        List<npe5__Affiliation__c> affiliation = [SELECT Id
                                                  FROM npe5__Affiliation__c 
                                                  WHERE npe5__Contact__c IN :contactMap.keySet() 
                                                  AND npe5__Status__c = :AFFILIATION_STATUS_NOT_APPROVED];
        System.assert(affiliation.isEmpty());
        BackgroundCheckService.updateAffiliationStatusNotApproved(backgroundCheckList, oldBackgroundCheckMap);
        Test.stopTest();
        affiliation = [SELECT Id
                       FROM npe5__Affiliation__c 
                       WHERE npe5__Contact__c IN :contactMap.keySet() 
                       AND npe5__Status__c = :AFFILIATION_STATUS_NOT_APPROVED];
        System.assert(!affiliation.isEmpty());
    }
    
    @isTest
    private static void validateUpdateVolunteerRoleStatus() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id 
                                                            FROM Contact 
                                                            WHERE Name = 'Joe Marco']);
        List<Background_check__c> backgroundCheckList = ([SELECT Id 
                                                          FROM Background_check__c
                                                          WHERE Volunteer__c IN :contactMap.keySet()]);
        Volunteer_Roles__c volRole = [SELECT Id, Status__c, Hidden_Previous_Status__c 
                                      FROM Volunteer_Roles__c 
                                      WHERE Volunteer_Name__c IN :contactMap.keySet()];
        BackgroundCheckService.updateVolunteerRoleStatus(contactMap.keySet(), backgroundCheckList);
        Test.stopTest();
        Volunteer_Roles__c volRoleUpdated = [SELECT Id, Status__c, Hidden_Previous_Status__c 
                                             FROM Volunteer_Roles__c 
                                             WHERE Volunteer_Name__c IN :contactMap.keySet()];
        System.assert(volRole.Hidden_Previous_Status__c == volRoleUpdated.Status__c);
    }
    
    @isTest
    private static void validateUpdateVolunteerOrientationStatus() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Hidden_Volunteer_OT_Status__c 
                                                            FROM Contact 
                                                            WHERE Name = 'Joe Marco']);
        List<Contact> contactList = contactMap.values();
        System.assert(contactList[0].Hidden_Volunteer_OT_Status__c == null);
        List<Background_check__c> backgroundCheckList = new List<Background_check__c>();
        Map<Id, Background_check__c> oldBackgroundCheckMap = new Map<Id, Background_check__c>();
        for(Background_check__c bc : [SELECT Id, Current__c, Status__c, Volunteer__c
                                      FROM Background_check__c
                                      WHERE Volunteer__c IN :contactMap.keySet() 
                                      AND Current__c = false]) {
            oldBackgroundCheckMap.put(bc.Id, bc);
            Background_check__c newBc = new Background_check__c(Id = bc.Id);
            newBc.Status__c = BACKGROUND_CHECK_STATUS_APPROVED;
            newBc.Current__c = true;
            newBc.Volunteer__c = bc.Volunteer__c;
            backgroundCheckList.add(newBc);
        }
        BackgroundCheckService.updateVolunteerOrientationStatus(backgroundCheckList, oldBackgroundCheckMap);
        Test.stopTest();
        List<Contact> updatedContactList = [SELECT Id, Hidden_Volunteer_OT_Status__c 
                                            FROM Contact 
                                            WHERE Name = 'Joe Marco'];
        System.assert(updatedContactList[0].Hidden_Volunteer_OT_Status__c != null);
    }
    
    @isTest
    private static void validateUpdateVolunteerRoleHiddenStatus() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Hidden_Volunteer_OT_Status__c 
                                                            FROM Contact 
                                                            WHERE Name = 'Joe Marco']);
        List<Background_check__c> backgroundCheckList = ([SELECT Id 
                                                          FROM Background_check__c
                                                          WHERE Volunteer__c IN :contactMap.keySet()]);
        Volunteer_Roles__c volRole = [SELECT Id, Status__c 
                                      FROM Volunteer_Roles__c 
                                      WHERE Volunteer_Name__c IN :contactMap.keySet()];
        volRole.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
        update volRole;
        BackgroundCheckService.updateVolunteerRoleHiddenStatus(contactMap.keySet(), 'backgroundcheck', backgroundCheckList);
        Test.stopTest();
        Volunteer_Roles__c volRoleUpdated = [SELECT Id, Status__c 
                                             FROM Volunteer_Roles__c 
                                             WHERE Volunteer_Name__c IN :contactMap.keySet()];
        System.assert(volRoleUpdated.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE);
    }
    
    @isTest
    private static void validateCreateBackgroundCheckReviewTask() {
        test.startTest();
        Map<Id, Background_check__c> backgroundCheckMap = new Map<Id, Background_check__c>([SELECT Id, Volunteer__c, OwnerId, Status__c
                                                                                            FROM Background_check__c 
                                                                                            WHERE Status__c = :BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE]);
        BackgroundCheckService.createBackgroundCheckReviewTask(backgroundCheckMap.values());
        test.stopTest();
        List<Task> taskList = [SELECT Id FROM Task 
                               WHERE WhatId IN :backgroundCheckMap.keySet() 
                               AND Subject = :TASK_SUBJECT_REVIEW_BACKGROUND_CHECK];
        System.assert(!taskList.isEmpty());
    }
}