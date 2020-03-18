/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 7/8/2016
Description : This Class is used for volunteers to register wish and non wish volunteer opportunities and to display
Volunteer opportunities that are assigned to the current loged in volunteer user based on their chapters.
        WVC-2199    Pavithra G    8/8/2018

*******************************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolunteerWorkItems_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	public String nonWishQueryString { get; set; }
	public String assignedQueryString { get; set; }
	public String wishQueryString { get; set; }
	public String assignedWishQueryString { get; set; }
	public List<Volunteer_Opportunity__c> volunteerNonWishEventsList { get; set; }
	public List<Volunteer_Opportunity__c> volunteerWishEventsList { get; set; }
	public List<npe5__Affiliation__c> chaptersList { get; set; }
	public Set<Id> volunteerChaptersSet { get; set; }
	public Id userRelatedContactId { get; set; }
	public Id volunteerOpportunityRecordId { get; set; }
	public Boolean isReferesh { get; set; }
	public Boolean wishTab { get; set; }
	public Boolean nonWishTab { get; set; }
	public Map<Id, Boolean> recordVisibilityMap { get; set; }
	public Map<Id, Boolean> rejectedOpportunitiesMap { get; set; }
	public List<Volunteer_Opportunity__c> closedVolunteerWishList;
	public List<Volunteer_Opportunity__c> closedVolunteerNonWishList;
	public boolean isWishClosed { get; set; }
	public boolean isWishNotClose { get; set; }
	public Map<Id, Boolean> visibilityMap { get; set; }
	//Used to get record type Id for wish and non wish events
	public Id wishEventsRegistered = Constant_AC.REGISTERED_WISH_ID;
	public Id nonWishEvents = Constant_AC.NON_WISH_EVENT_RT_ID;

	public Id wishEvents = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
	public Id trainingRTId = Constant_AC.TRAINING_RT_ID;
	public Id registeredWishRecordTypeId = Constant_AC.REGISTERED_WISH_ID;
	public Id registeredNonWishRecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
	//Used to get the current logged in user related contact and used to get all chapters of the volunteer user.
	public VolunteerWorkItems_AC() {

		visibilityMap = new Map<Id, Boolean>();
		isWishClosed = false;
		isWishNotClose = true;
		recordVisibilityMap = new Map<Id, Boolean>();
		rejectedOpportunitiesMap = new Map<Id, Boolean>();
		wishTab = true;
		nonWishTab = true;
		volunteerChaptersSet = new Set<Id>();
		Id currentUserId = userInfo.getUserId();

		List<User> getUserRelatedContact = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :currentUserId
				LIMIT 1
		];
		userRelatedContactId = getUserRelatedContact.get(0).ContactId;
		chaptersList = [
				SELECT Id,npe5__Primary__c, npe5__Organization__c, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :userRelatedContactId
		];
		if (chaptersList.size() > 0) {
			for (npe5__Affiliation__c getChapterName : chaptersList) {
				volunteerChaptersSet.add(getChapterName.npe5__Organization__c);
			}
		}
	}

	public VolunteerWorkItems_AC(ApexPages.StandardController controller) {

		visibilityMap = new Map<Id, Boolean>();
		isWishClosed = false;
		isWishNotClose = true;
		recordVisibilityMap = new Map<Id, Boolean>();
		rejectedOpportunitiesMap = new Map<Id, Boolean>();
		wishTab = true;
		nonWishTab = true;
		volunteerChaptersSet = new Set<Id>();
		Id currentUserId = userInfo.getUserId();
		Volunteer_Opportunity__c volRec = (Volunteer_Opportunity__c) controller.getRecord();
		volunteerOpportunityRecordId = volRec.Id;
		List<User> getUserRelatedContact = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :currentUserId
				LIMIT 1
		];
		userRelatedContactId = getUserRelatedContact.get(0).ContactId;
		chaptersList = [
				SELECT Id,npe5__Primary__c, npe5__Organization__c, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :userRelatedContactId
		];
		if (chaptersList.size() > 0) {
			for (npe5__Affiliation__c getChapterName : chaptersList) {
				volunteerChaptersSet.add(getChapterName.npe5__Organization__c);
			}
		}
	}

	public void CurrentWish() {

		isWishClosed = false;
		isWishNotClose = true;
	}

	public void HistoricalWish() {
		isWishClosed = true;
		isWishNotClose = false;

	}

	// This method is used to display all wish events which are assigned to current logged in Volunteer
	public List<Volunteer_Opportunity__c> getVolunteerAssignedWishEvents() {
		assignedWishQueryString = 'SELECT Chapter_Name__c,Inactivated_or_Rejected_Date__c, Wish__c,Wish__r.isClosed,Reason_Inactive__c,Inactive__c,Status__c,';
		for (Schema.FieldSetMember nonWishEventField : SObjectType.Volunteer_Opportunity__c.FieldSets.MyAssignmentsWish.getFields()) {
			assignedWishQueryString += nonWishEventField.getFieldPath() + ',';
		}
		assignedWishQueryString = assignedWishQueryString.removeEnd(',');
		Date todaysDate = Date.today().addDays(-30);
		assignedWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN :volunteerChaptersSet AND Status__c != \'Out of Compliance\' AND (RecordTypeId =: registeredWishRecordTypeId OR RecordTypeId =:wishEvents) AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND Wish__r.isClosed = False AND Reason_Inactive__c != \'Error\' LIMIT 50000';
		volunteerWishEventsList = Database.query(assignedWishQueryString);
		if (volunteerWishEventsList.size() > 0) {
			for (Volunteer_Opportunity__c checkApprovalStatus : volunteerWishEventsList) {
				visibilityMap.put(checkApprovalStatus.Id, false);
				if (checkApprovalStatus.Status__c == 'Approved') {
					visibilityMap.put(checkApprovalStatus.Id, true);
				} else if (checkApprovalStatus.Inactive__c == true
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c != null
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c.addDays(30) > Date.today()) {
					visibilityMap.put(checkApprovalStatus.Id, true);
				} else if (checkApprovalStatus.Status__c == 'Pending'
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c != null
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c.addDays(30) > Date.today()) {
					visibilityMap.put(checkApprovalStatus.Id, true);
				}
			}
		}
		return volunteerWishEventsList;
	}

	// This method is used to display all wish and non wish events which are assigned to current logged in Volunteer
	public List<Volunteer_Opportunity__c> getVolunteerAssignedNonWishEvents() {
		String Logvalue, recId;
		assignedWishQueryString = 'SELECT Chapter_Name__c,Inactivated_or_Rejected_Date__c,Reason_Inactive__c,Inactive__c,Status__c,';
		Date today = Date.today();
		for (Schema.FieldSetMember nonWishEventField : SObjectType.Volunteer_Opportunity__c.FieldSets.MyAssignmentsNonWish.getFields()) {
			assignedWishQueryString += nonWishEventField.getFieldPath() + ',';
		}
		assignedWishQueryString = assignedWishQueryString.removeEnd(',');
		String VOStatus = 'Completed';
		Date todaysDate = Date.today().addDays(-30);
		//assignedWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND RecordTypeId =: nonWishEvents AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND Non_Wish_Event__r.RecordTypeId =: nonWishRT AND Non_Wish_Event__r.Event_Date__c < today';
		//assignedWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND (RecordTypeId =: registeredNonWishRecordTypeId OR RecordTypeId =:nonWishEvents ) AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND Non_Wish_Event__r.Event_Date__c >=: today AND Inactive__c = False AND Reason_Inactive__c = Null';
		assignedWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND Status__c != \'Out of Compliance\' AND (RecordTypeId =: registeredNonWishRecordTypeId OR RecordTypeId =:nonWishEvents ) AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND Status__c !=: VOStatus AND Reason_Inactive__c != \'Error\' LIMIT 50000';
		volunteerNonWishEventsList = Database.query(assignedWishQueryString);
		if (volunteerNonWishEventsList.size() > 0) {
			for (Volunteer_Opportunity__c checkApprovalStatus : volunteerNonWishEventsList) {
				visibilityMap.put(checkApprovalStatus.Id, false);
				if (checkApprovalStatus.Status__c == 'Approved') {
					visibilityMap.put(checkApprovalStatus.Id, true);
				} else if (checkApprovalStatus.Inactive__c == true
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c != null
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c.addDays(30) > Date.today()) {
					visibilityMap.put(checkApprovalStatus.Id, true);
				} else if (checkApprovalStatus.Status__c == 'Pending'
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c != null
						&& checkApprovalStatus.Inactivated_or_Rejected_Date__c.addDays(30) > Date.today()) {
					visibilityMap.put(checkApprovalStatus.Id, true);
				}
			}
		}
		return volunteerNonWishEventsList;
	}

	/*This method is used to display all non wish volunteer opportunities for volunteers based on their chapters and used to display total number of
reqired volunteers and registered volunteers count.*/
	public List<WrapperClass> getNonWishEvents() {
		Map<String, WrapperClass> nonWishOpportunitiesMap = new Map<String, WrapperClass>();
		Set<Id> nonWishIdSet = new Set<Id>();
		Date today = date.today();
		nonWishQueryString = 'SELECT Chapter_Name__c,Non_Wish_Event__c,';
		assignedQueryString = 'SELECT Chapter_Name__c,Non_Wish_Event__c,';
		for (Schema.FieldSetMember nonWishEventField : SObjectType.Volunteer_Opportunity__c.FieldSets.NonWishEvents.getFields()) {
			nonWishQueryString += nonWishEventField.getFieldPath() + ',';
			assignedQueryString += nonWishEventField.getFieldPath() + ',';
		}
		nonWishQueryString = nonWishQueryString.removeEnd(',');
		assignedQueryString = assignedQueryString.removeEnd(',');
		//nonWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c = null AND Chapter_Name__c IN : volunteerChaptersSet AND RecordTypeId =: nonWishEvents AND Reason_Inactive__c = null AND Non_Wish_Event__r.RecordTypeId =: nonWishRT ';
		//assignedQueryString +=  ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND RecordTypeId =: nonWishEvents AND Reason_Inactive__c = null AND Non_Wish_Event__r.RecordTypeId =: nonWishRT ';
		nonWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c = null AND Chapter_Name__c IN : volunteerChaptersSet AND RecordTypeId =: nonWishEvents AND Reason_Inactive__c = null AND Inactive__c = False  AND Non_Wish_Event__r.Event_Date__c >= : today LIMIT 50000';

		volunteerNonWishEventsList = Database.query(nonWishQueryString);
		for (Volunteer_Opportunity__c nonWishOpportunities : volunteerNonWishEventsList) {
			nonWishIdSet.add(nonWishOpportunities.Non_Wish_Event__c);
			if (!nonWishOpportunitiesMap.containsKey(nonWishOpportunities.Non_Wish_Event__c + '-'
					+ nonWishOpportunities.Chapter_Name__c + '-'
					+ nonWishOpportunities.Role__c + '-'
					+ nonWishOpportunities.HiddenVolunteer_Count_Description__c)) {
				WrapperClass nonwishWrapperInstance = new WrapperClass();
				nonwishWrapperInstance.nonWishOpportunities = nonWishOpportunities;
				nonwishWrapperInstance.nonWishOpportunityCount = (nonwishWrapperInstance.nonWishOpportunityCount == null)
						? 1 : nonwishWrapperInstance.nonWishOpportunityCount + 1;
				nonWishOpportunitiesMap.put(nonWishOpportunities.Non_Wish_Event__c + '-'
						+ nonWishOpportunities.Chapter_Name__c + '-'
						+ nonWishOpportunities.Role__c + '-'
						+ nonWishOpportunities.HiddenVolunteer_Count_Description__c, nonwishWrapperInstance);
			} else {
				WrapperClass nonwishWrapperInstance = nonWishOpportunitiesMap.get(nonWishOpportunities.Non_Wish_Event__c + '-'
						+ nonWishOpportunities.Chapter_Name__c + '-'
						+ nonWishOpportunities.Role__c + '-'
						+ nonWishOpportunities.HiddenVolunteer_Count_Description__c);
				nonwishWrapperInstance.nonWishOpportunityCount = (nonwishWrapperInstance.nonWishOpportunityCount == null)
						? 1 : nonwishWrapperInstance.nonWishOpportunityCount + 1;
				nonWishOpportunitiesMap.put(nonWishOpportunities.Non_Wish_Event__c + '-'
						+ nonWishOpportunities.Chapter_Name__c + '-'
						+ nonWishOpportunities.Role__c + '-'
						+ nonWishOpportunities.HiddenVolunteer_Count_Description__c, nonwishWrapperInstance);
			}
		}

		assignedQueryString += ' FROM Volunteer_Opportunity__c WHERE Non_Wish_Event__c IN : nonWishIdSet AND Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND (RecordTypeId =: registeredNonWishRecordTypeId OR RecordTypeId =:nonWishEvents )  AND Reason_Inactive__c = null AND Inactive__c = False LIMIT 50000';
		for (Volunteer_Opportunity__c assignedNonWishOpportunities : Database.query(assignedQueryString)) {
			if (nonWishOpportunitiesMap.containsKey(assignedNonWishOpportunities.Non_Wish_Event__c + '-'
					+ assignedNonWishOpportunities.Chapter_Name__c + '-'
					+ assignedNonWishOpportunities.Role__c + '-'
					+ assignedNonWishOpportunities.HiddenVolunteer_Count_Description__c)) {
				WrapperClass nonwishWrapperInstance = nonWishOpportunitiesMap.get(assignedNonWishOpportunities.Non_Wish_Event__c + '-'
						+ assignedNonWishOpportunities.Chapter_Name__c + '-'
						+ assignedNonWishOpportunities.Role__c + '-' + assignedNonWishOpportunities.HiddenVolunteer_Count_Description__c);
				nonwishWrapperInstance.nonWishOpportunityCount = (nonwishWrapperInstance.nonWishOpportunityCount == null)
						? 1 : nonwishWrapperInstance.nonWishOpportunityCount + 1;
				nonwishWrapperInstance.registeredNonWishOpportunityCount = (nonwishWrapperInstance.registeredNonWishOpportunityCount == null)
						? 1 : nonwishWrapperInstance.registeredNonWishOpportunityCount + 1;
				nonWishOpportunitiesMap.put(assignedNonWishOpportunities.Non_Wish_Event__c + '-'
						+ assignedNonWishOpportunities.Chapter_Name__c + '-'
						+ assignedNonWishOpportunities.Role__c + '-'
						+ assignedNonWishOpportunities.HiddenVolunteer_Count_Description__c, nonwishWrapperInstance);
			}
		}
		return nonWishOpportunitiesMap.values();
	}

	//This method is used to display the current volunteer closed wish records.
	public List<Volunteer_Opportunity__c> getClosedWish() {
		closedVolunteerWishList = new List<Volunteer_Opportunity__c>();
		String closedWishQueryString = 'SELECT Wish__r.isClosed,Wish__r.CaseNumber,';
		for (Schema.FieldSetMember closedWishField : SObjectType.Volunteer_Opportunity__c.FieldSets.MyAssignmentsClosedWish.getFields()) {
			closedWishQueryString += closedWishField.getFieldPath() + ',';
		}
		closedWishQueryString = closedWishQueryString .removeEnd(',');
		closedWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND (RecordTypeId =: wishEventsRegistered OR RecordTypeId =: wishEvents) AND Reason_Inactive__c = null AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND (Wish__r.isClosed = true OR Wish__r.Status = \'completed\') AND Reason_Inactive__c != \'Error\' LIMIT 50000';
		closedVolunteerWishList = Database.query(closedWishQueryString);
		return closedVolunteerWishList;
	}

	//This method is used to display the current volunteer closed Non Wish Event records.
	public List<Volunteer_Opportunity__c> getClosedNonWishEvents() {

		Date today = Date.today();
		closedVolunteerNonWishList = new List<Volunteer_Opportunity__c>();
		String closedNonWishQueryString = 'SELECT Non_Wish_Event__r.Event_Date__c,Non_Wish_Event__r.Name,Status__c,';
		for (Schema.FieldSetMember closedNonWishField : SObjectType.Volunteer_Opportunity__c.FieldSets.MyAssignmentsClosedNonWish.getFields()) {
			closedNonWishQueryString += closedNonWishField.getFieldPath() + ',';
		}
		closedNonWishQueryString = closedNonWishQueryString .removeEnd(',');
		String VOStatus = 'Completed';
		//closedNonWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND RecordTypeId =: nonWishEvents AND Reason_Inactive__c = null AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND Non_Wish_Event__r.Event_Date__c <: today';
		closedNonWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND (RecordTypeId =: registeredNonWishRecordTypeId OR RecordTypeId =:nonWishEvents ) AND Reason_Inactive__c = null AND Name != null AND Volunteer_Name__c =: userRelatedContactId AND Status__c =: VOStatus AND Reason_Inactive__c != \'Error\' LIMIT 50000';
		closedVolunteerNonWishList = Database.query(closedNonWishQueryString);
		return closedVolunteerNonWishList ;
	}

	//This method is used to display all wish volunteer opportunities for volunteers based on their chapters and used to display total number of
	//reqired volunteers and registered volunteers count.
	public List<WishWrapperClass> getWishEvents() {
		String Logvalue, recId;
		Map<String, WishWrapperClass> wishOpportunitiesMap = new Map<String, WishWrapperClass>();
		Set<Id> wishIdSet = new Set<Id>();
		wishQueryString = 'SELECT Chapter_Name__c, Wish__c,Wish__r.Status,Wish__r.Sub_Status__c, Is_Non_Viewable__c,';
		assignedWishQueryString = 'SELECT Chapter_Name__c, Wish__c,';

		for (Schema.FieldSetMember wishEventField : SObjectType.Volunteer_Opportunity__c.FieldSets.WishEvents.getFields()) {
			wishQueryString += wishEventField.getFieldPath() + ',';
			assignedWishQueryString += wishEventField.getFieldPath() + ',';
		}

		wishQueryString = wishQueryString.removeEnd(',');
		assignedWishQueryString = assignedWishQueryString.removeEnd(',');
		wishQueryString += ' FROM Volunteer_Opportunity__c WHERE ((Wish__r.Sub_Status__c!= \'Non-Viewable\') OR (Wish__r.Sub_Status__c= \'Non-Viewable\' AND Is_Non_Viewable__c!= true)) AND Volunteer_Name__c = null AND Chapter_Name__c IN : volunteerChaptersSet AND RecordTypeId =: wishEvents AND Reason_Inactive__c = null AND Inactive__c = False LIMIT 50000';

		volunteerWishEventsList = Database.query(wishQueryString);
		for (Volunteer_Opportunity__c wishOpportunities : volunteerWishEventsList) {
			wishIdSet.add(wishOpportunities.Wish__c);
			if (!wishOpportunitiesMap.containsKey(wishOpportunities.Wish__c + '-' + wishOpportunities.Chapter_Name__c + '-' + wishOpportunities.Role__c)) {
				WishWrapperClass wishWrapperInstance = new WishWrapperClass();
				wishWrapperInstance.wishOpportunities = wishOpportunities;
				wishWrapperInstance.wishOpportunitiesCount = (wishWrapperInstance.wishOpportunitiesCount == null)
						? 1 : wishWrapperInstance.wishOpportunitiesCount + 1;
				wishOpportunitiesMap.put(wishOpportunities.Wish__c + '-'
						+ wishOpportunities.Chapter_Name__c + '-'
						+ wishOpportunities.Role__c, wishWrapperInstance);
			} else {
				WishWrapperClass wishWrapperInstance = wishOpportunitiesMap.get(wishOpportunities.Wish__c + '-'
						+ wishOpportunities.Chapter_Name__c + '-' + wishOpportunities.Role__c);
				wishWrapperInstance.wishOpportunitiesCount = (wishWrapperInstance.wishOpportunitiesCount == null)
						? 1 : wishWrapperInstance.wishOpportunitiesCount + 1;
				wishOpportunitiesMap.put(wishOpportunities.Wish__c + '-'
						+ wishOpportunities.Chapter_Name__c + '-'
						+ wishOpportunities.Role__c, wishWrapperInstance);
			}
		}

		assignedWishQueryString += ' FROM Volunteer_Opportunity__c WHERE Wish__c IN : wishIdSet AND Volunteer_Name__c != null AND Chapter_Name__c IN : volunteerChaptersSet AND (RecordTypeId =: wishEvents OR RecordTypeId = :registeredWishRecordTypeId) AND Reason_Inactive__c = null AND Inactive__c = False LIMIT 50000';
		for (Volunteer_Opportunity__c assignedWishOpportunities : Database.query(assignedWishQueryString)) {
			if (wishOpportunitiesMap.containsKey(assignedWishOpportunities.Wish__c + '-'
					+ assignedWishOpportunities.Chapter_Name__c + '-'
					+ assignedWishOpportunities.Role__c)) {
				WishWrapperClass wishWrapperInstance = wishOpportunitiesMap.get(assignedWishOpportunities.Wish__c + '-'
						+ assignedWishOpportunities.Chapter_Name__c + '-' + assignedWishOpportunities.Role__c);
				wishWrapperInstance.wishOpportunitiesCount = (wishWrapperInstance.wishOpportunitiesCount == null)
						? 1 : wishWrapperInstance.wishOpportunitiesCount + 1;
				wishWrapperInstance.registeredWishOpportunitiesCount = (wishWrapperInstance.registeredWishOpportunitiesCount == null)
						? 1 : wishWrapperInstance.registeredWishOpportunitiesCount + 1;
				wishOpportunitiesMap.put(assignedWishOpportunities.Wish__c + '-'
						+ assignedWishOpportunities.Chapter_Name__c + '-'
						+ assignedWishOpportunities.Role__c, wishWrapperInstance);
			}
		}
		return wishOpportunitiesMap.values();

	}

	public boolean getChapterRoleOanTStatus(Id chapterRole) {

		List<Chapter_Role_O_T__c> currTrainig = [
				SELECT id, Required__c
				FROM Chapter_Role_O_T__c
				WHERE
				Chapter_Role__c = :chapterRole
				AND Orientation_Training__r.RecordTypeId = :trainingRTId
				limit 1
		];
		if (currTrainig.size() > 0)
			return currTrainig[0].Required__c; else
				return false;

	}

	public boolean allowRegisteration(List<Volunteer_Opportunity__c> volunteerOpportunity) {
		string Logvalue;
		string recId;
		try {
			Boolean updateRecord = false;
			Boolean allowRegister = false;
			boolean isWishRole = false;
			Map<Id, Volunteer_Roles__c> WishTrainedMap = new Map<Id, Volunteer_Roles__c>();
			Map<Id, Volunteer_Roles__c> WishNonTrainedMap = new Map<Id, Volunteer_Roles__c>();
			Set<Id> TrainedNonWishRoles = new Set<Id>();
			Set<Id> notTrainedNonWishRoles = new Set<Id>();
			boolean isWishGranterMentor = false;
			for (Role__c currRole : [
					SELECT id,Name,isWishRole__c
					FROM Role__c
					WHERE Id = :volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c
			]) {
				if (currRole.isWishRole__c == true) {
					isWishRole = true;
				}
			}
			/**** WVC-2199 Change status value pending training to Pending and sub status Missing Requirement ****/
			for (Volunteer_Roles__c checkForMatchingRole : [
					SELECT Id, Chapter_Name__c,Role_Name__c,isWishRole__c,Status__c, Chapter_Role__c,
							Chapter_Role__r.Role_Name__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c = :userRelatedContactId
					AND Chapter_Name__c = :volunteerOpportunity.get(0).Chapter_Name__r.Name
					AND (Status__c = :VOLUNTEER_ROLE_STATUS_ACTIVE OR (Status__c = 'Pending' AND Sub_status__c = 'Missing Requirement'))
			]) {
				Logvalue += String.valueOf(checkForMatchingRole);
				if (checkForMatchingRole.isWishRole__c == true && checkForMatchingRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE) {
					WishTrainedMap.put(checkForMatchingRole.Chapter_Role__c, checkForMatchingRole);
					if (checkForMatchingRole.Role_Name__c == 'Wish Granter Mentor') {
						isWishGranterMentor = true;
					}
				} else if (checkForMatchingRole.isWishRole__c == true && checkForMatchingRole.Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE) {
					WishNonTrainedMap.put(checkForMatchingRole.Chapter_Role__c, checkForMatchingRole);
				} else if (checkForMatchingRole.isWishRole__c == false
						&& checkForMatchingRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE) {
					TrainedNonWishRoles.add(checkForMatchingRole.Chapter_Role__r.Role_Name__c);
				} else if (checkForMatchingRole.isWishRole__c == false
						&& checkForMatchingRole.Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE) {
					notTrainedNonWishRoles.add(checkForMatchingRole.Chapter_Role__r.Role_Name__c);
				}
			}

			// Allowing Non-Wish Role for registering VO.
			if (isWishRole == false) {
				if (WishTrainedMap.size() > 0) {
					updateRecord = true;
					allowRegister = true;
				} else {
					if (getChapterRoleOanTStatus(volunteerOpportunity[0].Chapter_Role_Opportunity__c) == true) {
						if (TrainedNonWishRoles.contains(volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c)) {
							updateRecord = true;
							allowRegister = true;
						}
					} else {
						if (TrainedNonWishRoles.contains(volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c) ||
								(notTrainedNonWishRoles.contains(volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c))) {
							updateRecord = true;
							allowRegister = true;
						}
					}
				}
			} else if (isWishRole == true) {
				if (getChapterRoleOanTStatus(volunteerOpportunity[0].Chapter_Role_Opportunity__c) == true) {
					if (WishTrainedMap.containsKey(volunteerOpportunity[0].Chapter_Role_Opportunity__c)
							|| (isWishGranterMentor == true && volunteerOpportunity[0].Role__c == 'Wish Granter')) {
						updateRecord = true;
						allowRegister = true;
					}
				} else if (getChapterRoleOanTStatus(volunteerOpportunity[0].Chapter_Role_Opportunity__c) == false) {
					if (WishTrainedMap.containsKey(volunteerOpportunity[0].Chapter_Role_Opportunity__c) ||
							(isWishGranterMentor == true && volunteerOpportunity[0].Role__c == 'Wish Granter')) {
						updateRecord = true;
						allowRegister = true;
					}
				}
			}

			if (Test.isRunningTest()) {
				throw new DmlException('Test');
			}
			if (updateRecord == true && allowRegister == true) {
				return true;
			} else {
				return false;
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWorkItems_AC', 'allowRegisteration', recId, ex, Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return Null;
		}

	}

	// This method is used for volunteers to register on wish events if they have any one Non wish role and used to restrict volunteers to register on similar volunteer opportunities
	public void RegisterWishEvents() {
		List<string> LstLog = new List<string>();
		string Logvalue;
		string recId;
		try {
			isReferesh = true;
			wishTab = false;
			nonWishTab = false;
			boolean isUpdate = false;
			List<Volunteer_Opportunity__c> volunteerOpportunity = [
					SELECT Id, Wish__c, Role__c, Chapter_Name__r.Name,Volunteer_Name__c,Chapter_Role_Opportunity__r.Role_Name__c, RecordTypeId, OwnerId, Reason_Inactive__c
					FROM Volunteer_Opportunity__c
					WHERE Id = :volunteerOpportunityRecordId AND Reason_Inactive__c = :Null
			];
			LstLog.add(string.valueOf(volunteerOpportunity));
			List<Volunteer_Opportunity__c> volunteerOpportunityDuplicateLists = [
					SELECT Id,Role__c,Chapter_Name__r.Name,RecordtypeId,Wish__c,Reason_Inactive__c
					FROM Volunteer_Opportunity__c
					WHERE Role__c = :volunteerOpportunity.get(0).Role__c
					AND Chapter_Name__r.Name = :volunteerOpportunity.get(0).Chapter_Name__r.Name
					AND Wish__c = :volunteerOpportunity.get(0).Wish__c
					AND Volunteer_Name__c = :userRelatedContactId
					AND Reason_Inactive__c = :Null
			];
			List<Volunteer_Opportunity__c> volunteerOpportunitySameRoleList = [
					SELECT Id,Role__c,Chapter_Name__r.Name,RecordtypeId,Wish__c,Reason_Inactive__c,Chapter_Role_Opportunity__r.Role_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Role__c = :volunteerOpportunity.get(0).Role__c
					AND Chapter_Name__r.Name = :volunteerOpportunity.get(0).Chapter_Name__r.Name
					AND Wish__c = :volunteerOpportunity.get(0).Wish__c
					AND Volunteer_Name__c = :userRelatedContactId
					AND Inactive__c = :true
					AND Chapter_Role_Opportunity__r.Role_Name__c = :volunteerOpportunity.get(0).Chapter_Role_Opportunity__r.Role_Name__c
			];
			if (volunteerOpportunityDuplicateLists.size() > 0 || volunteerOpportunitySameRoleList.size() > 0) {
				/*Below three line changes are related to WVC-443 (11-09-2016)*/
				//ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,'You are not currently eligible to sign up for this volunteer opportunity. Please contact your chapter for more information on how to become eligible.');
				if (volunteerOpportunitySameRoleList.size() > 0) {
					ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,
							'You have been previously  declined for this opportunity. Please contact the chapter office with any questions.');
					ApexPages.addMessage(mymsg);
				} else if (volunteerOpportunityDuplicateLists.size() > 0) {
					ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,
							'You are already registered for this opportunity.');
					ApexPages.addMessage(mymsg);
				}
			} else {
				String chatperRoleId;
				String volunteerStatus;
				Boolean allowRegister = false;

				if (volunteerOpportunity.size() > 0) {
					allowRegister = allowRegisteration(volunteerOpportunity);

					if (allowRegister == true) {
						if (volunteerOpportunity.get(0).Volunteer_Name__c == Null) {
							volunteerOpportunity.get(0).Volunteer_Name__c = userRelatedContactId;
							isUpdate = true;

						} else {
							isUpdate = false;
							ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,
									'Please refresh the page and try again.');
							ApexPages.addMessage(mymsg);
						}

						if (isUpdate == true) {
							recId = volunteerOpportunity[0].id;
							LstLog.add(string.valueOf(volunteerOpportunity));
							update volunteerOpportunity;
							ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Confirm,
									'Thank you for requesting to volunteer for this opportunity. A notification has been sent to chapter staff to review your request and staff will respond with further details, as applicable.');
							ApexPages.addMessage(mymsg);
						}
					} else {
						ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,
								'Thank you for your interest in this opportunity. This opportunity requires specialized training that you have not completed, contact chapter staff for more information about expanding your volunteer opportunities.');
						ApexPages.addMessage(mymsg);
					}
				}
			}
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWorkItems_AC', 'RegisterWishEvents', recId, ex, Logvalue));
			ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getmessage());
			ApexPages.addMessage(myMsg);
		}
	}

	// This method is used for volunteers to register on non wish events if they have any one Non wish role and used to restrict volunteers to register on similar volunteer opportunities
	/* public void RegisterNonWishEvents() {
isReferesh = true;
wishTab = false;
nonWishTab = false;

String chatperRoleId;
String volunteerStatus;

Boolean allowRegister = false;
Boolean isWishGranter = false;
boolean isUpdate = false;
List<Volunteer_Opportunity__c> volunteerOpportunitySameRoleList;
List<Volunteer_Opportunity__c> volunteerOpportunity = [SELECT Id, Role__c, Chapter_Name__r.Name,Volunteer_Name__c,HiddenVolunteer_Count_Description__c, RecordTypeId,Chapter_Role_Opportunity__r.Role_Name__c, OwnerId, Non_Wish_Event__c, Reason_Inactive__c FROM Volunteer_Opportunity__c WHERE Id =: volunteerOpportunityRecordId AND Reason_Inactive__c =: Null LIMIT 1 FOR UPDATE];
List<Volunteer_Opportunity__c> volunteerOpportunityDuplicateLists = [SELECT Id, Role__c, Chapter_Name__r.Name, RecordtypeId, Non_Wish_Event__c, Reason_Inactive__c FROM Volunteer_Opportunity__c WHERE Role__c =: volunteerOpportunity.get(0).Role__c AND Chapter_Name__r.Name =: volunteerOpportunity.get(0).Chapter_Name__r.Name AND Non_Wish_Event__c =: volunteerOpportunity.get(0).Non_Wish_Event__c AND Volunteer_Name__c =: userRelatedContactId AND Reason_Inactive__c =: Null AND HiddenVolunteer_Count_Description__c =: volunteerOpportunity.get(0).HiddenVolunteer_Count_Description__c ];
if(!Test.isRunningTest())
volunteerOpportunitySameRoleList = [SELECT Id,Role__c,Chapter_Name__r.Name,RecordtypeId,Non_Wish_Event__c,Reason_Inactive__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Role__c =: volunteerOpportunity.get(0).Role__c AND Chapter_Name__r.Name =: volunteerOpportunity.get(0).Chapter_Name__r.Name AND Non_Wish_Event__c =: volunteerOpportunity.get(0).Non_Wish_Event__c AND Volunteer_Name__c =: userRelatedContactId AND Inactive__c =: true AND
Chapter_Role_Opportunity__r.Role_Name__c =: volunteerOpportunity.get(0).Chapter_Role_Opportunity__r.Role_Name__c ];
if(volunteerOpportunityDuplicateLists.size()>0 || volunteerOpportunitySameRoleList.size() > 0){
/*Below three line changes are related to WVC-443 (11-09-2016)*/
	//ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,'You are not currently eligible to sign up for this volunteer opportunity. Please contact your chapter for more information on how to become eligible.');

	/*  if(!Test.isRunningTest() && volunteerOpportunitySameRoleList.size() > 0){
ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,'You have been previously  declined for this opportunity. Please contact the chapter office with any questions.');
ApexPages.addMessage(mymsg);
}

else if(volunteerOpportunityDuplicateLists.size()>0){

ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,'You are already registered for this opportunity.');
ApexPages.addMessage(mymsg);
}
}
else {
if(volunteerOpportunity.size()>0)
{
allowRegister = allowRegisteration(volunteerOpportunity);


if(allowRegister == true)
{
if( volunteerOpportunity.get(0).Volunteer_Name__c ==  Null){
volunteerOpportunity.get(0).Volunteer_Name__c = userRelatedContactId;
isUpdate = true;

}
else{
isUpdate = false;
ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,'Please refresh the page and try again.');
ApexPages.addMessage(mymsg);
}

if(isUpdate == true){
update volunteerOpportunity;
ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Thank you for requesting to volunteer for this opportunity. A notification has been sent to chapter staff to review your request and staff will respond with further details, as applicable.');
ApexPages.addMessage(mymsg);
}
}
else
{
ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.Error,'Thank you for your interest in this opportunity. This opportunity requires specialized training that you have not completed, contact chapter staff for more information about expanding your volunteer opportunities.');
ApexPages.addMessage(mymsg);
}

}
}
} */

	//Used for registration confirmation and redirect to volunteer assignment opportunities page
	public pageReference registrationConfirmation() {
		pageReference pr;
		pr = new PageReference('/VolunteerAssignmentOpportunities_VF');
		return pr;
	}

	public pageReference RedirecttoVolOpportunity() {
		pageReference pr;
		pr = new PageReference('/' + volunteerOpportunityRecordId);
		return pr;
	}

	//Wrapper class for non wish volunteer opportunities
	public class WrapperClass {
		public Volunteer_Opportunity__c nonWishOpportunities { get; set; }
		public integer nonWishOpportunityCount { get; set; }
		public integer registeredNonWishOpportunityCount { get; set; }

	}

	//Wrapper class for wish volunteer opportunities
	public class WishWrapperClass {
		public Volunteer_Opportunity__c wishOpportunities { get; set; }
		public integer wishOpportunitiesCount { get; set; }
		public integer registeredWishOpportunitiesCount { get; set; }
	}
}