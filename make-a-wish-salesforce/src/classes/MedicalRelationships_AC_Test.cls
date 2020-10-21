/**
 * @author Steve Doucette, Traction on Demand 
 * @date 5/21/2020
 */

@IsTest
private class MedicalRelationships_AC_Test {

    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContact(2);
        contacts[1].RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        contacts[1].Region_Chapter__c = account.Id;
        insert contacts;

        Case c = TestDataFactory.createCase(1)[0];
        c.ContactId = contacts[0].Id;
        insert c;

        npe4__Relationship__c relationship = TestDataFactory.createRelationship(1)[0];
        relationship.npe4__Contact__c = contacts[0].Id;
        relationship.npe4__RelatedContact__c = contacts[1].Id;
        insert relationship;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void testNonEmptyList() {
        ApexPages.StandardController standardController = new ApexPages.StandardController([
                SELECT Id
                FROM Case
        ]);
        MedicalRelationships_AC controller = new MedicalRelationships_AC(standardController);
        System.assertEquals(false, controller.getMedicalRelationshipsConList().isEmpty());
    }

    @IsTest
    static void testError() {
        ApexPages.StandardController standardController = new ApexPages.StandardController([
                SELECT Id
                FROM Case
        ]);
        MedicalRelationships_AC controller = new MedicalRelationships_AC(standardController);
        controller.currCase = null;
        System.assertEquals(null, controller.getMedicalRelationshipsConList());
    }
}