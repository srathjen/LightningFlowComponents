@IsTest
public class LeadWishFamilyDupe_Test {

	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
	}

	static testMethod void createRecords() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		newLead.Child_Age__c = '4';
		newLead.unique_wish_identifier__c = '123456';
		insert newLead;

		Test.startTest();
		String result = LeadWishFamilyDupe.FindFamilyContactDupe(newLead.id);
		Test.stopTest();
	}

	/*This method is used to increase the code coverage for findDuplicateRecords method */
	public testMethod static void findWishChildDupe() {

		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		newLead.unique_wish_identifier__c = '1234567';
		newLead.Child_Age__c = '4';
		insert newLead;
		Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		dupeLead.Override_Dupe_Check__c = true;
		dupeLead.unique_wish_identifier__c = '123456';
		insert dupeLead;

		Test.startTest();
		String result = LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);
		Test.stopTest();

		System.assertEquals(LeadWishFamilyDupe.DUPE_MESSAGE, result);
	}

	/*This method is used to increase the code coverage for findDuplicateRecords method */
	public testMethod static void findLeadDupe() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;

		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		newLead.unique_wish_identifier__c = '1234567';
		newLead.Child_Age__c = '4';
		newLead.State = 'Arizona';
		newLead.PostalCode = '35004';
		newLead.Street = 'test';
		newLead.Phone = '8220708920';
		insert newLead;
		Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		dupeLead.LastName = 'John';
		dupeLead.City = 'Karur';
		dupeLead.State = 'Arizona';
		dupeLead.PostalCode = '35004';
		dupeLead.Street = 'test';
		dupeLead.Phone = '8220708920';
		dupeLead.Override_Dupe_Check__c = true;
		dupeLead.unique_wish_identifier__c = '123456';
		insert dupeLead;

		String result = LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);
		LeadWishFamilyDupe.resetDVMedicalSummary(dupeLead.id);

		System.assertEquals(LeadWishFamilyDupe.DUPE_MESSAGE, result);

		// Covering other blocks of the FindLeadDupe method
		Test.startTest();
		dupeLead.FirstName = dupeLead.LastName = 'Test FN';
		dupeLead.DOB__c = newLead.DOB__c;
		dupeLead.Street = 'Test St.';
		update dupeLead;
		result = LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);

		dupeLead.FirstName = newLead.FirstName;
		dupeLead.State = 'Colorado';
		dupeLead.City = 'Denver';
		dupeLead.PostalCode = '12345';
		dupeLead.Phone = '1234567890';
		dupeLead.Email = 'Test@test.com';
		update dupeLead;
		result = LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);
		delete newLead;

		Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
		wishChildContact.FirstName = newLead.FirstName;
		wishChildContact.LastName = newLead.LastName;
		wishChildContact.Region_Chapter__c = newLead.ChapterName__c;
		insert wishChildContact;
		result = LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);

		wishChildContact.Birthdate = newLead.DOB__c;
		wishChildContact.Phone = newLead.Phone;
		wishChildContact.Email = newLead.Email;
		update wishChildContact;
		result = LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);
		Test.stopTest();
	}

	public testMethod static void sendDVWithICDCode() {

		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
		Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		dupeLead.LastName = 'John';
		dupeLead.city = 'Karur';
		dupeLead.State = 'Arizona';
		dupeLead.PostalCode = '35004';
		dupeLead.street = 'test';
		dupeLead.Phone = '8220708920';
		dupeLead.Override_Dupe_Check__c = true;
		dupeLead.unique_wish_identifier__c = '123456';
		dupeLead.ICD_Given_By_Referrer__c = dupeLead.PD_ICD_Code__c;
		insert dupeLead;

		Test.startTest();
		LeadWishFamilyDupe.resetDVMedicalSummary(dupeLead.id);
		Test.stopTest();

		Lead result = [
				SELECT LastName
				FROM Lead
		];
		System.assertEquals('John', result.LastName);
	}

	/*
	 * Chris Shinnimin, Traction on Demand:
	 * Additional tests to increase code coverage.
	 * Jira ticket WLP-322
	 */
	@IsTest
	private static void testDocusignDeleteList() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
		Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		dupeLead.LastName = 'John';
		dupeLead.city = 'Karur';
		dupeLead.State = 'Arizona';
		dupeLead.PostalCode = '35004';
		dupeLead.street = 'test';
		dupeLead.Phone = '8220708920';
		dupeLead.Override_Dupe_Check__c = true;
		dupeLead.unique_wish_identifier__c = '123456';
		dupeLead.ICD_Given_By_Referrer__c = dupeLead.PD_ICD_Code__c;
		insert dupeLead;

		dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(
				dsfs__Lead__c = dupeLead.id
		);
		insert dsStatus;

		Attachment att = new Attachment(
				ParentId = dsStatus.Id,
				Name = 'Some attachment',
				Body = Blob.valueOf('Some body')
		);
		insert att;

		Case caseToDelete = new Case(
				Lead__c = dupeLead.Id,
				RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID
		);
		insert caseToDelete;

		Test.startTest();
		LeadWishFamilyDupe.resetDVMedicalSummary(dupeLead.id);
		Test.stopTest();

		List<dsfs__DocuSign_Status__c> dsStatuses = [
				SELECT Id
				FROM dsfs__DocuSign_Status__c
		];
		List<Attachment> attachments = [
				SELECT Id
				FROM Attachment
		];

		System.assertEquals(0, dsStatuses.size());
		System.assertEquals(0, attachments.size());
	}
}