/**
 * @description Wish Required Signature Service Test Class
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 8/14/2019
 */
@IsTest
public class WishRequiredSignatureServiceTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
	private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
	private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id MEDICAL_PROF_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

	@TestSetup
	private static void insertTestData() {
		List<Account> accountsDataFactory = TestDataFactory.createAccount(2);
		accountsDataFactory[0].RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
		accountsDataFactory[0].OwnerId = UserInfo.getUserId();
		accountsDataFactory[0].Qualified_Wish_Owner__c = UserInfo.getUserId();
		accountsDataFactory[0].Intake_Manager__c = UserInfo.getUserId();
		accountsDataFactory[1].RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		accountsDataFactory[1].OwnerId = UserInfo.getUserId();
		accountsDataFactory[1].Intake_Manager__c = UserInfo.getUserId();
		accountsDataFactory[1].Qualified_Wish_Owner__c = UserInfo.getUserId();
		insert accountsDataFactory;
		ICD_Codes__c icdCode = new ICD_Codes__c();
		icdCode.Name = 'Q917';
		insert icdCode;
		List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
		contactsDataFactory[0].RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
		contactsDataFactory[0].ICD_10_Code__c = icdCode.Id;
		contactsDataFactory[0].OwnerId = UserInfo.getUserId();
		contactsDataFactory[1].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
		contactsDataFactory[1].Birthdate = System.today().addYears(-20);
		contactsDataFactory[1].OwnerId = UserInfo.getUserId();
		contactsDataFactory[2].RecordTypeId = MEDICAL_PROF_RECORD_TYPE_ID;
		contactsDataFactory[2].OwnerId = UserInfo.getUserId();
		contactsDataFactory[3].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
		contactsDataFactory[3].Birthdate = System.today().addYears(-18);
		contactsDataFactory[3].OwnerId = UserInfo.getUserId();
		insert contactsDataFactory;
		List<Case> casesDataFactory = TestDataFactory.createCase(1);
		casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
		casesDataFactory[0].ChapterName__c = accountsDataFactory[1].Id;
		casesDataFactory[0].AccountId = accountsDataFactory[0].Id;
		casesDataFactory[0].ContactId = contactsDataFactory[0].Id;
		casesDataFactory[0].Origin = 'Email';
		casesDataFactory[0].Status = 'Qualified';
		casesDataFactory[0].OwnerId = UserInfo.getUserId();
		insert casesDataFactory;
		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(2);
		wishAffiliationsDataFactory[0].Contact__c = contactsDataFactory[1].Id;
		wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
		wishAffiliationsDataFactory[0].Wish__c = casesDataFactory[0].Id;
		wishAffiliationsDataFactory[1].Contact__c = contactsDataFactory[2].Id;
		wishAffiliationsDataFactory[1].Wish_Affiliation_Type__c = 'Approved Participant' ;
		wishAffiliationsDataFactory[1].Wish__c = casesDataFactory[0].Id;
		insert wishAffiliationsDataFactory;
		List<Wish_Signature_Forms__c> wishSignFormsDataFactory = TestDataFactory.createWishSignatureForm(1);
		wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
		wishSignFormsDataFactory[0].Auto_add_for_Participant__c = true;
		wishSignFormsDataFactory[0].Auto_add_for_Wish_Child__c = true;
		wishSignFormsDataFactory[0].Auto_add_for_Participant_Guardian__c = true;
		wishSignFormsDataFactory[0].Auto_add_for_Wish_Child_Guardian__c = true;
		wishSignFormsDataFactory[0].Diagnosis_Verification_for_Lead_Convert__c = true;
		insert wishSignFormsDataFactory;
		List<Wish_Signature_Chapter_Form__c> wishSignChapFormsDataFactory = TestDataFactory.createWishSignatureChapterForm(1);
		wishSignChapFormsDataFactory[0].Chapter_Account__c = accountsDataFactory[1].Id;
		wishSignChapFormsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
		insert wishSignChapFormsDataFactory;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accountsDataFactory[0].Id;
		lead.FirstName = 'Will';
		lead.LastName = 'Smith';
		lead.Phone = '5555555555';
		lead.Email = 'js@email.com';
		lead.Street = '123 St';
		lead.StateCode = 'AZ';
		lead.City = 'Phoenix';
		lead.PostalCode = '85001';
		lead.CountryCode = 'US';
		lead.DOB__c = System.today() - 1435;
		lead.IsConverted = true;
		lead.ConvertedAccountId = accountsDataFactory[0].Id;
		lead.ConvertedContactId = contactsDataFactory[0].Id;
		lead.Company = 'MAWA';
		lead.Status = 'Inquiry';
		lead.Gender__c = 'Male';
		lead.Referrer_FirstName__c = 'Carol';
		lead.Referrer_Last_Name__c = 'Jones';
		lead.Referrer_Email__c = 'cj@email.com';
		lead.Referrer_Phone__c = '5555555555';
		lead.Referrer_City__c = 'Phoenix';
		lead.Referrer_Zip__c = '85123';
		lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		lead.PD_Condition_Description__c = 'Test Diagnosis';
		lead.Parent_First_Name__c = 'Bob';
		lead.Parent_Last_Name__c = 'Smith';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Medical_Questions__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Lung_Disease__c = 'Test1;Test2';
		lead.Angina__c = 'Test1;Test2';
		lead.Ventilator__c = 'Test1;Test2';
		lead.Arrhythmia__c = 'Test1;Test2';
		lead.Heart_Failure__c = 'Test1;Test2';
		lead.Congenital_Heart_Disease__c = 'Test1;Test2';
		lead.Chronic_Hepatitis__c = 'Test1;Test2';
		lead.Convulsive_Disorders__c = 'Test1;Test2';
		lead.Pulmonary_Hypertension__c = 'Test1;Test2';
		lead.Strokes__c = 'Test1;Test2';
		lead.Chronic_Heart_Failure__c = 'Test1;Test2';
		lead.isSign__c = true;
		lead.Travel_algorithm__c = 'Test1;Test2;';
		insert lead;
		List<dsfs__DocuSign_Status__c> dsStatus = TestDataFactory.createDocusignStatus(1);
		dsStatus[0].dsfs__Lead__c = lead.Id;
		dsStatus[0].dsfs__Subject__c = 'Diagnosis Verification Form';
		dsStatus[0].dsfs__Envelope_Status__c = 'Completed';
		dsStatus[0].dsfs__Completed_Date_Time__c = Date.today();
		insert dsStatus;
		List<Attachment> attachmentsDataFactory = TestDataFactory.createAttachments(1, dsStatus[0].Id);
		List<Attachment> docuSignAttachments = new List<Attachment>();
		Attachment attachment = attachmentsDataFactory.get(0);
		attachment.Name = 'Attachment1.txt';
		docuSignAttachments.add(attachment);
		insert docuSignAttachments;
		List<Diagnosis_Verification__c> diagnosisVerificationFactory = TestDataFactory.createDiagnosisVerification(1);
		List<Diagnosis_Verification__c> diagnosisVerifications = new List<Diagnosis_Verification__c>();
		Diagnosis_Verification__c diagnosisVerification = diagnosisVerificationFactory.get(0);
		diagnosisVerification.Lead__c = lead.Id;
		diagnosisVerifications.add(diagnosisVerification);
		insert diagnosisVerifications;
	}

	@IsTest
	public static void testCreateWishChildParticipantSignatures() {
		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		List<Contact> conList = [
				SELECT Id
				FROM Contact
		];

		Test.startTest();
		//Insert Wish Affiliations
		List<Wish_Affiliation__c> wishAffiliationsList = TestDataFactory.createWishAffiliation(2);
		wishAffiliationsList[0].Contact__c = conList[3].Id;
		wishAffiliationsList[0].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD;
		wishAffiliationsList[0].Wish__c = wishCase.Id;
		wishAffiliationsList[1].Contact__c = conList[1].Id;
		wishAffiliationsList[1].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
		wishAffiliationsList[1].Wish__c = wishCase.Id;
		insert wishAffiliationsList;

		//Update Wish Affiliations
		List<Wish_Affiliation__c> wishAffiliations = [
				SELECT Id
				FROM Wish_Affiliation__c
				WHERE Id IN :wishAffiliationsList
		];
		wishAffiliations[1].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD;
		wishAffiliations[0].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
		update wishAffiliations;
		Test.stopTest();

		List<Wish_Required_Signature__c> wishSignatures = [
				SELECT Id
				FROM Wish_Required_Signature__c
		];
		System.assertEquals(2, wishSignatures.size());
		List<Wish_Required_Signature__c> newWishSignatures = [
				SELECT Id
				FROM Wish_Required_Signature__c
		];
		System.assertEquals(2, newWishSignatures.size());

	}

	@IsTest
	public static void testCreateParticipantGuardianSignatures() {

		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		List<Contact> conList = [
				SELECT Id
				FROM Contact
		];
		conList[0].Birthdate = System.today().addDays(-16);
		update conList;
		List<Contact> contacts = TestDataFactory.createContact(1);
		contacts[0].Birthdate = System.today().addYears(-16);
		insert contacts;

		Test.startTest();
		//Insert Relations
		npe4__Relationship__c relationShip = TestDataFactory.createRelationship(contacts[0].Id, conList[2].Id);
		relationShip.Parent_Legal_Guardian__c = true;
		npe4__Relationship__c newRelationShips = TestDataFactory.createRelationship(conList[0].Id, conList[3].Id);
		newRelationShips.Parent_Legal_Guardian__c = true;
		insert new List<npe4__Relationship__c>{
				relationShip, newRelationShips
		};

		//Insert Affiliation with Relationship
		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
		wishAffiliationsDataFactory[0].Contact__c = conList[2].Id;
		wishAffiliationsDataFactory[0].Relationship__c = relationShip.Id;
		wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD;
		wishAffiliationsDataFactory[0].Wish__c = wishCase.Id;
		wishAffiliationsDataFactory[1].Contact__c = contacts[0].Id;
		wishAffiliationsDataFactory[1].Wish__c = wishCase.Id;
		wishAffiliationsDataFactory[2].Contact__c = conList[3].Id;
		wishAffiliationsDataFactory[2].Relationship__c = newRelationShips.Id;
		wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
		wishAffiliationsDataFactory[2].Wish__c = wishCase.Id;
		insert wishAffiliationsDataFactory;

		//Update Relationship on Affiliation
		List<Wish_Affiliation__c> wishAffList = [
				SELECT Wish_Affiliation_Type__c
				FROM Wish_Affiliation__c
				WHERE Id IN :wishAffiliationsDataFactory
		];
		wishAffList[1].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
		wishAffList[1].Relationship__c = relationShip.Id;
		update wishAffList;
		Test.stopTest();

		List<Wish_Required_Signature__c> newWishSignatures = [
				SELECT Id
				FROM Wish_Required_Signature__c
		];
		System.assertEquals(3, newWishSignatures.size());
		List<Guardian_Signature__c> guardians = [
				SELECT Id
				FROM Guardian_Signature__c
		];
		System.assertEquals(2, guardians.size());
	}

	@IsTest
	public static void testCreateGuardianSignaturesRelationship() {
		List<Contact> conList = [
				SELECT Id
				FROM Contact
		];
		conList[0].Birthdate = System.today().addDays(-16);
		update conList;

		List<Contact> contacts = TestDataFactory.createContact(1);
		contacts[0].Birthdate = System.today().addYears(-16);
		insert contacts;

		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		wishCase.ContactId = conList[0].Id;
		update wishCase;

		Test.startTest();
		//Insert Relationship
		npe4__Relationship__c relationShip = TestDataFactory.createRelationship(contacts[0].Id, conList[2].Id);
		npe4__Relationship__c newRelationShips = TestDataFactory.createRelationship(conList[0].Id, conList[3].Id);
		insert new List<npe4__Relationship__c>{
				relationShip, newRelationShips
		};

		//Insert Affiliation with Relationship
		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
		wishAffiliationsDataFactory[0].Contact__c = conList[2].Id;
		wishAffiliationsDataFactory[0].Relationship__c = relationShip.Id;
		wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD;
		wishAffiliationsDataFactory[0].Wish__c = wishCase.Id;
		wishAffiliationsDataFactory[1].Contact__c = contacts[0].Id;
		wishAffiliationsDataFactory[1].Wish__c = wishCase.Id;
		wishAffiliationsDataFactory[2].Contact__c = conList[3].Id;
		wishAffiliationsDataFactory[2].Relationship__c = newRelationShips.Id;
		wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
		wishAffiliationsDataFactory[2].Wish__c = wishCase.Id;
		insert wishAffiliationsDataFactory;

		//Update Relationship
		List<npe4__Relationship__c> listRelations = new List<npe4__Relationship__c>();
		for (npe4__Relationship__c objRelation : [
				SELECT Id
				FROM npe4__Relationship__c
		]) {
			objRelation.Parent_Legal_Guardian__c = true;
			listRelations.add(objRelation);
		}
		update listRelations;
		Test.stopTest();

		List<Wish_Required_Signature__c> newWishSignatures = [
				SELECT Id
				FROM Wish_Required_Signature__c
		];
		List<Guardian_Signature__c> guardians = [
				SELECT Id
				FROM Guardian_Signature__c
		];
		System.assertEquals(1, guardians.size());
		System.assertEquals(2, newWishSignatures.size());
	}

	@IsTest
	public static void testCreateSignaturesForQualifyingMedicalProfessional_WhenLeadConverts() {
		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Lead lead = [
				SELECT Id, Part_A_Received__c, Part_A_Sent__c
				FROM Lead
				LIMIT 1
		];
		Map<Id, Case> newCasesByLeadId = new Map<Id, Case>();
		newCasesByLeadId.put(lead.Id, wishCase);
		Map<Id, Lead> convertedLeadsById = new Map<Id, Lead>();
		convertedLeadsById.put(lead.Id, lead);
		List<Contact> conList = [
				SELECT Id
				FROM Contact
		];
		conList[0].Birthdate = System.today().addDays(-16);
		update conList;
		List<Contact> contacts = TestDataFactory.createContact(1);
		contacts[0].Birthdate = System.today().addYears(-16);
		insert contacts;
		wishCase.ContactId = conList[0].Id;
		update wishCase;
		Test.startTest();
		npe4__Relationship__c relationShip = TestDataFactory.createRelationship(contacts[0].Id, conList[2].Id);
		npe4__Relationship__c newRelationShips = TestDataFactory.createRelationship(conList[0].Id, conList[3].Id);
		insert new List<npe4__Relationship__c>{
				relationShip, newRelationShips
		};
		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
		wishAffiliationsDataFactory[0].Contact__c = conList[2].Id;
		wishAffiliationsDataFactory[0].Relationship__c = relationShip.Id;
		wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD;
		wishAffiliationsDataFactory[0].Wish__c = wishCase.Id;
		wishAffiliationsDataFactory[1].Contact__c = contacts[0].Id;
		wishAffiliationsDataFactory[1].Wish__c = wishCase.Id;
		wishAffiliationsDataFactory[2].Contact__c = conList[3].Id;
		wishAffiliationsDataFactory[2].Relationship__c = newRelationShips.Id;
		wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
		wishAffiliationsDataFactory[2].Wish__c = wishCase.Id;
		insert wishAffiliationsDataFactory;

		List<Wish_Required_Signature__c> result = WishRequiredSignatureService.createWishSignaturesForConvertedLeads(newCasesByLeadId, convertedLeadsById);

		System.assertEquals(1, result.size());
	}
}