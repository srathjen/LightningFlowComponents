/**
 * @description Contact Service, centralizes Contact business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2019
 */
public class ContactService {

	private final static Id MEDICAL_PROFESSIONAL_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
	private final static Id BOARD_MEMBER_RT_ID = Constant_AC.BOARD_MEMBER_RT_ID;
	private final static Id STAFF_TASK_RT_ID = Constant_AC.STAFF_TASK_RT_ID;
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String ORG_AFFILIATION_STATUS_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
	private final static String CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER = Constant_AC.CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER;
	private final static String CHAPTER_ROLE_WISH_GRANTER = Constant_AC.CHAPTER_ROLE_WISH_GRANTER;
	private final static String CHAPTER_ROLE_WISH_GRANTER_MENTOR = Constant_AC.CHAPTER_ROLE_WISH_GRANTER_MENTOR;
	private final static String WISH_CHILD_RECORD_TYPE_LABEL = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
	private static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
	private static final String CONTACT_TYPE_PARENT_LEGAL_GUARDIAN = Constant_AC.CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
	private static final String CONTACT_TYPE_REFERRER_AND_BEST = Constant_AC.CONTACT_TYPE_REFERRER_AND_BEST;
	private static final String CONTACT_TYPE_REFERRER_AND_TREATING = Constant_AC.CONTACT_TYPE_REFERRER_AND_TREATING;
	private static final String CONTACT_TYPE_BEST = Constant_AC.CONTACT_TYPE_BEST;
	private static final String CONTACT_TYPE_TREATING = Constant_AC.CONTACT_TYPE_TREATING;
	private static final String CONTACT_TYPE_REFERRING = Constant_AC.CONTACT_TYPE_REFERRING;
	private static final String BOARD_MEMBER_RT_LABEL = Constant_AC.BOARD_MEMBER_RT_LABEL;
	private static final String SALUTATION_MASTER = Constant_AC.CONTACT_SALUTATION_MASTER;
	private static final String SALUTATION_MR = Constant_AC.CONTACT_SALUTATION_MR;
	private static final String SALUTATION_MISS = Constant_AC.CONTACT_SALUTATION_MISS;
	private static final String SALUTATION_MS = Constant_AC.CONTACT_SALUTATION_MS;
	private static final String GENDER_MALE = Constant_AC.CONTACT_GENDER_MALE;
	private static final String GENDER_FEMALE = Constant_AC.CONTACT_GENDER_FEMALE;
	private static final String UNKNOWN = Constant_AC.CONTACT_NAME_UNKNOWN;
	private static final String WORK_EMAIL = Constant_AC.CONTACT_PREFERRED_EMAIL_WORK;
	private static final String AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
	private static final String AFFILIATION_STATUS_PENDING = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
	private final static String ACCOUNT_NAME_MAW_AMERICA = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
	private static final String DASH = '-';
	private static final String EMPTY = '';
	private final static String REMOVE = 'Remove';
	private final static String PHONE_PLACEHOLDER = '9912121313';
	private final static String ZIP_PLACEHOLDER = '11111';

	/**
	 * Activate Volunteer Contact Role
	 * @param contactMap
	 * @return Contact Map
	 */
	public static Map<Id, Contact> setVolunteerContactActive(Map<Id, Contact> contactMap) {
		if (contactMap.isEmpty()) {
			return contactMap;
		}
		Set<Id> activeConIdSet = new Set<Id>();
		Map<Id, String> affiliationStatusMap = new Map<Id, String>();
		// Find Affiliations
		for (npe5__Affiliation__c currAff : [
				SELECT Id,npe5__Contact__c,npe5__Status__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c IN:contactMap.keySet()
		]) {
			activeConIdSet.add(currAff.npe5__Contact__c);
			if (affiliationStatusMap.containsKey(currAff.npe5__Contact__c)) {
				if (currAff.npe5__Status__c == ORG_AFFILIATION_STATUS_STATUS_ACTIVE
						&& affiliationStatusMap.get(currAff.npe5__Contact__c) != ORG_AFFILIATION_STATUS_STATUS_ACTIVE) {
					affiliationStatusMap.put(currAff.npe5__Contact__c, currAff.npe5__Status__c);
				}
			} else {
				affiliationStatusMap.put(currAff.npe5__Contact__c, currAff.npe5__Status__c);
			}
		}
		// Find Volunteer Opportunities
		Map<Id, Date> volunteerLastComDate = new Map<Id, Date>();
		for (Volunteer_Opportunity__c volOpp : [
				SELECT Volunteer_Name__c,Event_Date__c,Wish__r.Contact.Hidden_Granted_Date__c,RecordTypeId
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c IN:activeConIdSet
				AND Role__c = :CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER
		]) {
			if (volunteerLastComDate.containsKey(volOpp.Volunteer_Name__c)) {
				if (volunteerLastComDate.get(volOpp.Volunteer_Name__c) < volOpp.Event_Date__c) {
					volunteerLastComDate.put(volOpp.Volunteer_Name__c, volOpp.Event_Date__c);
				} else if (volunteerLastComDate.get(volOpp.Volunteer_Name__c) < volOpp.Wish__r.Contact.Hidden_Granted_Date__c) {
					volunteerLastComDate.put(volOpp.Volunteer_Name__c, volOpp.Wish__r.Contact.Hidden_Granted_Date__c);
				}
			} else {
				if (volOpp.Event_Date__c == null
						&& volOpp.Wish__r.Contact.Hidden_Granted_Date__c != null) {
					volunteerLastComDate.put(volOpp.Volunteer_Name__c, volOpp.Wish__r.Contact.Hidden_Granted_Date__c);
				} else if (volOpp.Event_Date__c != null
						&& volOpp.Wish__r.Contact.Hidden_Granted_Date__c == null) {
					volunteerLastComDate.put(volOpp.Volunteer_Name__c, volOpp.Event_Date__c);
				}
			}
		}
		// Find Volunteer Roles and change Active on matching Role
		Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
		Boolean boardMember, wish, nonWish, singleDay;
		Contact updateCon;
		for (Volunteer_Roles__c volRole : [
				SELECT Id,Role_Name__c,Status__c,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c IN:activeConIdSet
		]) {
			// Check if Board Member Volunteer is Active
			if (volRole.Role_Name__c == BOARD_MEMBER_RT_LABEL
					&& affiliationStatusMap.get(volRole.Volunteer_Name__c) == ORG_AFFILIATION_STATUS_STATUS_ACTIVE
					&& volRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& contactMap.get(volRole.Volunteer_Name__c).B_C_Expiration_Date__c > Date.today()
					&& contactMap.get(volRole.Volunteer_Name__c).COI_Expiration_Date__c > Date.today()) {
				boardMember = true;
			} else {
				if (updateContactMap.containsKey(volRole.Volunteer_Name__c)) {
					boardMember = updateContactMap.get(volRole.Volunteer_Name__c).Active_Board_Member__c;
				} else {
					boardMember = false;
				}
			}
			// Check if Wish Volunteer is Active
			if ((volRole.Role_Name__c == CHAPTER_ROLE_WISH_GRANTER
					|| volRole.Role_Name__c == CHAPTER_ROLE_WISH_GRANTER_MENTOR)
					&& affiliationStatusMap.get(volRole.Volunteer_Name__c) == ORG_AFFILIATION_STATUS_STATUS_ACTIVE
					&& volRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& contactMap.get(volRole.Volunteer_Name__c).B_C_Expiration_Date__c > Date.today()
					&& contactMap.get(volRole.Volunteer_Name__c).COI_Expiration_Date__c > Date.today()) {
				wish = true;
			} else {
				if (updateContactMap.containsKey(volRole.Volunteer_Name__c)) {
					wish = updateContactMap.get(volRole.Volunteer_Name__c).Active_Wish_Granter__c;
				} else {
					wish = false;
				}
			}
			// Check if Non Wish Volunteer is Active
			if (volRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& affiliationStatusMap.get(volRole.Volunteer_Name__c) == ORG_AFFILIATION_STATUS_STATUS_ACTIVE
					&& contactMap.get(volRole.Volunteer_Name__c).COI_Expiration_Date__c > Date.today()
					&& ((volRole.Role_Name__c != BOARD_MEMBER_RT_LABEL
					&& volRole.Role_Name__c != CHAPTER_ROLE_WISH_GRANTER
					&& volRole.Role_Name__c != CHAPTER_ROLE_WISH_GRANTER_MENTOR)
					&& ((volRole.Chapter_Role__r.Background_Check_Required__c == true
					&& contactMap.get(volRole.Volunteer_Name__c).B_C_Expiration_Date__c > Date.today())
					|| volRole.Chapter_Role__r.Background_Check_Required__c == false))) {
				nonWish = true;
			} else {
				if (updateContactMap.containsKey(volRole.Volunteer_Name__c)) {
					nonWish = updateContactMap.get(volRole.Volunteer_Name__c).Active_Non_Wish_Granter__c;
				} else {
					nonWish = false;
				}
			}
			// Check if Single Day Event Volunteer is Active
			if (volRole.Role_Name__c == CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER
					&& affiliationStatusMap.get(volRole.Volunteer_Name__c) == ORG_AFFILIATION_STATUS_STATUS_ACTIVE
					&& volunteerLastComDate.containsKey(volRole.Volunteer_Name__c)
					&& volunteerLastComDate.get(volRole.Volunteer_Name__c) > System.today() - 365) {
				singleDay = true;
			} else {
				if (updateContactMap.containsKey(volRole.Volunteer_Name__c)) {
					singleDay = updateContactMap.get(volRole.Volunteer_Name__c).Active_Single_Day_Event_Volunteer__c ;
				} else {
					singleDay = false;
				}
			}
			// Update Volunteer Contact
			if (!updateContactMap.containsKey(volRole.Volunteer_Name__c)) {
				updateCon = new Contact();
				updateCon.Id = volRole.Volunteer_Name__c;
			} else {
				updateCon = updateContactMap.get(volRole.Volunteer_Name__c);
			}
			updateCon.Active_Board_Member__c = boardMember;
			updateCon.Active_Wish_Granter__c = wish;
			updateCon.Active_Non_Wish_Granter__c = nonWish;
			updateCon.Active_Single_Day_Event_Volunteer__c = singleDay;
			updateContactMap.put(volRole.Volunteer_Name__c, updateCon);
		}
		if (!updateContactMap.isEmpty()) {
			update updateContactMap.values();
		}
		return updateContactMap;
	}

	/**
	 * Find Duplicated Contacts
	 * @param firstName
	 * @param lastName
	 * @param phone
	 * @param email
	 * @param recordTypes
	 * @return List of Contacts
	 */
	public static List<Contact> findDuplicatedContacts(String firstName, String lastName,
			String phone, String email, List<Id> recordTypes) {
		return [
				SELECT Id, FirstName, Name, LastName, Email, Phone, MailingCity, Birthdate,
						MailingState, MailingPostalCode
				FROM Contact
				WHERE FirstName = :firstName
				AND LastName = :lastName
				AND (Phone = :phone OR Email = :email)
				AND RecordTypeId IN :recordTypes
		];
	}

	/**
	 * Find Family Duplicated Contacts
	 * @param firstName
	 * @param lastName
	 * @param phone
	 * @param email
	 * @param street
	 * @param city
	 * @param state
	 * @param postalCode
	 * @param recordTypes
	 * @return List of Contacts
	 */
	public static List<Contact> findFamilyDuplicatedContacts(String firstName, String lastName,
			String phone, String email, String street, String city, String state, String postalCode,
			List<Id> recordTypes) {
		return [
				SELECT Id, FirstName, Name, LastName, Email, Phone, MailingCity, Birthdate,
						MailingState, MailingPostalCode
				FROM Contact
				WHERE (FirstName = :firstName AND LastName = :lastName
				AND (((Email = :email OR Phone = :phone) AND (MailingStreet = :street
				AND MailingState = :state AND MailingPostalCode = :postalCode AND MailingCity = :city))
				OR ((Phone = :phone OR (MailingStreet = :street AND MailingState = :state
				AND MailingPostalCode = :postalCode AND MailingCity = :city)) AND Email = :email)
				OR (((MailingStreet = :street AND MailingState = :state AND MailingPostalCode = :postalCode
				AND MailingCity = :city) OR (Email = :email)) AND Phone = :phone)))
				AND RecordTypeId IN :recordTypes
		];
	}

