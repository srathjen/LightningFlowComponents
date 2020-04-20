@isTest
public class ContactMergeController_Test {
	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
	}

	public static testMethod void contactMergerTest() {
		Account hospitaltreatmentaccount = OrientationandTrainingUtil.HospitalTreatment();
		Account chapteraccount = OrientationandTrainingUtil.MakeAWishAmericaAcc();
		Account householdaccount = OrientationandTrainingUtil.HouseHoldAccount();
		insert new List<Account>{
				hospitaltreatmentaccount, chapteraccount, householdaccount
		};
            
		User prospect;
		system.runAs(new User(Id = userinfo.getuserId())) {
			prospect = OrientationandTrainingUtil.createProspectiveVolunteerUser(null);
			insert prospect;
		}
		Contact prospectContact = [
				SELECT Id
				FROM Contact
				WHERE Id = :prospect.ContactId
		];
		prospectContact.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		update prospectContact;

		Contact confamily = OrientationandTrainingUtil.CreateWishFamily();
		Contact conchild = OrientationandTrainingUtil.CreateWishChild();
		Contact convolunteer = OrientationandTrainingUtil.createVolunteerContact(chapteraccount.Id);
		Contact medicalprof = OrientationandTrainingUtil.CreateMedicalProfContact();
		insert new List<Contact>{
				confamily, conchild, convolunteer, medicalprof
		};

		insert new List<Case>{
				new Case(ContactId = confamily.Id),
				new Case(ContactId = conchild.Id),
				new Case(ContactId = convolunteer.Id),
				new Case(ContactId = prospectContact.Id)
		};

		Conflict_Of_Interest__c coi = OrientationandTrainingUtil.createCOI(convolunteer.id);
		insert coi;

		Role__c role = OrientationandTrainingUtil.createRole();
		insert role;

		Orientation_Training__c ot = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert ot;

		Chapter_Role__c chapterrole = OrientationandTrainingUtil.createChapter(chapteraccount.id, role.id);
		insert chapterrole;

		Chapter_Role_O_T__c chapterroleot = OrientationandTrainingUtil.createChapterOandT(chapterrole.id, ot.Id);
		insert chapterroleot;

		test.startTest();
		Class_Offering__c classoff = OrientationandTrainingUtil.createClassOffering(chapterroleot.Id);
		insert classoff;

		npe4__Relationship__c relation = OrientationandTrainingUtil.relationshipChild(confamily.id, conchild.id);
		insert relation;

		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(medicalprof.id);
		insert affiliation;

		Volunteer_Roles__c volrole = OrientationandTrainingUtil.createVolRole(convolunteer.Id, chapterrole.Id);
		insert volrole;

		Volunteer_Orientation_Training__c volorientationtraining = OrientationandTrainingUtil.createVolOrientation(ot.Id, classoff.Id, medicalprof.Id, 'Registered');
		insert volorientationtraining;
		
        Volunteer_Opportunity__c volopp = OrientationandTrainingUtil.NewnonWishVolunteerOpportunity(chapterAccount.Id, convolunteer.id);
		insert volopp;
		
        Background_check__c backgdcheck = OrientationandTrainingUtil.createBackgroundCheck(convolunteer.Id);
		insert backgdcheck;

		Awards_Recognition__c awdreg = OrientationandTrainingUtil.CreateAwardRecognition(chapteraccount.Id, convolunteer.Id);
		insert awdreg;

		In_Kind_Donation_Reimbursement__c inkinddonation = OrientationandTrainingUtil.createReImbursementRecord();
		insert inkinddonation;

		ApexPages.StandardController sc = new ApexPages.StandardController(convolunteer);
		ContactMergeController_AC testobj = new ContactMergeController_AC(sc);
		testobj.getStates();
		ContactMergeController_AC.contactWrapper contactwrapper1 = new ContactMergeController_AC.contactWrapper(convolunteer);
		ContactMergeController_AC.contactWrapper contactwrapper2 = new ContactMergeController_AC.contactWrapper(convolunteer);
		ContactMergeController_AC.Cell testcellwrap = new ContactMergeController_AC.Cell(convolunteer.Id, convolunteer.Name);
		ContactMergeController_AC.VolunteerOpportunityWrapper volopwrap = new ContactMergeController_AC.VolunteerOpportunityWrapper(volopp);
		ContactMergeController_AC.VolunteerRoleWrapper volrolwrap = new ContactMergeController_AC.VolunteerRoleWrapper(volrole);
		ContactMergeController_AC.VolunteerOTWrapper volotwrap = new ContactMergeController_AC.VolunteerOTWrapper(volorientationtraining);
		ContactMergeController_AC.VolunteerOTWrapper volotwrap2 = new ContactMergeController_AC.VolunteerOTWrapper(volorientationtraining);
		ContactMergeController_AC.affiliationWrapper affwrap = new ContactMergeController_AC.affiliationWrapper(affiliation);
		ContactMergeController_AC.affiliationWrapper affwrap2 = new ContactMergeController_AC.affiliationWrapper(affiliation);
		ContactMergeController_AC.relationshipWrapper relwrap = new ContactMergeController_AC.relationshipWrapper(relation);
		ContactMergeController_AC.relationshipWrapper relwrap2 = new ContactMergeController_AC.relationshipWrapper(relation);
		ContactMergeController_AC.BackgroundCheckWrapper backgdwrap = new ContactMergeController_AC.BackgroundCheckWrapper(backgdcheck);
		ContactMergeController_AC.AwardsRecognitionWrapper awdwrap = new ContactMergeController_AC.AwardsRecognitionWrapper(awdreg);
		ContactMergeController_AC.ConflictOfInterestWrapper coiwrap = new ContactMergeController_AC.ConflictOfInterestWrapper(coi);
		ContactMergeController_AC.InkindDonationWrapper inkindwrap = new ContactMergeController_AC.InkindDonationWrapper(inkinddonation);
		ContactMergeController_AC.InkindDonationWrapper inkindwrap2 = new ContactMergeController_AC.InkindDonationWrapper(inkinddonation);
		ContactMergeController_AC.FieldRow fieldrow = new ContactMergeController_AC.FieldRow('$MASTER$', 'Master Record', true, 'teststyleclass');
		ContactMergeController_AC.FieldRow fieldrow2 = new ContactMergeController_AC.FieldRow('FirstName', 'Master Record', true, 'teststyleclass');

		cg__ContactFile__c cf = new cg__ContactFile__c();
		cf.Name = 'Test';
		cf.cg__Contact__c = convolunteer.id;
		cf.cg__File_Name__c = 'Test File';
		insert cf;
		List<Contact> conlists = new List<Contact>();
		conlists.add(confamily);
		testobj.addFieldComparisonRows('Wish_Child_Id_Hidden__c', Contact.Wish_Child_Id_Hidden__c.getDescribe(), conlists);
		contactwrapper1.selected = true;
		testobj.searchResults.add(contactwrapper1);
		contactwrapper2.selected = true;
		testobj.searchResults.add(contactwrapper2);
		testobj.mapHoldingSelectedRecords.put(contactwrapper1.con.Id, contactwrapper1);
		testobj.mapHoldingSelectedRecords.put(contactwrapper2.con.Id, contactwrapper2);
		testobj.selectedRecords.put(confamily.Id, confamily);
		testobj.setPageSize();
		testobj.nextStep();
		testobj.first();
		testobj.next();
		testobj.previous();
		testobj.last();
		Boolean haspre = testobj.hasPrevious;
		Boolean hasnext = testobj.hasNext;
		integer pageNo = testobj.pageNumber;
		Integer totalPage = testobj.getTotalPages();
		testobj.searchRecords();
		volopwrap.checkbox = true;
		volrolwrap.checkbox = true;
		volotwrap.checkbox = true;
		volotwrap2.checkbox = false;
		testobj.volunteerRoleList.add(volrolwrap);
		relwrap.checkbox = true;
		relwrap2.checkbox = false;
		affwrap.checkbox = true;
		affwrap2.checkbox = false;
		backgdwrap.checkbox = true;
		inkindwrap.checkbox = true;
		inkindwrap2.checkbox = false;
		awdwrap.checkbox = true;
		coiwrap.checkbox = true;
		testobj.volunteerOppList.add(volopwrap);
		testobj.volunteerRoleList.add(volrolwrap);
		testobj.volunteerOTList.add(volotwrap);
		testobj.volunteerOTList.add(volotwrap2);
		testobj.relationshipList.add(relwrap);
		testobj.relationshipList.add(relwrap2);
		testobj.affiliationsList.add(affwrap);
		testobj.affiliationsList.add(affwrap2);
		testobj.backgroundcheckList.add(backgdwrap);
		testobj.awardsRecognitionList.add(awdwrap);
		testobj.inkindDonationList.add(inkindwrap);
		testobj.inkindDonationList.add(inkindwrap2);
		testobj.conflictofInterestList.add(coiwrap);
		testobj.fieldRows.add(fieldrow);
		testobj.fieldRows.add(fieldrow2);
		List<Contact> conlist = new List<Contact>();
		conlist.add(convolunteer);
		testobj.wrapSOSLResults(conlist);
		Test.setCurrentPage(Page.MergeContact_VF);
		ApexPages.currentPage().getParameters().put('recordId', conchild.Id);
		testobj.selectedRecords.put(confamily.Id, confamily);
		testobj.selectedRecords.put(conchild.Id, conchild);
		testobj.selectedRecords.put(convolunteer.Id, convolunteer);
		testobj.selectedRecords.put(prospectContact.Id, prospectContact);
		testobj.selectDefaultRecord();
		testobj.mergeContacts();
		Test.stopTest();

		testobj.volunteerOppList.clear();
		testobj.volunteerOTList.clear();
		testobj.volunteerRoleList.clear();
		testobj.relationshipList.clear();
		testobj.affiliationsList.clear();
		testobj.backgroundcheckList.clear();
		testobj.awardsRecognitionList.clear();
		testobj.inkindDonationList.clear();
		testobj.conflictofInterestList.clear();
		testobj.mergeContacts();
	}

	public static testmethod void contactSearchRecord() {
		Account chapteraccount = OrientationandTrainingUtil.MakeAWishAmericaAcc();
		insert chapteraccount;

		Contact confamily = OrientationandTrainingUtil.CreateWishFamily();
		Contact conchild = OrientationandTrainingUtil.CreateWishChild();
		Contact convolunteer = OrientationandTrainingUtil.createVolunteerContact(chapteraccount.Id);
		insert new List<Contact>{
				confamily, conchild, convolunteer
		};

		ApexPages.StandardController sc = new ApexPages.StandardController(convolunteer);
		ContactMergeController_AC testobj = new ContactMergeController_AC(sc);
		User prospect;
		system.runAs(new User(id = userinfo.getuserId())) {
			prospect = OrientationandTrainingUtil.createProspectiveVolunteerUser(convolunteer.Id);
			insert prospect;
		}

		Set<Id> contactIdSet = new Set<Id>();
		contactIdSet.add(convolunteer.Id);
		testobj.con.FirstName = 'moss';
		testobj.con.LastName = 'Smith';
		testobj.con.MailingStreet = 'ThillaiNagar';
		testobj.con.MailingCity = 'Trichy';
		testobj.con.MailingCountrycode = 'US';
		testobj.con.MailingPostalCode = '621010';
		testobj.con.mailingstatecode = 'AZ';
		testobj.searchRecords();
		testobj.setPageSize();
		testobj.first();
		testobj.next();
		testobj.previous();
		testobj.last();
		ContactMergeController_AC.updateUser(new Set<Id>{
				prospect.ContactId
		});

		ContactMergeController_AC.VolunteerOpportunityWrapper volunteerOpportunityWrapper = new ContactMergeController_AC.VolunteerOpportunityWrapper(new Volunteer_Opportunity__c());
		Volunteer_Opportunity__c volOpp = volunteerOpportunityWrapper.volunteerOpp;
		Boolean checkbox = volunteerOpportunityWrapper.checkbox;

		ContactMergeController_AC.contactWrapper contactwrapper1 = new ContactMergeController_AC.contactWrapper(convolunteer);
		ContactMergeController_AC.contactWrapper contactwrapper2 = new ContactMergeController_AC.contactWrapper(conchild);
		contactwrapper1.selected = true;
		testobj.searchResults.add(contactwrapper1);
		contactwrapper2.selected = true;
		testobj.searchResults.add(contactwrapper2);
		testobj.nextStep();
		testobj.mapHoldingSelectedRecords = new Map<Id, ContactMergeController_AC.ContactWrapper>();
		testobj.nextStep();
		ContactMergeController_AC.updateUser(contactIdSet);
		testobj.mySOSL = null;
		testobj.con.Email = 'Test@test.com';
		testobj.birthDate = '01/01/2000';
		testobj.setPageSize = null;
		ApexPages.StandardSetController ssc = testobj.mySOSL;
	}
}