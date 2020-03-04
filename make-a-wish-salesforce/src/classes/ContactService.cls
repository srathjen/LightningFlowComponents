/**
 * @description Contact Service, exposes methods for the Controller layer.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2019
 */
public with sharing class ContactService {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String ORG_AFFILIATION_STATUS_STATUS_ACTIVE = 'Active';
	private final static String CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER = 'Single Day Event Volunteer';
	private final static String CHAPTER_ROLE_WISH_GRANTER = 'Wish Granter';
	private final static String CHAPTER_ROLE_WISH_GRANTER_MENTOR = 'Wish Granter Mentor';

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
			if (volRole.Role_Name__c == Constant_AC.BOARD_MEMBER_RT_LABEL
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
					&& ((volRole.Role_Name__c != Constant_AC.BOARD_MEMBER_RT_LABEL
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
				SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
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
				SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
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
				AND MailingPostalCode = :postalCode) OR (Email != '' AND Email = :email)))
				OR (FirstName = :firstName AND ((MailingState = :state AND MailingCity = :city AND MailingStreet = :street
				AND MailingPostalCode = :postalCode) OR Phone = :phone OR (Email != '' AND Email = :email)))
				OR (Birthdate = :dateOfBirth AND ((MailingState = :state AND MailingCity = :city
				AND MailingStreet = :street AND MailingPostalCode = :postalCode) OR (Email != '' AND Email = :email)))
				OR (Birthdate = :dateOfBirth AND (LastName = :lastName OR FirstName = :firstName)))
				AND RecordTypeId IN :recordTypes
		];
	}
}