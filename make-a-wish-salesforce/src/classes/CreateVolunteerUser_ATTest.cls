/*******************************************************
Description : Test class for CreateVolunteerUser_AT Trigger
*****************************************************/

@isTest
public class CreateVolunteerUser_ATTest {

    static testmethod void CreateVolunteerUser() {
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountwithVolunteerManager();
        insert chapterAccount;
        
        Contact volunteerCon = new Contact();
        volunteerCon.Firstname = 'Test';
        VolunteerCon.LastName = 'Contact1';
        volunteerCon.Middle_Name__c = 'TestCon';
        volunteerCon.Email = 'TestVolunteerCon@con15.com';
        volunteerCon.MailingStreet  = 'ThillaiNagar';
        volunteerCon.MailingCity = 'Trichy';
        volunteerCon.MailingCountrycode = 'US';
        volunteerCon.MailingPostalCode = '35004';
        volunteerCon.mailingstatecode = 'AZ';
        volunteerCon.MobilePhone= '9003910426';
        volunteerCon.Migrated_Record__c = True;
        volunteerCon.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerCon.AccountId = chapterAccount.id;
        
        insert volunteerCon;
    }
    
    static testmethod void CreateVolunteerUserContatUpdated() {
        /*
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;
        
        Contact wishCon = new Contact();
        wishCon.Firstname = 'Test';
        wishCon.LastName = 'Contact1';
        wishCon.Middle_Name__c = 'TestCon';
        wishCon.Email = 'TestVolunteerCon@con15.com';
        wishCon.MailingStreet  = 'ThillaiNagar';
        wishCon.MailingCity = 'Trichy';
        wishCon.MailingCountrycode = 'US';
        wishCon.MailingPostalCode = '35004';
        wishCon.mailingstatecode = 'AZ';
        wishCon.MobilePhone= '9003910426';
        wishCon.Migrated_Record__c = True;
        wishCon.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishCon.AccountId = chapterAccount.id;
        insert wishCon;
        
        wishCon.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        update wishCon;
        */
    }
}