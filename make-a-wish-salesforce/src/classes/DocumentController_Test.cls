@isTest 
public class DocumentController_Test {
    static testmethod void testmethod1(){
        test.setMock(httpcalloutmock.class, new MockHttpResponseGenerator());
        List<Background_check__c>backgroundRec = new List<Background_check__c>();
        //inserting account records
        Account acc = new Account();
        acc.Name = 'Make-A-Wish Alabama';
        acc.Email__c='test@demo.com';
        acc.Chapter_Id__c ='041501';
        insert acc;
        //inserting contact record.
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Board Member').getRecordTypeId();
        contact con = new contact();
        con.RecordTypeId =RecordTypeIdContact;
        con.FirstName = 'test';
        con.LastName ='Volunteer';
        con.AccountId = acc.Id;
        con.Region_Chapter__c =acc.Id;
        insert con;
        //inserting background record.
        Background_check__c background = new Background_check__c();
        background.Volunteer__c = con.Id;
        background.Resided_in_US_for_past_7_years__c='yes';
        background.Order_Id__c = 'WPS-6991282';
        background.Package_Id__c ='041501';
        insert background;
        Test.startTest();
        PageReference pageRef = Page.BackgroundCheckPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(background.Id));
        Apexpages.StandardController stdController = new Apexpages.StandardController(background); 
        DocumentController_AC controller = new DocumentController_AC(stdController);
        controller.redirect();
        Test.stopTest();
    }
    
}