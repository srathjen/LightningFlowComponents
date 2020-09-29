/**
 * Created by gmayer on 05-Mar-20.
 */

public class LeadConvertService {

	/**
	 * Convert the "Qualified" leads
	 * @param qualifiedLeadMap
	 * @return Map By Lead Id and Contact Id
	 */
	public static Map<Id, Id> convertLead(Map<Id, Lead> qualifiedLeadMap) {
		RecursiveTriggerHandler.isFirstTime = false;
		Map<Id, Id> leadIdConvertedByContactIdMap = new Map<Id, Id>();
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		LeadStatus convertStatus = [
				SELECT MasterLabel
				FROM LeadStatus
				WHERE IsConverted = TRUE
				LIMIT 1
		];
		for (Lead lead : qualifiedLeadMap.values()) {
			// Add all updated leads to the LeadConvert object
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(lead.Id);
			lc.setDoNotCreateOpportunity(true);
			lc.setConvertedStatus(convertStatus.MasterLabel);
			leadConverts.add(lc);
		}
		if (!leadConverts.isEmpty()) {
			List<Database.LeadConvertResult> convertResults = Database.convertLead(leadConverts);
			for (Database.LeadConvertResult leadResult : convertResults) {
				leadIdConvertedByContactIdMap.put(leadResult.getLeadId(), leadResult.getContactId());
			}
		}
		return leadIdConvertedByContactIdMap;
	}
	/**
	 * Process the "Qualified" leads, create a new wish child, wish family and medical professionals contact
	 * checking for any potential duplicate records.
	 * @param leadIdConvertedByContactIdMap
	 */
	public static void processConvertedLead(Map<Id, Id> leadIdConvertedByContactIdMap) {
		Map<Id, LeadConvertWrapper> leadConvertByWishChildId = new Map<Id, LeadConvertWrapper>();
		try {
			if (leadIdConvertedByContactIdMap.isEmpty()) {
				return;
			}
			// Generate Lead Convert Wrappers from Lead
			leadConvertByWishChildId = generateLeadConvertWrapper(leadIdConvertedByContactIdMap);
			Map<Id, Lead> convertedLeadById = new Map<Id, Lead>();
			Map<Id, Case> caseMap = new Map<Id, Case>();
			List<cg__ContactFile__c> contactFileFolders = new List<cg__ContactFile__c>();
			List<Account> accountWishChildHousehold = new List<Account>();
			List<Contact> wishChildUpdates = new List<Contact>();
			List<Task> tasks = new List<Task>();
			List<Contact> leadConvertNewContacts = new List<Contact>();
			List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
			List<npe5__Affiliation__c> affiliations = new List<npe5__Affiliation__c>();
			for (LeadConvertWrapper wrapper : leadConvertByWishChildId.values()) {
				convertedLeadById.put(wrapper.convertedLead.Id, wrapper.convertedLead);
				wishChildUpdates.add(wrapper.wishChild);
				accountWishChildHousehold.add(wrapper.wishChildAccount);
				if (wrapper.qualifiedCase != null) {
					caseMap.put(wrapper.convertedLead.Id, wrapper.qualifiedCase);
				}
				contactFileFolders.addAll(wrapper.contactFolders);
				tasks.addAll(wrapper.tasks);
				leadConvertNewContacts.addAll(wrapper.familyContacts);
				relationships.addAll(wrapper.medicalRelationships);
				affiliations.addAll(wrapper.treatingHospitalAffiliations);
			}

			// Update Diagnosis Verification with converted Wish Child Contact Id
			DiagnosisVerificationService.updateContact(convertedLeadById);

			// Update Docusign Status Contact to be the converted Wish Child Id
			updateElectronicSigner(leadIdConvertedByContactIdMap);

			// Find any existing Diagnosis Verification Review Cases
			Map<Id, Case> existingDiagnosisVerificationCaseMap =
					CaseService.findCaseByLeadIdAndRecordType(convertedLeadById.keySet(), Constant_AC.DIAGNOSIS_RT_ID);

			// Find any existing Diagnosis Verification Review Cases
			List<Case> partACaseList = CaseService.setWishChildIdPartACases(convertedLeadById, existingDiagnosisVerificationCaseMap);

			// Find any existing Diagnosis Verification Review Cases
			CaseService.setCaseAsRush(caseMap, existingDiagnosisVerificationCaseMap);

			// Find Docusign Status already Completed
			List<dsfs__DocuSign_Status__c> docuSignStatuses = DocuSignService.findByLeadAndEnvelopeStatus(
					convertedLeadById.keySet(), Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED);

			// Update Completed Docusign Status Contact to be the converted Wish Child Id
			List<dsfs__DocuSign_Status__c > dsfsList = DocuSignService.setContact(docuSignStatuses, convertedLeadById);

			// Set Diagnosis Verification
			caseMap = CaseService.setDVReceiveDate(docuSignStatuses, caseMap);

			// Create Files
			List<cg__ContactFile__c> contactFiles = ContactFileService.buildFilesLeadConvert(convertedLeadById);

			RecursiveTriggerHandler.blockBeforeUpdate = true;
			RecursiveTriggerHandler.blockAfterUpdate = true;
			insert contactFileFolders;
			insert contactFiles;
			update accountWishChildHousehold;
			update dsfsList;
			update partACaseList;
			update wishChildUpdates;
			insert caseMap.values();
			insert tasks;
			insert leadConvertNewContacts;
			for (LeadConvertWrapper leadConvertWrapper : leadConvertByWishChildId.values()) {
				leadConvertWrapper.familyRelationships = RelationshipService.buildWishFamilyLeadConvertRelationship(leadConvertNewContacts);
				relationships.addAll(leadConvertWrapper.familyRelationships);
			}
			insert relationships;
			insert affiliations;

			// Generate Wish Affiliations
			Set<Id> relationshipIds = new Set<Id>();
			for (npe4__Relationship__c rel : relationships) {
				relationshipIds.add(rel.Id);
			}
			generateWishAffiliationsFromLead(convertedLeadById.keySet(), relationshipIds);
		} catch (Exception ex) {
			for (LeadConvertWrapper wrapper : leadConvertByWishChildId.values()) {
				ErrorMessage_AC.createDebugRec('LeadConvertService',
						String.valueOf(wrapper.convertedLead), String.valueOf(ex), 'convertLead',
						wrapper.convertedLead.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					wrapper.convertedLead.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * @description Build objects to insert, update from the Converted Leads
	 * @param leadIdConvertedByContactIdMap lead map
	 * @return Map of lead convert wrapper
	 */
	private static Map<Id, LeadConvertWrapper> generateLeadConvertWrapper(Map<Id, Id> leadIdConvertedByContactIdMap) {
		Map<Id, LeadConvertWrapper> wrappers = new Map<Id, LeadConvertWrapper>();
		for (Lead convertedLead : [
				SELECT Id, Name, DOB__c, FirstName, Why_do_you_feel_would_be_eligible_Wish__c, LastName, CreatedDate, Migrated_Record__c,
						I_am_Recognized_To_Practice_As_a__c, Sibling_Detail__c, Medical_Provider_Category__c,
						ChapterName__r.Name, ChapterName__c, Treating_Medical_Professional_First_Name__c, ConvertedContactId, ConvertedAccountId,
						Other_Relationship_To_Child__c, Relationship_to_child__c, LeadSource, Treating_Medical_Professional_Phone__c,
						Treating_Medical_Professional_Email__c, is_Family_Aware_of_Referral__c, Treating_Medical_Professional_Last_Name__c, Referrer_City__c,
						Referrer_Email__c, Referrer_FirstName__c, Referrer_Last_Name__c, Referrer_Phone__c, Referrer_Zip__c,
						Parent_First_Name__c, Alternate1MedProfessionalPhone__c, Alternate1MedicalProfessionalEmail__c,
						Alternate1MedProfessionalFirstName__c, Alternate1MedProfessionalLastName__c,
						What_is_the_family_s_primary_spoken_lang__c, Parent_Last_Name__c, Email,
						Phone, City, Alternate2MedProfessionalFirstName__c, Alternate2MedProfessionalEmail__c,
						Alternate2MedProfessionalLastName__c, Alternate2MedProfessionalPhone__c,
						CountryCode, PostalCode, State, StateCode, Street, Treating_Medical_Professional_Contact_Id__c,
						Medical_Professional_ContactId__c, Wish_Family_ContactId__c, Best_contact_for_Physician_Email__c,
						Best_Contact_for_Physician_First_Name__c, Best_Contact_for_Physician_Last_Name__c, Best_contact_for_Physician_Phone__c,
						Additional_Parent_First_Name__c, Additional_Parent_Last_Name__c, Additional_Parent_City__c,
						Additional_Parent_Email__c, Additional_Parent_Phone__c, Additional_Parent_Postal_Code__c,
						Additional_Parent_State__c, Additional_Parent_Street__c, Hidden_Additional_Parent_Id__c,
						Hidden_Best_Contact_Person_Id__c, Parent_Relationship_to_Child__c, HiddenAlternate1MedProfessionalId__c,
						HiddenAlternate2MedProfessionalId__c, Self_describe_comment_box__c, Child_Age__c, Gender__c, Hidden_DV_form_Medical_professional_Type__c,
						Additional_Parent_Relationship_to_Child__c, How_Did_you_hear_about_Make_A_Wish__c, Other_Medical_Provider_Category__c,
						Any_medical_reason_for_moving_quickly__c, Department__c, Hospital_Treatment_Facility_Treating__c, Part_A_Received__c,
						Part_A_Sent__c, ChapterName__r.Qualified_Wish_Owner__c, Alternate_1_Medical_Professional_Type__c, Alternate_2_Medical_Professional_Type__c,
						Alternate1HospitalTreatmentFacility__c, Alternate2HospitalTreatmentFacility__c, Qualified_Date__c, PD_Condition_Description__c, Rush__c,
						Please_Explain__c, Referred_Date__c, Inquiry_Date__c, Out_of_Territory__c, unique_wish_identifier__c,
						Will_Child_s_Condition_Deteriorate__c, Please_Explain_Deteriorate__c, Expedite_timeframe__c,
						Referring_MP__r.Name, Referring_MP__r.npe01__WorkEmail__c, Referring_MP__r.npe01__AlternateEmail__c,
						Referring_MP__r.Alternate_Email_2__c, Referring_MP_HTF__c, Treating_MP__c, Treating_MP__r.Name,
						Treating_MP__r.npe01__WorkEmail__c, Treating_MP__r.npe01__AlternateEmail__c,
						Treating_MP__r.Alternate_Email_2__c, Treating_MP_HTF__c, Best_Contact__c, Best_Contact__r.Name,
						Best_Contact__r.npe01__WorkEmail__c, Best_Contact__r.npe01__AlternateEmail__c,
						Best_Contact__r.Alternate_Email_2__c, Best_Contact_HTF__c, Alt_1_MP__c, Alt_1_MP__r.Name,
						Alt_1_MP__r.npe01__WorkEmail__c, Alt_1_MP__r.npe01__AlternateEmail__c, Alt_1_MP__r.Alternate_Email_2__c,
						Alt_1_MP_HTF__c, Alt_2_MP__c, Alt_2_MP__r.Name, Alt_2_MP__r.npe01__WorkEmail__c, Alt_2_MP__r.npe01__AlternateEmail__c,
						Alt_2_MP__r.Alternate_Email_2__c, Alt_2_MP_HTF__c, ConvertedContact.Id, ConvertedContact.OwnerId,
						ConvertedAccount.Id, ConvertedAccount.Name, ConvertedAccount.Volunteer_Manager__c, ConvertedAccount.Intake_Manager__c,
						ConvertedAccount.Volunteer_Manager__r.Name, ConvertedAccount.Volunteer_Manager__r.Email, ConvertedAccount.RecordTypeId
				FROM Lead
				WHERE Id IN:leadIdConvertedByContactIdMap.keySet()
		]) {
			LeadConvertWrapper wrapper = new LeadConvertWrapper();
			// Set the source Lead
			wrapper.convertedLead = convertedLead;

			// Update fields on converted Wish Child Contact
			wrapper.wishChild = ContactService.buildWishChildFromLead(convertedLead);

			// Create Family Contacts
			// Siblings of Wish Child
			wrapper.familyContacts = new List<Contact>();
			wrapper.familyContacts.addAll(extractSiblingContacts(convertedLead));

			// Parent/Legal Guardian of Wish Child
			if (convertedLead.Parent_Last_Name__c != null && convertedLead.Wish_Family_ContactId__c == null) {
				wrapper.familyContacts.add(ContactService.buildParentLegalGuardianFromLead(convertedLead));
			}

			// Additional Parent/Legal Guardian of Wish Child
			if (convertedLead.Additional_Parent_Last_Name__c != null && convertedLead.Hidden_Additional_Parent_Id__c == null) {
				wrapper.familyContacts.add(ContactService.buildAdditionalParentLegalGuardianFromLead(convertedLead));
			}

			// Relationships Wish Child to Medical Professionals
			wrapper.medicalRelationships = RelationshipService.buildLeadConvertRelationships(convertedLead).values();

			// Affiliations Wish Child to Hospital Facilities
			wrapper.treatingHospitalAffiliations = AffiliationService.buildTreatingHospitalAffiliation(convertedLead);

			// Folders
			wrapper.contactFolders = ContactFileService.buildFileFoldersLeadConvert(convertedLead.ConvertedContactId);

			// Welcome Letter Task
			wrapper.tasks = new List<Task>();
			wrapper.tasks.add(TaskService.buildSendWelcomeLetter(convertedLead.ConvertedContactId, convertedLead.ConvertedContact.OwnerId));

			// Rush Task
			if (convertedLead.Any_medical_reason_for_moving_quickly__c.containsIgnoreCase(Constant_AC.LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES)) {
				wrapper.tasks.add(TaskService.buildRush(convertedLead.ConvertedContactId));
			}

			// Qualified Case
			wrapper.qualifiedCase = CaseService.buildQualifiedCaseFromLead(convertedLead);

			// Household Account of Wish Child
			wrapper.wishChildAccount = AccountService.setHouseholdFields(convertedLead);

			wrappers.put(convertedLead.ConvertedContactId, wrapper);
		}
		return wrappers;
	}

	/**
    * @description Extract Sibling Contact information from converted Lead
    * @param convertedLead lead
    * @return List of Sibling Contacts to create
    */
	private static List<Contact> extractSiblingContacts(Lead convertedLead) {
		List<Contact> siblingContacts = new List<Contact>();
		String DASH = '-';
		if (String.isNotEmpty(convertedLead.Sibling_Detail__c)) {
			if (convertedLead.Sibling_Detail__c.contains('<br>')) {
				for (String currSiblings : convertedLead.Sibling_Detail__c.split('<br>')) {
					if (currSiblings.contains('|')) {
						List<String> siblingDetails = currSiblings.split('\\|');
						if (siblingDetails.size() == 3) {
							String fName = siblingDetails[0].trim();
							String lName = siblingDetails[1].trim();
							String age = siblingDetails[2].trim();
							if (String.isNotEmpty(lName) && lName.equals(DASH)) {
								lName = Constant_AC.CONTACT_NAME_UNKNOWN;
							}
							if (String.isNotEmpty(fName) && !fName.equals(DASH)
									&& String.isNotEmpty(age) && !age.equals(DASH)) {
								Contact newFamily = new Contact();
								newFamily.FirstName = fName;
								newFamily.LastName = lName;
								newFamily.Sibling_Age__c = age;
								newFamily.Wish_Child_Id_Hidden__c = convertedLead.ConvertedContactId;
								newFamily.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
								newFamily.AccountId = convertedLead.ConvertedAccountId;
								newFamily.Region_Chapter__c = convertedLead.ChapterName__c;
								newFamily.Language__c = convertedLead.What_is_the_family_s_primary_spoken_lang__c;
								newFamily.Type_of_Contact__c = Constant_AC.CONTACT_TYPE_SIBLING;
								siblingContacts.add(newFamily);
							}
						}
					}
				}
			} else if (convertedLead.Sibling_Detail__c.contains('|')) {
				List<String> siblingDetails = convertedLead.Sibling_Detail__c.split('\\|');
				if (siblingDetails.size() == 3) {
					String fName = siblingDetails[0].trim();
					String lName = siblingDetails[1].trim();
					String age = siblingDetails[2].trim();
					if (String.isNotEmpty(fName) && !fName.equals(DASH)
							&& String.isNotEmpty(age) && !age.equals(DASH)) {
						Contact newFamily = new Contact();
						newFamily.FirstName = fName;
						newFamily.LastName = lName;
						newFamily.Sibling_Age__c = age;
						newFamily.Wish_Child_Id_Hidden__c = convertedLead.ConvertedContactId;
						newFamily.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
						newFamily.AccountId = convertedLead.ConvertedAccountId;
						newFamily.Region_Chapter__c = convertedLead.ChapterName__c;
						newFamily.Language__c = convertedLead.What_is_the_family_s_primary_spoken_lang__c;
						newFamily.Type_of_Contact__c = Constant_AC.CONTACT_TYPE_SIBLING;
						siblingContacts.add(newFamily);
					}
				}
			}
		}
		return siblingContacts;
	}

	/**
	 * @description Asynchronously update the electronic signer on DocuSign status record related to lead
	 * @param leadContactMap lead contact map
	 */
	@Future
	private static void updateElectronicSigner(Map<Id, Id> leadContactMap) {
		DocuSignService.updateElectronicSigner(leadContactMap, Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM);
	}

	/**
	 * @description Asynchronously generate Wish Affiliations from Converted Lead
	 * @param leadIds lead ids
	 * @param relationshipIds relationship ids
	 */
	@Future
	private static void generateWishAffiliationsFromLead(Set<Id> leadIds, Set<Id> relationshipIds) {
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
				SELECT Id, ConvertedContactId, Referring_MP_HTF__c, Treating_MP_HTF__c,
						Best_Contact_HTF__c, Part_A_Received__c, Part_A_Sent__c
				FROM Lead
				WHERE Id IN :leadIds
		]) {
			convertedLeadsById.put(convertedLead.Id, convertedLead);
		}
		WishAffiliationService.createWishChildren(casesByLeadId, convertedLeadsById);
		List<npe4__Relationship__c> relationships = [
				SELECT Id, npe4__Contact__c, npe4__RelatedContact__c,
						npe4__Type__c, Referring_Medical_Professional__c,
						Treating_HCP__c, Best_Contact__c
				FROM npe4__Relationship__c
				WHERE Id IN :relationshipIds
		];
		WishAffiliationService.createWishAffiliations(casesByLeadId, convertedLeadsById, relationships);
	}

	public class LeadConvertWrapper {
		public Lead convertedLead { get; set; }
		public Id wishChildContactId { get; set; }
		public Account wishChildAccount { get; set; }
		public Contact wishChild { get; set; }
		public List<Contact> familyContacts { get; set; }
		public List<npe4__Relationship__c> familyRelationships { get; set; }
		public List<npe4__Relationship__c> medicalRelationships { get; set; }
		public List<npe5__Affiliation__c> treatingHospitalAffiliations { get; set; }
		public List<Task> tasks { get; set; }
		public Case qualifiedCase { get; set; }
		public List<cg__ContactFile__c> contactFolders { get; set; }
	}
}