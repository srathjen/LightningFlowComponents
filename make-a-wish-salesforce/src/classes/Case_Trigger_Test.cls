/**
 * @author Steve Doucette, Traction on Demand 
 * @date 10/24/2019
 */

@IsTest
private class Case_Trigger_Test {
	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		Account chapter = OrientationandTrainingUtil.createchapterAccount();
		insert chapter;

		Lead child = OrientationandTrainingUtil.createTestLeadRec(chapter.Id);
		child.I_am_Recognized_To_Practice_As_a__c = 'Child';
		child.Any_medical_reason_for_moving_quickly__c = 'No';
		child.Part_A_Received__c = Date.today();
		child.Sub_Status__c = 'Pending Paper DV';
		insert child;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(chapter.Id);
		insert con;

		Case wish = new Case(RecordTypeId = Constant_AC.WISH_RT_ID, ChapterName__c = chapter.Id, ContactId = con.Id, Lead__c = child.Id);
		insert wish;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void testInsert() {
		Case wish = getWish();

		CaseService.updateWishRecordIdentifier(new List<Case>{wish});

		CaseService.caseTeamInTakeManager(new List<Case>{wish});

		insert new Task(Subject = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary', WhoId = wish.ContactId);

		CaseService.reParentDvTask(new List<Case>{wish});
	}

	@IsTest
	static void testUpdate() {
		Case wish = getWish();

		Set<String> leadSet = new Set<String>{
			wish.Lead__c
		};
		List<Case> caseList = new List<Case>{
			wish
		};

		CaseService.updateLeadStatus(leadSet, leadSet, caseList);

		Lead child = [
			SELECT Id, DOB__c, Any_medical_reason_for_moving_quickly__c, Part_A_Received__c, I_am_Recognized_To_Practice_As_a__c
			FROM Lead
		];

		child.DOB__c = null;
		child.Any_medical_reason_for_moving_quickly__c = null;
		child.Part_A_Received__c = null;
		child.I_am_Recognized_To_Practice_As_a__c = null;
		child.Sub_Status__c = null;
		Bypass_Triggers__c currUser = new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
		insert currUser;
		update child;

		// Cover error messages
		CaseService.updateLeadStatus(leadSet, leadSet, caseList);

		// Cover where where lead is in second set but not first
		CaseService.updateLeadStatus(new Set<String>(), leadSet, caseList);
	}

	private static Case getWish() {
		return [
			SELECT Id, ChapterName__c, RecordTypeId, Lead__c, ContactId, IsClosed
			FROM Case
		];
	}
}