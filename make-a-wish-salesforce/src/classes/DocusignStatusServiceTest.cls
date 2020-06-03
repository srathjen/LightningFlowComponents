/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : DocusignStatusServiceTest is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@IsTest
public class DocusignStatusServiceTest {

	@TestSetup
	static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		Account accountAzChapter = TestDataFactory.createAccount(1)[0];
		accountAzChapter.Name = 'Make-A-Wish Arizona';
		accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accountAzChapter;

		List<Contact> contactList = TestDataFactory.createContact(2);
		Contact volunteerHector = contactList.get(0);
		volunteerHector.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		volunteerHector.AccountId = accountAzChapter.Id;
		volunteerHector.FirstName = 'Hector';
		volunteerHector.LastName = 'Sol';
		volunteerHector.Email = 'h.sol@email.com';

		Contact wishChildAnthony = contactList.get(1);
		wishChildAnthony.FirstName = 'Anthony';
		wishChildAnthony.LastName = 'Edwards';
		wishChildAnthony.Parent_Guardian_Name__c = 'Jonathan Edwards';
		wishChildAnthony.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		wishChildAnthony.Birthdate = Date.today().addDays(+21);
		wishChildAnthony.Birthdate = wishChildAnthony.Birthdate.addYears(-5);
		wishChildAnthony.MailingPostalCode = '94105-5188';
		wishChildAnthony.MailingStreet = '7540 E Gold Dust Ave';
		wishChildAnthony.MailingCountry = 'United States';
		wishChildAnthony.MailingState = 'Arizona';
		wishChildAnthony.MailingCity = 'Scottsdale';
		wishChildAnthony.MailingLatitude = -24.355798;
		wishChildAnthony.MailingLongitude = 69.830469;
		insert contactList;

		Case wishChildCase = TestDataFactory.createCase(1)[0];
		wishChildCase.RecordTypeId = Constant_AC.WISH_RT_ID;
		wishChildCase.ChapterName__c = accountAzChapter.Id;
		wishChildCase.Subject = 'Parent Wish';
		wishChildCase.Interview_date__c = System.today();
		wishChildCase.Wish_Type__c = 'Disney World';
		wishChildCase.Start_Date__c = System.today();
		wishChildCase.End_Date__c = System.today();
		wishChildCase.ContactId = wishChildAnthony.Id;
		wishChildCase.Status = 'New';
		wishChildCase.Start_Date__c = System.today();
		wishChildCase.LiabilitySignerMapKeyPair__c = 'Vennila';
		wishChildCase.Budget_Submitted_Date__c = System.today();
		wishChildCase.Budget_Approved_Date__c = System.today();
		insert wishChildCase;

		Lead referredLead = TestDataFactory.createLead(1)[0];
		referredLead.FirstName = 'Thomas';
		referredLead.LastName = 'Naranja';
		referredLead.Company = 'MAWA';
		referredLead.Street = '123 Cactus Road';
		referredLead.State = 'Arizona';
		referredLead.StateCode = 'AZ';
		referredLead.City = 'Phoenix';
		referredLead.Postalcode = '85264';
		referredLead.CountryCode = 'US';
		referredLead.Gender__c = 'Male';
		referredLead.Phone = '7600467559';
		referredLead.ChapterName__c = accountAzChapter.Id;
		referredLead.DOB__c = System.today() - 1435;
		referredLead.is_Family_Aware_of_Referral__c = 'Yes';
		referredLead.Referrer_FirstName__c = 'Janet';
		referredLead.Referrer_Last_Name__c = 'Evans';
		referredLead.Referrer_Email__c = 'janet.evans.test@gmail.com';
		referredLead.Referrer_Phone__c = '0600467559';
		referredLead.Referrer_City__c = 'Phoenix';
		referredLead.Referrer_Zip__c = '85264';
		referredLead.Hospital_Treatment_Facility__c = 'Phoenix Medical Center';
		referredLead.Hospital_Treatment_Facility_Treating__c = 'Phoenix Medical Center';
		referredLead.PD_Condition_Description__c = 'Malignant Melanoma';
		referredLead.Diagnosis_Given_By_Referrer__c = 'Malignant Melanoma';
		referredLead.Treating_Medical_Professional_First_Name__c = 'John';
		referredLead.Treating_Medical_Professional_Last_Name__c = 'Doe';
		referredLead.Treating_Medical_Professional_Phone__c = '9600467578';
		referredLead.Treating_Medical_Professional_Email__c = 'medical.prof.test@gmail.com';
		referredLead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		referredLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
		referredLead.RFI_Form_Info_Hidden__c = Constant_AC.LEAD_RFI_FORM_INFO_QUALIFIED;
		insert referredLead;

        referredLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
        referredLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
        update referredLead;

		Wish_Signature_Forms__c wishForm = TestDataFactory.createWishSignatureForm(1)[0];
		insert wishForm;

		Wish_Required_Signature__c wishSignature = TestDataFactory.createWishRequiredSignature(1)[0];
		wishSignature.Wish_Case__c = wishChildCase.Id;
		wishSignature.Wish_Signature_Form__c = wishForm.Id;
		insert wishSignature;

		List<dsfs__DocuSign_Status__c> docusignStatusList = TestDataFactory.createDocusignStatus(4);
		dsfs__DocuSign_Status__c dsfsVolunteer1 = docusignStatusList.get(0);
		dsfsVolunteer1.Docusign_Hidden_Contact__c = volunteerHector.Id;
		dsfsVolunteer1.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
		dsfsVolunteer1.dsfs__Subject__c = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_FORM;
		dsfsVolunteer1.dsfs__Contact__c = volunteerHector.Id;
		dsfsVolunteer1.Wish_Required_Signature__c = wishSignature.Id;
		dsfsVolunteer1.isConflict__c = false;
        dsfsVolunteer1.dsfs__Case__c = wishChildCase.Id;

		dsfs__DocuSign_Status__c dsfsVolunteer2 = docusignStatusList.get(1);
		dsfsVolunteer2.Docusign_Hidden_Contact__c = volunteerHector.Id;
		dsfsVolunteer2.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
		dsfsVolunteer2.dsfs__Subject__c = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_FORM;
		dsfsVolunteer2.dsfs__Contact__c = volunteerHector.Id;
		dsfsVolunteer2.Wish_Required_Signature__c = wishSignature.Id;
		dsfsVolunteer2.isConflict__c = false;

		dsfs__DocuSign_Status__c dsfsLead = docusignStatusList.get(2);
		dsfsLead.dsfs__Lead__c = referredLead.Id;
		dsfsLead.Docusign_Hidden_Contact__c = volunteerHector.Id;
		dsfsLead.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_STATUS_ENVELOPE_STATUS_SENT;
		dsfsLead.dsfs__Subject__c = Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM;
		dsfsLead.dsfs__Contact__c = volunteerHector.Id;
		dsfsLead.Wish_Required_Signature__c = wishSignature.Id;
		dsfsLead.isConflict__c = false;

		dsfs__DocuSign_Status__c dsfsCase = docusignStatusList.get(3);
		dsfsCase.dsfs__Case__c = wishChildCase.Id;
        dsfsCase.Docusign_Hidden_Contact__c = volunteerHector.Id;
		dsfsCase.dsfs__Subject__c = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_FORM;
        dsfsCase.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_STATUS_ENVELOPE_STATUS_SENT;
		dsfsCase.isConflict__c = false;
		insert docusignStatusList;

        System.debug('Texxxt ' + docusignStatusList);

		Attachment attachment = TestDataFactory.createAttachments(1, dsfsVolunteer1.Id)[0];
		insert attachment;