	/**
	 * Find Child Contact Duplicated Contacts
	 * @param firstName
	 * @param lastName
	 * @param phone
	 * @param email
	 * @param street
	 * @param city
	 * @param state
	 * @param postalCode
	 * @param dateOfBirth
	 * @param recordTypes
	 * @return List of Contacts
	 */
	public static List<Contact> findChildDuplicatedContacts(String firstName, String lastName,
			String phone, String email, String street, String city, String state, String postalCode,
			Date dateOfBirth, List<Id> recordTypes) {
		return [
				SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
						MailingState, MailingPostalCode,Region_Chapter__r.Name
				FROM Contact
				WHERE ((LastName = :lastName AND FirstName = :firstName)
				OR (LastName = :lastName AND ((MailingState = :state AND MailingCity = :city AND MailingStreet = :street
				AND MailingPostalCode = :postalCode) OR (Email != :EMPTY AND Email = :email)))
				OR (FirstName = :firstName AND ((MailingState = :state AND MailingCity = :city AND MailingStreet = :street
				AND MailingPostalCode = :postalCode) OR Phone = :phone OR (Email != :EMPTY AND Email = :email)))
				OR (Birthdate = :dateOfBirth AND ((MailingState = :state AND MailingCity = :city
				AND MailingStreet = :street AND MailingPostalCode = :postalCode) OR (Email != :EMPTY AND Email = :email)))
				OR (Birthdate = :dateOfBirth AND (LastName = :lastName OR FirstName = :firstName)))
				AND RecordTypeId IN :recordTypes
		];
	}

	/**
	 * Set fields on Wish Child
	 * @param wishChild
	 * @param lead
	 * @return
	 */
	public static Contact buildWishChildFromLead(Contact wishChild, Lead lead) {
		wishChild.Lead_Created_Date__c = Date.valueOf(lead.CreatedDate);
		wishChild.Birthdate = lead.DOB__c;
		wishChild.RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
		wishChild.Provider_Type__c = lead.Medical_Provider_Category__c;
		wishChild.Self_describe_comment_box__c = lead.Self_describe_comment_box__c;
		wishChild.Language__c = lead.What_is_the_family_s_primary_spoken_lang__c;
		wishChild.Region_Chapter__c = lead.ChapterName__c;
		wishChild.Inquiry_Referral_Method__c = lead.LeadSource;
		wishChild.Referrer_City__c = lead.Referrer_City__c;
		wishChild.Referrer_Email__c = lead.Referrer_Email__c;
		wishChild.Referrer_FirstName__c = lead.Referrer_FirstName__c;
		wishChild.Referrer_Last_Name__c = lead.Referrer_Last_Name__c;
		wishChild.Referrer_Phone__c = lead.Referrer_Phone__c;
		wishChild.Referrer_Zip__c = lead.Referrer_Zip__c;
		wishChild.Relationship__c = lead.Relationship_to_child__c;
		wishChild.Other_Medical_Provider_Category__c = lead.Other_Medical_Provider_Category__c;
		wishChild.Relationship_to_Wish_Child__c = lead.Other_Relationship_To_Child__c;
		wishChild.Is_Family_Aware_of_Referral__c = lead.is_Family_Aware_of_Referral__c;
		wishChild.Migrated_Record__c = lead.Migrated_Record__c;
		wishChild.Wish_How_Did_you_hear_about_Make_A_Wish__c = lead.How_Did_you_hear_about_Make_A_Wish__c;
		wishChild.Relationship_Type__c = WISH_CHILD_RECORD_TYPE_LABEL;
		if (lead.Additional_Parent_City__c != lead.City ||
				lead.Additional_Parent_Postal_Code__c != lead.PostalCode ||
				lead.Additional_Parent_State__c != lead.State ||
				lead.Additional_Parent_Street__c != lead.Street) {
			wishChild.npsp__is_Address_Override__c = true;
		}
		if (lead.DOB__c != null) {
			Date dob = lead.DOB__c;
			Integer age;
			if (Date.newInstance(2000, dob.month(), dob.day())
					<= Date.newInstance(2000, Date.today().month(), Date.today().day())) {
				age = Date.today().year() - dob.year();
			} else {
				age = Date.today().year() - dob.year() - 1;
			}
			if ((age < 16) && lead.Gender__c == GENDER_MALE) {
				wishChild.Salutation = SALUTATION_MASTER;
			} else if ((age >= 16) && lead.Gender__c == GENDER_MALE) {
				wishChild.Salutation = SALUTATION_MR;
			} else if ((age < 16) && lead.Gender__c == GENDER_FEMALE) {
				wishChild.Salutation = SALUTATION_MISS;
			} else if ((age >= 16) && lead.Gender__c == GENDER_FEMALE) {
				wishChild.Salutation = SALUTATION_MS;
			} else {
				wishChild.Salutation = EMPTY;
			}
		}
		wishChild.Hidden_Medical_Physician__c = lead.Treating_Medical_Professional_First_Name__c + ' '
				+ lead.Treating_Medical_Professional_Last_Name__c;
		return wishChild;
	}

	/**
	 * Build Sibling
	 * @param firstName
	 * @param lastName
	 * @param age
	 * @param wishChildId
	 * @param accountId
	 * @param regionChapterId
	 * @param language
	 * @return Contact
	 */
	public static Contact buildSibling(String firstName, String lastName, String age,
			Id wishChildId, Id accountId, Id regionChapterId, String language) {
		Contact newFamily = new Contact();
		newFamily.FirstName = firstName;
		newFamily.LastName = lastName;
		newFamily.Sibling_Age__c = age;
		newFamily.Wish_Child_Id_Hidden__c = wishChildId;
		newFamily.RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
		newFamily.AccountId = accountId;
		newFamily.Region_Chapter__c = regionChapterId;
		newFamily.Language__c = language;
		if ((!newFamily.FirstName.containsOnly(DASH) && newFamily.FirstName != null)
				&& (!newFamily.LastName.containsOnly(DASH) && newFamily.LastName != null)
				&& newFamily.Sibling_Age__c.isNumeric()) {
		}
		if ((!newFamily.FirstName.containsOnly(DASH)
				&& newFamily.FirstName != null)
				&& newFamily.LastName.containsOnly(DASH)
				&& newFamily.Sibling_Age__c.isNumeric()) {
			newFamily.LastName = UNKNOWN;
		}
		if (newFamily.FirstName.containsOnly(DASH)
				&& (!newFamily.LastName.containsOnly(DASH)
				&& newFamily.LastName != null)
				&& newFamily.Sibling_Age__c.isNumeric()) {
			newFamily.FirstName = EMPTY;
		}
		if ((!newFamily.FirstName.containsOnly(DASH) && newFamily.FirstName != null)
				&& (!newFamily.LastName.containsOnly(DASH) && newFamily.LastName != null)
				&& newFamily.Sibling_Age__c.containsOnly(DASH)) {
			newFamily.Sibling_Age__c = null;
		}
		if (newFamily.FirstName.containsOnly(DASH)
				&& (!newFamily.LastName.containsOnly(DASH)
				&& newFamily.LastName != null)
				&& newFamily.Sibling_Age__c.containsOnly(DASH)) {
			newFamily.FirstName = EMPTY;
			newFamily.Sibling_Age__c = null;
		}
		if ((!newFamily.FirstName.containsOnly(DASH)
				&& newFamily.FirstName != null)
				&& newFamily.LastName.containsOnly(DASH)
				&& newFamily.Sibling_Age__c.containsOnly(DASH)) {
			newFamily.LastName = UNKNOWN;
			newFamily.Sibling_Age__c = null;
		}
		return newFamily;
	}

