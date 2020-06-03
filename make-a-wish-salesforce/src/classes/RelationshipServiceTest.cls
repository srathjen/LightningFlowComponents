@IsTest
public class RelationshipServiceTest {
    
    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        Account azAccount = TestDataFactory.createAccount(1)[0];
        azAccount.Name = 'Make-A-Wish Arizona';
        azAccount.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert azAccount;
        
        ICD_Codes__c icdCode = TestDataFactory.createIcdCode(1)[0];
        icdCode.Name = 'Q917';
        insert icdCode;
        
        List<Contact> contactList = TestDataFactory.createContact(6);
        Contact medHolland = contactList.get(0);
        medHolland.FirstName = 'Francis';
        medHolland.LastName = 'Holland';
        medHolland.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        medHolland.AccountId = azAccount.Id;
        Contact medWatson = contactList.get(1);
        medWatson.FirstName = 'Jessica';
        medWatson.LastName = 'Watson';
        medWatson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        medWatson.Type_of_Contact__c = 'Referrer&Treating';
        medWatson.npe01__WorkEmail__c = 'nurse.watson@email.com';
        medWatson.AccountId = azAccount.Id;
        Contact medSmith = contactList.get(2);
        medSmith.FirstName = 'Jacobi';
        medSmith.LastName = 'Smith';
        medSmith.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        medSmith.AccountId = azAccount.Id;
        Contact medJohnson = contactList.get(3);
        medJohnson.FirstName = 'Pam';
        medJohnson.LastName = 'Johnson';
        medJohnson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        medJohnson.AccountId = azAccount.Id;
        Contact famGeorge = contactList.get(4);
        famGeorge.FirstName = 'William';
        famGeorge.LastName = 'George';
        famGeorge.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        famGeorge.AccountId = azAccount.Id;
        famGeorge.Type_of_Contact__c = 'Parent/Guardian';
        famGeorge.Email = 'william@george.com';
        famGeorge.Phone = '520-830-8978';
        Contact famGeorge2 = contactList.get(5);
        famGeorge2.FirstName = 'Natalie';
        famGeorge2.LastName = 'George';
        famGeorge2.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        famGeorge2.AccountId = azAccount.Id;
        famGeorge2.Type_of_Contact__c = 'Parent/Guardian';
        insert contactList;
        
        Lead qualifiedLead = TestDataFactory.createQualifiedLead(azAccount.Id, icdCode.Id);
        qualifiedLead.FirstName = 'Fred';
        qualifiedLead.LastName = 'George';
        qualifiedLead.Treating_Medical_Professional_Contact_Id__c = medHolland.Id;
        qualifiedLead.Medical_Professional_ContactId__c = medWatson.Id;
        qualifiedLead.HiddenAlternate1MedProfessionalId__c = medSmith.Id;
        qualifiedLead.HiddenAlternate2MedProfessionalId__c = medJohnson.Id;
        qualifiedLead.Hidden_Best_Contact_Person_Id__c = famGeorge.Id;
        qualifiedLead.Wish_Family_ContactId__c = famGeorge.Id;
        qualifiedLead.Hidden_Additional_Parent_Id__c = famGeorge2.Id;
        insert qualifiedLead;
        
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(qualifiedLead.Id);
        leadConvert.setConvertedStatus('Qualified');
        leadConvert.setDoNotCreateOpportunity(true);
        Database.convertLead(leadConvert);
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void buildLeadConvertRelationships() {
        Lead lead = [
            SELECT Id, Treating_Medical_Professional_Contact_Id__c, ConvertedContactId, Treating_Medical_Professional_First_Name__c,
            Referrer_FirstName__c, Treating_Medical_Professional_Phone__c, Referrer_Phone__c, Treating_Medical_Professional_Email__c, 
            Referrer_Email__c, Hidden_DV_form_Medical_professional_Type__c, Medical_Professional_ContactId__c, HiddenAlternate1MedProfessionalId__c,
            HiddenAlternate2MedProfessionalId__c, Alternate1MedProfessionalFirstName__c, Alternate1MedProfessionalLastName__c, Alternate1MedProfessionalPhone__c,
            Alternate1MedicalProfessionalEmail__c, Alternate2MedProfessionalFirstName__c, Alternate2MedProfessionalLastName__c, Alternate2MedProfessionalPhone__c, 
            Alternate2MedProfessionalEmail__c, Hidden_Best_Contact_Person_Id__c, Best_Contact_for_Physician_First_Name__c, Best_Contact_for_Physician_Last_Name__c,
            Best_contact_for_Physician_Email__c, Wish_Family_ContactId__c, Relationship_to_child__c, Hidden_Additional_Parent_Id__c, 
            Additional_Parent_Relationship_to_Child__c, Treating_Medical_Professional_Last_Name__c, Referrer_Last_Name__c, Parent_Relationship_to_Child__c
            FROM Lead
        ];
        Test.startTest();
        RelationshipService.buildLeadConvertRelationships(lead);
        Test.stopTest();
    }
    
    @IsTest
    public static void buildLeadConvertRelationshipMedical() {
        Contact wishChild = [
            SELECT Id 
            FROM Contact 
            WHERE Name = 'Fred George'
        ];
        Contact medicalProf = [
            SELECT Id, FirstName, LastName, npe01__WorkEmail__c, RecordTypeId, Type_of_Contact__c 
            FROM Contact 
            WHERE Name = 'Jessica Watson'
        ];
        Map<String, Boolean> qualifyingMap = new Map<String, Boolean>();
        qualifyingMap.put((medicalProf.FirstName + '-' + medicalProf.LastName + '-' + medicalProf.npe01__WorkEmail__c), true);
        
        Test.startTest();
        npe4__Relationship__c medRelation = RelationshipService.buildLeadConvertRelationship(wishChild.Id, medicalProf, qualifyingMap, null, null);
        Test.stopTest();
        System.assert(medRelation.npe4__Type__c == Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL);
    }
    
    @IsTest
    public static void buildLeadConvertRelationshipFamily() {
        Contact wishChild = [
            SELECT Id 
            FROM Contact 
            WHERE Name = 'Fred George'
        ];
        Contact parent = [
            SELECT Id, FirstName, LastName, RecordTypeId, Type_of_Contact__c, Email, Phone 
            FROM Contact 
            WHERE Name = 'William George'
        ];
        Map<String, String> relationMap = new Map<String, String>();
        relationMap.put((parent.FirstName + '-' + parent.LastName + '-' + parent.Email + '-' + parent.Phone), 'Father');
        Set<String> parentNameSet = new Set<String>();
        parentNameSet.add(parent.FirstName + '-' + parent.LastName + '-' + Constant_AC.WISH_FAMILY_RT_ID);
        
        Test.startTest();
        npe4__Relationship__c famRelation = RelationshipService.buildLeadConvertRelationship(wishChild.Id, parent, null, relationMap, parentNameSet);
        Test.stopTest();
        System.assert(famRelation.Parent_Legal_Guardian__c == true);
    }
}