/**
 * @description Create Wish Affiliation records for converted leads
 * @author Mason Buhler, Traction on Demand
 * @date 6/20/2019
 */
public without sharing class WishAffiliationService {

	private static final String WISH_AFFILIATION_API_NAME = Constant_AC.WISH_AFFILIATION_API_NAME;
	private static final String CONTACT_API_NAME = Constant_AC.CONTACT_API_NAME;
	private static final String RELATIONSHIP_API_NAME = Constant_AC.RELATIONSHIP_API_NAME;
	private static final String WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME = Constant_AC.WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME;
	private static final String WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME = Constant_AC.WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME;
	private static final String CONTACT_FIRSTNAME_API_NAME = Constant_AC.CONTACT_FIRSTNAME_API_NAME;
	private static final String CONTACT_MIDDLENAME_API_NAME = 'Middle_Name__c';
	private static final String CONTACT_LASTNAME_API_NAME = Constant_AC.CONTACT_LASTNAME_API_NAME;
	private static final String CONTACT_BIRTHDATE_API_NAME = Constant_AC.CONTACT_BIRTHDATE_API_NAME;
	private static final String CONTACT_MAILINGSTREET_API_NAME = Constant_AC.CONTACT_MAILINGSTREET_API_NAME;
	private static final String CONTACT_MAILINGCITY_API_NAME = Constant_AC.CONTACT_MAILINGCITY_API_NAME;
	private static final String CONTACT_MAILINGSTATE_API_NAME = Constant_AC.CONTACT_MAILINGSTATE_API_NAME;
	private static final String CONTACT_MAILINGPOSTALCODE_API_NAME = Constant_AC.CONTACT_MAILINGPOSTALCODE_API_NAME;
	private static final String CONTACT_NPE01_PREFERREDPHONE_API_NAME = Constant_AC.CONTACT_NPE01_PREFERREDPHONE_API_NAME;
	private static final String CONTACT_PHONE_API_NAME = Constant_AC.CONTACT_PHONE_API_NAME;
	private static final String CONTACT_NPE01_HOMEEMAIL_API_NAME = Constant_AC.CONTACT_NPE01_HOMEEMAIL_API_NAME;
	private static final String RELATIONSHIP_NPE4_TYPE_API_NAME = Constant_AC.RELATIONSHIP_NPE4_TYPE_API_NAME;
	private static final String RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME = Constant_AC.RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME;
	private static final String CONTACT_PHONE_HOME = Constant_AC.CONTACT_PHONE_HOME;
	private static final String CONTACT_PHONE_MOBILE = Constant_AC.CONTACT_PHONE_MOBILE;
	private static final String CONTACT_PHONE_OTHER = Constant_AC.CONTACT_PHONE_OTHER;
	private static final String CONTACT_PHONE_WORK = Constant_AC.CONTACT_PHONE_WORK;
	private static final String WISH_CHANGE_REQUEST_STATUS_PROPOSED = Constant_AC.WISH_CHANGE_REQUEST_STATUS_PROPOSED;
	private static final String CONTACT_GENDER = 'Gender__c';
	private static final String CONTACT_PREFERRED_NAME = 'Preferred_Name__c';
	private static final String CONTACT_MOBILE_PHONE = 'MobilePhone';

	/**
	 * @description Create wish affiliations for each wish child
	 * @param newCasesByLeadId Map of new cases by lead Id
	 * @param convertedLeadsById Map of all converted leads
	 * @return
	 */
	public static List<Wish_Affiliation__c> createWishChildren(Map<Id, Case> newCasesByLeadId, Map<Id, Lead> convertedLeadsById) {
		// Duplicate leads exist in convertedLeadsById, so re-map them
		Map<Id, Lead> leadsById = new Map<Id, Lead>();
		for (Lead currentLead : convertedLeadsById.values()) {
			leadsById.put(currentLead.Id, currentLead);
		}
		// Create the wish child affiliations
		List<Wish_Affiliation__c> affiliationsToInsert = new List<Wish_Affiliation__c>();
		for (Lead currentLead : leadsById.values()) {
			Case currentCase = newCasesByLeadId.get(currentLead.Id);
			if (currentCase != null) {
				Wish_Affiliation__c affiliation = createNewWishAffiliation(currentCase.Id, null, Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD);
				affiliation.Contact__c = currentLead.ConvertedContactId;
				affiliationsToInsert.add(affiliation);
			}
		}

		if (!affiliationsToInsert.isEmpty()) {
			insert affiliationsToInsert;
		}
		return affiliationsToInsert;
	}

	/**
	 * @description Create wish affiliations for all other wish participants
	 * @param newCasesByLeadId Map of new cases by lead Id
	 * @param convertedLeadsById Map of all converted leads
	 * @param contacts contacts
	 * @param relationships List of new relationships
	 * @param medicalAccountMap Map of medical facility accounts by facility name
	 * @return Wish Affiliations
	 */
	public static List<Wish_Affiliation__c> createWishAffiliations(Map<Id, Case> newCasesByLeadId, Map<Id, Lead> convertedLeadsById,
			List<npe4__Relationship__c> relationships) {
		// Duplicate leads exist in convertedLeadsById, so re-map them
		Map<Id, Lead> leadsById = new Map<Id, Lead>();
		for (Lead currentLead : convertedLeadsById.values()) {
			leadsById.put(currentLead.Id, currentLead);
		}
		// Map relationships by contact Id
		Map<Id, List<npe4__Relationship__c>> relationshipsByContactId = new Map<Id, List<npe4__Relationship__c>>();
		for (npe4__Relationship__c currentRelationship : relationships) {
			if (!relationshipsByContactId.containsKey(currentRelationship.npe4__Contact__c)) {
				relationshipsByContactId.put(currentRelationship.npe4__Contact__c, new List<npe4__Relationship__c>());
			}
			relationshipsByContactId.get(currentRelationship.npe4__Contact__c).add(currentRelationship);
		}
		// Create the wish affiliations
		List<Wish_Affiliation__c> affiliationsToInsert = new List<Wish_Affiliation__c>();
		for (Lead lead : leadsById.values()) {
			Id contactId = lead.ConvertedContactId;
			Case currentCase = newCasesByLeadId.get(lead.Id);
			List<npe4__Relationship__c> currentRelationships = relationshipsByContactId.get(contactId);
			if (currentCase != null && currentRelationships != null) {
				for (npe4__Relationship__c rel : currentRelationships) {
					// Medical professional
					if (rel.npe4__Type__c == Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL) {
						Wish_Affiliation__c wishAffiliation = createNewWishAffiliation(currentCase.Id, rel, Constant_AC.WISH_AFFILIATION_TYPE_MEDICAL_PROFESSIONAL);
						wishAffiliation.Created_Via_Lead_Convert__c = true;
						if (rel.Referring_Medical_Professional__c && lead.Referring_MP_HTF__c != null) {
							wishAffiliation.Health_Treatment_Facility__c = lead.Referring_MP_HTF__c;
							affiliationsToInsert.add(wishAffiliation);
						} else if (rel.Treating_HCP__c && lead.Treating_MP_HTF__c != null) {
							wishAffiliation.Health_Treatment_Facility__c = lead.Treating_MP_HTF__c;
							affiliationsToInsert.add(wishAffiliation);
						} else if (rel.Best_Contact__c && lead.Best_Contact_HTF__c != null) {
							wishAffiliation.Health_Treatment_Facility__c = lead.Best_Contact_HTF__c;
							affiliationsToInsert.add(wishAffiliation);
						} else if (lead.Alt_1_MP__c != null && rel.npe4__RelatedContact__c == lead.Alt_1_MP__c && lead.Alt_1_MP_HTF__c != null) {
							wishAffiliation.Health_Treatment_Facility__c = lead.Alt_1_MP_HTF__c;
							affiliationsToInsert.add(wishAffiliation);
						} else if (lead.Alt_2_MP__c != null && rel.npe4__RelatedContact__c == lead.Alt_2_MP__c && lead.Alt_2_MP_HTF__c != null) {
							wishAffiliation.Health_Treatment_Facility__c = lead.Alt_2_MP_HTF__c;
							affiliationsToInsert.add(wishAffiliation);
						}
					} else {
						Wish_Affiliation__c affiliation = createNewWishAffiliation(currentCase.Id, rel, Constant_AC.WISH_AFFILIATION_TYPE_OTHER);
						affiliationsToInsert.add(affiliation);
					}
				}
			}
		}
		if (!affiliationsToInsert.isEmpty()) {
			insert affiliationsToInsert;
			WishRequiredSignatureService.createWishSignaturesForConvertedLeads(newCasesByLeadId, convertedLeadsById);
		}
		return affiliationsToInsert;
	}

	/**
	 * @description WLP-363
	 * Update Wish Affiliation from the list of Approved Wish Change Requests.
	 * The Map holds the Id of Wish Affiliation and the Wish Affiliation's Change Requests
	 * @param wishChangeRequestsMapByWishAffiliationId
	 * @return
	 */
	public static Map<String, List<SObject>> updateWishAffiliationOfApprovedWishChangeRequests(Map<Id, List<Wish_Change_Request__c>> wishChangeRequestsMapByWishAffiliationId) {
		List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
		List<Contact> contacts = new List<Contact>();
		List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
		for (Id wishAffiliationWithChangeRequest : wishChangeRequestsMapByWishAffiliationId.keySet()) {
			Wish_Affiliation__c updateWishAffiliation = new Wish_Affiliation__c();
			Contact updateContact = new Contact();
			npe4__Relationship__c updateRelationship = new npe4__Relationship__c();
			for (Wish_Change_Request__c wishChangeRequest : wishChangeRequestsMapByWishAffiliationId.get(wishAffiliationWithChangeRequest)) {
				/**
				 * Wish Affiliation fields
				 */
				if (WISH_AFFILIATION_API_NAME.equals(wishChangeRequest.Object_API_Name_for_Proposed_Change__c)) {
					updateWishAffiliation.Id = wishChangeRequest.Record_Id__c;
					if (WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateWishAffiliation.Wish_Affiliation_Type__c = wishChangeRequest.Field_New_Value__c;
					} else if (WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateWishAffiliation.Residing_with_Wish_child__c = wishChangeRequest.Field_New_Value__c;
					}
				}
				/**
				* Contact fields
				*/
				if (CONTACT_API_NAME.equals(wishChangeRequest.Object_API_Name_for_Proposed_Change__c)) {
					updateContact.Id = wishChangeRequest.Record_Id__c;
					if (CONTACT_FIRSTNAME_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.FirstName = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_MIDDLENAME_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.Middle_Name__c = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_LASTNAME_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.LastName = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_PREFERRED_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.Preferred_Contact_Name__c = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_BIRTHDATE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						if (String.isNotEmpty(wishChangeRequest.Field_New_Value__c)) {
							/**
							 * WLP-656
							 * Field parsing needs to conform in what format the field was created in
							 * WishAffiliation_AC.buildWishChangeRequests
							 */
							Date birthDate;
							String birthDateFormat = Utils.DATE_FORMAT_MDDYYYY;
							try {
								birthDate = Utils.parseDate(wishChangeRequest.Field_New_Value__c, birthDateFormat);
								if (birthDate != null) {
									updateContact.Birthdate = birthDate;
								}
							} catch (Utils.UtilsException e) {
								wishChangeRequest.Field_New_Value__c.addError(Label.Wish_Change_Request_Error_Date_Format + ' ' + birthDateFormat);
							}
						} else {
							updateContact.Birthdate = null;
						}
					} else if (CONTACT_MAILINGSTREET_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.MailingStreet = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_MAILINGCITY_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.MailingCity = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_MAILINGSTATE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.MailingState = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_MAILINGPOSTALCODE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.MailingPostalCode = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_NPE01_PREFERREDPHONE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.npe01__PreferredPhone__c = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_PHONE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						if (String.isNotEmpty(wishChangeRequest.Field_New_Value__c)) {
							updateContact.Phone = wishChangeRequest.Field_New_Value__c;
						} else {
							updateContact.Phone = '';
						}
					} else if (CONTACT_MOBILE_PHONE.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.MobilePhone = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_NPE01_HOMEEMAIL_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.npe01__HomeEmail__c = wishChangeRequest.Field_New_Value__c;
					} else if (CONTACT_GENDER.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateContact.Gender__c = wishChangeRequest.Field_New_Value__c;
					}
				}
				/**
				 * Relationship fields
				*/
				if (RELATIONSHIP_API_NAME.equals(wishChangeRequest.Object_API_Name_for_Proposed_Change__c)) {
					updateRelationship.Id = wishChangeRequest.Record_Id__c;
					if (RELATIONSHIP_NPE4_TYPE_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateRelationship.npe4__Type__c = wishChangeRequest.Field_New_Value__c;
					} else if (RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME.equals(wishChangeRequest.Field_API_Name_for_Proposed_Change__c)) {
						updateRelationship.Parent_Legal_Guardian__c = Boolean.valueOf(wishChangeRequest.Field_New_Value__c);
					}
				}
			}
			if (updateWishAffiliation.Id != null) {
				wishAffiliations.add(updateWishAffiliation);
			}
			if (updateContact.Id != null) {
				Contact contactWithUpdatedSpecificPhoneField = updateSpecificPhoneField(updateContact);
				contacts.add(contactWithUpdatedSpecificPhoneField);
			}
			if (updateRelationship.Id != null) {
				relationships.add(updateRelationship);
			}
		}
		update wishAffiliations;
		update contacts;
		update relationships;
		Map<String, List<SObject>> wishAffiliationsUpdated = new Map<String, List<SObject>>();
		wishAffiliationsUpdated.put(WISH_AFFILIATION_API_NAME, wishAffiliations);
		wishAffiliationsUpdated.put(CONTACT_API_NAME, contacts);
		wishAffiliationsUpdated.put(RELATIONSHIP_API_NAME, relationships);
		return wishAffiliationsUpdated;
	}

	/**
	 * @description Check if Contact is already on a Wish Affiliation within the same Case
	 * @param contact
	 * @param caseRecordId
	 * @return String
	 */
	public static String isContactAlreadyWishAffiliation(Contact contact, Id caseRecordId) {
		List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
		wishAffiliations = [
				SELECT Id, Name
				FROM Wish_Affiliation__c
				WHERE Wish__c = :caseRecordId
				AND Contact__r.Id = :contact.Id
		];
		if (wishAffiliations.isEmpty()) {
			return '';
		} else {
			String wishAffiliationNames = '';
			for (Wish_Affiliation__c wf : wishAffiliations) {
				wishAffiliationNames += ' ' + wf.Name;
			}
			return wishAffiliationNames;
		}
	}

	/**
	 * @description Find Wish Affiliation Types not belonging to a particular Category
	 * @param affiliationCategory
	 * @param returnValuesMap
	 * @return List of Wish Affiliation Types
	 */
	public static List<String> findWishAffiliationTypesByCategory(String affiliationCategory, Map<Object, Object> returnValuesMap) {
		List<String> wishTypes = new List<String>();
		for (Wish_Affiliation_Category__mdt type : [
				SELECT Type__c, Is_Default_for_Category__c
				FROM Wish_Affiliation_Category__mdt
				WHERE Category__c = :affiliationCategory
		]) {
			wishTypes.add(type.Type__c);
			if (type.Is_Default_for_Category__c) {
				returnValuesMap.put('wishAffiliationTypesOfCategoryDefault', type.Type__c);
			}
		}
		return wishTypes;
	}

	/**
	 * @description Find Wish Affiliation Types not belonging to a particular Category
	 * @param affiliationCategory
	 * @return List of Wish Affiliation Types
	 */
	public static List<String> findWishAffiliationTypesNotBelongingToCategory(String affiliationCategory) {
		List<String> wishTypes = new List<String>();
		for (Wish_Affiliation_Category__mdt type : [
				SELECT Type__c, Is_Default_for_Category__c, Sort_Order__c
				FROM Wish_Affiliation_Category__mdt
				WHERE Category__c != :affiliationCategory
				ORDER BY Sort_Order__c
		]) {
			wishTypes.add(type.Type__c);
		}
		return wishTypes;
	}

	/**
	 * @description Update the specific phone field that was selected as the preferred phone
	 * @param contact
	 * @return Contact
	 */
	public static Contact updateSpecificPhoneField(Contact contact) {
		if(String.isNotEmpty(contact.Phone)){
			if (CONTACT_PHONE_HOME.equals(contact.npe01__PreferredPhone__c)) {
				contact.HomePhone = contact.Phone;
			} else if (CONTACT_PHONE_MOBILE.equals(contact.npe01__PreferredPhone__c)) {
				contact.MobilePhone = contact.Phone;
			} else if (CONTACT_PHONE_OTHER.equals(contact.npe01__PreferredPhone__c)) {
				contact.OtherPhone = contact.Phone;
			} else if (CONTACT_PHONE_WORK.equals(contact.npe01__PreferredPhone__c)) {
				contact.npe01__WorkPhone__c = contact.Phone;
			}
		}
		return contact;
	}

	/**
	 * @description Find Wish Affiliations belonging to a Case and to a List of Wish Affiliation Types
	 * @param caseRecordId
	 * @param wishAffiliationTypes
	 * @return List of Wish_Affiliation__c
	 */
	public static List<Wish_Affiliation__c> findWishAffiliationsByCaseIdAndTypes(Id caseRecordId, List<String> wishAffiliationTypes) {
		List<Wish_Affiliation__c> wishAffiliations = [
				SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c, Medical_Needs__c,
						Survey_Recipient__c, Non_Comped__c, Details__c, Send_Clearance_Forms_To__c, Medical_Professional_Status__c,
						Contact__r.Salutation, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, Contact__r.Current_Age__c,
						Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
						Contact__r.MailingCountry, Contact__r.npe01__Preferred_Email__c, Contact__r.npe01__PreferredPhone__c, Contact__r.Phone, Contact__r.HomePhone,
						Contact__r.MobilePhone, Contact__r.OtherPhone, Contact__r.npe01__WorkPhone__c, Contact__r.npe01__HomeEmail__c,
						Contact__r.npe01__AlternateEmail__c, Contact__r.Alternate_Email_2__c, Contact__r.Alternate_Fax__c,
						Contact__r.npe01__WorkEmail__c, Contact__r.npsp__Do_Not_Contact__c, Contact__r.Do_Not_Contact_Notes__c,
						Contact__r.npsp__Deceased__c, Contact__r.Provider_Type__c, Contact__r.Fax, Contact__r.npsp__is_Address_Override__c,
						Relationship__r.npe4__Type__c, Relationship__r.Parent_Legal_Guardian__c,
						Relationship__r.npe4__Contact__c, Relationship__r.npe4__Contact__r.Name,
						Relationship__r.Qualifying_Medical_Professional__c, Relationship__r.Treating_HCP__c,
						Relationship__r.Best_Contact__c, Health_Treatment_Facility__c, Health_Treatment_Facility__r.Name,
						Relationship__r.Referring_Medical_Professional__c, Relationship__r.Former_MP__c
				FROM Wish_Affiliation__c
				WHERE Wish__c = :caseRecordId
				AND Wish_Affiliation_Type__c IN :wishAffiliationTypes
				ORDER BY Wish_Affiliation_Type__c DESC, Contact__r.Name
		];
		return wishAffiliations;
	}

	/**
	 * @description Check if the User or the User's profile is allowed to Update a Wish Affiliation
	 * @param userId
	 * @param userProfileId
	 * @return Boolean
	 */
	public static Boolean isUserIdOrUserProfileAllowedToUpdateWishAffiliation(String userId, String userProfileId) {
		Wish_Affiliation_Security_Settings__c securitySettingsByUserId =
				Wish_Affiliation_Security_Settings__c.getInstance(userId);
		Wish_Affiliation_Security_Settings__c securitySettingsByUserProfile =
				Wish_Affiliation_Security_Settings__c.getInstance(userProfileId);

		if (securitySettingsByUserId.Restrict_Access__c || securitySettingsByUserProfile.Restrict_Access__c) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * @description Return all the Wish Affiliation Type options and exclude the Wish Child as an option
	 * @return List of Wish Affiliation Types
	 */
	public static List<String> findWishAffiliationTypes() {
		List<String> wishTypes = new List<String>();
		for (Wish_Affiliation_Category__mdt type : [
				SELECT Type__c
				FROM Wish_Affiliation_Category__mdt
		]) {
			if (type.Type__c != 'Wish Child') {
				wishTypes.add(type.Type__c);
			}
		}
		return wishTypes;
	}

	/**
	 * @description Create Change requests when user is not allowed to edit Wish Affiliation
	 * @param modifiedWishAffln
	 * @param modifiedRelationship
	 * @param requestParticipant
	 * @param requestParticipantPrevious
	 * @return List of Wish_Change_Request__c
	 */
	public static List<Wish_Change_Request__c> buildWishChangeRequests(Wish_Affiliation__c modifiedWishAffln, npe4__Relationship__c modifiedRelationship,
			Boolean requestParticipant, Boolean requestParticipantPrevious) {
		List<Wish_Change_Request__c> wishChangeRequests = new List<Wish_Change_Request__c>();
		Wish_Affiliation__c existingWishAffln = findWishAffiliationById(modifiedWishAffln.Id);
		// Fields Wish Affiliation
		String existingWishAffiliationRecordName = existingWishAffln.Name;
		Map<String, Wish_Change_Request__c> wishAffiliationChangeRequests =
				findProposedWishChangeRequestsByCaseIdAndRecordId(modifiedWishAffln.Wish__c, modifiedWishAffln.Id);
		String modifiedWishAffiliationType = modifiedWishAffln.Wish_Affiliation_Type__c == null
				? '' : modifiedWishAffln.Wish_Affiliation_Type__c;
		String existingWishAffiliationType = existingWishAffln.Wish_Affiliation_Type__c == null
				? '' : existingWishAffln.Wish_Affiliation_Type__c;
		if (modifiedWishAffiliationType != existingWishAffiliationType
				|| requestParticipant != requestParticipantPrevious) {
			if (requestParticipant) {
				// If request participant is checked update type to Requested Participant (will only happen if user is volunteer)
				existingWishAffln.Wish_Affiliation_Type__c = Constant_AC.WISH_AFFILIATION_TYPE_REQUESTED_PARTICIPANT;
				update existingWishAffln;
			} else if (!requestParticipant) {
				// Change request created only if request participant is unchecked
				Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(WISH_AFFILIATION_API_NAME, existingWishAffiliationRecordName, WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME,
						modifiedWishAffln.Wish__c, modifiedWishAffln.Id, String.valueOf(existingWishAffln.Wish_Affiliation_Type__c),
						String.valueOf(modifiedWishAffln.Wish_Affiliation_Type__c), modifiedWishAffln.Id);
				Wish_Change_Request__c existingChangeRequest = wishAffiliationChangeRequests.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
				if (existingChangeRequest != null) {
					wishChangeRequest.Id = existingChangeRequest.Id;
				}
				wishChangeRequest.Field_New_Value__c = Constant_AC.WISH_AFFILIATION_TYPE_OTHER;
				wishChangeRequests.add(wishChangeRequest);
			}
		}
		String modifiedResidingWithWishChild = modifiedWishAffln.Residing_with_Wish_child__c == null
				? '' : modifiedWishAffln.Residing_with_Wish_child__c;
		String existingResidingWithWishChild = existingWishAffln.Residing_with_Wish_child__c == null
				? '' : existingWishAffln.Residing_with_Wish_child__c;
		if (String.isNotEmpty(existingResidingWithWishChild) && modifiedResidingWithWishChild != existingResidingWithWishChild) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(WISH_AFFILIATION_API_NAME, existingWishAffiliationRecordName, WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME,
					modifiedWishAffln.Wish__c, modifiedWishAffln.Id, String.valueOf(existingWishAffln.Residing_with_Wish_child__c),
					String.valueOf(modifiedWishAffln.Residing_with_Wish_child__c), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = wishAffiliationChangeRequests.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		// Fields Wish Affiliation Contact
		Contact modifiedContact = modifiedWishAffln.Contact__r;
		Contact existingContact = existingWishAffln.Contact__r;
		String existingContactRecordName = existingContact != null ? existingContact.Name : '';
		Map<String, Wish_Change_Request__c> contactChangeRequests =
				findProposedWishChangeRequestsByCaseIdAndRecordId(modifiedWishAffln.Wish__c, modifiedContact.Id);
		String modifiedFirstName = modifiedContact.FirstName == null
				? '' : modifiedContact.FirstName;
		String existingFirstName = existingContact.FirstName == null
				? '' : existingContact.FirstName;
		if (String.isNotEmpty(existingFirstName) && modifiedFirstName != existingFirstName) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_FIRSTNAME_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.FirstName),
					String.valueOf(modifiedContact.FirstName), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedLastName = modifiedContact.LastName == null
				? '' : modifiedContact.LastName;
		String existingLastName = existingContact.LastName == null
				? '' : existingContact.LastName;
		if (String.isNotEmpty(existingLastName) && modifiedLastName != existingLastName) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_LASTNAME_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.LastName),
					String.valueOf(modifiedContact.LastName), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedBirthdate = modifiedContact.Birthdate == null
				? '' : String.valueOf(modifiedContact.Birthdate);
		String existingBirthdate = existingContact.Birthdate == null
				? '' : String.valueOf(existingContact.Birthdate);
		if (String.isNotEmpty(existingBirthdate) && modifiedBirthdate != existingBirthdate) {
			/**
			 * WLP-656
			 * Field format needs to conform with how its going to be parsed in
			 * WishAffiliationService.updateWishAffiliationOfApprovedWishChangeRequests
			 */
			String formattedExistingBirthdate = '';
			String formattedModifiedBirthdate = '';
			if (String.isNotEmpty(modifiedBirthdate)) {
				formattedModifiedBirthdate = Utils.formatDate(modifiedContact.Birthdate, Utils.DATE_FORMAT_MDDYYYY);
			}
			if (String.isNotEmpty(existingBirthdate)) {
				formattedExistingBirthdate = Utils.formatDate(existingContact.Birthdate, Utils.DATE_FORMAT_MDDYYYY);
			}
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_BIRTHDATE_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, formattedExistingBirthdate,
					formattedModifiedBirthdate, modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedMailingStreet = modifiedContact.MailingStreet == null
				? '' : modifiedContact.MailingStreet;
		String existingMailingStreet = existingContact.MailingStreet == null
				? '' : existingContact.MailingStreet;
		if (String.isNotEmpty(existingMailingStreet) && modifiedMailingStreet != existingMailingStreet) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_MAILINGSTREET_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.MailingStreet),
					String.valueOf(modifiedContact.MailingStreet), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedMailingCity = modifiedContact.MailingCity == null
				? '' : modifiedContact.MailingCity;
		String existingMailingCity = existingContact.MailingCity == null
				? '' : existingContact.MailingCity;
		if (String.isNotEmpty(existingMailingCity) && modifiedMailingCity != existingMailingCity) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_MAILINGCITY_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.MailingCity),
					String.valueOf(modifiedContact.MailingCity), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedMailingState = modifiedContact.MailingState == null
				? '' : modifiedContact.MailingState;
		String existingMailingState = existingContact.MailingState == null
				? '' : existingContact.MailingState;
		if (String.isNotEmpty(existingMailingState) && modifiedMailingState != existingMailingState) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_MAILINGSTATE_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.MailingState),
					String.valueOf(modifiedContact.MailingState), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedMailingPostalCode = modifiedContact.MailingPostalCode == null
				? '' : modifiedContact.MailingPostalCode;
		String existingMailingPostalCode = existingContact.MailingPostalCode == null
				? '' : existingContact.MailingPostalCode;
		if (String.isNotEmpty(existingMailingPostalCode) && modifiedMailingPostalCode != existingMailingPostalCode) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_MAILINGPOSTALCODE_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.MailingPostalCode),
					String.valueOf(modifiedContact.MailingPostalCode), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedPreferredPhone = modifiedContact.npe01__PreferredPhone__c == null
				? '' : modifiedContact.npe01__PreferredPhone__c;
		String existingPreferredPhone = existingContact.npe01__PreferredPhone__c == null
				? '' : existingContact.npe01__PreferredPhone__c;
		if (String.isNotEmpty(existingPreferredPhone) && modifiedPreferredPhone != existingPreferredPhone) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_NPE01_PREFERREDPHONE_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.npe01__PreferredPhone__c),
					String.valueOf(modifiedContact.npe01__PreferredPhone__c), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedPhone = modifiedContact.Phone == null
				? '' : modifiedContact.Phone;
		String existingPhone = existingContact.Phone == null
				? '' : existingContact.Phone;
		if (String.isNotEmpty(existingPhone) && modifiedPhone != existingPhone) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_PHONE_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.Phone),
					String.valueOf(modifiedContact.Phone), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		String modifiedHomeEmail = modifiedContact.npe01__HomeEmail__c == null
				? '' : modifiedContact.npe01__HomeEmail__c;
		String existingHomeEmail = existingContact.npe01__HomeEmail__c == null
				? '' : existingContact.npe01__HomeEmail__c;
		if (String.isNotEmpty(existingHomeEmail) && modifiedHomeEmail != existingHomeEmail) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(CONTACT_API_NAME, existingContactRecordName, CONTACT_NPE01_HOMEEMAIL_API_NAME,
					modifiedWishAffln.Wish__c, modifiedContact.Id, String.valueOf(existingContact.npe01__HomeEmail__c),
					String.valueOf(modifiedContact.npe01__HomeEmail__c), modifiedWishAffln.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		// Fields Wish Affiliation Relationship
		npe4__Relationship__c existingRelationship = existingWishAffln.Relationship__r;
		String existingRelationshipRecordName = existingRelationship != null ? existingRelationship.Name : '';
		if (existingRelationship == null && modifiedRelationship != null) {
			npe4__Relationship__c newWishAffiliationRelationship = new npe4__Relationship__c();
			newWishAffiliationRelationship.npe4__Type__c = modifiedRelationship.npe4__Type__c;
			newWishAffiliationRelationship.Parent_Legal_Guardian__c = modifiedRelationship.Parent_Legal_Guardian__c;
			newWishAffiliationRelationship.npe4__RelatedContact__c = modifiedContact.Id;
			newWishAffiliationRelationship.npe4__Contact__c = modifiedRelationship.npe4__Contact__c;
			insert newWishAffiliationRelationship;
		} else if (existingRelationship != null && modifiedRelationship != null) {
			Map<String, Wish_Change_Request__c> relationshipChangeRequests =
					findProposedWishChangeRequestsByCaseIdAndRecordId(modifiedWishAffln.Wish__c, modifiedRelationship.Id);

			String modifiedRelType = modifiedRelationship.npe4__Type__c == null
					? '' : modifiedRelationship.npe4__Type__c;
			String existingRelType = existingRelationship.npe4__Type__c == null
					? '' : existingRelationship.npe4__Type__c;
			if (modifiedRelType != existingRelType) {
				Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(RELATIONSHIP_API_NAME, existingRelationshipRecordName, RELATIONSHIP_NPE4_TYPE_API_NAME,
						modifiedWishAffln.Wish__c, existingRelationship.Id, String.valueOf(existingRelationship.npe4__Type__c),
						String.valueOf(modifiedRelationship.npe4__Type__c), modifiedWishAffln.Id);
				Wish_Change_Request__c existingChangeRequest = relationshipChangeRequests
						.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
				if (existingChangeRequest != null) {
					wishChangeRequest.Id = existingChangeRequest.Id;
				}
				wishChangeRequests.add(wishChangeRequest);
			}
			if (modifiedRelationship.Parent_Legal_Guardian__c != existingRelationship.Parent_Legal_Guardian__c) {
				Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(RELATIONSHIP_API_NAME, existingRelationshipRecordName, RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME,
						modifiedWishAffln.Wish__c, existingRelationship.Id, String.valueOf(existingRelationship.Parent_Legal_Guardian__c),
						String.valueOf(modifiedRelationship.Parent_Legal_Guardian__c), modifiedWishAffln.Id);
				Wish_Change_Request__c existingChangeRequest = relationshipChangeRequests
						.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
				if (existingChangeRequest != null) {
					wishChangeRequest.Id = existingChangeRequest.Id;
				}
				wishChangeRequests.add(wishChangeRequest);
			}
		}
		return wishChangeRequests;
	}

	public static List<Wish_Change_Request__c> buildVolunteerChangeRequests(Wish_Affiliation__c wishAffiliation, Wish_Affiliation__c oldWishAffiliation) {
		List<Wish_Change_Request__c> wishChangeRequests = new List<Wish_Change_Request__c>();
		Wish_Affiliation__c updateWishAffRecord = new Wish_Affiliation__c();
		updateWishAffRecord.Id = wishAffiliation.Id;
		//Check if the value of fields got changed for Contact/Relationship/WishAffiliation
		// Fields Wish Affiliation
		//Residing with Wish Child
		String existingResidingWishChild = oldWishAffiliation.Residing_with_Wish_child__c == null ? '' : oldWishAffiliation.Residing_with_Wish_child__c;
		String newResidingWishChild = wishAffiliation.Residing_with_Wish_child__c;
		if (!String.isEmpty(existingResidingWishChild)
				&& existingResidingWishChild != newResidingWishChild) {
			Map<String, Wish_Change_Request__c> wishAffiliationChangeRequests =
					WishAffiliationService.findProposedWishChangeRequestsByCaseIdAndRecordId(wishAffiliation.Wish__c, wishAffiliation.Id);
			Wish_Change_Request__c wishChangeRequest = WishAffiliationService.initializeWishChangeRequest(
					Constant_AC.WISH_AFFILIATION_API_NAME, wishAffiliation.Name, Constant_AC.WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME,
					wishAffiliation.Wish__c, String.valueOf(wishAffiliation.Id), existingResidingWishChild, newResidingWishChild, wishAffiliation.Id);
			Wish_Change_Request__c existingChangeRequest = wishAffiliationChangeRequests.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		// Fields Wish Affiliation Relationship
		if (wishAffiliation.Relationship__c != null) {
			npe4__Relationship__c updateRelationshipRecord = new npe4__Relationship__c();
			updateRelationshipRecord.Id = wishAffiliation.Relationship__c;
			//Type
			String existingRelType = oldWishAffiliation.Relationship__r.npe4__Type__c == null ? '' : oldWishAffiliation.Relationship__r.npe4__Type__c;
			String newRelType = wishAffiliation.Relationship__r.npe4__Type__c;
			if (!String.isEmpty(existingRelType)
					&& existingRelType != newRelType) {
				Map<String, Wish_Change_Request__c> relationshipChangeRequests =
						WishAffiliationService.findProposedWishChangeRequestsByCaseIdAndRecordId(wishAffiliation.Wish__c, wishAffiliation.Relationship__c);
				Wish_Change_Request__c wishChangeRequest = WishAffiliationService.initializeWishChangeRequest(
						Constant_AC.RELATIONSHIP_API_NAME, wishAffiliation.Relationship__r.Name, Constant_AC.RELATIONSHIP_NPE4_TYPE_API_NAME,
						wishAffiliation.Wish__c, updateRelationshipRecord.Id, existingRelType, newRelType, wishAffiliation.Id);
				Wish_Change_Request__c existingChangeRequest = relationshipChangeRequests.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
				if (existingChangeRequest != null) {
					wishChangeRequest.Id = existingChangeRequest.Id;
				}
				wishChangeRequests.add(wishChangeRequest);
			}
		}
		// Fields Wish Affiliation Contact
		Contact updateContactRecord = new Contact();
		updateContactRecord.Id = wishAffiliation.Contact__c;
		Contact modifiedContact = wishAffiliation.Contact__r;
		Contact existingContact = oldWishAffiliation.Contact__r;
		String existingContactRecordName = existingContact != null ? existingContact.Name : '';
		Map<String, Wish_Change_Request__c> contactChangeRequests =
				WishAffiliationService.findProposedWishChangeRequestsByCaseIdAndRecordId(wishAffiliation.Wish__c, modifiedContact.Id);
		//Firstname
		String modifiedFirstName = modifiedContact.FirstName == null
				? '' : modifiedContact.FirstName;
		String existingFirstName = existingContact.FirstName == null
				? '' : existingContact.FirstName;
		if (!String.isEmpty(existingFirstName)
				&& modifiedFirstName != existingFirstName) {
			Wish_Change_Request__c wishChangeRequest = WishAffiliationService.initializeWishChangeRequest(
					Constant_AC.CONTACT_API_NAME, existingContactRecordName, Constant_AC.CONTACT_FIRSTNAME_API_NAME,
					wishAffiliation.Wish__c, modifiedContact.Id, String.valueOf(existingContact.FirstName),
					String.valueOf(modifiedContact.FirstName), wishAffiliation.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		//Middlename
		String modifiedMiddleName = modifiedContact.Middle_Name__c == null
				? '' : modifiedContact.Middle_Name__c;
		String existingMiddleName = existingContact.Middle_Name__c == null
				? '' : existingContact.Middle_Name__c;
		if (!String.isEmpty(existingMiddleName)
				&& modifiedMiddleName != existingMiddleName) {
			Wish_Change_Request__c wishChangeRequest = WishAffiliationService.initializeWishChangeRequest(
					Constant_AC.CONTACT_API_NAME, existingContactRecordName, CONTACT_MIDDLENAME_API_NAME,
					wishAffiliation.Wish__c, modifiedContact.Id, String.valueOf(existingContact.Middle_Name__c),
					String.valueOf(modifiedContact.Middle_Name__c), wishAffiliation.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		//Lastname
		String modifiedLastName = modifiedContact.LastName == null
				? '' : modifiedContact.LastName;
		String existingLastName = existingContact.LastName == null
				? '' : existingContact.LastName;
		if (!String.isEmpty(existingLastName)
				&& modifiedLastName != existingLastName) {
			Wish_Change_Request__c wishChangeRequest = WishAffiliationService.initializeWishChangeRequest(
					Constant_AC.CONTACT_API_NAME, existingContactRecordName, Constant_AC.CONTACT_LASTNAME_API_NAME,
					wishAffiliation.Wish__c, modifiedContact.Id, String.valueOf(existingContact.LastName),
					String.valueOf(modifiedContact.LastName), wishAffiliation.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		//Birthdate
		String modifiedBirthdate = modifiedContact.Birthdate == null
				? '' : String.valueOf(modifiedContact.Birthdate);
		String existingBirthdate = existingContact.Birthdate == null
				? '' : String.valueOf(existingContact.Birthdate);
		if (!String.isEmpty(existingBirthdate)
				&& modifiedBirthdate != existingBirthdate) {
			/**
			 * WLP-656
			 * Field format needs to conform with how its going to be parsed in
			 * WishAffiliationService.updateWishAffiliationOfApprovedWishChangeRequests
			 */
			String formattedExistingBirthdate = '';
			String formattedModifiedBirthdate = '';
			if (String.isNotEmpty(modifiedBirthdate)) {
				formattedModifiedBirthdate = Utils.formatDate(modifiedContact.Birthdate, Utils.DATE_FORMAT_MDDYYYY);
			}
			if (String.isNotEmpty(existingBirthdate)) {
				formattedExistingBirthdate = Utils.formatDate(existingContact.Birthdate, Utils.DATE_FORMAT_MDDYYYY);
			}
			Wish_Change_Request__c wishChangeRequest = WishAffiliationService.initializeWishChangeRequest(
					Constant_AC.CONTACT_API_NAME, existingContactRecordName, Constant_AC.CONTACT_BIRTHDATE_API_NAME,
					wishAffiliation.Wish__c, modifiedContact.Id, formattedExistingBirthdate,
					formattedModifiedBirthdate, wishAffiliation.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		//Email
		String modifiedHomeEmail = modifiedContact.npe01__HomeEmail__c == null
				? '' : modifiedContact.npe01__HomeEmail__c;
		String existingHomeEmail = existingContact.npe01__HomeEmail__c == null
				? '' : existingContact.npe01__HomeEmail__c;
		if (!String.isEmpty(existingHomeEmail)
				&& modifiedHomeEmail != existingHomeEmail) {
			Wish_Change_Request__c wishChangeRequest = initializeWishChangeRequest(
					CONTACT_API_NAME, existingContactRecordName, CONTACT_NPE01_HOMEEMAIL_API_NAME,
					wishAffiliation.Wish__c, modifiedContact.Id, String.valueOf(existingContact.npe01__HomeEmail__c),
					String.valueOf(modifiedContact.npe01__HomeEmail__c), wishAffiliation.Id);
			Wish_Change_Request__c existingChangeRequest = contactChangeRequests
					.get(wishChangeRequest.Field_API_Name_for_Proposed_Change__c);
			if (existingChangeRequest != null) {
				wishChangeRequest.Id = existingChangeRequest.Id;
			}
			wishChangeRequests.add(wishChangeRequest);
		}
		return wishChangeRequests;
	}

	/**
	 * @description Create the base object for a Wish_Change_Request__c
	 * @param sObjectApiName
	 * @param recordName
	 * @param fieldApiName
	 * @param wishCaseRecordId
	 * @param recordId
	 * @param previousFieldValue
	 * @param newFieldValue
	 * @param wishAffiliationId
	 * @return Wish_Change_Request__c
	 */
	public static Wish_Change_Request__c initializeWishChangeRequest(String sObjectApiName, String recordName, String fieldApiName, Id wishCaseRecordId, String recordId,
			String previousFieldValue, String newFieldValue, Id wishAffiliationId) {
		DescribeSObjectResult sObjectDescribeSObjectResult = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe();
		Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
		Schema.DescribeFieldResult field = fieldsByName.get(fieldApiName).getDescribe();
		Wish_Change_Request__c wishChangeRequest = new Wish_Change_Request__c();
		wishChangeRequest.Status__c = WISH_CHANGE_REQUEST_STATUS_PROPOSED;
		wishChangeRequest.Wish_Case_Id__c = wishCaseRecordId;
		wishChangeRequest.Wish_Affiliation__c = wishAffiliationId;
		wishChangeRequest.Object_API_Name_for_Proposed_Change__c = sObjectDescribeSObjectResult.name;
		wishChangeRequest.Record_Name__c = recordName;
		wishChangeRequest.Record_Id__c = recordId;
		wishChangeRequest.Field_Previous_Value__c = String.valueOf(previousFieldValue);
		wishChangeRequest.Field_New_Value__c = String.valueOf(newFieldValue);
		wishChangeRequest.Field_API_Name_for_Proposed_Change__c = field.getName();
		wishChangeRequest.Field_Label_for_Proposed_Change__c = field.getLabel();
		return wishChangeRequest;
	}

	/**
	 * @description Find a Wish Affiliation by Id
	 * @param wishAffiliation
	 * @return Wish_Affiliation__c
	 */
	public static Wish_Affiliation__c findWishAffiliationById(Id wishAffiliation) {
		return [
				SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c, Medical_Needs__c,
						Survey_Recipient__c, Non_Comped__c, Details__c, Send_Clearance_Forms_To__c, Medical_Professional_Status__c,
						Contact__r.Salutation, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, Contact__r.Current_Age__c,
						Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
						Contact__r.MailingCountry, Contact__r.npe01__Preferred_Email__c, Contact__r.npe01__PreferredPhone__c, Contact__r.Phone, Contact__r.HomePhone,
						Contact__r.MobilePhone, Contact__r.OtherPhone, Contact__r.npe01__WorkPhone__c, Contact__r.npe01__HomeEmail__c,
						Contact__r.npe01__WorkEmail__c, Contact__r.npsp__Do_Not_Contact__c, Contact__r.Do_Not_Contact_Notes__c,
						Contact__r.npsp__Deceased__c, Contact__r.Provider_Type__c, Contact__r.Fax, Contact__r.npsp__is_Address_Override__c,
						Contact__r.npe01__AlternateEmail__c, Contact__r.Alternate_Email_2__c, Contact__r.Alternate_Fax__c,
						Relationship__r.Name, Relationship__r.npe4__Type__c, Relationship__r.Parent_Legal_Guardian__c,
						Relationship__r.npe4__Contact__c, Relationship__r.npe4__Contact__r.Name,
						Relationship__r.Qualifying_Medical_Professional__c, Relationship__r.Treating_HCP__c,
						Relationship__r.Best_Contact__c, Health_Treatment_Facility__c, Health_Treatment_Facility__r.Name,
						Relationship__r.Referring_Medical_Professional__c, Relationship__r.Former_MP__c
				FROM Wish_Affiliation__c
				WHERE Id = :wishAffiliation
				ORDER BY Wish_Affiliation_Type__c DESC, Contact__r.Name
		];
	}

	/**
	 * @description Find a Relationship by Related Contact and Contact
	 * @param relatedContact
	 * @param contact
	 * @return npe4__Relationship__c
	 */
	public static npe4__Relationship__c findRelationshipByRelatedContactAndContact(Id relatedContact, Id contact) {
		List<npe4__Relationship__c> relationships = [
				SELECT Id, npe4__Type__c, Parent_Legal_Guardian__c, npe4__Contact__c,
						Qualifying_Medical_Professional__c, Treating_HCP__c, Best_Contact__c,
						Referring_Medical_Professional__c, Former_MP__c
				FROM npe4__Relationship__c
				WHERE npe4__RelatedContact__c = :relatedContact
				AND npe4__Contact__c = :contact
		];
		if (relationships.isEmpty()) {
			return null;
		}
		return relationships.get(0);
	}

	/**
	 * @description Find a Contact by Id
	 * @param contactId
	 * @return Contact
	 */
	public static Contact findContactById(Id contactId) {
		return [
				SELECT Id, Name, Salutation, FirstName, LastName, Birthdate, MailingStreet,
						MailingCity,MailingState, MailingPostalCode, MailingCountry, npe01__Preferred_Email__c,
						npe01__PreferredPhone__c, Phone, npe01__HomeEmail__c, npe01__WorkEmail__c,
						npe01__AlternateEmail__c, Alternate_Email_2__c, Alternate_Fax__c, MobilePhone,
						AccountId, Region_Chapter__c
				FROM Contact
				WHERE Id = :contactId
		];
	}

	/**
	 * @description Find a Household Address by Contact Id
	 * @param contactId
	 * @return Account
	 */
	public static Address findHouseholdAddressByContactId(Id contactId) {
		Contact contact = [
				SELECT Account.BillingAddress
				FROM Contact
				WHERE Id = :contactId
		];
		if (contact.Account == null) {
			return null;
		}
		if (contact.Account.BillingAddress == null) {
			return null;
		}
		return contact.Account.BillingAddress;
	}

	/**
	 * @description Find Case by Id
	 * @param wishCaseRecordId
	 * @return Case
	 */
	public static Case findWishCaseById(String wishCaseRecordId) {
		return [
				SELECT Id, ChapterName__r.Id, ChapterName__r.Name, Contact.Id
				FROM Case
				WHERE Id = :wishCaseRecordId
		];
	}

	/**
	 * @description Find if proposed Change Resquest has been already created for the field
	 * @param caseRecordId
	 * @param recordId
	 * @return Map of Wish_Change_Request__c
	 */
	public static Map<String, Wish_Change_Request__c> findProposedWishChangeRequestsByCaseIdAndRecordId(Id caseRecordId, Id recordId) {
		final String initialChangeRequestStatus = WISH_CHANGE_REQUEST_STATUS_PROPOSED;
		Map<String, Wish_Change_Request__c> wishChangeRequestsMap = new Map<String, Wish_Change_Request__c>();
		for (Wish_Change_Request__c wishChangeRequest : [
				SELECT Name, Id, Field_API_Name_for_Proposed_Change__c
				FROM Wish_Change_Request__c
				WHERE Status__c = :initialChangeRequestStatus
				AND Wish_Case_Id__c = :caseRecordId
				AND Record_Id__c = :recordId
		]) {
			wishChangeRequestsMap.put(wishChangeRequest.Field_API_Name_for_Proposed_Change__c, wishChangeRequest);
		}
		return wishChangeRequestsMap;
	}

	/**
	 * @description Helper method to create new wish affiliation objects
	 * @param wishCaseId
	 * @param currentRelationship
	 * @param affiliationType
	 * @return Wish_Affiliation__c
	 */
	private static Wish_Affiliation__c createNewWishAffiliation(Id wishCaseId, npe4__Relationship__c currentRelationship, String affiliationType) {
		Wish_Affiliation__c affiliation = new Wish_Affiliation__c();
		affiliation.Wish__c = wishCaseId;
		affiliation.Wish_Affiliation_Type__c = affiliationType;
		if (currentRelationship != null) {
			affiliation.Relationship__c = currentRelationship.Id;
			affiliation.Contact__c = currentRelationship.npe4__RelatedContact__c;
			affiliation.Referral_Source__c = currentRelationship.Referring_Medical_Professional__c;
		}
		return affiliation;
	}

	/**
	 * @description Find Wish Affiliations belonging to a Case and to a List of Wish Affiliation Types
	 * @param caseRecordId
	 * @param wishAffiliationTypes
	 * @param isUserAllowedToUpdateWishAffiliation
	 * @return List of Wish_Affiliation__c
	 */
	public static List<SObject> findWishAffiliationsByCaseIdAndTypes(Id caseRecordId, List<String> wishAffiliationTypes, Boolean isUserAllowedToUpdateWishAffiliation) {
		String soqlQuery = 'SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c,Validated_in_Interview__c,' +
				' Contact__c, Contact__r.Name, Contact__r.Salutation, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName, Contact__r.Birthdate, ' +
				' Contact__r.npe01__HomeEmail__c, Contact__r.T_Shirt_Size__c,' +
				' Relationship__c, Relationship__r.npe4__Type__c FROM Wish_Affiliation__c' +
				' WHERE Wish__c = :caseRecordId  AND Wish_Affiliation_Type__c IN :wishAffiliationTypes';
		if (!isUserAllowedToUpdateWishAffiliation) {
			soqlQuery += ' AND Hide_from_Restricted_Users__c = FALSE';
		}
		soqlQuery += ' ORDER BY Contact__r.Name';
		List<SObject> wishAffiliations = (List<SObject>) Database.query(soqlQuery);
		//Order the Affiliation list on the basis of Affiliation Type as per the Sort Order from Custom Metadata
		List<SObject> filteredAffiliations = new List<SObject>();
		for (String affiliationType : wishAffiliationTypes) {
			for (SObject sObj : wishAffiliations) {
				if (String.valueOf(sObj.get('Wish_Affiliation_Type__c')) == affiliationType) {
					filteredAffiliations.add(sObj);
				}
			}
		}
		return filteredAffiliations;
	}

	/**
	 * @description Find Change Requests belonging to a Case and to a List of Wish Affiliation
	 * @param caseRecordId
	 * @param wishAffiliations
	 * @return List of Wish_Affiliation__c
	 */
	public static Map<Id, List<SObject>> findChangeRequests(Id caseRecordId, List<Wish_Affiliation__c> wishAffiliations) {
		//Get field API Names from Fieldset to be mapped with Field_API_Name_for_Proposed_Change__c field on change request record
		List<String> requiredFields = new List<String>();
		for (Schema.FieldSetMember fieldMem : Schema.SObjectType.Wish_Affiliation__c.fieldSets.DesignFields.getFields()) {
			requiredFields.add(String.valueOf(fieldMem.getSObjectField()));
		}
		Map<Id, List<SObject>> mapAffiliationToCR = new Map<Id, List<SObject>>();
		for (SObject objRequest : [
				SELECT Field_New_Value__c, Field_Previous_Value__c,Wish_Affiliation__c, Field_API_Name_for_Proposed_Change__c
				FROM Wish_Change_Request__c
				WHERE Status__c = :WISH_CHANGE_REQUEST_STATUS_PROPOSED
				AND Wish_Case_Id__c = :caseRecordId
				AND Wish_Affiliation__c IN :wishAffiliations
				AND Field_API_Name_for_Proposed_Change__c IN :requiredFields
				ORDER BY Wish_Affiliation__c, CreatedDate
		]) {
			if (!mapAffiliationToCR.containsKey((Id) (objRequest.get(WISH_AFFILIATION_API_NAME)))) {
				mapAffiliationToCR.put((Id) objRequest.get(WISH_AFFILIATION_API_NAME), new List<Wish_Change_Request__c>());
			}
			mapAffiliationToCR.get((Id) objRequest.get(WISH_AFFILIATION_API_NAME)).add(objRequest);
		}
		return mapAffiliationToCR;
	}

	/**
	 * @description Find Wish Affiliation Types belonging to list of Categories
	 * @param affiliationCategory
	 * @return List of Wish Affiliation Types
	 */
	public static List<String> findWishAffiliationTypesByCategories(List<String> affiliationCategory) {
		List<String> wishTypes = new List<String>();
		for (Wish_Affiliation_Category__mdt type : [
				SELECT Type__c, Is_Default_for_Category__c, Sort_Order__c
				FROM Wish_Affiliation_Category__mdt
				WHERE Category__c IN :affiliationCategory
		]) {
			wishTypes.add(type.Type__c);
		}
		return wishTypes;
	}

	/**
	 * @description Check if the User or the User's profile is allowed to Update a Wish Affiliation
	 * @return Boolean
	 */
	public static Boolean isUserIdOrUserProfileAllowedToUpdateWishAffiliation() {
		Wish_Affiliation_Security_Settings__c securitySettings =
				Wish_Affiliation_Security_Settings__c.getInstance();
		if (securitySettings.Restrict_Access__c) {
			return false;
		} else {
			return true;
		}
	}
}