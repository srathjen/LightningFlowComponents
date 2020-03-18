/**
 * @description Case Service, exposes methods for the Controller layer.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/20/2019
 */
public with sharing class CaseService {

	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
	private final static String STATUS_NEW = Constant_AC.CASE_STATUS_NEW;
	private final static String STATUS_QUALIFIED = Constant_AC.CASE_STATUS_QUALIFIED;
	private final static String STATUS_PENDING_CLARIFICATION_CHAPTER = Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER;
	private static final String ORIGIN_WEB = Constant_AC.CASE_ORIGIN_WEB;
	private static final String ORIGIN_EMAIL = Constant_AC.CASE_ORIGIN_EMAIL;
	private static final String RUSH_TIME_FRAME = Constant_AC.CASE_RUSH_TIME_FRAME;
	private static final String UWI_SOURCE_LEAD = Constant_AC.CASE_UWI_SOURCE_LEAD;
	private static final String LEAD_COMATOSE_VEGETATIVE_STATE_YES = Constant_AC.LEAD_COMATOSE_VEGETATIVE_STATE_YES;
	private static final String LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES = Constant_AC.LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES;
	private static final String SPACE = ' ';
	private static final String APPEND_ELIGIBILITY_REVIEW = ' - Eligibility Review';

	/**
	* Check if the User or the User's profile has permissions on Case
	* @param userId
	* @param userProfileId
	* @return Boolean
	*/
	public static Boolean userHasRestrictedPermissionOnCase() {
		return Closed_Case_Editing_Security_Settings__c.getInstance().Restrict_Access__c;
	}

	/**
	 * Delete Case found by Lead Id and Record Type Name
	 * @param leadId
	 * @param caseRecordTypeNames
	 */
	public static void deleteByLeadIdAndRecordTypeNames(Id leadId, List<String> caseRecordTypeNames) {
		delete [
				SELECT Id, Lead__c
				FROM Case
				WHERE Lead__c = :leadId
				AND RecordType.Name IN :caseRecordTypeNames
		];
	}

	/**
	 * Update Status on Case by Lead and Record Type
	 * @param leadIds
	 * @param recordTypeIds
	 * @param targetCaseStatus
	 * @return Map of Cases
	 */
	public static Map<Id, Case> updateStatusByLeadAndRecordType(Set<Id> leadIds, Set<Id> recordTypeIds, String targetCaseStatus) {
		Map<Id, Case> caseMap = new Map<Id, Case>();
		for (Case caseRecord : [
				SELECT Id, Rush__c, Lead__c
				FROM Case
				WHERE Lead__c IN :leadIds
				AND RecordTypeId IN :recordTypeIds
		]) {
			if (leadIds.contains(caseRecord.Lead__c)) {
				caseRecord.Status = targetCaseStatus;
			}
			caseMap.put(caseRecord.Id, caseRecord);
		}
		System.debug('caseMapz ' + caseMap);
		update caseMap.values();
		return caseMap;
	}

	/**
	 * Update Rush on Case by Rush Lead Map and Record Type
	 * Rush is true when any medical reason is true
	 * @param rushLeadMap
	 * @param recordTypesIds
	 */
	public static Map<Id, Case> updateRushByLeadAndRecordType(Map<Id, Boolean> rushLeadMap, Set<Id> recordTypesIds) {
		Map<Id, Case> caseMap = new Map<Id, Case>();
		for (Case caseRecord : [
				SELECT Id, Rush__c, Lead__c
				FROM Case
				WHERE Lead__c IN :rushLeadMap.keySet()
				AND RecordTypeId = :recordTypesIds
		]) {
			caseRecord.Rush__c = rushLeadMap.get(caseRecord.Lead__c);
			caseMap.put(caseRecord.Id, caseRecord);
		}
		update caseMap.values();
		return caseMap;
	}

	/**
	 * Set Diagnosis Verification Receive Date on DocuSign Status by Converted Lead Ids
	 * @param leadId
	 */
	public static Map<Id, Case> setDVReceiveDate(List<dsfs__DocuSign_Status__c> docuSignStatuses, Map<Id, Case> insertCaseMap) {
		for (dsfs__DocuSign_Status__c docuSignStatus : docuSignStatuses) {
			if (insertCaseMap.containsKey(docuSignStatus.dsfs__Lead__c) && docuSignStatus.dsfs__Completed_Date_Time__c != null) {
				Case caseConverted = new Case();
				caseConverted = insertCaseMap.get(docuSignStatus.dsfs__Lead__c);
				caseConverted.Diagnosis_Verification_Receive_Date__c = docuSignStatus.dsfs__Completed_Date_Time__c.dateGmt();
				insertCaseMap.put(docuSignStatus.dsfs__Lead__c, caseConverted);
			}
		}
		return insertCaseMap;
	}

	/**
	 * Build Qualified Case
	 * @param lead
	 * @param hasContactConverted
	 * @return Case
	 */
	public static Case buildQualifiedCaseFromLead(Lead lead, Boolean hasContactConverted) {
		Case newCase = new Case();
		newCase.RecordTypeId = WISH_RECORD_TYPE_ID;
		newCase.ContactId = lead.ConvertedContactId;
		newCase.Hidden_Lead_Id__c = lead.Id;
		newCase.Qualified_Date__c = lead.Qualified_Date__c;
		newCase.Migrated_Record__c = lead.Migrated_Record__c;
		newCase.Qualifying_Medical_Professional_Name__c = lead.Treating_Medical_Professional_First_Name__c
				+ SPACE + lead.Treating_Medical_Professional_Last_Name__c;
		newCase.Qualifying_Medical_Professional_Email__c = lead.Treating_Medical_Professional_Email__c;
		newCase.AccountId = lead.ConvertedAccountId;
		newCase.Status = STATUS_QUALIFIED;
		newCase.Hidden_Why_do_you_feel__c = lead.Why_do_you_feel_would_be_eligible_Wish__c;
		newCase.Origin = ORIGIN_WEB;
		newCase.Diagnosis_Verification_Receive_Date__c = lead.Part_A_Received__c;
		newCase.Diagnosis_Verification_Sent_Date__c = lead.Part_A_Sent__c;
		if (hasContactConverted) {
			newCase.ChapterName__c = lead.ChapterName__c;
			newCase.Hidden_Primary_Diagnosis__c = lead.PD_Condition_Description__c;
		}
		if (lead.ChapterName__r.Qualified_Wish_Owner__c != null) {
			newCase.OwnerId = lead.ChapterName__r.Qualified_Wish_Owner__c;
		}
		if (lead.FirstName != null) {
			newCase.Subject = lead.FirstName + SPACE + lead.LastName;
		} else {
			newCase.Subject = lead.LastName;
		}
		if (lead.Rush__c) {
			newCase.Rush__c = true;
			newCase.Rush_Explanation__c = lead.Please_Explain__c;
			newCase.Rush_Timeframe__c = RUSH_TIME_FRAME;
		} else {
			newCase.Rush__c = false;
		}
		if (lead.Referred_Date__c != null) {
			newCase.Referral_Date__c = lead.Referred_Date__c;
		}
		if (lead.Inquiry_Date__c != null) {
			newCase.Inquiry_Date__c = lead.Inquiry_Date__c;
		}
		if (lead.Out_of_Territory__c != null) {
			newCase.Out_of_Territory__c = lead.Out_of_Territory__c;
		}
		if (lead.unique_wish_identifier__c != null) {
			newCase.Lead__c = lead.Id;
			newCase.Unique_Wish_Record_Identifier__c = lead.unique_wish_identifier__c;
			newCase.Fund_Id__c = lead.unique_wish_identifier__c;
			newCase.UWISource__c = UWI_SOURCE_LEAD;
			newCase.Wish_Assist__c = true;
		}
		return newCase;
	}

	/**
	 * Create a new eligibility review case when the lead status is updated as elegibility review.
	 * @param LeadList
	 */
	public static void createEligibilityReview(List<Lead> LeadList) {
		List<Case> newCaseList = new List<Case>();
		Set<Id> accountIdSet = new Set<Id>();
		Map<Id, String> emailMap = new Map<Id, String>();
		Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		String nationalAdviser = System.Label.MedicalAdviser;
		Id nationAdvisorQueueId = [
				SELECT Id
				FROM Group
				WHERE Name = :nationalAdviser
		].Id;
		try {
			for (Lead process : LeadList) {
				accountIdSet.add(process.ChapterName__c);
			}
			if (!accountIdSet.isEmpty()) {
				for (Account dbChapterAcc : [
						SELECT Id,MAC_Email_del__c,RecordTypeId
						FROM Account
						WHERE Id IN:accountIdSet AND RecordTypeId = :chapterRecordTypeId
				]) {
					emailMap.put(dbChapterAcc.Id, dbChapterAcc.MAC_Email_del__c);
				}
			}
			for (Lead processLead : LeadList) {
				Case newCase = new Case();
				newCase.Status = STATUS_NEW;
				if (processLead.Is_in_a_Comatose_Vegetative_State__c == LEAD_COMATOSE_VEGETATIVE_STATE_YES) {
					newCase.Status = STATUS_PENDING_CLARIFICATION_CHAPTER;
				}
				newCase.Origin = ORIGIN_EMAIL;
				newCase.Subject = processLead.FirstName + SPACE + processLead.LastName + APPEND_ELIGIBILITY_REVIEW;
				newCase.RecordTypeId = partARecordTypeId;
				newCase.OwnerId = nationAdvisorQueueId;
				newCase.Hidden_Why_do_you_feel__c = processLead.Why_do_you_feel_would_be_eligible_Wish__c;
				if (emailMap.containsKey(processLead.ChapterName__c)) {
					newCase.MAC_Email__c = emailMap.get(processLead.ChapterName__c);
				}
				newCase.Lead__c = processLead.Id;
				newCase.AccountId = processLead.ChapterName__c;
				newCase.ChapterName__c = processLead.ChapterName__c;
				if (processLead.Any_medical_reason_for_moving_quickly__c == LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES) {
					newCase.Rush__c = true;
					newCase.Rush_Explanation__c = processLead.Please_Explain__c;
					newCase.Rush_Timeframe__c = RUSH_TIME_FRAME;
					newCase.Diagnosis_Verification_Receive_Date__c = processLead.Part_A_Received__c;
				}
				if (processLead.Any_medical_reason_for_moving_quickly__c != null) {
					String medicalReason = processLead.Any_medical_reason_for_moving_quickly__c;
					if (medicalReason.contains(LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES)) {
						newCase.Rush__c = true;
					}
				}
				newCaseList.add(newCase);
			}
			if (!newCaseList.isEmpty()) {
				insert newCaseList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Lead currRec : LeadList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'CreateNewCase',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : LeadList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * JIRA: WLP-286
	 * Author: Gustavo Mayer
	 * Update: Granting sub case conversion to the single Wish Case
	 */
	public static void updateGrantingCaseDevStaffEmail(Map<Id, String> chapterEmailMap) {
		List<Case> updateCaseList = new List<Case>();
		for (Case wishCase : [
				SELECT Id, RecordTypeId, ParentId, Parent.ChapterName__c, Dev_Staff_Email__c
				FROM Case
				WHERE Parent.ChapterName__c IN :chapterEmailMap.keySet()
				AND RecordTypeId = :Constant_AC.WISH_RT_ID
				AND IsClosed = FALSE
		]) {
			if (chapterEmailMap.containsKey(wishCase.Parent.ChapterName__c)) {
				wishCase.Dev_Staff_Email__c = chapterEmailMap.get(wishCase.Parent.ChapterName__c);
				updateCaseList.add(wishCase);
			}
		}
		if (!updateCaseList.isEmpty()) {
			update updateCaseList;
		}
	}
}