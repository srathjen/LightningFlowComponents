/**
 * @author Steve Doucette, Traction on Demand 
 * @date 10/1/2019
 *
 * Created to cover any code from the VolOpportunity_OnAfter_Update_Helper code that isn't covered by other test classes
 * NOTE: This will have NO assertions
 */

@IsTest
private class VolOpportunity_OnAfter_Update_HelperTest {
	private static final String VOLUNTEER_OPPORTUNITY_STATUS_APPROVED = 'Approved';
	private static final String VOLUNTEER_OPPORTUNITY_STATUS_PENDING = 'Pending';
	private static final String VOLUNTEER_OPPORTUNITY_STATUS_OOC = 'Out of Compliance';

	@IsTest
	static void coverClass() {
		trac_TriggerHandlerBase.blockTrigger = true;
		Account acc = OrientationandTrainingUtil.createchapterAccount();
		acc.Name = 'Primary Account';
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}

		insert OrientationandTrainingUtil.createAffiliation(currUser.ContactId);

		Role__c currRole = OrientationandTrainingUtil.createRole();
		Role__c currNonWishRole = OrientationandTrainingUtil.createNonWishRole();
		insert new List<Role__C>{
				currRole, currNonWishRole
		};

		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.Id);
		Chapter_Role__c currNonWishChapRole = OrientationandTrainingUtil.createChapter(acc.id, currNonWishRole.Id);
		insert new List<Chapter_Role__c>{
				currChapRole, currNonWishChapRole
		};

		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
		insert currVolRole;

		CaseTeamRole caseTeamRole = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = :Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
		];

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Test.startTest();
		Case newParentWish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		newParentWish.Sub_Status__c = 'Abandoned';
		newParentWish.ContactId = currUser.ContactId;
		insert newParentWish;

		Event__c event = new Event__c();
		insert event;

		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEvent(acc.Id);
		insert nonWishEvent;

		// VolOpp creation
		Volunteer_Opportunity__c wishVolunteerOpportunityApproved = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		wishVolunteerOpportunityApproved.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		wishVolunteerOpportunityApproved.Volunteer_Name__c = currUser.ContactId;
		wishVolunteerOpportunityApproved.Reason_Inactive__c = 'Not Approved';
		wishVolunteerOpportunityApproved.Event__c = event.Id;

		Volunteer_Opportunity__c wishVolunteerOpportunityApprovedToOOC = wishVolunteerOpportunityApproved.clone();

		Volunteer_Opportunity__c wishVolunteerOpportunityPending = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		wishVolunteerOpportunityPending.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
		wishVolunteerOpportunityPending.Volunteer_Name__c = null;
		wishVolunteerOpportunityPending.Event__c = event.Id;

		Volunteer_Opportunity__c wishVolunteerOpportunityPendingToApproved = wishVolunteerOpportunityPending.clone();

		Volunteer_Opportunity__c wishVolunteerOpportunityPendingToOOC = wishVolunteerOpportunityPending.clone();
		wishVolunteerOpportunityPendingToOOC.Volunteer_Name__c = null;

		Volunteer_Opportunity__c wishVolunteerOpportunityOOCToApproved = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		wishVolunteerOpportunityPending.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_OOC;

		// List of VolOpps and insert
		List<Volunteer_Opportunity__c> volOpps = new List<Volunteer_Opportunity__c>{
				wishVolunteerOpportunityApproved, wishVolunteerOpportunityApprovedToOOC,
				wishVolunteerOpportunityPending, wishVolunteerOpportunityPendingToApproved, wishVolunteerOpportunityPendingToOOC,
				wishVolunteerOpportunityOOCToApproved
		};
		insert volOpps;

		Map<Id, Volunteer_Opportunity__c> volOppsBefore = new Map<Id, Volunteer_Opportunity__c>(volOpps.deepClone(true, true, true));

		User nationalStaffUser = [
				SELECT Id
				FROM User
				WHERE Id != :UserInfo.getUserId() AND UserRole.Name = 'National Staff'
				LIMIT 1
		];
		for (Volunteer_Opportunity__c volOpp : volOpps) {
			volOpp.OwnerId = nationalStaffUser.Id;
		}

		// Make changes to VolOpps to trigger if blocks of handler
		wishVolunteerOpportunityApproved.Reason_Inactive__c = 'Test';
		wishVolunteerOpportunityApprovedToOOC.Status__c = wishVolunteerOpportunityPendingToOOC.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_OOC;

		wishVolunteerOpportunityPending.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
		wishVolunteerOpportunityPending.Event__c = event.Id;
		wishVolunteerOpportunityPending.Volunteer_Name__c
				= wishVolunteerOpportunityPendingToApproved.Volunteer_Name__c
				= wishVolunteerOpportunityPendingToOOC.Volunteer_Name__c
						= currUser.ContactId;
		wishVolunteerOpportunityPending.Wish__c
				= wishVolunteerOpportunityPendingToApproved.Wish__c
				= wishVolunteerOpportunityPendingToOOC.Wish__c
						= null;
		wishVolunteerOpportunityPending.Reason_Inactive__c
				= wishVolunteerOpportunityPendingToApproved.Reason_Inactive__c
				= wishVolunteerOpportunityPendingToOOC.Reason_Inactive__c
						= null;
		wishVolunteerOpportunityPending.Non_Wish_Event__c
				= wishVolunteerOpportunityApproved.Non_Wish_Event__c
				= wishVolunteerOpportunityPendingToApproved.Non_Wish_Event__c
						= wishVolunteerOpportunityPendingToOOC.Non_Wish_Event__c
								= nonWishEvent.Id;

		wishVolunteerOpportunityPendingToApproved.Status__c
				= wishVolunteerOpportunityOOCToApproved.Status__c
				= VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		RecursiveTriggerHandler.isFirstTime = true;
		update volOpps;

		newParentWish.Status = 'Closed';
		newParentWish.Closed_Date__c = System.now().date();
		update newParentWish;
		trac_TriggerHandlerBase.blockTrigger = false;

		Set<Id> caseIds = new Set<Id>{
				newParentWish.Id
		};
		Set<Id> volunteerIds = new Set<Id>{
				currUser.ContactId
		};

		System.runAs(currUser) {
			Task t = new Task(
					WhatId = newParentWish.Id,
					Task_Type__c = 'Wish Granter'
			);
			Task t2 = new Task(
					WhatId = newParentWish.Id
			);
			insert new List<Task>{
					t, t2
			};

			VolOpportunity_OnAfter_Update_Helper.updateCase(caseIds, volunteerIds, volOpps);
			VolOpportunity_OnAfter_Update_Helper.CreateNewVolunteerOpportunity(volOpps, volunteerIds);
		}
		Test.stopTest();
	}
}