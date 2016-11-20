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
    
    static testmethod void approvedInKindDonorAccount() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com'];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
            inkindAccount.Chapter_Name__c = chapterAccount.Id;
            insert inkindAccount;
        System.runAs(sysAdmin) {
            List<ProcessInstanceWorkitem> listaAprobacionPendiente = [SELECT Id, ProcessInstance.TargetObjectId
                                                                      FROM ProcessInstanceWorkitem
                                                                      WHERE ProcessInstance.TargetObjectId =:inkindAccount.Id];
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
            req.setWorkitemId(listaAprobacionPendiente[0].Id);
            Approval.ProcessResult result = Approval.process(req);
            
            inkindAccount.In_Kind_Approval_Status__c = 'Approved';
            update inkindAccount;
        }
    }
    
    static testmethod void rejectedInKindDonorAccount() {
        User sysAdmin = [SELECT Id,userName,Email FROM User WHERE Email =: 'testmawa@gmail.com'];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
            inkindAccount.Chapter_Name__c = chapterAccount.Id;
            insert inkindAccount;
        System.runAs(sysAdmin) {
            List<ProcessInstanceWorkitem> listaAprobacionPendiente = [SELECT Id, ProcessInstance.TargetObjectId
                                                                      FROM ProcessInstanceWorkitem
                                                                      WHERE ProcessInstance.TargetObjectId =:inkindAccount.Id];
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
            req.setWorkitemId(listaAprobacionPendiente[0].Id);
            Approval.ProcessResult result = Approval.process(req);
            
            inkindAccount.In_Kind_Approval_Status__c = 'Rejected';
            update inkindAccount;
        }
    }
    
    
    
    
}