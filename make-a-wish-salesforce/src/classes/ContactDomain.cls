/**
 * @description Domain class for Contact trigger
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/24/2020
 */
public class ContactDomain extends trac_TriggerHandlerBase {

	private List<Contact> newContactsList = (List<Contact>) newRecordsList;
	private List<Contact> oldContactsList = (List<Contact>) oldRecordsList;
	private Map<Id, Contact> newContactsMap = (Map<Id, Contact>) newRecordsMap;
	private Map<Id, Contact> oldContactsMap = (Map<Id, Contact>) oldRecordsMap;
	private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
	private final static Id WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id WISH_FAMILY_RT_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id BOARD_MEMBER_RT_ID = Constant_AC.BOARD_MEMBER_RT_ID;
	private final static String CONTACT_WISH_CHILD_RT_LABEL = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
	private final static String ACCOUNT_NAME_MAW_AMERICA = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
	private final static String RELATIONSHIP_TYPE_PARENT_GUARDIAN = Constant_AC.CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
	private final static Map<String, String> MONTH_VALUE_MAP = constructMonthNameValueMap();
	private final static Map<String, String> MONTH_NAME_MAP = constructMonthValueNameMap();

	/**
	* Before insert of contact
	*/
    public override void handleBeforeInsert() {
        for (Contact contact : newContactsList) {
            if (!blockTrigger) {
                if (contact.RecordTypeId == VOLUNTEER_RT_ID) {
                    contact.Region_Chapter__c = contact.AccountId;
                }
                if (contact.birth_day__c != null && contact.birth_year__c != null && contact.birth_month__c != null) {
                    date dtConverted = Date.valueOf(contact.birth_year__c + '-' + MONTH_VALUE_MAP.get(contact.birth_month__c) + '-' + contact.birth_day__c);
                    contact.BirthDate = dtConverted ;
                }
            }
            if (contact.RecordTypeId == WISH_CHILD_RT_ID) {
                contact.Relationship_Type__c = CONTACT_WISH_CHILD_RT_LABEL;
            } else if (contact.RecordTypeId == WISH_FAMILY_RT_ID) {
                contact.Relationship_Type__c = RELATIONSHIP_TYPE_PARENT_GUARDIAN;
            }
            if(contact.Region_Chapter__c != null) {
                contact.Hidden_Chapter__c = contact.Region_Chapter__c;
            }
        }
        ContactService.populateRegionChapterOnMedicalProfessional(newContactsList, null);
        ContactService.updateContactOwnerToChapter(newContactsList, null);
    }

	/**
	* After insert of contact
	*/
    public override void handleAfterInsert() {
        if (!blockTrigger) {
            RecursiveTriggerHandler.isFirstTime = false;
            ContactService.createAffiliation(newContactsList);
        }
        ContactService.shareContactToChapter(newContactsList, null);
        ContactService.createVolunteerUser(newContactsMap.keySet());
    }

	/**
	* Before update of contact
	*/
	public override void handleBeforeUpdate() {
		if (RecursiveTriggerHandler.blockBeforeUpdate || blockTrigger) {
			return;
		}
		Set<Id> wishChildIdSet = new Set<Id>();
		for (Contact newContact : newContactsList) {
			Contact oldContact = oldContactsMap.get(newContact.Id);
			if (hasMailingAddressChanged(newContact, oldContact)) {
				newContact.MailingAddressVerified__c = false;
				newContact.MailingAddressVerificationAttempted__c = null;
				newContact.County__c = ' ';
			}
			if (hasOtherAddressChanged(newContact, oldContact)) {
				newContact.OtherAddressVerified__c = false;
				newContact.OtherAddressVerificationAttempted__c = null;
			}
			if (newContact.RecordTypeId == VOLUNTEER_RT_ID && newContact.RecordTypeId != oldContact.RecordTypeId) {
				newContact.AccountId = newContact.Region_Chapter__c;
			}
			if (newContact.Birth_Year__c != oldContact.Birth_Year__c || newContact.Birth_Month__c != oldContact.Birth_Month__c || newContact.Birth_Day__c != oldContact.Birth_Day__c) {
				if (newContact.Birth_Month__c != null && newContact.Birth_Day__c != null && newContact.Birth_Year__c != null) {
					date dtConverted = Date.valueOf(newContact.birth_year__c + '-' + MONTH_VALUE_MAP.get(newContact.birth_month__c) + '-' + newContact.birth_day__c);
					newContact.BirthDate = dtConverted ;
				} else {
					newContact.BirthDate = null;
				}
			} else if (newContact.BirthDate != null && newContact.BirthDate != oldContact.BirthDate) {
				newContact.Birth_Month__c = MONTH_NAME_MAP.get(String.valueOf(newContact.BirthDate.month()));
				newContact.Birth_Year__c = String.valueOf(newContact.BirthDate.year());
				newContact.birth_day__c = String.valueOf(newContact.BirthDate.day());
			} else if (newContact.BirthDate == null && newContact.BirthDate != oldContact.BirthDate) {
				newContact.Birth_Month__c = '';
				newContact.Birth_Year__c = '';
				newContact.birth_day__c = '';
			}
			if (newContact.RecordTypeId == VOLUNTEER_RT_ID || newContact.RecordTypeId == BOARD_MEMBER_RT_ID) {
				if (newContact.is_Active_Volunteer__c == false && !isNotActiveVolunteer(newContact)) {
					newContact.is_Active_Volunteer__c = true;
				}
				if (newContact.is_Active_Volunteer__c == true && isNotActiveVolunteer(newContact)) {
					newContact.is_Active_Volunteer__c = false;
				}
			}
		}
        wishChildIdSet = ContactService.updateWishChildContactInfo(newContactsList);
        ContactService.updateFamilyContactDetails(wishChildIdSet, newContactsList);
        ContactService.matchConditionDescription(newContactsList, oldContactsMap);
        ContactService.updateContactHiddenFields(newContactsList);
        ContactService.clearHiddenFields(newContactsList);
        ContactService.updatePicklistTranslations(newContactsMap, oldContactsMap);
        ContactService.populateRegionChapterOnMedicalProfessional(newContactsList, oldContactsMap);
        ContactService.updateContactOwnerToChapter(newContactsList, oldContactsMap);
    }

