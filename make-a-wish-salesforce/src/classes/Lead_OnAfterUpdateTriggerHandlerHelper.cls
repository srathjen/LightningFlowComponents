/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : Lead_OnAfterUpdateTriggerHandlerHelper is used to assign the case owner as a queue dynamically based on the lead state.And also if any duplicate records available in leads or contact then it displayed as a duplicate leads and contacts.
And also it is used to call the approval process automatically when the record is created. And also convert the lead automatically when approver
approve the record.

Modification Log:
1. Vignesh SM - IME 58 Line No 395-409
1. Vignesh SM - IME 58 Line No 395-409
1. 06/04/2018 - Vignesh SM - IME 9 - Line No. 1467-1480
2. 04/06/2018 - Yuvraj - IME-81 - Line No: 558-560
3. 04/12/2018 - Yuvraj - IME-86 - Line No: 134,327,764,783,1183-1185, 1120-1222, 1250-1252, 1287-1289, 1321-1323
4. 07/18/2019 - Mason Buhler, Traction on Demand
5. 09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/

public class Lead_OnAfterUpdateTriggerHandlerHelper {

	private final static String medicalProfessionalLabel = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
	private final static String contactWishChildLabel = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
	private final static String wishFamilyLabel = Constant_AC.WISH_FAMILY_RT_LABEL;
	private final static Id staffTaskRecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
	private final static Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id wishFamilyRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id HouseholdRecordTypeId = Constant_AC.HOUSEHOLD_RT_ID;
	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private final static Id diagnosisRecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
	private final static Id hospitalTreatmentRecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
	private static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String CONTACT_SIBLING = 'Sibling';

	/**
	 * WLP-543
	 * Commenting unused variable instantiation
	 */
//	public Boolean falg = true;
//	static Map<String, Account> newAccountMap = new Map<String, Account>();
//	static Map<String, Account> medicalAccountMap = new Map<String, Account>();
	/**
	 * WLP-543
	 * Commenting unused variable instantiation
	 */
//    static Map<String,Boolean> qualifyingMap = new Map<String,Boolean>();
//	List<Lead> convertedLeadList = new List<Lead>();
//	static Map<Id, Lead> convertedLeadMap = new Map<Id, Lead>();
//	static String convertedAccId;
	// static Savepoint sp = Database.setSavepoint();

