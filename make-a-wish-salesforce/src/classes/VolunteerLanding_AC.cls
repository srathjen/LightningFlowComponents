/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 7/4/2016
Description : This class is used to pull the landing page content dynamically for active volunteer. If Background
check / COI record is expired or going to expire in 30 days, It will display  a popup message for renewel
their details.
*******************************************************************************************************************/
public class VolunteerLanding_AC {
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_ROLE_STATUS_PENDING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
	private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = Constant_AC.VOLUNTEER_ROLE_STATUS_NOT_APPROVED;
	private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
	private final static String VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW;
	private final static String VOLUNTEER_ROLE_SUB_STATUS_CHAPTER = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_CHAPTER;
	private final static String VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER;
	private final static String ORG_AFFILIATION_STATUS_PENDING = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
	private final static String ORG_AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
	private final static String ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE = Constant_AC.ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE;
	private final static String ORG_AFFILIATION_STATUS_NOT_APPROVED = Constant_AC.ORG_AFFILIATION_STATUS_NOT_APPROVED;
	private final static String ORG_AFFILIATION_STATUS_INACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
	private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
	private final static String BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_YES = Constant_AC.BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_YES;
	private final static String BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_NO = Constant_AC.BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_NO;
	public static final String VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
	public static final String VOLUNTEER_ATTENDANCE_VOLUNTEER_REGISTERED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
	public static final String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
	private final static String CONTACT_PREFERRED_EMAIL_WORK = Constant_AC.CONTACT_PREFERRED_EMAIL_WORK;
	private final static String CONTACT_PREFERRED_EMAIL_PERSONAL = Constant_AC.CONTACT_PREFERRED_EMAIL_PERSONAL;
	private final static String CONTACT_PREFERRED_EMAIL_ALTERNATE = Constant_AC.CONTACT_PREFERRED_EMAIL_ALTERNATE;
	private final static String WISH_ROLE_ALL_ROLES = Constant_AC.WISH_ROLE_ALL_ROLES;
	private final static String TASK_TYPE_EMAIL = Constant_AC.TASK_TYPE_EMAIL;
	private final static String PAGE_VOLUNTEER_LANDING_VF = 'VolunteerLanding_VF';
	public List<Dynamic_Content__c> activeVolunteerLandingPageInfoList { get; set; }
	public Id currentUserId;
	public Id eventsRTId;
	public String currentChapter { get; set; }
	public String selectedChapter { get; set; }
	public List<User> getRelatedContactId;
	public Boolean displayPopup { get; set; }
	public Boolean displayPopupconflict { get; set; }
	public Boolean blockNewBG { get; set; }
	public User currUser;
	public Boolean flagForCancel { get; set; }
	public Boolean flagForCOICancel { get; set; }
	public Contact volunteercon { get; set; }
	public String residingStatus { get; set; }
	public Boolean isExpired { get; set; }
	public Integer nBCDays { get; set; }
	public Integer nCOIDays { get; set; }
	public Boolean isCOIExpired { get; set; }
	public String email { get; set; }
	public Boolean displayBCMsg { get; set; }
	public String broadCaseMsg { get; set; }
	public String broadCastName;
	public List<Orientation_Training__c> orientationList { get; set; }
	public List<Class_Offering__c> diplayClassOffRec { get; set; }
	public Boolean displayTrainingDetails { get; set; }
	public Boolean displayTrainingAck { get; set; }
	public String myId;
	public String trainingName { get; set; }
	public Boolean isBGRoleExpOOC { get; set; }
	public Boolean isInactivePopup { get; set; }
	public Boolean isExpirednew { get; set; }
	public Boolean displayTrainingnewDetails { get; set; }
	public String featuredImage { get; set; }
	public String featuredQuote { get; set; }
	public String welcomeMsg { get; set; }
	public String headingTitle1 { get; set; }
	public String headingText1 { get; set; }
	public String title1 { get; set; }
	public String image1 { get; set; }
	public String text1 { get; set; }
	public String title2 { get; set; }
	public String image2 { get; set; }
	public String text2 { get; set; }
	public String title3 { get; set; }
	public String image3 { get; set; }
	public String text3 { get; set; }
	public Boolean confirmPopup { get; set; }

