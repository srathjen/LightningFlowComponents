/**
 * @description Case Service, exposes methods for the Controller layer.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/20/2019
 */
public with sharing class CaseService {

	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
	private final static String CASE_QUALIFIED = Constant_AC.CASE_STATUS_QUALIFIED;
	private static final String CASE_ORIGIN_WEB = Constant_AC.CASE_ORIGIN_WEB;
	private static final String CASE_RUSH_TIME_FRAME = Constant_AC.CASE_RUSH_TIME_FRAME;
	private static final String CASE_UWI_SOURCE_LEAD = Constant_AC.CASE_UWI_SOURCE_LEAD;

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
	 *  Delete Case found by Lead Id and Record Type Name
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
	 * Set Contacts on DocuSign Status by Converted Lead Ids
	 * @param leadId
	 */
	public static Map<Id, Case> setDVReceiveDateConvertedLead(List<dsfs__DocuSign_Status__c> docuSignStatuses, Map<Id, Case> insertCaseMap) {
		for (dsfs__DocuSign_Status__c docuSignStatus : docuSignStatuses) {
			if (insertCaseMap.containsKey(docuSignStatus.dsfs__Lead__c) && docuSignStatus.dsfs__Completed_Date_Time__c != null) {
				Case caseConverted = new Case();
				caseConverted = insertCaseMap.get(docuSignStatus.dsfs__Lead__c);
				caseConverted.Diagnosis_Verification_Receive_Date__c = docuSignStatus.dsfs__Completed_Date_Time__c.date();
				insertCaseMap.put(docuSignStatus.dsfs__Lead__c, caseConverted);
			}
		}
		return insertCaseMap;
	}

	public static Case buildCaseForLeadConvert(Id contactId, Id leadId, Date qualifiedDate, Boolean isMigratedRecord,
			String qualifyingMedicalProfessionalName, String qualifyingMedicalProfessionalEmail, Id chapterId,
			String primaryDiagnosis, Id accountId, String firstName, String lastName,
			String whyDoYouFeelWouldBeEligibleWish, Boolean isRush, String pleaseExplain, Date referredDate,
			Date inquiryDate, Date partAReceived, Date partASent, Boolean outOfTerritory, String uniqueWishIdentifier,
			Boolean hasContactConverted, Id ownerId
	) {
		Case newCase = new Case();
		newCase.RecordTypeId = WISH_RECORD_TYPE_ID;
		newCase.ContactId = contactId;
		newCase.Hidden_Lead_Id__c = leadId;
		newCase.Qualified_Date__c = qualifiedDate;
		newCase.Migrated_Record__c = isMigratedRecord;
		newCase.Qualifying_Medical_Professional_Name__c = qualifyingMedicalProfessionalName;
		newCase.Qualifying_Medical_Professional_Email__c = qualifyingMedicalProfessionalEmail;
		newCase.AccountId = accountId;
		newCase.Status = CASE_QUALIFIED;
		newCase.Hidden_Why_do_you_feel__c = whyDoYouFeelWouldBeEligibleWish;
		newCase.Origin = CASE_ORIGIN_WEB;
		newCase.Diagnosis_Verification_Receive_Date__c = partAReceived;
		newCase.Diagnosis_Verification_Sent_Date__c = partASent;
		if (hasContactConverted) {
			newCase.ChapterName__c = chapterId;
			newCase.Hidden_Primary_Diagnosis__c = primaryDiagnosis;
		}
		if (ownerId != null) {
			newCase.OwnerId = ownerId;
		}
		if (firstName != null) {
			newCase.Subject = firstName + ' ' + lastName;
		} else {
			newCase.Subject = lastName;
		}
		if (isRush) {
			newCase.Rush__c = true;
			newCase.Rush_Explanation__c = pleaseExplain;
			newCase.Rush_Timeframe__c = CASE_RUSH_TIME_FRAME;
		} else {
			newCase.Rush__c = false;
		}
		if (referredDate != null) {
			newCase.Referral_Date__c = referredDate;
		}
		if (inquiryDate != null) {
			newCase.Inquiry_Date__c = inquiryDate;
		}
		if (outOfTerritory != null) {
			newCase.Out_of_Territory__c = outOfTerritory;
		}
		if (uniqueWishIdentifier != null) {
			newCase.Lead__c = leadId;
			newCase.Unique_Wish_Record_Identifier__c = uniqueWishIdentifier;
			newCase.Fund_Id__c = uniqueWishIdentifier;
			newCase.UWISource__c = CASE_UWI_SOURCE_LEAD;
			newCase.Wish_Assist__c = true;
		}
		return newCase;
	}

}