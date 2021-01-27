@IsTest
private class AffiliationServiceTest {
    
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accounts = TestDataFactory.createAccount(2);
        Account arizonaChapter = accounts.get(0);
        arizonaChapter.Name = 'Make-A-Wish Arizona';
        arizonaChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        Account arizonaHospital = accounts.get(1);
        arizonaHospital.Name = 'Phoenix General Hospital';
        arizonaHospital.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
        insert accounts;
        
        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodes.get(0);
        insert icdCodes;
        
        List<Contact> contactList = TestDataFactory.createContact(8);
        Contact mpContactLee = contactList.get(0);
        mpContactLee.FirstName = 'Ken';
        mpContactLee.LastName = 'Lee';
        mpContactLee.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactLee.Region_Chapter__c = arizonaChapter.Id;
        Contact mpContactMiller = contactList.get(1);
        mpContactMiller.FirstName = 'Jennifer';
        mpContactMiller.LastName = 'Miller';
        mpContactMiller.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactMiller.Region_Chapter__c = arizonaChapter.Id;
        Contact mpContactJohnson = contactList.get(2);
        mpContactJohnson.FirstName = 'Raymond';
        mpContactJohnson.LastName = 'Johnson';
        mpContactJohnson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactJohnson.Region_Chapter__c = arizonaChapter.Id;
        Contact mpContactPatel = contactList.get(3);
        mpContactPatel.FirstName = 'Daniel';
        mpContactPatel.LastName = 'Patel';
        mpContactPatel.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactPatel.Region_Chapter__c = arizonaChapter.Id;
        Contact mpContactBrown = contactList.get(4);
        mpContactBrown.FirstName = 'Rachel';
        mpContactBrown.LastName = 'Brown';
        mpContactBrown.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactBrown.Region_Chapter__c = arizonaChapter.Id;
        Contact wishFamilyWalker = contactList.get(5);
        wishFamilyWalker.FirstName = 'Lucy';
        wishFamilyWalker.LastName = 'Walker';
        wishFamilyWalker.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        wishFamilyWalker.Region_Chapter__c = arizonaChapter.Id;
        Contact boardMember = contactList.get(6);
        boardMember.FirstName = 'Samuel';
        boardMember.LastName = 'Crane';
        boardMember.RecordTypeId = Constant_AC.BOARD_MEMBER_RT_ID;
        boardMember.Region_Chapter__c = arizonaChapter.Id;
        Contact volunteer = contactList.get(7);
        volunteer.FirstName = 'Katherine';
        volunteer.LastName = 'Buckland';
        volunteer.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteer.AccountId = arizonaChapter.Id;
        volunteer.Region_Chapter__c = arizonaChapter.Id;
        insert contactList;
        
        List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(6);
        npe5__Affiliation__c mpLeeAffiliation = affiliationList.get(0);
        mpLeeAffiliation.npe5__Contact__c = mpContactLee.Id;
        mpLeeAffiliation.npe5__Organization__c = arizonaHospital.Id;
        mpLeeAffiliation.npe5__Primary__c = true;
        mpLeeAffiliation.npe5__Status__c = 'Active';
        npe5__Affiliation__c mpMillerAffiliation = affiliationList.get(1);
        mpMillerAffiliation.npe5__Contact__c = mpContactMiller.Id;
        mpMillerAffiliation.npe5__Organization__c = arizonaHospital.Id;
        mpMillerAffiliation.npe5__Primary__c = true;
        npe5__Affiliation__c mpJohnsonAffiliation = affiliationList.get(2);
        mpJohnsonAffiliation.npe5__Contact__c = mpContactJohnson.Id;
        mpJohnsonAffiliation.npe5__Organization__c = arizonaHospital.Id;
        mpJohnsonAffiliation.npe5__Primary__c = true;
        npe5__Affiliation__c mpPatelAffiliation = affiliationList.get(3);
        mpPatelAffiliation.npe5__Contact__c = mpContactPatel.Id;
        mpPatelAffiliation.npe5__Organization__c = arizonaHospital.Id;
        mpPatelAffiliation.npe5__Primary__c = true;
        npe5__Affiliation__c mpBrownAffiliation = affiliationList.get(4);
        mpBrownAffiliation.npe5__Contact__c = mpContactBrown.Id;
        mpBrownAffiliation.npe5__Organization__c = arizonaHospital.Id;
        mpBrownAffiliation.npe5__Primary__c = true;
        npe5__Affiliation__c volunteerAffiliation = affiliationList.get(5);
        volunteerAffiliation.npe5__Contact__c = volunteer.Id;
        volunteerAffiliation.npe5__Organization__c = arizonaChapter.Id;
        volunteerAffiliation.npe5__Primary__c = true;
        volunteerAffiliation.npe5__Status__c = 'Pending';
        insert affiliationList;
        