    /**
    * After update of contact
    */
    public override void handleAfterUpdate() {
        if (RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }
        List<Contact> volunteerContactList = new List<Contact>();
        for (Contact newContact : newContactsList) {
            Contact oldContact = oldContactsMap.get(newContact.Id);
            if (newContact.recordTypeId == VOLUNTEER_RT_ID && oldContact.recordTypeId != VOLUNTEER_RT_ID) {
                volunteerContactList.add(newContact);
            }
        }
        if (RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) {
            RecursiveTriggerHandler.isFirstTime = false;
            ContactService.updateEmailAddress(newContactsList, oldContactsMap);
        }
        ContactService.createAffiliation(volunteerContactList);
        ContactService.updateHouseHoldAddress(newContactsList, oldContactsMap);
        ContactService.updateRelationship(newContactsList, oldContactsMap);
        ContactService.updateMedicalProfessional(newContactsList, oldContactsMap);
        ContactService.updateOrgAffiliationStatus(newContactsList, oldContactsMap);
        ContactService.createVolunteerRoles(newContactsList, oldContactsMap);
        ContactService.createZipcodeUpdateTask(newContactsList, oldContactsMap);
        ContactService.updateUserDetails(newContactsList, oldContactsMap);
        ContactService.shareContactRecord(newContactsMap, oldContactsMap);
        ContactService.updateHiddenCaseFields(newContactsList, oldContactsMap);
        ContactService.shareContactToChapter(newContactsList, oldContactsMap);
    }

	/**
	* Before delete of contact
	*/
	public override void handleBeforeDelete() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		Set<Id> wishFormIdSet = new Set<Id>();
		for (Contact contact : oldContactsList) {
			contactMap.put(contact.Id, contact);
			if (contact.Hidden_Wish_Form_Id__c != null) {
				wishFormIdSet.add(contact.Hidden_Wish_Form_Id__c);
			}
		}
		ContactService.validateContact(contactMap);
	}

	//Check if mailing address has been updated
	private static Boolean hasMailingAddressChanged(Contact newContact, Contact oldContact) {
		return (newContact.MailingStreet != oldContact.MailingStreet
				|| newContact.MailingCity != oldContact.MailingCity
				|| newContact.MailingState != oldContact.MailingState
				|| newContact.MailingStateCode != oldContact.MailingStateCode
				|| newContact.MailingPostalCode != oldContact.MailingPostalCode);
	}
	//Check if other address has been updated
	private static Boolean hasOtherAddressChanged(Contact newContact, Contact oldContact) {
		return (newContact.OtherStreet != oldContact.OtherStreet
				|| newContact.OtherState != oldContact.OtherState
				|| newContact.OtherStateCode != oldContact.OtherStateCode
				|| newContact.OtherCity != oldContact.OtherCity
				|| newContact.OtherPostalCode != oldContact.OtherPostalCode);
	}
	//Check if contact is active volunteer
	private static Boolean isNotActiveVolunteer(Contact newContact) {
		return(newContact.Active_Board_Member__c == false
				&& newContact.Active_Non_Wish_Granter__c == false
				&& newContact.Active_Single_Day_Event_Volunteer__c == false
				&& newContact.Active_Wish_Granter__c == false);
	}
	//Create map of month name with coordinating digit value
	private static Map<String, String> constructMonthNameValueMap() {
		Map<String, String> monthValueMap = new Map<String, String>();
		monthValueMap.put('January', '1');
		monthValueMap.put('February', '2');
		monthValueMap.put('March', '3');
		monthValueMap.put('April', '4');
		monthValueMap.put('May', '5');
		monthValueMap.put('June', '6');
		monthValueMap.put('July', '7');
		monthValueMap.put('August', '8');
		monthValueMap.put('September', '9');
		monthValueMap.put('October', '10');
		monthValueMap.put('November', '11');
		monthValueMap.put('December', '12');
		return monthValueMap;
	}
	//Create map of month digit value with coordinating name
	private static Map<String, String> constructMonthValueNameMap() {
		Map<String, String> monthNameMap = new Map<String, String>();
		monthNameMap.put('1', 'January');
		monthNameMap.put('2', 'February');
		monthNameMap.put('3', 'March');
		monthNameMap.put('4', 'April');
		monthNameMap.put('5', 'May');
		monthNameMap.put('6', 'June');
		monthNameMap.put('7', 'July');
		monthNameMap.put('8', 'August');
		monthNameMap.put('9', 'September');
		monthNameMap.put('10', 'October');
		monthNameMap.put('11', 'November');
		monthNameMap.put('12', 'December');
		return monthNameMap;
	}
}