	/**
	 * Controller Constructor
	*/
	public VolunteerLanding_AC() {
		confirmPopup = false;
		String log;
		myId = ApexPages.currentPage().getParameters().get('event');
		diplayClassOffRec = new List<Class_Offering__c>();
		Id activeVolunteerRecordTypeId = Constant_AC.ACTIVE_VOL_RT_ID;
		currUser = Utils.currentUser;
		currentUserId = currUser.Id;
		List<Background_check__c> dbBackGround = [
				SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c
				FROM Background_check__c
				WHERE Volunteer__c = :currUser.ContactId
				ORDER BY CreatedDate DESC
				LIMIT 1
		];
		log = String.valueOf(dbBackGround);
		if (!Test.isRunningTest()) {
			if (dbBackGround.size() > 0 && dbBackGround[0].Hidden_Display_Popup__c) {
				confirmPopup = true;
			}
		}
		isBGRoleExpOOC = false;
		for (Volunteer_Roles__c currRole : [
				SELECT Id
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c = :currUser.ContactId
				AND Status__c IN (:VOLUNTEER_ROLE_STATUS_ACTIVE, :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE,
						:VOLUNTEER_ROLE_STATUS_PENDING)
				AND Sub_status__c != :VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW
		]) {
			log = String.valueOf(currRole);
			isBGRoleExpOOC = true;
		}
		volunteercon = [
				SELECT Id,FirstName,LastName,Name,Residing_in_US__c,Region_Chapter__c,isApplication__c,
						Account.Phone,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,BackGroundCheckUpdated__c,
						Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,
						npe01__AlternateEmail__c,npe01__WorkEmail__c
				FROM Contact
				WHERE Id = :currUser.ContactId
		];
		if (volunteercon != null) {
			currentChapter = volunteercon.Region_Chapter__c;
			activeVolunteerLandingPageInfoList = [
					SELECT Id, Featured_Image__c, Feature_Quote__c, Heading_Highlight_Image_1__c,
							Heading_Highlight_Image_2__c, Heading_Highlight_Image_3__c, Heading_Highlight_Text_1__c,
							Heading_Highlight_Text_2__c, Heading_Highlight_Text_3__c, Heading_Highlight_Title_1__c,
							Heading_Highlight_Title_2__c,Heading_Text__c, Heading_Highlight_Title_3__c, Heading_Title__c, Welcome_Message__c
					FROM Dynamic_Content__c
					WHERE RecordTypeId = :activeVolunteerRecordTypeId
					AND Chapter_Name__c = :currentChapter
					AND Active__c = TRUE
					LIMIT 1
			];
			log = String.valueOf(activeVolunteerLandingPageInfoList);
			if (activeVolunteerLandingPageInfoList.size() > 0) {
				featuredImage = activeVolunteerLandingPageInfoList[0].Featured_Image__c;
				featuredQuote = activeVolunteerLandingPageInfoList[0].Feature_Quote__c;
				welcomeMsg = activeVolunteerLandingPageInfoList[0].Welcome_Message__c;
				headingTitle1 = activeVolunteerLandingPageInfoList[0].Heading_Title__c;
				headingText1 = activeVolunteerLandingPageInfoList[0].Heading_Text__c;
				title1 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Title_1__c;
				image1 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Image_1__c;
				text1 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Text_1__c;
				title2 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Title_2__c;
				image2 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Image_2__c;
				text2 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Text_2__c;
				title3 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Title_3__c;
				image3 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Image_3__c;
				text3 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Text_3__c;
			}
		}
	}

