/**
 * @description Wish Affiliation Design Test Class
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 11/7/2019
 */
@IsTest
public with sharing class WishAffiliationDesign_AC_Test {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;

    @TestSetup
    public static void setUpData() {
        Wish_Affiliation_Security_Settings__c setting = new Wish_Affiliation_Security_Settings__c();
        setting.SetupOwnerId = UserInfo.getUserId();
        setting.Restrict_Access__c = true;
        insert setting;
        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        insert icdCode;
        List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
        List<Contact> contacts = new List<Contact>();
        Contact wishChildContact = contactsDataFactory.get(0);
        wishChildContact.FirstName = 'Mark';
        wishChildContact.LastName = 'Smith';
        wishChildContact.ICD_10_Code__c = icdCode.Id;
        wishChildContact.Birthdate = Date.today().addYears(-10);
        wishChildContact.MailingPostalCode = '12345-9876';
        wishChildContact.MailingStreet = 'Mark Street';
        wishChildContact.MailingCountry = 'United States';
        wishChildContact.MailingState = 'Arizona';
        wishChildContact.MailingCity = 'Phoenix';
        Contact wishFamilyContactFather = contactsDataFactory.get(1);
        wishFamilyContactFather.FirstName = 'Jack';
        wishFamilyContactFather.LastName = 'Smith';
        wishFamilyContactFather.RecordTypeId = '01236000000xW2qAAE';
        wishFamilyContactFather.MailingPostalCode = '12345-9876';
        wishFamilyContactFather.MailingStreet = 'Jack Street';
        wishFamilyContactFather.MailingCountry = 'United States';
        wishFamilyContactFather.MailingState = 'Arizona';
        wishFamilyContactFather.MailingCity = 'Phoenix';
        Contact wishFamilyContactBrother = contactsDataFactory.get(2);
        wishFamilyContactBrother.FirstName = 'Danny';
        wishFamilyContactBrother.LastName = 'Smith';
        wishFamilyContactBrother.RecordTypeId = '01236000000xW2qAAE';
        wishFamilyContactBrother.MailingPostalCode = '12345-9876';
        wishFamilyContactBrother.MailingStreet = 'Danny Street';
        wishFamilyContactBrother.MailingCountry = 'United States';
        wishFamilyContactBrother.MailingState = 'Arizona';
        wishFamilyContactBrother.MailingCity = 'Phoenix';
        Contact wishFamilyContactMother = contactsDataFactory.get(3);
        wishFamilyContactMother.FirstName = 'Lucy';
        wishFamilyContactMother.LastName = 'Smith';
        wishFamilyContactMother.RecordTypeId = '01236000000xW2qAAE';
        wishFamilyContactMother.MailingPostalCode = '12345-9876';
        wishFamilyContactMother.MailingStreet = '987 Street';
        wishFamilyContactMother.MailingCountry = 'United States';
        wishFamilyContactMother.MailingState = 'Arizona';
        wishFamilyContactMother.MailingCity = 'Phoenix';
        contacts.add(wishChildContact);
        contacts.add(wishFamilyContactFather);
        contacts.add(wishFamilyContactBrother);
        contacts.add(wishFamilyContactMother);
        insert contacts;
        List<Account> accountsDataFactory = TestDataFactory.createAccount(1);
        List<Account> accounts = new List<Account>();
        Account account = accountsDataFactory.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        accounts.add(account);
        insert accounts;
        List<Case> casesDataFactory = TestDataFactory.createCase(1);
        List<Case> cases = new List<Case>();
        Case wishCase = casesDataFactory.get(0);
        wishCase.RecordTypeId = WISH_RECORD_TYPE_ID;
        wishCase.ChapterName__c = accounts.get(0).Id;
        wishCase.Subject = 'Wish';
        wishCase.Interview_date__c = System.today();
        wishCase.Wish_Type__c = 'Disney World';
        wishCase.Start_Date__c = System.today();
        wishCase.End_Date__c = System.today();
        wishCase.ContactId = wishChildContact.Id;
        wishCase.Status = 'New';
        wishCase.Start_Date__c = System.today();
        wishCase.Budget_Submitted_Date__c = System.today();
        wishCase.Budget_Approved_Date__c = System.today();
        wishCase.Update_Wish_Child_Form_Info__c = true;
        cases.add(wishCase);
        insert cases;
        List<npe4__Relationship__c> relationshipsDataFactory = TestDataFactory.createRelationship(2);
        List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
        npe4__Relationship__c relationship = relationshipsDataFactory.get(0);
        relationship.npe4__Type__c = 'Father';
        relationship.Parent_Legal_Guardian__c = false;
        relationship.npe4__Contact__c = wishChildContact.Id;
        relationship.npe4__RelatedContact__c = wishFamilyContactFather.Id;
        relationshipsDataFactory[1].npe4__Type__c = 'Mother';
        relationshipsDataFactory[1].Parent_Legal_Guardian__c = false;
        relationshipsDataFactory[1].npe4__Contact__c = wishChildContact.Id;
        relationshipsDataFactory[1].npe4__RelatedContact__c = wishFamilyContactMother.Id;
        relationships.add(relationship);
        relationships.add(relationshipsDataFactory[1]);
        insert relationships;
        List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
        List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
        Wish_Affiliation__c wishAffiliation = wishAffiliationsDataFactory.get(0);
        wishAffiliation.Wish__c = wishCase.Id;
        wishAffiliation.Non_Comped__c = false;
        wishAffiliation.Survey_Recipient__c = false;
        wishAffiliation.Medical_Needs__c = false;
        wishAffiliation.Contact__c = wishFamilyContactFather.Id;
        wishAffiliation.Relationship__c = relationship.Id;
        wishAffiliation.Residing_with_Wish_child__c = 'No';
        wishAffiliation.Wish_Affiliation_Type__c = 'Approved Participant';
        wishAffiliationsDataFactory[1].Wish__c = wishCase.Id;
        wishAffiliationsDataFactory[1].Non_Comped__c = false;
        wishAffiliationsDataFactory[1].Survey_Recipient__c = false;
        wishAffiliationsDataFactory[1].Medical_Needs__c = false;
        wishAffiliationsDataFactory[1].Contact__c = wishChildContact.Id;
        wishAffiliationsDataFactory[1].Residing_with_Wish_child__c = 'No';
        wishAffiliationsDataFactory[1].Wish_Affiliation_Type__c = 'Wish Child';
        wishAffiliationsDataFactory[2].Wish__c = wishCase.Id;
        wishAffiliationsDataFactory[2].Non_Comped__c = false;
        wishAffiliationsDataFactory[2].Survey_Recipient__c = false;
        wishAffiliationsDataFactory[2].Medical_Needs__c = false;
        wishAffiliationsDataFactory[2].Contact__c = wishFamilyContactMother.Id;
        wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = 'Other';
        wishAffiliations.add(wishAffiliation);
        wishAffiliations.add(wishAffiliationsDataFactory[1]);
        wishAffiliations.add(wishAffiliationsDataFactory[2]);
        insert wishAffiliations;
    }

    static testMethod void getParticipants() {
        // ARRANGE
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];

        Wish_Affiliation__c wishAff = [SELECT Id FROM Wish_Affiliation__c WHERE Contact__r.FirstName = 'Jack'];

        Test.startTest();
        List<Wish_Change_Request__c> wishChangeRequestsDataFactory = TestDataFactory.createWishChangeRequests(1, wishCase.Id, wishAff.Id);
        wishChangeRequestsDataFactory[0].Field_API_Name_for_Proposed_Change__c = 'LastName';
        wishChangeRequestsDataFactory[0].Field_New_Value__c = 'Shawn';
        insert wishChangeRequestsDataFactory;
        Map<Object, Object> resultMap = WishAffiliationDesign_AC.getWishAffiliations(wishCase.Id, 'Medical Professional');
        List<WishAffiliationDesign_AC.WishAffiliationWrapper> wishAffiliations = (List<WishAffiliationDesign_AC.WishAffiliationWrapper>) resultMap.get('wishAffiliations');

        Test.stopTest();
        System.assertEquals(3, wishAffiliations.size());


    }

    static testMethod void createWishAffiliation() {
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];
        WishAffiliationDesign_AC.newWishAffiliationRecordWrapper wrap = new WishAffiliationDesign_AC.newWishAffiliationRecordWrapper();
        wrap.WishAffiliationWishCaseRecordId = wishCase.Id;
        wrap.RelationshipType = 'Brother';
        wrap.ContactFirstName = 'Tom';
        wrap.ContactLastName = 'Walker';
        wrap.ContactBirthdate = Date.parse('11/06/2006');
        wrap.WishAffiliationResidingWithWishChild = 'No';
        wrap.ContactTShirtSize = 'small';
        wrap.ContactEmail = '';
        String payload = JSON.serialize(wrap);

        Test.startTest();
        Map<Object, Object> resultMap = WishAffiliationDesign_AC.createWishAffiliation(payload);
        Test.stopTest();

        Wish_Affiliation__c wishAff = [SELECT Id, Contact__r.FirstName FROM Wish_Affiliation__c WHERE Contact__r.FirstName = 'Tom'];
        System.assertEquals('Tom', wishAff.Contact__r.FirstName);

    }

    static testMethod void removeAsParticipant() {
        Wish_Affiliation__c wishAff = [SELECT Id, Wish_Affiliation_Type__c FROM Wish_Affiliation__c WHERE Contact__r.FirstName = 'Jack'];
        WishAffiliationDesign_AC.WishAffiliationWrapper wrap = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrap.wishAffRecord = wishAff;
        String payload = JSON.serialize(wrap);

        Test.startTest();
        WishAffiliationDesign_AC.removeAsParticipant(payload);
        Test.stopTest();

        Wish_Affiliation__c wishAffiliation = [SELECT Id, Wish_Affiliation_Type__c FROM Wish_Affiliation__c WHERE Contact__r.FirstName = 'Jack'];
        System.assertEquals('Other', wishAffiliation.Wish_Affiliation_Type__c);
    }

    static testMethod void addUpdateAsParticipant() {


        Wish_Affiliation__c wishAff = [
                SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c,Validated_in_Interview__c,
                        Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName, Contact__r.Birthdate,
                        Contact__r.Email, Contact__r.T_Shirt_Size__c,Relationship__c, Relationship__r.npe4__Type__c
                FROM Wish_Affiliation__c
                WHERE Contact__r.FirstName = 'Jack'
        ];
        wishAff.Contact__r.Birthdate = Date.parse('11/06/2006');
        wishAff.Contact__r.Email = 'jack@bond.com';
        wishAff.Contact__r.T_Shirt_Size__c = 'Small';
        wishAff.Relationship__r.npe4__Type__c = 'Father';
        wishAff.Contact__r.Middle_Name__c = 'Felix';
        WishAffiliationDesign_AC.WishAffiliationWrapper wrap = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrap.wishAffRecord = wishAff;
        String payloadOriginal = JSON.serialize(wrap);

        //Make updates to the same Wish Affiliation
        Wish_Affiliation__c wishAffClone = wishAff.clone();
        wishAffClone.Contact__r.FirstName = 'James';
        wishAffClone.Contact__r.LastName = 'Bond';
        wishAff.Contact__r.Middle_Name__c = 'Kay';
        wishAffClone.Relationship__r.npe4__Type__c = 'Friend';
        wishAffClone.Contact__r.T_Shirt_Size__c = 'Medium';
        wishAffClone.Contact__r.Email = 'james@bond.com';
        wishAffClone.Contact__r.Birthdate = Date.parse('12/06/2006');
        WishAffiliationDesign_AC.WishAffiliationWrapper wrapDup = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrapDup.wishAffRecord = wishAffClone;
        String payloadDuplicate = JSON.serialize(wrapDup);

        Test.startTest();
        Map<Object, Object> objResult = WishAffiliationDesign_AC.addUpdateAsParticipant(payloadDuplicate, payloadOriginal);
        Wish_Affiliation_Security_Settings__c setting = [SELECT Restrict_Access__c FROM Wish_Affiliation_Security_Settings__c WHERE SetupOwnerId = :UserInfo.getUserId()];
        setting.Restrict_Access__c = false;
        update setting;
        Map<Object, Object> result = WishAffiliationDesign_AC.addUpdateAsParticipant(payloadDuplicate, payloadOriginal);
        Test.stopTest();

        Wish_Affiliation__c newWishAff = [SELECT Id, Name FROM Wish_Affiliation__c WHERE Contact__r.FirstName = 'James'];
        System.assertEquals(true, newWishAff != null);
    }
    
    @isTest
    static void addUpdateAsParticipantByRestrictedUser() {
        Wish_Affiliation__c wishAff = [
            SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c,Validated_in_Interview__c,
            Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName, Contact__r.Birthdate,
            Contact__r.Email, Contact__r.T_Shirt_Size__c,Relationship__c, Relationship__r.npe4__Type__c
            FROM Wish_Affiliation__c
            WHERE Contact__r.FirstName = 'Lucy'
        ];
        WishAffiliationDesign_AC.WishAffiliationWrapper wrap = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrap.wishAffRecord = wishAff;
        String payloadOriginal = JSON.serialize(wrap);
        //Make updates to the same Wish Affiliation
        Wish_Affiliation__c wishAffClone = wishAff.clone();
        wishAffClone.Id = wishAff.Id;
        wishAffClone.Contact__r.Birthdate = Date.parse('07/27/1985');
        wishAffClone.Contact__r.Salutation = 'Miss';
        wishAffClone.Contact__r.Middle_Name__c = 'Jeanine';
        wishAffClone.Contact__r.npe01__HomeEmail__c = 'Lucy.Jeanine@mail.com';
        wishAffClone.Residing_with_Wish_child__c = 'Yes';
        WishAffiliationDesign_AC.WishAffiliationWrapper wrapDup = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrapDup.wishAffRecord = wishAffClone;
        String payloadDuplicate = JSON.serialize(wrapDup);
        
        Test.startTest();
        WishAffiliationDesign_AC.addUpdateAsParticipant(payloadDuplicate, payloadOriginal);
        Test.stopTest();
        //Verify DOB and Residing with Wish Child updates save because fields were not previously populated
        Wish_Affiliation__c wishAffUpdateCheck = [
            SELECT Id, Residing_with_Wish_child__c 
            FROM Wish_Affiliation__c 
            WHERE Id = :wishAff.Id
        ];
        Contact contactUpdateCheck = [
            SELECT Id, Birthdate 
            FROM Contact 
            WHERE Id = :wishAff.Contact__c
        ];
        System.assert(wishAffUpdateCheck.Residing_with_Wish_child__c == 'Yes');
        System.assert(contactUpdateCheck.Birthdate == Date.parse('07/27/1985'));
    }
    
    @isTest
    static void addUpdateAsParticipantByRestrictedUserIgnoreChange() {
        Wish_Affiliation__c wishAff = [
            SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c,Validated_in_Interview__c,
            Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName, Contact__r.Birthdate,
            Contact__r.Email, Contact__r.T_Shirt_Size__c,Relationship__c, Relationship__r.npe4__Type__c
            FROM Wish_Affiliation__c
            WHERE Contact__r.FirstName = 'Lucy'
        ];
        wishAff.Contact__r.Birthdate = Date.parse('07/27/1980');
        wishAff.Residing_with_Wish_child__c = 'Yes';
        WishAffiliationDesign_AC.WishAffiliationWrapper wrap = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrap.wishAffRecord = wishAff;
        String payloadOriginal = JSON.serialize(wrap);
        //Make updates to the same Wish Affiliation
        Wish_Affiliation__c wishAffClone = wishAff.clone();
        wishAffClone.Contact__r.Birthdate = Date.parse('07/27/1985');
        wishAffClone.Residing_with_Wish_child__c = 'No';
        WishAffiliationDesign_AC.WishAffiliationWrapper wrapDup = new WishAffiliationDesign_AC.WishAffiliationWrapper();
        wrapDup.wishAffRecord = wishAffClone;
        String payloadDuplicate = JSON.serialize(wrapDup);
        
        Test.startTest();
        WishAffiliationDesign_AC.addUpdateAsParticipant(payloadDuplicate, payloadOriginal);
        Test.stopTest();
        //Verify DOB and Residing with Wish Child values did not update because fields were already populated
        Wish_Affiliation__c wishAffUpdateCheck = [
            SELECT Id, Residing_with_Wish_child__c 
            FROM Wish_Affiliation__c 
            WHERE Id = :wishAff.Id
        ];
        Contact contactUpdateCheck = [
            SELECT Id, Birthdate 
            FROM Contact 
            WHERE Id = :wishAff.Contact__c
        ];
        System.assert(wishAffUpdateCheck.Residing_with_Wish_child__c != 'No');
        System.assert(contactUpdateCheck.Birthdate != Date.parse('07/27/1985'));
    }
}