        List<Lead> leadList = TestDataFactory.createLead(1);
        Lead wishLead = leadList.get(0);
        wishLead.FirstName = 'Darnell';
        wishLead.LastName = 'Walker';
        wishLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
        wishLead.is_Family_Aware_of_Referral__c = 'Yes';
        wishLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        wishLead.PD_ICD_Code__c = icdCode.Id;
        wishLead.Company = 'MAW';
        wishLead.Referring_MP__c = mpContactLee.Id;
        wishLead.Referring_MP_HTF__c = arizonaHospital.Id;
        wishLead.Treating_MP__c = mpContactMiller.Id;
        wishLead.Treating_MP_HTF__c = arizonaHospital.Id;
        wishLead.Best_Contact__c = mpContactJohnson.Id;
        wishLead.Best_Contact_HTF__c = arizonaHospital.Id;
        wishLead.Alt_1_MP__c = mpContactPatel.Id;
        wishLead.Alt_1_MP_HTF__c = arizonaHospital.Id;
        wishLead.Alt_2_MP__c = mpContactBrown.Id;
        wishLead.Alt_2_MP_HTF__c = arizonaHospital.Id;
        insert leadList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void findExistingAffiliations() {
        Map<Id, Contact> mpContactMap = new Map<Id, Contact>([
            SELECT Id, RecordTypeId 
            FROM Contact 
            WHERE RecordTypeId = :Constant_AC.MEDICAL_PROFESSIONAL_RT_ID
        ]);
        Map<Id, Account> htfAccountMap = new Map<Id, Account>([
            SELECT Id 
            FROM Account 
            WHERE RecordTypeId = :Constant_AC.HOSPITAL_TREATMENT_ID
        ]);
        List<npe5__Affiliation__c> affiliationList = [
            SELECT Id 
            FROM npe5__Affiliation__c 
            WHERE npe5__Contact__c IN :mpContactMap.keySet() 
            OR npe5__Organization__c IN :htfAccountMap.keySet()
        ];
        Test.startTest();
        Map<String, npe5__Affiliation__c> affiliationMap = 
            AffiliationService.findExistingAffiliations(mpContactMap.keySet(), htfAccountMap.keySet());
        Test.stopTest();
        System.assert(affiliationList.size() == affiliationMap.values().size());
    }
    
    @isTest
    private static void buildWishChildAffiliation() {
        Lead wishChild = [
            SELECT Id, ConvertedContactId, Hidden_DV_form_Medical_professional_Type__c, Referring_MP_HTF__c, 
            Treating_MP_HTF__c, Best_Contact_HTF__c, Alt_1_MP_HTF__c, Alt_2_MP_HTF__c
            FROM Lead 
            WHERE Name = 'Darnell Walker'
        ];
        List<npe5__Affiliation__c> affiliations;
        Test.startTest();
        wishChild.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
        affiliations = AffiliationService.buildWishChildAffiliation(wishChild);
        System.assert(affiliations[0].npe5__Organization__c == wishChild.Referring_MP_HTF__c);
        
        wishChild.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
        affiliations = AffiliationService.buildWishChildAffiliation(wishChild);
        System.assert(affiliations[0].npe5__Organization__c == wishChild.Alt_1_MP_HTF__c);
        
        wishChild.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
        affiliations = AffiliationService.buildWishChildAffiliation(wishChild);
        System.assert(affiliations[0].npe5__Organization__c == wishChild.Treating_MP_HTF__c);
        
        wishChild.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
        affiliations = AffiliationService.buildWishChildAffiliation(wishChild);
        System.assert(affiliations[0].npe5__Organization__c == wishChild.Alt_2_MP_HTF__c);
        
        wishChild.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
        affiliations = AffiliationService.buildWishChildAffiliation(wishChild);
        System.assert(affiliations[0].npe5__Organization__c == wishChild.Best_Contact_HTF__c);
        Test.stopTest();
    }
    
