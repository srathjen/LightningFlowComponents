/**
 * @description Wish Affiliation Controller, exposes methods for the front end components.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 6/20/2019
 */
public without sharing class WishAffiliation_AC {

	private static final String CONTACT_WISH_CHILD_RT_LABEL = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
	private static final String MEDICAL_PROFESSIONAL_WISH_AFFILIATION_CATEGORY = 'Medical Professional';
	private static final String MEDICAL_PROFESSIONAL_WISH_AFFILIATION_TYPE = 'Medical Professional';
	private static final String PARTICIPANT_WISH_AFFILIATION_CATEGORY = 'Participant';

	/**
	 * Find all of the Wish Affiliations belonging to the Wish Case
	 * Find all of the dependencies to be exposed on the UI
	 * @param wishCaseRecordId
	 * @param wishAffiliationCategory
	 * @return Map of Object
	 */
	@AuraEnabled
	public static Map<Object, Object> findWishAffiliations(String wishCaseRecordId, String wishAffiliationCategory) {
		final String contactSobjectApiName = 'Contact';
		final String accountSobjectApiName = 'Account';
		final String mailingStateCodeFieldApiNameOfContact = 'MailingStateCode';
		final String mailingCountryCodeFieldApiNameOfContact = 'MailingCountryCode';
		final String preferredPhoneFieldApiNameOfContact = 'npe01__PreferredPhone__c';
		final String salutationFieldApiNameOfContact = 'Salutation';
		final String wishAffiliationSobjectApiName = 'Wish_Affiliation__c';
		final String relationshipSobjectApiName = 'npe4__Relationship__c';
		final String residingWithWishChildFieldApiNameOfWishAffiliation = 'Residing_with_Wish_child__c';
		final String relationshipTypeFieldApiNameOfRelationship = 'npe4__Type__c';
		final String providerTypeFieldApiNameOfContact = 'Provider_Type__c';

		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		try {
			// Find Wish Affiliations by Category and Wish Case Record Id
			List<String> wishAffiliationTypesOfCategory = WishAffiliationService.findWishAffiliationTypesByCategory(wishAffiliationCategory, returnValuesMap);
			List<Wish_Affiliation__c> wishAffiliations = WishAffiliationService.findWishAffiliationsByCaseIdAndTypes(wishCaseRecordId, wishAffiliationTypesOfCategory);
			returnValuesMap.put('wishAffiliations', wishAffiliations);

			// Find Field Labels
			Map<String, String> wishAffiliationLabels = Utils.getFieldLabels(wishAffiliationSobjectApiName);
			returnValuesMap.put('wishAffiliationLabels', wishAffiliationLabels);
			Map<String, String> contactLabels = Utils.getFieldLabels(contactSobjectApiName);
			returnValuesMap.put('contactLabels', contactLabels);
			Map<String, String> relationshipLabels = Utils.getFieldLabels(relationshipSobjectApiName);
			returnValuesMap.put('relationshipLabels', relationshipLabels);
			Map<String, String> accountLabels = Utils.getFieldLabels(accountSobjectApiName);
			returnValuesMap.put('accountLabels', accountLabels);

			// Check to see if the User is allowed to edit directly the WishAffiliation:
			Boolean isUserProfileAllowedToUpdateWishAffiliation = WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation(UserInfo.getUserId(), UserInfo.getProfileId());
			returnValuesMap.put('isUserProfileAllowedToUpdateWishAffiliation', isUserProfileAllowedToUpdateWishAffiliation);

			// Find Residing With Child options
			List<String> residingWithChildOptions = Utils.getPicklistLabels(wishAffiliationSobjectApiName, residingWithWishChildFieldApiNameOfWishAffiliation);
			returnValuesMap.put('residingWithChildOptions', residingWithChildOptions);

			// Find State options
			List<String> states = Utils.getPicklistLabels(contactSobjectApiName, mailingStateCodeFieldApiNameOfContact);
			returnValuesMap.put('states', states);

			// Find Country options
			List<String> countries = Utils.getPicklistLabels(contactSobjectApiName, mailingCountryCodeFieldApiNameOfContact);
			returnValuesMap.put('countries', countries);

			// Find Preferred Phone options
			List<String> preferredPhoneOptions = Utils.getPicklistLabels(contactSobjectApiName, preferredPhoneFieldApiNameOfContact);
			returnValuesMap.put('preferredPhoneOptions', preferredPhoneOptions);

			// Find Salutation options
			List<String> salutationOptions = Utils.getPicklistLabels(contactSobjectApiName, salutationFieldApiNameOfContact);
			returnValuesMap.put('salutationOptions', salutationOptions);

			// Find Relationship Types
			List<String> relationshipTypes = Utils.getPicklistLabels(relationshipSobjectApiName, relationshipTypeFieldApiNameOfRelationship);
			returnValuesMap.put('relationshipTypes', relationshipTypes);

			// Wish Affiliation types for editing, excluding Wish Child as an option
			if (PARTICIPANT_WISH_AFFILIATION_CATEGORY.equals(wishAffiliationCategory)) {
				wishAffiliationTypesOfCategory = removeItemFromList(wishAffiliationTypesOfCategory, CONTACT_WISH_CHILD_RT_LABEL);
			}
			returnValuesMap.put('wishAffiliationTypesOfCategory', wishAffiliationTypesOfCategory);

			// Wish Affiliation types for editing, excluding Wish Child as an option
			List<String> wishAffiliationTypes = WishAffiliationService.findWishAffiliationTypes();
			returnValuesMap.put('wishAffiliationTypes', wishAffiliationTypes);

			// Find Medical Provider Types
			if (MEDICAL_PROFESSIONAL_WISH_AFFILIATION_CATEGORY.equals(wishAffiliationCategory)) {
				List<String> medicalProviderTypes = Utils.getPicklistLabels(contactSobjectApiName, providerTypeFieldApiNameOfContact);
				returnValuesMap.put('medicalProviderTypes', medicalProviderTypes);
			}

			// Find Chapter Name
			Case wishCase = WishAffiliationService.findWishCaseById(wishCaseRecordId);
			returnValuesMap.put('chapterName', wishCase.ChapterName__r.Name);

			// Get Wish Child Contact record
			Contact wishChildContact = WishAffiliationService.findContactById(wishCase.ContactId);
			returnValuesMap.put('wishChildContactId', wishChildContact.Id);
			returnValuesMap.put('wishChildName', wishChildContact.Name);
		} catch (Exception e) {
			returnValuesMap.put('error', e.getMessage());
		}
		return returnValuesMap;
	}
	/**
	 * Save the Wish Affiliation Changes
	 * If the current user's profile matches the
	 * profiles existent in Wish_Affiliation_Profile_Settings__mdt and is in Active state
	 * then Change Requests are created instead of making changes to the Wish Affiliation
	 * @param payload
	 * @param isUserProfileAllowedToUpdateWishAffiliation
	 * @return Map of Object
	 */
	@AuraEnabled
	public static Map<Object, Object> saveWishAffiliation(String payload, Boolean isUserProfileAllowedToUpdateWishAffiliation,
			Boolean requestParticipant, Boolean requestParticipantPrevious) {
		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		Map<String, Object> wishAffiliationMap = deserializePayload(payload);
		Wish_Affiliation__c oldWishAffiliation = (Wish_Affiliation__c) wishAffiliationMap.get('oldWishAffiliation');
		Wish_Affiliation__c modifiedWishAffiliation = (Wish_Affiliation__c) wishAffiliationMap.get('modifiedWishAffiliation');
		npe4__Relationship__c modifiedRelationship = (npe4__Relationship__c) wishAffiliationMap.get('modifiedRelationship');
		List<String> validationErrorMessages = new List<String>();
		// Convert Wish Affiliation if Wish Affiliation Type changed to another Category
		// Example: Requested Participant (Requested Participant category) changed to Approved Participant (Participant Category)
		if (!oldWishAffiliation.Wish_Affiliation_Type__c.equals(modifiedWishAffiliation.Wish_Affiliation_Type__c)) {
			if (MEDICAL_PROFESSIONAL_WISH_AFFILIATION_TYPE.equals(oldWishAffiliation.Wish_Affiliation_Type__c)) {
				if (MEDICAL_PROFESSIONAL_WISH_AFFILIATION_TYPE.equals(modifiedRelationship.npe4__Type__c)) {
					validationErrorMessages.add('Relationship type must be different then ' + MEDICAL_PROFESSIONAL_WISH_AFFILIATION_TYPE);
					returnValuesMap.put('validationErrors', validationErrorMessages);
					return returnValuesMap;
				}
			}
		}
		try {
			if (isUserProfileAllowedToUpdateWishAffiliation) {
				// Update Contact
				Contact contact = modifiedWishAffiliation.Contact__r;
				contact = WishAffiliationService.updateSpecificPhoneField(contact);
				update contact;
				// Update or Insert Relationship
				if (modifiedRelationship != null) {
					npe4__Relationship__c existingRelationship = WishAffiliationService.findRelationshipByRelatedContactAndContact(contact.Id, modifiedRelationship.npe4__Contact__c);
					if (existingRelationship != null) {
						existingRelationship.npe4__Type__c = modifiedRelationship.npe4__Type__c;
						existingRelationship.Parent_Legal_Guardian__c = modifiedRelationship.Parent_Legal_Guardian__c;
						existingRelationship.Referring_Medical_Professional__c = modifiedRelationship.Referring_Medical_Professional__c;
						existingRelationship.Former_MP__c = modifiedRelationship.Former_MP__c;
						if (MEDICAL_PROFESSIONAL_WISH_AFFILIATION_TYPE.equals(modifiedWishAffiliation.Wish_Affiliation_Type__c)) {
							existingRelationship.Best_Contact__c = modifiedRelationship.Best_Contact__c;
							existingRelationship.Qualifying_Medical_Professional__c = modifiedRelationship.Qualifying_Medical_Professional__c;
							existingRelationship.Treating_HCP__c = modifiedRelationship.Treating_HCP__c;
						}
						update existingRelationship;
						modifiedWishAffiliation.Relationship__c = existingRelationship.Id;
					} else {
						modifiedRelationship.npe4__RelatedContact__c = contact.Id;
						insert modifiedRelationship;
						modifiedWishAffiliation.Relationship__c = modifiedRelationship.Id;
					}
				} else {
					modifiedWishAffiliation.Relationship__c = null;
				}
				modifiedWishAffiliation.Created_Via_Lead_Convert__c = false;
				update modifiedWishAffiliation;
			} else {
				List<Wish_Change_Request__c> wishChangeRequests = WishAffiliationService.buildWishChangeRequests(
						modifiedWishAffiliation, modifiedRelationship, requestParticipant, requestParticipantPrevious);
				upsert wishChangeRequests;

				// Fields Wish Affiliation
				Wish_Affiliation__c existingWishAffln = WishAffiliationService.findWishAffiliationById(modifiedWishAffiliation.Id);
				Boolean isUpdateAffiliation = false;

				String modifiedResidingWithWishChild = modifiedWishAffiliation.Residing_with_Wish_child__c == null
						? '' : modifiedWishAffiliation.Residing_with_Wish_child__c;
				String existingResidingWithWishChild = existingWishAffln.Residing_with_Wish_child__c == null
						? '' : existingWishAffln.Residing_with_Wish_child__c;
				if (String.isEmpty(existingResidingWithWishChild) && modifiedResidingWithWishChild != existingResidingWithWishChild) {
					isUpdateAffiliation = true;
				}

				// Fields Wish Affiliation Contact
				Contact updateContactRecord = new Contact();
				updateContactRecord.Id = modifiedWishAffiliation.Contact__r.Id;
				Boolean isUpdateContact = false;
				Contact modifiedContact = modifiedWishAffiliation.Contact__r;
				Contact existingContact = existingWishAffln.Contact__r;
				//Salutation
				String modifiedSalutation = modifiedContact.Salutation == null
						? '' : modifiedContact.Salutation;
				String existingSalutation = existingContact.Salutation == null
						? '' : existingContact.Salutation;
				if (String.isEmpty(existingSalutation)
						&& modifiedSalutation != existingSalutation) {
					updateContactRecord.Salutation = modifiedSalutation;
					isUpdateContact = true;
				}
				//Firstname
				String modifiedFirstName = modifiedContact.FirstName == null
						? '' : modifiedContact.FirstName;
				String existingFirstName = existingContact.FirstName == null
						? '' : existingContact.FirstName;
				if (String.isEmpty(existingFirstName)
						&& modifiedFirstName != existingFirstName) {
					updateContactRecord.FirstName = modifiedFirstName;
					isUpdateContact = true;
				}
				//Lastname
				String modifiedLastName = modifiedContact.LastName == null
						? '' : modifiedContact.LastName;
				String existingLastName = existingContact.LastName == null
						? '' : existingContact.LastName;
				if (String.isEmpty(existingLastName)
						&& modifiedLastName != existingLastName) {
					updateContactRecord.LastName = modifiedLastName;
					isUpdateContact = true;
				}
				//Birthdate
				String modifiedBirthdate = modifiedContact.Birthdate == null
						? '' : String.valueOf(modifiedContact.Birthdate);
				String existingBirthdate = existingContact.Birthdate == null
						? '' : String.valueOf(existingContact.Birthdate);
				if (String.isEmpty(existingBirthdate)
						&& modifiedBirthdate != existingBirthdate) {
					updateContactRecord.Birthdate = modifiedContact.Birthdate;
					isUpdateContact = true;
				}
				//Mailing Street
				String modifiedMailingStreet = modifiedContact.MailingStreet == null
						? '' : modifiedContact.MailingStreet;
				String existingMailingStreet = existingContact.MailingStreet == null
						? '' : existingContact.MailingStreet;
				if (String.isEmpty(existingMailingStreet) && modifiedMailingStreet != existingMailingStreet) {
					updateContactRecord.MailingStreet = modifiedMailingStreet;
					isUpdateContact = true;
				}
				//Mailing City
				String modifiedMailingCity = modifiedContact.MailingCity == null
						? '' : modifiedContact.MailingCity;
				String existingMailingCity = existingContact.MailingCity == null
						? '' : existingContact.MailingCity;
				if (String.isEmpty(existingMailingCity) && modifiedMailingCity != existingMailingCity) {
					updateContactRecord.MailingCity = modifiedMailingCity;
					isUpdateContact = true;
				}
				//Mailing State
				String modifiedMailingState = modifiedContact.MailingState == null
						? '' : modifiedContact.MailingState;
				String existingMailingState = existingContact.MailingState == null
						? '' : existingContact.MailingState;
				if (String.isEmpty(existingMailingState) && modifiedMailingState != existingMailingState) {
					updateContactRecord.MailingState = modifiedMailingState;
					isUpdateContact = true;
				}
				//Mailing Postal Code
				String modifiedMailingPostalCode = modifiedContact.MailingPostalCode == null
						? '' : modifiedContact.MailingPostalCode;
				String existingMailingPostalCode = existingContact.MailingPostalCode == null
						? '' : existingContact.MailingPostalCode;
				if (String.isEmpty(existingMailingPostalCode) && modifiedMailingPostalCode != existingMailingPostalCode) {
					updateContactRecord.MailingPostalCode = modifiedMailingPostalCode;
					isUpdateContact = true;
				}
				//Preferred Phone
				String modifiedPreferredPhone = modifiedContact.npe01__PreferredPhone__c == null
						? '' : modifiedContact.npe01__PreferredPhone__c;
				String existingPreferredPhone = existingContact.npe01__PreferredPhone__c == null
						? '' : existingContact.npe01__PreferredPhone__c;
				if (String.isEmpty(existingPreferredPhone) && modifiedPreferredPhone != existingPreferredPhone) {
					updateContactRecord.npe01__PreferredPhone__c = modifiedPreferredPhone;
					isUpdateContact = true;
				}
				//Phone
				String modifiedPhone = modifiedContact.Phone == null
						? '' : modifiedContact.Phone;
				String existingPhone = existingContact.Phone == null
						? '' : existingContact.Phone;
				if (String.isEmpty(existingPhone) && modifiedPhone != existingPhone) {
					updateContactRecord.Phone = modifiedPhone;
					isUpdateContact = true;
				}
				//Home Email
				String modifiedHomeEmail = modifiedContact.npe01__HomeEmail__c == null
						? '' : modifiedContact.npe01__HomeEmail__c;
				String existingHomeEmail = existingContact.npe01__HomeEmail__c == null
						? '' : existingContact.npe01__HomeEmail__c;
				if (String.isEmpty(existingHomeEmail) && modifiedHomeEmail != existingHomeEmail) {
					updateContactRecord.npe01__HomeEmail__c = modifiedHomeEmail;
					isUpdateContact = true;
				}
				if (isUpdateContact) {
					update updateContactRecord;
				}
				if (isUpdateAffiliation) {
					update modifiedWishAffiliation;
				}
			}
		} catch (DmlException e) {
			Integer numErrors = e.getNumDml();
			for (Integer i = 0; i < numErrors; i++) {
				validationErrorMessages.add(e.getDmlMessage(i));
			}
			returnValuesMap.put('validationErrors', validationErrorMessages);
			System.debug('Wish Affiliation Validation Error ' + validationErrorMessages);
		} catch (Exception e) {
			System.debug('Wish Affiliation System Error ' + e.getMessage());
			returnValuesMap.put('Wish Affiliation System Error', e.getMessage());
		}
		returnValuesMap.put('validationErrors', validationErrorMessages);
		Wish_Affiliation__c updatedWishAffiliation = WishAffiliationService.findWishAffiliationById(modifiedWishAffiliation.Id);
		returnValuesMap.put('wishAffiliation', updatedWishAffiliation);
		return returnValuesMap;
	}

	/**
	 * Save the Wish Affiliation Changes overload for Medical Professionals
	 * If the current user's profile matches the
	 * profiles existent in Wish_Affiliation_Profile_Settings__mdt and is in Active state
	 * then Change Requests are created instead of making changes to the Wish Affiliation
	 * @param payload
	 * @param isUserProfileAllowedToUpdateWishAffiliation
	 * @return Map of Object
	 */
	@AuraEnabled public static Map<Object, Object> saveWishAffiliation(String payload, Boolean isUserProfileAllowedToUpdateWishAffiliation) {
		return saveWishAffiliation(payload, isUserProfileAllowedToUpdateWishAffiliation, false, false);
	}

	/**
	 * Create a new Wish Affiliation
	 * @param payload
	 * @param existingContactId
	 * @return Map of Object
	 */
	@AuraEnabled
	public static Map<Object, Object> createWishAffiliation(String payload, String existingContactId,
			Boolean contactResidesWithRelationshipContact, Id wishChildContactId, String relationshipContactHouseholdAddressPayload) {
		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		Wish_Affiliation__c newWishAffiliation = new Wish_Affiliation__c();
		List<String> validationErrorMessages = new List<String>();
		try {
			// Deserializing Wish Affiliation
			newWishAffiliation = deserializeWishAffiliation(payload);
			Case wishCase = WishAffiliationService.findWishCaseById(newWishAffiliation.Wish__c);
			Contact contact;
			if (String.isNotEmpty(existingContactId)) {
				contact = WishAffiliationService.findContactById(existingContactId);
				String contactAlreadyWishAffiliation = WishAffiliationService.isContactAlreadyWishAffiliation(contact, wishCase.Id);
				if (String.isNotEmpty(contactAlreadyWishAffiliation)) {
					validationErrorMessages.add('This contact is already on Wish Affiliation (' + contactAlreadyWishAffiliation + ' )');
					returnValuesMap.put('validationErrors', validationErrorMessages);
					return returnValuesMap;
				}
			} else {
				// Deserializing Wish Affiliation
				contact = deserializeContact(payload, wishCase.ChapterName__r.Id, newWishAffiliation.Wish_Affiliation_Type__c);
				contact = WishAffiliationService.updateSpecificPhoneField(contact);
				insert contact;
			}
			newWishAffiliation.Contact__c = contact.Id;
			// Deserializing Relationship
			npe4__Relationship__c relationship = deserializeRelationship(payload, contact.Id);
			if (relationship != null) {
				insert relationship;
				newWishAffiliation.Relationship__c = relationship.Id;
				if (contactResidesWithRelationshipContact != null && contactResidesWithRelationshipContact
						&& wishChildContactId == relationship.npe4__Contact__c) {
					newWishAffiliation.Residing_with_Wish_child__c = 'Yes';
				} else {
					newWishAffiliation.Residing_with_Wish_child__c = 'No';
				}
			}
			// Deserializing Address
			Address relationshipContactHouseholdAddress = deserializeAddress(relationshipContactHouseholdAddressPayload);
			// Assigning a Household Account to the new Contact
			if (String.isEmpty(existingContactId) && contactResidesWithRelationshipContact != null && relationshipContactHouseholdAddressPayload != null) {
				if (relationship != null && contactResidesWithRelationshipContact) {
					Contact relationshipContact = WishAffiliationService.findContactById(relationship.npe4__Contact__c);
					contact.AccountId = relationshipContact.AccountId;
					if (!contact.npsp__is_Address_Override__c) {
						if (relationshipContactHouseholdAddress != null) {
							contact.MailingCity = relationshipContactHouseholdAddress.city;
							contact.MailingCountry = relationshipContactHouseholdAddress.country;
							contact.MailingCountryCode = relationshipContactHouseholdAddress.countryCode;
							contact.MailingGeocodeAccuracy = relationshipContactHouseholdAddress.geocodeAccuracy;
							contact.MailingPostalCode = relationshipContactHouseholdAddress.postalCode;
							contact.MailingState = relationshipContactHouseholdAddress.state;
							contact.MailingStateCode = relationshipContactHouseholdAddress.stateCode;
							contact.MailingStreet = relationshipContactHouseholdAddress.street;
						}
					}
					update contact;
				}
			}
			newWishAffiliation.Created_Via_Lead_Convert__c = false;
			insert newWishAffiliation;
		} catch (DmlException e) {
			Integer numErrors = e.getNumDml();
			for (Integer i = 0; i < numErrors; i++) {
				validationErrorMessages.add(e.getDmlMessage(i));
			}
			returnValuesMap.put('validationErrors', validationErrorMessages);
			System.debug('Wish Affiliation Validation Error ' + validationErrorMessages);
			return returnValuesMap;
		} catch (Exception e) {
			System.debug('Wish Affiliation System Error ' + e.getMessage());
			returnValuesMap.put('Wish Affiliation System Error', e.getMessage());
			return returnValuesMap;
		}
		Wish_Affiliation__c updatedWishAffiliation = WishAffiliationService.findWishAffiliationById(newWishAffiliation.Id);
		returnValuesMap.put('newWishAffiliation', updatedWishAffiliation);
		return returnValuesMap;
	}

	/**
	 * Find Household Address of Contact
	 * @param Contact Id
	 * @return Map of Object
	 */
	@AuraEnabled
	public static Map<Object, Object> getHouseholdAddressOfContact(Id contactId) {
		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		Address householdAddress = WishAffiliationService.findHouseholdAddressByContactId(contactId);
		returnValuesMap.put('relationshipContactHouseholdAddress', householdAddress);
		return returnValuesMap;
	}

	/**
	 * Deserialize the Wish Affiliation, there is a case when a Wish Affiliation does not
	 * have a Relationship but we want to create it if the user fills in
	 * the Relationship fields exposed on the UI
	 * @param wishAffiliationPayload
	 * @return Map of Wish Affiliation being before and after changes
	 */
	private static Map<String, Object> deserializePayload(String wishAffiliationPayload) {
		Map<String, Object> wishAffiliationMap = new Map<String, Object>();
		// Build Wish Affiliation
		Wish_Affiliation__c wishAffiliation = new Wish_Affiliation__c();
		try {
			// Parse the Wish Affiliation fields
			JSONParser parentParser = JSON.createParser(wishAffiliationPayload);
			Wish_Affiliation__c parsed = (Wish_Affiliation__c) parentParser.readValueAsStrict(Wish_Affiliation__c.class);
			wishAffiliation = WishAffiliationService.findWishAffiliationById(parsed.Id);
			Wish_Affiliation__c oldWishAffiliationSnapshot = new Wish_Affiliation__c();
			oldWishAffiliationSnapshot.Wish_Affiliation_Type__c = wishAffiliation.Wish_Affiliation_Type__c;
			oldWishAffiliationSnapshot.Relationship__r = wishAffiliation.Relationship__r;
			wishAffiliationMap.put('oldWishAffiliation', oldWishAffiliationSnapshot);
			wishAffiliation.Id = parsed.Id;
			// Build Wish Affiliation
			wishAffiliation.Wish_Affiliation_Type__c = parsed.Wish_Affiliation_Type__c;
			wishAffiliation.Details__c = parsed.Details__c;
			wishAffiliation.Non_Comped__c = parsed.Non_Comped__c;
			wishAffiliation.Medical_Needs__c = parsed.Medical_Needs__c;
			wishAffiliation.Survey_Recipient__c = parsed.Survey_Recipient__c;
			wishAffiliation.Residing_with_Wish_child__c = parsed.Residing_with_Wish_child__c;
			// Only for Medical Professionals:
			wishAffiliation.Send_Clearance_Forms_To__c = parsed.Send_Clearance_Forms_To__c;
			wishAffiliation.Health_Treatment_Facility__c = parsed.Health_Treatment_Facility__c;

			// Deserialize Contact and Relationship, remove the __r from the payload.
			// Wrapper class must contain the exact field names for the parser to work, cannot use a
			// reserved keyword, Relationship__r may not be assigned to variable name relationship__r
			String findRelationshipContactObject =
					wishAffiliationPayload.substringBetween('"npe4__Contact__r":{', '}}}');
			if (String.isNotEmpty(findRelationshipContactObject)) {
				wishAffiliationPayload = wishAffiliationPayload.replace(findRelationshipContactObject, '');
			}
			wishAffiliationPayload = wishAffiliationPayload.replaceAll('__r', '');
			WishAffiliationWrapper wrapper
					= (WishAffiliationWrapper) JSON.deserialize(wishAffiliationPayload, WishAffiliationWrapper.class);
			// Build Contact
			if (wrapper.contact != null) {
				wishAffiliation.Contact__r.Salutation = wrapper.contact.Salutation;
				wishAffiliation.Contact__r.FirstName = wrapper.contact.FirstName;
				wishAffiliation.Contact__r.LastName = wrapper.contact.LastName;
				wishAffiliation.Contact__r.Birthdate = wrapper.contact.Birthdate;
				wishAffiliation.Contact__r.MailingStreet = wrapper.contact.MailingStreet;
				wishAffiliation.Contact__r.MailingCity = wrapper.contact.MailingCity;
				wishAffiliation.Contact__r.MailingState = wrapper.contact.MailingState;
				wishAffiliation.Contact__r.MailingPostalCode = wrapper.contact.MailingPostalCode;
				wishAffiliation.Contact__r.MailingCountry = wrapper.contact.MailingCountry;
				wishAffiliation.Contact__r.npe01__PreferredPhone__c = wrapper.contact.npe01__PreferredPhone__c;
				wishAffiliation.Contact__r.Phone = wrapper.contact.Phone;
				wishAffiliation.Contact__r.npe01__HomeEmail__c = wrapper.contact.npe01__HomeEmail__c;
				wishAffiliation.Contact__r.npsp__Do_Not_Contact__c = wrapper.contact.npsp__Do_Not_Contact__c;
				wishAffiliation.Contact__r.Do_Not_Contact_Notes__c = wrapper.contact.Do_Not_Contact_Notes__c;
				wishAffiliation.Contact__r.npsp__Deceased__c = wrapper.contact.npsp__Deceased__c;
				// Only for Medical Professionals:
				wishAffiliation.Contact__r.Provider_Type__c = wrapper.contact.Provider_Type__c;
				wishAffiliation.Contact__r.Fax = wrapper.contact.Fax;
				wishAffiliation.Contact__r.npe01__WorkEmail__c = wrapper.contact.npe01__WorkEmail__c;
			}
			// Build Relationship
			if (wrapper.relationship != null) {
				if (String.isNotEmpty(wrapper.relationship.npe4__Type__c) && wrapper.relationship.npe4__Contact__c != null) {
					npe4__Relationship__c relationship = new npe4__Relationship__c();
					// Update relationship with whats being updated
					relationship.npe4__Type__c = wrapper.relationship.npe4__Type__c;
					relationship.Parent_Legal_Guardian__c = wrapper.relationship.Parent_Legal_Guardian__c;
					relationship.npe4__Contact__c = wrapper.relationship.npe4__Contact__c;
					// Only for Medical Professionals:
					relationship.Qualifying_Medical_Professional__c = wrapper.relationship.Qualifying_Medical_Professional__c;
					relationship.Treating_HCP__c = wrapper.relationship.Treating_HCP__c;
					relationship.Best_Contact__c = wrapper.relationship.Best_Contact__c;
					relationship.Referring_Medical_Professional__c = wrapper.relationship.Referring_Medical_Professional__c;
					relationship.Former_MP__c = wrapper.relationship.Former_MP__c;
					wishAffiliationMap.put('modifiedRelationship', relationship);
				} else if (String.isEmpty(wrapper.relationship.npe4__Type__c) && wrapper.relationship.npe4__Contact__c == null) {
					wishAffiliationMap.put('modifiedRelationship', null);
				}
			}
		} catch (Exception e) {
			System.debug('Deserialize Payload Error' + e.getMessage());
		}
		wishAffiliationMap.put('modifiedWishAffiliation', wishAffiliation);
		return wishAffiliationMap;
	}

	/**
	 * Deserialize WishAffiliation
	 * @param wishAffiliationPayload
	 * @return Wish_Affiliation__c
	 */
	private static Wish_Affiliation__c deserializeWishAffiliation(String wishAffiliationPayload) {
		JSONParser parser = JSON.createParser(wishAffiliationPayload);
		Wish_Affiliation__c wishAffiliation = new Wish_Affiliation__c();
		try {
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String fieldName = parser.getText();
					parser.nextToken();
					if (fieldName == 'Id') {
						wishAffiliation.Id = parser.getIdValue();
						wishAffiliation = WishAffiliationService.findWishAffiliationById(wishAffiliation.Id);
					} else if (fieldName == 'Wish__c') {
						wishAffiliation.Wish__c = parser.getIdValue();
					} else if (fieldName == 'Wish_Affiliation_Type__c') {
						wishAffiliation.Wish_Affiliation_Type__c = parser.getText();
					} else if (fieldName == 'Residing_with_Wish_child__c') {
						wishAffiliation.Residing_with_Wish_child__c = parser.getText();
					} else if (fieldName == 'Non_Comped__c') {
						wishAffiliation.Non_Comped__c = parser.getBooleanValue();
					} else if (fieldName == 'Medical_Needs__c') {
						wishAffiliation.Medical_Needs__c = parser.getBooleanValue();
					} else if (fieldName == 'Survey_Recipient__c') {
						wishAffiliation.Survey_Recipient__c = parser.getBooleanValue();
					} else if (fieldName == 'Details__c') {
						wishAffiliation.Details__c = parser.getText();
					} else if (fieldName == 'Send_Clearance_Forms_To__c') {
						wishAffiliation.Send_Clearance_Forms_To__c = parser.getBooleanValue();
					} else if (fieldName == 'Health_Treatment_Facility__c') {
						wishAffiliation.Health_Treatment_Facility__c = parser.getIdValue();
					}
					parser.skipChildren();
				}
			}
		} catch (Exception e) {
			System.debug('Deserialize Wish Affiliation Error' + e.getMessage());
		}
		return wishAffiliation;
	}
	/**
	 * Deserialize Contact
	 * @param wishAffiliationPayload
	 * @param regionChapterId
	 * @return Contact
	 */
	private static Contact deserializeContact(String wishAffiliationPayload, Id regionChapterId, String wishAffiliationType) {
		// Exception to Birthdate which is a optional field, needs to be removed before parsing
		// if the field is not filled in as its a Date type which cannot be parsed from null to Date
		wishAffiliationPayload = wishAffiliationPayload.replace('"Birthdate":"",', '');
		JSONParser parser = JSON.createParser(wishAffiliationPayload);
		Contact contact = new Contact();
		try {
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String fieldName = parser.getText();
					parser.nextToken();
					if (fieldName == 'Contact__r') {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							contact = (Contact) parser.readValueAs(contact.class);
						}
					}
				}
			}
			// Guarantee that Contact is assigned a Record Type and Region Chapter
			if (MEDICAL_PROFESSIONAL_WISH_AFFILIATION_TYPE.equals(wishAffiliationType)) {
				contact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
				contact.AccountId = regionChapterId;
				if (String.isNotEmpty(contact.npe01__WorkEmail__c)) {
					contact.npe01__Preferred_Email__c = Constant_AC.CONTACT_PREFERRED_EMAIL_WORK;
				} else {
					contact.npe01__Preferred_Email__c = '';
				}
			} else {
				contact.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
			}
			if (contact.Region_Chapter__c == null) {
				contact.Region_Chapter__c = regionChapterId;
			}
		} catch (Exception e) {
			System.debug('Deserialize Contact Error ' + e.getMessage());
		}
		return contact;
	}
	/**
	 * Deserialize Relationship
	 * @param wishAffiliationPayload
	 * @param wishAffiliationContactId
	 * @return npe__Relationship__c
	 */
	private static npe4__Relationship__c deserializeRelationship(String wishAffiliationPayload, Id wishAffiliationContactId) {
		JSONParser parser = JSON.createParser(wishAffiliationPayload);
		npe4__Relationship__c relationship;
		try {
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String fieldName = parser.getText();
					parser.nextToken();
					if (fieldName == 'Relationship__r') {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							relationship = new npe4__Relationship__c();
							relationship = (npe4__Relationship__c) parser.readValueAs(npe4__Relationship__c.class);
						}
					}
				}
			}
			// If Relationship type and Related Contact are empty then dont create a relationship
			if (String.isEmpty(relationship.npe4__Type__c) && String.isEmpty(relationship.npe4__Contact__c)) {
				return null;
			}
			// Guarantee for new Relationships record, assign Contact
			if (relationship != null) {
				if (relationship.Id == null) {
					relationship.npe4__RelatedContact__c = wishAffiliationContactId;
				}
			}
		} catch (Exception e) {
			System.debug('Deserialize Relationship Error ' + e.getMessage());
		}
		return relationship;
	}

	/**
	 * Deserialize Address
	 * @param addressPayload
	 * @return Address
	 */
	private static Address deserializeAddress(String addressPayload) {
		Address address;
		if (String.isEmpty(addressPayload)) {
			return address;
		}
		JSONParser parser = JSON.createParser(addressPayload);
		try {
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
					address = new Address();
					address = (Address) parser.readValueAs(address.class);
				}
			}
		} catch (Exception e) {
			System.debug('Deserialize Address Error ' + e.getMessage());
		}
		return address;
	}

	/**
	 * Remove item from a String from a List
	 * @param targetList
	 * @param itemToRemove
	 * @return List of Strings
	 */
	private static List<String> removeItemFromList(List<String> targetList, String itemToRemove) {
		List<String> newList = new List<String>();
		for (String item : targetList) {
			if (!item.equals(itemToRemove)) {
				newList.add(item);
			}
		}
		return newList;
	}

	/**
	 *  Wrapper Class for deserializing Wish Affiliation object
	 */
	public class WishAffiliationWrapper {
		Contact contact { get; set; }
		npe4__Relationship__c relationship { get; set; }
	}
}