/**
 * Test
 */
@IsTest
public class Batch_UpdateVolunteerRoleStatus_Test {

	@IsTest
	static void updateVolunteerStatus() {
		Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAc;

		Contact volunteerContact2 = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
		insert volunteerContact2;

		npe5__Affiliation__c affiliation2 = OrientationandTrainingUtil.CreateAffiliation(volunteerContact2.Id);
		affiliation2.npe5__Status__c = 'Active';
		insert affiliation2;

		User currUser2;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser2 = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact2.id);
			insert currUser2;
		}

		Role__c wishGranterRole = OrientationandTrainingUtil.createRole();
		Role__c nonWishRole = OrientationandTrainingUtil.createNonWishRole();
		insert new List<Role__c>{
				wishGranterRole, nonWishRole
		};

		Chapter_Role__c wishGranterChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, wishGranterRole.Id);
		Chapter_Role__c nonWishChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, nonWishRole.Id);
		insert new List<Chapter_Role__c>{
				wishGranterChapterRole, nonWishChapterRole
		};

		Orientation_Training__c OrientationId = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert OrientationId;

		Chapter_Role_O_T__c chapRoleandId = OrientationandTrainingUtil.createChapterOandT(wishGranterChapterRole.Id, OrientationId.Id);
		Chapter_Role_O_T__c chapRoleandId2 = OrientationandTrainingUtil.createChapterOandT(nonWishChapterRole.Id, OrientationId.Id);
		insert new List<Chapter_Role_O_T__c>{
				chapRoleandId, chapRoleandId2
		};

		Class_Offering__c newclass = OrientationandTrainingUtil.createClassOffering(chapRoleandId.Id);
		Class_Offering__c newclass2 = OrientationandTrainingUtil.createClassOffering(chapRoleandId2.Id);
		insert new List<Class_Offering__c>{
				newclass, newclass2
		};

		Volunteer_Roles__c wishGranterVolRole = OrientationandTrainingUtil.createVolRole(currUser2.ContactId, wishGranterChapterRole.Id);
		Volunteer_Roles__c nonWishVolRole = OrientationandTrainingUtil.createVolRole(currUser2.ContactId, nonWishChapterRole.Id);
		insert new List<Volunteer_Roles__c>{
				wishGranterVolRole, nonWishVolRole
		};

		Volunteer_Orientation_Training__c createVolTraining = OrientationandTrainingUtil.createVolTraining(OrientationId.id, newclass2.Id, volunteerContact2.Id, 'Completed');
		insert createVolTraining;

		Test.startTest();
		wishGranterVolRole.Status__C = 'Out of Compliance';
		nonWishVolRole.Status__C = 'Out of Compliance';
		update nonWishVolRole;
		update wishGranterVolRole;
		Database.executeBatch(new Batch_UpdateVolunteerRoleStatus_AC());
		Test.stopTest();
	}

	@IsTest
	static void updateVolunteerSingleActiveStatus() {
		Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAc;

		Contact volunteerContact1 = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
		Contact volunteerContact2 = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
		insert new List<Contact>{
				volunteerContact1, volunteerContact2
		};

		npe5__Affiliation__c affiliation1 = OrientationandTrainingUtil.CreateAffiliation(volunteerContact1.Id);
		npe5__Affiliation__c affiliation2 = OrientationandTrainingUtil.CreateAffiliation(volunteerContact2.Id);
		affiliation1.npe5__Status__c = affiliation2.npe5__Status__c = 'Active';
		insert new List<npe5__Affiliation__c>{
				affiliation1, affiliation2
		};

		User currUser1;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser1 = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact1.id);
			insert currUser1;
		}

		Role__c wishGranterRole = OrientationandTrainingUtil.createRole();
		Role__c nonWishRole = OrientationandTrainingUtil.createNonWishRole();
		Role__c boardMemberRole = OrientationandTrainingUtil.createRole();
		boardMemberRole.Name = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert new List<Role__c>{
				wishGranterRole, nonWishRole, boardMemberRole
		};

		Chapter_Role__c wishGranterChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, wishGranterRole.Id);
		Chapter_Role__c nonWishChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, nonWishRole.Id);
		Chapter_Role__c boardMemberChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, boardMemberRole.Id);
		insert new List<Chapter_Role__c>{
				wishGranterChapterRole, nonWishChapterRole, boardMemberChapterRole
		};

		Volunteer_Roles__c wishGranterVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact1.Id, wishGranterChapterRole.Id);
		Volunteer_Roles__c nonWishVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact2.Id, nonWishChapterRole.Id);
		Volunteer_Roles__c boardMemberVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact1.Id, boardMemberChapterRole.Id);
		insert new List<Volunteer_Roles__c>{
				wishGranterVolRole, nonWishVolRole, boardMemberVolRole
		};

		Test.startTest();
		wishGranterVolRole.Status__C = 'Out of Compliance';
		nonWishVolRole.Status__C = 'Out of Compliance';
		boardMemberVolRole.Status__C = 'Out of Compliance';
		update boardMemberVolRole;
		update nonWishVolRole;
		update wishGranterVolRole;
		Database.executeBatch(new Batch_UpdateVolunteerRoleStatus_AC());
		Test.stopTest();
		System.assertEquals(boardMemberRole.Name, Constant_AC.BOARD_MEMBER_RT_LABEL, 'Role is not board member');
	}

	@IsTest
	static void updateVolunteerRolePedingStatus() {
		Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAc;

		Contact volunteerContact1 = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
		Contact volunteerContact2 = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
		insert new List<Contact>{
				volunteerContact1, volunteerContact2
		};

		npe5__Affiliation__c affiliation1 = OrientationandTrainingUtil.CreateAffiliation(volunteerContact1.Id);
		npe5__Affiliation__c affiliation2 = OrientationandTrainingUtil.CreateAffiliation(volunteerContact2.Id);
		affiliation1.npe5__Status__c = affiliation2.npe5__Status__c = 'Active';
		insert new List<npe5__Affiliation__c>{
				affiliation1, affiliation2
		};

		User currUser2;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser2 = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact2.id);
			insert currUser2;
		}

		Role__c wishGranterRole = OrientationandTrainingUtil.createRole();
		Role__c nonWishRole = OrientationandTrainingUtil.createNonWishRole();
		Role__c boardMemberRole = OrientationandTrainingUtil.createRole();
		boardMemberRole.Name = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert new List<Role__c>{
				wishGranterRole, nonWishRole, boardMemberRole
		};

		Chapter_Role__c wishGranterChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, wishGranterRole.Id);
		Chapter_Role__c nonWishChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, nonWishRole.Id);
		Chapter_Role__c boardMemberChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, boardMemberRole.Id);
		insert new List<Chapter_Role__c>{
				wishGranterChapterRole, nonWishChapterRole, boardMemberChapterRole
		};

		Volunteer_Roles__c wishGranterVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact1.Id, wishGranterChapterRole.Id);
		Volunteer_Roles__c nonWishVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact2.Id, nonWishChapterRole.Id);
		Volunteer_Roles__c boardMemberVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact1.Id, boardMemberChapterRole.Id);
		insert new List<Volunteer_Roles__c>{
				wishGranterVolRole, nonWishVolRole, boardMemberVolRole
		};

		Test.startTest();
		wishGranterVolRole.Status__c = 'Out of Compliance';
		nonWishVolRole.Status__c = 'Out of Compliance';
		boardMemberVolRole.Status__c = 'Out of Compliance';
		update boardMemberVolRole;
		update nonWishVolRole;
		update wishGranterVolRole;
		Database.executeBatch(new Batch_UpdateVolunteerRoleStatus_AC());
		Test.stopTest();
		System.assertEquals(boardMemberRole.Name, Constant_AC.BOARD_MEMBER_RT_LABEL, 'Role is not board member');
	}
}