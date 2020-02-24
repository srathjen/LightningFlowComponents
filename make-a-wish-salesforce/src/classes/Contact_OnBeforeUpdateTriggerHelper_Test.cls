/**
 * Class Contact_OnBeforeUpdateTriggerHelper_Test
 *
 * A test class for Contact_OnBeforeUpdateTriggerHelper.
 *
 * Class is initially being created for code coverage only because the tested class was from a previous vendor and
 * it would take substantial effort to reverse engineer to determine the proper assertions to be writing for it.
 * If the tested class does not eventually get deprecated, this test class should be revised to include assertions.
 * Both the tested class and this test class do not meet acceptable best practice coding standards and are not an
 * example of the usual quality of code produced or endorsed by the individual author or Traction on Demand developers.
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2019-09-24
 */
@isTest
private class Contact_OnBeforeUpdateTriggerHelper_Test {
    private static final String HARD_CODED_PHONE = '9912121313'; // this value is hard coded in to the class being tested
    private static final String DUMMY_VALUE = Label.Dummy_Email; // unknown purpose at the time test class was written
    private static final String HARD_CODED_ZIP = '11111'; // another hard coded value in the class being tested

    @testSetup
    static void setup() {
        Contact wishFamilyContact = new Contact(
            RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID,
            FirstName = 'WishFamily',
            LastName = 'Contact',
            Hidden_First_Name__c = 'abc',
            Hidden_Last_Name__c = 'abc',
            Hidden_Phone__c = '123',
            HiddenMobilePhone__c = '123',
            Hidden_Work_Phone__c = '123',
            HiddenOtherPhone__c = '123',
            Hidden_Email__c = '123@abc.com',
            Hidden_Preferred_Phone_Types__c = 'abc',
            Hidden_Street__c = '123',
            Hidden_city__c = 'abc',
            Hidden_State__c = 'ab',
            Hidden_Country__c = 'abc',
            Hidden_Zip_Code__c = '85001',
            Hidden_Use_as_Household_Address__c = true,
            Hidden_Same_Address__c = true
        );
        insert wishFamilyContact;

        Contact wishChildContact = new Contact(
            RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID,
            FirstName = 'WishChild',
            LastName = 'Contact'
        );
        insert wishChildContact;

        npe4__Relationship__c relationship = new npe4__Relationship__c(
            npe4__Contact__c = wishChildContact.Id,
            npe4__RelatedContact__c = wishFamilyContact.Id
        );
        insert relationship;
    }

    @isTest
    static void coverUpdateFamilyConInfo() {
        Contact wishFamilyContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'WishFamily'];
        Contact wishChildContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'WishChild'];
        List<npe4__Relationship__c> relationships = [SELECT Id FROM npe4__Relationship__c];

        Set<Id> wishChildIdSet = new Set<Id>{wishChildContact.Id};
        Map<Id, Contact> relationshipIdMap = new Map<Id, Contact>();
        relationshipIdMap.put(relationships[0].Id, wishFamilyContact);
        relationshipIdMap.put(relationships[1].Id, wishChildContact);
        Set<Id> removePrefIdSet = new Set<Id>();

        Test.startTest();
        Contact_OnBeforeUpdateTriggerHelper.updateFamilyConInfo(wishChildIdSet, relationshipIdMap, removePrefIdSet);
        Test.stopTest();
    }

    @isTest
    static void coverUpdateFamilyConInfoOtherValues() {
        Contact wishFamilyContact = [SELECT Id, Name, Hidden_Phone__c, HiddenMobilePhone__c, Hidden_Work_Phone__c, HiddenOtherPhone__c,
            Hidden_Email__c, Hidden_Preferred_Phone_Types__c, Hidden_Street__c, Hidden_city__c, Hidden_State__c, Hidden_Country__c,
            Hidden_Zip_Code__c, Hidden_Use_as_Household_Address__c, Hidden_Same_Address__c FROM Contact WHERE FirstName = 'WishFamily'
        ];
        wishFamilyContact.Hidden_Phone__c = HARD_CODED_PHONE;
        wishFamilyContact.HiddenMobilePhone__c = HARD_CODED_PHONE;
        wishFamilyContact.Hidden_Work_Phone__c = HARD_CODED_PHONE;
        wishFamilyContact.HiddenOtherPhone__c = HARD_CODED_PHONE;
        wishFamilyContact.Hidden_Email__c = DUMMY_VALUE;
        wishFamilyContact.Hidden_Preferred_Phone_Types__c = DUMMY_VALUE;
        wishFamilyContact.Hidden_Street__c = DUMMY_VALUE;
        wishFamilyContact.Hidden_City__c = DUMMY_VALUE;
        wishFamilyContact.Hidden_Country__c = DUMMY_VALUE.substring(0, 20);
        wishFamilyContact.Hidden_Zip_Code__c = HARD_CODED_ZIP;
        wishFamilyContact.Hidden_Use_as_Household_Address__c = false;
        wishFamilyContact.Hidden_Same_Address__c = false;
        update wishFamilyContact;

        Contact wishChildContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'WishChild'];
        List<npe4__Relationship__c> relationships = [SELECT Id FROM npe4__Relationship__c];

        Set<Id> wishChildIdSet = new Set<Id>{wishChildContact.Id};
        Map<Id, Contact> relationshipIdMap = new Map<Id, Contact>();
        relationshipIdMap.put(relationships[0].Id, wishFamilyContact);
        relationshipIdMap.put(relationships[1].Id, wishChildContact);
        Set<Id> removePrefIdSet = new Set<Id>();

        Test.startTest();
        Contact_OnBeforeUpdateTriggerHelper.updateFamilyConInfo(wishChildIdSet, relationshipIdMap, removePrefIdSet);
        Test.stopTest();
    }

    @isTest
    static void coverRecallApproval() {
        Contact wishChildContact = [SELECT Id, Name FROM Contact WHERE FirstName = 'WishChild'];
        Contact wishFamilyContact = [SELECT Id, Hidden_First_Name__c FROM Contact WHERE FirstName = 'WishFamily'];
        wishFamilyContact.Hidden_First_Name__c = 'abc';
        update wishFamilyContact;

        Set<Id> recallWishIdSet = new Set<Id>();
        recallWishIdSet.add(wishChildContact.Id);

        Test.startTest();
        Contact_OnBeforeUpdateTriggerHelper.recallApproval(recallWishIdSet);
        Test.stopTest();
    }
}