/**
 * @description Domain class for Contact trigger
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/24/2020
 */
public with sharing class ContactDomain extends trac_TriggerHandlerBase {
    
    private List<Contact> newContactsList = (List<Contact>)newRecordsList;
    private List<Contact> oldContactsList = (List<Contact>)oldRecordsList;
    private Map<Id, Contact> newContactsMap = (Map<Id, Contact>)newRecordsMap;
    private Map<Id, Contact> oldContactsMap = (Map<Id, Contact>)oldRecordsMap;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static Id WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id WISH_FAMILY_RT_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static Id BOARD_MEMBER_RT_ID = Constant_AC.BOARD_MEMBER_RT_ID;
    private final static Id MEDICAL_PROFESSIONAL_RT_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
    private final static String CONTACT_WISH_CHILD_RT_LABEL = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
    private final static String ACCOUNT_NAME_MAW_AMERICA = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
    private final static String RELATIONSHIP_TYPE_PARENT_GUARDIAN = 'Parent/Legal Guardian';
    private final static String REMOVE = 'Remove';

    /**
    * Before insert of contact
    */
    public override void handleBeforeInsert() {
        Map<String, String> monthValueMap = new Map<String, String>(constructMonthNameValueMap());
        for(Contact contact : newContactsList) {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == null) {
                if(contact.RecordTypeId == VOLUNTEER_RT_ID) {
                    contact.Region_Chapter__c = contact.AccountId;
                }
                if(contact.birth_day__c != null && contact.birth_year__c != null && contact.birth_month__c != null) {
                    date dtConverted = Date.valueOf(contact.birth_year__c + '-' + monthValueMap.get(contact.birth_month__c) + '-' + contact.birth_day__c);
                    contact.BirthDate = dtConverted ;
                }
            }
            if(contact.RecordTypeId == WISH_CHILD_RT_ID) {
                contact.Relationship_Type__c = CONTACT_WISH_CHILD_RT_LABEL;
            } else if(contact.RecordTypeId == WISH_FAMILY_RT_ID ) {
                contact.Relationship_Type__c = RELATIONSHIP_TYPE_PARENT_GUARDIAN;
            }
        }
    }

    /**
    * After insert of contact
    */
    public override void handleAfterInsert() {
        Map<String, List<Contact>> contactChapterMap = new Map<String, List<Contact>>();
        for(Contact contact : newContactsList) {
            if(contact.Region_Chapter__c!= null && contact.Region_Chapter__r.Name != ACCOUNT_NAME_MAW_AMERICA) {
                if(contactChapterMap.containsKey(contact.Region_Chapter__r.Name)) {
                    contactChapterMap.get(contact.Region_Chapter__r.Name).add(contact);
                } else {
                    contactChapterMap.put(contact.Region_Chapter__r.Name, new List<Contact>{contact});
                }
            }
        }
        if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == null) {
            RecursiveTriggerHandler.isFirstTime = false;
            ContactService.createAffiliation(newContactsList);
        }
        if(!contactChapterMap.isEmpty()) {
            ChapterStaffRecordSharing_AC.ContactSharing(contactChapterMap);
        }
        ContactService.updateWishFormContact(newContactsList);
        ContactService.createVolunteerUser(newContactsMap.keySet());
    }

    /**
    * Before update of contact
    */
    public override void handleBeforeUpdate() {
        List<Contact> contactIcdChangeList = new List<Contact>();
        Set<Id> icdCodeInfoIdSet = new Set<Id>();
        List<Contact> conICDList = new List<Contact>();
        Map<Id, Set<Integer>> icdInfoMap = new Map<Id, Set<Integer>>();
        Map<String, String> monthValueMap = new Map<String, String>(constructMonthNameValueMap());
        Map<String, String> monthNameMap = new Map<String, String>(constructMonthValueNameMap());
        Map<Id, Contact> contactRelationshipMap = new Map<Id, Contact>();
        Set<Id> contactRemoveSet = new Set<Id>();
        Set<Id> wishChildIdSet = new Set<Id>();
        Map<Id, Contact> contactRecalledMap = new Map<Id, Contact>();
        if(RecursiveTriggerHandler.blockBeforeUpdate) {
            return;
        }
        for(Contact newContact : newContactsList) {
            Contact oldContact = oldContactsMap.get(newContact.Id);
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == null) {
                if(newContact.SD1_ICD_Code__c != oldContact.SD1_ICD_Code__c && newContact.SD1_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD1_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(1);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{
                            1
                                });
                    }
                }
                if(newContact.SD2_ICD_Code__c != oldContact.SD2_ICD_Code__c && newContact.SD2_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD2_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(2);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{
                            2
                                });
                    }
                }
                if(newContact.SD3_ICD_Code__c != oldContact.SD3_ICD_Code__c && newContact.SD3_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD3_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(3);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{
                            3
                                });
                    }
                }
                if(newContact.SD4_ICD_Code__c != oldContact.SD4_ICD_Code__c && newContact.SD4_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD4_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(4);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{
                            4
                                });
                    }
                }
                if(newContact.ICD_10_Code__c != oldContact.ICD_10_Code__c && newContact.ICD_10_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.ICD_10_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(5);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{
                            5
                                });
                    }
                }
                if(hasMailingAddressChanged(newContact, oldContact)) {
                    newContact.MailingAddressVerified__c = false;
                    newContact.MailingAddressVerificationAttempted__c = null;
                    newContact.County__c = ' ';
                }
                if(hasOtherAddressChanged(newContact, oldContact)) {
                    newContact.OtherAddressVerified__c = false;
                    newContact.OtherAddressVerificationAttempted__c = null;
                }
                if(newContact.RecordTypeId == VOLUNTEER_RT_ID && newContact.RecordTypeId != oldContact.RecordTypeId) {
                    newContact.AccountId = newContact.Region_Chapter__c;
                }
                if(newContact.Birth_Year__c != oldContact.Birth_Year__c || newContact.Birth_Month__c != oldContact.Birth_Month__c || newContact.Birth_Day__c != oldContact.Birth_Day__c) {
                    if(newContact.Birth_Month__c != null && newContact.Birth_Day__c != null && newContact.Birth_Year__c != null) {
                        date dtConverted = Date.valueOf(newContact.birth_year__c + '-' + monthValueMap.get(newContact.birth_month__c) + '-' + newContact.birth_day__c);
                        newContact.BirthDate = dtConverted ;
                    } else {
                        newContact.BirthDate = null;
                    }
                } else if(newContact.BirthDate != null && newContact.BirthDate != oldContact.BirthDate) {
                    newContact.Birth_Month__c = monthNameMap.get(String.valueOf(newContact.BirthDate.month()));
                    newContact.Birth_Year__c = String.valueOf(newContact.BirthDate.year());
                    newContact.birth_day__c = String.valueOf(newContact.BirthDate.day());
                } else if(newContact.BirthDate == null && newContact.BirthDate != oldContact.BirthDate) {
                    newContact.Birth_Month__c = '';
                    newContact.Birth_Year__c = '';
                    newContact.birth_day__c = '';
                }
                if(newContact.RecordTypeId == VOLUNTEER_RT_ID || newContact.RecordTypeId == BOARD_MEMBER_RT_ID) {
                    if(newContact.is_Active_Volunteer__c == false && (newContact.Active_Board_Member__c == true || newContact.Active_Non_Wish_Granter__c == true
                                                                      || newContact.Active_Single_Day_Event_Volunteer__c == true || newContact.Active_Wish_Granter__c == true)) {
                                                                          newContact.is_Active_Volunteer__c = true;
                                                                      }
                    if(newContact.is_Active_Volunteer__c == true && (newContact.Active_Board_Member__c == false && newContact.Active_Non_Wish_Granter__c == false
                                                                     && newContact.Active_Single_Day_Event_Volunteer__c == false && newContact.Active_Wish_Granter__c == false)) {
                                                                         newContact.is_Active_Volunteer__c = false;
                                                                     }
                }
                if(newContact.RecordTypeId == WISH_CHILD_RT_ID && newContact.IsContactInfoUpdated__c == true) {
                    if(newContact.Hidden_Preferred_Contact_Rel_Id__c != null && newContact.Hidden_Preferred_Contact_Rel_Id__c != REMOVE) {
                        contactRelationshipMap.put(newContact.Hidden_Preferred_Contact_Rel_Id__c, newContact);
                        contactRemoveSet.add(newContact.Id);
                    }
                    if(newContact.Hidden_Preferred_Contact_Rel_Id__c == REMOVE) {
                        contactRemoveSet.add(newContact.Id);
                    } 
                    if((newContact.Hidden_Current_Pref_Con_Rel_Id__c != null && newContact.Hidden_Current_Pref_Con_Rel_Id__c != '') 
                       && newContact.Hidden_Preferred_Contact_Rel_Id__c != REMOVE) {
                           contactRelationshipMap.put(newContact.Hidden_Current_Pref_Con_Rel_Id__c, newContact);
                       }
                    if(newContact.IsRejected_Contact_Info__c == true || newContact.isRecall_Contact_Info__c == true) {
                        contactRecalledMap.put(newContact.Id, newContact);
                    }
                }
            }
        }
        wishChildIdSet = ContactService.updateWishChildContactInfo(newContactsList);
        if(!wishChildIdSet.isEmpty()) {
            ContactService.updateFamilyContactDetails(wishChildIdSet, contactRelationshipMap, contactRemoveSet);
        }
        if(!contactRecalledMap.isEmpty()) {
            ContactService.updateContactHiddenFields(contactRecalledMap.keySet());
            ContactService.clearHiddenFields(contactRecalledMap.values());
        }
        if(!icdInfoMap.isEmpty()) {
            ContactService.matchConditionDescription(icdInfoMap, conICDList, icdCodeInfoIdSet);
        }
    }
	
    /**
    * After update of contact
    */
    public override void handleAfterUpdate() {
        List<Contact> volunteerContactList = new List<Contact>();
        List<Contact> wishFormContactList = new List<Contact>();
        List<Contact> wishFormFamilyContactList = new List<Contact>();
        Map<Id, Contact> contactApplicationMap = new Map<Id, Contact>();
        Set<Id> medicalContactIdSet = new Set<Id>();
        Set<Id> contactHouseholdSet = new Set<Id>();
        Map<Id, Contact> wishFamilyContactMap = new Map<Id, Contact>();
        if(RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }
        for(Contact newContact : newContactsList) {
            Contact oldContact = oldContactsMap.get(newContact.Id);
            if(newContact.recordTypeId == VOLUNTEER_RT_ID && oldContact.recordTypeId != VOLUNTEER_RT_ID) {
                volunteerContactList.add(newContact);    
            }
            if(newContact.RecordTypeId == WISH_CHILD_RT_ID && newContact.Hidden_Wish_Form_Id__c != null) {
                wishFormContactList.add(newContact);
            }
            if(newContact.RecordTypeId == WISH_FAMILY_RT_ID && newContact.Hidden_Wish_Form_Id__c != null  
               && (hasNameChanged(newContact, oldContact) || hasMailingAddressChanged(newContact, oldContact) 
                   || hasFamilyInformationChanged(newContact, oldContact))) {
                       wishFormFamilyContactList.add(newContact);
                   }
            if(newContact.is_Application__c != oldContact.is_Application__c) {
                contactApplicationMap.put(newContact.Id, newContact);                
            }
            if(newContact.recordTypeId == MEDICAL_PROFESSIONAL_RT_ID  
               && (newContact.Name != oldContact.Name || newContact.Email != oldContact.Email)) {
                   medicalContactIdSet.add(newContact.Id);
               }
            if(newContact.Same_as_Household_Address__c != oldContact.Same_as_Household_Address__c && newContact.Same_as_Household_Address__c == true) {
                contactHouseholdSet.add(newContact.Id);
            }
            if(newContact.RecordTypeId == WISH_FAMILY_RT_ID && newContact.Relationship__c != oldContact.Relationship__c) {
                wishFamilyContactMap.put(newContact.Id, newContact);
            }
        }
        if(RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) {
            RecursiveTriggerHandler.isFirstTime = false;
            ContactService.updateEmailAddress(newContactsList, oldContactsMap);
        }
        if(!wishFormContactList.isEmpty()) {
            ContactService.updateWishFormRecord(wishFormContactList);
        }
        if(!wishFormFamilyContactList.isEmpty()) {
            ContactService.updateWishFormRecord(wishFormFamilyContactList);
        }
        if(!volunteerContactList.isEmpty()) {
            ContactService.createAffiliation(volunteerContactList);
        }
        if(!contactApplicationMap.isEmpty()) {
            ContactService.updateOrgAffiliationStatus(contactApplicationMap);
        }
        if(!medicalContactIdSet.isEmpty()) {
            ContactService.updateMedicalProfessional(medicalContactIdSet);
        }
        if(!contactHouseholdSet.isEmpty()) {
            ContactService.updateHouseHoldAddress(contactHouseholdSet);
        }
        if(!wishFamilyContactMap.isEmpty()) {
            ContactService.updateRelationship(wishFamilyContactMap);
        }
        ContactService.createVolunteerRoles(newContactsList, oldContactsMap);
        ContactService.createZipcodeUpdateTask(newContactsList, oldContactsMap);
        ContactService.updateUserDetails(newContactsList, oldContactsMap);
        ContactService.shareContactRecord(newContactsMap, oldContactsMap);
        ContactService.updateHiddenCaseFields(newContactsList, oldContactsMap);
    }

    /**
    * Before delete of contact
    */
    public override void handleBeforeDelete() {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<Id> wishFormIdSet = new Set<Id>();
        for(Contact contact : oldContactsList) {
            contactMap.put(contact.Id, contact);
            if(contact.Hidden_Wish_Form_Id__c != null){
                wishFormIdSet.add(contact.Hidden_Wish_Form_Id__c);
            }
        }
        if(!wishFormIdSet.isEmpty()) {
            ContactService.deleteWishForm(wishFormIdSet);
        }
        ContactService.updateAffiliationPrimaryStatus(contactMap);
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
    //Check if name has been updated
    private static Boolean hasNameChanged(Contact newContact, Contact oldContact) {
        return (newContact.FirstName != oldContact.FirstName 
                || newContact.Middle_Name__c!= oldContact.Middle_Name__c 
                || newContact.LastName != oldContact.LastName
                || newContact.Preferred_Name__c != oldContact.Preferred_Name__c);
    }
    //Check if family information has been updated
    private static Boolean hasFamilyInformationChanged(Contact newContact, Contact oldContact) {
        return (newContact.Email != oldContact.Email 
                || newContact.T_Shirt_Size__c != oldContact.T_Shirt_Size__c
                || newContact.Residing_with_Wish_child__c != oldContact.Residing_with_Wish_child__c 
                || newContact.HomePhone != oldContact.HomePhone 
                || newContact.Relationship__c != oldContact.Relationship__c 
                || newContact.npe01__WorkPhone__c != oldContact.npe01__WorkPhone__c
                || newContact.Birthdate != oldContact.Birthdate
                || newContact.MobilePhone != oldContact.MobilePhone
                || newContact.Gender__c != oldContact.Gender__c
                || newContact.MailingCountry != oldContact.MailingCountry);
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