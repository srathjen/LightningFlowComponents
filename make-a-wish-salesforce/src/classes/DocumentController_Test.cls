@IsTest
public class DocumentController_Test {
    @IsTest
    static void testmethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        //inserting account records
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accounts;

        //inserting contact record.
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Board Member').getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = RecordTypeIdContact;
        con.FirstName = 'test';
        con.LastName = 'Volunteer';
        con.AccountId = account1.Id;
        con.Region_Chapter__c = account1.Id;
        insert con;

        //inserting background record.
        Background_check__c background = new Background_check__c();
        background.Volunteer__c = con.Id;
        background.Resided_in_US_for_past_7_years__c = 'yes';
        background.Order_Id__c = 'WPS-6991282';
        background.Package_Id__c = '041501';
        insert background;

        Test.startTest();
        PageReference pageRef = Page.BackgroundCheckPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(background.Id));
        ApexPages.StandardController stdController = new ApexPages.StandardController(background);
        DocumentController_AC controller = new DocumentController_AC(stdController);
        controller.redirect();

        controller.orderId = controller.packageId = null;
        controller.redirect();
        Test.stopTest();
    }
}