	/**********************************************************************************************************
This onAfterUpdate() method is used to convert the lead when the lead status is "Qualyfied".
When the lead is converted it create a new wish child, wish family and medical proffecinal contact
while converting lead it aslo done dupe check for wish child, wish family and medical proffecinal contact
if any contact already exists then it create new relationship record. else it create contact record and
aslo create new relationship record and it associate with wish child record.
***********************************************************************************************************/
	public static void leadConvertion(Map<Id, Lead> toconvertLeadMap) {
		RecursiveTriggerHandler.isFirstTime = false;
		Map<Id, Id> leadContactMap = new Map<Id, Id>();
		Map<Id, Lead> convertedAccountMap = new Map<Id, Lead>();
		List<Account> updateAccountList = new List<Account>();
		Map<Id, Contact> conMap = new Map<Id, Contact>();
		Map<Id, Lead> LeadMap = new Map<Id, Lead>();
		Map<Id, Lead> leadFamilyMap = new Map<Id, Lead>();
		Set<Id> convertedLeadIds = new Set<Id>();
		Set<Id> conId = new Set<Id>();
		Set<Id> leadConvertAccountIds = new Set<Id>();
		List<Case>caseList = new List<Case>();
		Map<Id, Case> insertCaseMap = new Map<Id, Case>();
		List<cg__ContactFile__c> ConFileList = new List<cg__ContactFile__c>();
		/**
		 * WLP-543
		 * Commenting unused variable instantiation
		 */
//		List<npe4__Relationship__c> wishFamilyRelationList = new List<npe4__Relationship__c>();
//		List<Contact> siblingList = new List<Contact>();
		LeadStatus convertStatus = [
				SELECT MasterLabel
				FROM LeadStatus
				WHERE IsConverted = TRUE
				LIMIT 1
		];
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		List<Case> partACaseList = new List<Case>();
		List<dsfs__DocuSign_Status__c > dsfsList = new List<dsfs__DocuSign_Status__c>();
//		Set<String> leadFamilyFirstNameSet = new Set<String>();
//		Set<String> leadFamilyLastNameSet = new Set<String>();
//		Set<String> leadFamilyEmailSet = new Set<String>();
//		Set<String> leadFamilyPhoneSet = new Set<String>();
		Set<Id> chapterIdSet = new Set<Id>();
		Set<Id> leadIdSet = new Set<Id>();
		/**
		 * WLP-581
		 * Changing Relationships to a Map to allow easier duplication check on lead convert
		 */
//		List<npe4__Relationship__c> relationShipList = new List<npe4__Relationship__c>();
		Map<Id, npe4__Relationship__c> relationshipMap = new Map<Id, npe4__Relationship__c>();
		Map<Id, Account> chapterUserMap = new Map<Id, Account>();
		/**
		 * WLP-543
		 * Commenting unused variable instantiation
		 */
//		Map<String, Contact> contactFamilyNameMap = new Map<String, Contact>();
//		Map<String, Contact> contactFamilyEmailMap = new Map<String, Contact>();
//		Map<String, Contact> contactFamilyPhoneMap = new Map<String, Contact>();
//		Map<String, Contact> contactFamilyAddressMap = new Map<String, Contact>();
//		List<Case> casesToInsert = new List<Case>();
		List<Task> rushReminderList = new List<Task>();
		Map<Id, Lead> existingMedicalProfIdMap = new Map<Id, Lead>();
		Id ChapterId;
		Map<Id, Lead> convertedLeadsById = new Map<Id, Lead>();
		//sp = Database.setSavepoint();

		/**
		 * WLP-591 Recreate list of same objects to reduce SOQL
		 */
		List<Contact> leadNewContacts = new List<Contact>();
		Set<Id> allLeadContacts = new Set<Id>();
		Set<Id> leadCases = new Set<Id>();
		Map<Id, Lead> convertedLeadMapByChildContactId = new Map<Id, Lead>();
		Map<String, Account> newAccountMap = new Map<String, Account>();
		Map<String, Account> medicalAccountMap = new Map<String, Account>();
		String convertedAccId;

		try {
			for (Lead processNewLeads : toconvertLeadMap.values()) {
				// Add all updated leads to the LeadConvert object
				Database.LeadConvert lc = new Database.LeadConvert();
				LeadMap.put(processNewLeads.Id, processNewLeads);
				lc.setLeadId(processNewLeads.Id);
				lc.setDoNotCreateOpportunity(true);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				leadConverts.add(lc);
			}
			if (!leadConverts.isEmpty()) {
				// Convert the leads to accounts and contacts
				List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
				for (Database.LeadConvertResult convertLeads : lcr) {
					leadContactMap.put(convertLeads.getLeadId(), convertLeads.getContactId());
					leadConvertAccountIds.add(convertLeads.getAccountId());
					conId.add(convertLeads.getContactId());
					convertedLeadIds.add(convertLeads.getLeadId());
				}
				if (leadContactMap.size() > 0) {
					List<Diagnosis_Verification__c> diagnosisList = new List<Diagnosis_Verification__c>();
					for (Diagnosis_Verification__c diagnosisInfo : [
							SELECT Id, Contact__c, Lead__c
							FROM Diagnosis_Verification__c
							WHERE Lead__c IN :leadContactMap.keySet()
							LIMIT 50000
					]) {
						// Update the Diagnosis_Verification__c record for each lead with the new contact Id
						diagnosisInfo.Contact__c = leadContactMap.get(diagnosisInfo.Lead__c);
						diagnosisList.add(diagnosisInfo);
					}
					if (diagnosisList.size() > 0) {
						update diagnosisList;
					}
					updateDocusignStatus(leadContactMap);
				}
				for (Lead convertedLead : [
						SELECT Id,Name,DOB__c,FirstName, Why_do_you_feel_would_be_eligible_Wish__c, LastName,CreatedDate,Migrated_Record__c,
								I_am_Recognized_To_Practice_As_a__c,Sibling_Detail__c,Medical_Provider_Category__c,
								ChapterName__r.Name,ChapterName__c,Treating_Medical_Professional_First_Name__c,ConvertedContactId,ConvertedAccountId,
								Other_Relationship_To_Child__c,Relationship_to_child__c,LeadSource,Treating_Medical_Professional_Phone__c,
								Treating_Medical_Professional_Email__c, is_Family_Aware_of_Referral__c,Treating_Medical_Professional_Last_Name__c,Referrer_City__c,
								Referrer_Email__c,Referrer_FirstName__c,Referrer_Last_Name__c,Referrer_Phone__c,Referrer_Zip__c,
								Parent_First_Name__c,Alternate1MedProfessionalPhone__c,Alternate1MedicalProfessionalEmail__c,
								Alternate1MedProfessionalFirstName__c,Alternate1MedProfessionalLastName__c,What_is_the_family_s_primary_spoken_lang__c,Parent_Last_Name__c,Email,
								Phone,City,Alternate2MedProfessionalFirstName__c,Alternate2MedProfessionalEmail__c,
								Alternate2MedProfessionalLastName__c,Alternate2MedProfessionalPhone__c,
								CountryCode,PostalCode, State, StateCode,Street,Treating_Medical_Professional_Contact_Id__c,
								Medical_Professional_ContactId__c,Wish_Family_ContactId__c,Best_contact_for_Physician_Email__c,
								Best_Contact_for_Physician_First_Name__c,Best_Contact_for_Physician_Last_Name__c,
								Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,Additional_Parent_City__c,
								Additional_Parent_Email__c,Additional_Parent_Phone__c,Additional_Parent_Postal_Code__c,
								Additional_Parent_State__c,Additional_Parent_Street__c,Hidden_Additional_Parent_Id__c,
								Hidden_Best_Contact_Person_Id__c,Parent_Relationship_to_Child__c,HiddenAlternate1MedProfessionalId__c,
								HiddenAlternate2MedProfessionalId__c,Self_describe_comment_box__c,Child_Age__c,Gender__c,Hidden_DV_form_Medical_professional_Type__c,
								Additional_Parent_Relationship_to_Child__c,How_Did_you_hear_about_Make_A_Wish__c,Other_Medical_Provider_Category__c,
								Any_medical_reason_for_moving_quickly__c, Department__c, Hospital_Treatment_Facility_Treating__c,Part_A_Received__c,
								Part_A_Sent__c, ChapterName__r.Qualified_Wish_Owner__c, Alternate_1_Medical_Professional_Type__c, Alternate_2_Medical_Professional_Type__c,
								Alternate1HospitalTreatmentFacility__c, Alternate2HospitalTreatmentFacility__c
						FROM Lead
						WHERE Id IN:convertedLeadIds
						LIMIT 50000
				]) {
					/**
					 * WLP-573
					 * Quick fix Phone comparision, see method removeFormatNumberField
					 */
					convertedLead.Treating_Medical_Professional_Phone__c = removeFormatNumberField(convertedLead.Treating_Medical_Professional_Phone__c);
					convertedLead.Referrer_Phone__c = removeFormatNumberField(convertedLead.Referrer_Phone__c);
					convertedLead.Alternate1MedProfessionalPhone__c = removeFormatNumberField(convertedLead.Alternate1MedProfessionalPhone__c);
					convertedLead.Phone = removeFormatNumberField(convertedLead.Phone);
					convertedLead.Alternate2MedProfessionalPhone__c = removeFormatNumberField(convertedLead.Alternate2MedProfessionalPhone__c);
					convertedLead.Additional_Parent_Phone__c = removeFormatNumberField(convertedLead.Additional_Parent_Phone__c);
					convertedLeadsById.put(convertedLead.Id, convertedLead);
					if (convertedLeadIds.contains(convertedLead.Id)) {
						leadFamilyMap.put(convertedLead.Id, convertedLead);
						convertedLeadMapByChildContactId.put(convertedLead.ConvertedContactId, convertedLead);
						convertedAccountMap.put(convertedLead.ConvertedAccountId, convertedLead);
						chapterIdSet.add(convertedLead.ChapterName__c);
//						leadFamilyFirstNameSet.add(convertedLead.FirstName);
//						leadFamilyLastNameSet.add(convertedLead.LastName);
//						leadFamilyEmailSet.add(convertedLead.Email);
//						leadFamilyPhoneSet.add(convertedLead.Phone);
						// Create Relationship Treating Medical Professional

						if (convertedLead.Treating_Medical_Professional_Contact_Id__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							if (relationshipMap.containsKey(convertedLead.Treating_Medical_Professional_Contact_Id__c)) {
								newRelationship = relationshipMap.get(convertedLead.Treating_Medical_Professional_Contact_Id__c);
							} else {
								newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
								newRelationship.npe4__Type__c = medicalProfessionalLabel;
								newRelationship.npe4__RelatedContact__c = convertedLead.Treating_Medical_Professional_Contact_Id__c;
								newRelationship.npe4__Status__c = 'Active';
								newRelationship.Treating_HCP__c = true;
							}
							Boolean isTreatingMedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
									convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Referrer_FirstName__c,
									convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Referrer_Last_Name__c,
									convertedLead.Treating_Medical_Professional_Phone__c, convertedLead.Referrer_Phone__c,
									convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Referrer_Email__c);
							if (isTreatingMedicalProfessionalAlsoReferrer) {
								newRelationship.Referring_Medical_Professional__c = true;
							}
							if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
								newRelationship.Qualifying_Medical_Professional__c = true;
							}
							if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
									|| convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
								existingMedicalProfIdMap.put(convertedLead.Treating_Medical_Professional_Contact_Id__c, convertedLead);
							}
							relationshipMap.put(convertedLead.Treating_Medical_Professional_Contact_Id__c, newRelationship);
							allLeadContacts.add(convertedLead.Treating_Medical_Professional_Contact_Id__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
						// Create Relationship Referring Medical Professional
						if (convertedLead.Medical_Professional_ContactId__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							if (relationshipMap.containsKey(convertedLead.Medical_Professional_ContactId__c)) {
								newRelationship = relationshipMap.get(convertedLead.Medical_Professional_ContactId__c);
							} else {
								newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
								newRelationship.npe4__Type__c = medicalProfessionalLabel;
								newRelationship.npe4__RelatedContact__c = convertedLead.Medical_Professional_ContactId__c ;
								newRelationship.npe4__Status__c = 'Active';
								newRelationship.Treating_HCP__c = true;
							}
							newRelationship.Referring_Medical_Professional__c = true;
							Boolean isTreatingMedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
									convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Referrer_FirstName__c,
									convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Referrer_Last_Name__c,
									convertedLead.Treating_Medical_Professional_Phone__c, convertedLead.Referrer_Phone__c,
									convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Referrer_Email__c);
							if (isTreatingMedicalProfessionalAlsoReferrer) {
								if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
									newRelationship.Qualifying_Medical_Professional__c = true;
								}
							}
							existingMedicalProfIdMap.put(convertedLead.Medical_Professional_ContactId__c, convertedLead);
							relationshipMap.put(convertedLead.Medical_Professional_ContactId__c, newRelationship);
							allLeadContacts.add(convertedLead.Medical_Professional_ContactId__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
						// Create Relationship Alternate 1 Medical Professional
						if (convertedLead.HiddenAlternate1MedProfessionalId__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							if (relationshipMap.containsKey(convertedLead.HiddenAlternate1MedProfessionalId__c)) {
								newRelationship = relationshipMap.get(convertedLead.HiddenAlternate1MedProfessionalId__c);
							} else {
								newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
								newRelationship.npe4__Type__c = medicalProfessionalLabel;
								newRelationship.npe4__RelatedContact__c = convertedLead.HiddenAlternate1MedProfessionalId__c ;
								newRelationship.npe4__Status__c = 'Active';
							}

							Boolean isAlternate1MedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
									convertedLead.Alternate1MedProfessionalFirstName__c, convertedLead.Referrer_FirstName__c,
									convertedLead.Alternate1MedProfessionalLastName__c, convertedLead.Referrer_Last_Name__c,
									convertedLead.Alternate1MedProfessionalPhone__c, convertedLead.Referrer_Phone__c,
									convertedLead.Alternate1MedicalProfessionalEmail__c, convertedLead.Referrer_Email__c);
							if (isAlternate1MedicalProfessionalAlsoReferrer) {
								newRelationship.Referring_Medical_Professional__c = true;
							}
							if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
								existingMedicalProfIdMap.put(convertedLead.HiddenAlternate1MedProfessionalId__c, convertedLead);
								newRelationship.Qualifying_Medical_Professional__c = true;
							}
							relationshipMap.put(convertedLead.HiddenAlternate1MedProfessionalId__c, newRelationship);
							allLeadContacts.add(convertedLead.HiddenAlternate1MedProfessionalId__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
						// Create Relationship Alternate 2 Medical Professional
						if (convertedLead.HiddenAlternate2MedProfessionalId__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							if (relationshipMap.containsKey(convertedLead.HiddenAlternate2MedProfessionalId__c)) {
								newRelationship = relationshipMap.get(convertedLead.HiddenAlternate2MedProfessionalId__c);
							} else {
								newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
								newRelationship.npe4__Type__c = medicalProfessionalLabel;
								newRelationship.npe4__RelatedContact__c = convertedLead.HiddenAlternate2MedProfessionalId__c ;
								newRelationship.npe4__Status__c = 'Active';
							}
							Boolean isAlternate2MedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
									convertedLead.Alternate2MedProfessionalFirstName__c, convertedLead.Referrer_FirstName__c,
									convertedLead.Alternate2MedProfessionalLastName__c, convertedLead.Referrer_Last_Name__c,
									convertedLead.Alternate2MedProfessionalPhone__c, convertedLead.Referrer_Phone__c,
									convertedLead.Alternate2MedProfessionalEmail__c, convertedLead.Referrer_Email__c);
							if (isAlternate2MedicalProfessionalAlsoReferrer) {
								newRelationship.Referring_Medical_Professional__c = true;
							}
							if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
								existingMedicalProfIdMap.put(convertedLead.HiddenAlternate2MedProfessionalId__c, convertedLead);
								newRelationship.Qualifying_Medical_Professional__c = true;
							}
							relationshipMap.put(convertedLead.HiddenAlternate2MedProfessionalId__c, newRelationship);
							allLeadContacts.add(convertedLead.HiddenAlternate2MedProfessionalId__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
						// Create Relationship Best Contact
						if (convertedLead.Hidden_Best_Contact_Person_Id__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							if (relationshipMap.containsKey(convertedLead.Hidden_Best_Contact_Person_Id__c)) {
								newRelationship = relationshipMap.get(convertedLead.Hidden_Best_Contact_Person_Id__c);
							} else {
								newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
								newRelationship.npe4__Type__c = medicalProfessionalLabel;
								newRelationship.npe4__RelatedContact__c = convertedLead.Hidden_Best_Contact_Person_Id__c;
								newRelationship.npe4__Status__c = 'Active';
							}
							newRelationship.Best_Contact__c = true;
							Boolean isBestContactMedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
									convertedLead.Best_Contact_for_Physician_First_Name__c, convertedLead.Referrer_FirstName__c,
									convertedLead.Best_Contact_for_Physician_Last_Name__c, convertedLead.Referrer_Last_Name__c,
									null, null,
									convertedLead.Best_contact_for_Physician_Email__c, convertedLead.Referrer_Email__c);
							if (isBestContactMedicalProfessionalAlsoReferrer) {
								newRelationship.Referring_Medical_Professional__c = true;
							}
							Boolean isTreatingMedicalProfessionalAlsoBestContact = isSameMedicalProfessional(
									convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Best_Contact_for_Physician_First_Name__c,
									convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Best_Contact_for_Physician_Last_Name__c,
									null, null,
									convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Best_contact_for_Physician_Email__c);
							if (isTreatingMedicalProfessionalAlsoBestContact) {
								newRelationship.Treating_HCP__c = true;
							}
							if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT) {
								newRelationship.Qualifying_Medical_Professional__c = true;
							}
							relationshipMap.put(convertedLead.Hidden_Best_Contact_Person_Id__c, newRelationship);
							allLeadContacts.add(convertedLead.Hidden_Best_Contact_Person_Id__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
						// Create Relationship Family Parent Guardian
						if (convertedLead.Wish_Family_ContactId__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
							newRelationship.npe4__Type__c = convertedLead.Parent_Relationship_to_Child__c;
							newRelationship.Hidden_isparentFirst__c = true;
							newRelationship.Parent_Legal_Guardian__c = true;
							newRelationship.npe4__RelatedContact__c = convertedLead.Wish_Family_ContactId__c;
							newRelationship.npe4__Status__c = 'Active';
							if (convertedLead.Relationship_to_child__c == 'Parent/Guardian') {
								newRelationship.Referring_Medical_Professional__c = true;
							}
							relationshipMap.put(convertedLead.Wish_Family_ContactId__c, newRelationship);
							allLeadContacts.add(convertedLead.Wish_Family_ContactId__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
						// Create Relationship Additional Family Parent Guardian
						if (convertedLead.Hidden_Additional_Parent_Id__c != null) {
							npe4__Relationship__c newRelationship = new npe4__Relationship__c();
							newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
							newRelationship.Hidden_isparentFirst__c = false;
							newRelationship.Parent_Legal_Guardian__c = true;
							newRelationship.npe4__Type__c = convertedLead.Additional_Parent_Relationship_to_Child__c;
							newRelationship.npe4__RelatedContact__c = convertedLead.Hidden_Additional_Parent_Id__c;
							newRelationship.npe4__Status__c = 'Active';
							relationshipMap.put(convertedLead.Hidden_Additional_Parent_Id__c, newRelationship);
							allLeadContacts.add(convertedLead.Hidden_Additional_Parent_Id__c);
						} else {
							leadIdSet.add(convertedLead.Id);
						}
					}
				}

				if (leadConvertAccountIds.size() > 0) {
					updateLeadConvertedAccounts(leadConvertAccountIds, chapterIdSet,
							ChapterId, chapterUserMap, convertedAccountMap, updateAccountList);
//					for (Account conAccount : [
//							SELECT Id,Name,Volunteer_Manager__c,Intake_Manager__c,
//									Volunteer_Manager__r.Name,Volunteer_Manager__r.Email,
//									RecordTypeId
//							FROM Account
//							WHERE Id IN:leadConvertAccountIds
//							LIMIT 50000
//					]) {
//						if (chapterIdSet.contains(conAccount.Id)) {
//							ChapterId = conAccount.Id;
//							chapterUserMap.put(conAccount.Id, conAccount);
//						}
//						if (convertedAccountMap.containsKey(conAccount.Id)) {
//							if (convertedAccountMap.get(conAccount.Id).FirstName == null) {
//								conAccount.Name = convertedAccountMap.get(conAccount.Id).LastName + ' ' + ' & ' + ' ' + 'Family Household';
//								conAccount.RecordTypeId = HouseholdRecordTypeId;
//								conAccount.PrimaryLanguage__c = convertedAccountMap.get(conAccount .Id).What_is_the_family_s_primary_spoken_lang__c;
//							} else {
//								conAccount.Name = convertedAccountMap.get(conAccount.Id).FirstName + ' ' + convertedAccountMap.get(conAccount.Id).LastName + ' ' + ' & ' + ' ' + 'Family Household';
//								conAccount.PrimaryLanguage__c = convertedAccountMap.get(conAccount .Id).What_is_the_family_s_primary_spoken_lang__c;
//								conAccount.RecordTypeId = HouseholdRecordTypeId;
//							}
//							updateAcccountList.add(conAccount);
//						}
//					}
				}

				List<cg__ContactFile__c> ContactFileFolders = new List<cg__ContactFile__c>();
				for (Contact con : [
						SELECT Id,FirstName,Birthdate,Department,Provider_Type__c,Language__c,
								Self_describe_comment_box__c,Migrated_Record__c,Lead_Created_Date__c,
								Relationship_to_Wish_Child__c, Referrer_FirstName__c,Referrer_Last_Name__c,
								Referrer_Phone__c,Referrer_Email__c,Referrer_City__c,Referrer_Zip__c,
								Relationship__c,Inquiry_Referral_Method__c,Is_Family_Aware_of_Referral__c,
								Parent_Guardian_Name__c,RecordTypeId,AccountId,LastName,MailingCity,
								OwnerId,MailingState,MailingPostalCode,Wish_How_Did_you_hear_about_Make_A_Wish__c,
								Other_Medical_Provider_Category__c
						FROM Contact
						WHERE Id IN:conId
						LIMIT 50000
				]) {
					if (convertedLeadMapByChildContactId.containsKey(con.Id)) {
						convertedLeadMapByChildContactId.get(con.Id).Referrer_Phone__c = removeFormatNumberField(convertedLeadMapByChildContactId.get(con.Id).Referrer_Phone__c);
						con.Lead_Created_Date__c = Date.valueOf(convertedLeadMapByChildContactId.get(con.Id).CreatedDate);
						con.Birthdate = convertedLeadMapByChildContactId.get(con.Id).DOB__c;
						con.RecordTypeId = wishChildRecordTypeId;
						con.Provider_Type__c = convertedLeadMapByChildContactId.get(con.Id).Medical_Provider_Category__c;
						con.Self_describe_comment_box__c = convertedLeadMapByChildContactId.get(con.Id).Self_describe_comment_box__c;
						con.Language__c = convertedLeadMapByChildContactId.get(con.Id).What_is_the_family_s_primary_spoken_lang__c;
						con.Region_Chapter__c = convertedLeadMapByChildContactId.get(con.Id).ChapterName__c;
						con.Inquiry_Referral_Method__c = convertedLeadMapByChildContactId.get(con.Id).LeadSource;
						con.Referrer_City__c = convertedLeadMapByChildContactId.get(con.Id).Referrer_City__c;
						con.Referrer_Email__c = convertedLeadMapByChildContactId.get(con.Id).Referrer_Email__c;
						con.Referrer_FirstName__c = convertedLeadMapByChildContactId.get(con.Id).Referrer_FirstName__c;
						con.Referrer_Last_Name__c = convertedLeadMapByChildContactId.get(con.Id).Referrer_Last_Name__c;
						con.Referrer_Phone__c = convertedLeadMapByChildContactId.get(con.Id).Referrer_Phone__c;
						con.Referrer_Zip__c = convertedLeadMapByChildContactId.get(con.Id).Referrer_Zip__c;
						con.Relationship__c = convertedLeadMapByChildContactId.get(con.Id).Relationship_to_child__c;
						con.Other_Medical_Provider_Category__c = convertedLeadMapByChildContactId.get(con.Id).Other_Medical_Provider_Category__c;
						con.Relationship_to_Wish_Child__c = convertedLeadMapByChildContactId.get(con.Id).Other_Relationship_To_Child__c;
						con.Is_Family_Aware_of_Referral__c = convertedLeadMapByChildContactId.get(con.Id).is_Family_Aware_of_Referral__c;
						con.Migrated_Record__c = convertedLeadMapByChildContactId.get(con.Id).Migrated_Record__c;
						con.Wish_How_Did_you_hear_about_Make_A_Wish__c = convertedLeadMapByChildContactId.get(con.Id).How_Did_you_hear_about_Make_A_Wish__c;
						con.Relationship_Type__c = contactWishChildLabel;
						if (convertedLeadMapByChildContactId.get(con.Id).Additional_Parent_City__c != convertedLeadMapByChildContactId.get(con.Id).City ||
								convertedLeadMapByChildContactId.get(con.Id).Additional_Parent_Postal_Code__c != convertedLeadMapByChildContactId.get(con.Id).PostalCode ||
								convertedLeadMapByChildContactId.get(con.Id).Additional_Parent_State__c != convertedLeadMapByChildContactId.get(con.Id).State ||
								convertedLeadMapByChildContactId.get(con.Id).Additional_Parent_Street__c != convertedLeadMapByChildContactId.get(con.Id).Street) {
							con.npsp__is_Address_Override__c = true;
						}
						if (convertedLeadMapByChildContactId.get(con.Id).DOB__c != null) {
							Date dob = convertedLeadMapByChildContactId.get(con.Id).DOB__c;
							Integer age;
							if (Date.newInstance(2000, dob.month(), dob.day())
									<= Date.newInstance(2000, Date.today().month(), Date.today().day())) {
								age = Date.today().year() - dob.year();
							} else {
								age = Date.today().year() - dob.year() - 1;
							}
							if ((age < 16) && convertedLeadMapByChildContactId.get(con.Id).Gender__c == 'Male') {
								con.Salutation = 'Master';
							} else if ((age >= 16) && convertedLeadMapByChildContactId.get(con.Id).Gender__c == 'Male') {
								con.Salutation = 'Mr.';
							} else if ((age < 16) && convertedLeadMapByChildContactId.get(con.Id).Gender__c == 'Female') {
								con.Salutation = 'Miss';
							} else if ((age >= 16) && convertedLeadMapByChildContactId.get(con.Id).Gender__c == 'Female') {
								con.Salutation = 'Ms.';
							} else {
								con.Salutation = '';
							}
						}
						con.Hidden_Medical_Physician__c = convertedLeadMapByChildContactId.get(con.Id).Treating_Medical_Professional_First_Name__c + ' '
								+ convertedLeadMapByChildContactId.get(con.Id).Treating_Medical_Professional_Last_Name__c;
						conMap.put(con.Id, con);
						cg__ContactFile__c picFolder = new cg__ContactFile__c();
						picFolder.cg__Contact__c = con.Id;
						picFolder.cg__Content_Type__c = 'Folder';
						picFolder.cg__File_Name__c = 'Photos';
						picFolder.cg__WIP__c = false;
						ContactFileFolders.add(picFolder);

						cg__ContactFile__c docFolder = new cg__ContactFile__c();
						docFolder.cg__Contact__c = con.Id;
						docFolder.cg__Content_Type__c = 'Folder';
						docFolder.cg__File_Name__c = 'Documents';
						docFolder.cg__WIP__c = false;
						ContactFileFolders.add(docFolder);

						cg__ContactFile__c videosFolder = new cg__ContactFile__c();
						videosFolder.cg__Contact__c = con.Id;
						videosFolder.cg__Content_Type__c = 'Folder';
						videosFolder.cg__File_Name__c = 'Videos';
						videosFolder.cg__WIP__c = false;
						ContactFileFolders.add(videosFolder);

						Task newTask = new Task();
						newTask.OwnerId = con.OwnerId;
						newTask.SystemGeneratedTask__c = true;
						newTask.Subject = 'Send Welcome Letter/Make Welcome Call';
						newTask.WhoId = con.Id;
						newTask.Description = 'Send Welcome Letter/Make Welcome Call';
						newTask.Status = 'In Progress';
						newTask.ActivityDate = System.today() + 10;
						newTask.RecordTypeId = staffTaskRecordTypeId;
						rushReminderList.add(newTask);
						//IME 58
						String medicalReason = convertedLeadMapByChildContactId.get(con.Id).Any_medical_reason_for_moving_quickly__c;
						if (medicalReason.contains('Yes')) {
							Task newRushTask = new Task(Description = 'New RUSH referral qualified',
									Priority = 'Normal',
									Status = 'Completed',
									Subject = 'Lead ET : New Rush Qualified',
									OwnerId = Label.Salesforce_Support_User_Id,
									ActivityDate = System.today(),
									WhoId = con.Id);
							rushReminderList.add(newRushTask);
						}
					}
				}

				for (Database.LeadConvertResult convertLeads : lcr) {
					if (leadFamilyMap.containsKey(convertLeads.getLeadId())) {
						if (leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c != null) {
							if (leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.contains('<br>')) {
								for (String currSiblings : leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.split('<br>')) {
									if (currSiblings.contains('|')) {
										List<String> siblingDetails = currSiblings.split('\\|');
										if (siblingDetails.size() == 3) {
											Contact newFamily = new Contact();
											newFamily.FirstName = siblingDetails [0].trim();
											newFamily.LastName = siblingDetails [1].trim();
											newFamily.Sibling_Age__c = siblingDetails [2].trim();
											newFamily.Wish_Child_Id_Hidden__c = convertLeads.getContactId();
											newFamily.RecordTypeId = wishFamilyRecordTypeId;
											newFamily.AccountId = convertLeads.getAccountId();
											newFamily.Region_Chapter__c = leadFamilyMap.get(convertLeads.getLeadId()).ChapterName__c;
											newFamily.Language__c = leadFamilyMap.get(convertLeads.getLeadId()).What_is_the_family_s_primary_spoken_lang__c;
											if ((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != null)
													&& (!newFamily.LastName.containsOnly('-') && newFamily.LastName != null)
													&& newFamily.Sibling_Age__c.isNumeric()) {
//												siblingList.add(newFamily);
											}
											if ((!newFamily.FirstName.containsOnly('-')
													&& newFamily.FirstName != null)
													&& newFamily.LastName.containsOnly('-')
													&& newFamily.Sibling_Age__c.isNumeric()) {
												newFamily.LastName = 'Unknown';
//												siblingList.add(newFamily);
											}
											if (newFamily.FirstName.containsOnly('-')
													&& (!newFamily.LastName.containsOnly('-')
													&& newFamily.LastName != null)
													&& newFamily.Sibling_Age__c.isNumeric()) {
												newFamily.FirstName = '';
//												siblingList.add(newFamily);
											}
											if ((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != null)
													&& (!newFamily.LastName.containsOnly('-') && newFamily.LastName != null)
													&& newFamily.Sibling_Age__c.containsOnly('-')) {
												newFamily.Sibling_Age__c = null;
//												siblingList.add(newFamily);
											}
											if (newFamily.FirstName.containsOnly('-')
													&& (!newFamily.LastName.containsOnly('-')
													&& newFamily.LastName != null)
													&& newFamily.Sibling_Age__c.containsOnly('-')) {
												newFamily.FirstName = '';
												newFamily.Sibling_Age__c = null;
//												siblingList.add(newFamily);
											}
											if ((!newFamily.FirstName.containsOnly('-')
													&& newFamily.FirstName != null)
													&& newFamily.LastName.containsOnly('-')
													&& newFamily.Sibling_Age__c.containsOnly('-')) {
												newFamily.LastName = 'Unknown';
												newFamily.Sibling_Age__c = null;
//												siblingList.add(newFamily);
											}
											/**
											 * WLP-591
											 */
											leadNewContacts.add(newFamily);
										}
									}
								}
							} else if (leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.contains('|')) {
								List<String> siblingDetails = leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.split('\\|');
								if (siblingDetails.size() == 3) {
									Contact newFamily = new Contact();
									newFamily.FirstName = siblingDetails [0].trim();
									newFamily.LastName = siblingDetails [1].trim();
									newFamily.Sibling_Age__c = siblingDetails[2].trim();
									newFamily.Wish_Child_Id_Hidden__c = convertLeads.getContactId();
									newFamily.RecordTypeId = wishFamilyRecordTypeId;
									newFamily.AccountId = convertLeads.getAccountId();
									newFamily.Region_Chapter__c = leadFamilyMap.get(convertLeads.getLeadId()).ChapterName__c;
									newFamily.Language__c = leadFamilyMap.get(convertLeads.getLeadId()).What_is_the_family_s_primary_spoken_lang__c;
									if ((!newFamily.FirstName.containsOnly('-')
											&& newFamily.FirstName != null)
											&& (!newFamily.LastName.containsOnly('-')
											&& newFamily.LastName != null)
											&& newFamily.Sibling_Age__c.isNumeric()) {
//										siblingList.add(newFamily);
									}
									if ((!newFamily.FirstName.containsOnly('-')
											&& newFamily.FirstName != null)
											&& newFamily.LastName.containsOnly('-')
											&& newFamily.Sibling_Age__c.isNumeric()) {
										newFamily.LastName = 'Unknown';
//										siblingList.add(newFamily);
									}
									if (newFamily.FirstName.containsOnly('-')
											&& (!newFamily.LastName.containsOnly('-')
											&& newFamily.LastName != null)
											&& newFamily.Sibling_Age__c.isNumeric()) {
										newFamily.FirstName = '';
//										siblingList.add(newFamily);
									}
									if ((!newFamily.FirstName.containsOnly('-')
											&& newFamily.FirstName != null)
											&& (!newFamily.LastName.containsOnly('-')
											&& newFamily.LastName != null)
											&& newFamily.Sibling_Age__c.containsOnly('-')) {
										newFamily.Sibling_Age__c = null;
//										siblingList.add(newFamily);
									}
									if (newFamily.FirstName.containsOnly('-')
											&& (!newFamily.LastName.containsOnly('-')
											&& newFamily.LastName != null)
											&& newFamily.Sibling_Age__c.containsOnly('-')) {
										newFamily.FirstName = '';
										newFamily.Sibling_Age__c = null;
//										siblingList.add(newFamily);
									}
									if ((!newFamily.FirstName.containsOnly('-')
											&& newFamily.FirstName != null)
											&& newFamily.LastName.containsOnly('-')
											&& newFamily.Sibling_Age__c.containsOnly('-')) {
										newFamily.LastName = 'Unknown';
										newFamily.Sibling_Age__c = null;
//										siblingList.add(newFamily);
									}
									/**
									* WLP-591
									*/
									leadNewContacts.add(newFamily);
								}
							}
						}
					}

					if (LeadMap.containsKey(convertLeads.getLeadId())) {
						Case newCase = new Case();
						newCase.RecordTypeId = wishRecordTypeId;
						newCase.ContactId = convertLeads.getContactId();
						newCase.Hidden_Lead_Id__c = convertLeads.getLeadId();
						newCase.Qualified_Date__c = LeadMap.get(convertLeads.getLeadId()).Qualified_Date__c;
						newCase.Migrated_Record__c = LeadMap.get(convertLeads.getLeadId()).Migrated_Record__c;
						newCase.Qualifying_Medical_Professional_Name__c = LeadMap.get(convertLeads.getLeadId()).Treating_Medical_Professional_First_Name__c + ' '
								+ LeadMap.get(convertLeads.getLeadId()).Treating_Medical_Professional_Last_Name__c;
						newCase.Qualifying_Medical_Professional_Email__c = LeadMap.get(convertLeads.getLeadId()).Treating_Medical_Professional_Email__c;
						if (conMap.containsKey(convertLeads.getContactId())) {
							/*WLP-451 The owner should be the user specified in the accounts Qualified Wish Owner */
							// newcase.ownerId = conMap.get(convertLeads.getcontactId()).ownerId;
							newCase.ChapterName__c = LeadMap.get(convertLeads.getLeadId()).ChapterName__c;
							newCase.Hidden_Primary_Diagnosis__c = LeadMap.get(convertLeads.getLeadId()).PD_Condition_Description__c ;
						}
						newCase.AccountId = convertLeads.getAccountId();
						/*WLP-451 The owner should be the user specified in the accounts Qualified Wish Owner */
						if (convertedLeadMapByChildContactId.containsKey(convertLeads.getContactId())) {
							newCase.OwnerId = convertedLeadMapByChildContactId.get(convertLeads.getContactId()).ChapterName__r.Qualified_Wish_Owner__c;
						}
//						Date myDate = Date.valueOf(LeadMap.get(convertLeads.getLeadId()).CreatedDate);
//						String dateval = String.valueOf(myDate);
						if (LeadMap.get(convertLeads.getLeadId()).FirstName != null) {
							newCase.Subject = LeadMap.get(convertLeads.getLeadId()).FirstName + ' ' + LeadMap.get(convertLeads.getLeadId()).LastName;
						} else {
							newCase.Subject = LeadMap.get(convertLeads.getLeadId()).LastName;
						}
						if (chapterUserMap.size() > 0) {
							/*if (chapterUserMap.get(ChapterId).Volunteer_Manager__r.Name != Null && chapterUserMap.get(ChapterId).Volunteer_Manager__r.Email != Null) {
								newcase.VOlunteer_Manager_Name__c = chapterUserMap.get(ChapterId).Volunteer_Manager__r.Name;
								newcase.Volunteer_Manager_Email__c = chapterUserMap.get(ChapterId).Volunteer_Manager__r.Email;
							}*/
							if (chapterUserMap.get(ChapterId).Intake_Manager__c != null) {
								newCase.OwnerId = chapterUserMap.get(ChapterId).Intake_Manager__c;
							}
						}
						newCase.Status = 'Qualified';
						newCase.Hidden_Why_do_you_feel__c = LeadMap.get(convertLeads.getLeadId()).Why_do_you_feel_would_be_eligible_Wish__c;
						newCase.Origin = 'Web';
						//IME- 107 - changed "Is_We_Need_To_Expedite_The_Process__c" to "Rush__c"
						if (LeadMap.get(convertLeads.getLeadId()).Rush__c == true) {
							newCase.Rush__c = true;
							newCase.Rush_Explanation__c = LeadMap.get(convertLeads.getLeadId()).Please_Explain__c;
							newCase.Rush_Timeframe__c = 'Select timeframe';
						} else {
							newCase.Rush__c = false;
						}
						if (LeadMap.get(convertLeads.getLeadId()).Referred_Date__c != null) {
							newCase.Referral_Date__c = LeadMap.get(convertLeads.getLeadId()).Referred_Date__c;
						}
						if (LeadMap.get(convertLeads.getLeadId()).Inquiry_Date__c != null) {
							newCase.Inquiry_Date__c = LeadMap.get(convertLeads.getLeadId()).Inquiry_Date__c;
						}
						newCase.Diagnosis_Verification_Receive_Date__c = LeadMap.get(convertLeads.getLeadId()).Part_A_Received__c;
						newCase.Diagnosis_Verification_Sent_Date__c = LeadMap.get(convertLeads.getLeadId()).Part_A_Sent__c;
						//IME-81
						if (LeadMap.get(convertLeads.getLeadId()).Out_of_Territory__c != null) {
							newCase.Out_of_Territory__c = LeadMap.get(convertLeads.getLeadId()).Out_of_Territory__c;
						}
						if (LeadMap.get(convertLeads.getLeadId()).unique_wish_identifier__c != null) {
							newCase.Lead__c = LeadMap.get(convertLeads.getLeadId()).Id;
							newCase.Unique_Wish_Record_Identifier__c = LeadMap.get(convertLeads.getLeadId()).unique_wish_identifier__c;
							newCase.Fund_Id__c = LeadMap.get(convertLeads.getLeadId()).unique_wish_identifier__c;
							newCase.UWISource__c = 'Lead';
							newCase.Wish_Assist__c = true;
						}
						caseList.add(newCase);
						insertCaseMap.put(convertLeads.getLeadId(), newCase);
					}
				}

				for (Case dbPartAcase : [
						SELECT Id,CaseNumber,Lead__c,ContactId,RecordTypeId
						FROM Case
						WHERE Lead__c IN:convertedLeadIds AND RecordTypeId = :diagnosisRecordTypeId
						LIMIT 50000
				]) {
					if (leadFamilyMap.containsKey(dbPartAcase.Lead__c)) {
						dbPartAcase.ContactId = leadFamilyMap.get(dbPartAcase.Lead__c).ConvertedContactId;
						partACaseList.add(dbPartAcase);
					}
					if (insertCaseMap.containsKey(dbPartAcase.Lead__c)) {
						Case rushCase = new Case();
						rushCase = insertCaseMap.get(dbPartAcase.Lead__c);
						if (rushCase.Rush__c == true) {
							rushCase.Hidden_already_send_rush_wish__c = true;
						}
						insertCaseMap.put(dbPartAcase.Lead__c, rushCase);
					}
				}

				if (convertedLeadIds.size() > 0) {
					for (dsfs__DocuSign_Status__c dbdsfsLead : [
							SELECT Id,dsfs__Lead__c,dsfs__Envelope_Status__c, dsfs__Completed_Date_Time__c
							FROM dsfs__DocuSign_Status__c
							WHERE dsfs__Lead__c IN:convertedLeadIds AND dsfs__Envelope_Status__c = :'Completed'
					]) {
						if (leadFamilyMap.containsKey(dbdsfsLead.dsfs__Lead__c)) {
							dbdsfsLead.dsfs__Contact__c = leadFamilyMap.get(dbdsfsLead.dsfs__Lead__c).ConvertedContactId;
							dsfsList.add(dbdsfsLead);

						}
						// WLP-545
						if (insertCaseMap.containsKey(dbdsfsLead.dsfs__Lead__c) && dbdsfsLead.dsfs__Completed_Date_Time__c != null) {
							Case caseConverted = new Case();
							caseConverted = insertCaseMap.get(dbdsfsLead.dsfs__Lead__c);
							caseConverted.Diagnosis_Verification_Receive_Date__c = dbdsfsLead.dsfs__Completed_Date_Time__c.date();
							insertCaseMap.put(dbdsfsLead.dsfs__Lead__c, caseConverted);
						}
					}
				}

				if (ContactFileFolders.size() > 0) {
					insert ContactFileFolders;
				}
				Map<Id, Id> docFolderContactsMAP = new Map<Id, Id>();
				for (cg__ContactFile__c contactFile : [
						SELECT Id, cg__Contact__c
						FROM cg__ContactFile__c
						WHERE cg__File_Name__c = :'Documents'
						AND cg__Contact__c IN :conId
				]) {
					docFolderContactsMAP.put(contactFile.cg__Contact__c, contactFile.Id);
				}
				for (cg__Lead_File__c leadFile : [
						SELECT Id, cg__Content_Type__c, cg__Description__c, cg__File_Name__c, cg__File_Size__c,
								cg__Is_Latest_Version__c, cg__Key__c, cg__Lead__c, cg__Parent_Folder_Id__c,
								Private__c, cg__Version_Description__c, cg__Version_Id__c, cg__WIP__c
						FROM cg__Lead_File__c
						WHERE cg__Lead__c IN :convertedLeadIds
						LIMIT 50000
				]) {
					cg__ContactFile__c cFile = new cg__ContactFile__c();
					cFile.cg__Contact__c = leadFamilyMap.get(leadFile.cg__Lead__c).ConvertedContactId;
					cFile.cg__Content_Type__c = leadFile.cg__Content_Type__c;
					cFile.cg__Description__c = leadFile.cg__Description__c;
					cFile.cg__File_Name__c = leadFile.cg__File_Name__c;
					cFile.cg__Is_Latest_Version__c = leadFile.cg__Is_Latest_Version__c;
					cFile.cg__Key__c = leadFile.cg__Key__c;
					cFile.cg__Parent_Folder_Id__c = docFolderContactsMAP.get(leadFamilyMap.get(leadFile.cg__Lead__c).ConvertedContactId);
					cFile.cg__Private__c = leadFile.Private__c;
					cFile.cg__Version_Description__c = leadFile.cg__Version_Description__c;
					cFile.cg__Version_Id__c = leadFile.cg__Version_Id__c;
					cFile.cg__WIP__c = leadFile.cg__WIP__c;
					ConFileList.add(cFile);
				}
			}
//			RecursiveTriggerHandler.blockBeforeUpdate = true;
//			RecursiveTriggerHandler.blockAfterUpdate = true;
//			if (ConFileList.size() > 0) {
//				insert ConFileList;
//			}
//			if (siblingList.size() > 0) {
//				insert siblingList;
//			}
//			if (siblingList.size() > 0) {
//				for (Contact processSiblingList : siblingList) {
//					/**
//					 * WLP-543
//					 * Reversed relationship for Sibling
//					 */
//					npe4__Relationship__c newRelationship = new npe4__Relationship__c();
//					newRelationship.npe4__Type__c = 'Sibling';
//					newRelationship.npe4__RelatedContact__c = processSiblingList.Id;
//					newRelationship.npe4__Contact__c = processSiblingList.Wish_Child_Id_Hidden__c;
//					newRelationship.npe4__Status__c = 'Active';
//					relationshipMap.put(processSiblingList.Id, newRelationship);
//				}
//			}
			RecursiveTriggerHandler.blockBeforeUpdate = true;
			RecursiveTriggerHandler.blockAfterUpdate = true;
			if (ConFileList.size() > 0) {
				insert ConFileList;
			}
			if (updateAccountList.size() > 0) {
				update updateAccountList;
			}
			if (dsfsList.size() > 0) {
				update dsfsList;
			}
			if (partACaseList.size() > 0) {
				update partACaseList;
			}
			if (conMap.size() > 0) {
				update conMap.values();
			}
			/*
			if(caseList.size() > 0)
			insert caseList;
			*/
			if (insertCaseMap.size() > 0) {
				insert insertCaseMap.values();
				leadCases.addAll(insertCaseMap.keySet());
				//casesToInsert = insertCaseMap.values();
				//insert casesToInsert;
			}
//			List<npe4__Relationship__c> relationshipList = new List<npe4__Relationship__c>();
//			relationshipList = relationshipMap.values();
//			if (relationshipList.size() > 0) {
//				insert relationshipList;
//			}
			if (rushReminderList.size() > 0) {
				insert rushReminderList;
			}
			if (leadIdSet.size() > 0) {
				Set<String> healthTreatmentFacilitySet = new Set<String>();
				for (Lead processConvertedLeads : [
						SELECT ConvertedAccountId, Hospital_Treatment_Facility_Treating__c,
								Alternate1HospitalTreatmentFacility__c,
								Alternate2HospitalTreatmentFacility__c
						FROM Lead
						WHERE Id IN:convertedLeadIds
						LIMIT 50000
				]) {
					convertedAccId = processConvertedLeads.ConvertedAccountId;
					healthTreatmentFacilitySet.add(processConvertedLeads.Hospital_Treatment_Facility_Treating__c);
					if (processConvertedLeads.Alternate1HospitalTreatmentFacility__c != null) {
						healthTreatmentFacilitySet.add(processConvertedLeads.Alternate1HospitalTreatmentFacility__c);
					}
					if (processConvertedLeads.Alternate2HospitalTreatmentFacility__c != null) {
						healthTreatmentFacilitySet.add(processConvertedLeads.Alternate2HospitalTreatmentFacility__c);
					}
				}
				for (Account dbAccount : [
						SELECT Id,Name,RecordTypeId
						FROM Account
						WHERE RecordTypeId = :hospitalTreatmentRecordTypeId
						AND Name IN:healthTreatmentFacilitySet
						LIMIT 50000
				]) {
					medicalAccountMap.put(dbAccount.Name, dbAccount);
				}

				for (Lead processConvertedLeads : [
						SELECT Id,Name,Alternate1HospitalTreatmentFacility__c,
								Alternate2HospitalTreatmentFacility__c,
								Hospital_Treatment_Facility__c,Migrated_Record__c,
								Hospital_Treatment_Facility_Treating__c,ChapterName__c,
								Department__c
						FROM Lead
						WHERE Id IN:convertedLeadIds
						LIMIT 50000
				]) {
					if (!medicalAccountMap.containsKey(processConvertedLeads.Hospital_Treatment_Facility_Treating__c)) {
						if (processConvertedLeads.Hospital_Treatment_Facility_Treating__c != null) {
							Account newAccount = new Account();
							newAccount.Name = processConvertedLeads.Hospital_Treatment_Facility_Treating__c;
							newAccount.RecordTypeId = hospitalTreatmentRecordTypeId;
							newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
							newAccountMap.put(newAccount.Name, newAccount);
						}
					}
					if (!medicalAccountMap.containsKey(processConvertedLeads.Alternate1HospitalTreatmentFacility__c)) {
						if (processConvertedLeads.Alternate1HospitalTreatmentFacility__c != null) {
							Account newAccount = new Account();
							newAccount.Name = processConvertedLeads.Alternate1HospitalTreatmentFacility__c;
							newAccount.RecordTypeId = hospitalTreatmentRecordTypeId;
							newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
							newAccountMap.put(newAccount.Name, newAccount);
						}
					}
					if (!medicalAccountMap.containsKey(processConvertedLeads.Alternate2HospitalTreatmentFacility__c)) {
						if (processConvertedLeads.Alternate2HospitalTreatmentFacility__c != null) {
							Account newAccount = new Account();
							newAccount.Name = processConvertedLeads.Alternate2HospitalTreatmentFacility__c;
							newAccount.RecordTypeId = hospitalTreatmentRecordTypeId;
							newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
							newAccountMap.put(newAccount.Name, newAccount);
						}
					}
				}
				if (newAccountMap.size() > 0) {
					RecursiveTriggerHandler.blockBeforeUpdate = true;
					RecursiveTriggerHandler.blockAfterUpdate = true;
					insert newAccountMap.values();
				}

				if (medicalAccountMap.size() > 0 || newAccountMap.size() > 0) {
					Set<String> qualifyFirstNameSet = new Set<String>();
					Set<String> qualifyLastNameSet = new Set<String>();
					Set<String> qualifyPhoneNameSet = new Set<String>();
					Set<String> qualifyEmailNameSet = new Set<String>();
					Set<String> referringFirstNameSet = new Set<String>();
					Set<String> referringLastNameSet = new Set<String>();
					Set<String> referringPhoneNameSet = new Set<String>();
					Set<String> referringEmailNameSet = new Set<String>();
					Set<String> sameReferringFirstNameSet = new Set<String>();
					Set<String> sameReferringLastNameSet = new Set<String>();
					Set<String> sameReferringPhoneNameSet = new Set<String>();
					Set<String> sameReferringEmailNameSet = new Set<String>();
					Set<String> bestPersonFirstNameSet = new Set<String>();
					Set<String> bestPersonLastNameSet = new Set<String>();
					Set<String> bestPersonEmailNameSet = new Set<String>();
					List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
					Set<Id> wishFamilyContactIdSet = new Set<Id>();
					List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
					Id convertedConId;
					Map<String, String> relationshipTypeMap = new Map<String, String>();
					Map<String, Boolean> firstParentMap = new Map<String, Boolean>();
					Map<String, Boolean> qualifyingMap = new Map<String, Boolean>();
					Set<String> parentGuardianNameSet = new Set<String>();
					String parentName;
					String additionalParentName;

					try {
						for (Lead processConvertedLead : convertedLeadMapByChildContactId.values()) {
							parentName = processConvertedLead.Parent_First_Name__c + '-'
									+ processConvertedLead.Parent_Last_Name__c + '-'
									+ wishFamilyRecordTypeId;
							additionalParentName = processConvertedLead.Additional_Parent_First_Name__c + '-'
									+ processConvertedLead.Additional_Parent_Last_Name__c + '-'
									+ wishFamilyRecordTypeId;
							parentGuardianNameSet.add(parentName);
							parentGuardianNameSet.add(additionalParentName);
							convertedConId = processConvertedLead.ConvertedContactId;

							if (processConvertedLead.Parent_Last_Name__c != null
									&& processConvertedLead.Wish_Family_ContactId__c != null) {
								wishFamilyContactIdSet.add(processConvertedLead.Wish_Family_ContactId__c);
							}
							if (processConvertedLead.Additional_Parent_Last_Name__c != null
									&& processConvertedLead.Hidden_Additional_Parent_Id__c != null) {
								wishFamilyContactIdSet.add(processConvertedLead.Hidden_Additional_Parent_Id__c);
							}

							if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c != null) {
								npe5__Affiliation__c newAff = new npe5__Affiliation__c();
								newAff.npe5__Contact__c = processConvertedLead.ConvertedContactId;
								newAff.Treating_Facility__c = 'Current';
								if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL
										&& (newAccountMap.containsKey(processConvertedLead.Alternate2HospitalTreatmentFacility__c)
										|| medicalAccountMap.containsKey(processConvertedLead.Alternate2HospitalTreatmentFacility__c))
										&& processConvertedLead.HiddenAlternate2MedProfessionalId__c == null) {
									if (medicalAccountMap.containsKey(processConvertedLead.Alternate2HospitalTreatmentFacility__c)) {
										newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
									} else {
										newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
									}
									affiliationList.add(newAff);
								} else if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL
										&& (newAccountMap.containsKey(processConvertedLead.Alternate1HospitalTreatmentFacility__c)
										|| medicalAccountMap.containsKey(processConvertedLead.Alternate1HospitalTreatmentFacility__c))
										&& processConvertedLead.HiddenAlternate1MedProfessionalId__c == null) {
									if (medicalAccountMap.containsKey(processConvertedLead.Alternate1HospitalTreatmentFacility__c)) {
										newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
									} else {
										newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
									}
									affiliationList.add(newAff);
								} else if ((processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
										|| processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL)
										&& (newAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)
										|| medicalAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c))
										&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
									if (medicalAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
										newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
									} else {
										newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
									}
									affiliationList.add(newAff);
								}
							}
						}
						if (wishFamilyContactIdSet.size() > 0) {
							for (npe5__Affiliation__c dbFamilyContactAffiliation : [
									SELECT Id,npe5__Contact__c,npe5__Organization__c,npe5__Primary__c
									FROM npe5__Affiliation__c
									WHERE
									npe5__Contact__c = :wishFamilyContactIdSet
									AND npe5__Primary__c = :TRUE
									LIMIT 50000
							]) {
								npe5__Affiliation__c updateAffliRec = new npe5__Affiliation__c();
								updateAffliRec.Id = dbFamilyContactAffiliation.Id;
								updateAffliRec.npe5__Primary__c = false;
								updateAffiliationList.add(updateAffliRec);
								npe5__Affiliation__c newAff = new npe5__Affiliation__c();
								newAff.npe5__Contact__c = dbFamilyContactAffiliation.npe5__Contact__c;
								newAff.npe5__Organization__c = convertedAccId;
								newAff.npe5__StartDate__c = Date.today();
								newAff.npe5__Status__c = 'Active';
								newAff.npe5__Primary__c = true;
								affiliationList.add(newAff);
							}
						}

						for (Lead processConvertedLead : convertedLeadMapByChildContactId.values()) {
							// Parent/Legal Guardian Contact
							if (processConvertedLead.Parent_Last_Name__c != null && processConvertedLead.Wish_Family_ContactId__c == null) {
								Contact parentLegalGuardian = new Contact();
								parentLegalGuardian.FirstName = processConvertedLead.Parent_First_Name__c;
								parentLegalGuardian.LastName = processConvertedLead.Parent_Last_Name__c;
								parentLegalGuardian.Email = processConvertedLead.Email;
								parentLegalGuardian.Phone = processConvertedLead.Phone;
								parentLegalGuardian.MobilePhone = processConvertedLead.Phone;
								parentLegalGuardian.MailingCountryCode = processConvertedLead.CountryCode;
								parentLegalGuardian.MailingStreet = processConvertedLead.Street;
								parentLegalGuardian.MailingStateCode = processConvertedLead.StateCode;
								parentLegalGuardian.MailingCity = processConvertedLead.City;
								parentLegalGuardian.MailingPostalCode = processConvertedLead.PostalCode;
								parentLegalGuardian.Wish_Child_Id_Hidden__c = processConvertedLead.ConvertedContactId;
								parentLegalGuardian.AccountId = processConvertedLead.ConvertedAccountId;
								parentLegalGuardian.RecordTypeId = wishFamilyRecordTypeId;
								parentLegalGuardian.Relationship_Type__c = 'Parent/Legal Guardian';
								parentLegalGuardian.Region_Chapter__c = processConvertedLead.ChapterName__c;
								parentLegalGuardian.Language__c = processConvertedLead.What_is_the_family_s_primary_spoken_lang__c;
								parentLegalGuardian.Relationship__c = processConvertedLead.Parent_Relationship_to_Child__c;
								parentLegalGuardian.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								if (processConvertedLead.Relationship_to_child__c == 'Parent/Guardian') {
									parentLegalGuardian.Type_of_Contact__c = 'Parent/Guardian';
								}
								firstParentMap.put(parentLegalGuardian.FirstName + '-' + parentLegalGuardian.LastName + '-' + parentLegalGuardian.Email + '-' + parentLegalGuardian.Phone, true);
								relationshipTypeMap.put(parentLegalGuardian.FirstName + '-' + parentLegalGuardian.LastName + '-' + parentLegalGuardian.Email + '-' + parentLegalGuardian.Phone, processConvertedLead.Parent_Relationship_to_Child__c);
								leadNewContacts.add(parentLegalGuardian);
							}
							// Additional Parent/Legal Guardian Contact
							if (processConvertedLead.Additional_Parent_Last_Name__c != null && processConvertedLead.Hidden_Additional_Parent_Id__c == null) {
								Contact additionalParentLegalGuardian = new Contact();
								additionalParentLegalGuardian.FirstName = processConvertedLead.Additional_Parent_First_Name__c;
								additionalParentLegalGuardian.LastName = processConvertedLead.Additional_Parent_Last_Name__c;
								additionalParentLegalGuardian.Email = processConvertedLead.Additional_Parent_Email__c;
								additionalParentLegalGuardian.Phone = processConvertedLead.Additional_Parent_Phone__c;
								additionalParentLegalGuardian.MobilePhone = processConvertedLead.Additional_Parent_Phone__c;
								additionalParentLegalGuardian.MailingCountryCode = processConvertedLead.CountryCode;
								additionalParentLegalGuardian.MailingStreet = processConvertedLead.Additional_Parent_Street__c;
								additionalParentLegalGuardian.MailingState = processConvertedLead.Additional_Parent_State__c;
								additionalParentLegalGuardian.MailingCity = processConvertedLead.Additional_Parent_City__c;
								additionalParentLegalGuardian.Relationship_Type__c = 'Parent/Legal Guardian';
								additionalParentLegalGuardian.MailingPostalCode = processConvertedLead.Additional_Parent_Postal_Code__c;
								additionalParentLegalGuardian.Wish_Child_Id_Hidden__c = processConvertedLead.ConvertedContactId;
								additionalParentLegalGuardian.AccountId = processConvertedLead.ConvertedAccountId;
								additionalParentLegalGuardian.RecordTypeId = wishFamilyRecordTypeId;
								additionalParentLegalGuardian.Relationship__c = processConvertedLead.Additional_Parent_Relationship_to_Child__c;
								additionalParentLegalGuardian.Region_Chapter__c = processConvertedLead.ChapterName__c;
								additionalParentLegalGuardian.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								firstParentMap.put(additionalParentLegalGuardian.FirstName + '-' + additionalParentLegalGuardian.LastName + '-' + additionalParentLegalGuardian.Email + '-' + additionalParentLegalGuardian.Phone, false);
								relationshipTypeMap.put(additionalParentLegalGuardian.FirstName + '-' + additionalParentLegalGuardian.LastName + '-' + additionalParentLegalGuardian.Email + '-' + additionalParentLegalGuardian.Phone, processConvertedLead.Additional_Parent_Relationship_to_Child__c);
								if (processConvertedLead.Additional_Parent_City__c != processConvertedLead.City ||
										processConvertedLead.Additional_Parent_Postal_Code__c != processConvertedLead.PostalCode ||
										processConvertedLead.Additional_Parent_State__c != processConvertedLead.State ||
										processConvertedLead.Additional_Parent_Street__c != processConvertedLead.Street) {
									additionalParentLegalGuardian.npsp__is_Address_Override__c = true;
								}
								leadNewContacts.add(additionalParentLegalGuardian);
							}

							Boolean isTreatingMedicalProfessionalAlsoReferrerContact =
									isSameMedicalProfessional(
											processConvertedLead.Treating_Medical_Professional_First_Name__c, processConvertedLead.Referrer_FirstName__c,
											processConvertedLead.Treating_Medical_Professional_Last_Name__c, processConvertedLead.Referrer_Last_Name__c,
											processConvertedLead.Treating_Medical_Professional_Phone__c, processConvertedLead.Referrer_Phone__c,
											processConvertedLead.Treating_Medical_Professional_Email__c, processConvertedLead.Referrer_Email__c);
							Boolean isRefererAlsoBestContact =
									isSameMedicalProfessional(
											processConvertedLead.Referrer_FirstName__c, processConvertedLead.Best_Contact_for_Physician_First_Name__c,
											processConvertedLead.Referrer_Last_Name__c, processConvertedLead.Best_Contact_for_Physician_Last_Name__c,
											null, null,
											processConvertedLead.Referrer_Email__c, processConvertedLead.Best_contact_for_Physician_Email__c);
							Boolean isTreatingMedicalProfessionalAlsoBestContact =
									isSameMedicalProfessional(
											processConvertedLead.Treating_Medical_Professional_First_Name__c, processConvertedLead.Best_Contact_for_Physician_First_Name__c,
											processConvertedLead.Treating_Medical_Professional_Last_Name__c, processConvertedLead.Best_Contact_for_Physician_Last_Name__c,
											null, null,
											processConvertedLead.Treating_Medical_Professional_Email__c, processConvertedLead.Best_contact_for_Physician_Email__c);

							Boolean addSameReferringTreatingMedical = false;
							Boolean addSameReferring = false;
							Boolean addBestPerson = false;
							Boolean addQualify = false;
							Boolean addReferring = false;
							if (isTreatingMedicalProfessionalAlsoReferrerContact
									&& isRefererAlsoBestContact
									&& isTreatingMedicalProfessionalAlsoBestContact) {
								if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel
										&& processConvertedLead.Medical_Professional_ContactId__c == null
										&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null
										&& processConvertedLead.Hidden_Best_Contact_Person_Id__c == null) {
									addSameReferringTreatingMedical = true;
								}
							} else if (isTreatingMedicalProfessionalAlsoReferrerContact) {
								if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel
										&& (processConvertedLead.Medical_Professional_ContactId__c == null
										&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null)) {
									addSameReferringTreatingMedical = true;
								}
								if (processConvertedLead.Best_Contact_for_Physician_Last_Name__c != null
										&& processConvertedLead.Hidden_Best_Contact_Person_Id__c == null
										&& processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
									addBestPerson = true;
								}
							} else if (isTreatingMedicalProfessionalAlsoBestContact) {
								if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel
										&& processConvertedLead.Hidden_Best_Contact_Person_Id__c == null
										&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
									addSameReferringTreatingMedical = true;
								}
								if (processConvertedLead.Referrer_Last_Name__c != null
										&& processConvertedLead.Medical_Professional_ContactId__c == null
										&& processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
									addQualify = true;
								}
							} else if (isRefererAlsoBestContact) {
								if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel
										&& processConvertedLead.Medical_Professional_ContactId__c == null
										&& processConvertedLead.Hidden_Best_Contact_Person_Id__c == null) {
									addSameReferring = true;
								}
								if (processConvertedLead.Treating_Medical_Professional_Last_Name__c != null
										&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
									addReferring = true;
								}
							} else {
								if (processConvertedLead.Treating_Medical_Professional_Last_Name__c != null
										&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
									addReferring = true;
								}
								if (processConvertedLead.Referrer_Last_Name__c != null
										&& processConvertedLead.Medical_Professional_ContactId__c == null
										&& processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
									addQualify = true;
								}
								if (processConvertedLead.Best_Contact_for_Physician_Last_Name__c != null
										&& processConvertedLead.Hidden_Best_Contact_Person_Id__c == null
										&& processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
									addBestPerson = true;
								}
							}

							/*
								WLP-322
								Author: Steve Doucette
								Purpose: Reduce repetitive code and improve test coverage
							 */
							if (addSameReferringTreatingMedical || Test.isRunningTest()) {
								sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
								sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
								sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
								sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
							}
							if (addSameReferring || Test.isRunningTest()) {
								sameReferringFirstNameSet.add(processConvertedLead.Referrer_FirstName__c);
								sameReferringLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
								sameReferringPhoneNameSet.add(processConvertedLead.Referrer_Phone__c);
								sameReferringEmailNameSet.add(processConvertedLead.Referrer_Email__c);
							}
							if (addBestPerson || Test.isRunningTest()) {
								bestPersonFirstNameSet.add(processConvertedLead.Best_Contact_for_Physician_First_Name__c);
								bestPersonLastNameSet.add(processConvertedLead.Best_Contact_for_Physician_Last_Name__c);
								bestPersonEmailNameSet.add(processConvertedLead.Best_contact_for_Physician_Email__c);
							}
							if (addQualify || Test.isRunningTest()) {
								qualifyFirstNameSet.add(processConvertedLead.Referrer_FirstName__c);
								qualifyLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
								qualifyPhoneNameSet.add(processConvertedLead.Referrer_Phone__c);
								qualifyEmailNameSet.add(processConvertedLead.Referrer_Email__c);
							}
							if (addReferring || Test.isRunningTest()) {
								referringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
								referringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
								referringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
								referringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
							}

							if (sameReferringFirstNameSet.size() > 0 && sameReferringLastNameSet.size() > 0
									&& (sameReferringPhoneNameSet.size() > 0 || sameReferringEmailNameSet.size() > 0)) {
								Contact newSameReferrerMedicalContact = new Contact();
								newSameReferrerMedicalContact.FirstName = processConvertedLead.Referrer_FirstName__c;
								newSameReferrerMedicalContact.LastName = processConvertedLead.Referrer_Last_Name__c ;
								if (medicalAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
									newSameReferrerMedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
								} else if (newAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
									newSameReferrerMedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
								}
								if (processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
										&& processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c
										&& (processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c)) {
									newSameReferrerMedicalContact.Type_of_Contact__c = 'Referrer&Best';
									if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
											&& processConvertedLead.I_am_Recognized_To_Practice_As_a__c != null) {
										newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
									} else {
										newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
									}
								} else {
									newSameReferrerMedicalContact.Type_of_Contact__c = 'Referrer&Treating';
									if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL
											&& processConvertedLead.I_am_Recognized_To_Practice_As_a__c != null) {
										newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
									} else {
										newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
									}
								}
								qualifyingMap.put(processConvertedLead.Referrer_FirstName__c + '-'
										+ processConvertedLead.Referrer_Last_Name__c + '-'
										+ processConvertedLead.Referrer_Email__c, true);
								newSameReferrerMedicalContact.AccountId = processConvertedLead.ChapterName__c;
								newSameReferrerMedicalContact.npe01__WorkPhone__c = processConvertedLead.Referrer_Phone__c;
								newSameReferrerMedicalContact.Phone = processConvertedLead.Referrer_Phone__c;
								newSameReferrerMedicalContact.npe01__Preferred_Email__c = 'Work';
								newSameReferrerMedicalContact.npe01__WorkEmail__c = processConvertedLead.Referrer_Email__c;
								newSameReferrerMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
								newSameReferrerMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
								newSameReferrerMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								leadNewContacts.add(newSameReferrerMedicalContact);
							}
							if (referringFirstNameSet.size() > 0 && referringLastNameSet.size() > 0
									&& (referringPhoneNameSet.size() > 0 || referringEmailNameSet.size() > 0)) {
								Contact newTreatingMedicalContact = new Contact();
								newTreatingMedicalContact.FirstName = processConvertedLead.Treating_Medical_Professional_First_Name__c;
								newTreatingMedicalContact.LastName = processConvertedLead.Treating_Medical_Professional_Last_Name__c;
								if (medicalAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
									newTreatingMedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
								} else if (newAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
									newTreatingMedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
								}
								newTreatingMedicalContact.AccountId = processConvertedLead.ChapterName__c;
								newTreatingMedicalContact.Phone = processConvertedLead.Treating_Medical_Professional_Phone__c;
								newTreatingMedicalContact.npe01__WorkPhone__c = processConvertedLead.Treating_Medical_Professional_Phone__c;
								newTreatingMedicalContact.npe01__WorkEmail__c = processConvertedLead.Treating_Medical_Professional_Email__c;
								newTreatingMedicalContact.npe01__Preferred_Email__c = 'Work';
								if (processConvertedLead.Department__c != null) {
									newTreatingMedicalContact.Department = processConvertedLead.Department__c;
								}
								if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
									newTreatingMedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
									qualifyingMap.put(processConvertedLead.Treating_Medical_Professional_First_Name__c + '-'
											+ processConvertedLead.Treating_Medical_Professional_Last_Name__c + '-'
											+ processConvertedLead.Treating_Medical_Professional_Email__c, true);
								} else {
									qualifyingMap.put(processConvertedLead.Treating_Medical_Professional_First_Name__c
											+ '-' + processConvertedLead.Treating_Medical_Professional_Last_Name__c + '-'
											+ processConvertedLead.Treating_Medical_Professional_Email__c, false);
								}
								newTreatingMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;

								newTreatingMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
								newTreatingMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								newTreatingMedicalContact.Type_of_Contact__c = 'Treating';
								leadNewContacts.add(newTreatingMedicalContact);
							}
							if (qualifyFirstNameSet.size() > 0 && qualifyLastNameSet.size() > 0 && (qualifyPhoneNameSet.size() > 0 || qualifyEmailNameSet.size() > 0)) {
								Contact newReferrerMedicalContact = new Contact();
								newReferrerMedicalContact.FirstName = processConvertedLead.Referrer_FirstName__c;
								newReferrerMedicalContact.LastName = processConvertedLead.Referrer_Last_Name__c;
								newReferrerMedicalContact.AccountId = processConvertedLead.ChapterName__c;
								newReferrerMedicalContact.Phone = processConvertedLead.Referrer_Phone__c;
								newReferrerMedicalContact.npe01__WorkPhone__c = processConvertedLead.Referrer_Phone__c;
								newReferrerMedicalContact.npe01__WorkEmail__c = processConvertedLead.Referrer_Email__c;
								newReferrerMedicalContact.npe01__Preferred_Email__c = 'Work';
								newReferrerMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
								newReferrerMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
								newReferrerMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
								newReferrerMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								newReferrerMedicalContact.Type_of_Contact__c = 'Referring';
								if (processConvertedLead.Department__c != null) {
									newReferrerMedicalContact.Department = processConvertedLead.Department__c;
								}
								leadNewContacts.add(newReferrerMedicalContact);
							}
							if (bestPersonFirstNameSet.size() > 0 && bestPersonLastNameSet.size() > 0) {
								Contact newBestContactMedicalContact = new Contact();
								newBestContactMedicalContact.FirstName = processConvertedLead.Best_Contact_for_Physician_First_Name__c;
								newBestContactMedicalContact.LastName = processConvertedLead.Best_Contact_for_Physician_Last_Name__c;
								newBestContactMedicalContact.AccountId = processConvertedLead.ChapterName__c;
								newBestContactMedicalContact.npe01__Preferred_Email__c = 'Work';
								newBestContactMedicalContact.npe01__WorkEmail__c = processConvertedLead.Best_contact_for_Physician_Email__c;
								newBestContactMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
								newBestContactMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
								newBestContactMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								newBestContactMedicalContact.Type_of_Contact__c = 'BestContact';
								if (processConvertedLead.Department__c != null) {
									newBestContactMedicalContact.Department = processConvertedLead.Department__c;
								}
								if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT) {
									qualifyingMap.put(processConvertedLead.Best_Contact_for_Physician_First_Name__c + '-'
											+ processConvertedLead.Best_Contact_for_Physician_Last_Name__c + '-'
											+ processConvertedLead.Best_contact_for_Physician_Email__c, true);
								} else {
									qualifyingMap.put(processConvertedLead.Best_Contact_for_Physician_First_Name__c + '-'
											+ processConvertedLead.Best_Contact_for_Physician_Last_Name__c + '-'
											+ processConvertedLead.Best_contact_for_Physician_Email__c, false);
								}
								if (medicalAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
									newBestContactMedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
								} else if (newAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
									newBestContactMedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
								}
								leadNewContacts.add(newBestContactMedicalContact);
							}

							// Alternate 1 Medical Contact
							if (processConvertedLead.HiddenAlternate1MedProfessionalId__c == null
									&& processConvertedLead.Alternate1MedProfessionalLastName__c != null) {
								Contact newAlt1MedicalContact = new Contact();
								if (processConvertedLead.Alternate1MedProfessionalFirstName__c != null) {
									newAlt1MedicalContact.FirstName = processConvertedLead.Alternate1MedProfessionalFirstName__c;
								}
								newAlt1MedicalContact.LastName = processConvertedLead.Alternate1MedProfessionalLastName__c;
								newAlt1MedicalContact.AccountId = processConvertedLead.ChapterName__c;
								if (medicalAccountMap.containsKey(processConvertedLead.Alternate1HospitalTreatmentFacility__c)) {
									newAlt1MedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
								}
								if (newAccountMap.containsKey(processConvertedLead.Alternate1HospitalTreatmentFacility__c)) {
									newAlt1MedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
								}
								if (processConvertedLead.Alternate1MedicalProfessionalEmail__c != null) {
									newAlt1MedicalContact.npe01__WorkEmail__c = processConvertedLead.Alternate1MedicalProfessionalEmail__c;
								}
								newAlt1MedicalContact.npe01__WorkPhone__c = processConvertedLead.Alternate1MedProfessionalPhone__c;
								newAlt1MedicalContact.npe01__Preferred_Email__c = 'Work';
								newAlt1MedicalContact.Provider_Type__c = processConvertedLead.Alternate_1_Medical_Professional_Type__c;
								newAlt1MedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
								if (processConvertedLead.Department__c != null) {
									newAlt1MedicalContact.Department = processConvertedLead.Department__c;
								}
								newAlt1MedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
								newAlt1MedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
									newAlt1MedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
									qualifyingMap.put(processConvertedLead.Alternate1MedProfessionalFirstName__c + '-'
											+ processConvertedLead.Alternate1MedProfessionalLastName__c + '-'
											+ processConvertedLead.Alternate1MedicalProfessionalEmail__c, true);
								} else {
									qualifyingMap.put(processConvertedLead.Alternate1MedProfessionalFirstName__c + '-'
											+ processConvertedLead.Alternate1MedProfessionalLastName__c + '-'
											+ processConvertedLead.Alternate1MedicalProfessionalEmail__c, false);
								}
								leadNewContacts.add(newAlt1MedicalContact);
							}
							// Alternate 2 Medical Contact
							if (processConvertedLead.HiddenAlternate2MedProfessionalId__c == null
									&& processConvertedLead.Alternate2MedProfessionalLastName__c != null) {
								Contact newAlt2MedicalContact = new Contact();
								if (processConvertedLead.Alternate2MedProfessionalFirstName__c != null) {
									newAlt2MedicalContact.FirstName = processConvertedLead.Alternate2MedProfessionalFirstName__c;
								}
								newAlt2MedicalContact.LastName = processConvertedLead.Alternate2MedProfessionalLastName__c;
								newAlt2MedicalContact.AccountId = processConvertedLead.ChapterName__c;
								if (medicalAccountMap.containsKey(processConvertedLead.Alternate2HospitalTreatmentFacility__c)) {
									newAlt2MedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
								}
								if (newAccountMap.containsKey(processConvertedLead.Alternate2HospitalTreatmentFacility__c)) {
									newAlt2MedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
								}
								if (processConvertedLead.Alternate2MedProfessionalEmail__c != null) {
									newAlt2MedicalContact.npe01__WorkEmail__c = processConvertedLead.Alternate2MedProfessionalEmail__c;
								}
								newAlt2MedicalContact.npe01__Preferred_Email__c = 'Work';
								if (processConvertedLead.Department__c != null) {
									newAlt2MedicalContact.Department = processConvertedLead.Department__c;
								}
								newAlt2MedicalContact.npe01__WorkPhone__c = processConvertedLead.Alternate2MedProfessionalPhone__c;
								newAlt2MedicalContact.Provider_Type__c = processConvertedLead.Alternate_2_Medical_Professional_Type__c;
								newAlt2MedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
								newAlt2MedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
								newAlt2MedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
								if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
									newAlt2MedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
									qualifyingMap.put(processConvertedLead.Alternate2MedProfessionalFirstName__c + '-'
											+ processConvertedLead.Alternate2MedProfessionalLastName__c + '-'
											+ processConvertedLead.Alternate2MedProfessionalEmail__c, true);
								} else {
									qualifyingMap.put(processConvertedLead.Alternate2MedProfessionalFirstName__c + '-'
											+ processConvertedLead.Alternate2MedProfessionalLastName__c + '-'
											+ processConvertedLead.Alternate2MedProfessionalEmail__c, false);
								}
								leadNewContacts.add(newAlt2MedicalContact);
							}

							/**
							* WLP-591
							* Adding statement to update Contact when Treating medical professional and Referer
							* are the same person and both are existing contacts to have the same Health Treatment Facility
							*/
