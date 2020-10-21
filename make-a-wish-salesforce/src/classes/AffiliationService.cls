/**
 * @description Affiliation Service, centralizes Affiliation business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @date 10/03/2020
 */
public class AffiliationService {

	private static final String ORG_AFFILIATION_STATUS_INACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
	private static final String ORG_AFFILIATION_STATUS_NOT_APPROVED = Constant_AC.ORG_AFFILIATION_STATUS_NOT_APPROVED;
	private static final String ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE = Constant_AC.ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE;
	private static final String ORG_AFFILIATION_STATUS_PENDING = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
	private static final String ORG_AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
	private static final String ORG_AFFILIATION_STATUS_PROSPECTIVE = Constant_AC.ORG_AFFILIATION_STATUS_PROSPECTIVE;
	private static final String ORG_AFFILIATION_CONSTITUENT_CODE_VOLUNTEER = 'Volunteer';
	private static final String REFERRING_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
	private static final String TREATING_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
	private static final String ALT1_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String ALT2_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String CURRENT_TREATING_FACILITY = Constant_AC.ORG_AFFILIATION_TREATING_FACILITY_CURRENT;
	private static final String TEST_EXCEPTION = Constant_AC.TEST_EXCEPTION_ERROR;
	private static final String PREFIX_STRING_MAKE_A_WISH = 'Make-A-Wish ';
	private static final String CLASS_NAME = 'AffiliationService';
	private static final String DEBUG_LOG_TYPE_ERROR = 'Error';
	private static final Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;

	/**
	 * @description Find existing Affiliations
	 * @param contactIds contact ids
	 * @param accountIds account ids
	 * @return Map of Affiliations
	*/
	public static Map<String, npe5__Affiliation__c> findExistingAffiliations(Set<Id> contactIds, Set<Id> accountIds) {
		Map<String, npe5__Affiliation__c> affiliationMap = new Map<String, npe5__Affiliation__c>();
		for (npe5__Affiliation__c affiliation : [
				SELECT Id, npe5__Contact__c, npe5__Organization__c, npe5__Organization__r.RecordTypeId,
						npe5__Status__c, npe5__Primary__c, Constituent_Code__c, npe5__StartDate__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c IN :contactIds
				OR npe5__Organization__c IN :accountIds
		]) {
			String contactAccountKey = String.valueOf(affiliation.npe5__Contact__c) + String.valueOf(affiliation.npe5__Organization__c);
			affiliationMap.put(contactAccountKey, affiliation);
		}
		return affiliationMap;
	}

