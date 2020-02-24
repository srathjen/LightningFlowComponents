/**
 * Created by mbuhler on 7/26/2019.
 */
@IsTest
public class SurveyRecipientServiceTest {

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Contact c1 = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Birthdate = System.now().addYears(-20).date()
        );
        insert c1;

        Contact c2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Birthdate = System.now().addYears(-20).date()
        );
        insert c2;
        
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
        
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;
        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void triggerInsert() {
        Test.startTest();
        Case c = [SELECT Id FROM Case][0];
        Contact con1 = [SELECT Id, Birthdate FROM Contact WHERE FirstName = 'Test1'][0];
        Contact con2 = [SELECT Id, Birthdate FROM Contact WHERE FirstName = 'Test2'][0];
        Wish_Affiliation__c wa1 = new Wish_Affiliation__c(
            Wish__c = c.Id,
            Contact__c = con1.Id,
            Survey_Recipient__c = true
        );
        insert wa1;
        Wish_Affiliation__c wa2 = new Wish_Affiliation__c(
            Wish__c = c.Id,
            Contact__c = con2.Id,
            Survey_Recipient__c = true
        );
        insert wa2;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Survey_Recipient__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(con2.Id, updatedCase.Survey_Recipient__c);
        Wish_Affiliation__c updatedWA1 = [SELECT Id, Survey_Recipient__c FROM Wish_Affiliation__c WHERE Id = :wa1.Id];
        System.assertEquals(false, updatedWA1.Survey_Recipient__c);
        Wish_Affiliation__c updatedWA2 = [SELECT Id, Survey_Recipient__c FROM Wish_Affiliation__c WHERE Id = :wa2.Id];
        System.assertEquals(true, updatedWA2.Survey_Recipient__c);
    }

    @IsTest
    public static void triggerUpdate() {
        Test.startTest();
        Case c = [SELECT Id FROM Case][0];
        Contact con1 = [SELECT Id FROM Contact WHERE FirstName = 'Test1'][0];
        Contact con2 = [SELECT Id FROM Contact WHERE FirstName = 'Test2'][0];
        Wish_Affiliation__c wa1 = new Wish_Affiliation__c(
            Wish__c = c.Id,
            Contact__c = con1.Id,
            Survey_Recipient__c = true
        );
        insert wa1;
        Wish_Affiliation__c wa2 = new Wish_Affiliation__c(
            Wish__c = c.Id,
            Contact__c = con2.Id,
            Survey_Recipient__c = false
        );
        insert wa2;
        wa2.Survey_Recipient__c = true;
        update wa2;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Survey_Recipient__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(con2.Id, updatedCase.Survey_Recipient__c);
        Wish_Affiliation__c updatedWA1 = [SELECT Id, Survey_Recipient__c FROM Wish_Affiliation__c WHERE Id = :wa1.Id];
        System.assertEquals(false, updatedWA1.Survey_Recipient__c);
        Wish_Affiliation__c updatedWA2 = [SELECT Id, Survey_Recipient__c FROM Wish_Affiliation__c WHERE Id = :wa2.Id];
        System.assertEquals(true, updatedWA2.Survey_Recipient__c);
    }

}