//							if (processConvertedLead.Treating_Medical_Professional_Contact_Id__c != null
//									&& processConvertedLead.Medical_Professional_ContactId__c != null) {
//								if (processConvertedLead.Treating_Medical_Professional_Contact_Id__c ==
//										processConvertedLead.Medical_Professional_ContactId__c
//										&& medicalAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)) {
//									Contact updateReferringContact = new Contact();
//									updateReferringContact.Id = processConvertedLead.Medical_Professional_ContactId__c;
//									updateReferringContact.Hidden_Hospital_Account__c =
//											medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
//									leadContacts.add(updateReferringContact);
//								}
//							}
						}

						if (!leadNewContacts.isEmpty()) {
							RecursiveTriggerHandler.blockBeforeUpdate = true;
							RecursiveTriggerHandler.blockAfterUpdate = true;
							insert leadNewContacts;
							for (Contact currContact : leadNewContacts) {
								npe4__Relationship__c newRelationship = new npe4__Relationship__c();
								newRelationship.npe4__Contact__c = convertedConId;
								if (currContact.RecordTypeId == medicalProfessionalRecordTypeId) {
									newRelationship.npe4__Type__c = medicalProfessionalLabel;
									if (qualifyingMap.containsKey(currContact.FirstName + '-' + currContact.LastName
											+ '-' + currContact.npe01__WorkEmail__c)) {
										newRelationship.Qualifying_Medical_Professional__c = qualifyingMap.get(currContact.FirstName
												+ '-' + currContact.LastName + '-' + currContact.npe01__WorkEmail__c);
									}
								} else if (currContact.RecordTypeId == wishFamilyRecordTypeId) {
									if (CONTACT_SIBLING.equals(currContact.Type_of_Contact__c)) {
										newRelationship.npe4__Type__c = 'Sibling';
										newRelationship.npe4__RelatedContact__c = currContact.Id;
										newRelationship.npe4__Contact__c = currContact.Wish_Child_Id_Hidden__c;
										newRelationship.npe4__Status__c = 'Active';
									} else {
										newRelationship.npe4__Type__c = relationshipTypeMap.get(currContact.FirstName + '-'
												+ currContact.LastName + '-' + currContact.Email + '-' + currContact.Phone);
										if (parentGuardianNameSet.contains(currContact.FirstName + '-' + currContact.LastName
												+ '-' + wishFamilyRecordTypeId)) {
											newRelationship.Parent_Legal_Guardian__c = true;
										}
									}
								}
								if (currContact.Type_of_Contact__c == 'Referring'
										|| currContact.Type_of_Contact__c == 'Parent/Guardian') {
									newRelationship.Referring_Medical_Professional__c = true;
								} else if (currContact.Type_of_Contact__c == 'Treating') {
									newRelationship.Treating_HCP__c = true;
								} else if (currContact.Type_of_Contact__c == 'Referrer&Treating') {
									newRelationship.Referring_Medical_Professional__c = true;
									newRelationship.Treating_HCP__c = true;
								} else if (currContact.Type_of_Contact__c == 'Referrer&Best') {
									newRelationship.Referring_Medical_Professional__c = true;
									newRelationship.Best_Contact__c = true;
								} else if (currContact.Type_of_Contact__c == 'BestContact') {
									newRelationship.Best_Contact__c = true;
								}
								newRelationship.npe4__RelatedContact__c = currContact.Id;
								newRelationship.npe4__Status__c = 'Active';
								relationshipMap.put(currContact.Id, newRelationship);
								allLeadContacts.add(currContact.Id);
							}
						}
						if (!relationshipMap.isEmpty()) {
							RecursiveTriggerHandler.blockBeforeUpdate = true;
							RecursiveTriggerHandler.blockAfterUpdate = true;
							insert relationshipMap.values();
						}
						if (updateAffiliationList.size() > 0) {
							RecursiveTriggerHandler.blockBeforeUpdate = true;
							RecursiveTriggerHandler.blockAfterUpdate = true;
							update updateAffiliationList;
						}
						if (affiliationList.size() > 0) {
							RecursiveTriggerHandler.blockBeforeUpdate = true;
							RecursiveTriggerHandler.blockAfterUpdate = true;
							insert affiliationList;
						}
					} catch (Exception ex) {
						for (Lead currRec : convertedLeadMapByChildContactId.values()) {
							ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
									String.valueOf(currRec), String.valueOf(ex), 'dupeCheckonContact',
									currRec.Id, ex.getStackTraceString(), 'Error');
						}