		List<Conflict_Of_Interest__c> conflictOfInterestDataFactory = TestDataFactory.createConflictOfInterest(1);
		List<Conflict_Of_Interest__c> conflictOfInterests = new List<Conflict_Of_Interest__c>();
		Conflict_Of_Interest__c conflictOfInterest = conflictOfInterestDataFactory.get(0);
		conflictOfInterest.Current__c = true;
		conflictOfInterest.Account_Name__c = accountAzChapter.Name;
		conflictOfInterest.Signed_Date__c = Date.today();
		conflictOfInterest.Volunteer_Contact__c = volunteerHector.Id;
		conflictOfInterests.add(conflictOfInterest);
		insert conflictOfInterests;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldUpdateWishSignature() {
		List<dsfs__DocuSign_Status__c> docuSignStatuses = [
				SELECT Id, dsfs__Envelope_Status__c, Wish_Required_Signature__c
				FROM dsfs__DocuSign_Status__c
				WHERE Wish_Required_Signature__c != NULL
		];
		Test.startTest();
		DocusignStatusService.updateWishSignatures(docuSignStatuses);
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateRelatedParentRecords() {
		List<dsfs__DocuSign_Status__c> docuSignStatuses = [
				SELECT Id, Docusign_Hidden_Contact__c, dsfs__Envelope_Status__c, isConflict__c, dsfs__Lead__c,
						dsfs__Case__c, dsfs__Subject__c
				FROM dsfs__DocuSign_Status__c
		];

        docuSignStatuses.get(0).dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        docuSignStatuses.get(0).isConflict__c = true;
        dsfs__DocuSign_Status__c oldDocusignStatus = new dsfs__DocuSign_Status__c();
        oldDocusignStatus.Id = docuSignStatuses.get(0).Id;
        oldDocusignStatus.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_RECIPIENT_STATUS_SENT;
        List<dsfs__DocuSign_Status__c> newDocusignStatuses = new List<dsfs__DocuSign_Status__c>{docuSignStatuses.get(0)};
        Map<Id, dsfs__DocuSign_Status__c> oldDocusignStatusesMap = new Map<Id, dsfs__DocuSign_Status__c>{oldDocusignStatus.Id => oldDocusignStatus};

        Test.startTest();
        DocusignStatusService.updateRelatedParentRecords(newDocusignStatuses, oldDocusignStatusesMap, Date.today());
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateLeads() {
		List<dsfs__DocuSign_Status__c> docuSignStatuses = [
				SELECT Id, Docusign_Hidden_Contact__c, dsfs__Envelope_Status__c, isConflict__c, dsfs__Lead__c,
						dsfs__Case__c, dsfs__Contact__c, dsfs__Subject__c, dsfs__Completed_Date_Time__c
				FROM dsfs__DocuSign_Status__c
                WHERE dsfs__Envelope_Status__c = :Constant_AC.DOCUSIGN_STATUS_ENVELOPE_STATUS_SENT
                LIMIT 1
		];
		Contact wishChildAnthony = [
				SELECT Id
				FROM Contact
				WHERE LastName = 'Edwards'
		];
        docuSignStatuses.get(0).dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
		dsfs__DocuSign_Status__c oldDocusignStatus = new dsfs__DocuSign_Status__c();
        oldDocusignStatus.Id = docuSignStatuses.get(0).Id;
        oldDocusignStatus.dsfs__Contact__c = wishChildAnthony.Id;
        oldDocusignStatus.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_RECIPIENT_STATUS_SENT;
        oldDocusignStatus.dsfs__Case__c = docuSignStatuses.get(0).dsfs__Case__c;

		Map<Id, dsfs__DocuSign_Status__c> oldDocusignStatuses = new Map<Id, dsfs__DocuSign_Status__c>{oldDocusignStatus.Id => oldDocusignStatus};
		Test.startTest();
		DocusignStatusService.updateLeads(docuSignStatuses, oldDocusignStatuses);
		Test.stopTest();
	}

	@IsTest
	public static void shouldWishChildDVAttachment() {
		Attachment attachment = [
				SELECT ParentId
				FROM Attachment
				LIMIT 1
		];
		Contact contact = [
				SELECT Id
				FROM Contact
                WHERE Name = 'Anthony Edwards'
				LIMIT 1
		];
		Test.startTest();
		DocusignStatusService.wishChildDVAttachment(new Map<Id, Id>{
				contact.Id => attachment.ParentId
		});
		Test.stopTest();
	}
}