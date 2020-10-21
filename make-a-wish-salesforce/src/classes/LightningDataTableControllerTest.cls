/* 
* @Description Test class of LightningDatatableController
* @author Mitali Nahar, Traction on Demand
* @Date 2019-06-10
*/

@IsTest
public class LightningDataTableControllerTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
	private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
	private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id MEDICAL_PROF_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Date DT = System.today().addYears(-20);

	@TestSetup
	private static void insertTestData() {
		List<Account> accountsDataFactory = TestDataFactory.createAccount(2);
		accountsDataFactory[0].RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
		accountsDataFactory[1].RecordTypeId = CHAPTER_RECORD_TYPE_ID ;
		insert accountsDataFactory;

		ICD_Codes__c obj = new ICD_Codes__c();
		obj.Name = 'Q917';
		insert obj;
        List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
        contactsDataFactory[0].RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
        contactsDataFactory[0].ICD_10_Code__c = obj.Id;
        contactsDataFactory[1].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[1].BirthDate = System.today().addYears(-20);
        contactsDataFactory[2].RecordTypeId = MEDICAL_PROF_RECORD_TYPE_ID;
        contactsDataFactory[2].Region_Chapter__c = accountsDataFactory[1].Id;
        contactsDataFactory[3].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[3].BirthDate = System.today().addYears(-10);
        insert contactsDataFactory;

		List<Case> casesDataFactory = TestDataFactory.createCase(1);
		casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
		casesDataFactory[0].ChapterName__c = accountsDataFactory[1].Id;
		casesDataFactory[0].AccountId = accountsDataFactory[0].Id;
		casesDataFactory[0].ContactId = contactsDataFactory[0].Id;
		casesDataFactory[0].Origin = 'Email';
		casesDataFactory[0].Status = 'Qualified';
		insert casesDataFactory;

		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
		wishAffiliationsDataFactory[0].Contact__c = contactsDataFactory[1].Id;
		wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
		wishAffiliationsDataFactory[0].Wish__c = casesDataFactory[0].Id;
		wishAffiliationsDataFactory[1].Contact__c = contactsDataFactory[3].Id;
		wishAffiliationsDataFactory[1].Wish_Affiliation_Type__c = 'Approved Participant' ;
		wishAffiliationsDataFactory[1].Wish__c = casesDataFactory[0].Id;
		wishAffiliationsDataFactory[2].Contact__c = contactsDataFactory[2].Id;
		wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = 'Medical Professional' ;
		wishAffiliationsDataFactory[2].Wish__c = casesDataFactory[0].Id;
		insert wishAffiliationsDataFactory;

		List<Wish_Signature_Forms__c> wishSignFormsDataFactory = TestDataFactory.createWishSignatureForm(1);
		wishSignFormsDataFactory[0].DocGen_Package_ID__c = wishSignFormsDataFactory[0].Delivery_Option_ID_eSign__c = null;
		wishSignFormsDataFactory[0].Delivery_Option_ID_Print__c = '1234567890';
		wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
		insert wishSignFormsDataFactory;

		List<Wish_Signature_Chapter_Form__c> wishSignChapFormsDataFactory = TestDataFactory.createWishSignatureChapterForm(1);
		wishSignChapFormsDataFactory[0].Chapter_Account__c = accountsDataFactory[1].Id;
		wishSignChapFormsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
		insert wishSignChapFormsDataFactory;

		List<Wish_Required_Signature__c> wishReqSignsDataFactory = TestDataFactory.createWishRequiredSignature(1);
		wishReqSignsDataFactory[0].Wish_Case__c = casesDataFactory[0].Id;
		wishReqSignsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
		wishReqSignsDataFactory[0].Status__c = 'Not Sent';
		wishReqSignsDataFactory[0].Type__c = 'Medical';
		wishReqSignsDataFactory[0].Wish_Affiliation__c = wishAffiliationsDataFactory[0].Id;
		insert wishReqSignsDataFactory;
	}

	@IsTest
	public static void testgetWishAffiliations() {
		Test.startTest();
		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		System.assertEquals(true, wishCase != null);

		LightningDataTableController.DataTableResponse wrapperData = LightningDataTableController.getRecords('Wish_Required_Signature__c', 'FamilySignatureTracker', 'Family', wishCase.Id, 'false');
		System.assertEquals(false, wrapperData == null);
		wrapperData = LightningDataTableController.getRecords('Wish_Required_Signature__c', 'FamilySignatureTracker', 'Medical', wishCase.Id, 'false');
		System.assertEquals(false, wrapperData == null);
		Test.stopTest();
	}

	@IsTest
	public static void testdeleteWishRequiredSigns() {
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);

		LightningDataTableController.deleteWishRequiredSigns(String.valueOf(wishSign.Id));

		try {
			LightningDataTableController.deleteWishRequiredSigns(String.valueOf(wishSign.Id));
			System.assert(false, 'Expecting a AuraHandledException here');
		} catch (AuraHandledException e) {
			// Expecting a DmlException
		} catch (Exception e) {
			System.assert(false, 'Expecting a AuraHandledException here');
		}
		Test.stopTest();
	}

	@IsTest
	public static void testupdateFormOnWRS() {
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);

		Wish_Signature_Forms__c wishForm = [
				SELECT Id
				FROM Wish_Signature_Forms__c
				LIMIT 1
		];
		System.assertEquals(false, wishForm == null);

		LightningDataTableController.updateFormOnWRS(String.valueOf(wishSign.Id), String.valueOf(wishForm.Id));
		try {
			Account acc = [
					SELECT Id
					FROM Account
					LIMIT 1
			];
			LightningDataTableController.updateFormOnWRS(String.valueOf(wishSign.Id), String.valueOf(acc.Id));
			System.assert(false, 'Expecting a AuraHandledException here');
		} catch (AuraHandledException e) {
			// Expecting a AuraHandledException
		} catch (Exception e) {
			System.assert(false, 'Expecting a AuraHandledException here');
		}
		Test.stopTest();
	}

	@IsTest
	public static void testupdateSignerOnWRS() {
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);

		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		System.assertEquals(true, wishCase != null);

		Case getCase = LightningDataTableController.getWish(String.valueOf(wishCase.Id));

		Contact wishCon = [
				SELECT Id
				FROM Contact
				WHERE BirthDate = :DT
				LIMIT 1
		];
		System.assertEquals(false, wishCon == null);

		Wish_Affiliation__c wisAff = LightningDataTableController.getWishAffRecord(String.valueOf(wishCon.Id), String.valueOf(wishCase.Id));
		LightningDataTableController.updateSignerOnWRS(String.valueOf(wishSign.Id), String.valueOf(wishCon.Id), String.valueOf(wishCase.Id));
		try {
			Account acc = [
					SELECT Id
					FROM Account
					LIMIT 1
			];
			LightningDataTableController.updateSignerOnWRS(String.valueOf(wishSign.Id), String.valueOf(acc.Id), String.valueOf(acc.Id));
			System.assert(false, 'Expecting a AuraHandledException here');
		} catch (AuraHandledException e) {
			// Expecting a AuraHandledException
		} catch (Exception e) {
			System.assert(false, 'Expecting a AuraHandledException here');
		}
		Test.stopTest();
	}

	@IsTest
	public static void testGetWishAffRecord() {
		Contact wishCon = [
				SELECT Id
				FROM Contact
				WHERE BirthDate = :DT
				LIMIT 1
		];

		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];

		Test.startTest();
		Wish_Affiliation__c wishAff = LightningDataTableController.getWishAffRecord(String.valueOf(wishCon.Id), String.valueOf(wishCase.Id));
		System.assertNotEquals(null, wishAff);
		try {
			wishAff = LightningDataTableController.getWishAffRecord(null, null);
			System.assert(false, 'Expecting a AuraHandledException here');
		} catch (AuraHandledException e) {
			// Expecting a AuraHandledException
		} catch (Exception e) {
			System.assert(false, 'Expecting a AuraHandledException here');
		}
	}

	@IsTest
	public static void testGetWish() {
		Case wishCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];

		Case getCase = LightningDataTableController.getWish(String.valueOf(wishCase.Id));
		System.assertNotEquals(null, getCase);
		getCase = LightningDataTableController.getWish(null);
		System.assertEquals(null, getCase);
		try {
			Account acc = [
					SELECT Id
					FROM Account
					LIMIT 1
			];
			getCase = LightningDataTableController.getWish(acc.Id);
			System.assert(false, 'Expecting a AuraHandledException here');
		} catch (AuraHandledException e) {
			// Expecting a AuraHandledException
		} catch (Exception e) {
			System.assert(false, 'Expecting a AuraHandledException here');
		}
	}

	@IsTest
	public static void testDocGen() {
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);

		try {
			Wish_Signature_Forms__c wishForm = LightningDataTableController.getDocGen(wishSign.Id);
		} catch (Exception e) {
			System.assertEquals('Script-thrown exception', e.getMessage());
		}
		Test.stopTest();
	}

	@IsTest
	public static void testgetWishFilePath() {
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);
		Wish_Required_Signature_File__c wishFile = new Wish_Required_Signature_File__c(Wish_Required_Signature__c = wishSign.Id, File_Path__c = 'tesp path');
		insert wishFile;

		Wish_Required_Signature_File__c obj = LightningDataTableController.getWishFilePath (wishSign.Id);
		System.assertEquals(wishFile.File_Path__c, obj.File_Path__c);
		Test.stopTest();
	}

	@IsTest
	public static void testupdateEnvelopeDocusign() {
		DocuSignCredentialsSetting__c setting = new DocuSignCredentialsSetting__c();
		setting.Name = 'Custom Setting';
		setting.account__c = 'Test Setting';
		setting.account__c = 'Whatever';
		insert setting;
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);
		Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator());
		LightningDataTableController.updateEnvelopeDocusign('Resend', 'test@test.com', wishSign.Id, '', null, '', '');
		LightningDataTableController.updateEnvelopeDocusign('Void', '', wishSign.Id, 'Void Reason', null, '', '');

		Contact wishCon = [
				SELECT Id,Name,Email
				FROM Contact
				LIMIT 1
		];
		System.assertEquals(false, wishCon == null);

		insert new dsfs__DocuSign_Status__c(Wish_Required_Signature__c = wishSign.Id, dsfs__DocuSign_Envelope_ID__c = '1234567890');

		LightningDataTableController.updateEnvelopeDocusign('Reassign', '', wishSign.Id, '', wishCon, 'test@test.com', '');
		Test.stopTest();
	}

	@IsTest
	public static void testupdateWishSign() {
		Test.startTest();
		Wish_Required_Signature__c wishSign = [
				SELECT Id
				FROM Wish_Required_Signature__c
				LIMIT 1
		];
		System.assertEquals(false, wishSign == null);

		LightningDataTableController.updateWishSignature(wishSign.Id, 'E-Signature', 'test@test.com');

		List<Wish_Affiliation__c> wishAffList = [
				SELECT Id
				FROM Wish_Affiliation__c
				LIMIT 1
		];
		System.assertEquals(false, wishAffList == null);
		String wishAffiliation = JSON.serialize(wishAffList);
		LightningDataTableController.updateWishSignatureForReassign(wishSign.Id, 'Paper', 'test@test.com', wishAffiliation);
		try {
			Account acc = [
					SELECT Id
					FROM Account
					LIMIT 1
			];
			LightningDataTableController.updateWishSignature(null, 'Paper', 'test@test.com');
			System.assert(false, 'Expecting a AuraHandledException here');
		} catch (AuraHandledException e) {
			// Expecting a AuraHandledException
		} catch (Exception e) {
			System.assert(false, 'Expecting a AuraHandledException here');
		}
		Test.stopTest();
	}

	@IsTest
	public static void testGetMetadata() {
		Test.startTest();
		LightningDataTableController.MetadataWrapper metadataWrapper = LightningDataTableController.getMetadata();
		Test.stopTest();
		String metadataMedRtId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		System.assertEquals(metadataMedRtId, metadataWrapper.medicalProfessionalId);
	}
}