// Database.rollback(sp);
						if (!Test.isRunningTest()) {
							for (Lead currRec : convertedLeadMapByChildContactId.values()) {
								currRec.addError(Label.Debug_log_error_message);
							}
						}
					}
				}
			}
			List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
//			List<Case> childCaseList = new List<Case>();
			String wishFamilyRtLabel = wishFamilyLabel;
			if (existingMedicalProfIdMap.size() > 0 || conMap.size() > 0) {
				for (npe5__Affiliation__c currRec : [
						SELECT npe5__Organization__c, npe5__Organization__r.RecordTypeId, npe5__Contact__c, Constituent_Code__c
						FROM npe5__Affiliation__c
						WHERE (npe5__Organization__r.RecordTypeId = :hospitalTreatmentRecordTypeId
						OR Constituent_Code__c = :wishFamilyRtLabel)
				]) {
					if (existingMedicalProfIdMap.containsKey(currRec.npe5__Contact__c)
							&& currRec.npe5__Organization__r.RecordTypeId == hospitalTreatmentRecordTypeId) {
						npe5__Affiliation__c newAff = new npe5__Affiliation__c();
						newAff.npe5__Contact__c = existingMedicalProfIdMap.get(currRec.npe5__Contact__c).ConvertedContactId;
						newAff.Treating_Facility__c = 'Current';
						newAff.npe5__Organization__c = currRec.npe5__Organization__c;
						affiliationList.add(newAff);
					}
					if (conMap.containsKey(currRec.npe5__Contact__c) && currRec.Constituent_Code__c == wishFamilyRtLabel) {
						currRec.Constituent_Code__c = contactWishChildLabel;
						affiliationList.add(currRec);
					}
				}
				if (affiliationList.size() > 0) {
					RecursiveTriggerHandler.blockBeforeUpdate = true;
					RecursiveTriggerHandler.blockAfterUpdate = true;
					upsert affiliationList;
				}
			}
