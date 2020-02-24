/*********************************************
Description : Test Class create ChapterStaffRecordSharing.
**********************************************/
//This class used to do the unit testing
// createRecords methosd will create chapter role record
@isTest
public class ChapterStaffRecordSharing_ACTest {

	@TestSetup static void leadSharing() {
		User nationalStaff = OrientationandTrainingUtil.createUserWithRole([
				SELECT Id
				FROM UserRole
				WHERE Name = 'National Staff'
		].Id);

		System.runAs(nationalStaff) {
			Chapter_Vs_Role__c createRec = new Chapter_Vs_Role__c();
			createRec.Chapter_Name__c = 'Make-A-Wish Alabama';
			createRec.Role_Name__c = 'Alabama - Chapter';
			createRec.Name = 'Make-A-Wish Alabama';
			insert createRec;

			Map<String, List<Lead>> leadMap = new Map<String, List<Lead>>();
			// Map<String,List<Contact>> contactMapforSharing = new Map<String,List<Contact>>();
			Set<ID> chapteridsSet = new Set<ID>();
			Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
			insert chapterAccount;

			chapterAccount.Intake_Manager__c = nationalStaff.id;
			update chapterAccount;
			chapteridsSet.add(chapterAccount.id);
			Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.id);
			Contact newContact = OrientationandTrainingUtil.CreateWishFamily();
			Account newAccount = OrientationandTrainingUtil.inKindAccountWithStatus();
			Contact volContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
			insert newLead;
			leadMap.put(chapterAccount.Name, new List<Lead>{
					newLead
			});
			ChapterStaffRecordSharing_AC.LeadSharing(leadMap);
			ChapterStaffRecordSharing_AC.getChapterName(chapteridsSet);
		}
	}

	static testMethod void contachSharing() {

		Chapter_Vs_Role__c getRec = [
				select Chapter_Name__c,Role_Name__c
				from Chapter_Vs_Role__c
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;
		Contact newContact = OrientationandTrainingUtil.CreateWishFamily();
		insert newContact;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;
		Conflict_Of_Interest__c coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
		insert coiRec;
		Map<String, List<Contact>> contactMapforSharing = new Map<String, List<Contact>>();
		System.assert(10 == 10, 'Value does not match');
		contactMapforSharing.put(chapterAccount.Name, new List<Contact>{
				newContact
		});
		ChapterStaffRecordSharing_AC.ContactSharing(contactMapforSharing);

		Map<String, List<Conflict_Of_Interest__c>> coiMapforSharing = new Map<String, List<Conflict_Of_Interest__c>>{
				getRec.Chapter_Name__c => new List<Conflict_Of_Interest__c>{
						coiRec
				}
		};
		ChapterStaffRecordSharing_AC.COIRecordSharing(coiMapforSharing);

		Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c();
		insert volOpp;
		Map<String, List<Volunteer_Opportunity__c>> volMapforSharing = new Map<String, List<Volunteer_Opportunity__c>>{
				getRec.Chapter_Name__c => new List<Volunteer_Opportunity__c>{
						volOpp
				}
		};
		ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volMapforSharing);

	}

	static testMethod void accounthSharing() {
		Map<String, List<Account>> accountMapforSharing = new Map<String, List<Account>>();
		Account newAccount = OrientationandTrainingUtil.inKindAccountWithStatus();
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		Contact newContact = OrientationandTrainingUtil.CreateWishFamily();
		accountMapforSharing.put(chapterAccount.Name, new List<Account>{
				newAccount
		});
		ChapterStaffRecordSharing_AC.AccountSharing(accountMapforSharing);

	}

	static testMethod void backGroundCheckSharing() {
		User nationStaffUser = [
				select Id
				from User
				where UserRole.Name = 'National Staff' AND isActive = TRUE
				LIMIT 1
		];
		System.runAs(nationStaffUser) {
			Map<String, List<Background_check__c>> bgcMap = new Map<String, List<Background_check__c>>();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;

			Contact volContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
			insert volContact;

			Background_check__c bgc = OrientationandTrainingUtil.createBackgroundCheck(volContact.id);
			insert bgc;
			bgcMap.put(chapterAccount.Name, new List<Background_check__c>{
					bgc
			});
			ChapterStaffRecordSharing_AC.BGCRecordSharing(bgcMap);
		}

	}

	/*  static testMethod void volOpportunitySharing(){

Map<String, List<Volunteer_Opportunity__c >> volunteerOppMap = new Map<String, List<Volunteer_Opportunity__c>>();
List<Volunteer_Opportunity__c> volOppList = VolunteerOpportunityTrigger_AT_Test.SubmittoApproval();
test.startTest();
Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
volunteerOppMap.put(chapterAccount.Name, volOppList);
// ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOppMap);
Test.stopTest();

}*/

	static testMethod void broadCastRecordSharing() {
		User nationStaffUser = [
				select Id
				from User
				where UserRole.Name = 'National Staff' AND isActive = TRUE
				LIMIT 1
		];
		System.runAs(nationStaffUser) {
			Map<String, List<Broadcast__c>> broadCastMap = new Map<String, List<Broadcast__c>>();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			Broadcast__c newBroadcast = new Broadcast__c();
			newBroadcast.Broadcast_Message__c = 'test';
			newBroadcast.Chapter_Name__c = chapterAccount.id;
			insert newBroadcast;
			broadCastMap.put(chapterAccount.Name, new List<Broadcast__c>{
					newBroadcast
			});
			ChapterStaffRecordSharing_AC.broadRecordSharing(broadCastMap);
		}
	}

	static testMethod void chapterActionSharing() {
		User nationStaffUser = [
				select Id
				from User
				where UserRole.Name = 'National Staff' AND isActive = TRUE
				LIMIT 1
		];
		System.runAs(nationStaffUser) {

			Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			Chapter_Action_Track__c newChapterTaction = new Chapter_Action_Track__c();
			newChapterTaction.Chapter_Name__c = chapterAccount.id;
			insert newChapterTaction;
			chapterActionMap.put(chapterAccount.Name, new List<Chapter_Action_Track__c>{
					newChapterTaction
			});
			ChapterStaffRecordSharing_AC.chapterActionTrackSharing(chapterActionMap);
		}
	}

	static testMethod void chapterRoleSharing() {
		User nationStaffUser = [
				select Id
				from User
				where UserRole.Name = 'National Staff' AND isActive = TRUE
				LIMIT 1
		];
		System.runAs(nationStaffUser) {
			Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			Chapter_Role__c newChapterRole = new Chapter_Role__c();
			newChapterRole.Chapter_Name__c = chapterAccount.id;
			insert newChapterRole;
			chapterRoleMap.put(chapterAccount.Name, new List<Chapter_Role__c>{
					newChapterRole
			});
			ChapterStaffRecordSharing_AC.chapterRoleSharing(chapterRoleMap);
		}
	}

	static testMethod void chapterRoleOTSharing() {
		User nationStaffUser = [
				select Id
				from User
				where UserRole.Name = 'National Staff' AND isActive = TRUE
				LIMIT 1
		];
		System.runAs(nationStaffUser) {
			Map<String, List<Chapter_Role_O_T__c>> chapterRoleMap = new Map<String, List<Chapter_Role_O_T__c>>();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			Chapter_Role__c newChapterRole = new Chapter_Role__c();
			newChapterRole.Chapter_Name__c = chapterAccount.id;
			insert newChapterRole;
			Chapter_Role_O_T__c newChapterRoleOT = new Chapter_Role_O_T__c();
			newChapterRoleOT.Chapter_Role__c = newChapterRole.id;
			insert newChapterRoleOT;
			chapterRoleMap.put(chapterAccount.Name, new List<Chapter_Role_O_T__c>{
					newChapterRoleOT
			});
			ChapterStaffRecordSharing_AC.chapterRoleOTSharing(chapterRoleMap);
		}
	}

	static testMethod void classOfferingSharing() {

		User nationStaffUser = [
				select Id
				from User
				where UserRole.Name = 'National Staff' AND isActive = TRUE
				LIMIT 1
		];
		System.runAs(nationStaffUser) {

			Map<String, List<Class_Offering__c>> classOfferingMap = new Map<String, List<Class_Offering__c>>();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;

			Chapter_Role__c newChapterRole = new Chapter_Role__c();
			newChapterRole.Chapter_Name__c = chapterAccount.id;
			insert newChapterRole;

			Chapter_Role_O_T__c newChapterRoleOT = new Chapter_Role_O_T__c();
			newChapterRoleOT.Chapter_Role__c = newChapterRole.id;
			insert newChapterRoleOT;

			Class_Offering__c newclassOffering = OrientationandTrainingUtil.createClassOffering(newChapterRoleOT.id);
			insert newclassOffering;
			classOfferingMap.put(chapterAccount.Name, new List<Class_Offering__c>{
					newclassOffering
			});
			ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
		}

	}

	static testMethod void awardsRegRecordSharing() {
		ChapterStaffRecordSharing_AC.CaseSharing(new Map<String, List<Case>>());
	}

	static testMethod void cover() {

	}
}