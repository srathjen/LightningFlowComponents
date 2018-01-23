/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : 
*******************************************************************************************************************/
@isTest
public class AccountTrigger_Test {
    
    @testSetup static void createRecords(){
        OrientationandTrainingUtil.createrSystemAdminUser();
        
    }
    
    
    static testmethod void inKindDonor() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        System.RunAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
            inkindAccount.Chapter_Name__c = chapterAccount.Id;
            insert inkindAccount;
        }
    }
    
    static testmethod void inKindDonorUpdateChapterName() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        Constant_AC  constant = new Constant_AC();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        Account newchapterAccount = new Account(Name = 'InKind Account', RecordTypeId = inKindDonorsAccountRTId,Chapter_Name__c = chapterAccount.Id);
        insert newchapterAccount;
        newchapterAccount.In_Kind_Approval_Status__c = 'Rejected';
        update newchapterAccount;
  
    }
    
    static testmethod void inKindDonorUpdateNullChapterName() {
        Constant_AC  constant = new Constant_AC();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        Account newchapterAccount = new Account(Name = 'InKind Account', RecordTypeId = inKindDonorsAccountRTId,Chapter_Name__c = chapterAccount.Id);
        insert newchapterAccount;
        newchapterAccount.In_Kind_Approval_Status__c = 'Approved';
        update newchapterAccount;
        
    }
    
    //Account with wishCoordinator Not Null
    static testmethod void wishCoordinatorNotNull() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        System.RunAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            
            try {
                insert inkindAccount;
            } catch (Exception e) {
                Boolean expectedExceptionThrown =  (e.getMessage().contains('There is no approver for this account.')) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
        }
    }
    
    //Account and wishCoordinator as null
    static testmethod void accountWishCoordinatorAsNull() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        chapterAccount.Wish_Co_ordinator__c = null;
        update chapterAccount;
        chapterAccount.Wish_Co_ordinator__c = userinfo.getUserId();
        update chapterAccount;
        chapterAccount.Wish_Co_ordinator__c = sysAdmin.id;
        update chapterAccount;
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        System.RunAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            Database.SaveResult result = Database.insert(inkindAccount, false);
            // System.assertEquals('There is no approver for this account.',result.getErrors()[0].getMessage());
            
        }
    }
    
    //Account and wishCoordinator as null
    static testmethod void chapterName() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        System.RunAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            insert inkindAccount;
        }
    }
    
    static testmethod void AddFlagonHouseHoldAccount(){
        Bypass_Triggers__c turnOnHouseHold = new Bypass_Triggers__c();
        turnOnHouseHold.setupownerId = userinfo.getUserId();
        insert turnOnHousehold;
        Account chapterAccount = OrientationandTrainingUtil.HouseHoldAccount();
    }
    
    static testmethod void updateChapterAccountDevEmail() {
         User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com' limit 1];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ChapterName__c = chapterAccount.id;
        parentCase.Closed_Date__c = system.today();
        insert parentCase;
        Contact wishChildCon = OrientationandTrainingUtil.CreateWishChildCon();
        Case wishGranting = OrientationandTrainingUtil.createWishGrantCase(wishChildCon.id,parentCase.id);
        chapterAccount.DevStaffEmail__c = 'chandru.406@gmail.com';
        update chapterAccount;
        }
}