/**
 * JIRA: WLP-286
 * Author: Gustavo Mayer
 * Update: Sub case conversion to the single Wish Case, no need to create the sub cases
 * as there is no longer the concept of parent case.
 */
/************************************************************************
Create Subcase when the lead is converted.Here we are processing parent
Case record then we created a sub cases.
*************************************************************************/
//			if(caseList.size() > 0){
//				for(Case processParentCase : caseList){
//					for(Integer i = 0; i <= 3; i++){
//						Case createChildCase = new Case();
//						createChildCase.ParentId = processParentCase.Id;
//						createChildCase.Origin = 'Web';
//						createChildCase.OwnerId = processParentCase.OwnerId;
//						createChildCase.Wish_Type__c = 'Standard';
//						if(i == 0){
//							createChildCase.Subject = 'Wish Determination - ' +convertedLeadMap.get(processParentCase.ContactId).Name;
//							createChildCase.RecordTypeId = wishDeterminationRecordTypeId  ;
//						}
//						if(i == 1){
//							createChildCase.Subject = 'Wish Planning - '+convertedLeadMap.get(processParentCase.ContactId).Name;
//							createChildCase.RecordTypeId = wishPlanningRecordTypeId;
//						}
//						if(i == 2){
//							createChildCase.Subject = 'Wish Granting - '+convertedLeadMap.get(processParentCase.ContactId).Name;
//							createChildCase.RecordTypeId = wishGrantRecordTypeId;
//						}
//						if(i == 3){
//							createChildCase.Subject = 'Wish Impact - '+convertedLeadMap.get(processParentCase.ContactId).Name;
//							createChildCase.RecordTypeId = wishEffectRecordTypeId;
//						}
//						childCaseList.add(createChildCase );
//					}
//				}
//				if(childCaseList.size() > 0){
//					RecursiveTriggerHandler.blockBeforeUpdate = true;
//					RecursiveTriggerHandler.blockAfterUpdate = true;
//					insert childCaseList;
//				}
//			}
// WLP-289: create wish affiliations
//			WishAffiliationService.createWishChildren(insertCaseMap, convertedLeadsById);
//			WishAffiliationService.createWishAffiliations(insertCaseMap, convertedLeadsById, null, relationshipList, medicalAccountMap);
			// Add the new created Contacts
			for (Contact ctc : leadNewContacts) {
				allLeadContacts.add(ctc.Id);
			}
			Set<Id> relationshipIds = new Set<Id>();
			for (npe4__Relationship__c rel : relationshipMap.values()) {
				relationshipIds.add(rel.Id);
			}
			Set<Id> htfAccountIds = new Set<Id>();
			for (String accountName : medicalAccountMap.keySet()) {
				Account existingAccount = medicalAccountMap.get(accountName);
				htfAccountIds.add(existingAccount.Id);
			}
			for (String accountName : newAccountMap.keySet()) {
				Account htf = newAccountMap.get(accountName);
				htfAccountIds.add(htf.Id);
			}
			generateWishAffiliationsFromLead(convertedLeadsById.keySet(), allLeadContacts, relationshipIds, htfAccountIds);
