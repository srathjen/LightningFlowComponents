/*************************************************************************
Author : MST Solutions
CreatedDate :  8/5/2016
Description : Unit Test for AffiliationTriggerHandler and Affiliation_AT.
Modification Log
1. WVC-2205 - Kanagaraj - 08/08/2018 - //Line 38 previously the status was "Prospective"
                                         Now we have updated as "Pending".
**************************************************************************/
@IsTest
public class Affiliation_AT_Test {

	@IsTest//Used to verify the status of the Affiliation is set to prospective when it gets created.
	static void updateContact() {
		Test.startTest();
		Id volunteerRecordTypeId = Constant_AC.BOARD_MEMBER_RT_ID;
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
		volunteerContact.RecordTypeId = volunteerRecordTypeId;
		insert volunteerContact;

		System.assertEquals(volunteerContact.RecordTypeId, volunteerRecordTypeId, 'Recordtype doesnot match');
		Map<Id, npe5__Affiliation__c> contactMap = new Map<Id, npe5__Affiliation__c>();
		Set<Id> affiliationIds = new Set<Id>();
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = volunteerContact.Id;
		neworgAffiliation.npe5__Organization__c = volunteerAccount.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
		neworgAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		insert neworgAffiliation;

		contactMap.put(neworgAffiliation.npe5__Contact__c, neworgAffiliation);
		affiliationIds.add(neworgAffiliation.npe5__Organization__c);
		System.assertEquals(Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE, neworgAffiliation.npe5__Status__c, 'Incorrect Affiliation Status');
		neworgAffiliation.Id = neworgAffiliation.Id;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
		update neworgAffiliation;
		System.assertEquals('Pending', neworgAffiliation.npe5__Status__c, 'Incorrect Affiliation Status');
		Test.stopTest();
	}

	//Used to create volunteer account, contact and affilation with status active for volunteer user.
	@IsTest
	static void affiliationUpdateWithActive() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
		insert volunteerContact;

		System.runAs (new User(Id = UserInfo.getUserId())) {
			User activeVolunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert activeVolunteerUser;
		}

		Background_check__c bgRecord = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.Id);
		bgRecord.Volunteer_is_Inactive__c = true;
		insert bgRecord;

		Conflict_Of_Interest__c coiRecord = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
		coiRecord.Volunteer_is_Inactive__c = true;
		insert coiRecord;

		Group alabamaGroup = new Group();
		alabamaGroup.Name = 'Make-A-Wish Alabama';
		alabamaGroup.DeveloperName = 'ABC';
		insert alabamaGroup;

		System.assertEquals('Make-A-Wish Alabama', alabamaGroup.Name, 'Chapter Name doesnot match');

		List<npe5__Affiliation__c> volunteerAffiliationList = [
				SELECT Id, npe5__Status__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :volunteerContact.Id
		];
		volunteerAffiliationList[0].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		volunteerAffiliationList[1].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
		update volunteerAffiliationList;

		List<npe5__Affiliation__c> updatedAfflList = [
				SELECT Id, npe5__Status__c
				FROM npe5__Affiliation__c
				WHERE ID IN :volunteerAffiliationList
		];

		System.assertEquals(Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE, volunteerAffiliationList[1].npe5__Status__c, 'Status is not Inactive');

		volunteerAffiliationList[0].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
		volunteerAffiliationList[1].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		update volunteerAffiliationList;

		System.assertEquals(Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE, volunteerAffiliationList[1].npe5__Status__c, 'Status is Active');
	}

	//Remove volunteer from public group when affilaition deleted.
	@IsTest
	static void affiliationDelete() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
		insert volunteerContact;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			User newUser = OrientationandTrainingUtil.createActVolunteerUser(volunteerContact.Id);
			insert newUser;
		}

		Group alabamaGroup = new Group();
		alabamaGroup.Name = 'Make-A-Wish Alabama';
		alabamaGroup.DeveloperName = 'ABC';
		insert alabamaGroup;

		System.assertEquals('Make-A-Wish Alabama', alabamaGroup.Name, 'Chapter Name doesnot match');

		insert OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
		npe5__Affiliation__c volunteerAffiliation = [
				SELECT Id, npe5__Status__c
				FROM npe5__Affiliation__c
				LIMIT 1
		];
		volunteerAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
		delete volunteerAffiliation;
	}

	@IsTest
	static void createTaskforVolunteerManager() {
		Account volunteerAcc = OrientationandTrainingUtil.createVolunteerAccountwithVolunteerManager();
		insert volunteerAcc;

		Contact volunteerCon = OrientationandTrainingUtil.createVolunteerContact(volunteerAcc.Id);
		insert volunteerCon;

		Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c(Chapter_Name__c = volunteerAcc.Id,
				Volunteer_Name__c = volunteerCon.id, Volunteer_Contact__c = volunteerCon.Id, Inactive__c = false);
		insert newVolOpp;

		npe5__Affiliation__c affiliationRec = OrientationandTrainingUtil.CreateAffiliationwithAccount(volunteerCon.Id, volunteerAcc.Id);

		affiliationRec.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
		insert affiliationRec;

		System.assertEquals(0, [
				SELECT Id, Subject, WhoId
				FROM Task
				WHERE WhoId = :volunteerCon.Id AND Subject = 'Inactive Volunteer - review volunteer opportunities'
		].size());
	}

	@IsTest
	static void addUserToChapterGroup() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		CollaborationGroup collabGroup = OrientationandTrainingUtil.createCollaborationGroup(volunteerAccount.Name);
		insert collabGroup;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
		insert volunteerContact;

		System.runAs (new User(Id = UserInfo.getUserId())) {
			User prospectiveVolunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert prospectiveVolunteerUser;
		}

		List<npe5__Affiliation__c> affiliatedList = [
				SELECT Id, npe5__Status__c,npe5__Organization__c, npe5__Organization__r.Name
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :volunteerContact.Id
		];
		List<npe5__Affiliation__c> updatedAfflList = new List<npe5__Affiliation__c>();

		for (npe5__Affiliation__c newAffiliate : affiliatedList) {
			newAffiliate.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
			updatedAfflList.add(newAffiliate);
		}
		if (updatedAfflList.size() > 0) {
			update updatedAfflList;
		}
		npe5__Affiliation__c newAffiliation = [
				SELECT Id, npe5__Status__c, npe5__Organization__r.Name
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :volunteerContact.Id
				LIMIT 1
		];
		newAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		update newAffiliation;
	}
}