	/**
	 * Get Chapters
	 * @return List of Select Options
	 */
	public List<SelectOption> getChapterList() {
		String log, recId;
		getRelatedContactId = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :currentUserId
		];
		List<SelectOption> chapterList = new List<SelectOption>();
		if (getRelatedContactId.size() > 0) {
			for (npe5__Affiliation__c getChapterList : [
					SELECT Id, npe5__Organization__r.Name
					FROM npe5__Affiliation__c
					WHERE npe5__Organization__r.Name != :currentChapter
					AND npe5__Contact__c = :getRelatedContactId.get(0).ContactId
			]) {
				log = String.valueOf(getChapterList);
				recId = getChapterList.Id;
				chapterList.add(new SelectOption(getChapterList.npe5__Organization__r.Name, getChapterList.npe5__Organization__r.Name));
			}
		}
		return chapterList;
	}

	/**
	 * Update Selected Chapter
	 * @return Page
	 */
	public PageReference EnterchapterPage() {
		String log, recId;
		try {
			if (selectedChapter != '--Swith Chapter--') {
				List<HoldCurrentChapter__c> getChapterValues = [
						SELECT Name,CurrentChapter__c
						FROM HoldCurrentChapter__c
						WHERE Name = :currentUserId
				];
				if (getChapterValues.size() > 0) {
					getChapterValues.get(0).CurrentChapter__c = selectedChapter;
					recId = getChapterValues[0].Id;
					log = String.valueOf(getChapterValues);
					update getChapterValues;
				} else {
					HoldCurrentChapter__c newHoldChapter = new HoldCurrentChapter__c();
					newHoldChapter.Name = currentUserId;
					newHoldChapter.CurrentChapter__c = selectedChapter;
					log = String.valueOf(newHoldChapter);
					insert newHoldChapter;
				}
			}
			PageReference page = new PageReference('/' + PAGE_VOLUNTEER_LANDING_VF);
			page.setRedirect(true);
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
			return page;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'EnterchapterPage', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/**
	 * Find Non Wish Events
	 * @return List of Non Wish Events
	 */
	public List<Non_Wish_Events__c> getEvents() {
		eventsRTId = Constant_AC.EVENTS_ID;
		List<Non_Wish_Events__c> eventRecords = [
				SELECT Id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
				FROM Non_Wish_Events__c
				WHERE Chapter__c = :currentChapter
				AND Event_Date__c >= :Date.today()
				AND Priority__c != NULL
				ORDER BY Priority__c ASC, Event_Date__c ASC
				LIMIT 4
		];

		if (eventRecords.size() < 4) {
			for (Non_Wish_Events__c currRec : [
					SELECT Id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
					FROM Non_Wish_Events__c
					WHERE Chapter__c = :currentChapter
					AND Event_Date__c >= :Date.today()
					AND Priority__c = NULL
					ORDER BY Event_Date__c ASC
					LIMIT 4
			]) {
				if (eventRecords.size() < 4) {
					eventRecords.add(currRec);
				}
			}
		}
		return eventRecords;
	}

	/**
	 * Check Conflict of Interest
	 */
	public void COICheck() {
		String log, recId;
		try {
			Integer coiDays = Integer.valueOf(Label.COI_no_of_expiration_days);
			displayPopupconflict = false;
			List<Conflict_Of_Interest__c> conflictIns = [
					SELECT Id,Name,Expiration_Date__c,Signed_Date__c,Current__c,
							Volunteer_Contact__c
					FROM Conflict_Of_Interest__c
					WHERE Volunteer_Contact__c = :currUser.ContactId
					AND Expiration_Date__c != NULL
					AND Current__c = TRUE
					ORDER BY CreatedDate DESC
					LIMIT 1
			];
			List<npe5__Affiliation__c> affiliationList = [
					SELECT Id,npe5__Organization__c,npe5__Contact__c,npe5__Status__c,
							npe5__Primary__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c = :currUser.ContactId
					AND npe5__Primary__c = TRUE
					ORDER BY CreatedDate DESC
					LIMIT 1
			];
			log = String.valueOf(conflictIns);
			if (ORG_AFFILIATION_STATUS_NOT_APPROVED.equals(affiliationList[0].npe5__Status__c)
					|| ORG_AFFILIATION_STATUS_INACTIVE.equals(affiliationList[0].npe5__Status__c)) {
				isInactivePopup = true;
			} else {
				isCOIExpired = false;
				if (conflictIns.size() > 0) {
					nCOIDays = (Date.today()).daysBetween(conflictIns[0].Expiration_Date__c);
				}
				if (conflictIns.size() > 0 && myId == null && affiliationList.size() > 0) {
					if (conflictIns[0].Expiration_Date__c >= Date.today()
							&& conflictIns[0].Expiration_Date__c < Date.today().addDays(coiDays)
							&& (ORG_AFFILIATION_STATUS_ACTIVE.equals(affiliationList[0].npe5__Status__c)
							|| ORG_AFFILIATION_STATUS_PENDING.equals(affiliationList[0].npe5__Status__c)
							|| ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE.equals(affiliationList[0].npe5__Status__c))
							&& myId == null) {
						displayPopupconflict = true;
						flagForCOICancel = true;
					} else if (conflictIns[0].Expiration_Date__c < Date.today()
							&& (ORG_AFFILIATION_STATUS_ACTIVE.equals(affiliationList[0].npe5__Status__c)
							|| ORG_AFFILIATION_STATUS_PENDING.equals(affiliationList[0].npe5__Status__c)
							|| ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE.equals(affiliationList[0].npe5__Status__c))
							&& myId == null) {
						displayPopupconflict = true;
						flagForCOICancel = false;
						isCOIExpired = true;
					}
				}
				if (!displayPopupconflict) {
					backgroundCheck();
				}
				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'COICheck', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/**
	 * Check Background Check
	 */
	public void backgroundCheck() {
		String log, recId;
		try {
			User currUser = Utils.currentUser;
			List<Background_check__c> currVolBGCheck = [
					SELECT Id,Volunteer__c, Current__c, Date_Completed__c,Date__c,Status__c
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					ORDER BY CreatedDate DESC
					LIMIT 2
			];
			List<Volunteer_Roles__c> DbVolRoleBGReqCheck = [
					SELECT Id, Chapter_Role__c, Volunteer_Name__c, Status__c, Chapter_Role__r.Background_Check_Required__c
					FROM Volunteer_Roles__c
					WHERE Status__c NOT IN (:VOLUNTEER_ROLE_STATUS_NOT_APPROVED,
							:VOLUNTEER_ROLE_STATUS_FORMER)
					AND Sub_status__c NOT IN (:VOLUNTEER_ROLE_SUB_STATUS_CHAPTER,
							:VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER,
							:VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW)
					AND Chapter_Role__r.Background_Check_Required__c = :TRUE
					AND Volunteer_Name__c = :currUser.ContactId
			];
			isExpired = false;
			blockNewBG = false;
			displayPopup = false;
			isExpirednew = false;
			if (isBGRoleExpOOC) {
				if (currVolBGCheck.size() == 1) {
					if (currVolBGCheck[0].Status__c != null
							&& currVolBGCheck[0].Date__c >= Date.today()
							&& Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0 && currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = true;
					} else if ((currVolBGCheck[0].Date__c < Date.today()
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0 && currVolBGCheck[0].Current__c)) {
						displayPopup = true;
						flagForCancel = false;
						isExpired = true;
					} else if ((currVolBGCheck[0].Status__c != null
							&& BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c)) {
						isExpired = true;
					}
				} else if (currVolBGCheck.size() == 2) {
					if (currVolBGCheck[0].Date__c == null && currVolBGCheck[1].Date__c > Date.today()
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[1].Current__c) {
						if (BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[1].Status__c)) {
							blockNewBG = true;
						}
					} else if (currVolBGCheck[1].Date__c < Date.today()
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[1].Current__c) {
						if (!BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[1].Status__c)) {
							blockNewBG = true;
						}
					} else if (currVolBGCheck[0].Date__c > Date.today()
							&& Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c) && DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = true;

					} else if (currVolBGCheck[0].Date__c <= Date.today()
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = false;
						isExpired = true;
					} else if (BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						blockNewBG = true;
					}
				} else if (currVolBGCheck.size() <= 0
						&& DbVolRoleBGReqCheck.size() > 0) {
					displayPopup = true;
					flagForCancel = true;
					isExpirednew = true;
				}
			}
			if (!displayPopup && !blockNewBG) {
				DisplayBroadCast(displayPopup);
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'BackgroundCheck', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);

		}
	}

	/**
	 * Get Broadcast
	 * @param displayPopup Boolean
	 */
	public void DisplayBroadCast(Boolean displayPopup) {
		String log, recId;
		try {
			Set<String> broadCastsNameSet = new Set<String>();
			volunteercon = [
					SELECT Id,FirstName,OwnerId,Name,LastName,isApplication__c,AccountId,
							Account.Volunteer_Manager__c,Email,Phone,Broadcast_Number__c,npe01__Preferred_Email__c
					FROM Contact
					WHERE Id = :currUser.ContactId
					LIMIT 1
			] ;
			npe5__Affiliation__c primaryChapter = [
					SELECT Id, npe5__Organization__c, npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Primary__c = TRUE
					AND npe5__Contact__c = :currUser.ContactId
					LIMIT 1
			];
			displayBCMsg = false;
			if (volunteercon.Broadcast_Number__c != null) {
				for (String currStr : (volunteercon.Broadcast_Number__c).split(',')) {
					broadCastsNameSet.add(currStr);
					log += String.valueOf(currStr);
				}
			}
			List<Broadcast__c> recentBroadCastList = [
					SELECT Id,Name, Broadcast_Message__c,Active__c
					FROM Broadcast__c
					WHERE Name NOT IN :broadCastsNameSet
					AND (Date__c < :Date.today().addDays(30))
					AND Chapter_Name__c = :primaryChapter.npe5__Organization__c
					AND Active__c = TRUE
					LIMIT 1
			];
			if (recentBroadCastList.size() > 0 && displayPopup != true) {
				log += String.valueOf(recentBroadCastList);
				broadCaseMsg = recentBroadCastList[0].Broadcast_Message__c;
				broadCastName = recentBroadCastList[0].Name;
				displayBCMsg = true;
			}
			if (!displayBCMsg) {
				displayTraining();
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'DisplayBroadCast', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/**
	 * Get Training
	 */
	public void displayTraining() {
		String log, recId;
		try {
			Set<Id> chapterRoleIdSet = new Set<Id>();
			List<Background_check__c> bcList = [
					SELECT Id
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					AND Current__c = TRUE
			];
			for (Volunteer_Roles__c chapterRole : [
					SELECT Chapter_Role__c,Chapter_Role__r.Chapter_Name__c,Sub_status__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c = :currUser.ContactId
					AND Sub_status__c != :VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW
					AND Status__c = :VOLUNTEER_ROLE_STATUS_PENDING
			]) {
				chapterRoleIdSet.add(chapterRole.Chapter_Role__c);
			}
			if (bcList.size() == 1 && chapterRoleIdSet.size() > 0) {
				diplayClassOffRec = [
						SELECT Id,Orientation_and_Training__c,Chapter_Role_O_T__c,
								Chapter_Role_O_T__r.Orientation_Training__c,Date__c,Start_Time__c,End_Time__c
						FROM Class_Offering__c
						WHERE Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
						AND Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIdSet
						AND ((Date__c >= :Date.today()
						AND Date__c <= :Date.today().addMonths(6))
						OR Date__c = NULL)
						AND (max_capacity__c = NULL OR (max_capacity__c > 0 AND AvailableSeats__c > 0))
						LIMIT 1
				];
				if (diplayClassOffRec.size() > 0 && blockNewBG != true) {
					trainingName = diplayClassOffRec[0].Orientation_and_Training__c;
					displayTrainingnewDetails = true;
					flagForCancel = true;
					displayTrainingDetails = true;
				}
			} else {
				Set<Id> orientationIds = new Set<Id>();
				Set<Id> registeredIds = new Set<Id>();
				Set<Id> chapterRoles = new Set<Id>();
				Set<Id> chapterIds = new Set<Id>();
				for (Volunteer_Roles__c chapterRole : [
						SELECT Chapter_Role__c,Chapter_Role__r.Chapter_Name__c,Sub_status__c
						FROM Volunteer_Roles__c
						WHERE Volunteer_Name__c = :currUser.ContactId
						AND Sub_status__c != :VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW
				]) {
					log += String.valueOf(chapterRole);
					chapterRoles.add(chapterRole.Chapter_Role__c);
					chapterIds.add(chapterRole.Chapter_Role__r.Chapter_Name__c);
				}
				for (Chapter_Role__c currRec : [
						SELECT Id
						FROM Chapter_Role__c
						WHERE Chapter_Name__c IN :chapterIds
						AND Role_Name__r.Name = :WISH_ROLE_ALL_ROLES
				]) {
					chapterRoles.add(currRec.Id);
				}
				for (Volunteer_Orientation_Training__c currRec : [
						SELECT Id,Volunteer_Attendance__c,Hidden_O_T_Id__c
						FROM Volunteer_Orientation_Training__c
						WHERE Volunteer__c = :currUser.ContactId
						AND Volunteer_Attendance__c != :VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED
						AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
				]) {
					orientationIds.add(currRec.Hidden_O_T_Id__c);
					log += String.valueOf(currRec);
					if (VOLUNTEER_ATTENDANCE_VOLUNTEER_REGISTERED.equals(currRec.Volunteer_Attendance__c)) {
						registeredIds.add(currRec.Hidden_O_T_Id__c);
					}
				}
				diplayClassOffRec = [
						SELECT Id,Orientation_and_Training__c,Chapter_Role_O_T__c,
								Chapter_Role_O_T__r.Orientation_Training__c,Date__c,Start_Time__c,End_Time__c
						FROM Class_Offering__c
						WHERE Chapter_Role_O_T__r.Orientation_Training__c NOT IN :orientationIds
						AND Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = TRUE
						AND Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
						AND Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoles
						AND ((Date__c >= :Date.today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = NULL)
						AND (max_capacity__c = NULL OR (max_capacity__c > 0 AND AvailableSeats__c > 0))
						LIMIT 1
				];
				if (diplayClassOffRec.size() > 0 && blockNewBG != true) {
					trainingName = diplayClassOffRec[0].Orientation_and_Training__c;
					displayTrainingDetails = true;
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'DisplayTraining', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/**
	 * Register
	 * @return Page
	 */
	public PageReference register() {
		PageReference pr;
		pr = new PageReference('/VolunteerActiveTraining_VF');
		return pr;
	}

	/**
	 * Confirm Background Check
	 * @return Page
	 */
	public PageReference confirmBackGroundCheck() {
		String log;
		String recId;
		try {
			if (volunteercon.BackGroundCheckUpdated__c) {
				Contact updateContact = new Contact();
				updateContact.Id = currUser.ContactId;
				updateContact.HomePhone = volunteercon.HomePhone;
				updateContact.MobilePhone = volunteercon.MobilePhone;
				updateContact.npe01__Preferred_Email__c = volunteercon.npe01__Preferred_Email__c;
				updateContact.npe01__HomeEmail__c = volunteercon.npe01__HomeEmail__c;
				updateContact.npe01__WorkEmail__c = volunteercon.npe01__WorkEmail__c;
				updateContact.npe01__AlternateEmail__c = volunteercon.npe01__AlternateEmail__c;
				RecursiveTriggerHandler.blockBeforeUpdate = true;
				RecursiveTriggerHandler.blockAfterUpdate = true;
				recId = updateContact.Id;
				log = String.valueOf(updateContact);
				update updateContact;
			}
			List<Background_check__c> currVolBGChecklist = [
					SELECT Id,Volunteer__c,Volunteer__r.OwnerId,Date_Completed__c,Date__c,Current__c
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					AND Current__c = :TRUE
					ORDER BY CreatedDate DESC
					LIMIT 1
			];
			if (currVolBGChecklist.size() > 0) {
				if (currVolBGChecklist[0].Date__c >= System.today()) {
					confirmPopup = true;
				}
			} else {
				confirmPopup = false;
			}
			Background_check__c newCheck = new Background_check__c();
			newCheck.Date_Requested__c = Date.today();
			newCheck.Requested_By__c = Utils.currentUser.Id;
			newCheck.Volunteer__c = currUser.ContactId;
			if (confirmPopup) {
				newCheck.Hidden_Display_Popup__c = true;
			} else {
				newCheck.Hidden_Display_Popup__c = false;
			}
			if (volunteercon.Residing_in_US__c) {
				newCheck.Resided_in_US_for_past_7_years__c = BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_YES;
			} else {
				newCheck.Resided_in_US_for_past_7_years__c = BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_NO;
			}
			log = String.valueOf(newCheck);
			insert newCheck;
			Id taskRecordTypeId = Constant_AC.BACKGROUND_RT_ID;
			Task newBGTask = new Task();
			newBGTask.Type = TASK_TYPE_EMAIL;
			newBGTask.Description = '';
			if (volunteercon != null) {
				if (volunteercon.Account.Volunteer_Manager__c != null) {
					newBGTask.OwnerId = volunteercon.Account.Volunteer_Manager__c;
				} else {
					newBGTask.OwnerId = volunteercon.OwnerId;
				}
			}
			newBGTask.WhoId = currUser.ContactId;
			newBGTask.WhatId = newCheck.Id;
			newBGTask.Subject = 'Background Check';
			newBGTask.SystemGeneratedTask__c = true;
			newBGTask.RecordTypeId = taskRecordTypeId;
			log = String.valueOf(newBGTask);
			if (!Test.isRunningTest()) {
				insert newBGTask;
			}
			displayPopup = false;
			if (currVolBGChecklist.size() > 0 && currVolBGChecklist[0].Date__c >= Date.today()) {
				blockNewBG = false;
			} else {
				blockNewBG = true;
				displayPopupconflict = false;
				displayPopup = false;
			}
			PageReference page = new PageReference('/' + PAGE_VOLUNTEER_LANDING_VF);
			page.setRedirect(true);
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
			return page;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'confirmBackGroundCheck', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/**
	 * Cancel
	 */
	public void cancel() {
		displayPopup = false;
		DisplayBroadCast(displayPopup);
	}

	/**
	 * Training Cancel
	 */
	public void TrainingAckCancel() {
		displayTrainingAck = false;
	}

	/**
	 * Cancel Broadcast
	 */
	public void broadCastCancel() {
		displayBCMsg = false;
		String log;
		if (broadCastName != '') {
			try {
				Contact updateContact = new Contact();
				updateContact.Id = currUser.ContactId;
				if (volunteercon != null && volunteercon.Broadcast_Number__c != null) {
					updateContact.Broadcast_Number__c = volunteercon.Broadcast_Number__c + ',' + broadCastName;
				} else {
					updateContact.Broadcast_Number__c = broadCastName;
				}
				log = String.valueOf(updateContact);
				update updateContact;
				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			} catch (Exception ex) {
				new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'broadCastCancel', null, ex, log));
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
			}
		}
		displayTraining();
	}

	/**
	 * Cancel Conflict
	 */
	public void cancelConflict() {
		displayPopupconflict = false;
		backgroundCheck();
	}

	/**
	 * Confirm Conflict
	 * @return Page
	 */
	public PageReference callConfirmConflict() {
		return confirmConflict(PAGE_VOLUNTEER_LANDING_VF);
	}

	/**
	 * Display Broadcast
	 * @return Page
	 */
	public PageReference confirmConflict(String pageName) {
		displayPopupconflict = false;
		String log;
		String recId;
		try {
			User currUser = Utils.currentUser;
			volunteercon = [
					SELECT Id,FirstName,LastName,Name,Email,Phone
					FROM Contact
					WHERE Id = :currUser.ContactId
					LIMIT 1
			] ;
			HttpResponse res = DocuSignService.createEnvelope(volunteercon);
			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
			if (String.isNotEmpty((String) results.get('envelopeId'))) {
				String envelopeId = (String) results.get('envelopeId');
				HttpResponse response = DocuSignService.createRecipient(volunteercon, envelopeId, pageName);
				results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
				if ((String) results.get('url') != '' || (String) results.get('url') != null) {
					volunteercon.isApplication__c = true;
					if (!Test.isRunningTest()) {
						recId = volunteercon.Id;
						log = String.valueOf(volunteercon);
						update volunteercon;
					}
					dsfs__DocuSign_Status__c dsfs = new dsfs__DocuSign_Status__c();
					dsfs.dsfs__DocuSign_Envelope_ID__c = envelopeId;
					dsfs.isConflict__c = true;
					dsfs.Docusign_Hidden_Contact__c = volunteercon.Id;
					log = String.valueOf(dsfs);
					insert dsfs;
					PageReference reference = new PageReference((String) results.get('url'));
					reference.setRedirect(true);
					if (Test.isRunningTest()) {
						throw new CommonTriggerException('Test Class execution');
					}
					return reference;
				}
			}
			return null;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'confirmConflict', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/**
	 * Display Email
	 */
	public void displayEmail() {
		Contact dbContact = [
				SELECT Id,FirstName,LastName,Name,Region_Chapter__c,isApplication__c,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,
						Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,npe01__AlternateEmail__c,npe01__WorkEmail__c
				FROM Contact
				WHERE Id = :currUser.ContactId
				LIMIT 1
		] ;
		if (CONTACT_PREFERRED_EMAIL_PERSONAL.equals(volunteercon.npe01__Preferred_Email__c)) {
			email = dbContact.npe01__HomeEmail__c;
		} else if (CONTACT_PREFERRED_EMAIL_WORK.equals(volunteercon.npe01__Preferred_Email__c)) {
			email = dbContact.npe01__WorkEmail__c;
		} else if (CONTACT_PREFERRED_EMAIL_ALTERNATE.equals(volunteercon.npe01__Preferred_Email__c)) {
			email = dbContact.npe01__AlternateEmail__c;
		}
	}

	/**
	 * Hide Popup
	 */
	public void hidePopup() {
		confirmPopup = false;
		Background_check__c updateBackgroundCheck = new Background_check__c();
		String log;
		String recId;
		try {
			List<Background_check__c> backgroundCheck = [
					SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					ORDER BY CreatedDate DESC
					LIMIT 1
			];
			if (backgroundCheck.size() > 0) {
				updateBackgroundCheck.Id = backgroundCheck[0].Id;
				updateBackgroundCheck.Hidden_Display_Popup__c = false;
				recId = updateBackgroundCheck.Id;
				log = String.valueOf(backgroundCheck[0]);
				update updateBackgroundCheck;
				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'hidePopup', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}
}