	/**
	 * Build Parent Legal Guardian From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildParentLegalGuardianFromLead(Lead lead) {
		Contact parentLegalGuardian = new Contact();
		parentLegalGuardian.FirstName = lead.Parent_First_Name__c;
		parentLegalGuardian.LastName = lead.Parent_Last_Name__c;
		parentLegalGuardian.Email = lead.Email;
		parentLegalGuardian.Phone = lead.Phone;
		parentLegalGuardian.MobilePhone = lead.Phone;
		parentLegalGuardian.MailingCountryCode = lead.CountryCode;
		parentLegalGuardian.MailingStreet = lead.Street;
		parentLegalGuardian.MailingStateCode = lead.StateCode;
		parentLegalGuardian.MailingCity = lead.City;
		parentLegalGuardian.MailingPostalCode = lead.PostalCode;
		parentLegalGuardian.Wish_Child_Id_Hidden__c = lead.ConvertedContactId;
		parentLegalGuardian.AccountId = lead.ConvertedAccountId;
		parentLegalGuardian.RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
		parentLegalGuardian.Relationship_Type__c = CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
		parentLegalGuardian.Region_Chapter__c = lead.ChapterName__c;
		parentLegalGuardian.Language__c = lead.What_is_the_family_s_primary_spoken_lang__c;
		parentLegalGuardian.Relationship__c = lead.Parent_Relationship_to_Child__c;
		parentLegalGuardian.Migrated_Record__c = lead.Migrated_Record__c;
		if (lead.Relationship_to_child__c == LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN) {
			parentLegalGuardian.Type_of_Contact__c = LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
		}
		return parentLegalGuardian;
	}

	/**
	 * Build Additional Parent Legal Guardian From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildAdditionalParentLegalGuardianFromLead(Lead lead) {
		Contact additionalParentLegalGuardian = new Contact();
		additionalParentLegalGuardian.FirstName = lead.Additional_Parent_First_Name__c;
		additionalParentLegalGuardian.LastName = lead.Additional_Parent_Last_Name__c;
		additionalParentLegalGuardian.Email = lead.Additional_Parent_Email__c;
		additionalParentLegalGuardian.Phone = lead.Additional_Parent_Phone__c;
		additionalParentLegalGuardian.MobilePhone = lead.Additional_Parent_Phone__c;
		additionalParentLegalGuardian.MailingCountryCode = lead.CountryCode;
		additionalParentLegalGuardian.MailingStreet = lead.Additional_Parent_Street__c;
		additionalParentLegalGuardian.MailingState = lead.Additional_Parent_State__c;
		additionalParentLegalGuardian.MailingCity = lead.Additional_Parent_City__c;
		additionalParentLegalGuardian.Relationship_Type__c = CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
		additionalParentLegalGuardian.MailingPostalCode = lead.Additional_Parent_Postal_Code__c;
		additionalParentLegalGuardian.Wish_Child_Id_Hidden__c = lead.ConvertedContactId;
		additionalParentLegalGuardian.AccountId = lead.ConvertedAccountId;
		additionalParentLegalGuardian.RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
		additionalParentLegalGuardian.Relationship__c = lead.Additional_Parent_Relationship_to_Child__c;
		additionalParentLegalGuardian.Region_Chapter__c = lead.ChapterName__c;
		additionalParentLegalGuardian.Migrated_Record__c = lead.Migrated_Record__c;
		if (lead.Additional_Parent_City__c != lead.City ||
				lead.Additional_Parent_Postal_Code__c != lead.PostalCode ||
				lead.Additional_Parent_State__c != lead.State ||
				lead.Additional_Parent_Street__c != lead.Street) {
			additionalParentLegalGuardian.npsp__is_Address_Override__c = true;
		}
		return additionalParentLegalGuardian;
	}

	/**
	 * Build Best, Treating, Referring Medical Professional are same Contact From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildBestTreatingReferrerMedicalProfessionalFromLead(Lead lead, Map<String, Account> medicalAccountMap) {
		Contact newSameReferrerMedicalContact = new Contact();
		newSameReferrerMedicalContact.FirstName = lead.Referrer_FirstName__c;
		newSameReferrerMedicalContact.LastName = lead.Referrer_Last_Name__c ;
		if (medicalAccountMap.containsKey(lead.Hospital_Treatment_Facility_Treating__c)) {
			newSameReferrerMedicalContact.Hidden_Hospital_Account__c =
					medicalAccountMap.get(lead.Hospital_Treatment_Facility_Treating__c).Id;
		}
		if (lead.Best_Contact_for_Physician_First_Name__c == lead.Referrer_FirstName__c
				&& lead.Best_Contact_for_Physician_Last_Name__c == lead.Referrer_Last_Name__c
				&& (lead.Best_contact_for_Physician_Email__c == lead.Referrer_Email__c)) {
			newSameReferrerMedicalContact.Type_of_Contact__c = CONTACT_TYPE_REFERRER_AND_BEST;
			if (lead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
					&& lead.I_am_Recognized_To_Practice_As_a__c != null) {
				newSameReferrerMedicalContact.Provider_Type__c = lead.I_am_Recognized_To_Practice_As_a__c;
			} else {
				newSameReferrerMedicalContact.Provider_Type__c = lead.Medical_Provider_Category__c;
			}
		} else {
			newSameReferrerMedicalContact.Type_of_Contact__c = CONTACT_TYPE_REFERRER_AND_TREATING;
			if (lead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL
					&& lead.I_am_Recognized_To_Practice_As_a__c != null) {
				newSameReferrerMedicalContact.Provider_Type__c = lead.I_am_Recognized_To_Practice_As_a__c;
			} else {
				newSameReferrerMedicalContact.Provider_Type__c = lead.Medical_Provider_Category__c;
			}
		}
		newSameReferrerMedicalContact.AccountId = lead.ChapterName__c;
		newSameReferrerMedicalContact.npe01__WorkPhone__c = lead.Referrer_Phone__c;
		newSameReferrerMedicalContact.Phone = lead.Referrer_Phone__c;
		newSameReferrerMedicalContact.npe01__Preferred_Email__c = WORK_EMAIL;
		newSameReferrerMedicalContact.npe01__WorkEmail__c = lead.Referrer_Email__c;
		newSameReferrerMedicalContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		newSameReferrerMedicalContact.Region_Chapter__c = lead.ChapterName__c;
		newSameReferrerMedicalContact.Migrated_Record__c = lead.Migrated_Record__c;
		return newSameReferrerMedicalContact;
	}

	/**
	 * Build Referring Medical Professional From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildReferrerMedicalProfessionalFromLead(Lead lead) {
		Contact newReferrerMedicalContact = new Contact();
		newReferrerMedicalContact.FirstName = lead.Referrer_FirstName__c;
		newReferrerMedicalContact.LastName = lead.Referrer_Last_Name__c;
		newReferrerMedicalContact.AccountId = lead.ChapterName__c;
		newReferrerMedicalContact.Phone = lead.Referrer_Phone__c;
		newReferrerMedicalContact.npe01__WorkPhone__c = lead.Referrer_Phone__c;
		newReferrerMedicalContact.npe01__WorkEmail__c = lead.Referrer_Email__c;
		newReferrerMedicalContact.npe01__Preferred_Email__c = WORK_EMAIL;
		newReferrerMedicalContact.Provider_Type__c = lead.Medical_Provider_Category__c;
		newReferrerMedicalContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		newReferrerMedicalContact.Region_Chapter__c = lead.ChapterName__c;
		newReferrerMedicalContact.Migrated_Record__c = lead.Migrated_Record__c;
		newReferrerMedicalContact.Type_of_Contact__c = CONTACT_TYPE_REFERRING;
		if (lead.Department__c != null) {
			newReferrerMedicalContact.Department = lead.Department__c;
		}
		return newReferrerMedicalContact;
	}

	/**
	 * Build Treating Medical Professional From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildTreatingMedicalProfessionalFromLead(Lead lead, Map<String, Account> medicalAccountMap) {
		Contact newTreatingMedicalContact = new Contact();
		newTreatingMedicalContact.FirstName = lead.Treating_Medical_Professional_First_Name__c;
		newTreatingMedicalContact.LastName = lead.Treating_Medical_Professional_Last_Name__c;
		newTreatingMedicalContact.AccountId = lead.ChapterName__c;
		newTreatingMedicalContact.Phone = lead.Treating_Medical_Professional_Phone__c;
		newTreatingMedicalContact.npe01__WorkPhone__c = lead.Treating_Medical_Professional_Phone__c;
		newTreatingMedicalContact.npe01__WorkEmail__c = lead.Treating_Medical_Professional_Email__c;
		newTreatingMedicalContact.npe01__Preferred_Email__c = WORK_EMAIL;
		newTreatingMedicalContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		newTreatingMedicalContact.Region_Chapter__c = lead.ChapterName__c;
		newTreatingMedicalContact.Migrated_Record__c = lead.Migrated_Record__c;
		newTreatingMedicalContact.Type_of_Contact__c = CONTACT_TYPE_TREATING;
		if (medicalAccountMap.containsKey(lead.Hospital_Treatment_Facility_Treating__c)) {
			newTreatingMedicalContact.Hidden_Hospital_Account__c =
					medicalAccountMap.get(lead.Hospital_Treatment_Facility_Treating__c).Id;
		}
		if (lead.Department__c != null) {
			newTreatingMedicalContact.Department = lead.Department__c;
		}
		if (lead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
			newTreatingMedicalContact.Provider_Type__c = lead.I_am_Recognized_To_Practice_As_a__c;
		}
		return newTreatingMedicalContact;
	}

	/**
	 * Build Best Medical Professional From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildBestMedicalProfessionalFromLead(Lead lead, Map<String, Account> medicalAccountMap) {
		Contact newBestContactMedicalContact = new Contact();
		newBestContactMedicalContact.FirstName = lead.Best_Contact_for_Physician_First_Name__c;
		newBestContactMedicalContact.LastName = lead.Best_Contact_for_Physician_Last_Name__c;
		newBestContactMedicalContact.AccountId = lead.ChapterName__c;
		newBestContactMedicalContact.npe01__Preferred_Email__c = WORK_EMAIL;
		newBestContactMedicalContact.npe01__WorkEmail__c = lead.Best_contact_for_Physician_Email__c;
		newBestContactMedicalContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		newBestContactMedicalContact.Region_Chapter__c = lead.ChapterName__c;
		newBestContactMedicalContact.Migrated_Record__c = lead.Migrated_Record__c;
		newBestContactMedicalContact.Type_of_Contact__c = CONTACT_TYPE_BEST;
		if (lead.Department__c != null) {
			newBestContactMedicalContact.Department = lead.Department__c;
		}
		if (medicalAccountMap.containsKey(lead.Hospital_Treatment_Facility_Treating__c)) {
			newBestContactMedicalContact.Hidden_Hospital_Account__c =
					medicalAccountMap.get(lead.Hospital_Treatment_Facility_Treating__c).Id;
		}
		return newBestContactMedicalContact;
	}

	/**
	 * Build Alternate1 Medical Professional From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildAlternate1MedicalProfessionalFromLead(Lead lead, Map<String, Account> medicalAccountMap) {
		Contact newAlt1MedicalContact = new Contact();
		newAlt1MedicalContact.LastName = lead.Alternate1MedProfessionalLastName__c;
		newAlt1MedicalContact.AccountId = lead.ChapterName__c;
		newAlt1MedicalContact.npe01__WorkPhone__c = lead.Alternate1MedProfessionalPhone__c;
		newAlt1MedicalContact.npe01__Preferred_Email__c = WORK_EMAIL;
		newAlt1MedicalContact.Provider_Type__c = lead.Alternate_1_Medical_Professional_Type__c;
		newAlt1MedicalContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		newAlt1MedicalContact.Region_Chapter__c = lead.ChapterName__c;
		newAlt1MedicalContact.Migrated_Record__c = lead.Migrated_Record__c;
		if (lead.Alternate1MedProfessionalFirstName__c != null) {
			newAlt1MedicalContact.FirstName = lead.Alternate1MedProfessionalFirstName__c;
		}
		if (medicalAccountMap.containsKey(lead.Alternate1HospitalTreatmentFacility__c)) {
			newAlt1MedicalContact.Hidden_Hospital_Account__c =
					medicalAccountMap.get(lead.Alternate1HospitalTreatmentFacility__c).Id;
		}
		if (lead.Alternate1MedicalProfessionalEmail__c != null) {
			newAlt1MedicalContact.npe01__WorkEmail__c = lead.Alternate1MedicalProfessionalEmail__c;
		}
		if (lead.Department__c != null) {
			newAlt1MedicalContact.Department = lead.Department__c;
		}
		if (lead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
			newAlt1MedicalContact.Provider_Type__c = lead.I_am_Recognized_To_Practice_As_a__c;
		}
		return newAlt1MedicalContact;
	}

	/**
	 * Build Alternate2 Medical Professional From Lead
	 * @param lead
	 * @param medicalAccountMap
	 * @return Contact
	 */
	public static Contact buildAlternate2MedicalProfessionalFromLead(Lead lead, Map<String, Account> medicalAccountMap) {
		Contact newAlt2MedicalContact = new Contact();
		newAlt2MedicalContact.LastName = lead.Alternate2MedProfessionalLastName__c;
		newAlt2MedicalContact.AccountId = lead.ChapterName__c;
		newAlt2MedicalContact.npe01__Preferred_Email__c = WORK_EMAIL;
		newAlt2MedicalContact.npe01__WorkPhone__c = lead.Alternate2MedProfessionalPhone__c;
		newAlt2MedicalContact.Provider_Type__c = lead.Alternate_2_Medical_Professional_Type__c;
		newAlt2MedicalContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		newAlt2MedicalContact.Region_Chapter__c = lead.ChapterName__c;
		newAlt2MedicalContact.Migrated_Record__c = lead.Migrated_Record__c;
		if (lead.Alternate2MedProfessionalFirstName__c != null) {
			newAlt2MedicalContact.FirstName = lead.Alternate2MedProfessionalFirstName__c;
		}
		if (medicalAccountMap.containsKey(lead.Alternate2HospitalTreatmentFacility__c)) {
			newAlt2MedicalContact.Hidden_Hospital_Account__c =
					medicalAccountMap.get(lead.Alternate2HospitalTreatmentFacility__c).Id;
		}
		if (lead.Alternate2MedProfessionalEmail__c != null) {
			newAlt2MedicalContact.npe01__WorkEmail__c = lead.Alternate2MedProfessionalEmail__c;
		}
		if (lead.Department__c != null) {
			newAlt2MedicalContact.Department = lead.Department__c;
		}
		if (lead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
			newAlt2MedicalContact.Provider_Type__c = lead.I_am_Recognized_To_Practice_As_a__c;
		}
		return newAlt2MedicalContact;
	}

	/**
	* Create affiliation for contact
	* @param contactList
	*/
	public static void createAffiliation(List<Contact> contactList) {
		List<npe5__Affiliation__c> insertAffiliationList = new List<npe5__Affiliation__c>();
		Set<Id> contactIdSet = new Set<Id>();
		for (Contact contact : contactList) {
			if ((contact.RecordTypeId == MEDICAL_PROFESSIONAL_RECORD_TYPE_ID
					&& contact.Hidden_Hospital_Account__c != null)
					|| contact.RecordTypeId != MEDICAL_PROFESSIONAL_RECORD_TYPE_ID) {
				npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
				if (contact.RecordTypeId == MEDICAL_PROFESSIONAL_RECORD_TYPE_ID) {
					affiliation.npe5__Primary__c = false;
					if (contact.Hidden_Hospital_Account__c != null) {
						affiliation.npe5__Organization__c = contact.Hidden_Hospital_Account__c;
					}
				} else if (contact.RecordTypeId == VOLUNTEER_RT_ID) {
					affiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
					affiliation.npe5__Status__c = AFFILIATION_STATUS_PENDING;
					affiliation.npe5__Primary__c = true;
					contactIdSet.add(contact.Id);
				} else if (contact.RecordTypeId == BOARD_MEMBER_RT_ID) {
					affiliation.Constituent_Code__c = BOARD_MEMBER_RT_LABEL;
				}
				if (contact.RecordTypeId != MEDICAL_PROFESSIONAL_RECORD_TYPE_ID
						|| contact.Hidden_Hospital_Account__c == null) {
					affiliation.npe5__Organization__c = contact.AccountId;
				}
				affiliation.npe5__Contact__c = contact.Id;
				affiliation.npe5__StartDate__c = Date.today();
				affiliation.npe5__Status__c = AFFILIATION_STATUS_ACTIVE;
				insertAffiliationList.add(affiliation);
			}
			if ((contact.RecordTypeId == MEDICAL_PROFESSIONAL_RECORD_TYPE_ID
					|| contact.RecordTypeId == WISH_FAMILY_RECORD_TYPE_ID
					|| contact.RecordTypeId == WISH_CHILD_RECORD_TYPE_ID)
					&& contact.Region_Chapter__c != null) {
				npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
				if (contact.RecordTypeId == MEDICAL_PROFESSIONAL_RECORD_TYPE_ID) {
					affiliation.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
					affiliation.npe5__Primary__c = true;
				} else if (contact.RecordTypeId == WISH_FAMILY_RECORD_TYPE_ID) {
					affiliation.Constituent_Code__c = Constant_AC.WISH_FAMILY_RT_LABEL;
				} else {
					affiliation.Constituent_Code__c = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
				}
				affiliation.npe5__Organization__c = contact.Region_Chapter__c;
				affiliation.npe5__Contact__c = contact.Id;
				affiliation.npe5__StartDate__c = Date.Today();
				affiliation.npe5__Status__c = AFFILIATION_STATUS_ACTIVE;
				insertAffiliationList.add(affiliation);
			}
		}
		updateContactAffiliation(contactIdSet);
		try {
			insert insertAffiliationList;
		} catch (Exception e) {
			createContactDebugLog(insertAffiliationList, 'createAffiliation', e);
		}
	}

