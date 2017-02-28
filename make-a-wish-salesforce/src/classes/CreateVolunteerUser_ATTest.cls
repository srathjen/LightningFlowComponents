/*******************************************************
Description : Test class for CreateVolunteerUser_AT Trigger
*****************************************************/

@isTest
public class CreateVolunteerUser_ATTest
{

    static  testmethod void CreateVolunteerUser()
    {
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountwithVolunteerManager();
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        
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
        volunteerCon.RecordTypeId = volunteerRecordTypeId;
        volunteerCon.AccountId = chapterAccount.id;
        
        insert volunteerCon;
    
    }

}