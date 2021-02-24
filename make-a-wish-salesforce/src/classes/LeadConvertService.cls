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
		try {
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
		} catch (Exception ex) {
			System.debug('Lead Convert Exception: ' + ex);
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadConvertService', 'convertLead', qualifiedLeadMap.values()[0].Id,
					ex, 'Lead convert process failed, please contact your administrator.'));
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

			// Get lead fields
			List<Lead> convertedLeads = LeadService.findLeadById(leadIdConvertedByContactIdMap.keySet());

			// Generate Lead Convert Wrappers from Lead
			leadConvertByWishChildId = generateLeadConvertWrapper(convertedLeads);

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

			// Set Diagnosis Verification
			caseMap = CaseService.setDVReceiveDate(docuSignStatuses, caseMap);

			// Create Files
			List<cg__ContactFile__c> contactFiles = ContactFileService.buildFilesLeadConvert(convertedLeadById);

			RecursiveTriggerHandler.blockBeforeUpdate = true;
			RecursiveTriggerHandler.blockAfterUpdate = true;
			insert contactFileFolders;
			insert contactFiles;
			update accountWishChildHousehold;
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
			System.debug('processConvertedLead ' + ex);
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
	 * @param convertedLeads converted leads
	 * @return Map of lead convert wrapper
	 */
	private static Map<Id, LeadConvertWrapper> generateLeadConvertWrapper(List<Lead> convertedLeads) {
		Map<Id, LeadConvertWrapper> wrappers = new Map<Id, LeadConvertWrapper>();
		for (Lead convertedLead : convertedLeads) {
			try {
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

				// Find Medical Contacts
				wrapper.medicalContacts = getMedicalContacts(convertedLead);

				// Relationships Wish Child to Medical Professionals
				wrapper.medicalRelationships = RelationshipService.buildLeadConvertRelationships(convertedLead).values();

				// Affiliations Wish Child to Hospital Facilities
				wrapper.treatingHospitalAffiliations = AffiliationService.buildWishChildAffiliation(convertedLead);

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
				Contact qualifyingMedicalContact = getQualifyingMedicalProfessional(wrapper.medicalRelationships, wrapper.medicalContacts);
				wrapper.qualifiedCase = CaseService.buildQualifiedCaseFromLead(convertedLead, qualifyingMedicalContact);

				// Household Account of Wish Child
				wrapper.wishChildAccount = AccountService.setHouseholdFields(convertedLead);

				wrappers.put(convertedLead.ConvertedContactId, wrapper);

			} catch (Exception ex) {
				System.debug('generateLeadConvertWrapper ' + ex);
			}
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
						Best_Contact_HTF__c, Part_A_Received__c, Part_A_Sent__c,
						Alt_1_MP__c, Alt_1_MP_HTF__c, Alt_2_MP__c, Alt_2_MP_HTF__c
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

	private static Contact getQualifyingMedicalProfessional(List<npe4__Relationship__c> relationships, Map<Id, Contact> medicalContacts) {
		for (npe4__Relationship__c relationship : relationships) {
			if (relationship.Qualifying_Medical_Professional__c && medicalContacts.containsKey(relationship.npe4__RelatedContact__c)) {
				return medicalContacts.get(relationship.npe4__RelatedContact__c);
			}
		}
		return null;
	}

	private static Map<Id, Contact> getMedicalContacts(Lead convertedLead) {
		Map<Id, Contact> mps = new Map<Id, Contact>();
		if (convertedLead.Referring_MP__c != null) {
			Contact referringMp = new Contact();
			referringMp.Id = convertedLead.Referring_MP__c;
			referringMp.FirstName = convertedLead.Referring_MP__r.FirstName;
			referringMp.LastName = convertedLead.Referring_MP__r.LastName;
			referringMp.npe01__WorkEmail__c = convertedLead.Referring_MP__r.npe01__WorkEmail__c;
			referringMp.npe01__AlternateEmail__c = convertedLead.Referring_MP__r.npe01__AlternateEmail__c;
			referringMp.Alternate_Email_2__c = convertedLead.Referring_MP__r.Alternate_Email_2__c;
			mps.put(convertedLead.Referring_MP__c, referringMp);
		}

		if (convertedLead.Treating_MP__c != null) {
			Contact treatingMp = new Contact();
			treatingMp.Id = convertedLead.Treating_MP__c;
			treatingMp.FirstName = convertedLead.Treating_MP__r.FirstName;
			treatingMp.LastName = convertedLead.Treating_MP__r.LastName;
			treatingMp.npe01__WorkEmail__c = convertedLead.Treating_MP__r.npe01__WorkEmail__c;
			treatingMp.npe01__AlternateEmail__c = convertedLead.Treating_MP__r.npe01__AlternateEmail__c;
			treatingMp.Alternate_Email_2__c = convertedLead.Treating_MP__r.Alternate_Email_2__c;
			mps.put(convertedLead.Treating_MP__c, treatingMp);
		}

		if (convertedLead.Best_Contact__c != null) {
			Contact bestContact = new Contact();
			bestContact.Id = convertedLead.Best_Contact__c;
			bestContact.FirstName = convertedLead.Best_Contact__r.FirstName;
			bestContact.LastName = convertedLead.Best_Contact__r.LastName;
			bestContact.npe01__WorkEmail__c = convertedLead.Best_Contact__r.npe01__WorkEmail__c;
			bestContact.npe01__AlternateEmail__c = convertedLead.Best_Contact__r.npe01__AlternateEmail__c;
			bestContact.Alternate_Email_2__c = convertedLead.Best_Contact__r.Alternate_Email_2__c;
			mps.put(convertedLead.Best_Contact__c, bestContact);
		}

		if (convertedLead.Alt_1_MP__c != null) {
			Contact alt1Mp = new Contact();
			alt1Mp.Id = convertedLead.Alt_1_MP__c;
			alt1Mp.FirstName = convertedLead.Alt_1_MP__r.FirstName;
			alt1Mp.LastName = convertedLead.Alt_1_MP__r.LastName;
			alt1Mp.npe01__WorkEmail__c = convertedLead.Alt_1_MP__r.npe01__WorkEmail__c;
			alt1Mp.npe01__AlternateEmail__c = convertedLead.Alt_1_MP__r.npe01__AlternateEmail__c;
			alt1Mp.Alternate_Email_2__c = convertedLead.Alt_1_MP__r.Alternate_Email_2__c;
			mps.put(convertedLead.Alt_1_MP__c, alt1Mp);
		}

		if (convertedLead.Alt_2_MP__c != null) {
			Contact alt2Mp = new Contact();
			alt2Mp.Id = convertedLead.Alt_2_MP__c;
			alt2Mp.FirstName = convertedLead.Alt_2_MP__r.FirstName;
			alt2Mp.LastName = convertedLead.Alt_2_MP__r.LastName;
			alt2Mp.npe01__WorkEmail__c = convertedLead.Alt_2_MP__r.npe01__WorkEmail__c;
			alt2Mp.npe01__AlternateEmail__c = convertedLead.Alt_2_MP__r.npe01__AlternateEmail__c;
			alt2Mp.Alternate_Email_2__c = convertedLead.Alt_2_MP__r.Alternate_Email_2__c;
			mps.put(convertedLead.Alt_2_MP__c, alt2Mp);
		}
		return mps;
	}

	public class LeadConvertWrapper {
		public Lead convertedLead { get; set; }
		public Id wishChildContactId { get; set; }
		public Account wishChildAccount { get; set; }
		public Contact wishChild { get; set; }
		public List<Contact> familyContacts { get; set; }
		public Map<Id, Contact> medicalContacts { get; set; }
		public List<npe4__Relationship__c> familyRelationships { get; set; }
		public List<npe4__Relationship__c> medicalRelationships { get; set; }
		public List<npe5__Affiliation__c> treatingHospitalAffiliations { get; set; }
		public List<Task> tasks { get; set; }
		public Case qualifiedCase { get; set; }
		public List<cg__ContactFile__c> contactFolders { get; set; }
	}
}