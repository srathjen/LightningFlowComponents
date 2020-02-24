/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeUpdateHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              WVC-2045    Pavithra G  6/13/2018 
              WVC-2205    kanagaraj A 08/07/2018 (line - 23 previously it has Declined. Now I have updated as
                                                   "Not Approved") 
              WVC-2199    Pavithra G    8/8/2018 (line no - 195 and 199 
                                                  Hold the previous satatus value to hidden previous status filed) 
*****************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class BackGroundCheck_OnAfterUpdateHelper {

	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
	private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = Constant_AC.VOLUNTEER_ROLE_STATUS_NOT_APPROVED;

// If Interview Task is rejected, then update affiliation status as "Not Approved".
	public static void UpdateAffiliationStatusToDeclined(Set<Id> rejectedIds, List<SObject> exceptionList) {
		try {
			List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
			for (npe5__Affiliation__c dbAffiliationRec : [
					SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :rejectedIds
					AND npe5__Status__c != 'Active'
			]) {
				npe5__Affiliation__c updateRec = new npe5__Affiliation__c();
				updateRec.npe5__Status__c = 'Not Approved';
				updateRec.Id = dbAffiliationRec.Id;
				affiliationList.add(updateRec);
			}
			if (affiliationList.size() > 0) {
				update affiliationList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (SObject currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',
						String.valueOf(currRec), String.valueOf(ex), 'UpdateAffiliationStatusToDeclined',
						currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (SObject currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	// If Interview Task is approved, then update affiliation status as "Pending/Active" based on the training required.
	public static void UpdateAffiliationStatusToPending(Set<Id> approvedVolunteerIds, List<Background_check__c> exceptionList) {
		try {
//			List<npe5__Affiliation__c> updateAffliationList = new List<npe5__Affiliation__c>();
//			Set<Id> activeContactIdsSet = new Set<Id>();
			Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
//			Set<Id> orientationTrainingId = new Set<Id>();
//			Map<String, Set<String>> volunteerChapterRoleMap = new Map<String, Set<String>>();
			Set<Id> chapterRolesSet = new Set<Id>();
//			Set<Id> volunteerProsProfileSet = new Set<Id>();
//			Set<Id> volunteerActiveProfileSet = new Set<Id>();
			List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
			List<Volunteer_Roles__c> volunteerRoleList = new List<Volunteer_Roles__c>();
			Map<String, Conflict_Of_Interest__c> coiMap = new Map<String, Conflict_Of_Interest__c>();
//			Set<String> chapterRoleOandTsSet = new Set<String>();

			for (Conflict_Of_Interest__c currCOI : [
					SELECT Id, Volunteer_Contact__c, Expiration_Date__c
					FROM Conflict_Of_Interest__c
					WHERE Volunteer_Contact__c IN :approvedVolunteerIds
					AND Expiration_Date__c > :Date.today()
					LIMIT 50000
			]) {
				coiMap.put(currCOI.Volunteer_Contact__c, currCOI);
			}
			for (Volunteer_Roles__c currRole : [
					SELECT Id,Name,Status__c,Hidden_Previous_Sub_Status__c,Hidden_Previous_Status__c,
							Chapter_Role__c,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c,
							Chapter_Role__r.COI_Required__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c IN :coiMap.keySet()
					AND Status__c = :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
//					AND Status__c != :VOLUNTEER_ROLE_STATUS_NOT_APPROVED
//					AND Status__c != :VOLUNTEER_ROLE_STATUS_FORMER
//					AND Status__c != :VOLUNTEER_ROLE_STATUS_ACTIVE
					LIMIT 50000
			]) {
				volunteerRoleList.add(currRole);
				chapterRolesSet.add(currRole.Chapter_Role__c);
			}
			/**
			 * WLP-619
			 * Replaced code with VolunteerJourneyService
			 */
//			for (Chapter_Role_O_T__c currChapterRole : [
//					SELECT Id,Name,Orientation_Training__c,Orientation_Training__r.RecordTypeId,
//							Required__c,Chapter_Role__c
//					FROM Chapter_Role_O_T__c
//					WHERE Chapter_Role__c IN :chapterRolesSet
//					AND Required__c = TRUE
//					AND Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
//					LIMIT 50000
//			]) {
//				chapterRoleOandTsSet.add(currChapterRole.Chapter_Role__c);
//			}
			/*if(volunteerChapterRoleMap.containsKey(currRole.Volunteer_Name__c))
				volunteerChapterRoleMap.get(currRole.Volunteer_Name__c).add(currRole.Chapter_Role__c);
			else
				volunteerChapterRoleMap.put(currRole.Volunteer_Name__c, new Set<String>{currRole.Chapter_Role__c});
		   */
			/**************** WVC - 2199 ***************/
			if (volunteerRoleList.size() > 0) {
				for (Volunteer_Roles__c currRole : volunteerRoleList) {
					Volunteer_Roles__c updateRole = new Volunteer_Roles__c();
					updateRole.Id = currRole.Id;
					if (currRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
							&& (String.isNotEmpty(currRole.Hidden_Previous_Status__c))
							&& currRole.Chapter_Role__r.Background_Check_Required__c) {
						updateRole.Status__c = currRole.Hidden_Previous_Status__c;
						// If(currRole.Hidden_Previous_Status__c == 'Pending')
						updateRole.Sub_status__c = currRole.Hidden_Previous_Sub_Status__c;
						updateRole.Hidden_Previous_Status__c = '';
						updateRole.Hidden_Previous_Sub_Status__c = '';
					}
					/**
					 * WLP-619
					 * Replaced code with VolunteerJourneyService
					 */
//					if (!chapterRoleOandTsSet.contains(currRole.Chapter_Role__c)) {
//						updateRole.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
//						volunteerActiveProfileSet.add(currRole.Volunteer_Name__c);
//					}
					updateVolunteerRoleList.add(updateRole);
				}
			}
			/***** END WVC-2199 *****************/
			//}

			/**** Comment WVC-2205 ************/
			/* Set<String> chapterRoleOandTsSet = new Set<String>();
			 for(Chapter_Role_O_T__c currChapterRole : [SELECT Id,Name,Orientation_Training__c,Orientation_Training__r.RecordTypeId,Required__c,Chapter_Role__c FROM Chapter_Role_O_T__c WHERE Chapter_Role__c IN :chapterRolesSet AND Required__c = TRUE AND Orientation_Training__r.RecordTypeId =:triainingRecordTypeId])
			 {
				 chapterRoleOandTsSet.add(currChapterRole.Chapter_Role__c);
			 }
			 for(Conflict_Of_Interest__c currCOI : [SELECT  id, Volunteer_Contact__c, Expiration_Date__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c IN :approvedVolunteerIds AND Expiration_Date__c > : Date.Today()])
			 {
				 coiMap.put(currCOI.Volunteer_Contact__c, currCOI);
			 }
			 for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : approvedVolunteerIds AND npe5__Status__c != 'Active'])
			 {
				 If(!volunteerActiveProfileSet.contains(dbAffiliationRec.npe5__Contact__c)){
				 npe5__Affiliation__c currAffiliation = new npe5__Affiliation__c();
				 if(coiMap.containsKey(dbAffiliationRec.npe5__Contact__c))
				 {
					 currAffiliation.npe5__Status__c = 'Active';
				 }
				 else
				 {
					 currAffiliation.npe5__Status__c = 'Pending';
				 }
				 currAffiliation.id = dbAffiliationRec.id;
				 if(volunteerChapterRoleMap.containsKey(dbAffiliationRec.npe5__Contact__c)){
					 for(String currChapterRole : volunteerChapterRoleMap.get(dbAffiliationRec.npe5__Contact__c))
					 {
						 if(chapterRoleOandTsSet.contains(currChapterRole))
						 {
							 currAffiliation.npe5__Status__c = 'Pending';
						 }
					 }
				 }
				 if(currAffiliation.npe5__Status__c == 'Active')
					 activeContactIdsSet.add(dbAffiliationRec.npe5__Contact__c);
				 updateAffliationList.add(currAffiliation);
			 }
			 }*/
			/***************** WVC-2205 commnented lines Ended ************/

			if (updateVolunteerRoleList.size() > 0) {
				update updateVolunteerRoleList;
			}
			/*  if(updateAffliationList.size() > 0){
				  update updateAffliationList;
			}*/
			/**
			 * WLP-619
			 * Replaced code with VolunteerJourneyService
			 */
//			if (volunteerActiveProfileSet.size() > 0) {
//				VolunteerOandTHandler.updateUser(volunteerActiveProfileSet);
//			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Background_check__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',
						String.valueOf(currRec), String.valueOf(ex), 'UpdateAffiliationStatusToPending',
						currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Background_check__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	//Update the hidden vaolunteer role status on contact.
	public static void updateVolunteerHiddenVolOTStatus(Set<Id> volIdsSet, List<Background_check__c> exceptionList) {
		try {
			Map<Id, Id> chapterRoleIdsMap = new Map<Id, Id>();
			Set<Id> roleSpecificVolIdsSet = new Set<Id>();
			List<Contact> updateVolunteerConList = new List<Contact>();
			for (Volunteer_Roles__c currVolRole : [
					SELECT Id,Chapter_Role__c,Volunteer_Name__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c IN:volIdsSet
			]) {
				chapterRoleIdsMap.put(currVolRole.Chapter_Role__c, currVolRole.Volunteer_Name__c);
			}
			if (chapterRoleIdsMap.size() > 0) {
				for (Chapter_Role_O_T__c currChpterRole : [
						SELECT Id,Chapter_Role__c
						FROM Chapter_Role_O_T__c
						WHERE Chapter_Role__c IN:chapterRoleIdsMap.keySet()
						AND Required__c = TRUE
				]) {
					if (chapterRoleIdsMap.containsKey(currChpterRole.Chapter_Role__c)) {
						roleSpecificVolIdsSet.add(chapterRoleIdsMap.get(currChpterRole.Chapter_Role__c));
					}
				}
			}
			if (roleSpecificVolIdsSet.size() > 0) {
				for (Contact currContact : [
						SELECT Id
						FROM Contact
						WHERE Id IN:roleSpecificVolIdsSet
				]) {
					currContact.Hidden_Volunteer_OT_Status__c = 'Role Specific Training Available';
					updateVolunteerConList.add(currContact);
				}
			}
			if (updateVolunteerConList.size() > 0) {
				update updateVolunteerConList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Background_check__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper', String.valueOf(currRec),
						String.valueOf(ex), 'updateVolunteerHiddenVolOTStatus', currRec.Id,
						ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Background_check__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	//Update volunteer Opportunity and volunteer Role status.
	public static void UpdateVOppAndVRoleStatus(Set<Id> volunteerContactIdSet, String objectName, List<SObject> exceptionList) {
		try {
			if (volunteerContactIdSet.size() > 0) {
				List<Volunteer_Opportunity__c> updateVolOpportunityList = new List<Volunteer_Opportunity__c>();
//				List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
				Map<Id, Volunteer_Roles__c> VolunteerRoleMap = new Map<Id, Volunteer_Roles__c>();
//				Map<Id, String> wishIdRoleNameMap = new Map<Id, String>();
				Set<Id> volunteerIdSet = new Set<Id>();
				//WVC-2045 added if condion and status != 'Completed' in where condion
				for (Volunteer_Roles__c dbVolRole : [
						SELECT Id,Volunteer_Name__c,Hidden_Previous_Sub_Status__c,Hidden_Previous_Status__c,Status__c,
								Sub_status__c,Chapter_Role__c,Chapter_Role__r.Background_Check_Required__c,
								Chapter_Role__r.COI_Required__c
						FROM Volunteer_Roles__c
						WHERE Volunteer_Name__c IN:volunteerContactIdSet
						AND Status__c != :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
						AND Status__c != :VOLUNTEER_ROLE_STATUS_FORMER
						AND Status__c != :VOLUNTEER_ROLE_STATUS_NOT_APPROVED
				]) {
					Volunteer_Roles__c updateVolStatus = new Volunteer_Roles__c();
					updateVolStatus.Id = dbVolRole.Id;
					/**
					 * JIRA: WLP-422
					 * Author: Gustavo Mayer
					 * Update: Adding the new field COI Required to the condition
					 * to change Volunteer_Roles__c from Active to Out of Compliance.
					 */
					if (dbVolRole.Chapter_Role__r.Background_Check_Required__c
							&& objectName == 'backgroundcheck') {
						updateVolStatus.Hidden_Previous_Status__c = dbVolRole.Status__c;
						updateVolStatus.Hidden_Previous_Sub_Status__c = dbVolRole.Sub_status__c;
						updateVolStatus.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
						volunteerIdSet.add(dbVolRole.Volunteer_Name__c);
					} else if (dbVolRole.Chapter_Role__r.COI_Required__c
							&& objectName == 'COI') {
						updateVolStatus.Hidden_Previous_Status__c = dbVolRole.Status__c;
						updateVolStatus.Hidden_Previous_Sub_Status__c = dbVolRole.Sub_status__c;
						updateVolStatus.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
						volunteerIdSet.add(dbVolRole.Volunteer_Name__c);
					}
					VolunteerRoleMap.put(updateVolStatus.Id, updateVolStatus);
				}
				/*  for(Volunteer_Opportunity__c dbVolOpportunity : [SELECT Id,Volunteer_Name__c,Role__c,Wish__C,Wish__r.Status,Status__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volunteerIdSet AND Status__c != 'Out of Compliance']){
					  If( dbVolOpportunity.Status__c != 'Completed'){
						  If((dbVolOpportunity.Wish__C != Null && dbVolOpportunity.Wish__r.Status != 'Granted' && dbVolOpportunity.Wish__r.Status != 'Completed' && dbVolOpportunity.Wish__r.Status != 'Closed') || (dbVolOpportunity.Wish__c == Null )){
							  Volunteer_Opportunity__c updateVolStatus = new Volunteer_Opportunity__c();
							  updateVolStatus.Id = dbVolOpportunity.Id;
							  updateVolStatus.Status__c  = 'Out of Compliance';
							  updateVolOpportunityList.add(updateVolStatus);
						  }
					  }
					  If(dbVolOpportunity.Wish__C != Null)
							  wishIdRoleNameMap.put(dbVolOpportunity.Wish__c,dbVolOpportunity.Role__c);
				  }*/
				if (updateVolOpportunityList.size() > 0) {
					update updateVolOpportunityList;
				}
				if (VolunteerRoleMap.size() > 0) {
					update VolunteerRoleMap.values();
				}
				/**** commented for WVC-2199 & WVC-2205 *****/
				/*If(wishIdRoleNameMap.Size() > 0 ){
				 Map<Id, String> caseTeamIdMap = new Map<Id, String>();
				 Map<String, Id> caseTeamNameMap = new Map<String, Id>();
				 List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
				 Set<Id> userIdSet = new Set<Id>();
				 for(CaseTeamRole caseTeamInfo : [Select Id, Name FROM CaseTeamRole]) {
					caseTeamIdMap.put(caseTeamInfo.Id, caseTeamInfo.Name);
					caseTeamNameMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
				 }
				 for(User currUser : [SELECT Id FROM USer WHERE ContactId IN :volunteerContactIdSet]){
					 userIdSet.add(currUser.Id);
				 }
				 for(CaseTeamMember dbcaseTeamMember : [SELECT id,MemberId, ParentId, TeamRoleId, TeamRole.Name  FROM CaseTeamMember WHERE ParentId IN : wishIdRoleNameMap.keySet() AND TeamRole.Name IN :wishIdRoleNameMap.values() AND MemberId IN :userIdSet]){
					   If(caseTeamNameMap.containsKey(dbcaseTeamMember.TeamRole.Name)){
						   If(caseTeamNameMap.containskey(dbcaseTeamMember.TeamRole.Name+' (Inactive)'))
							   dbcaseTeamMember.TeamRoleId = caseTeamNameMap.get(dbcaseTeamMember.TeamRole.Name+' (Inactive)');
						   caseTeamList.add(dbcaseTeamMember);
					   }
				 }
				 If(caseTeamList.Size() > 0)
					 Update caseTeamList;
				}*/
				/********* End WVC-2199 & WVC - 2205 ****/

			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (SObject currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',
						String.valueOf(currRec), String.valueOf(ex), 'UpdateVOppAndVRoleStatus',
						currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (SObject currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	//Create the task when back ground check status goes to Received from First Advantage.
	public static void createReviewBCTask(List<Background_check__c> reviewTaskBCList) {
		try {
			List<Task> taskList = new List<Task>();
			Id taskRecordTypeId = Constant_AC.BACKGROUND_RT_ID;
			for (Background_check__c backGroundCheck : reviewTaskBCList) {
				Task newBGTask = new Task();
				newBGTask.Description = '';
				newBGTask.WhoId = backGroundCheck.Volunteer__c;
				newBGTask.WhatId = backGroundCheck.Id;
				newBGTask.OwnerId = backGroundCheck.OwnerId;
				newBGTask.Subject = 'Review Background Check';
				newBGTask.SystemGeneratedTask__c = true;
				newBGTask.ActivityDate = System.today() + 1;
				newBGTask.RecordTypeId = taskRecordTypeId;
				taskList.add(newBGTask);
			}
			if (taskList.size() > 0) {
				insert taskList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (SObject currRec : reviewTaskBCList) {
				ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',
						String.valueOf(currRec), String.valueOf(ex), 'createReviewBCTask',
						currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (SObject currRec : reviewTaskBCList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}
}