    @isTest
    private static void buildMedicalProfessionalHospitalAffiliation() {
        Lead wishChild = [
            SELECT Id, Referring_MP__c, Referring_MP_HTF__c, Treating_MP__c, Treating_MP_HTF__c, Best_Contact__c, 
            Best_Contact_HTF__c, Alt_1_MP__c, Alt_1_MP_HTF__c, Alt_2_MP__c, Alt_2_MP_HTF__c
            FROM Lead 
            WHERE Name = 'Darnell Walker'
        ];
        Map<String, npe5__Affiliation__c> affiliationMap = new Map<String, npe5__Affiliation__c>();
        Test.startTest();
        List<npe5__Affiliation__c> affiliationList = 
            AffiliationService.buildMedicalProfessionalHospitalAffiliation(wishChild, affiliationMap);
        Test.stopTest();
        System.assert(affiliationList.size() == 5);
    }
    
    @isTest
    private static void buildMedicalProfessionalHospitalAffiliationExisting() {
        Lead wishChild = [
            SELECT Id, Referring_MP__c, Referring_MP_HTF__c, Treating_MP__c, Treating_MP_HTF__c, Best_Contact__c, 
            Best_Contact_HTF__c, Alt_1_MP__c, Alt_1_MP_HTF__c, Alt_2_MP__c, Alt_2_MP_HTF__c
            FROM Lead 
            WHERE Name = 'Darnell Walker'
        ];
        Map<String, npe5__Affiliation__c> affiliationMap = new Map<String, npe5__Affiliation__c>();
        for (npe5__Affiliation__c affiliation : [
            SELECT Id, npe5__Contact__c, npe5__Organization__c, npe5__Organization__r.RecordTypeId,
            npe5__Status__c, npe5__Primary__c, Constituent_Code__c, npe5__StartDate__c
            FROM npe5__Affiliation__c
        ]) {
            String contactAccountKey = String.valueOf(affiliation.npe5__Contact__c) + String.valueOf(affiliation.npe5__Organization__c);
            affiliationMap.put(contactAccountKey, affiliation);
        }
        Test.startTest();
        List<npe5__Affiliation__c> affiliationList = 
            AffiliationService.buildMedicalProfessionalHospitalAffiliation(wishChild, affiliationMap);
        Test.stopTest();
        System.assert(affiliationList.size() == 0);
    }
    
    @isTest
    private static void createAffiliations() {
        List<Contact> contactList = [
            SELECT Id, RecordTypeId, Region_Chapter__c, npsp__Primary_Affiliation__c 
            FROM Contact
        ];
        Test.startTest();
        AffiliationService.createAffiliation(contactList);
        Test.stopTest();
        List<npe5__Affiliation__c> affiliationList = [
            SELECT Id 
            FROM npe5__Affiliation__c 
            WHERE npe5__Contact__c IN :contactList
        ];
        System.assert(!affiliationList.isEmpty());
    }
    
    @isTest
    private static void updateOrgAffiliationStatus() {
        Map<Id, Contact> volunteerMap = new Map<Id, Contact>([
            SELECT Id, is_Application__c 
            FROM Contact
            WHERE RecordTypeId = :Constant_AC.VOLUNTEER_RT_ID
        ]);
        List<Contact> updatedContactList = new List<Contact>();
        for(Contact con : volunteerMap.values()) {
            Contact contact = new Contact(Id = con.Id);
            contact.is_Application__c = 'Rejected';
            updatedContactList.add(contact);
        }
        Test.startTest();
        AffiliationService.updateOrgAffiliationStatus(updatedContactList, volunteerMap);
        Test.stopTest();
        List<npe5__Affiliation__c> affiliationUpdatedList = [
            SELECT Id, npe5__Status__c 
            FROM npe5__Affiliation__c 
            WHERE npe5__Contact__c IN :volunteerMap.keySet()
        ];
        System.assert(affiliationUpdatedList[0].npe5__Status__c == 'Not Approved');
    }
    
    @isTest
    private static void updateAffiliationStatusInactive() {
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, npsp__Deceased__c, Region_Chapter__c
            FROM Contact
            WHERE Name = 'Ken Lee'
        ]);
        List<Contact> updatedContactList = new List<Contact>();
        for(Contact con : contactMap.values()) {
            Contact contact = new Contact(Id = con.Id);
            contact.npsp__Deceased__c = true;
            updatedContactList.add(contact);
        }
        Test.startTest();
        AffiliationService.updateAffiliationStatusInactive(updatedContactList, contactMap);
        Test.stopTest();
        List<npe5__Affiliation__c> affiliationUpdatedList = [
            SELECT Id, npe5__Status__c 
            FROM npe5__Affiliation__c 
            WHERE npe5__Contact__c IN :contactMap.keySet()
        ];
        System.assert(affiliationUpdatedList[0].npe5__Status__c == 'Inactive');
    }
}