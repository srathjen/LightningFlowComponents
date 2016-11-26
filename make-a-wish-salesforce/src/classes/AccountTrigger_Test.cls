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
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com'];
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
    
    //Inkind Approval Approved value Status change
    static testmethod void inKindApprovalStatus() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com'];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        System.RunAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
            inkindAccount.Chapter_Name__c = chapterAccount.Id;
            insert inkindAccount;
        }
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        List<Account> inKindAccount = [SELECT Id FROM Account WHERE RecordTypeId =: inKindDonorsAccountRTId];
        Account updateAcc = new Account();
        updateAcc.Id = inkindAccount[0].Id;
        updateAcc.In_Kind_Approval_Status__c = 'Approved';
        update updateAcc;
        
    }
    
    //Inkind Approval Rejected value Status change
    static testmethod void inKindApprovalRejectedStatus() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com'];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        System.RunAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
            inkindAccount.Chapter_Name__c = chapterAccount.Id;
            insert inkindAccount;
        }
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        List<Account> inKindAccount = [SELECT Id FROM Account WHERE RecordTypeId =: inKindDonorsAccountRTId];
        Account updateAcc = new Account();
        updateAcc.Id = inkindAccount[0].Id;
        updateAcc.In_Kind_Approval_Status__c = 'Rejected';
        update updateAcc;
        
    }
    
    
    
    
    
    
}