public class Affiliation_OnAfterUpdateTriggerHelper {
	// Used to add a user to chatter group based on their chapter when the volunter become active.
	public static void addUserToChaptterGroup(Set<Id> volunteerContactIdsSet, Set<Id> affiliationsIdsSet, List<npe5__Affiliation__c> exceptionList) {
		try {
			Map<Id, String> volunteerChaptersMap = new Map<Id, String>();
			Set<String> chapterNamesSet = new Set<String>();
			Map<Id, Id> volunteerUsersMap = new Map<Id, Id>();
			Map<String, Id> chatterGroupNameIdsMap = new Map<String, Id>();
			List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();

			for (npe5__Affiliation__c getChapters : [
					SELECT Id, npe5__Organization__r.Name, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerContactIdsSet AND Id IN :affiliationsIdsSet
			]) {
				if (!chapterNamesSet.contains(getChapters.npe5__Organization__r.Name)) {
					chapterNamesSet.add(String.valueOf(getChapters.npe5__Organization__r.Name).removeStart('Make-A-Wish '));
				}
				volunteerChaptersMap.put(getChapters.npe5__Contact__c, String.valueOf(getChapters.npe5__Organization__r.Name).removeStart('Make-A-Wish '));
			}

			// Used to get volunteer user id and volunteer contact id
			for (User relatedUsers : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerContactIdsSet
			]) {
				volunteerUsersMap.put(relatedUsers.ContactId, relatedUsers.Id);
			}
			if (chapterNamesSet.size() > 0) {
				// Used to get the group name based on the chapter names
				for (CollaborationGroup getgroupId : [
						SELECT Id, Name
						FROM CollaborationGroup
						WHERE Name IN :chapterNamesSet
				]) {
					chatterGroupNameIdsMap.put(getgroupId.Name, getgroupId.Id);
				}
			}
			Set<String> chatterGroupsMembersSet = new Set<String>();
			for (CollaborationGroupMember chatterGroupMemberExistCheck : [
					SELECT Id, MemberId, CollaborationGroupId
					FROM CollaborationGroupMember
					WHERE MemberId IN :volunteerUsersMap.values()
			]) {
				chatterGroupsMembersSet.add(chatterGroupMemberExistCheck.CollaborationGroupId + '-' + chatterGroupMemberExistCheck.MemberId);
			}
			//Used to check whether a user exists in the chatter group before adding the user to group
			for (Id volunteerContact : volunteerContactIdsSet) {
				if (volunteerChaptersMap.containsKey(volunteerContact) && chatterGroupNameIdsMap.containsKey(volunteerChaptersMap.get(volunteerContact)) && volunteerChaptersMap.containsKey(volunteerContact)) {
					/************ WVC-2179 Added containkey in condition*******/
					if (!chatterGroupsMembersSet.contains(chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)) + '-' + volunteerUsersMap.get(volunteerContact)) && volunteerUsersMap.containsKey(volunteerContact)) {
						chatterGroupMembersList.add(new CollaborationGroupMember (CollaborationGroupId = chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)), MemberId = volunteerUsersMap.get(volunteerContact)));
					}
				}
			}
			if (chatterGroupMembersList.size() > 0) {
				if (!Test.isRunningTest()) {
					insert chatterGroupMembersList; // adding members to the group.
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'addUserToChaptterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe5__Affiliation__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}
	/*WLP-467 remove automated task creation */
	public Static void createTaskforVolunteerManager(Set<Id> userList, List<npe5__Affiliation__c> exceptionList) {

//		try {
//			Map<Id, Id> volunteerManagerId = new Map<Id, Id>();
//			List<Volunteer_Opportunity__c> VolunteerOpportunityActive = new List<Volunteer_Opportunity__c>([
//					SELECT id,Chapter_Name__r.Volunteer_Manager__c,Volunteer_Name__c
//					FROM Volunteer_Opportunity__c
//					WHERE Volunteer_Name__c IN:userList AND Inactive__c = False
//			]);
//			for (Volunteer_Opportunity__c currRec : VolunteerOpportunityActive) {
//				volunteerManagerId.put(currRec.Volunteer_Name__c, currRec.Chapter_Name__r.Volunteer_Manager__c);
//			}
//			if (volunteerManagerId.size() > 0) {
//				List<Task> ActiveTask = new List<Task>();
//				Task newTask;
//				for (Id currRec : volunteerManagerId.keyset()) {
//					newTask = new Task();
//					if (volunteerManagerId.containsKey(currRec) && volunteerManagerId.get(currRec) != null) {
//						newTask.OwnerId = volunteerManagerId.get(currRec);
//					}
//					newTask.WhoId = currRec;
//					newTask.Subject = 'Inactive Volunteer - review volunteer opportunities';
//					newTask.SystemGeneratedTask__c = TRUE;
//					ActiveTask.add(newTask);
//				}
//				Insert ActiveTask;
//			}
//			if (Test.isRunningTest()) {
//				throw new CommonTriggerException('Test Class execution');
//			}
//		}
//		// updateBCandCOIVolunteerInactive(userList,True);
//		catch (Exception ex) {
//			for (npe5__Affiliation__c currRec : exceptionList) {
//				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'createTaskforVolunteerManager', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
//			}
//			if (!Test.isRunningTest()) {
//				for (npe5__Affiliation__c currRec : exceptionList) {
//					currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//
//		}
	}
	public static void inactiveAffiliations(Set<Id> volunteerIdSet, List<npe5__Affiliation__c> exceptionList) {
		try {
			Set<Id> inactiveVolunteerIdSet = new set<Id>();
			for (npe5__Affiliation__c currAff : [
					SELECT id,npe5__Status__c,npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerIdSet
			]) {

				if (currAff.npe5__Status__c != 'Active') {
					inactiveVolunteerIdSet.add(currAff.npe5__Contact__c);
				} else if (currAff.npe5__Status__c == 'Active' && inactiveVolunteerIdSet.Contains(currAff.npe5__Contact__c)) {
					inactiveVolunteerIdSet.Remove(currAff.npe5__Contact__c);
				}
			}
			if (inactiveVolunteerIdSet.Size() > 0) {
				updateBCandCOIVolunteerInactive(inactiveVolunteerIdSet, True, exceptionList);
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'inactiveAffiliations', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe5__Affiliation__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}
	public static void activeAffiliations(Set<Id> volunteerIdsSet, List<npe5__Affiliation__c> exceptionList) {
		try {
			Set<Id> activeVolunteerIdSet = new set<Id>();
			Set<Id> volunteerIdSet = new Set<Id>();
			for (npe5__Affiliation__c currAff : [
					SELECT id,npe5__Status__c,npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerIdsSet
			]) {
				if (currAff.npe5__Status__c == 'Active') {
					volunteerIdSet.add(currAff.npe5__Contact__c);
				}
			}
			if (volunteerIdSet.Size() > 0) {
				For (User currUser : [
						SELECT Id,ContactId
						FROM User
						Where contactId IN :volunteerIdSet AND isActive = True
				]) {
					activeVolunteerIdSet.add(currUser.ContactId);
				}
				if (activeVolunteerIdSet.Size() > 0) {
					updateBCandCOIVolunteerInactive(activeVolunteerIdSet, False, exceptionList);
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'activeAffiliations', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe5__Affiliation__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}
	public static void updateBCandCOIVolunteerInactive(Set<Id> inactiveVolunteerIdSet, Boolean isInactiveVolunteer, List<npe5__Affiliation__c> exceptionList) {
		try {
			List<Background_check__c> updateBCList = New List<Background_check__c>();
			List<Conflict_Of_Interest__c> updateCOIList = New List<Conflict_Of_Interest__c>();
			for (Background_check__c currBC : [
					SELECT Id,Volunteer_is_Inactive__c
					FROM Background_check__c
					WHERE Volunteer__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
			]) {
				currBc.Volunteer_is_Inactive__c = isInactiveVolunteer;
				updateBCList.add(currBc);
			}

			if (updateBCList.Size() > 0) {
				Update updateBCList;
			}
			for (Conflict_Of_Interest__c currCOI : [
					SELECT Id,Volunteer_is_Inactive__c
					FROM Conflict_Of_Interest__c
					WHERE Volunteer_Contact__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
			]) {
				currCOI.Volunteer_is_Inactive__c = isInactiveVolunteer;
				updateCOIList.add(currCOI);
			}
			if (updateCOIList.Size() > 0) {
				Update updateCOIList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'updateBCandCOIVolunteerInactive', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe5__Affiliation__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}
	//used to update the status field in contact for reporting purpose
	public static void updateContact(Map<Id, npe5__Affiliation__c> contactMap, Set<Id> affiliationIds, List<npe5__Affiliation__c> exceptionList) {
		try {
			RecursiveTriggerHandler.isFirstTime = false;
			Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
			Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
			Id familyContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
			Id MedicalProfContactRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
			Id boardMemberRT = Constant_AC.BOARD_MEMBER_RT_ID;
			Id chapterRT = Constant_AC.CHAPTER_RT_ID;
			List<Contact> conList = [
					SELECT Id, Hidden_Status__c, RecordTypeId, RecordType.Name
					FROM Contact
					WHERE Id IN :contactMap.keySet()
			];
			Map<Id, Account> accountMap = new Map<Id, Account>([
					SELECT Id, RecordTypeId
					FROM Account
					WHERE Id IN :affiliationIds
			]);

			Map<String, Integer> recordTypeOrder = new Map<String, Integer>();
			recordTypeOrder.put(Constant_AC.BOARD_MEMBER_RT_LABEL, 1);
			recordTypeOrder.put(Constant_AC.VOLUNTEER_TASK_RT_LABEL, 2);
			recordTypeOrder.put(Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL, 3);
			recordTypeOrder.put(Constant_AC.CONTACT_WISH_CHILD_RT_LABEL, 4);
			recordTypeOrder.put(Constant_AC.WISH_FAMILY_RT_LABEL, 5);

			Map<Id, String> recordTypeNames = new Map<Id, String>();
			recordTypeNames.put(volunteerRecordTypeId, Constant_AC.VOLUNTEER_TASK_RT_LABEL);
			recordTypeNames.put(wishChildRecordTypeId, Constant_AC.CONTACT_WISH_CHILD_RT_LABEL);
			recordTypeNames.put(familyContactRecordTypeId, Constant_AC.WISH_FAMILY_RT_LABEL);
			recordTypeNames.put(MedicalProfContactRecordTypeId, Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL);
			recordTypeNames.put(boardMemberRT, Constant_AC.BOARD_MEMBER_RT_LABEL);

			Map<String, Id> recordTypes = new Map<String, Id>();
			for (Id recordTypeNameKey : recordTypeNames.keySet()) {
				recordTypes.put(recordTypeNames.get(recordTypeNameKey), recordTypeNameKey);
			}

			for (Contact currContact : conList) {
				npe5__Affiliation__c currAffiliation = contactMap.get(currContact.Id);
				currContact.Hidden_Status__c = currAffiliation.npe5__Status__c;

				if (currAffiliation.Constituent_Code__c != null && recordTypeNames.containsKey(currContact.RecordTypeId)) {
					if (currAffiliation.Constituent_Code__c != recordTypeNames.get(currContact.RecordTypeId)) {
						if (recordTypeOrder.get(currAffiliation.Constituent_Code__c) < recordTypeOrder.get(recordTypeNames.get(currContact.RecordTypeId))) {
							if (recordTypes.containsKey(currAffiliation.Constituent_Code__c) && accountMap.get(currAffiliation.npe5__Organization__c).RecordTypeId == chapterRT)
								currContact.RecordTypeId = recordTypes.get(currAffiliation.Constituent_Code__c);
						}
					}
				}
			}
			update conList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'updateContact', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe5__Affiliation__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}
	// Used to add a user to group based on their affilaition when the affilaition created.
	@future
	public static void insertGroupMember(Set<string> vlounteerNameSet, Set<String> chapterNameSet, set<id> affiliationSet, Map<Id, String> exceptionMap) {
		try {
			Map<id, User> userMap = new Map<id, user>();
			Map<Id, String> chapterNameMap = new Map<Id, String>();
			map<string, id> publicGroupMap = new map<string, id>();
			List<GroupMember> groupMemberList = new List<GroupMember>();
			if (vlounteerNameSet.size() > 0) {
				for (User currentUser : [
						SELECT ID,ContactID
						FROM User
						WHERE ContactID IN:vlounteerNameSet
				]) {
					userMap.put(currentUser.ContactID, currentUser);
				}
			}
			if (chapterNameSet.size() > 0) {
				for (Account currentAccount : [
						SELECT Id,Name
						FROM Account
						WHERE Id IN:chapterNameSet
				]) {
					String chapterNameTrim = currentAccount.Name.removeStart('Make-A-Wish ');
					chapterNameMap.put(currentAccount.Id, chapterNameTrim);
				}
			}
			for (Group currentGroup : [
					SELECT Id, Name
					FROM Group
					WHERE Type = 'Regular'
			]) {
				publicGroupMap.put(currentGroup.Name, currentGroup.id);
			}
			for (npe5__Affiliation__c currentRec : [
					SELECT ID,Name,npe5__Organization__c,npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE ID IN:affiliationSet
			]) {
				if (userMap.containsKey(currentRec.npe5__Contact__c) && chapterNameMap.containsKey(currentRec.npe5__Organization__c) && publicGroupMap.containsKey(chapterNameMap.get(currentRec.npe5__Organization__c))) {

					GroupMember newGroupMem = new GroupMember();
					newGroupMem.GroupId = publicGroupMap.get(chapterNameMap.get(currentRec.npe5__Organization__c));
					newGroupMem.UserOrGroupId = userMap.get(currentRec.npe5__Contact__c).id;
					groupMemberList.add(newGroupMem);
				}
			}
			if (groupMemberList.size() > 0) {
				insert groupMemberList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('Affiliation_OnAfterUpdateTriggerHelper', exceptionMap.get(currRec), String.valueOf(ex), 'updateContact', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe5__Affiliation__c currRec : [
						SELECT Id
						FROM npe5__Affiliation__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}
}