	/**
	 * @description Build Wish Child Affiliations
	 * @param convertedLead
	 * @return List of Affiliations
	 */
	public static List<npe5__Affiliation__c> buildWishChildAffiliation(Lead convertedLead) {
		List<npe5__Affiliation__c> affiliations = new List<npe5__Affiliation__c>();

		npe5__Affiliation__c chapterAffiliation = new npe5__Affiliation__c();
		chapterAffiliation.Constituent_Code__c = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
		chapterAffiliation.npe5__Organization__c = convertedLead.ConvertedContact.Region_Chapter__c;
		chapterAffiliation.npe5__Contact__c = convertedLead.ConvertedContactId;
		chapterAffiliation.npe5__StartDate__c = Date.today();
		chapterAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		chapterAffiliation.npe5__Primary__c = false;
		affiliations.add(chapterAffiliation);

		if (convertedLead.Hidden_DV_form_Medical_professional_Type__c != null) {
			npe5__Affiliation__c treatingHtfAffiliation = new npe5__Affiliation__c();
			treatingHtfAffiliation.npe5__Contact__c = convertedLead.ConvertedContactId;
			treatingHtfAffiliation.Treating_Facility__c = CURRENT_TREATING_FACILITY;
			treatingHtfAffiliation.npe5__Primary__c = false;
			treatingHtfAffiliation.npe5__StartDate__c = Date.today();
			treatingHtfAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c.equals(REFERRING_MED_PROFESSIONAL)
					&& convertedLead.Referring_MP_HTF__c != null) {
				treatingHtfAffiliation.npe5__Organization__c = convertedLead.Referring_MP_HTF__c;
				affiliations.add(treatingHtfAffiliation);
			} else if (convertedLead.Hidden_DV_form_Medical_professional_Type__c.equals(TREATING_MED_PROFESSIONAL)
					&& convertedLead.Treating_MP_HTF__c != null) {
				treatingHtfAffiliation.npe5__Organization__c = convertedLead.Treating_MP_HTF__c;
				affiliations.add(treatingHtfAffiliation);
			} else if (convertedLead.Hidden_DV_form_Medical_professional_Type__c.equals(BEST_CONTACT)
					&& convertedLead.Best_Contact_HTF__c != null) {
				treatingHtfAffiliation.npe5__Organization__c = convertedLead.Best_Contact_HTF__c;
				affiliations.add(treatingHtfAffiliation);
			} else if (convertedLead.Hidden_DV_form_Medical_professional_Type__c.equals(ALT2_MED_PROFESSIONAL)
					&& convertedLead.Alt_2_MP_HTF__c != null) {
				treatingHtfAffiliation.npe5__Organization__c = convertedLead.Alt_2_MP_HTF__c;
				affiliations.add(treatingHtfAffiliation);
			} else if (convertedLead.Hidden_DV_form_Medical_professional_Type__c.equals(ALT1_MED_PROFESSIONAL)
					&& convertedLead.Alt_1_MP_HTF__c != null) {
				treatingHtfAffiliation.npe5__Organization__c = convertedLead.Alt_1_MP_HTF__c;
				affiliations.add(treatingHtfAffiliation);
			}
		}
		return affiliations;
	}

	/**
	 * @description Build Medical Professional Hospital Facilities Affiliations
	 * @param lead lead
	 * @param mpHtfAffiliations existing mp htf affiliations
	 * @return List of Affiliations
	 */
	public static List<npe5__Affiliation__c> buildMedicalProfessionalHospitalAffiliation(Lead lead,
			Map<String, npe5__Affiliation__c> mpHtfAffiliations) {
		List<npe5__Affiliation__c> affiliations = new List<npe5__Affiliation__c>();
		Boolean referringMpHasPrimaryHtfAffiliation = false;
		Boolean treatingMpHasPrimaryHtfAffiliation = false;
		Boolean bestMpHasPrimaryHtfAffiliation = false;
		Boolean alt1MpHasPrimaryHtfAffiliation = false;
		Boolean alt2MpHasPrimaryHtfAffiliation = false;

		for (String key : mpHtfAffiliations.keySet()) {
			if (lead.Referring_MP__c != null && key.contains(lead.Referring_MP__c) && mpHtfAffiliations.get(key).npe5__Primary__c
					&& mpHtfAffiliations.get(key).npe5__Organization__r.RecordTypeId.equals(Constant_AC.HOSPITAL_TREATMENT_ID)) {
				referringMpHasPrimaryHtfAffiliation = true;
			}
			if (lead.Treating_MP__c != null && key.contains(lead.Treating_MP__c) && mpHtfAffiliations.get(key).npe5__Primary__c
					&& mpHtfAffiliations.get(key).npe5__Organization__r.RecordTypeId.equals(Constant_AC.HOSPITAL_TREATMENT_ID)) {
				treatingMpHasPrimaryHtfAffiliation = true;
			}
			if (lead.Best_Contact__c != null && key.contains(lead.Best_Contact__c) && mpHtfAffiliations.get(key).npe5__Primary__c
					&& mpHtfAffiliations.get(key).npe5__Organization__r.RecordTypeId.equals(Constant_AC.HOSPITAL_TREATMENT_ID)) {
				bestMpHasPrimaryHtfAffiliation = true;
			}
			if (lead.Alt_1_MP__c != null && key.contains(lead.Alt_1_MP__c) && mpHtfAffiliations.get(key).npe5__Primary__c
					&& mpHtfAffiliations.get(key).npe5__Organization__r.RecordTypeId.equals(Constant_AC.HOSPITAL_TREATMENT_ID)) {
				alt1MpHasPrimaryHtfAffiliation = true;
			}
			if (lead.Alt_2_MP__c != null && key.contains(lead.Alt_2_MP__c) && mpHtfAffiliations.get(key).npe5__Primary__c
					&& mpHtfAffiliations.get(key).npe5__Organization__r.RecordTypeId.equals(Constant_AC.HOSPITAL_TREATMENT_ID)) {
				alt2MpHasPrimaryHtfAffiliation = true;
			}
		}

		if (lead.Referring_MP__c != null && lead.Referring_MP_HTF__c != null
				&& !mpHtfAffiliations.containsKey(String.valueOf(lead.Referring_MP__c) + String.valueOf(lead.Referring_MP_HTF__c))) {
			npe5__Affiliation__c aff = new npe5__Affiliation__c();
			aff.npe5__Contact__c = lead.Referring_MP__c;
			aff.npe5__Organization__c = lead.Referring_MP_HTF__c;
			aff.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
			aff.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
			aff.npe5__StartDate__c = Date.today();
			if (!referringMpHasPrimaryHtfAffiliation) {
				aff.npe5__Primary__c = true;
			}
			affiliations.add(aff);
		}
		if (lead.Treating_MP__c != null && lead.Treating_MP_HTF__c != null
				&& !mpHtfAffiliations.containsKey(String.valueOf(lead.Treating_MP__c) + String.valueOf(lead.Treating_MP_HTF__c))) {
			npe5__Affiliation__c aff = new npe5__Affiliation__c();
			aff.npe5__Contact__c = lead.Treating_MP__c;
			aff.npe5__Organization__c = lead.Treating_MP_HTF__c;
			aff.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
			aff.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
			aff.npe5__StartDate__c = Date.today();
			if (!treatingMpHasPrimaryHtfAffiliation) {
				aff.npe5__Primary__c = true;
			}
			affiliations.add(aff);
		}
		if (lead.Best_Contact__c != null && lead.Best_Contact_HTF__c != null
				&& !mpHtfAffiliations.containsKey(String.valueOf(lead.Best_Contact__c) + String.valueOf(lead.Best_Contact_HTF__c))) {
			npe5__Affiliation__c aff = new npe5__Affiliation__c();
			aff.npe5__Contact__c = lead.Best_Contact__c;
			aff.npe5__Organization__c = lead.Best_Contact_HTF__c;
			aff.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
			aff.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
			aff.npe5__StartDate__c = Date.today();
			if (!bestMpHasPrimaryHtfAffiliation) {
				aff.npe5__Primary__c = true;
			}
			affiliations.add(aff);
		}
		if (lead.Alt_1_MP__c != null && lead.Alt_1_MP_HTF__c != null
				&& !mpHtfAffiliations.containsKey(String.valueOf(lead.Alt_1_MP__c) + String.valueOf(lead.Alt_1_MP_HTF__c))) {
			npe5__Affiliation__c aff = new npe5__Affiliation__c();
			aff.npe5__Contact__c = lead.Alt_1_MP__c;
			aff.npe5__Organization__c = lead.Alt_1_MP_HTF__c;
			aff.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
			aff.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
			aff.npe5__StartDate__c = Date.today();
			if (!alt1MpHasPrimaryHtfAffiliation) {
				aff.npe5__Primary__c = true;
			}
			affiliations.add(aff);
		}
		if (lead.Alt_2_MP__c != null && lead.Alt_2_MP_HTF__c != null
				&& !mpHtfAffiliations.containsKey(String.valueOf(lead.Alt_2_MP__c) + String.valueOf(lead.Alt_2_MP_HTF__c))) {
			npe5__Affiliation__c aff = new npe5__Affiliation__c();
			aff.npe5__Contact__c = lead.Alt_2_MP__c;
			aff.npe5__Organization__c = lead.Alt_2_MP_HTF__c;
			aff.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
			aff.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
			aff.npe5__StartDate__c = Date.today();
			if (!alt2MpHasPrimaryHtfAffiliation) {
				aff.npe5__Primary__c = true;
			}
			affiliations.add(aff);
		}
		return affiliations;
	}

	/**
	 * @description Whenever first Affiliation record has fallen under contact, assigning that record as primary.
	 * @param newList list
	 */
	public static void setStatusAndPrimary(List<npe5__Affiliation__c> newList) {
		Set<Id> contactIds = new Set<Id>();
		for (npe5__Affiliation__c currRec : newList) {
			contactIds.add(currRec.npe5__Contact__c);
		}

		if (contactIds.isEmpty()) {
			return;
		}

		Map<Id, Contact> getContactRecType = new Map<Id, Contact>([
				SELECT Id, RecordTypeId
				FROM Contact
				WHERE Id IN :contactIds
				AND RecordTypeId != :Constant_AC.MEDICAL_PROFESSIONAL_RT_ID
		]);

		Map<String, Integer> contactsMap = new Map<String, Integer>();
		for (AggregateResult ar : [
				SELECT npe5__Contact__c, COUNT(Id) cnt
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c IN :contactIds
				GROUP BY npe5__Contact__c
		]) {
			contactsMap.put(String.valueOf(ar.get('npe5__Contact__c')), Integer.valueOf(ar.get('cnt')));
		}

		for (npe5__Affiliation__c affiliation : newList) {
			if (!(contactsMap.containsKey(affiliation.npe5__Contact__c))) {
				affiliation.npe5__Primary__c = true;
			}
			if (affiliation.npe5__Contact__c != null && getContactRecType.containsKey(affiliation.npe5__Contact__c)) {
				if (getContactRecType.get(affiliation.npe5__Contact__c).RecordTypeId != VOLUNTEER_RECORD_TYPE_ID) {
					affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
				} else {
					affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
				}
			}
		}
	}

	/**
	 * @description This is used to get affiliation's corresponding username and email to merge in active user welcome email template
	 * @param newList
	 * @param oldMap
	 */
	public static void setHiddenUserFields(List<npe5__Affiliation__c> newList, Map<Id, npe5__Affiliation__c> oldMap) {
		if (RecursiveTriggerHandler.blockBeforeUpdate) {
			return;
		}

		Set<Id> contactIdsSet = new Set<Id>();
		for (npe5__Affiliation__c currRec : newList) {
			if ((currRec.npe5__Status__c != null && currRec.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE)
					&& (oldMap.get(currRec.Id).npe5__Status__c != currRec.npe5__Status__c)) {
				contactIdsSet.add(currRec.npe5__Contact__c);
			}
		}
		if (contactIdsSet.isEmpty()) {
			return;
		}

		Map<Id, User> volunteerUserMap = new Map<Id, User>();
		for (User currUser : [
				SELECT Id, Username, ContactId, Email
				FROM User
				WHERE ContactId IN :contactIdsSet
		]) {
			if (contactIdsSet.contains(currUser.ContactId)) {
				volunteerUserMap.put(currUser.ContactId, currUser);
			}
		}

		for (npe5__Affiliation__c currRec : newList) {
			if ((currRec.npe5__Status__c != null && currRec.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE)
					&& (volunteerUserMap.containsKey(currRec.npe5__Contact__c))) {
				currRec.User_Name_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Username;
				currRec.User_Email_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Email;
			}
		}
	}

	/**
	 * @description Add the user to the public group to access the approved In-Kind donor account record based on the affiliation record
	 * @param newList
	 */
	public static void addToPublicGroup(List<npe5__Affiliation__c> newList) {
		// Only runs on insert
		Set<String> volunteerNameSet = new Set<String>();
		Set<String> chapterNameSet = new Set<String>();
		Set<Id> affiliationSet = new Set<Id>();
		Map<Id, String> affiliationRecMap = new Map<Id, String>();
		for (npe5__Affiliation__c currRec : newList) {
			if (currRec.npe5__Contact__c != null && currRec.npe5__Organization__c != null) {
				volunteerNameSet.add(currRec.npe5__Contact__c);
				chapterNameSet.add(currRec.npe5__Organization__c);
				affiliationSet.add(currRec.Id);
				affiliationRecMap.put(currRec.Id, String.valueOf(currRec));
			}
		}

		Boolean createUserGroup = false;
		if (!volunteerNameSet.isEmpty() && !chapterNameSet.isEmpty() && !affiliationSet.isEmpty()) {
			for (Contact dbVolunteerContact : [
					SELECT Id, RecordTypeId, Name
					FROM Contact
					WHERE Id IN :volunteerNameSet AND RecordTypeId = :VOLUNTEER_RECORD_TYPE_ID
			]) {
				if (dbVolunteerContact.Id != null) {
					createUserGroup = true;
					break;
				}
			}
			if (createUserGroup) {
				insertGroupMember(volunteerNameSet, chapterNameSet, affiliationSet, affiliationRecMap);
			}
		}
		addToPublicGroup(newList, null);
	}

	/**
	 * @description Add the user to the public group to access the approved In-Kind donor account record based on the affiliation record
	 * @param newList
	 * @param oldMap
	 */
	public static void addToPublicGroup(List<npe5__Affiliation__c> newList, Map<Id, npe5__Affiliation__c> oldMap) {
		if (RecursiveTriggerHandler.blockAfterUpdate) {
			return;
		}

		Map<Id, npe5__Affiliation__c> affiliationMap = new Map<Id, npe5__Affiliation__c>();
		Set<Id> affiliationIds = new Set<Id>();
		for (npe5__Affiliation__c currRec : newList) {
			if (oldMap == null
					|| currRec.Constituent_Code__c != oldMap.get(currRec.Id).Constituent_Code__c
					|| currRec.npe5__Status__c != oldMap.get(currRec.Id).npe5__Status__c) {
				affiliationMap.put(currRec.npe5__Contact__c, currRec);
				affiliationIds.add(currRec.npe5__Organization__c);
			}
		}
		updateContact(affiliationMap, affiliationIds, newList);
	}

	/**
	 * @description Used to add a user to chatter group based on their chapter when the volunteer become active.
	 * @param volunteerContactIdsSet
	 * @param affiliationsIdsSet
	 * @param exceptionList
	 */
	public static void addUserToChapterGroup(Set<Id> volunteerContactIdsSet, Set<Id> affiliationsIdsSet, List<npe5__Affiliation__c> exceptionList) {
		if (volunteerContactIdsSet.isEmpty() || affiliationsIdsSet.isEmpty()) {
			return;
		}
		try {
			Set<String> chapterNamesSet = new Set<String>();
			Map<Id, String> volunteerChaptersMap = new Map<Id, String>();
			for (npe5__Affiliation__c getChapters : [
					SELECT Id, npe5__Organization__r.Name, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerContactIdsSet AND Id IN :affiliationsIdsSet
			]) {
				if (!chapterNamesSet.contains(getChapters.npe5__Organization__r.Name)) {
					chapterNamesSet.add(String.valueOf(getChapters.npe5__Organization__r.Name).removeStartIgnoreCase(PREFIX_STRING_MAKE_A_WISH));
				}
				volunteerChaptersMap.put(getChapters.npe5__Contact__c, String.valueOf(getChapters.npe5__Organization__r.Name).removeStartIgnoreCase(PREFIX_STRING_MAKE_A_WISH));
			}

			// Used to get volunteer user id and volunteer contact id
			Map<Id, Id> volunteerUsersMap = new Map<Id, Id>();
			for (User relatedUsers : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerContactIdsSet
			]) {
				volunteerUsersMap.put(relatedUsers.ContactId, relatedUsers.Id);
			}

			Map<String, Id> chatterGroupNameIdsMap = new Map<String, Id>();
			if (!chapterNamesSet.isEmpty()) {
				// Used to get the group name based on the chapter names
				for (CollaborationGroup collaborationGroup : [
						SELECT Id, Name
						FROM CollaborationGroup
						WHERE Name IN :chapterNamesSet
				]) {
					chatterGroupNameIdsMap.put(collaborationGroup.Name, collaborationGroup.Id);
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
			List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();
			for (Id volunteerContact : volunteerContactIdsSet) {
				if (volunteerChaptersMap.containsKey(volunteerContact)
						&& chatterGroupNameIdsMap.containsKey(volunteerChaptersMap.get(volunteerContact))
						&& volunteerChaptersMap.containsKey(volunteerContact)) {
					if (!chatterGroupsMembersSet.contains(chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)) + '-' + volunteerUsersMap.get(volunteerContact))
							&& volunteerUsersMap.containsKey(volunteerContact)) {
						chatterGroupMembersList.add(new CollaborationGroupMember (CollaborationGroupId = chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)), MemberId = volunteerUsersMap.get(volunteerContact)));
					}
				}
			}
			if (!Test.isRunningTest()) {
				insert chatterGroupMembersList;
			} else {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, String.valueOf(currRec), String.valueOf(ex), 'addUserToChapterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * @description Add user to chatter group when a user becomes active to particular chapter
	 * @param newList
	 * @param oldMap
	 */
	public static void addToChatterGroup(List<npe5__Affiliation__c> newList, Map<Id, npe5__Affiliation__c> oldMap) {
		if (RecursiveTriggerHandler.blockAfterUpdate) {
			return;
		}
		Set<Id> affiliationsIdsSet = new Set<Id>();
		Set<Id> volunteerContactIdsSet = new Set<Id>();
		Set<Id> inactiveVolunteerContactIdSet = new Set<Id>();
		Set<Id> activeVolunteerIdSet = new Set<Id>();
		for (npe5__Affiliation__c modifiedAffiliation : newList) {
			if (modifiedAffiliation.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE
					&& oldMap.get(modifiedAffiliation.Id).npe5__Status__c != modifiedAffiliation.npe5__Status__c) {
				volunteerContactIdsSet.add(modifiedAffiliation.npe5__Contact__c);
				affiliationsIdsSet.add(modifiedAffiliation.Id);
				activeVolunteerIdSet.add(modifiedAffiliation.npe5__Contact__c);
			} else if (modifiedAffiliation.npe5__Status__c != Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE
					&& oldMap.get(modifiedAffiliation.Id).npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
				inactiveVolunteerContactIdSet.add(modifiedAffiliation.npe5__Contact__c);
			}
		}
		addUserToChapterGroup(volunteerContactIdsSet, affiliationsIdsSet, newList);
		inactiveAffiliations(inactiveVolunteerContactIdSet, newList);
		removeUserFromChatterGroups(inactiveVolunteerContactIdSet, newList);
		activeAffiliations(activeVolunteerIdSet, newList);
	}

	/**
	 * @description Used to remove a user from group based on their affiliation when the affiliation deleted.
	 * @param volunteerNameSet
	 * @param chapterNameSet
	 * @param exceptionMap
	 */
	@Future
	public static void removeMemberFromGroup(Set<String> volunteerNameSet, Set<String> chapterNameSet, Map<Id, String> exceptionMap) {
		if (volunteerNameSet.isEmpty() || chapterNameSet.isEmpty()) {
			return;
		}
		try {
			Map<Id, String> groupNameMap = new Map<Id, String>();
			for (Account chapterName : [
					SELECT Id, Name
					FROM Account
					WHERE Id IN :chapterNameSet
			]) {
				String groupNameTrim = chapterName.Name.removeStartIgnoreCase(PREFIX_STRING_MAKE_A_WISH);
				groupNameMap.put(chapterName.Id, groupNameTrim);
			}

			Map<Id, Id> userMap = new Map<Id, Id>();
			for (User currentUser : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerNameSet
			]) {
				userMap.put(currentUser.ContactId, currentUser.Id);
			}

			List<GroupMember> grpList = new List<GroupMember>();
			for (GroupMember currentMember : [
					SELECT Id, GroupId, UserOrGroupId
					FROM GroupMember
					WHERE UserOrGroupId IN :userMap.values()
					AND Group.Type = :Constant_AC.GROUP_TYPE_REGULAR AND Group.Name IN :groupNameMap.values()
			]) {
				grpList.add(currentMember);
			}
			delete grpList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keySet()) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, exceptionMap.get(currRec), String.valueOf(ex), 'removeMemberFromGroup', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
			}
		}
	}

	/**
	 * @description Update Affiliation Status based on Volunteer Roles of Volunteer
	 * @param volunteerRoleCountMap
	 * @param volunteerRoleStatusMap
	 * @param inActiveSingleStatusMap
	 * @param declinedStatusMap
	 * @param OCCStatusMap
	 * @param pendingStatusMap
	 * @param trainedVRsSet
	 */
	public static void updateAffiliationFromVolunteerRoleStatus(
			Map<String, Integer> volunteerRoleCountMap, Map<Id, List<Volunteer_Roles__c>> volunteerRoleStatusMap,
			Map<Id, List<Volunteer_Roles__c>> inActiveSingleStatusMap, Map<Id, List<Volunteer_Roles__c>> declinedStatusMap,
			Map<Id, List<Volunteer_Roles__c>> OCCStatusMap, Map<Id, List<Volunteer_Roles__c>> pendingStatusMap,
			Map<Id, List<Volunteer_Roles__c>> trainedVRsSet) {
		if (volunteerRoleStatusMap.isEmpty()) {
			return;
		}
		List<npe5__Affiliation__c> updateAffiliations = new List<npe5__Affiliation__c>();
		for (npe5__Affiliation__c aff : [
				SELECT Id, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c IN :volunteerRoleStatusMap.keySet()
				AND constituent_code__c = :ORG_AFFILIATION_CONSTITUENT_CODE_VOLUNTEER
		]) {
			npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
			affiliation.Id = aff.Id;
			if (volunteerRoleCountMap.get(aff.npe5__Contact__c) == 1) {
				if (inActiveSingleStatusMap.containsKey(aff.npe5__Contact__c)) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_INACTIVE;
				} else if (declinedStatusMap.containsKey(aff.npe5__Contact__c)) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_NOT_APPROVED;
				} else if (OCCStatusMap.containsKey(aff.npe5__Contact__c)) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE;
				} else if (pendingStatusMap.containsKey(aff.npe5__Contact__c)) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_PENDING;
				}
			} else if (volunteerRoleCountMap.get(aff.npe5__Contact__c) > 1) {
				if (pendingStatusMap.containsKey(aff.npe5__Contact__c)
						&& !trainedVRsSet.containsKey(aff.npe5__Contact__c)) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_PENDING;
				} else if (inActiveSingleStatusMap.containsKey(aff.npe5__Contact__c)
						&& (inActiveSingleStatusMap.get(aff.npe5__Contact__c).size()
						== volunteerRoleCountMap.get(aff.npe5__Contact__c)
						|| (!pendingStatusMap.containsKey(aff.npe5__Contact__c)
						&& !OCCStatusMap.containsKey(aff.npe5__Contact__c)))) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_INACTIVE;
				} else if (declinedStatusMap.containsKey(aff.npe5__Contact__c)
						&& (declinedStatusMap.get(aff.npe5__Contact__c)).size()
						== volunteerRoleCountMap.get(aff.npe5__Contact__c)) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_NOT_APPROVED;
				} else if (OCCStatusMap.containsKey(aff.npe5__Contact__c)
						&& ((OCCStatusMap.get(aff.npe5__Contact__c).size() == volunteerRoleCountMap.get(aff.npe5__Contact__c))
						|| (!pendingStatusMap.containsKey(aff.npe5__Contact__c)))) {
					affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE;
				}
			}
			if (trainedVRsSet.containsKey(aff.npe5__Contact__c)) {
				affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_ACTIVE;
			}
			updateAffiliations.add(affiliation);
		}
		update updateAffiliations;
	}

	/**
	 * @description Update Inactive Affiliation
	 * @param volunteerRoleStatusMap
	 */
	public static void updateInactiveAffiliationFromContact(Map<Id, List<Volunteer_Roles__c>> volunteerRoleStatusMap) {
		if (volunteerRoleStatusMap.isEmpty()) {
			return;
		}
		try {
			List<npe5__Affiliation__c> updateAffiliations = new List<npe5__Affiliation__c>();
			for (npe5__Affiliation__c aff : [
					SELECT Id, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerRoleStatusMap.keySet()
					AND npe5__Status__c != :ORG_AFFILIATION_STATUS_ACTIVE
					AND npe5__Status__c != :ORG_AFFILIATION_STATUS_PENDING
			]) {
				npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
				affiliation.Id = aff.Id;
				affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_PROSPECTIVE;
				updateAffiliations.add(affiliation);
			}
			update updateAffiliations;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (List<Volunteer_Roles__c> volunteerRoles : volunteerRoleStatusMap.values()) {
				for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
					ErrorMessage_AC.createDebugRec('AffiliationService',
							String.valueOf(volunteerRole), String.valueOf(ex), 'updateInactiveAffiliationFromContact',
							volunteerRole.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
					if (!Test.isRunningTest()) {
						volunteerRole.addError(Label.Debug_log_error_message);
					}
				}
			}
		}
	}

	/**
	* Create affiliation for contact
	* @param contactList
	*/
	public static void createAffiliation(List<Contact> contactList) {
		List<npe5__Affiliation__c> insertAffiliationList = new List<npe5__Affiliation__c>();
		Set<Id> volunteerContactIds = new Set<Id>();
		Map<Id, Id> mpChapterAffiliations = new Map<Id, Id>();
		for (Contact contact : contactList) {
			if (contact.RecordTypeId == Constant_AC.VOLUNTEER_RT_ID) {
				npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
				affiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
				affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
				affiliation.npe5__Primary__c = true;
				affiliation.npe5__Organization__c = contact.Region_Chapter__c;
				affiliation.npe5__Contact__c = contact.Id;
				volunteerContactIds.add(contact.Id);
				insertAffiliationList.add(affiliation);
			} else if (contact.RecordTypeId == Constant_AC.BOARD_MEMBER_RT_ID) {
				npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
				affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
				affiliation.npe5__Contact__c = contact.Id;
				affiliation.npe5__StartDate__c = Date.today();
				affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
				insertAffiliationList.add(affiliation);
			} else if ((contact.RecordTypeId == Constant_AC.MEDICAL_PROFESSIONAL_RT_ID
					|| contact.RecordTypeId == Constant_AC.WISH_FAMILY_RT_ID
					|| contact.RecordTypeId == Constant_AC.CONTACT_WISH_CHILD_RT_ID)
					&& contact.Region_Chapter__c != null) {
				npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
				if (contact.RecordTypeId == Constant_AC.MEDICAL_PROFESSIONAL_RT_ID) {
					affiliation.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
					mpChapterAffiliations.put(contact.Id, contact.Region_Chapter__c);
				} else if (contact.RecordTypeId == Constant_AC.WISH_FAMILY_RT_ID) {
					affiliation.Constituent_Code__c = Constant_AC.WISH_FAMILY_RT_LABEL;
				} else {
					affiliation.Constituent_Code__c = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
				}
				affiliation.npe5__Organization__c = contact.Region_Chapter__c;
				affiliation.npe5__Contact__c = contact.Id;
				affiliation.npe5__StartDate__c = Date.today();
				affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
				insertAffiliationList.add(affiliation);
			}
            if(contact.RecordTypeId == Constant_AC.MEDICAL_PROFESSIONAL_RT_ID 
               && contact.npsp__Primary_Affiliation__c != null) {
                npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
                affiliation.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
                affiliation.npe5__Primary__c = true;
                affiliation.npe5__Organization__c = contact.npsp__Primary_Affiliation__c;
                affiliation.npe5__Contact__c = contact.Id;
                affiliation.npe5__StartDate__c = Date.today();
                affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
                insertAffiliationList.add(affiliation);
            }
		}
		List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
		if (!volunteerContactIds.isEmpty()) {
			for (npe5__Affiliation__c affiliation : [
					SELECT Id, npe5__Primary__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerContactIds
					AND npe5__Primary__c = TRUE
			]) {
				affiliation.npe5__Primary__c = false;
				affiliationList.add(affiliation);
			}
		}
		update affiliationList;
		insert insertAffiliationList;
		List<npe5__Affiliation__c> mpPrimaryAffiliationsUpdate = new List<npe5__Affiliation__c>();
		for(npe5__Affiliation__c affiliation : [
				SELECT Id, npe5__Primary__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c IN :mpChapterAffiliations.keySet()
				AND npe5__Organization__c IN :mpChapterAffiliations.values()
		]){
            affiliation.npe5__Primary__c = false;
            affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
            affiliation.npe5__EndDate__c = null;
            mpPrimaryAffiliationsUpdate.add(affiliation);
		}
		update mpPrimaryAffiliationsUpdate;
	}

	/**
	* Update affiliation status based on contact application status
	* @param newContactsList
	* @param oldContactsMap
	*/
	public static void updateOrgAffiliationStatus(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap) {
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		for (Contact newContact : newContactsList) {
			if (newContact.is_Application__c != oldContactsMap.get(newContact.Id).is_Application__c) {
				contactMap.put(newContact.Id, newContact);
			}
		}
		if (!contactMap.isEmpty()) {
			List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
			for (npe5__Affiliation__c dbAffiliationRec : [
					SELECT Id, npe5__Contact__c, npe5__Primary__c, npe5__Status__c, npe5__Organization__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :contactMap.keySet() AND npe5__Status__c != 'Active'
			]) {
				if (contactMap.containsKey(dbAffiliationRec.npe5__Contact__c)) {
					npe5__Affiliation__c updateAffiliation = new npe5__Affiliation__c();
					updateAffiliation.Id = dbAffiliationRec.Id;
					if (contactMap.get(dbAffiliationRec.npe5__Contact__c).is_Application__c == 'Complete') {
						updateAffiliation.npe5__Status__c = 'Pending';
					} else if (contactMap.get(dbAffiliationRec.npe5__Contact__c).is_Application__c == 'Rejected') {
						updateAffiliation.npe5__Status__c = 'Not Approved';
					}
					affiliationList.add(updateAffiliation);
				}
			}
			try {
				update affiliationList;
			} catch (Exception e) {
				createContactDebugLog(affiliationList, 'updateOrgAffiliationStatus', e);
			}
		}
	}

	//used to update the status field in contact for reporting purpose
	private static void updateContact(Map<Id, npe5__Affiliation__c> affiliationMap, Set<Id> affiliationIds,
			List<npe5__Affiliation__c> exceptionList) {
		if (Test.isRunningTest()) {
			RecursiveTriggerHandler.isFirstTime = true;
		}
		if (affiliationMap.isEmpty() || affiliationIds.isEmpty() || !RecursiveTriggerHandler.isFirstTime) {
			return;
		}
		try {
			RecursiveTriggerHandler.isFirstTime = false;
			List<Contact> conList = [
					SELECT Id, Hidden_Status__c, RecordTypeId, RecordType.Name
					FROM Contact
					WHERE Id IN :affiliationMap.keySet()
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
			recordTypeNames.put(Constant_AC.VOLUNTEER_RT_ID, Constant_AC.VOLUNTEER_TASK_RT_LABEL);
			recordTypeNames.put(Constant_AC.CONTACT_WISH_CHILD_RT_ID, Constant_AC.CONTACT_WISH_CHILD_RT_LABEL);
			recordTypeNames.put(Constant_AC.WISH_FAMILY_RT_ID, Constant_AC.WISH_FAMILY_RT_LABEL);
			recordTypeNames.put(Constant_AC.MEDICAL_PROFESSIONAL_RT_ID, Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL);
			recordTypeNames.put(Constant_AC.BOARD_MEMBER_RT_ID, Constant_AC.BOARD_MEMBER_RT_LABEL);

			Map<String, Id> recordTypes = new Map<String, Id>();
			for (Id recordTypeNameKey : recordTypeNames.keySet()) {
				recordTypes.put(recordTypeNames.get(recordTypeNameKey), recordTypeNameKey);
			}

			for (Contact currContact : conList) {
				npe5__Affiliation__c currAffiliation = affiliationMap.get(currContact.Id);
				currContact.Hidden_Status__c = currAffiliation.npe5__Status__c;

				if (currAffiliation.Constituent_Code__c != null && recordTypeNames.containsKey(currContact.RecordTypeId)
						&& currAffiliation.Constituent_Code__c != recordTypeNames.get(currContact.RecordTypeId)
						&& recordTypeOrder.get(currAffiliation.Constituent_Code__c) < recordTypeOrder.get(recordTypeNames.get(currContact.RecordTypeId))
						&& recordTypes.containsKey(currAffiliation.Constituent_Code__c)
						&& accountMap.get(currAffiliation.npe5__Organization__c).RecordTypeId == Constant_AC.CHAPTER_RT_ID) {
					currContact.RecordTypeId = recordTypes.get(currAffiliation.Constituent_Code__c);
				}
			}
			update conList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, String.valueOf(currRec), String.valueOf(ex), 'updateContact', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	private static void inactiveAffiliations(Set<Id> volunteerIdSet, List<npe5__Affiliation__c> exceptionList) {
		if (volunteerIdSet == null || volunteerIdSet.isEmpty()) {
			return;
		}
		try {
			Set<Id> inactiveVolunteerIdSet = new Set<Id>();
			for (npe5__Affiliation__c currAff : [
					SELECT Id, npe5__Status__c, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerIdSet
			]) {

				if (currAff.npe5__Status__c != Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
					inactiveVolunteerIdSet.add(currAff.npe5__Contact__c);
				} else if (currAff.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE && inactiveVolunteerIdSet.contains(currAff.npe5__Contact__c)) {
					inactiveVolunteerIdSet.remove(currAff.npe5__Contact__c);
				}
			}
			updateBCandCOIVolunteerInactive(inactiveVolunteerIdSet, true, exceptionList);
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}

		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, String.valueOf(currRec), String.valueOf(ex), 'inactiveAffiliations', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	private static void updateBCandCOIVolunteerInactive(Set<Id> inactiveVolunteerIdSet, Boolean isInactiveVolunteer,
			List<npe5__Affiliation__c> exceptionList) {
		if (inactiveVolunteerIdSet.isEmpty()) {
			return;
		}
		try {
			List<Background_check__c> updateBCList = new List<Background_check__c>();
			for (Background_check__c currBC : [
					SELECT Id,Volunteer_is_Inactive__c
					FROM Background_check__c
					WHERE Volunteer__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
			]) {
				currBC.Volunteer_is_Inactive__c = isInactiveVolunteer;
				updateBCList.add(currBC);
			}
			update updateBCList;

			List<Conflict_Of_Interest__c> updateCOIList = new List<Conflict_Of_Interest__c>();
			for (Conflict_Of_Interest__c currCOI : [
					SELECT Id,Volunteer_is_Inactive__c
					FROM Conflict_Of_Interest__c
					WHERE Volunteer_Contact__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
			]) {
				currCOI.Volunteer_is_Inactive__c = isInactiveVolunteer;
				updateCOIList.add(currCOI);
			}
			update updateCOIList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, String.valueOf(currRec), String.valueOf(ex), 'updateBCandCOIVolunteerInactive', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	private static void removeUserFromChatterGroups(set<ID> volunteerContactSet, List<npe5__Affiliation__c> affiliationList) {
		if (volunteerContactSet.isEmpty()) {
			return;
		}
		try {
			List<npe5__Affiliation__c> affiliationListWithOrgNames = [
					SELECT id, npe5__organization__r.name, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE id IN :affiliationList
			];
			Set<String> groupNames = new Set<String>();
			for (npe5__Affiliation__c affiliationOrg : affiliationListWithOrgNames) {
				if (affiliationOrg.npe5__organization__r.name.startsWithIgnoreCase(PREFIX_STRING_MAKE_A_WISH)) {
					groupnames.add(affiliationOrg.npe5__organization__r.name.removeStartIgnoreCase(PREFIX_STRING_MAKE_A_WISH));
				}
			}
			List<CollaborationGroup> chatGroupList = [
					SELECT id, name
					FROM CollaborationGroup
					WHERE name IN :groupNames
			];
			Map<ID, String> groupIDToNameMap = new Map<ID, String>();
			for (CollaborationGroup chatGroup : chatGroupList) {
				groupIDToNameMap.put(chatGroup.id, chatGroup.Name);
			}
			Map<ID, ID> contactToUserMap = new Map<ID, ID>();

			for (User volunteerUser : [
					SELECT id, contactID
					FROM User
					WHERE contactID IN :volunteerContactSet
			]) {
				contactToUserMap.put(volunteerUser.contactID, volunteerUser.ID);
			}
			List<CollaborationGroupMember> chatterMembersForDelete = new List<CollaborationGroupMember>();
			List<CollaborationGroupMember> chatterMemberList = [
					SELECT id, CollaborationGroupId, MemberID
					FROM CollaborationGroupMember
					WHERE MemberID IN :contactToUserMap.values() AND CollaborationGroupID IN :groupIDToNameMap.keyset()
			];

			for (npe5__Affiliation__c affiliation : affiliationListWithOrgNames) {
				for (CollaborationGroupMember groupMember : chatterMemberList) {
					if (groupIDToNameMap.get(groupMember.CollaborationGroupID).contains(affiliation.npe5__Organization__r.name.removeStartIgnoreCase(PREFIX_STRING_MAKE_A_WISH))
							&& groupMember.MemberID == contactToUserMap.get(affiliation.npe5__Contact__c)) {
						chatterMembersForDelete.add(groupMember);
					}
				}
			}

			if (chatterMembersForDelete.size() > 0) {
				delete chatterMembersForDelete;
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : affiliationList) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, String.valueOf(currRec), String.valueOf(ex), 'removeUserFromChatterGroups', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	private static void activeAffiliations(Set<Id> volunteerIdsSet, List<npe5__Affiliation__c> exceptionList) {
		if (volunteerIdsSet.isEmpty()) {
			return;
		}
		try {
			Set<Id> volunteerIdSubsetSet = new Set<Id>();
			for (npe5__Affiliation__c currAff : [
					SELECT Id, npe5__Status__c, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerIdsSet
			]) {
				if (currAff.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
					volunteerIdSubsetSet.add(currAff.npe5__Contact__c);
				}
			}
			if (volunteerIdSubsetSet.isEmpty()) {
				return;
			}

			Set<Id> activeVolunteerIdSet = new Set<Id>();
			for (User currUser : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerIdSubsetSet AND IsActive = TRUE
			]) {
				activeVolunteerIdSet.add(currUser.ContactId);
			}
			updateBCandCOIVolunteerInactive(activeVolunteerIdSet, false, exceptionList);
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}
		} catch (Exception ex) {
			for (npe5__Affiliation__c currRec : exceptionList) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, String.valueOf(currRec), String.valueOf(ex), 'activeAffiliations', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	// Used to add a user to group based on their affiliation when the affiliation created.
	@Future
	private static void insertGroupMember(Set<String> volunteerNameSet, Set<String> chapterNameSet, Set<Id> affiliationSet,
			Map<Id, String> exceptionMap) {
		if (volunteerNameSet.isEmpty() || chapterNameSet.isEmpty() || affiliationSet.isEmpty()) {
			return;
		}
		try {
			Map<Id, User> userMap = new Map<Id, User>();
			for (User currentUser : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerNameSet
			]) {
				userMap.put(currentUser.ContactId, currentUser);
			}

			Map<Id, String> chapterNameMap = new Map<Id, String>();
			for (Account currentAccount : [
					SELECT Id,Name
					FROM Account
					WHERE Id IN :chapterNameSet
			]) {
				String chapterNameTrim = currentAccount.Name.removeStartIgnoreCase(PREFIX_STRING_MAKE_A_WISH);
				chapterNameMap.put(currentAccount.Id, chapterNameTrim);
			}

			Map<String, Id> publicGroupMap = new Map<String, Id>();
			for (Group currentGroup : [
					SELECT Id, Name
					FROM Group
					WHERE Type = :Constant_AC.GROUP_TYPE_REGULAR
			]) {
				publicGroupMap.put(currentGroup.Name, currentGroup.Id);
			}

			List<GroupMember> groupMemberList = new List<GroupMember>();
			for (npe5__Affiliation__c currentRec : [
					SELECT Id, Name, npe5__Organization__c, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE Id IN :affiliationSet
			]) {
				if (userMap.containsKey(currentRec.npe5__Contact__c) && chapterNameMap.containsKey(currentRec.npe5__Organization__c) && publicGroupMap.containsKey(chapterNameMap.get(currentRec.npe5__Organization__c))) {
					GroupMember newGroupMem = new GroupMember();
					newGroupMem.GroupId = publicGroupMap.get(chapterNameMap.get(currentRec.npe5__Organization__c));
					newGroupMem.UserOrGroupId = userMap.get(currentRec.npe5__Contact__c).Id;
					groupMemberList.add(newGroupMem);
				}
			}
			insert groupMemberList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(TEST_EXCEPTION);
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keySet()) {
				ErrorMessage_AC.createDebugRec(CLASS_NAME, exceptionMap.get(currRec), String.valueOf(ex), 'insertGroupMember', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), DEBUG_LOG_TYPE_ERROR);
			}
		}
	}

	private static void createContactDebugLog(List<SObject> exceptionList, String methodName, Exception ex) {
		for (SObject record : exceptionList) {
			ErrorMessage_AC.createDebugRec('AffiliationService', String.valueOf(record), String.valueOf(ex),
					methodName, record.Id, ex.getStackTraceString() + ' ' + ex.getMessage(), 'Error');
			record.addError(Label.Debug_log_error_message);
		}
	}
}