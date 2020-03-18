/**
 * @description Contact Service, centralizes Contact business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2019
 */
public class ContactService {

	private final static Id MEDICAL_PROFESSIONAL_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
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
	private static final String DASH = '-';
	private static final String EMPTY = '';

	/**
	 * Activate Volunteer Contact Role
	 * @param contactMap
	 * @return Contact Map
	 */
	public static Map<Id, Contact> setVolunteerContactActive(Map<Id, Contact> contactMap) {
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
    // Update HouseHoldAddress for family contact records.
    @future
    public static void updateHouseHoldAddress(Set<Id> addressSet) {
        List<Contact> dbFamilyContact = new List<Contact>();
        Set<Id> dbFamilyAccountIdSet = new Set<Id>();
        List<Contact> updateFamilyContactList = new List<Contact>();
        Map<Id, Account> houseHoldAccountMap = new Map<Id, Account>();

        for (Contact familyContact : [
                SELECT Id,AccountId,Name,FirstName,LastName,Phone,Email,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Same_as_Household_Address__c
                From Contact
                WHERE Id IN:addressSet
                Limit 50000
        ]) {
            if (familyContact.Same_as_Household_Address__c == true) {
                dbFamilyAccountIdSet.add(familyContact.AccountId);
                dbFamilyContact.add(familyContact);
            }
        }
        if (dbFamilyAccountIdSet.size() > 0) {
            for (Account dbHouseHoldAccount : [
                    SELECT Id,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode
                    FROM Account
                    WHERE Id IN:dbFamilyAccountIdSet
                    Limit 50000
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

        }
        if (updateFamilyContactList.size() > 0)
            update updateFamilyContactList;
    }
}