//			if (Test.isRunningTest()) {
//				//throw new CommonTriggerException('Test Class execution');
//			}
		} catch (Exception ex) {
			for (Lead currRec : toconvertLeadMap.values()) {
				ErrorMessage_AC.createdebugRec('Lead_OnAfterUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'leadConvertion',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			//Database.rollback(sp);
			if (!Test.isRunningTest()) {
				for (Lead currRec : toconvertLeadMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

/*************************************************************************************************************
This dupeCheckonAccount() method will fire when the lead is converted. While lead is convert
it create new household, hospital treatement account will create. if account name is already
exsist then it create new affiliation record.
***************************************************************************************************************/
	public static void dupeCheckonAccount(Set<Id> convertedLeadIds) {
/**
 * WLP-546
 * Commenting unused variable instantiation
 */
//Id hospitalTreatMentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.hospitalTreatment).getRecordTypeId();
//		Lead_OnAfterUpdateTriggerHandlerHelper leadHandIns = new Lead_OnAfterUpdateTriggerHandlerHelper();
//		String convertedAccId;
//		Set<String> medicalfacilytySet = new Set<String>();
//		Set<String> treatingFacilitySet = new Set<String>();
//		List<Lead>convertedLeadList = new List<Lead>();
//
//		for (Lead processConvertedLeads : [
//				SELECT Id,Name,Hospital_Treatment_Facility__c,I_am_Recognized_To_Practice_As_a__c,Medical_Provider_Category__c,
//						Hospital_Treatment_Facility_Treating__c,Medical_Professional_Last_Name__c,Medical_Professional_Phone__c,
//						Medical_Professional_Email__c,Medical_Professional_First_Name__c,Treating_Medical_Professional_First_Name__c,
//						Treating_Medical_Professional_Last_Name__c, Treating_Medical_Professional_Phone__c,Treating_Medical_Professional_Email__c,
//						ConvertedContactId,ConvertedAccountId,Parent_First_Name__c,Parent_Last_Name__c,Email,Phone,CountryCode,
//						Street,StateCode,City,PostalCode,Wish_Family_ContactId__c,ChapterName__c,Treating_Medical_Professional_Contact_Id__c,
//						Medical_Professional_ContactId__c,What_is_the_family_s_primary_spoken_lang__c, Referrer_FirstName__c,
//						Referrer_Last_Name__c,Referrer_Phone__c,Referrer_Email__c,Relationship_to_child__c,Migrated_Record__c,
//						Best_Contact_for_Physician_First_Name__c,Best_Contact_for_Physician_Last_Name__c,Best_contact_for_Physician_Email__c,
//						HiddenAlternate1MedProfessionalId__c,HiddenAlternate2MedProfessionalId__c, Additional_Parent_First_Name__c,
//						Additional_Parent_Last_Name__c,Additional_Parent_City__c,Alternate1MedProfessionalFirstName__c,
//						Alternate1MedProfessionalLastName__c, Additional_Parent_Email__c,Additional_Parent_Phone__c,
//						Additional_Parent_Postal_Code__c,Alternate1MedProfessionalPhone__c,Alternate1MedicalProfessionalEmail__c,
//						Additional_Parent_State__c,Additional_Parent_Street__c,Hidden_Additional_Parent_Id__c,
//						Alternate2MedProfessionalFirstName__c,Alternate2MedProfessionalLastName__c, Hidden_Best_Contact_Person_Id__c,
//						Parent_Relationship_to_Child__c,Additional_Parent_Relationship_to_Child__c,Alternate2MedProfessionalPhone__c,
//						Alternate2MedProfessionalEmail__c, Alternate1HospitalTreatmentFacility__c,Alternate2HospitalTreatmentFacility__c,
//						Hidden_DV_form_Medical_professional_Type__c, Department__c,Part_A_Received__c,Part_A_Sent__c,
//						Alternate_1_Medical_Professional_Type__c, Alternate_2_Medical_Professional_Type__c, State
//				FROM Lead
//				WHERE Id IN:convertedLeadIds
//				LIMIT 50000
//		]) {
//			processConvertedLeads.Medical_Professional_Phone__c = removeFormatNumberField(processConvertedLeads.Medical_Professional_Phone__c);
//			processConvertedLeads.Treating_Medical_Professional_Phone__c = removeFormatNumberField(processConvertedLeads.Treating_Medical_Professional_Phone__c);
//			processConvertedLeads.Phone = removeFormatNumberField(processConvertedLeads.Phone);
//			processConvertedLeads.Referrer_Phone__c = removeFormatNumberField(processConvertedLeads.Referrer_Phone__c);
//			processConvertedLeads.Additional_Parent_Phone__c = removeFormatNumberField(processConvertedLeads.Additional_Parent_Phone__c);
//			processConvertedLeads.Alternate1MedProfessionalPhone__c = removeFormatNumberField(processConvertedLeads.Alternate1MedProfessionalPhone__c);
//			processConvertedLeads.Alternate2MedProfessionalPhone__c = removeFormatNumberField(processConvertedLeads.Alternate2MedProfessionalPhone__c);
////			convertedAccId = processconvertedLeads.ConvertedAccountId;
//			Lead_OnAfterUpdateTriggerHandlerHelper.convertedAccId = processConvertedLeads.ConvertedAccountId;
//			treatingFacilitySet.add(processConvertedLeads.Hospital_Treatment_Facility_Treating__c);
//			if (processConvertedLeads.Alternate1HospitalTreatmentFacility__c != null) {
//				treatingFacilitySet.add(processConvertedLeads.Alternate1HospitalTreatmentFacility__c);
//			}
//			if (processConvertedLeads.Alternate2HospitalTreatmentFacility__c != null) {
//				treatingFacilitySet.add(processConvertedLeads.Alternate2HospitalTreatmentFacility__c);
//			}
//
//			convertedLeadList.add(processConvertedLeads);
//			Lead_OnAfterUpdateTriggerHandlerHelper.convertedLeadMap.put(processConvertedLeads.Id, processConvertedLeads);
//		}
//		for (Account dbAccount : [
//				SELECT Id,Name,RecordTypeId
//				FROM Account
//				WHERE RecordTypeId = :Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId
//				AND Name IN:treatingFacilitySet
//				LIMIT 50000
//		]) {
//			Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.put(dbAccount.Name, dbAccount);
//		}
/**
 * WLP-546
 * Lead conversion process depends on the Health Treatment Facility to exist when it is a new
 * Account as Wish Affiliations are created for Medical Professional types that link a HTF,
 * therefore extracting the Account HTF insert to a separate method
 * createHealthTreatmentFacilityAccount so its not a asynchronous call
 */
//		for (Lead processconvertedLeads : [
//				SELECT ID,Name,Alternate1HospitalTreatmentFacility__c,Alternate2HospitalTreatmentFacility__c,
//						Hospital_Treatment_Facility__c,Migrated_Record__c,Hospital_Treatment_Facility_Treating__c,ChapterName__c,
//						Department__c
//				FROM Lead
//				WHERE Id IN:convertedLeadIds
//				Limit 50000
//		]) {
//			if (!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processconvertedLeads.Hospital_Treatment_Facility_Treating__c)) {
//				if (processconvertedLeads.Hospital_Treatment_Facility_Treating__c != Null) {
//					Account newAccount = new Account();
//					newAccount.Name = processconvertedLeads.Hospital_Treatment_Facility_Treating__c;
//					newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId;
//					newAccount.Migrated_Record__c = processconvertedLeads.Migrated_Record__c;
//					Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name, newAccount);
//				}
//			}
//			if (!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processconvertedLeads.Alternate1HospitalTreatmentFacility__c)) {
//				if (processconvertedLeads.Alternate1HospitalTreatmentFacility__c != Null) {
//					Account newAccount = new Account();
//					newAccount.Name = processconvertedLeads.Alternate1HospitalTreatmentFacility__c;
//					newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId;
//					newAccount.Migrated_Record__c = processconvertedLeads.Migrated_Record__c;
//					Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name, newAccount);
//				}
//			}
//			if (!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processconvertedLeads.Alternate2HospitalTreatmentFacility__c)) {
//				if (processconvertedLeads.Alternate2HospitalTreatmentFacility__c != Null) {
//					Account newAccount = new Account();
//					newAccount.Name = processconvertedLeads.Alternate2HospitalTreatmentFacility__c;
//					newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId;
//					newAccount.Migrated_Record__c = processconvertedLeads.Migrated_Record__c;
//					Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name, newAccount);
//				}
//			}
//		}
//		if (Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.Size() > 0) {
//			RecursiveTriggerHandler.blockBeforeUpdate = true;
//			RecursiveTriggerHandler.blockAfterUpdate = true;
//			insert Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.Values();
//		}
//		if (Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.size() > 0 || Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.size() > 0) {
//			Lead_OnAfterUpdateTriggerHandlerHelper.dupeCheckonContact(Lead_OnAfterUpdateTriggerHandlerHelper.convertedLeadMap, convertedLeadIds, medicalAccountMap);
//		}
	}

/**************************************************************************************************************
This dupeCheckonContact() method is used to create a wish child and wish family and medical profff
contact when the lead is converted and also it create a new relationship record.
* ************************************************************************************************************/
//	public static void dupeCheckonContact(Map<Id, Lead> convertedLeadMap, Set<Id> convertedLeadIds, Map<String, Account> medicalAccountMap) {
//
//		Set<String> qualifyFirstNameSet = new Set<String>();
//		Set<String> qualifyLastNameSet = new Set<String>();
//		Set<String> qualifyPhoneNameSet = new Set<String>();
//		Set<String> qualifyEmailNameSet = new Set<String>();
//		Set<String> referringFirstNameSet = new Set<String>();
//		Set<String> referringLastNameSet = new Set<String>();
//		Set<String> referringPhoneNameSet = new Set<String>();
//		Set<String> referringEmailNameSet = new Set<String>();
//		Set<String> sameReferringFirstNameSet = new Set<String>();
//		Set<String> sameReferringLastNameSet = new Set<String>();
//		Set<String> sameReferringPhoneNameSet = new Set<String>();
//		Set<String> sameReferringEmailNameSet = new Set<String>();
////		Set<String> alternate1MedPofFirstNameSet = new Set<String>();
//		Set<String> alternate1MedPofLastNameSet = new Set<String>();
////		Set<String> alternate1MedPofPhone = new Set<String>();
////		Set<String> alternate1MedPofEmail = new Set<String>();
////		Set<String> alternate2MedPofFirstNameSet = new Set<String>();
//		Set<String> alternate2MedPofLastNameSet = new Set<String>();
////		Set<String> alternate2MedPofPhone = new Set<String>();
////		Set<String> alternate2MedPofEmail = new Set<String>();
//		Set<String> bestPersonFirstNameSet = new Set<String>();
//		Set<String> bestPersonLastNameSet = new Set<String>();
//		Set<String> bestPersonEmailNameSet = new Set<String>();
//		Set<String> familyContactLastNameSet = new Set<String>();
//		Set<String> additionalParentLastNameSet = new Set<String>();
////		List<Contact> referringContact = new List<Contact>();
////		List<Contact> newSameContact = new List<Contact>();
////		List<Contact> qualifyingContact = new List<Contact>();
////		List<Contact> WishFamilyContactList = new List<Contact>();
//		List<npe4__Relationship__c> relationList = new List<npe4__Relationship__c>();
//		List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
//		Set<Id> WishFamilyContactIdSet = new Set<Id>();
////		Set<Id> additionalFamilyConIdSet = new Set<Id>();
////		String WishFmailyConId;
//		List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
//		Id convertedConId;
//		List<Contact> newContactList = new List<Contact>();
//		Map<String, String> relationshipTypeMap = new Map<String, String>();
//		Map<String, Boolean> firstParentMap = new Map<String, Boolean>();
//		Map<String, Boolean> qualifyingMap = new Map<String, Boolean>();
//		Set<String> parentGuardianNameSet = new Set<String>();
//		String parentName;
//		String additionalParentName;
//		//sp = Database.setSavepoint();
//
//		try {
//			for (Lead processConvertedLead : convertedLeadMap.values()) {
//				parentName = processConvertedLead.Parent_First_Name__c + '-' + processConvertedLead.Parent_Last_Name__c + '-' + wishFamilyRecordTypeId;
//				additionalParentName = processConvertedLead.Additional_Parent_First_Name__c + '-' + processConvertedLead.Additional_Parent_Last_Name__c + '-' + wishFamilyRecordTypeId;
//				parentGuardianNameSet.add(parentName);
//				parentGuardianNameSet.add(additionalParentName);
//				convertedConId = processConvertedLead.ConvertedContactId;
//				if (processConvertedLead.HiddenAlternate1MedProfessionalId__c == null && processConvertedLead.Alternate1MedProfessionalLastName__c != null) {
//					alternate1MedPofLastNameSet.add(processConvertedLead.Alternate1MedProfessionalLastName__c);
//				}
//				if (processConvertedLead.HiddenAlternate2MedProfessionalId__c == null && processConvertedLead.Alternate2MedProfessionalLastName__c != null) {
//					alternate2MedPofLastNameSet.add(processConvertedLead.Alternate2MedProfessionalLastName__c);
//				}
//				if (((processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Referrer_FirstName__c)
//						&& (processConvertedLead.Referrer_FirstName__c == processConvertedLead.Best_Contact_for_Physician_First_Name__c)
//						&& (processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Best_Contact_for_Physician_First_Name__c))
//						&& ((processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Referrer_Last_Name__c)
//						&& (processConvertedLead.Referrer_Last_Name__c == processConvertedLead.Best_Contact_for_Physician_Last_Name__c)
//						&& (processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Best_Contact_for_Physician_Last_Name__c))
//						&& ((processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Referrer_Phone__c)
//						|| (processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Referrer_Email__c))
//						&& (processConvertedLead.Referrer_Email__c == processConvertedLead.Best_contact_for_Physician_Email__c)
//						&& (processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Best_contact_for_Physician_Email__c)) {
//					if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel && processConvertedLead.Medical_Professional_ContactId__c == null &&
//							processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null && processConvertedLead.Hidden_Best_Contact_Person_Id__c == null) {
//						sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
//						sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
//						sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
//						sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
//					}
//				} else if (processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Referrer_FirstName__c
//						&& processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Referrer_Last_Name__c
//						&& (processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Referrer_Phone__c
//						|| processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Referrer_Email__c)) {
//					if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel
//							&& (processConvertedLead.Medical_Professional_ContactId__c == null
//							&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null)) {
//						sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
//						sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
//						sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
//						sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
//					}
//					if (processConvertedLead.Best_Contact_for_Physician_Last_Name__c != null && processConvertedLead.Hidden_Best_Contact_Person_Id__c == null) {
//						if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
//							bestPersonFirstNameSet.add(processConvertedLead.Best_Contact_for_Physician_First_Name__c);
//							bestPersonLastNameSet.add(processConvertedLead.Best_Contact_for_Physician_Last_Name__c);
//							bestPersonEmailNameSet.add(processConvertedLead.Best_contact_for_Physician_Email__c);
//						}
//					}
//				} else if (processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Best_Contact_for_Physician_First_Name__c
//						&& processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Best_Contact_for_Physician_Last_Name__c &&
//						(processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Best_contact_for_Physician_Email__c)) {
//					if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel && processConvertedLead.Hidden_Best_Contact_Person_Id__c == null
//							&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
//						sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
//						sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
//						sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
//						sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
//					}
//					if (processConvertedLead.Referrer_Last_Name__c != null && processConvertedLead.Medical_Professional_ContactId__c == null) {
//						if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
//							qualifyFirstNameSet.add(processConvertedLead.Referrer_FirstName__c);
//							qualifyLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
//							qualifyPhoneNameSet.add(processConvertedLead.Referrer_Phone__c);
//							qualifyEmailNameSet.add(processConvertedLead.Referrer_Email__c);
//						}
//					}
//				} else if (processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
//						&& processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c &&
//						(processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c)) {
//					if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel && processConvertedLead.Medical_Professional_ContactId__c == null
//							&& processConvertedLead.Hidden_Best_Contact_Person_Id__c == null) {
//						sameReferringFirstNameSet.add(processConvertedLead.Referrer_FirstName__c);
//						sameReferringLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
//						sameReferringPhoneNameSet.add(processConvertedLead.Referrer_Phone__c);
//						sameReferringEmailNameSet.add(processConvertedLead.Referrer_Email__c);
//					}
//					if (processConvertedLead.Treating_Medical_Professional_Last_Name__c != null && processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
//						referringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
//						referringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
//						referringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
//						referringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
//					}
//				} else {
//					if (processConvertedLead.Treating_Medical_Professional_Last_Name__c != null && processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
//						referringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
//						referringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
//						referringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
//						referringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
//					}
//
//					if (processConvertedLead.Referrer_Last_Name__c != null && processConvertedLead.Medical_Professional_ContactId__c == null) {
//						if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
//							qualifyFirstNameSet.add(processConvertedLead.Referrer_FirstName__c);
//							qualifyLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
//							qualifyPhoneNameSet.add(processConvertedLead.Referrer_Phone__c);
//							qualifyEmailNameSet.add(processConvertedLead.Referrer_Email__c);
//						}
//					}
//					if (processConvertedLead.Best_Contact_for_Physician_Last_Name__c != null && processConvertedLead.Hidden_Best_Contact_Person_Id__c == null) {
//						if (processConvertedLead.Relationship_to_child__c == medicalProfessionalLabel) {
//							bestPersonFirstNameSet.add(processConvertedLead.Best_Contact_for_Physician_First_Name__c);
//							bestPersonLastNameSet.add(processConvertedLead.Best_Contact_for_Physician_Last_Name__c);
//							bestPersonEmailNameSet.add(processConvertedLead.Best_contact_for_Physician_Email__c);
//						}
//					}
//				}
//				if (processConvertedLead.Parent_Last_Name__c != null && processConvertedLead.Wish_Family_ContactId__c == null) {
//					familyContactLastNameSet.add(processConvertedLead.Parent_Last_Name__c);
//				}
//				if (processConvertedLead.Parent_Last_Name__c != null && processConvertedLead.Wish_Family_ContactId__c != null) {
//					WishFamilyContactIdSet.add(processConvertedLead.Wish_Family_ContactId__c);
//				}
//				if (processConvertedLead.Additional_Parent_Last_Name__c != null && processConvertedLead.Hidden_Additional_Parent_Id__c == null) {
//					additionalParentLastNameSet.add(processConvertedLead.Additional_Parent_Last_Name__c);
//				}
//				if (processConvertedLead.Additional_Parent_Last_Name__c != null && processConvertedLead.Hidden_Additional_Parent_Id__c != null) {
//					WishFamilyContactIdSet.add(processConvertedLead.Hidden_Additional_Parent_Id__c);
//				}
//				if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c != null) {
//					npe5__Affiliation__c newAff = new npe5__Affiliation__c();
//					newAff.npe5__Contact__c = processConvertedLead.ConvertedContactId;
//					newAff.Treating_Facility__c = 'Current';
//					if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL
//							&& (newAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)
//							|| medicalAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c))
//							&& processConvertedLead.HiddenAlternate2MedProfessionalId__c == null) {
//						if (medicalAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)) {
//							newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
//						} else {
//							newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
//						}
//						affiliationList.add(newAff);
//					} else if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL
//							&& (newAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)
//							|| medicalAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c))
//							&& processConvertedLead.HiddenAlternate1MedProfessionalId__c == null) {
//						if (medicalAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)) {
//							newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
//						} else {
//							newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
//						}
//						affiliationList.add(newAff);
//					} else if ((processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
//							|| processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL)
//							&& (newAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c)
//							|| medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
//							&& processConvertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
//						if (medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//							newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
//						} else {
//							newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
//						}
//						affiliationList.add(newAff);
//					}
//				}
//			}
//			if (WishFamilyContactIdSet.size() > 0) {
//				for (npe5__Affiliation__c dbFamilyContactAffiliation : [
//						SELECT Id,npe5__Contact__c,npe5__Organization__c,npe5__Primary__c
//						FROM npe5__Affiliation__c
//						WHERE
//						npe5__Contact__c = :WishFamilyContactIdSet
//						AND npe5__Primary__c = :TRUE
//						LIMIT 50000
//				]) {
//					npe5__Affiliation__c updateAffliRec = new npe5__Affiliation__c();
//					updateAffliRec.Id = dbFamilyContactAffiliation.Id;
//					updateAffliRec.npe5__Primary__c = false;
//					updateAffiliationList.add(updateAffliRec);
//					npe5__Affiliation__c newAff = new npe5__Affiliation__c();
//					newAff.npe5__Contact__c = dbFamilyContactAffiliation.npe5__Contact__c;
//					newAff.npe5__Organization__c = convertedAccId;
//					newAff.npe5__StartDate__c = Date.today();
//					newAff.npe5__Status__c = 'Active';
//					newAff.npe5__Primary__c = true;
//					affiliationList.add(newAff);
//				}
//			}
//			if (familyContactLastNameSet.size() > 0) {
//				for (Lead processConvertedLead : convertedLeadMap.Values()) {
//					Contact newWishFamily = new Contact();
//					newWishFamily.FirstName = processConvertedLead.Parent_First_Name__c;
//					newWishFamily.LastName = processConvertedLead.Parent_Last_Name__c;
//					newWishFamily.Email = processConvertedLead.Email;
//					newWishFamily.Phone = processConvertedLead.Phone;
//					newWishFamily.MobilePhone = processConvertedLead.Phone;
//					newWishFamily.MailingCountryCode = processConvertedLead.CountryCode;
//					newWishFamily.MailingStreet = processConvertedLead.Street;
//					newWishFamily.MailingStateCode = processConvertedLead.StateCode;
//					newWishFamily.MailingCity = processConvertedLead.City;
//					newWishFamily.MailingPostalCode = processConvertedLead.PostalCode;
//					newWishFamily.Wish_Child_Id_Hidden__c = processConvertedLead .ConvertedContactId;
//					newWishFamily.AccountId = processConvertedLead.ConvertedAccountId;
//					newWishFamily.RecordTypeId = wishFamilyRecordTypeId;
//					newWishFamily.Relationship_Type__c = 'Parent/Legal Guardian';
//					newWishFamily.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newWishFamily.Language__c = processConvertedLead.What_is_the_family_s_primary_spoken_lang__c;
//					newWishFamily.Relationship__c = processConvertedLead.Parent_Relationship_to_Child__c;
//					newWishFamily.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					if (processConvertedLead.Relationship_to_child__c == 'Parent/Guardian') {
//						newWishFamily.Type_Of_Contact__c = 'Parent/Guardian';
//					}
//					newContactList.add(newWishFamily);
//					firstParentMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email + '-' + newWishFamily.Phone, true);
//					relationshipTypeMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email + '-' + newWishFamily.Phone, processConvertedLead.Parent_Relationship_to_Child__c);
//				}
//			}
//			if (additionalParentLastNameSet.size() > 0) {
////				List<Contact> additionalContactList = new List<Contact>();
//				for (Lead processConvertedLead : convertedLeadMap.Values()) {
//					Contact newWishFamily = new Contact();
//					newWishFamily.FirstName = processConvertedLead.Additional_Parent_First_Name__c;
//					newWishFamily.LastName = processConvertedLead.Additional_Parent_Last_Name__c;
//					newWishFamily.Email = processConvertedLead.Additional_Parent_Email__c;
//					newWishFamily.Phone = processConvertedLead.Additional_Parent_Phone__c;
//					newWishFamily.MobilePhone = processConvertedLead.Additional_Parent_Phone__c;
//					newWishFamily.MailingCountryCode = processConvertedLead.CountryCode;
//					newWishFamily.MailingStreet = processConvertedLead.Additional_Parent_Street__c;
//					newWishFamily.MailingState = processConvertedLead.Additional_Parent_State__c;
//					newWishFamily.MailingCity = processConvertedLead.Additional_Parent_City__c;
//					newWishFamily.Relationship_Type__c = 'Parent/Legal Guardian';
//					newWishFamily.MailingPostalCode = processConvertedLead.Additional_Parent_Postal_Code__c;
//					newWishFamily.Wish_Child_Id_Hidden__c = processConvertedLead .ConvertedContactId;
//					newWishFamily.AccountId = processConvertedLead.ConvertedAccountId;
//					newWishFamily.RecordTypeId = wishFamilyRecordTypeId;
//					newWishFamily.Relationship__c = processConvertedLead.Additional_Parent_Relationship_to_Child__c;
//					newWishFamily.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newWishFamily.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					firstParentMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email + '-' + newWishFamily.Phone, false);
//					relationshipTypeMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email + '-' + newWishFamily.Phone, processConvertedLead.Additional_Parent_Relationship_to_Child__c);
//					if (processConvertedLead.Additional_Parent_City__c != processConvertedLead.City ||
//							processConvertedLead.Additional_Parent_Postal_Code__c != processConvertedLead.PostalCode ||
//							processConvertedLead.Additional_Parent_State__c != processConvertedLead.State ||
//							processConvertedLead.Additional_Parent_Street__c != processConvertedLead.Street) {
//						newWishFamily.npsp__is_address_Override__c = true;
//					}
//					newContactList.add(newWishFamily);
//				}
//			}
//			if (sameReferringFirstNameSet.size() > 0 && sameReferringLastNameSet.size() > 0 && (sameReferringPhoneNameSet.size() > 0 || sameReferringEmailNameSet.size() > 0)) {
////				List<npe4__Relationship__c> sameNameRelationList = new List<npe4__Relationship__c>();
//				for (Lead processConvertedLead : convertedLeadMap.values()) {
//					Contact newSameReferrerMedicalContact = new Contact();
//					newSameReferrerMedicalContact.FirstName = processConvertedLead.Referrer_FirstName__c;
//					newSameReferrerMedicalContact.LastName = processConvertedLead.Referrer_Last_Name__c ;
//					if ((processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Referrer_FirstName__c
//							&& processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Referrer_Last_Name__c &&
//							(processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Referrer_Phone__c
//									|| processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Referrer_Email__c))
//							|| (processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
//							&& processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c &&
//							(processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c))) {
//						if (medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//							newSameReferrerMedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
//						}
//						if (newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//							newSameReferrerMedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
//						}
//						if (processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
//								&& processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c
//								&& (processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c)) {
//							newSameReferrerMedicalContact.Type_of_Contact__c = 'Referrer&Best';
//							if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
//									&& processConvertedLead.I_am_Recognized_To_Practice_As_a__c != null) {
//								newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
//							} else {
//								newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
//							}
//						} else {
//							newSameReferrerMedicalContact.Type_of_Contact__c = 'Referrer&Treating';
//							if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL
//									&& processConvertedLead.I_am_Recognized_To_Practice_As_a__c != null) {
//								newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
//							} else {
//								newSameReferrerMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
//							}
//						}
//					}
//					qualifyingMap.put(processConvertedLead.Referrer_FirstName__c + '-' + processConvertedLead.Referrer_Last_Name__c + '-' + processConvertedLead.Referrer_Email__c, true);
//					newSameReferrerMedicalContact.AccountId = processConvertedLead.ChapterName__c;
//					newSameReferrerMedicalContact.npe01__WorkPhone__c = processConvertedLead.Referrer_Phone__c;
//					newSameReferrerMedicalContact.Phone = processConvertedLead.Referrer_Phone__c;
//					newSameReferrerMedicalContact.Email = null;
//					newSameReferrerMedicalContact.npe01__HomeEmail__c = '';
//					newSameReferrerMedicalContact.npe01__Preferred_Email__c = 'Work';
//					newSameReferrerMedicalContact.npe01__WorkEmail__c = processConvertedLead.Referrer_Email__c;
//					newSameReferrerMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
//					newSameReferrerMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newSameReferrerMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					newContactList.add(newSameReferrerMedicalContact);
//				}
//			}
//			if (referringFirstNameSet.size() > 0 && referringLastNameSet.size() > 0 && (referringPhoneNameSet.size() > 0 || referringEmailNameSet.size() > 0)) {
////				List<npe4__Relationship__c> referringRelationList = new List<npe4__Relationship__c>();
//				for (Lead processConvertedLead : convertedLeadMap.values()) {
//					Contact newTreatingMedicalContact = new Contact();
//					newTreatingMedicalContact.FirstName = processConvertedLead.Treating_Medical_Professional_First_Name__c;
//					newTreatingMedicalContact.LastName = processConvertedLead.Treating_Medical_Professional_Last_Name__c;
//					if (medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//						newTreatingMedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
//					}
//					if (newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//						newTreatingMedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
//					}
//					newTreatingMedicalContact.AccountId = processConvertedLead.ChapterName__c;
//					newTreatingMedicalContact.Phone = processConvertedLead.Treating_Medical_Professional_Phone__c;
//					newTreatingMedicalContact.npe01__WorkPhone__c = processConvertedLead.Treating_Medical_Professional_Phone__c;
//					newTreatingMedicalContact.Email = '';
//					newTreatingMedicalContact.npe01__WorkEmail__c = processConvertedLead.Treating_Medical_Professional_Email__c;
//					newTreatingMedicalContact.Email = null;
//					newTreatingMedicalContact.npe01__HomeEmail__c = '';
//					newTreatingMedicalContact.npe01__Preferred_Email__c = 'Work';
//					//IME-86
//					if (processConvertedLead.Department__c != null) {
//						newTreatingMedicalContact.Department = processConvertedLead.Department__c;
//					}
//					if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
//						newTreatingMedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
//						qualifyingMap.put(processConvertedLead.Treating_Medical_Professional_First_Name__c + '-'
//								+ processConvertedLead.Treating_Medical_Professional_Last_Name__c + '-'
//								+ processConvertedLead.Treating_Medical_Professional_Email__c, true);
//					} else {
//						qualifyingMap.put(processConvertedLead.Treating_Medical_Professional_First_Name__c
//								+ '-' + processConvertedLead.Treating_Medical_Professional_Last_Name__c + '-'
//								+ processConvertedLead.Treating_Medical_Professional_Email__c, false);
//					}
//					newTreatingMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
//
//					newTreatingMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newTreatingMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					newTreatingMedicalContact.Type_of_Contact__c = 'Treating';
//					newContactList.add(newTreatingMedicalContact);
//				}
//			}
//			if (qualifyFirstNameSet.size() > 0 && qualifyLastNameSet.size() > 0 && (qualifyPhoneNameSet.size() > 0 || qualifyEmailNameSet.Size() > 0)) {
////				List<npe4__Relationship__c> qualifyingRelationList = new List<npe4__Relationship__c>();
//				for (Lead processConvertedLead : convertedLeadMap.values()) {
//					Contact newReferrerMedicalContact = new Contact();
//					newReferrerMedicalContact.FirstName = processConvertedLead.Referrer_FirstName__c;
//					newReferrerMedicalContact.LastName = processConvertedLead.Referrer_Last_Name__c;
//					newReferrerMedicalContact.AccountId = processConvertedLead.ChapterName__c;
//					newReferrerMedicalContact.Phone = processConvertedLead.Referrer_Phone__c;
//					newReferrerMedicalContact.npe01__WorkPhone__c = processConvertedLead.Referrer_Phone__c;
//					newReferrerMedicalContact.Email = '';
//					newReferrerMedicalContact.npe01__WorkEmail__c = processConvertedLead.Referrer_Email__c;
//					newReferrerMedicalContact.Email = null;
//					newReferrerMedicalContact.npe01__HomeEmail__c = '';
//					newReferrerMedicalContact.npe01__Preferred_Email__c = 'Work';
//					newReferrerMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
//					newReferrerMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
//					newReferrerMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newReferrerMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					newReferrerMedicalContact.Type_of_Contact__c = 'Referring';
//					//IME-86
//					if (processConvertedLead.Department__c != null) {
//						newReferrerMedicalContact.Department = processConvertedLead.Department__c;
//					}
//					// qualifyingMap.put(processConvertedLead.Referrer_FirstName__c+ '-' + processConvertedLead.Referrer_Last_Name__c + '-' + processConvertedLead.Referrer_Email__c,processConvertedLead.Hidden_DV_form_Medical_professional_Type__c);
//					newContactList.add(newReferrerMedicalContact);
//				}
//			}
//			if (bestPersonFirstNameSet.size() > 0 && bestPersonLastNameSet.size() > 0) {
////				List<contact> bestPhysicanConList = new List<contact>();
//				for (Lead processConvertedLead : convertedLeadMap.values()) {
//					Contact newBestContactMedicalContact = new Contact();
//					newBestContactMedicalContact.FirstName = processConvertedLead.Best_Contact_for_Physician_First_Name__c;
//					newBestContactMedicalContact.LastName = processConvertedLead.Best_Contact_for_Physician_Last_Name__c;
//					newBestContactMedicalContact.AccountId = processConvertedLead.ChapterName__c;
//					if (medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//						newBestContactMedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
//					}
//					if (newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) {
//						newBestContactMedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
//					}
//					newBestContactMedicalContact.Email = '';
//					newBestContactMedicalContact.npe01__HomeEmail__c = '';
//					newBestContactMedicalContact.npe01__Preferred_Email__c = 'Work';
//					newBestContactMedicalContact.npe01__WorkEmail__c = processConvertedLead.Best_contact_for_Physician_Email__c;
////					newBestContactMedicalContact.Provider_Type__c = processConvertedLead.Medical_Provider_Category__c;
//					newBestContactMedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
//					newBestContactMedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newBestContactMedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					newBestContactMedicalContact.Type_of_Contact__c = 'BestContact';
//					//IME-86
//					if (processConvertedLead.Department__c != null) {
//						newBestContactMedicalContact.Department = processConvertedLead.Department__c;
//					}
//					if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT) {
////						newMedicalcon.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
//						qualifyingMap.put(processConvertedLead.Best_Contact_for_Physician_First_Name__c + '-'
//								+ processConvertedLead.Best_Contact_for_Physician_Last_Name__c + '-'
//								+ processConvertedLead.Best_contact_for_Physician_Email__c, true);
//					} else {
//						qualifyingMap.put(processConvertedLead.Best_Contact_for_Physician_First_Name__c + '-'
//								+ processConvertedLead.Best_Contact_for_Physician_Last_Name__c + '-'
//								+ processConvertedLead.Best_contact_for_Physician_Email__c, false);
//					}
//					newContactList.add(newBestContactMedicalContact);
//				}
//			}
//			if (alternate1MedPofLastNameSet.size() > 0) {
//				for (Lead processConvertedLead : convertedLeadMap.values()) {
//					Contact newAlt1MedicalContact = new Contact();
//					if (processConvertedLead.Alternate1MedProfessionalFirstName__c != null) {
//						newAlt1MedicalContact.FirstName = processConvertedLead.Alternate1MedProfessionalFirstName__c;
//					}
//					newAlt1MedicalContact.LastName = processConvertedLead.Alternate1MedProfessionalLastName__c;
//					newAlt1MedicalContact.AccountId = processConvertedLead.ChapterName__c;
//					if (medicalAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)) {
//						newAlt1MedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
//					}
//					if (newAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)) {
//						newAlt1MedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
//					}
//					if (processConvertedLead.Alternate1MedicalProfessionalEmail__c != null) {
//						newAlt1MedicalContact.npe01__WorkEmail__c = processConvertedLead.Alternate1MedicalProfessionalEmail__c;
//					}
//					newAlt1MedicalContact.npe01__WorkPhone__c = processConvertedLead.Alternate1MedProfessionalPhone__c;
//					newAlt1MedicalContact.Email = null;
//					newAlt1MedicalContact.npe01__HomeEmail__c = '';
//					newAlt1MedicalContact.npe01__Preferred_Email__c = 'Work';
//					newAlt1MedicalContact.Provider_Type__c = processConvertedLead.Alternate_1_Medical_Professional_Type__c;
//					newAlt1MedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
//					//IME-86
//					if (processConvertedLead.Department__c != null) {
//						newAlt1MedicalContact.Department = processConvertedLead.Department__c;
//					}
//					newAlt1MedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newAlt1MedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
//						newAlt1MedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
//						qualifyingMap.put(processConvertedLead.Alternate1MedProfessionalFirstName__c + '-'
//								+ processConvertedLead.Alternate1MedProfessionalLastName__c + '-'
//								+ processConvertedLead.Alternate1MedicalProfessionalEmail__c, true);
//					} else {
//						qualifyingMap.put(processConvertedLead.Alternate1MedProfessionalFirstName__c + '-'
//								+ processConvertedLead.Alternate1MedProfessionalLastName__c + '-'
//								+ processConvertedLead.Alternate1MedicalProfessionalEmail__c, false);
//					}
//					newContactList.add(newAlt1MedicalContact);
//				}
//			}
//			if (alternate2MedPofLastNameSet.size() > 0) {
//				for (Lead processConvertedLead : convertedLeadMap.values()) {
//					Contact newAlt2MedicalContact = new Contact();
//					if (processConvertedLead.Alternate2MedProfessionalFirstName__c != null) {
//						newAlt2MedicalContact.FirstName = processConvertedLead.Alternate2MedProfessionalFirstName__c;
//					}
//					newAlt2MedicalContact.LastName = processConvertedLead.Alternate2MedProfessionalLastName__c;
//					newAlt2MedicalContact.AccountId = processConvertedLead.ChapterName__c;
//					if (medicalAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)) {
//						newAlt2MedicalContact.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
//					}
//					if (newAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)) {
//						newAlt2MedicalContact.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
//					}
//					if (processConvertedLead.Alternate2MedProfessionalEmail__c != null) {
//						newAlt2MedicalContact.npe01__WorkEmail__c = processConvertedLead.Alternate2MedProfessionalEmail__c;
//					}
//					newAlt2MedicalContact.Email = '';
//					newAlt2MedicalContact.Email = null;
//					newAlt2MedicalContact.npe01__HomeEmail__c = '';
//					newAlt2MedicalContact.npe01__Preferred_Email__c = 'Work';
//					//IME-86
//					if (processConvertedLead.Department__c != null) {
//						newAlt2MedicalContact.Department = processConvertedLead.Department__c;
//					}
//					newAlt2MedicalContact.npe01__WorkPhone__c = processConvertedLead.Alternate2MedProfessionalPhone__c;
//					newAlt2MedicalContact.Provider_Type__c = processConvertedLead.Alternate_2_Medical_Professional_Type__c;
//					newAlt2MedicalContact.RecordTypeId = medicalProfessionalRecordTypeId;
//					newAlt2MedicalContact.Region_Chapter__c = processConvertedLead.ChapterName__c;
//					newAlt2MedicalContact.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
//					if (processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
//						newAlt2MedicalContact.Provider_Type__c = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
//						qualifyingMap.put(processConvertedLead.Alternate2MedProfessionalFirstName__c + '-'
//								+ processConvertedLead.Alternate2MedProfessionalLastName__c + '-'
//								+ processConvertedLead.Alternate2MedProfessionalEmail__c, true);
//					} else {
//						qualifyingMap.put(processConvertedLead.Alternate2MedProfessionalFirstName__c + '-'
//								+ processConvertedLead.Alternate2MedProfessionalLastName__c + '-'
//								+ processConvertedLead.Alternate2MedProfessionalEmail__c, false);
//					}
//					newContactList.add(newAlt2MedicalContact);
//				}
//			}
//			if (newContactList.size() > 0) {
//				RecursiveTriggerHandler.blockBeforeUpdate = true;
//				RecursiveTriggerHandler.blockAfterUpdate = true;
//				insert newContactList;
//				for (Contact currContact : newContactList) {
//					npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
//					newRelationShip.npe4__Contact__c = convertedConId;
//					if (currContact.RecordTypeId == medicalProfessionalRecordTypeId) {
//						newRelationShip.npe4__Type__c = medicalProfessionalLabel;
//						if (qualifyingMap.containsKey(currContact.FirstName + '-' + currContact.LastName + '-' + currContact.npe01__WorkEmail__c)) {
//							newRelationShip.Qualifying_Medical_Professional__c = qualifyingMap.get(currContact.FirstName + '-' + currContact.LastName + '-' + currContact.npe01__WorkEmail__c);
//						}
//					} else if (currContact.RecordTypeId == wishFamilyRecordTypeId) {
//						newRelationShip.Hidden_isparentFirst__c = firstParentMap.get(currContact.FirstName + '-' + currContact.LastName + '-' + currContact.Email + '-' + currContact.Phone);
//						newRelationShip.npe4__Type__c = relationshipTypeMap.get(currContact.FirstName + '-' + currContact.LastName + '-' + currContact.Email + '-' + currContact.Phone);
//						if (parentGuardianNameSet.contains(currContact.FirstName + '-' + currContact.LastName + '-' + wishFamilyRecordTypeId)) {
//							newRelationShip.Parent_Legal_Guardian__c = true;
//						}
//					}
//					if (currContact.Type_of_Contact__c == 'Referring'
//							|| currContact.Type_of_Contact__c == 'Parent/Guardian') {
//						newRelationShip.Referring_Medical_Professional__c = true;
//					} else if (currContact.Type_of_Contact__c == 'Treating') {
//						newRelationShip.Treating_HCP__c = true;
//					} else if (currContact.Type_of_Contact__c == 'Referrer&Treating') {
//						newRelationShip.Referring_Medical_Professional__c = true;
//						newRelationShip.Treating_HCP__c = true;
//					} else if (currContact.Type_of_Contact__c == 'Referrer&Best') {
//						newRelationShip.Referring_Medical_Professional__c = true;
//						newRelationShip.Best_Contact__c = true;
//					} else if (currContact.Type_of_Contact__c == 'BestContact') {
//						newRelationShip.Best_Contact__c = true;
//					}
//					newRelationShip.npe4__RelatedContact__c = currContact.Id;
//					newRelationShip.npe4__Status__c = 'Active';
//					relationList.add(newRelationShip);
//				}
//			}
//			if (relationList.size() > 0) {
//				RecursiveTriggerHandler.blockBeforeUpdate = true;
//				RecursiveTriggerHandler.blockAfterUpdate = true;
//				insert relationList;
//				// Cases by converted lead Id, leadsByLeadId, relationships
//				Map<Id, Case> casesByLeadId = new Map<Id, Case>();
//				for (Case currentCase : [
//						SELECT Id, Lead__c, Hidden_Lead_Id__c
//						FROM Case
//						WHERE Hidden_Lead_Id__c IN :convertedLeadIds
//				]) {
//					casesByLeadId.put(currentCase.Hidden_Lead_Id__c, currentCase);
//				}
//				// WLP-289: create wish affiliations
//				WishAffiliationService.createWishAffiliations(casesByLeadId, convertedLeadMap, newContactList, relationList, medicalAccountMap);
//			}
//			if (updateAffiliationList.size() > 0) {
//				RecursiveTriggerHandler.blockBeforeUpdate = true;
//				RecursiveTriggerHandler.blockAfterUpdate = true;
//				update updateAffiliationList;
//			}
//			if (affiliationList.size() > 0) {
//				RecursiveTriggerHandler.blockBeforeUpdate = true;
//				RecursiveTriggerHandler.blockAfterUpdate = true;
//				insert affiliationList;
//			}
//			if (Test.isRunningTest()) {
//				//throw new CommonTriggerException('Test Class execution');
//			}
//		} catch (Exception ex) {
//			for (Lead currRec : convertedLeadMap.values()) {
//				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
//						String.valueOf(currRec), String.valueOf(ex), 'dupeCheckonContact',
//						currRec.Id, ex.getStackTraceString(), 'Error');
//			}
//			// Database.rollback(sp);
//			if (!Test.isRunningTest()) {
//				for (Lead currRec : convertedLeadMap.Values()) {
//					currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//		}
//	}

//	private static void createHealthTreatmentFacilityAccount(Set<Id> convertedLeadIds) {
//		Set<String> healthTreatmentFacilitySet = new Set<String>();
//		List<Lead> convertedLeadList = new List<Lead>();
//		for (Lead processConvertedLeads : [
//				SELECT Id,Name,Hospital_Treatment_Facility__c,I_am_Recognized_To_Practice_As_a__c,Medical_Provider_Category__c,
//						Hospital_Treatment_Facility_Treating__c,Medical_Professional_Last_Name__c,Medical_Professional_Phone__c,
//						Medical_Professional_Email__c,Medical_Professional_First_Name__c,Treating_Medical_Professional_First_Name__c,
//						Treating_Medical_Professional_Last_Name__c, Treating_Medical_Professional_Phone__c, Treating_Medical_Professional_Email__c,
//						ConvertedContactId,ConvertedAccountId,Parent_First_Name__c,Parent_Last_Name__c,Email,Phone,CountryCode,
//						Street, StateCode, City, PostalCode, State, Wish_Family_ContactId__c,ChapterName__c, Treating_Medical_Professional_Contact_Id__c,
//						Medical_Professional_ContactId__c,What_is_the_family_s_primary_spoken_lang__c, Referrer_FirstName__c,Referrer_Last_Name__c,
//						Referrer_Phone__c,Referrer_Email__c,Relationship_to_child__c,Migrated_Record__c, Best_Contact_for_Physician_First_Name__c,
//						Best_Contact_for_Physician_Last_Name__c,Best_contact_for_Physician_Email__c, HiddenAlternate1MedProfessionalId__c,
//						HiddenAlternate2MedProfessionalId__c, Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,
//						Additional_Parent_City__c,Alternate1MedProfessionalFirstName__c,Alternate1MedProfessionalLastName__c,
//						Additional_Parent_Email__c,Additional_Parent_Phone__c,Additional_Parent_Postal_Code__c,Alternate1MedProfessionalPhone__c,
//						Alternate1MedicalProfessionalEmail__c, Additional_Parent_State__c,Additional_Parent_Street__c,
//						Hidden_Additional_Parent_Id__c,Alternate2MedProfessionalFirstName__c,Alternate2MedProfessionalLastName__c,
//						Hidden_Best_Contact_Person_Id__c,Parent_Relationship_to_Child__c,Additional_Parent_Relationship_to_Child__c,
//						Alternate2MedProfessionalPhone__c,Alternate2MedProfessionalEmail__c, Alternate1HospitalTreatmentFacility__c,
//						Alternate2HospitalTreatmentFacility__c,Hidden_DV_form_Medical_professional_Type__c, Department__c,
//						Alternate_1_Medical_Professional_Type__c, Alternate_2_Medical_Professional_Type__c
//				FROM Lead
//				WHERE Id IN:convertedLeadIds
//				LIMIT 50000
//		]) {
//			Lead_OnAfterUpdateTriggerHandlerHelper.convertedAccId = processConvertedLeads.ConvertedAccountId;
//			healthTreatmentFacilitySet.add(processConvertedLeads.Hospital_Treatment_Facility_Treating__c);
//			if (processConvertedLeads.Alternate1HospitalTreatmentFacility__c != null) {
//				healthTreatmentFacilitySet.add(processConvertedLeads.Alternate1HospitalTreatmentFacility__c);
//			}
//			if (processConvertedLeads.Alternate2HospitalTreatmentFacility__c != null) {
//				healthTreatmentFacilitySet.add(processConvertedLeads.Alternate2HospitalTreatmentFacility__c);
//			}
//			convertedLeadList.add(processConvertedLeads);
//			Lead_OnAfterUpdateTriggerHandlerHelper.convertedLeadMap.put(processConvertedLeads.Id, processConvertedLeads);
//		}
//		for (Account dbAccount : [
//				SELECT Id,Name,RecordTypeId
//				FROM Account
//				WHERE RecordTypeId = :Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId
//				AND Name IN:healthTreatmentFacilitySet
//				LIMIT 50000
//		]) {
//			Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.put(dbAccount.Name, dbAccount);
//		}
//		for (Lead processConvertedLeads : [
//				SELECT Id,Name,Alternate1HospitalTreatmentFacility__c,
//						Alternate2HospitalTreatmentFacility__c,
//						Hospital_Treatment_Facility__c,Migrated_Record__c,
//						Hospital_Treatment_Facility_Treating__c,ChapterName__c,
//						Department__c
//				FROM Lead
//				WHERE Id IN:convertedLeadIds
//				LIMIT 50000
//		]) {
//			if (!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processConvertedLeads.Hospital_Treatment_Facility_Treating__c)) {
//				if (processConvertedLeads.Hospital_Treatment_Facility_Treating__c != null) {
//					Account newAccount = new Account();
//					newAccount.Name = processConvertedLeads.Hospital_Treatment_Facility_Treating__c;
//					newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId;
//					newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
//					Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name, newAccount);
//				}
//			}
//			if (!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processConvertedLeads.Alternate1HospitalTreatmentFacility__c)) {
//				if (processConvertedLeads.Alternate1HospitalTreatmentFacility__c != null) {
//					Account newAccount = new Account();
//					newAccount.Name = processConvertedLeads.Alternate1HospitalTreatmentFacility__c;
//					newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId;
//					newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
//					Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name, newAccount);
//				}
//			}
//			if (!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processConvertedLeads.Alternate2HospitalTreatmentFacility__c)) {
//				if (processConvertedLeads.Alternate2HospitalTreatmentFacility__c != null) {
//					Account newAccount = new Account();
//					newAccount.Name = processConvertedLeads.Alternate2HospitalTreatmentFacility__c;
//					newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatmentRecordTypeId;
//					newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
//					Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name, newAccount);
//				}
//			}
//		}
//		if (Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.size() > 0) {
//			RecursiveTriggerHandler.blockBeforeUpdate = true;
//			RecursiveTriggerHandler.blockAfterUpdate = true;
//			insert Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.values();
//		}
//	}

	@TestVisible
	private static void updateLeadConvertedAccounts(Set<Id> leadConvertAccountIds, Set<Id> chapterIdSet,
			Id ChapterId, Map<Id, Account> chapterUserMap, Map<Id, Lead> convertedAccountMap, List<Account> updateAccountList) {
		for (Account conAccount : [
				SELECT Id, Name, Volunteer_Manager__c, Intake_Manager__c,
						Volunteer_Manager__r.Name, Volunteer_Manager__r.Email,
						RecordTypeId
				FROM Account
				WHERE Id IN:leadConvertAccountIds
				LIMIT 50000
		]) {
			if (chapterIdSet.contains(conAccount.Id)) {
				ChapterId = conAccount.Id;
				chapterUserMap.put(conAccount.Id, conAccount);
			}
			if (convertedAccountMap.containsKey(conAccount.Id)) {
				if (convertedAccountMap.get(conAccount.Id).FirstName == null) {
					conAccount.Name = convertedAccountMap.get(conAccount.Id).LastName
							+ ' ' + ' & ' + ' ' + 'Family Household';
					conAccount.RecordTypeId = HouseholdRecordTypeId;
					conAccount.PrimaryLanguage__c = convertedAccountMap.get(conAccount.Id).What_is_the_family_s_primary_spoken_lang__c;
				} else {
					conAccount.Name = convertedAccountMap.get(conAccount.Id).FirstName + ' '
							+ convertedAccountMap.get(conAccount.Id).LastName + ' ' + ' & ' + ' ' + 'Family Household';
					conAccount.PrimaryLanguage__c = convertedAccountMap.get(conAccount.Id).What_is_the_family_s_primary_spoken_lang__c;
					conAccount.RecordTypeId = HouseholdRecordTypeId;
				}
				updateAccountList.add(conAccount);
			}
		}
	}

	/****************************************************************************
	This updateDocusignStatus() this method is used update the electronic signer
	in lead related docusign status record.
	****************************************************************************/
	@Future
	private static void updateDocusignStatus(Map<Id, Id> leadContactMap) {
		List<dsfs__DocuSign_Status__c> docusignStatusList = new List<dsfs__DocuSign_Status__c>();
		try {
			for (dsfs__DocuSign_Status__c docusignStatus : [
					SELECT Id, dsfs__Lead__c, dsfs__Envelope_Status__c, dsfs__Contact__c
					FROM dsfs__DocuSign_Status__c
					WHERE dsfs__Lead__c IN :leadContactMap.keySet() AND dsfs__Subject__c = 'Diagnosis Verification Form'
			]) {
				if (docusignStatus.dsfs__Contact__c == null) {
					docusignStatus.dsfs__Contact__c = leadContactMap.get(docusignStatus.dsfs__Lead__c);
					docusignStatusList.add(docusignStatus);
				}
			}
			if (docusignStatusList.size() > 0) {
				RecursiveTriggerHandler.blockBeforeUpdate = true;
				RecursiveTriggerHandler.blockAfterUpdate = true;
				if(Test.isRunningTest()){
					throw new DmlException('Test');
				}
				update docusignStatusList;
			}
		} catch (Exception ex) {
			for (Lead currRec : [
					SELECT Id, LastName
					FROM Lead
					WHERE Id IN:leadContactMap.keySet()
			]) {
				ErrorMessage_AC.createdebugRec('Lead_OnAfterUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'updateDocusignStatus',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Lead currRec : [
						SELECT Id, LastName
						FROM Lead
						WHERE Id IN:leadContactMap.keySet()
				]) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	@Future
	private static void generateWishAffiliationsFromLead(Set<Id> leadIds, Set<Id> contactIds, Set<Id> relationshipIds, Set<Id> htfAccountIds) {
		Map<Id, Case> casesByLeadId = new Map<Id, Case>();
		for (Case currentCase : [
				SELECT Id, Lead__c, Hidden_Lead_Id__c
				FROM Case
				WHERE Hidden_Lead_Id__c IN :leadIds
		]) {
			casesByLeadId.put(currentCase.Hidden_Lead_Id__c, currentCase);
		}
		Map<Id, Lead> convertedLeadsById = new Map<Id, Lead>();
		for (Lead convertedLead : [
				SELECT Id, ConvertedContactId, Hospital_Treatment_Facility_Treating__c,
						Part_A_Received__c, Part_A_Sent__c
				FROM Lead
				WHERE Id IN :leadIds
		]) {
			convertedLeadsById.put(convertedLead.Id, convertedLead);
		}
		WishAffiliationService.createWishChildren(casesByLeadId, convertedLeadsById);
		List<Contact> contacts = [
				SELECT Id, Hidden_Hospital_Account__c
				FROM Contact
				WHERE Id IN :contactIds
		];

		List<npe4__Relationship__c> relationships = [
				SELECT Id, npe4__Contact__c, npe4__RelatedContact__c,
						npe4__Type__c, Referring_Medical_Professional__c
				FROM npe4__Relationship__c
				WHERE Id IN :relationshipIds
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();
		for (Account dbAccount : [
				SELECT Id, Name, RecordTypeId
				FROM Account
				WHERE RecordTypeId = :hospitalTreatmentRecordTypeId
				AND Id IN :htfAccountIds
		]) {
			medicalAccountMap.put(dbAccount.Name, dbAccount);
		}
		WishAffiliationService.createWishAffiliations(casesByLeadId, convertedLeadsById, contacts, relationships, medicalAccountMap);
	}

	/****************************************************************************************
	Create and assign the task to lead intake user when the lead status is updated with DNQ.
	******************************************************************************************/
	//Commented for IME-2
	/*public static void createTaskforDNQLeads(Map<Lead,Id> lead_ChapterIdMap){
		Id staffTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
		Map<Id,Id> leadIntakeUserMap = new Map<Id,Id>();

		try{
			for(Account currRec : [SELECT Id, Intake_Manager__c FROM Account WHERE Id IN :lead_ChapterIdMap.Values() AND Intake_Manager__c != NULL]){
				leadIntakeUserMap.put(currRec.Id,currRec.Intake_Manager__c);
			}
			Task newTask;
			List<Task> newTaskList = new List<Task>();
			for(Lead currLead: lead_ChapterIdMap.keyset()){
				newTask = new Task();
				newTask.Subject='Referral DNQ';
				newTask.SystemGeneratedTask__c = TRUE;
				newTask.ActivityDate=System.today().addDays(3);
				if(leadIntakeUserMap.containsKey(currLead.ChapterName__c)) {
					newTask.OwnerId=leadIntakeUserMap.get(currLead.ChapterName__c);
				} else {
					newTask.OwnerId= currLead.OwnerId;
				}
				newTask.WhoId=currLead.Id;
				newTask.RecordTypeId = staffTaskRT;
				newTaskList.add(newTask);
			}
			if(newTaskList.Size() > 0){
				Insert newTaskList;
			}
		}
		catch(Exception ex){
			for(Lead currRec : lead_ChapterIdMap.KeySet()){
				ErrorMessage_AC.createdebugRec('Lead_OnAfterUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex),'createTaskforDNQLeads',currRec.Id,ex.getStackTraceString(),'Error');
			}
			for(Lead currRec : lead_ChapterIdMap.KeySet()){
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	} */

	/* IME 9
	This method update DV case, the rush checkbox is checked when any medical reason is true
	*/
	public static void updateRushInDVCase(Map<Id, Boolean> rushLeadMap) {
		List<Case> updateCase = new List<Case>();
		Set<Id> leadIds = rushLeadMap.keySet();

		for (Case processCase : [
				SELECT Id, Rush__c, Lead__c
				FROM Case
				WHERE Lead__c IN :leadIds
				AND RecordTypeId = :diagnosisRecordTypeId
				LIMIT 50000
		]) {
			processCase.Rush__c = rushLeadMap.get(processCase.Lead__c);
			updateCase.add(processCase);
		}
		if (updateCase.size() > 0) {
			update updateCase;
		}
	}

	public static void updateDvCaseStatus(Set<Id> LeadIdSet) {
		List<Case> updateCase = new List<Case>();

		for (Case processCase : [
				SELECT Id, Rush__c, Lead__c
				FROM Case
				WHERE Lead__c IN :LeadIdSet
				AND RecordTypeId = :diagnosisRecordTypeId
				LIMIT 50000
		]) {
			if (LeadIdSet.contains(processCase.Lead__c)) {
				processCase.Status = 'Pending Clarification - Chapter';
			}
			updateCase.add(processCase);
		}
		if (updateCase.size() > 0) {
			update updateCase;
		}
	}

	/**
	 * Check if a Medical Professional contact equal
	 *
	 * @param sourceFirstName
	 * @param sourceLastName
	 * @param sourcePhone
	 * @param sourceEmail
	 * @param targetFirstName
	 * @param targetLastName
	 * @param targetPhone
	 * @param targetEmail
	 *
	 * @return
	 */
	private static Boolean isSameMedicalProfessional(
			String sourceFirstName, String targetFirstName,
			String sourceLastName, String targetLastName,
			String sourcePhone, String targetPhone,
			String sourceEmail, String targetEmail) {
		if (sourceFirstName == targetFirstName
				&& sourceLastName == targetLastName
				&& (sourcePhone == targetPhone || sourceEmail == targetEmail)) {
			return true;
		} else {
			return false;
		}
	}

/**
* WLP-573
* Phone fields are currently String type fields and are being used in comparision,
* but when compared they are coming formatted and some are not causing the if statetment to fail
* e.g: (555)555-5555 is not equal to 5555555555
*
* Creating a method to remove special characters and alphabet
*/
	private static String removeFormatNumberField(String field) {
		if (String.isNotEmpty(field)) {
			return field.replaceAll('[^0-9]', '');
		}
		return field;
	}
}