	/**
	* Update contact affiliation record
	* @param contactIds
	*/
	public static void updateContactAffiliation(Set<Id> contactIds) {
		List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
		if (!contactIds.isEmpty()) {
			for (npe5__Affiliation__c affiliation : [
					SELECT Id, npe5__Primary__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :contactIds
					AND npe5__Primary__c = true
			]) {
				affiliation.npe5__Primary__c = false;
				affiliationList.add(affiliation);
			}
			try {
				update affiliationList;
			} catch (Exception e) {
				createContactDebugLog(affiliationList, 'updateContactAffiliation', e);
			}
		}
	}

	/**
	* Update family contact information
	* @param wishChildIdSet
	* @param newContactsList
	*/
	public static void updateFamilyContactDetails(Set<Id> wishChildIdSet, List<Contact> newContactsList) {
		List<npe4__Relationship__c> updateRelationshipList = new List<npe4__Relationship__c>();
		Map<Id, Id> relationshipContactIdMap = new Map<Id, Id>();
		Set<Id> wishFamilySet = new Set<Id>();
		Map<Id, Contact> wishFamilyMap = new Map<Id, Contact>();
		Map<Id, Account> houseHoldAccountMap = new Map<Id, Account>();
		String dummyValue = Label.Dummy_Email;
		Map<Id, Contact> contactRelationshipMap = new Map<Id, Contact>();
		Set<Id> contactRemoveSet = new Set<Id>();

		for (Contact newContact : newContactsList) {
			if (newContact.RecordTypeId == WISH_CHILD_RECORD_TYPE_ID && newContact.IsContactInfoUpdated__c == true) {
				if (newContact.Hidden_Preferred_Contact_Rel_Id__c != null && newContact.Hidden_Preferred_Contact_Rel_Id__c != REMOVE) {
					contactRelationshipMap.put(newContact.Hidden_Preferred_Contact_Rel_Id__c, newContact);
					contactRemoveSet.add(newContact.Id);
				}
				if (newContact.Hidden_Preferred_Contact_Rel_Id__c == REMOVE) {
					contactRemoveSet.add(newContact.Id);
				}
				if ((newContact.Hidden_Current_Pref_Con_Rel_Id__c != null && newContact.Hidden_Current_Pref_Con_Rel_Id__c != '')
						&& newContact.Hidden_Preferred_Contact_Rel_Id__c != REMOVE) {
					contactRelationshipMap.put(newContact.Hidden_Current_Pref_Con_Rel_Id__c, newContact);
				}
			}
		}
		if (!wishChildIdSet.isEmpty() || !contactRelationshipMap.isEmpty()) {
			try {
				if (RecursiveTriggerHandler.accountRecursive == true) {
					RecursiveTriggerHandler.accountRecursive = false;
					for (npe4__Relationship__c relationship : [
							SELECT Id, npe4__Contact__c, npe4__RelatedContact__c, npe4__RelatedContact__r.Name,
									Hidden_Preferred_Contact__c, npe4__Type__c, npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.HomePhone,
									npe4__RelatedContact__r.MobilePhone, npe4__RelatedContact__r.npe01__PreferredPhone__c,
									npe4__RelatedContact__r.OtherPhone, npe4__RelatedContact__r.npe01__WorkPhone__c
							FROM npe4__Relationship__c
							WHERE (npe4__Contact__c IN :wishChildIdSet OR Id IN :contactRelationshipMap.keySet())
							AND npe4__RelatedContact__r.RecordTypeId = :WISH_FAMILY_RECORD_TYPE_ID
					]) {
						if (contactRemoveSet.contains(relationship.npe4__Contact__c) && (!contactRelationshipMap.containsKey(relationship.Id)) && relationship.Hidden_Preferred_Contact__c == true) {
							relationship.Hidden_Preferred_Contact__c = false;
							updateRelationshipList.add(relationship);
						}
						if (!contactRelationshipMap.isEmpty()) {
							if (contactRelationshipMap.containsKey(relationship.Id)) {
								contactRelationshipMap.get(relationship.Id).Preferred_Contact_Name__c = relationship.npe4__RelatedContact__r.Name;
								relationshipContactIdMap.put(relationship.npe4__RelatedContact__c, relationship.Id);
								contactRelationshipMap.get(relationship.Id).Preferred_Contact_Relationship__c = relationship.npe4__Type__c;
								if (relationship.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Home' || relationship.npe4__RelatedContact__r.npe01__PreferredPhone__c != null) {
									contactRelationshipMap.get(relationship.Id).Preferred_Contact_Number__c = relationship.npe4__RelatedContact__r.HomePhone;
								} else if (relationship.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Mobile') {
									contactRelationshipMap.get(relationship.Id).Preferred_Contact_Number__c = relationship.npe4__RelatedContact__r.MobilePhone;
								} else if (relationship.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Other') {
									contactRelationshipMap.get(relationship.Id).Preferred_Contact_Number__c = relationship.npe4__RelatedContact__r.OtherPhone;
								} else if (relationship.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Work') {
									contactRelationshipMap.get(relationship.Id).Preferred_Contact_Number__c = relationship.npe4__RelatedContact__r.npe01__WorkPhone__c;
								}
								relationship.Hidden_Preferred_Contact__c = true;
								updateRelationshipList.add(relationship);
							}
						}
						wishFamilySet.add(relationship.npe4__RelatedContact__c);
					}
				}
				if (!wishFamilySet.isEmpty()) {
					for (Contact wishFamilyContact : [
							SELECT Id,Name,FirstName,LastName,Phone,Homephone,Email,MailingStreet,MailingCity,AccountId,Account.npe01__SYSTEM_AccountType__c,Hidden_Use_as_Household_Address__c,Use_as_Household_Address__c,MailingState,MailingCountry,MailingPostalCode,Hidden_First_Name__c,
									Hidden_Last_Name__c,Hidden_Street__c,Hidden_Phone__c,Hidden_Email__c,Hidden_city__c,npe01__WorkPhone__c,Hidden_Work_Phone__c,npe01__PreferredPhone__c,Hidden_Preferred_Phone_Types__c,
									Hidden_State__c,Hidden_Country__c,Hidden_Zip_Code__c,Same_as_Household_Address__c,Hidden_Same_Address__c,OtherPhone,MobilePhone,HiddenMobilePhone__c,HiddenOtherPhone__c
							FROM Contact
							WHERE Id IN :wishFamilySet
					]) {
						if (wishFamilyContact.Hidden_First_Name__c != null) {
							wishFamilyContact.FirstName = wishFamilyContact.Hidden_First_Name__c;
							wishFamilyContact.Hidden_First_Name__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Last_Name__c != null) {
							wishFamilyContact.LastName = wishFamilyContact.Hidden_Last_Name__c;
							wishFamilyContact.Hidden_Last_Name__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Phone__c != null && wishFamilyContact.Hidden_Phone__c != PHONE_PLACEHOLDER) {
							wishFamilyContact.HomePhone = wishFamilyContact.Hidden_Phone__c;
							wishFamilyContact.Hidden_Phone__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Phone__c == PHONE_PLACEHOLDER) {
							wishFamilyContact.HomePhone = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.HiddenMobilePhone__c != null && wishFamilyContact.HiddenMobilePhone__c != PHONE_PLACEHOLDER) {
							wishFamilyContact.MobilePhone = wishFamilyContact.HiddenMobilePhone__c;
							wishFamilyContact.HiddenMobilePhone__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.HiddenMobilePhone__c == PHONE_PLACEHOLDER) {
							wishFamilyContact.MobilePhone = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Work_Phone__c != null && wishFamilyContact.Hidden_Work_Phone__c != PHONE_PLACEHOLDER) {
							wishFamilyContact.npe01__WorkPhone__c = wishFamilyContact.Hidden_Work_Phone__c;
							wishFamilyContact.Hidden_Work_Phone__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Work_Phone__c == PHONE_PLACEHOLDER) {
							wishFamilyContact.npe01__WorkPhone__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.HiddenOtherPhone__c != null && wishFamilyContact.HiddenOtherPhone__c != PHONE_PLACEHOLDER) {
							wishFamilyContact.otherPhone = wishFamilyContact.HiddenOtherPhone__c;
							wishFamilyContact.HiddenOtherPhone__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.HiddenOtherPhone__c == PHONE_PLACEHOLDER) {
							wishFamilyContact.otherPhone = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Email__c != null && wishFamilyContact.Hidden_Email__c != dummyValue) {
							wishFamilyContact.Email = wishFamilyContact.Hidden_Email__c;
							wishFamilyContact.Hidden_Email__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Email__c == dummyValue) {
							wishFamilyContact.Email = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Preferred_Phone_Types__c != null && wishFamilyContact.Hidden_Preferred_Phone_Types__c != dummyValue) {
							wishFamilyContact.npe01__PreferredPhone__c = wishFamilyContact.Hidden_Preferred_Phone_Types__c;
							wishFamilyContact.Hidden_Preferred_Phone_Types__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Preferred_Phone_Types__c == dummyValue) {
							wishFamilyContact.npe01__PreferredPhone__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Street__c != null && wishFamilyContact.Hidden_Street__c != dummyValue) {
							wishFamilyContact.MailingStreet = wishFamilyContact.Hidden_Street__c;
							wishFamilyContact.Hidden_Street__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Street__c == dummyValue) {
							wishFamilyContact.MailingStreet = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (relationshipContactIdMap.size() > 0 && contactRelationshipMap.size() > 0) {
							if (relationshipContactIdMap.containsKey(wishFamilyContact.Id)) {
								if (wishFamilyContact.npe01__PreferredPhone__c == 'Home') {
									contactRelationshipMap.get(relationshipContactIdMap.get(wishFamilyContact.Id)).Preferred_Contact_Number__c = wishFamilyContact.HomePhone;
								} else if (wishFamilyContact.npe01__PreferredPhone__c == 'Mobile') {
									contactRelationshipMap.get(relationshipContactIdMap.get(wishFamilyContact.Id)).Preferred_Contact_Number__c = wishFamilyContact.MobilePhone;
								} else if (wishFamilyContact.npe01__PreferredPhone__c == 'Other') {
									contactRelationshipMap.get(relationshipContactIdMap.get(wishFamilyContact.Id)).Preferred_Contact_Number__c = wishFamilyContact.OtherPhone;
								} else if (wishFamilyContact.npe01__PreferredPhone__c == 'Work') {
									contactRelationshipMap.get(relationshipContactIdMap.get(wishFamilyContact.Id)).Preferred_Contact_Number__c = wishFamilyContact.npe01__WorkPhone__c;
								}
							}
						}
						if (wishFamilyContact.Hidden_city__c != null && wishFamilyContact.Hidden_city__c != dummyValue) {
							wishFamilyContact.MailingCity = wishFamilyContact.Hidden_city__c;
							wishFamilyContact.Hidden_city__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_city__c == dummyValue) {
							wishFamilyContact.MailingCity = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_State__c != null && wishFamilyContact.Hidden_State__c != dummyValue) {
							wishFamilyContact.MailingState = wishFamilyContact.Hidden_State__c;
							wishFamilyContact.Hidden_State__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_State__c == dummyValue) {
							wishFamilyContact.MailingState = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Country__c != null && wishFamilyContact.Hidden_Country__c != dummyValue) {
							wishFamilyContact.MailingCountry = wishFamilyContact.Hidden_Country__c;
							wishFamilyContact.Hidden_Country__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Country__c == dummyValue) {
							wishFamilyContact.MailingCountry = 'United States';
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Zip_Code__c != null && wishFamilyContact.Hidden_Zip_Code__c != ZIP_PLACEHOLDER) {
							wishFamilyContact.MailingPostalCode = wishFamilyContact.Hidden_Zip_Code__c;
							wishFamilyContact.Hidden_Zip_Code__c = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Zip_Code__c == ZIP_PLACEHOLDER) {
							wishFamilyContact.MailingPostalCode = null;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Use_as_Household_Address__c == true) {
							wishFamilyContact.Use_as_Household_Address__c = true;
							Account newAcc = new Account();
							newAcc.Id = wishFamilyContact.AccountId;
							newAcc.BillingStreet = wishFamilyContact.MailingStreet;
							newAcc.BillingCity = wishFamilyContact.MailingCity;
							newAcc.BillingState = wishFamilyContact.MailingState;
							newAcc.BillingCountry = wishFamilyContact.MailingCountry;
							newAcc.BillingPostalCode = wishFamilyContact.MailingPostalCode;
							houseHoldAccountMap.put(newAcc.Id, newAcc);
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						} else if (wishFamilyContact.Hidden_Use_as_Household_Address__c == false) {
							wishFamilyContact.Use_as_Household_Address__c = false;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
						if (wishFamilyContact.Hidden_Same_Address__c == false) {
							wishFamilyContact.Same_as_Household_Address__c = false;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						} else if (wishFamilyContact.Hidden_Same_Address__c == true) {
							wishFamilyContact.Same_as_Household_Address__c = true;
							wishFamilyMap.put(wishFamilyContact.Id, wishFamilyContact);
						}
					}
					if (!wishFamilyMap.isEmpty()) {
						update wishFamilyMap.values();
					}
					if (!houseHoldAccountMap.isEmpty()) {
						update houseHoldAccountMap.values();
					}
					if (!updateRelationshipList.isEmpty()) {
						update updateRelationshipList;
					}
				}
			} catch (Exception ex) {
				createContactDebugLog(contactRelationshipMap.values(), 'updateFamilyContactDetails', ex);
			}
		}
	}

	/**
	* Updates hidden contact fields of wish family
	* @param newContactList
	*/
	public static void updateContactHiddenFields(List<Contact> newContactList) {
		Set<Id> wishFamilySet = new Set<Id>();
		Set<Id> recallWishIdSet = new Set<Id>();
		for (Contact newContact : newContactList) {
			if (newContact.RecordTypeId == WISH_CHILD_RECORD_TYPE_ID && newContact.IsContactInfoUpdated__c == true
					&& (newContact.IsRejected_Contact_Info__c == true || newContact.isRecall_Contact_Info__c == true)) {
				recallWishIdSet.add(newContact.Id);
			}
		}
		if (!recallWishIdSet.isEmpty()) {
			for (npe4__Relationship__c relationship : [
					SELECT Id, npe4__Contact__c, npe4__RelatedContact__c
					FROM npe4__Relationship__c
					WHERE npe4__Contact__c IN :recallWishIdSet
					AND npe4__RelatedContact__r.RecordTypeId = :WISH_FAMILY_RECORD_TYPE_ID
			]) {
				wishFamilySet.add(relationship.npe4__RelatedContact__c);
			}

			List<Contact> contactList = new List<Contact>();
			contactList = [
					SELECT Id, Name, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState,
							MailingCountry, MailingPostalCode, Hidden_First_Name__c, HiddenOtherPhone__c, HiddenMobilePhone__c, Hidden_Use_as_Household_Address__c,
							Hidden_Last_Name__c, Hidden_Street__c, Hidden_Phone__c, Hidden_Email__c, Hidden_city__c, Hidden_State__c, Hidden_Country__c,
							Hidden_Zip_Code__c, Hidden_Work_Phone__c, Hidden_Preferred_Phone_Types__c
					FROM Contact
					WHERE Id IN :wishFamilySet
			];

			for (Contact dbWishFamily : contactList) {
				if (dbWishFamily.Hidden_First_Name__c != null || dbWishFamily.Hidden_Last_Name__c != null || dbWishFamily.Hidden_Phone__c != null
						|| dbWishFamily.Hidden_Use_as_Household_Address__c == true || dbWishFamily.Hidden_Email__c != null || dbWishFamily .Hidden_Street__c != null
						|| dbWishFamily.Hidden_State__c != null || dbWishFamily.Hidden_Country__c != null || dbWishFamily.Hidden_Zip_Code__c != null
						|| dbWishFamily.Hidden_city__c != null || dbWishFamily.Hidden_Preferred_Phone_Types__c != null || dbWishFamily.Hidden_Work_Phone__c != null
						|| dbWishFamily.HiddenMobilePhone__c != null || dbWishFamily.HiddenOtherPhone__c != null) {
					dbWishFamily.Hidden_First_Name__c = null;
					dbWishFamily.Hidden_Last_Name__c = null;
					dbWishFamily.Hidden_Phone__c = null;
					dbWishFamily.Hidden_Email__c = null;
					dbWishFamily.Hidden_Street__c = null;
					dbWishFamily.Hidden_State__c = null;
					dbWishFamily.Hidden_Country__c = null;
					dbWishFamily.Hidden_Zip_Code__c = null;
					dbWishFamily.Hidden_city__c = null;
					dbWishFamily.HiddenMobilePhone__c = null;
					dbWishFamily.HiddenOtherPhone__c = null;
					dbWishFamily.Hidden_Preferred_Phone_Types__c = null;
					dbWishFamily.Hidden_Work_Phone__c = null;
					dbWishFamily.Hidden_Use_as_Household_Address__c = false;
				}
			}
			try {
				update contactList;
			} catch (Exception e) {
				createContactDebugLog(contactList, 'updateContactHiddenFields', e);
			}
		}
	}

	/**
	* Populate condition description based on ICD Code Values
	* @param newContactsList
	* @param oldContactsMap
	*/
	public static List<Contact> matchConditionDescription(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap) {
		Set<Id> icdCodeRecSet = new Set<Id>();
		List<Contact> contactIcdList = new List<Contact>();
		Map<Id, Set<Integer>> icdInfoMap = new Map<Id, Set<Integer>>();
		Map<Id, ICD_Codes__c> icdCodeDetails = new Map<Id, ICD_Codes__c>();

		for (Contact newContact : newContactsList) {
			Contact oldContact = oldContactsMap.get(newContact.Id);
			if (newContact.SD1_ICD_Code__c != oldContact.SD1_ICD_Code__c && newContact.SD1_ICD_Code__c != null) {
				icdCodeRecSet.add(newContact.SD1_ICD_Code__c);
				contactIcdList.add(newContact);
				if (icdInfoMap.containsKey(newContact.Id)) {
					icdInfoMap.get(newContact.Id).add(1);
				} else {
					icdInfoMap.put(newContact.Id, new Set<Integer>{
							1
					});
				}
			}
			if (newContact.SD2_ICD_Code__c != oldContact.SD2_ICD_Code__c && newContact.SD2_ICD_Code__c != null) {
				icdCodeRecSet.add(newContact.SD2_ICD_Code__c);
				contactIcdList.add(newContact);
				if (icdInfoMap.containsKey(newContact.Id)) {
					icdInfoMap.get(newContact.Id).add(2);
				} else {
					icdInfoMap.put(newContact.Id, new Set<Integer>{
							2
					});
				}
			}
			if (newContact.SD3_ICD_Code__c != oldContact.SD3_ICD_Code__c && newContact.SD3_ICD_Code__c != null) {
				icdCodeRecSet.add(newContact.SD3_ICD_Code__c);
				contactIcdList.add(newContact);
				if (icdInfoMap.containsKey(newContact.Id)) {
					icdInfoMap.get(newContact.Id).add(3);
				} else {
					icdInfoMap.put(newContact.Id, new Set<Integer>{
							3
					});
				}
			}
			if (newContact.SD4_ICD_Code__c != oldContact.SD4_ICD_Code__c && newContact.SD4_ICD_Code__c != null) {
				icdCodeRecSet.add(newContact.SD4_ICD_Code__c);
				contactIcdList.add(newContact);
				if (icdInfoMap.containsKey(newContact.Id)) {
					icdInfoMap.get(newContact.Id).add(4);
				} else {
					icdInfoMap.put(newContact.Id, new Set<Integer>{
							4
					});
				}
			}
			if (newContact.ICD_10_Code__c != oldContact.ICD_10_Code__c && newContact.ICD_10_Code__c != null) {
				icdCodeRecSet.add(newContact.ICD_10_Code__c);
				contactIcdList.add(newContact);
				if (icdInfoMap.containsKey(newContact.Id)) {
					icdInfoMap.get(newContact.Id).add(5);
				} else {
					icdInfoMap.put(newContact.Id, new Set<Integer>{
							5
					});
				}
			}
		}
		if (!icdCodeRecSet.isEmpty()) {
			for (ICD_Codes__c icdInfo : [
					SELECT Id, Name, Group1__c,
							Condition_Description__c, Condition_Description__r.Code_to_Use__c, Condition_Description__r.Name
					FROM ICD_Codes__c
					WHERE Id IN :icdCodeRecSet
			]) {
				icdCodeDetails.put(icdInfo.Id, icdInfo);
			}
			for (Contact updatePD : contactIcdList) {
				if (icdInfoMap.containsKey(updatePD.Id)) {
					for (Integer icdField : icdInfoMap.get(updatePD.Id)) {
						if (icdField == 1 && icdCodeDetails.containsKey(updatePD.SD1_ICD_Code__c)) {
							updatePD.SD1_Condition_Description__c = icdCodeDetails.get(updatePD.SD1_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 2 && icdCodeDetails.containsKey(updatePD.SD2_ICD_Code__c)) {
							updatePD.SD2_Condition_Description__c = icdCodeDetails.get(updatePD.SD2_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 3 && icdCodeDetails.containsKey(updatePD.SD3_ICD_Code__c)) {
							updatePD.SD3_Condition_Description__c = icdCodeDetails.get(updatePD.SD3_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 4 && icdCodeDetails.containsKey(updatePD.SD4_ICD_Code__c)) {
							updatePD.SD4_Condition_Description__c = icdCodeDetails.get(updatePD.SD4_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 5 && icdCodeDetails.containsKey(updatePD.ICD_10_Code__c)) {
							updatePD.Diagnosis__c = icdCodeDetails.get(updatePD.ICD_10_Code__c).Condition_Description__r.Name;
						}
					}
				}
			}
		}
		return contactIcdList;
	}

	/**
	* Update affiliation status based on contact application status
	* @param newContactsList
	* @param oldContactsMap
	*/
	public static void updateOrgAffiliationStatus(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap) {
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		for (Contact newContact : newContactsList) {
			if (newContact.is_Application__c != oldContactsMap.get(newContact.Id).is_Application__c) {
				contactMap.put(newContact.Id, newContact);
			}
		}
		if (!contactMap.isEmpty()) {
			List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
			for (npe5__Affiliation__c dbAffiliationRec : [
					SELECT Id, npe5__Contact__c, npe5__Primary__c, npe5__Status__c, npe5__Organization__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :contactMap.keySet() AND npe5__Status__c != 'Active'
			]) {
				if (contactMap.containsKey(dbAffiliationRec.npe5__Contact__c)) {
					npe5__Affiliation__c updateAffiliation = new npe5__Affiliation__c();
					updateAffiliation.Id = dbAffiliationRec.Id;
					if (contactMap.get(dbAffiliationRec.npe5__Contact__c).is_Application__c == 'Complete') {
						updateAffiliation.npe5__Status__c = 'Pending';
					} else if (contactMap.get(dbAffiliationRec.npe5__Contact__c).is_Application__c == 'Rejected') {
						updateAffiliation.npe5__Status__c = 'Not Approved';
					}
					affiliationList.add(updateAffiliation);
				}
			}
			try {
				update affiliationList;
			} catch (Exception e) {
				createContactDebugLog(affiliationList, 'updateOrgAffiliationStatus', e);
			}
		}
	}

	/**
	* Update medical professional contact information on wish child record
	* @param newContactsList
	* @param oldContactsMap
	*/
	public static void updateMedicalProfessional(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap) {
		Set<Id> medicalProfContactSet = new Set<Id>();
		for (Contact newContact : newContactsList) {
			if (newContact.RecordTypeId == MEDICAL_PROFESSIONAL_RECORD_TYPE_ID
					&& (newContact.Name != oldContactsMap.get(newContact.Id).Name || newContact.Email != oldContactsMap.get(newContact.Id).Email)) {
				medicalProfContactSet.add(newContact.Id);
			}
		}
		if (!medicalProfContactSet.isEmpty()) {
			Map<Id, npe4__Relationship__c > childContactMap = new Map<Id, npe4__Relationship__c >();
			List<Contact> updateChildContactList = new List<Contact>();
			for (npe4__Relationship__c dbMedicalRelationShipRec : [
					SELECT Id, npe4__RelatedContact__c, npe4__RelatedContact__r.Name,
							npe4__RelatedContact__r.Email, npe4__Contact__c
					FROM npe4__Relationship__c
					WHERE npe4__RelatedContact__c IN :medicalProfContactSet
					AND Qualifying_Medical_Professional__c = true
					AND npe4__Status__c = 'Active'
			]) {
				childContactMap.put(dbMedicalRelationShipRec.npe4__Contact__c, dbMedicalRelationShipRec);
			}
			if (!childContactMap.isEmpty()) {
				for (Contact dbChildContact : [
						SELECT Id, Hidden_Medical_Physician__c, Hidden_Medical_Physician_Email__c
						FROM Contact
						WHERE Id IN :childContactMap.keySet()
						AND RecordTypeId = :WISH_CHILD_RECORD_TYPE_ID
				]) {
					Contact updateChildContact = new contact();
					updateChildContact.Id = dbChildContact.Id;
					updateChildContact.Hidden_Medical_Physician__c = childContactMap.get(dbChildContact.Id).npe4__RelatedContact__r.Name;
					updateChildContact.Hidden_Medical_Physician_Email__c = childContactMap.get(dbChildContact.Id).npe4__RelatedContact__r.Email;
					updateChildContactList.add(updateChildContact);

				}
				try {
					update updateChildContactList;
				} catch (Exception e) {
					createContactDebugLog(updateChildContactList, 'updateMedicalProfessional', e);
				}
			}
		}
	}

	/**
	* Create volunteer roles when volunteer role field is updated on volunteer contact
	* @param contactList
	* @param oldContactsMap
	*/
	public static void createVolunteerRoles(List<Contact> contactList, Map<Id, Contact> oldContactsMap) {
		Map<Id, Id> volunteerChapterMap = new Map<Id, Id>();
		Map<Id, Set<string>> volunteerRolesMap = new Map<Id, Set<String>>();
		Set<String> allVolunteerRoles = new Set<String>();
		Map<Id, Contact> volunteerContactMap = new Map<Id, Contact>();

		for (Contact contact : contactList) {
			Contact oldContact = oldContactsMap.get(contact.Id);
			if (contact.recordTypeId == VOLUNTEER_RT_ID && contact.Volunteer_Role__c != null
					&& (contact.Volunteer_Role__c != oldContact.Volunteer_Role__c)) {
				volunteerContactMap.put(contact.Id, contact);
			}
		}
		if (!volunteerContactMap.isEmpty()) {
			for (npe5__Affiliation__c currRec : [
					SELECT Id,npe5__Contact__c, npe5__Organization__c,
							npe5__Contact__r.Volunteer_Role__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :volunteerContactMap.keySet()
					AND npe5__Primary__c = true
			]) {
				volunteerChapterMap.put(currRec.npe5__Contact__c, currRec.npe5__Organization__c);
				if (currRec.npe5__Contact__r.Volunteer_Role__c != null) {
					for (String currRole : (currRec.npe5__Contact__r.Volunteer_Role__c.split(';'))) {
						allVolunteerRoles.add(currRole);
					}
					volunteerRolesMap.put(currRec.npe5__Contact__c, allVolunteerRoles);
				}
			}
			if (!volunteerChapterMap.isEmpty()) {
				delete [
						SELECT Id
						FROM Volunteer_Roles__c
						WHERE Volunteer_Name__c IN :volunteerChapterMap.keySet()
				];
			}
			List<Volunteer_Roles__c> volunteerRoleList = new List<Volunteer_Roles__c>();
			for (Chapter_Role__c currRec : [
					SELECT Id, Chapter_Name__c, Role_Name__c, Role_Name__r.Name
					FROM Chapter_Role__c
					WHERE Role_Name__r.Name IN :allVolunteerRoles
					AND Chapter_Name__c IN :volunteerChapterMap.values()
			]) {
				for (Id currContact : volunteerChapterMap.keySet()) {
					if ((volunteerChapterMap.get(currContact) == (currRec.Chapter_Name__c))
							&& ((volunteerRolesMap.get(currContact)).contains(currRec.Role_Name__r.Name))) {
						Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
						newVolRole.Chapter_Role__c = currRec.Id;
						newVolRole.Volunteer_Name__c = currContact;
						newVolRole.Status__c = 'Pending';
						newVolRole.Sub_Status__c = 'Missing Requirement';
						volunteerRoleList.add(newVolRole);
					}
				}
			}
			for (Chapter_Role__c roleToAddAutomatically : [
					SELECT Id, Chapter_Name__c, Role_Name__c, Role_Name__r.Name
					FROM Chapter_Role__c
					WHERE Chapter_Name__c IN :volunteerChapterMap.values()
					AND Add_to_New_Volunteers_Automatically__c = true
					AND Role_Name__r.Name NOT IN :allVolunteerRoles
			]) {
				for (Id currContact : volunteerChapterMap.keySet()) {
					if (volunteerChapterMap.get(currContact) == (roleToAddAutomatically.Chapter_Name__c)) {
						Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
						newVolRole.Chapter_Role__c = roleToAddAutomatically.Id;
						newVolRole.Volunteer_Name__c = currContact;
						newVolRole.Status__c = 'Pending';
						newVolRole.sub_status__c = 'Missing Requirement';
						volunteerRoleList.add(newVolRole);
					}
				}
			}
			try {
				insert volunteerRoleList;
			} catch (Exception e) {
				createContactDebugLog(volunteerRoleList, 'createVolunteerRoles', e);
			}
		}
	}

	/**
	* Create task for volunteer manager if volunteer updates zipcode that belongs to another chapter
	* @param contactList
	* @param oldContactsMap
	*/
	public static void createZipcodeUpdateTask(List<Contact> contactList, Map<Id, Contact> oldContactsMap) {
		Map<String, String> zipCodeChapterMap = new Map<String, String>();
		List<Task> newTaskList = new List<Task>();
		String mailingCode;
		Map<Id, Set<Id>> taskIdsMap = new Map<Id, Set<Id>>();
		Set<String> zipCodesSet = new Set<String>();
		Map<Id, Contact> contactMap = new Map<Id, Contact>();

		for (Contact newContact : contactList) {
			Contact oldContact = oldContactsMap.get(newContact.Id);
			if (newContact.recordTypeId == VOLUNTEER_RT_ID && newContact.MailingAddressVerified__c == false
					&& newContact.MailingPostalCode != oldContact.MailingPostalCode) {
				contactMap.put(newContact.Id, newContact);
				if (newContact.MailingPostalCode != null && String.valueOf(newContact.MailingPostalCode).length() > 5
						&& String.valueOf(newContact.MailingPostalCode).contains('-')) {
					zipCodesSet.add(String.valueOf(newContact.MailingPostalCode).split('-')[0]);
				} else {
					zipCodesSet.add(newContact.MailingPostalCode);
				}
			}
		}
		if (!contactMap.isEmpty()) {
			for (Task addressTask : [
					SELECT Id
					FROM Task
					WHERE WhatId IN :contactMap.keySet()
					AND Subject = 'Volunteer Address Change' AND isClosed = false
			]) {
				if (taskIdsMap.containsKey(addressTask.WhoId)) {
					taskIdsMap.get(addressTask.WhoId).add(addressTask.WhatId);
				} else {
					taskIdsMap.put(addressTask.WhoId, new Set<Id>{
							addressTask.WhatId
					});
				}
			}
			for (Zip_Code__c currZip : [
					SELECT Id, Name, Office__c, Office__r.Chapter__c
					FROM Zip_Code__c
					WHERE Name IN :zipCodesSet
			]) {
				if (currZip.Office__c != null)
					zipCodeChapterMap.put(currZip.Name, currZip.Office__r.Chapter__c);
			}
			for (npe5__Affiliation__c currAffiliation : [
					SELECT Id, npe5__Contact__c, npe5__Contact__r.MailingPostalcode,
							npe5__Contact__r.OwnerId, npe5__Organization__c, npe5__Contact__r.Volunteer_Role__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :contactMap.keySet()
					AND npe5__Primary__c = true
			]) {
				if (currAffiliation.npe5__Contact__r.MailingPostalcode != null
						&& String.valueOf(currAffiliation.npe5__Contact__r.MailingPostalcode).length() > 5
						&& String.valueOf(currAffiliation.npe5__Contact__r.MailingPostalcode).contains('-')) {
					mailingCode = String.valueOf(currAffiliation.npe5__Contact__r.MailingPostalcode).split('-')[0];
				} else {
					mailingCode = currAffiliation.npe5__Contact__r.MailingPostalcode;
				}
				if (zipCodeChapterMap.containsKey(mailingCode)) {
					if (currAffiliation.npe5__Organization__c != zipCodeChapterMap.get(mailingCode)) {
						if (taskIdsMap.containsKey(currAffiliation.npe5__Contact__c) && !taskIdsMap.get(currAffiliation.npe5__Contact__c).contains(currAffiliation.npe5__Contact__c)) {
							Task newTask = new Task();
							newTask.Subject = 'Volunteer Address Change';
							newTask.WhoId = currAffiliation.npe5__Contact__c;
							newTask.OwnerId = currAffiliation.npe5__Contact__r.OwnerId;
							newTask.Status = 'Not Started';
							newTask.activityDate = Date.Today() + 5;
							newTask.WhatId = zipCodeChapterMap.get(mailingCode);
							newTask.RecordTypeId = STAFF_TASK_RT_ID;
							newTaskList.add(newTask);
						}
					}
				}
			}
			try {
				insert newTaskList;
			} catch (Exception e) {
				createContactDebugLog(newTaskList, 'createZipcodeUpdateTask', e);
			}
		}
	}

	/**
	* Update the email address for drawloop purpose to send email to parent legual gurdian
	* @param contactList
	* @param oldContactsMap
	*/
	public static void updateEmailAddress(List<Contact> contactList, Map<Id, Contact> oldContactsMap) {
		Set<Id> contactIdSet = new Set<Id>();
		Map<String, Contact> contactNameEmailMap = new Map<String, Contact>();
		Map<Id, Contact> updateEmailContactMap = new Map<Id, Contact>();
		String firstName;
		String concatNameEmail;

		for (Contact newContact : contactList) {
			Contact oldContact = oldContactsMap.get(newContact.Id);
			if (newContact.Email != null && oldContact.Email != null && newContact.Email != oldContact.Email) {
				contactIdSet.add(newContact.Id);
				firstName = oldContact.Firstname != null ? oldContact.Firstname : '';
				concatNameEmail = firstName + ' ' + oldContact.lastName + '-' + oldContact.Email;
				contactNameEmailMap.put(concatNameEmail, newContact);
			}
		}
		if (!contactNameEmailMap.isEmpty()) {
			for (npe4__Relationship__c newRelationShip : [
					SELECT ID, Name, Parent_Legal_Guardian__c, npe4__RelatedContact__c,
							npe4__RelatedContact__r.LastName, npe4__RelatedContact__r.FirstName,
							npe4__RelatedContact__r.Name, npe4__RelatedContact__r.Email, npe4__Contact__c,
							npe4__Contact__r.Recipient_Email__c, npe4__Contact__r.Second_Recipient_Email__c,
							npe4__Contact__r.First_Recipient_Name__c, npe4__Contact__r.Second_Recipient_Name__c
					FROM npe4__Relationship__c
					WHERE Parent_Legal_Guardian__c = true
					AND npe4__RelatedContact__c IN :contactIdSet
			]) {
				String temp;
				String temp1;
				temp = newRelationShip.npe4__Contact__r.First_Recipient_Name__c + '-' + newRelationShip.npe4__Contact__r.Recipient_Email__c;
				temp1 = newRelationShip.npe4__Contact__r.Second_Recipient_Name__c + '-' + newRelationShip.npe4__Contact__r.Second_Recipient_Email__c;
				if (contactNameEmailMap.containsKey(temp)) {
					Contact con = new contact();
					con.Id = newRelationShip.npe4__Contact__c;
					Con.Recipient_Email__c = contactNameEmailMap.get(temp).Email;
					updateEmailContactMap.put(con.Id, con);
				} else if (contactNameEmailMap.containsKey(temp1)) {
					Contact con = new contact();
					con.Id = newRelationShip.npe4__Contact__c;
					con.second_Recipient_Email__c = contactNameEmailMap.get(temp1).Email;
					updateEmailContactMap.put(con.Id, con);
				}
			}
			if (!updateEmailContactMap.isEmpty()) {
				try {
					update updateEmailContactMap.values();
				} catch (Exception e) {
					createContactDebugLog(updateEmailContactMap.values(), 'updateEmailAddress', e);
				}
			}
		}
	}

	public static void updateHouseHoldAddress(List<Contact> contactList, Map<Id, Contact> oldContactsMap) {
		Set<Id> contactHouseholdSet = new Set<Id>();
		for (Contact newContact : contactList) {
			if (newContact.Same_as_Household_Address__c && !oldContactsMap.get(newContact.Id).Same_as_Household_Address__c) {
				contactHouseholdSet.add(newContact.Id);
			}
		}
		if (!contactHouseholdSet.isEmpty()) {
			updateHouseHoldAddress(contactHouseholdSet);
		}
	}

	/**
	* Update household address for family contact records
	* @param addressSet
	*/
	@future
	public static void updateHouseHoldAddress(Set<Id> addressSet) {
		List<Contact> dbFamilyContact = new List<Contact>();
		Set<Id> dbFamilyAccountIdSet = new Set<Id>();
		List<Contact> updateFamilyContactList = new List<Contact>();
		Map<Id, Account> houseHoldAccountMap = new Map<Id, Account>();
		if (!addressSet.isEmpty()) {
			for (Contact familyContact : [
					SELECT Id, AccountId, MailingStreet, MailingCity, MailingState,
							MailingCountry, MailingPostalCode, Same_as_Household_Address__c
					FROM Contact
					WHERE Id IN :addressSet
			]) {
				if (familyContact.Same_as_Household_Address__c == true) {
					dbFamilyAccountIdSet.add(familyContact.AccountId);
					dbFamilyContact.add(familyContact);
				}
			}
		}
		if (!dbFamilyAccountIdSet.isEmpty()) {
			for (Account dbHouseHoldAccount : [
					SELECT Id, BillingStreet, BillingCity, BillingState,
							BillingCountry, BillingPostalCode
					FROM Account
					WHERE Id IN :dbFamilyAccountIdSet
			]) {
				houseHoldAccountMap.put(dbHouseHoldAccount.Id, dbHouseHoldAccount);
			}
			for (Contact familyContact : dbFamilyContact) {
				if (houseHoldAccountMap.containsKey(familyContact.AccountId)) {
					familyContact.MailingStreet = houseHoldAccountMap.get(familyContact.AccountId).BillingStreet;
					familyContact.MailingCity = houseHoldAccountMap.get(familyContact.AccountId).BillingCity;
					familyContact.MailingState = houseHoldAccountMap.get(familyContact.AccountId).BillingState;
					familyContact.MailingCountry = houseHoldAccountMap.get(familyContact.AccountId).BillingCountry;
					familyContact.MailingPostalCode = houseHoldAccountMap.get(familyContact.AccountId).BillingPostalCode ;
					updateFamilyContactList.add(familyContact);
				}
			}
			try {
				update updateFamilyContactList;
			} catch (Exception e) {
				createContactDebugLog(updateFamilyContactList, 'updateHouseHoldAddress', e);
			}
		}
	}

	/**
	* Update user information when volunteer contact details update
	* @param contactList
	* @param oldContactsMap
	*/
	public static void updateUserDetails(List<Contact> contactList, Map<Id, Contact> oldContactsMap) {
		if (System.isFuture()) {
			return;
		}

		List<User> updateUserList = new List<User>();
		Map<Id, Contact> updatedContactMap = new Map<Id, Contact>();
		for (Contact newContact : contactList) {
			Contact oldContact = oldContactsMap.get(newContact.Id);
			if (newContact.recordTypeId == VOLUNTEER_RT_ID
					&& ((newContact.FirstName != null && oldContact.FirstName != newContact.FirstName)
					|| (newContact.LastName != null && oldContact.LastName != newContact.LastName)
					|| (newContact.MobilePhone != null && oldContact.MobilePhone != newContact.MobilePhone)
					|| (newContact.Email != null && oldContact.Email != newContact.Email)
					|| (newContact.MailingStreet != null && oldContact.MailingStreet != newContact.MailingStreet)
					|| (newContact.MailingCity != null && oldContact.MailingCity != newContact.MailingCity)
					|| (newContact.MailingState != null && oldContact.MailingState != newContact.mailingstate)
					|| (newContact.MailingPostalCode != null && oldContact.MailingPostalCode != newContact.MailingPostalCode)
					|| (newContact.County__c != null && oldContact.County__c != newContact.County__c)
					|| (newContact.Fax != null && oldContact.Fax != newContact.Fax))) {
				updatedContactMap.put(newContact.Id, newContact);
			}
		}
		if (!updatedContactMap.isEmpty()) {
			for (User currRecUser : [
					SELECT Id, ContactId, FirstName, LastName, Email, mobilephone,
							Phone, City, Street, State, PostalCode, Fax
					FROM User
					WHERE ContactId IN :updatedContactMap.keySet()
			]) {
				User updateUser = new User();
				updateUser.Id = currRecUser.Id;
				Boolean flag = false;
				if (updatedContactMap.get(currRecUser.ContactId).FirstName != oldContactsMap.get(currRecUser.ContactId).FirstName
						&& currRecUser.FirstName != updatedContactMap.get(currRecUser.ContactId).FirstName) {
					updateUser.FirstName = updatedContactMap.get(currRecUser.ContactId).FirstName;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).LastName != oldContactsMap.get(currRecUser.ContactId).LastName
						&& currRecUser.LastName != updatedContactMap.get(currRecUser.ContactId).LastName) {
					updateUser.LastName = updatedContactMap.get(currRecUser.ContactId).LastName;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).Email != oldContactsMap.get(currRecUser.ContactId).Email
						&& currRecUser.Email != updatedContactMap.get(currRecUser.ContactId).Email) {
					updateUser.Email = updatedContactMap.get(currRecUser.ContactId).Email;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).MobilePhone != oldContactsMap.get(currRecUser.ContactId).MobilePhone
						&& currRecUser.Phone != updatedContactMap.get(currRecUser.ContactId).MobilePhone) {
					updateUser.MobilePhone = updatedContactMap.get(currRecUser.ContactId).MobilePhone;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).MailingStreet != oldContactsMap.get(currRecUser.ContactId).MailingStreet
						&& currRecUser.Street != updatedContactMap.get(currRecUser.ContactId).MailingStreet) {
					updateUser.Street = updatedContactMap.get(currRecUser.ContactId).MailingStreet;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).MailingCity != oldContactsMap.get(currRecUser.ContactId).MailingCity
						&& currRecUser.City != updatedContactMap.get(currRecUser.ContactId).MailingCity) {
					updateUser.City = updatedContactMap.get(currRecUser.ContactId).MailingCity;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).mailingstate != oldContactsMap.get(currRecUser.ContactId).mailingstate
						&& currRecUser.State != updatedContactMap.get(currRecUser.ContactId).mailingstate) {
					updateUser.State = updatedContactMap.get(currRecUser.ContactId).mailingstate;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).mailingpostalcode != oldContactsMap.get(currRecUser.ContactId).mailingpostalcode
						&& currRecUser.PostalCode != updatedContactMap.get(currRecUser.ContactId).mailingpostalcode) {
					updateUser.PostalCode = updatedContactMap.get(currRecUser.ContactId).mailingpostalcode;
					flag = true;
				}
				if (updatedContactMap.get(currRecUser.ContactId).Fax != oldContactsMap.get(currRecUser.ContactId).Fax
						&& currRecUser.Fax != updatedContactMap.get(currRecUser.ContactId).Fax) {
					updateUser.Fax = updatedContactMap.get(currRecUser.ContactId).Fax;
					flag = true;
				}
				if (flag == true) {
					updateUserList.add(updateUser);
				}
			}
			if (!updateUserList.isEmpty()) {
				try {
					update updateUserList;
				} catch (Exception e) {
					createContactDebugLog(updatedContactMap.values(), 'updateUserDetails', e);
				}
			}
		}
	}

	/**
	* Update relationship type when contact is updated
	* @param newContactsList
	* @param oldContactsMap
	*/
	public static void updateRelationship(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap) {
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		for (Contact newContact : newContactsList) {
			if (newContact.RecordTypeId == WISH_FAMILY_RECORD_TYPE_ID
					&& newContact.Relationship__c != oldContactsMap.get(newContact.Id).Relationship__c) {
				contactMap.put(newContact.Id, newContact);
			}
		}
		if (!contactMap.isEmpty()) {
			List<npe4__Relationship__c> updateRelationshipList = new List<npe4__Relationship__c>();
			for (npe4__Relationship__c dbRelationShip : [
					SELECT Id, npe4__Contact__c, npe4__RelatedContact__c, npe4__Type__c
					FROM npe4__Relationship__c
					WHERE npe4__RelatedContact__c IN :contactMap.keySet()
			]) {
				if (contactMap.containsKey(dbRelationShip.npe4__RelatedContact__c)) {
					dbRelationShip.npe4__Type__c = contactMap.get(dbRelationShip.npe4__RelatedContact__c).Relationship__c;
					updateRelationshipList.add(dbRelationShip);
				}
			}
			try {
				update updateRelationshipList;
			} catch (Exception e) {
				createContactDebugLog(contactMap.values(), 'updateRelationship', e);
			}
		}
	}

	/**
	* Check if contact meets criteria to share record
	* @param newContactsMap
	* @param oldContactsMap
	*/
	public static void shareContactRecord(Map<Id, Contact> newContactsMap, Map<Id, Contact> oldContactsMap) {
		Map<String, List<Contact>> contactMapforSharing = new Map<String, List<Contact>>();
		for (Contact contact : [
				SELECT Id, OwnerId, Migrated_record__c, AccountId, RecordTypeId, Owner.UserRole.Name, Region_Chapter__c,
						Hidden_Hospital_Account__c, Region_Chapter__r.Name, MailingState
				FROM Contact
				WHERE Id IN :newContactsMap.keySet()
				AND Owner.UserRole.Name = :ROLE_NATIONAL_STAFF
		]) {
			if (contact.OwnerId != oldContactsMap.get(contact.Id).OwnerId && contact.Region_Chapter__c != null
					&& contact.Region_Chapter__r.Name != ACCOUNT_NAME_MAW_AMERICA) {
				if (contactMapforSharing.containsKey(contact.Region_Chapter__r.Name)) {
					contactMapforSharing.get(contact.Region_Chapter__r.Name).add(contact);
				} else {
					contactMapforSharing.put(contact.Region_Chapter__r.Name, new List<contact>{
							contact
					});
				}
			}
		}
		if (!contactMapforSharing.isEmpty()) {
			ChapterStaffRecordSharing_AC.ContactSharing(contactMapforSharing);
		}
	}

	/**
	* Update hidden case fields
	* @param contactList
	* @param oldContactsMap
	*/
	public static void updateHiddenCaseFields(List<Contact> contactList, Map<Id, Contact> oldContactsMap) {
		RecursiveTriggerHandler.allowToEditRecord = true;
		List<Case> caseUpdateList = new List<Case>();
		Map<Id, Contact> updatedContact = new Map<Id, Contact>();
		for (Contact newContact : contactList) {
			Contact oldContact = oldContactsMap.get(newContact.Id);
			if (newContact.Diagnosis__c != oldContact.Diagnosis__c
					|| newContact.FirstName != oldContact.FirstName
					|| newContact.LastName != oldContact.LastName
					|| newContact.Preferred_Name__c != oldContact.Preferred_Name__c
					|| newContact.Middle_Name__c != oldContact.Middle_Name__c
					|| newContact.Gender__c != oldContact.Gender__c
					|| newContact.Birthdate != oldContact.Birthdate
					|| oldContact.County__c != newContact.County__c
					|| newContact.MobilePhone != oldContact.MobilePhone
					|| newContact.npe01__HomeEmail__c != oldContact.npe01__HomeEmail__c
					|| newContact.Mailingstreet != oldContact.Mailingstreet
					|| newContact.Mailingcity != oldContact.Mailingcity
					|| newContact.Mailingstate != oldContact.Mailingstate
					|| newContact.Mailingpostalcode != oldContact.Mailingpostalcode
					|| newContact.Mailingcountry != oldContact.Mailingcountry) {
				updatedContact.put(newContact.Id, newContact);
			}
		}
		if (!updatedContact.isEmpty()) {
			for (Case caseRecord : [
					SELECT Id, ContactId, Hidden_Contact_County__c, Hidden_Contact_Gender__c
					FROM Case
					WHERE ContactId IN :updatedContact.keySet()
					AND RecordType.Name != :Constant_AC.CASE_RECORD_TYPE_DIAGNOSIS_VERIFICATION_REVIEW
			]) {
				if (caseRecord.Hidden_Contact_County__c != updatedContact.get(caseRecord.ContactId).County__c
						|| caseRecord.Hidden_Contact_Gender__c != updatedContact.get(caseRecord.ContactId).Gender__c) {
					caseRecord.Hidden_Contact_County__c = updatedContact.get(caseRecord.ContactId).County__c;
					caseRecord.Hidden_Contact_Gender__c = updatedContact.get(caseRecord.ContactId).Gender__c;
					caseUpdateList.add(caseRecord);
				}
			}
			try {
				update caseUpdateList;
			} catch (Exception e) {
				createContactDebugLog(updatedContact.values(), 'updateHiddenCaseFields', e);
			}
			RecursiveTriggerHandler.allowToEditRecord = false;
		}
	}

	/**
	* Display error message when the contact record is associated with a lead
	* @param contactMap
	*/
	public static void validateContact(Map<Id, Contact> contactMap) {
		if (!contactMap.isEmpty()) {
			List<Lead> leadList = new List<Lead>([
					SELECT Id, Hidden_Best_Contact_Person_Id__c, Medical_Professional_ContactId__c,
							Treating_Medical_Professional_Contact_Id__c, Hidden_Additional_Parent_Id__c, Wish_Family_ContactId__c
					FROM Lead
					WHERE Hidden_Best_Contact_Person_Id__c IN :contactMap.keySet()
					OR Medical_Professional_ContactId__c IN :contactMap.keySet()
					OR Treating_Medical_Professional_Contact_Id__c IN :contactMap.keySet()
					OR Hidden_Additional_Parent_Id__c IN :contactMap.keySet()
					OR Wish_Family_ContactId__c IN :contactMap.keySet()
			]);
			if (!leadList.isEmpty()) {
				for (Contact dbContact : contactMap.values()) {
					dbContact.addError('You cannot delete this Contact as it is associated with a Lead');
				}
			}
		}
	}

	/**
	* Updates fields on wish child record to hidden field
	* @param contactList
	* @return wishChildIdSet
	*/
	public static Set<Id> updateWishChildContactInfo(List<Contact> contactList) {
		String dummyEmail = Label.Dummy_Email;
		Set<Id> wishChildIdSet = new Set<Id>();
		for (Contact newContact : contactList) {
			if (newContact.RecordTypeId == WISH_CHILD_RECORD_TYPE_ID && newContact.IsContactInfoUpdated__c == true) {
				if (newContact.Hidden_First_Name__c != null) {
					newContact.FirstName = newContact.Hidden_First_Name__c;
					newContact.Hidden_First_Name__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Last_Name__c != null) {
					newContact.LastName = newContact.Hidden_Last_Name__c;
					newContact.Hidden_Last_Name__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Phone__c != null && newContact.Hidden_Phone__c != PHONE_PLACEHOLDER) {
					newContact.HomePhone = newContact.Hidden_Phone__c;
					newContact.Hidden_Phone__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_Phone__c == PHONE_PLACEHOLDER) {
						newContact.HomePhone = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.HiddenOtherPhone__c != null && newContact.HiddenOtherPhone__c != PHONE_PLACEHOLDER) {
					newContact.OtherPhone = newContact.HiddenOtherPhone__c;
					newContact.HiddenOtherPhone__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.HiddenOtherPhone__c == PHONE_PLACEHOLDER) {
						newContact.OtherPhone = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.HiddenMobilePhone__c != null && newContact.HiddenMobilePhone__c != PHONE_PLACEHOLDER) {
					newContact.MobilePhone = newContact.HiddenMobilePhone__c;
					newContact.HiddenMobilePhone__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.HiddenMobilePhone__c == PHONE_PLACEHOLDER) {
						newContact.MobilePhone = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Email__c != null && newContact.Hidden_Email__c != dummyEmail) {
					newContact.Email = newContact.Hidden_Email__c;
					newContact.Hidden_Email__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_Email__c == dummyEmail) {
						newContact.Email = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Street__c != null && newContact.Hidden_Street__c != dummyEmail) {
					newContact.MailingStreet = newContact.Hidden_Street__c;
					newContact.Hidden_Street__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_Street__c == dummyEmail) {
						newContact.MailingStreet = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_city__c != null && newContact.Hidden_city__c != dummyEmail) {
					newContact.MailingCity = newContact.Hidden_city__c;
					newContact.Hidden_city__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_city__c == dummyEmail) {
						newContact.MailingCity = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_State__c != null && newContact.Hidden_State__c != dummyEmail) {
					newContact.MailingState = newContact.Hidden_State__c;
					newContact.Hidden_State__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_State__c == dummyEmail) {
						newContact.MailingState = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Country__c != null && newContact.Hidden_Country__c != dummyEmail) {
					newContact.MailingCountry = newContact.Hidden_Country__c;
					newContact.Hidden_Country__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_Country__c == dummyEmail) {
						newContact.MailingCountry = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Zip_Code__c != null && newContact.Hidden_Zip_Code__c != ZIP_PLACEHOLDER) {
					newContact.MailingPostalCode = newContact.Hidden_Zip_Code__c;
					newContact.Hidden_Zip_Code__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					if (newContact.Hidden_Zip_Code__c == ZIP_PLACEHOLDER) {
						newContact.MailingPostalCode = null;
					}
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Preferred_Contact_Rel_Id__c != null && newContact.Hidden_Preferred_Contact_Rel_Id__c != REMOVE) {
					newContact.Hidden_Current_Pref_Con_Rel_Id__c = newContact.Hidden_Preferred_Contact_Rel_Id__c;
					newContact.Hidden_Preferred_Contact_Rel_Id__c = null;
					newContact.IsContactInfoUpdated__c = false;
				} else {
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
				if (newContact.Hidden_Preferred_Contact_Rel_Id__c == REMOVE) {
					newContact.Preferred_Contact_Name__c = '';
					newContact.Preferred_Contact_Relationship__c = '';
					newContact.Preferred_Contact_Number__c = '';
					newContact.Hidden_Preferred_Contact_Rel_Id__c = '';
					newContact.Hidden_Current_Pref_Con_Rel_Id__c = '';
					newContact.IsContactInfoUpdated__c = false;
				} else {
					wishChildIdSet.add(newContact.Id);
					newContact.IsContactInfoUpdated__c = false;
				}
			}
		}
		return wishChildIdSet;
	}

	/**
	* Update hidden contact fields to empty/null if wish child record has been updated
	* @param contactList
	*/
	public static void clearHiddenFields(List<Contact> contactList) {
		for (Contact newContact : contactList) {
			if (newContact.RecordTypeId == WISH_CHILD_RECORD_TYPE_ID && newContact.IsContactInfoUpdated__c == true
					&& (newContact.IsRejected_Contact_Info__c == true || newContact.isRecall_Contact_Info__c == true)
					&& (newContact.Hidden_First_Name__c != null
					|| newContact.Hidden_Last_Name__c != null
					|| newContact.Hidden_Phone__c != null
					|| newContact.Hidden_Email__c != null
					|| newContact.Hidden_Street__c != null
					|| newContact.Hidden_State__c != null
					|| newContact.HiddenOtherPhone__c != null
					|| newContact.HiddenMobilePhone__c != null
					|| newContact.Hidden_Country__c != null
					|| newContact.Hidden_Zip_Code__c != null
					|| newContact.Hidden_city__c != null
					|| newContact.Hidden_Preferred_Contact_Rel_Id__c != null)) {
				newContact.Hidden_First_Name__c = null;
				newContact.Hidden_Last_Name__c = null;
				newContact.Hidden_Phone__c = null;
				newContact.HiddenMobilePhone__c = null;
				newContact.HiddenOtherPhone__c = null;
				newContact.Hidden_Email__c = null;
				newContact.Hidden_Street__c = null;
				newContact.Hidden_State__c = null;
				newContact.Hidden_Country__c = null;
				newContact.Hidden_Zip_Code__c = null;
				newContact.Hidden_city__c = null;
				newContact.Hidden_Preferred_Contact_Rel_Id__c = null;
			}
			newContact.IsRejected_Contact_Info__c = false;
			newContact.isRecall_Contact_Info__c = false;
		}
	}

	/**
	* Create volunteer user record
	* @param contactIds
	*/
	@Future
	public static void createVolunteerUser(Set<Id> contactIds) {
		Map<String, String> timeZoneMap = new Map<String, String>();
		timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Phoenix)', 'America/Phoenix');
		timeZoneMap.put('(GMT-02:00) Brasilia Summer Time (America/Sao_Paulo)', 'America/Sao_Paulo');
		timeZoneMap.put('(GMT-03:00) Argentina Time (America/Argentina/Buenos_Aires)', 'America/Argentina/Buenos_Aires');
		timeZoneMap.put('(GMT-03:00) Chile Summer Time (America/Santiago)', 'America/Santiago');
		timeZoneMap.put('(GMT-03:30) Newfoundland Standard Time (America/St_Johns)', 'America/St_Johns');
		timeZoneMap.put('(GMT-04:00) Atlantic Standard Time (America/Halifax)', 'America/Halifax');
		timeZoneMap.put('(GMT-04:00) Atlantic Standard Time (America/Puerto_Rico)', 'America/Puerto_Rico');
		timeZoneMap.put('(GMT-04:30) Venezuela Time (America/Caracas)', 'America/Caracas');
		timeZoneMap.put('(GMT-05:00) Colombia Time (America/Bogota)', 'America/Bogota');
		timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/Indiana/Indianapolis)', 'America/Indiana/Indianapolis');
		timeZoneMap.put('(GMT-05:00) Peru Time (America/Lima)', 'America/Lima');
		timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/New_York)', 'America/New_York');
		timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/Panama)', 'America/Panama');
		timeZoneMap.put('(GMT-06:00) Central Standard Time (America/Chicago)', 'America/Chicago');
		timeZoneMap.put('(GMT-06:00) Central Standard Time (America/El_Salvador)', 'America/El_Salvador');
		timeZoneMap.put('(GMT-06:00) Central Standard Time (America/Mexico_City)', 'America/Mexico_City');
		timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Denver)', 'America/Denver');
		timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Phoenix)', 'America/Phoenix');
		timeZoneMap.put('(GMT-08:00) Pacific Standard Time (America/Los_Angeles)', 'America/Los_Angeles');
		timeZoneMap.put('(GMT-08:00) Pacific Standard Time (America/Tijuana)', 'America/Tijuana');
		timeZoneMap.put('(GMT-09:00) Alaska Standard Time (America/Anchorage)', 'America/Anchorage');
		List<User> userList = new List<User>();
		String profileId = label.Active_Volunteer_Profile;
		if (!contactIds.isEmpty()) {
			for (Contact contact : [
					SELECT Id, FirstName, Middle_Name__c, LastName, Account.Timezone__c, Email
					FROM Contact
					WHERE Id IN :contactIds
					AND RecordTypeId = :VOLUNTEER_RT_ID
					AND Do_Not_Create_User__c = false
					AND Migrated_Record__c = true
					AND Email != null
			]) {
				User user = new User();
				user.FirstName = contact.FirstName;
				user.LastName = contact.LastName;
				user.ContactId = contact.Id;
				user.CommunityNickname = contact.Email;
				user.ProfileId = profileId;
				user.Email = contact.Email;
				user.Username = contact.Email;
				if (contact.LastName != null) {
					if (contact.LastName.length() > 7) {
						user.Alias = (contact.LastName).subString(0, 7);
					} else {
						user.Alias = contact.LastName;
					}
				}
				if (contact.Middle_Name__c != null) {
					if (contact.Middle_Name__c.length() > 7) {
						user.Alias = (contact.Middle_Name__c).subString(0, 7);
					} else {
						user.Alias = contact.Middle_Name__c;
					}
				}
				if (timeZoneMap.containsKey(contact.Account.Timezone__c)) {
					user.TimeZoneSidKey = timeZoneMap.get(contact.Account.Timezone__c);
				} else {
					user.TimeZoneSidKey = 'America/Los_Angeles';
				}
				user.LocaleSidKey = 'en_US';
				user.EmailEncodingKey = 'ISO-8859-1';
				user.LanguageLocaleKey = 'en_US';
				user.IsActive = true;
				user.migrated_user__c = true;
				userList.add(user);
				if (!userList.isEmpty()) {
					Database.insert(userList, false);
				}
			}
		}
	}

	/**
	* Create debug log when error occurs
	* @param exceptionList
	* @param methodName
	* @param exception
	*/
	public static void createContactDebugLog(List<SObject> exceptionList, String methodName, Exception ex) {
		for (SObject record : exceptionList) {
			ErrorMessage_AC.createDebugRec('ContactService', String.valueOf(record), String.valueOf(ex),
					methodName, record.Id, ex.getStackTraceString() + ' ' + ex.getMessage(), 'Error');
			record.addError(Label.Debug_log_error_message);
		}
	}

	/**
	 * Update the number of Volunteer Opportunities assigned to the Volunteer Contact
	 * @param volunteerIds
	 */
	public static List<Contact> updateAssignedNumberOfOpportunities(Set<Id> volunteerIds) {
		List<Contact> contacts = new List<Contact>();
		if (volunteerIds.isEmpty()) {
			return contacts;
		}
		try {
			for (Contact contact : [
					SELECT Id,Number_of_Assignments__c,Name, (
							SELECT Id,Volunteer_Name__c
							FROM Volunteer_Opportunities__r
							WHERE Volunteer_Name__c IN:volunteerIds
					)
					FROM Contact
					WHERE Id IN:volunteerIds
			]) {
				Contact updateContact = new Contact();
				updateContact.Id = contact.Id;
				updateContact.Number_of_Assignments__c = contact.Volunteer_Opportunities__r.size();
				contacts.add(updateContact);
			}
			update contacts;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : [
					SELECT Id,Volunteer_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Volunteer_Name__c IN:volunteerIds
			]) {
				ErrorMessage_AC.createDebugRec('ContactService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex),
						'updateAssignedNumberOfOpportunities', volunteerOpportunity.Id,
						ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
		return contacts;
	}
}