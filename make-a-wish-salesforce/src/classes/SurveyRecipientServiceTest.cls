/**
 * @description Created by mbuhler on 7/26/2019.
 */
@IsTest
public class SurveyRecipientServiceTest {

    @IsTest
    public static void testFunctionality() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Contact> contacts =  TestDataFactory.createContact(3);
        contacts[0].Birthdate = contacts[1].Birthdate = System.now().addYears(-20).date();
        Contact wishChild = contacts[2];
        wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        insert contacts;

        Case c = TestDataFactory.createCase(1)[0];
        c.ContactId = wishChild.Id;
        c.RecordTypeId = Constant_AC.WISH_RT_ID;
        insert c;

        trac_TriggerHandlerBase.blockTrigger = false;

        Test.startTest();
        Wish_Affiliation__c wa1 = new Wish_Affiliation__c(
                Wish__c = c.Id,
                Contact__c = contacts[0].Id,
                Survey_Recipient__c = true
        );
        Wish_Affiliation__c wa2 = new Wish_Affiliation__c(
                Wish__c = c.Id,
                Contact__c = contacts[1].Id,
                Survey_Recipient__c = false
        );
        insert new List<Wish_Affiliation__c>{
                wa1, wa2
        };
        wa2.Survey_Recipient__c = true;
        update wa2;
        update wa2; // Cover nothing to do scenario
        Test.stopTest();

        Case updatedCase = [
                SELECT Id, Survey_Recipient__c
                FROM Case
                WHERE Id = :c.Id
        ];
        System.assertEquals(contacts[1].Id, updatedCase.Survey_Recipient__c);
        Wish_Affiliation__c updatedWA1 = [
                SELECT Id, Survey_Recipient__c
                FROM Wish_Affiliation__c
                WHERE Id = :wa1.Id
        ];
        System.assertEquals(false, updatedWA1.Survey_Recipient__c);

        Wish_Affiliation__c updatedWA2 = [
                SELECT Id, Survey_Recipient__c
                FROM Wish_Affiliation__c
                WHERE Id = :wa2.Id
        ];
        System.assertEquals(true, updatedWA2.Survey_Recipient__c);
    }
}