/**
 * @description Wish Affiliation Controller, exposes methods for the front end components.
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 10/31/2019
 */
public without sharing class WishAffiliationDesign_AC {

	private static final String WISH_AFFILIATION_STATE_PARTICIPANT = 'Participant';
	private static final String WISH_AFFILIATION_STATE_NOT_PARTICIPANT = 'Not Participant';
	private static final String WISH_AFFILIATION_STATE_REQUESTED_VALIDATED = 'Requested Validated';
	private static final String WISH_AFFILIATION_STATE_REQUESTED_NOT_VALIDATED = 'Requested Not Validated';

	/**
	 * Find all of the Wish Affiliations belonging to the Wish Case for a Category
	 * @param wishCaseRecordId
	 * @param wishAffiliationCategory
	 * @return Map of Object,Object
	 */
	@AuraEnabled
	public static Map<Object, Object> getWishAffiliations(String wishCaseRecordId, String wishAffiliationCategory) {
		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		List<WishAffiliationWrapper> wrapperList = new List<WishAffiliationWrapper>();
		Integer countReqParticipants = 0;
		try {
			//Find Wish Affiliation Categories
			List<String> wishAffiliationTypesOfCategory = WishAffiliationService.findWishAffiliationTypesNotBelongingToCategory(wishAffiliationCategory);
			// Check to see if the User is allowed to edit directly the WishAffiliation:
			Boolean isUserProfileAllowedToUpdateWishAffiliation = WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation();
			returnValuesMap.put('isUserProfileAllowedToUpdateWishAffiliation', isUserProfileAllowedToUpdateWishAffiliation);
			// Find Wish Affiliations by Category and Wish Case Record Id
			List<SObject> wishAffiliations = WishAffiliationService.findWishAffiliationsByCaseIdAndTypes(wishCaseRecordId, wishAffiliationTypesOfCategory, isUserProfileAllowedToUpdateWishAffiliation);
			//Find change Request records for List of Affiliations and Case Id
			Map<Id, List<SObject>> affToChangeRequestMap = WishAffiliationService.findChangeRequests(wishCaseRecordId, wishAffiliations);
			if (!isUserProfileAllowedToUpdateWishAffiliation) {
				//Get FieldSet fields details from Schema
				Map<String, Schema.FieldSetMember> fieldNameToFieldSetMem = new Map<String, Schema.FieldSetMember>();
				for (Schema.FieldSetMember fieldMem : Schema.SObjectType.Wish_Affiliation__c.fieldSets.DesignFields.getFields()) {
					fieldNameToFieldSetMem.put(String.valueOf(fieldMem.getSObjectField()), fieldMem);
				}
				//Club data from Change Request list and Wish Affiliation list
				for (SObject objAffiliation : wishAffiliations) {
					if (affToChangeRequestMap.containsKey(objAffiliation.Id)) {
						for (SObject objChange : affToChangeRequestMap.get(objAffiliation.Id)) {
							String relatedField = String.valueOf(fieldNameToFieldSetMem.get(String.valueOf(objChange.get('Field_API_Name_for_Proposed_Change__c'))).getFieldPath());
							//Split field name for Reference Type fields to get Object and Field API
							if (relatedField.contains('.')) {
								List<String> objectField = relatedField.split('\\.');
								//Parse for Date and Datetime field types
								if (fieldNameToFieldSetMem.get(objectField[1]).getType() == Schema.DisplayType.DATE) {
									if (String.valueOf(objChange.get('Field_New_Value__c')).contains('-')) {
										objAffiliation.getSObject(objectField[0]).put(objectField[1], Date.valueOf(String.valueOf(objChange.get('Field_New_Value__c'))));
									} else {
										objAffiliation.getSObject(objectField[0]).put(objectField[1], Date.parse(String.valueOf(objChange.get('Field_New_Value__c'))));
									}
								} else if (fieldNameToFieldSetMem.get(objectField[1]).getType() == Schema.DisplayType.DATETIME) {
									if (String.valueOf(objChange.get('Field_New_Value__c')).contains('-')) {
										objAffiliation.getSObject(objectField[0]).put(objectField[1], Datetime.valueOf(String.valueOf(objChange.get('Field_New_Value__c'))));
									} else {
										objAffiliation.getSObject(objectField[0]).put(objectField[1], Datetime.parse(String.valueOf(objChange.get('Field_New_Value__c'))));
									}
								} else {
									objAffiliation.getSObject(objectField[0]).put(objectField[1], objChange.get('Field_New_Value__c'));
								}
							} else {
								objAffiliation.put((String) (objChange.get('Field_API_Name_for_Proposed_Change__c')), objChange.get('Field_New_Value__c')) ;
							}
						}
					}
				}
			}
			//Build Wish Affiliation Wrapper with Card State
			List<String> wishTypeCategories = WishAffiliationService.findWishAffiliationTypesByCategories(new List<String>{
					'Participant', 'Requested Participant'
			});
			for (Wish_Affiliation__c objAffiliation : (List<Wish_Affiliation__c>) wishAffiliations) {
				WishAffiliationWrapper wishAffWrap = new WishAffiliationWrapper();
				wishAffWrap.wishAffRecord = objAffiliation;
				if (objAffiliation.Wish_Affiliation_Type__c == Constant_AC.CONTACT_WISH_CHILD_RT_LABEL) {
					wishAffWrap.State = WISH_AFFILIATION_STATE_PARTICIPANT;
					countReqParticipants++;
				} else {
					if (objAffiliation.Validated_in_Interview__c && wishTypeCategories.contains(objAffiliation.Wish_Affiliation_Type__c)) {
						wishAffWrap.State = WISH_AFFILIATION_STATE_REQUESTED_VALIDATED;
						countReqParticipants++;
					} else if (!objAffiliation.Validated_in_Interview__c && wishTypeCategories.contains(objAffiliation.Wish_Affiliation_Type__c)) {
						wishAffWrap.State = WISH_AFFILIATION_STATE_REQUESTED_NOT_VALIDATED;
						countReqParticipants++;
					} else if (!wishTypeCategories.contains(objAffiliation.Wish_Affiliation_Type__c)) {
						wishAffWrap.State = WISH_AFFILIATION_STATE_NOT_PARTICIPANT;
					}
				}
				wrapperList.add(wishAffWrap);
			}
			returnValuesMap.put('wishAffiliations', wrapperList);
			returnValuesMap.put('countReqParticipants', countReqParticipants);
			// Find Salutations
			List<String> salutationOptions = Utils.getPicklistLabels('Contact', 'Salutation');
			returnValuesMap.put('salutationOptions', salutationOptions);
			// Find Relationship Types
			List<String> relationshipTypes = Utils.getPicklistLabels('npe4__Relationship__c', 'npe4__Type__c');
			returnValuesMap.put('relationshipTypes', relationshipTypes);
			// Find Residing with Wish Child Values
			List<String> residingWithChild = Utils.getPicklistLabels('Wish_Affiliation__c', 'Residing_with_Wish_child__c');
			returnValuesMap.put('residingWithChild', residingWithChild);
			// Find Wish Child Name
			Case wish = WishAffiliationService.findWishCaseById(wishCaseRecordId);
			Contact wishChild = WishAffiliationService.findContactById(wish.Contact.Id);
			returnValuesMap.put('wishChildFirstName', wishChild.FirstName);
		} catch (Exception e) {
			returnValuesMap.put('error', e.getMessage());
		}
		return returnValuesMap;
	}

	/**
	 * Create a new Wish Affiliation
	 * @param payload
	 * @return Map<Object, Object>
	 */
	@AuraEnabled
	public static Map<Object, Object> createWishAffiliation(String payload) {
		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		List<String> validationErrorMessages = new List<String>();
		//Deserialize the payload
		newWishAffiliationRecordWrapper newWishAffRecord = (newWishAffiliationRecordWrapper) JSON.deserialize(payload, newWishAffiliationRecordWrapper.class);
		Case wish = WishAffiliationService.findWishCaseById(newWishAffRecord.WishAffiliationWishCaseRecordId);
		Contact wishChild = WishAffiliationService.findContactById(wish.Contact.Id);
		try {
			//Create Contact
			Contact con = new Contact();
			con.Salutation = newWishAffRecord.ContactSalutation;
			con.FirstName = newWishAffRecord.ContactFirstName;
			con.Middle_Name__c = newWishAffRecord.ContactMiddleName;
			con.LastName = newWishAffRecord.ContactLastName;
			con.Birthdate = newWishAffRecord.ContactBirthdate;
			con.npe01__HomeEmail__c = newWishAffRecord.ContactEmail;
			con.T_Shirt_Size__c = newWishAffRecord.ContactTShirtSize;
			con.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
			con.Region_Chapter__c = wishChild.Region_Chapter__c;
			if (newWishAffRecord.WishAffiliationResidingWithWishChild == 'Yes') {
				con.AccountId = wishChild.AccountId;
			}
			insert con;
			//Create Relationship
			npe4__Relationship__c relationship = new npe4__Relationship__c();
			relationship.npe4__Contact__c = wishChild.Id;
			relationship.npe4__RelatedContact__c = con.Id;
			relationship.npe4__Type__c = newWishAffRecord.RelationshipType;
			insert relationship;
			//Create Wish Affiliation
			Wish_Affiliation__c wishAffiliation = new Wish_Affiliation__c();
			wishAffiliation.Contact__c = con.Id;
			wishAffiliation.Relationship__c = relationship.Id;
			wishAffiliation.Wish__c = wish.Id;
			wishAffiliation.Wish_Affiliation_Type__c = 'Requested Participant';
			wishAffiliation.Residing_with_Wish_child__c = newWishAffRecord.WishAffiliationResidingWithWishChild;
			wishAffiliation.Validated_in_Interview__c = true;
			insert wishAffiliation;
			return returnValuesMap;
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
	}

	/**
	* Remove an affiliation as a Participant by submitting a Change Request for it
	* @param objWishAffiliation
	*/
	@AuraEnabled
	public static void removeAsParticipant(String objWishAffiliation) {
		try {
			WishAffiliationWrapper wishAffiliation = (WishAffiliationWrapper) JSON.deserialize(objWishAffiliation, WishAffiliationDesign_AC.WishAffiliationWrapper.class);
			Wish_Affiliation__c updateWishAffiliation = new Wish_Affiliation__c();
			updateWishAffiliation.Id = wishAffiliation.wishAffRecord.Id;
			updateWishAffiliation.Wish_Affiliation_Type__c = 'Other';
			update updateWishAffiliation;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Add or Update Wish Affiliation/Contact/Relationship/Change Requests
	 * @param objWishAffiliation
	 * @param objNewWishAffiliation
	 */
	@AuraEnabled
	public static Map<Object, Object> addUpdateAsParticipant(String objWishAffiliation, String objOldWishAffiliation) {
		Map<Object, Object> returnValuesMap = new Map<Object, Object>();
		List<String> validationErrorMessages = new List<String>();
		try {
			WishAffiliationWrapper wishAffiliation = (WishAffiliationWrapper) JSON.deserialize(objWishAffiliation, WishAffiliationDesign_AC.WishAffiliationWrapper.class);
			WishAffiliationWrapper oldWishAffiliation = (WishAffiliationWrapper) JSON.deserialize(objOldWishAffiliation, WishAffiliationDesign_AC.WishAffiliationWrapper.class);
			Boolean isAccessAllowed = WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation();
			List<Wish_Change_Request__c> wishChangeRequests = new List<Wish_Change_Request__c>();
			Wish_Affiliation__c updateWishAffRecord = new Wish_Affiliation__c();
			updateWishAffRecord.Id = wishAffiliation.wishAffRecord.Id;
			if (!isAccessAllowed) {
				wishChangeRequests = WishAffiliationService.buildVolunteerChangeRequests(wishAffiliation.wishAffRecord, oldWishAffiliation.wishAffRecord);
				upsert wishChangeRequests;
				// Fields Wish Affiliation Contact
				Contact updateContactRecord = new Contact();
				updateContactRecord.Id = wishAffiliation.wishAffRecord.Contact__c;
				Boolean isUpdateContact = false;
				Contact modifiedContact = wishAffiliation.wishAffRecord.Contact__r;
				Contact existingContact = oldWishAffiliation.wishAffRecord.Contact__r;
				// SIW-641 Salutation can be updated by a Volunteer
				String modifiedSalutation = modifiedContact.Salutation == null
						? '' : modifiedContact.Salutation;
				String existingSalutation = existingContact.Salutation == null
						? '' : existingContact.Salutation;
				if (modifiedSalutation != existingSalutation) {
					updateContactRecord.Salutation = modifiedSalutation;
					isUpdateContact = true;
				}
                //SIW-609 Birthdate and Residing with Wish Child fields can be updated if previous value blank
                if(existingContact.Birthdate == null && modifiedContact.Birthdate != null) {
                    updateContactRecord.Birthdate = modifiedContact.Birthdate;
                    isUpdateContact = true;
                }
                if(oldWishAffiliation.wishAffRecord.Residing_with_Wish_child__c == null && wishAffiliation.wishAffRecord.Residing_with_Wish_child__c != null) {
                    updateWishAffRecord.Residing_with_Wish_child__c = wishAffiliation.wishAffRecord.Residing_with_Wish_child__c;
                }
                if (isUpdateContact) {
                    update updateContactRecord;
                }
			} else {
				//Check if the value of fields got changed for Contact/Relationship/WishAffiliation
				// Fields Wish Affiliation
				//Residing with Wish Child
				String existingResidingWishChild = oldWishAffiliation.wishAffRecord.Residing_with_Wish_child__c == null ? '' : oldWishAffiliation.wishAffRecord.Residing_with_Wish_child__c;
				String newResidingWishChild = wishAffiliation.wishAffRecord.Residing_with_Wish_child__c;
				if (existingResidingWishChild != newResidingWishChild) {
					updateWishAffRecord.Residing_with_Wish_child__c = wishAffiliation.wishAffRecord.Residing_with_Wish_child__c;
				}
				// Fields Wish Affiliation Relationship
				npe4__Relationship__c updateRelationshipRecord = new npe4__Relationship__c();
				Boolean isUpdateRelationship = false;
				if (wishAffiliation.wishAffRecord.Relationship__c != null) {
					updateRelationshipRecord.Id = wishAffiliation.wishAffRecord.Relationship__c;
					//Type
					String existingRelType = oldWishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c == null ? '' : oldWishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c;
					String newRelType = wishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c;
					if (existingRelType != newRelType) {
						updateRelationshipRecord.npe4__Type__c = wishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c;
						isUpdateRelationship = true;
					}
				}
				// Fields Wish Affiliation Contact
				Contact updateContactRecord = new Contact();
				updateContactRecord.Id = wishAffiliation.wishAffRecord.Contact__c;
				Boolean isUpdateContact = false;
				Contact modifiedContact = wishAffiliation.wishAffRecord.Contact__r;
				Contact existingContact = oldWishAffiliation.wishAffRecord.Contact__r;
				//Salutation
				String modifiedSalutation = modifiedContact.Salutation == null
						? '' : modifiedContact.Salutation;
				String existingSalutation = existingContact.Salutation == null
						? '' : existingContact.Salutation;
				if (modifiedSalutation != existingSalutation) {
					updateContactRecord.Salutation = modifiedSalutation;
					isUpdateContact = true;
				}
				//Firstname
				String modifiedFirstName = modifiedContact.FirstName == null
						? '' : modifiedContact.FirstName;
				String existingFirstName = existingContact.FirstName == null
						? '' : existingContact.FirstName;
				if (modifiedFirstName != existingFirstName) {
					updateContactRecord.FirstName = modifiedFirstName;
					isUpdateContact = true;
				}
				//Middlename
				String modifiedMiddleName = modifiedContact.Middle_Name__c == null
						? '' : modifiedContact.Middle_Name__c;
				String existingMiddleName = existingContact.Middle_Name__c == null
						? '' : existingContact.Middle_Name__c;
				if (modifiedMiddleName != existingMiddleName) {
					updateContactRecord.Middle_Name__c = modifiedMiddleName;
					isUpdateContact = true;
				}
				//Lastname
				String modifiedLastName = modifiedContact.LastName == null
						? '' : modifiedContact.LastName;
				String existingLastName = existingContact.LastName == null
						? '' : existingContact.LastName;
				if (modifiedLastName != existingLastName) {
					updateContactRecord.LastName = modifiedLastName;
					isUpdateContact = true;
				}
				//Birthdate
				String modifiedBirthdate = modifiedContact.Birthdate == null
						? '' : String.valueOf(modifiedContact.Birthdate);
				String existingBirthdate = existingContact.Birthdate == null
						? '' : String.valueOf(existingContact.Birthdate);
				if (modifiedBirthdate != existingBirthdate) {
					updateContactRecord.Birthdate = modifiedContact.Birthdate;
					isUpdateContact = true;
				}
				//Email
				String modifiedEmail = modifiedContact.npe01__HomeEmail__c == null
						? '' : String.valueOf(modifiedContact.npe01__HomeEmail__c);
				String existingEmail = existingContact.npe01__HomeEmail__c == null
						? '' : String.valueOf(existingContact.npe01__HomeEmail__c);
				if (modifiedEmail != existingEmail) {
					updateContactRecord.npe01__HomeEmail__c = modifiedEmail;
					isUpdateContact = true;
				}
				//T-Shirt Size
				String modifiedShirtSize = modifiedContact.T_Shirt_Size__c == null
						? '' : String.valueOf(modifiedContact.T_Shirt_Size__c);
				String existingShirtSize = existingContact.T_Shirt_Size__c == null
						? '' : String.valueOf(existingContact.T_Shirt_Size__c);
				if (modifiedShirtSize != existingShirtSize) {
					updateContactRecord.T_Shirt_Size__c = modifiedShirtSize;
					isUpdateContact = true;
				}
				if (isUpdateContact) {
					update updateContactRecord;
				}
				if (isUpdateRelationship) {
					update updateRelationshipRecord;
				}
			}
			// When Relationship fields are populated but Relationship does not exist for the Wish Affiliation then create it
			if (wishAffiliation.wishAffRecord.Relationship__c == null
					&& String.isNotEmpty(wishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c)) {
				Case wish = WishAffiliationService.findWishCaseById(wishAffiliation.wishAffRecord.Wish__c);
				Contact wishChild = WishAffiliationService.findContactById(wish.Contact.Id);
				npe4__Relationship__c newWishAffiliationRelationship = new npe4__Relationship__c();
				newWishAffiliationRelationship.npe4__Type__c = wishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c;
				newWishAffiliationRelationship.npe4__RelatedContact__c = wishAffiliation.wishAffRecord.Contact__c;
				newWishAffiliationRelationship.npe4__Contact__c = wishChild.Id;
				insert newWishAffiliationRelationship;
				updateWishAffRecord.Relationship__c = newWishAffiliationRelationship.Id;
			}
			List<String> wishTypeCategories = WishAffiliationService.findWishAffiliationTypesByCategories(new List<String>{
					'Participant', 'Requested Participant'
			});
			if (!wishTypeCategories.contains(oldWishAffiliation.wishAffRecord.Wish_Affiliation_Type__c)) {
				updateWishAffRecord.Wish_Affiliation_Type__c = 'Requested Participant';
			}
			updateWishAffRecord.Validated_in_Interview__c = true;
			update updateWishAffRecord;
			return returnValuesMap;
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
	}

	/**
	 *  Wrapper Class for storing Wish Affiliation record and its State
	 */
	public class WishAffiliationWrapper {
		@AuraEnabled public Wish_Affiliation__c wishAffRecord { get; set; }
		@AuraEnabled public String State { get; set; }
	}

	/**
	  *  Wrapper Class for storing New Wish Affiliation record created
	  */
	public class newWishAffiliationRecordWrapper {
		@AuraEnabled public Id WishAffiliationWishCaseRecordId { get; set; }
		@AuraEnabled public String RelationshipType { get; set; }
		@AuraEnabled public String ContactSalutation { get; set; }
		@AuraEnabled public String ContactFirstName { get; set; }
		@AuraEnabled public String ContactLastName { get; set; }
		@AuraEnabled public Date ContactBirthdate { get; set; }
		@AuraEnabled public String ContactMiddleName { get; set; }
		@AuraEnabled public String ContactTShirtSize { get; set; }
		@AuraEnabled public String ContactEmail { get; set; }
		@AuraEnabled public String WishAffiliationResidingWithWishChild { get; set; }
	}
}