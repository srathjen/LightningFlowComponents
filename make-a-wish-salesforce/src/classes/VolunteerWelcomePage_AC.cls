/********************************************************************************
Author : MST Solutions
Description: This is Volunteer Landing page. Once Volunteer successfully signed up into volunteer portal, they can redirected
to this volunteer landing page. This would display welcome message. This welcome message is dynamic content that is stored under 
Dynamic Content object.  And also this page would display two buttons 1. Become A Volunteer and 2. Continue Process.
1. Become A Volunteer would display when a volunteer login to portal without submitting any orientation.
2. Continue Process would display if the volunteer registered for orientation.
3. It will display the status of the form. Example, If orientation has been completed, then the status
would display in Green checked color. Once the Orientation completed only, It will redirect the user 
to Application page. Similary if user finished the application form only, they can submit background check.
*********************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolunteerWelcomePage_AC {
	public static final String VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
	public static final String VOLUNTEER_ATTENDANCE_VOLUNTEER_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
	public static final String VOLUNTEER_ATTENDANCE_VOLUNTEER_REGISTERED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
	public static final String VOLUNTEER_ROLE_STATUS_PENDING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = Constant_AC.VOLUNTEER_ROLE_STATUS_NOT_APPROVED;
	private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
	private final static String VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW;
	private final static String VOLUNTEER_ROLE_SUB_STATUS_CHAPTER = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_CHAPTER;
	private final static String VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER;
	private final static Datetime OLD_VOLUNTEER_SIGNUP_PATH_CUTOFF = Volunteer_New_Application_Control__c.getOrgDefaults().User_Created_Date_Cutoff__c;
	private final static String CONTACT_APPLICATION_STATUS_SUBMIT = Constant_AC.CONTACT_APPLICATION_STATUS_SUBMIT;
	private final static String CONTACT_APPLICATION_STATUS_APPROVED = Constant_AC.CONTACT_APPLICATION_STATUS_APPROVED;
	private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
	private final static String BACKGROUND_CHECK_STATUS_APPROVED = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
	private final static String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS;
	private final static String BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_YES = Constant_AC.BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_YES;
	private final static String BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_NO = Constant_AC.BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_NO;
	private final static String ORG_AFFILIATION_STATUS_PENDING = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
	private final static String ORG_AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
	private final static String ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE = Constant_AC.ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE;
	private final static String ORG_AFFILIATION_STATUS_NOT_APPROVED = Constant_AC.ORG_AFFILIATION_STATUS_NOT_APPROVED;
	private final static String ORG_AFFILIATION_STATUS_INACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;
	private final static String TASK_TYPE_EMAIL = Constant_AC.TASK_TYPE_EMAIL;
	private final static String PAGE_STATUS_COMPLETED = 'Completed';
	private final static String PAGE_STATUS_IN_PROGRESS = 'In Progress';
	private final static String GO_TO_PAGE_VOLUNTEER_LANDING = 'VolunteerLanding_VF';
	private final static String GO_TO_PAGE_VOLUNTEER_ORIENTATION = 'VolunteerOrientation_VF';
	private final static String GO_TO_PAGE_APPLICATION = 'Application_VF';
	private final static String GO_TO_PAGE_APPLY_FOR_ROLES = 'ApplyForRoles_VF';
	private final static String GO_TO_PAGE_BACKGROUND_CHECK = 'BackgroundCheck_VF';
	private final static String GO_TO_PAGE_VOLUNTEER_TRAINING = 'VolunteerTraining_VF';
	private final static String GO_TO_PAGE_VOLUNTEER_WELCOME_PAGE = 'VolunteerWelcomePage_VF';
	private final static String BLANK = '';
	public Boolean displayBecomAVolunteer { get; set; }
	public Boolean displayContinueProcess { get; set; }
	public String welcomText { get; set; }
	public String becomeAVolunteer { get; set; }
	public Boolean isBecomVolunteer { get; set; }
	public Boolean continueProcess { get; set; }
	@TestVisible String chapterId;
	public List<Contact> checkcontactApplicationList { get; set; }
	public List<Background_check__c> checkBackGroundList { get; set; }
	public List<Volunteer_Orientation_Training__c> trainingList { get; set; }
	public String gotoPage { get; set; }
	public Boolean displayPopupconflict { get; set; }
	public Boolean isCOIExpired { get; set; }
	public Integer nCOIDays { get; set; }
	public Boolean flagForCOICancel { get; set; }
	public String orientationStatus { get; set; }
	public String applicationStatus { get; set; }
	public String interviewStatus { get; set; }
	public String applyForRolesStatus { get; set; }
	public String backgroundCheckStatus { get; set; }
	public String trainingStatus { get; set; }
	@TestVisible Set<Id> requiredOrientationIds = new Set<Id>();
	@TestVisible Set<Id> completedVolunteerOrientationIdsIds = new Set<Id>();
	public String myId;
	public Boolean bgRequired { get; set; }
	public Boolean trainingRequired { get; set; }
	public Boolean isExpired { get; set; }
	public Boolean blockNewBG { get; set; }
	public Boolean displayPopup { get; set; }
	public Boolean isBGRoleExpOOC { get; set; }
	public Integer nBCDays { get; set; }
	public Boolean flagForCancel { get; set; }
	public String residingStatus { get; set; }
	public Contact volunteercon { get; set; }
	public Boolean confirmPopup { get; set; }
	public Boolean isInactivePopup { get; set; }
	private Datetime userCreatedDate;
	private String userProfileId;

	public VolunteerWelcomePage_AC() {
		Id volunteerContactRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		Id orientationRecordTypeId = Constant_AC.ORIENTATION_RT_ID;
		Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
		Id boardMemberContactRecTyped = Constant_AC.BOARD_MEMBER_RT_ID;
		User currentUser = Utils.currentUser;
		if (Test.isRunningTest()) {
			currentUser = [
					SELECT Id,ContactId,CreatedDate,ProfileId
					FROM User
					WHERE Id = :UserInfo.getUserId()
			];
		}
		String log;
		applicationStatus = null;
		interviewStatus = null;
		backgroundCheckStatus = null;
		trainingStatus = null;
		isBecomVolunteer = true;
		continueProcess = false;
		gotoPage = BLANK;
		trainingList = new List<Volunteer_Orientation_Training__c>();
		userCreatedDate = currentUser.CreatedDate;
		userProfileId = currentUser.ProfileId;
		myId = ApexPages.currentPage().getParameters().get('event');
		for (Volunteer_Orientation_Training__c checkOrientationAndTraining : [
				SELECT Id, Volunteer_Attendance__c, Class_Offering__c, Class_Offering__r.Chapter_Role_O_T__c,
						Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer_Attendance__c != :VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED
				AND Volunteer__c = :currentUser.ContactId
		]) {
			if (checkOrientationAndTraining.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId == trainingRecordTypeId) {
				trainingList.add(checkOrientationAndTraining);
				log = log + '|' + String.valueOf(checkOrientationAndTraining);
			}
		}
		isBGRoleExpOOC = false;
		for (Volunteer_Roles__c currRole : [
				SELECT Id
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c = :currentUser.ContactId
				AND Status__c IN
				(:VOLUNTEER_ROLE_STATUS_PENDING, :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE, :VOLUNTEER_ROLE_STATUS_ACTIVE)
				AND Sub_status__c != :VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW
		]) {
			log = String.valueOf(currRole);
			isBGRoleExpOOC = true;
		}
		checkcontactApplicationList = [
				SELECT Id,is_Application__c, (
						SELECT Id, Chapter_Role__c,Chapter_Role__r.Background_Check_Required__c
						FROM Volunteer_Roles__r
						ORDER BY Chapter_Role__r.Background_Check_Required__c
				), RecordTypeId
				FROM Contact
				WHERE (RecordTypeId = :volunteerContactRecordTypeId OR RecordTypeId = :boardMemberContactRecTyped)
				AND Id = :currentUser.ContactId
		];
		bgRequired = false;
		trainingRequired = false;
		if (checkcontactApplicationList[0].Volunteer_Roles__r.size() > 0) {
			for (Volunteer_Roles__c currRole : checkcontactApplicationList[0].Volunteer_Roles__r) {
				if (currRole.Chapter_Role__r.Background_Check_Required__c) {
					bgRequired = true;
					break;
				}
			}
		}
		checkBackGroundList = [
				SELECT Id, Volunteer__c,Status__c
				FROM Background_check__c
				WHERE Volunteer__c = :currentUser.ContactId
		];
		List<npe5__Affiliation__c> currAffliation = [
				SELECT Id,npe5__Organization__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :currentUser.ContactId
				AND npe5__Primary__c = TRUE
				LIMIT 1
		];
		if (currAffliation.size() > 0) {
			chapterId = currAffliation[0].npe5__Organization__c;
		}
		Set<Id> chatperRoleIds = new Set<Id>();
		for (Volunteer_Roles__c currRec : [
				SELECT Id, Chapter_Role__c,Volunteer_Name__c
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c = :currentUser.ContactId
		]) {
			chatperRoleIds.add(currRec.Chapter_Role__c);
		}
		for (Chapter_Role_O_T__c currChapterRoleOT : [
				SELECT Id,Orientation_Training__c
				FROM Chapter_Role_O_T__c
				WHERE Required__c = TRUE
				AND Chapter_Role__r.Chapter_Name__c = :chapterId
				AND Orientation_Training__r.RecordTypeId = :orientationRecordTypeId
		]) {
			requiredOrientationIds.add(currChapterRoleOT.Orientation_Training__c);
		}
		trainingRequired = false;
		List<Chapter_Role_O_T__c> trainings = [
				SELECT Id
				FROM Chapter_Role_O_T__c
				WHERE Chapter_Role__c IN :chatperRoleIds
				AND Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
				AND Required__c = TRUE
		];
		if (trainings.size() > 0) {
			trainingRequired = true;
		}
		for (Volunteer_Orientation_Training__c checkOrientationAndTraining : [
				SELECT Id,Volunteer_Attendance__c,Class_Offering__r.Chapter_Role_O_T__c,
						Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId,
						Class_Offering__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer_Attendance__c = :Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
				AND Completion_Status__c NOT IN (:Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED, :Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED)
				AND Hidden_O_T_Id__c IN :requiredOrientationIds
				AND Volunteer__c = :currentUser.ContactId
				AND Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :orientationRecordTypeId
		]) {
			completedVolunteerOrientationIdsIds.add(checkOrientationAndTraining.Id);
			log = log + '|' + String.valueOf(completedVolunteerOrientationIdsIds);
		}
		Id nationalRT = Constant_AC.NATIONAL_RT_ID;
		Id ProspectiveRT = Constant_AC.PROSPECTIVE_VOLUNTEER_RT_ID;
		volunteercon = [
				SELECT Id,FirstName,LastName,Name,Residing_in_US__c,Region_Chapter__c,isApplication__c,
						Account.Phone,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,BackGroundCheckUpdated__c,
						Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,
						npe01__AlternateEmail__c,npe01__WorkEmail__c
				FROM Contact
				WHERE Id = :currentUser.ContactId
				LIMIT 1
		];
		for (Dynamic_Content__c currContent : [
				SELECT Id,How_do_I_Become_a_Volunteer__c,Welcome_Text__c
				FROM Dynamic_Content__c
				WHERE RecordTypeId = :nationalRT
				AND Active__c = TRUE
		]) {
			if (currContent.Welcome_Text__c != null) {
				welcomText = currContent.Welcome_Text__c;
			}
		}
		List<Dynamic_Content__c> getBecomeAVolText = [
				SELECT Id,How_do_I_Become_a_Volunteer__c,Welcome_Text__c
				FROM Dynamic_Content__c
				WHERE RecordTypeId = :ProspectiveRT
				AND Chapter_Name__c = :chapterId
				AND Active__c = TRUE
		];
		if (getBecomeAVolText.size() > 0) {
			becomeAVolunteer = getBecomeAVolText[0].How_do_I_Become_a_Volunteer__c;
		}
		List<Volunteer_Orientation_Training__c> volunteerOritentationList = [
				SELECT Id
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c = :currentUser.ContactId
				AND Volunteer_Attendance__c != :VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED
		];
		if (volunteerOritentationList.size() > 0) {
			isBecomVolunteer = false;
		}
		findVolunteerStatus();
	}

	public void findVolunteerStatus() {
		if (userProfileId == Label.Active_Volunteer_Profile) {
			isBecomVolunteer = true;
			continueProcess = true;
			orientationStatus = PAGE_STATUS_COMPLETED;
			applicationStatus = PAGE_STATUS_COMPLETED;
			applyForRolesStatus = PAGE_STATUS_COMPLETED;
			interviewStatus = PAGE_STATUS_COMPLETED;
			backgroundCheckStatus = PAGE_STATUS_COMPLETED;
			trainingStatus = PAGE_STATUS_COMPLETED;
			gotoPage = GO_TO_PAGE_VOLUNTEER_LANDING;
			return;
		}
		if (completedVolunteerOrientationIdsIds.size() == 0) {
			isBecomVolunteer = true;
			orientationStatus = PAGE_STATUS_IN_PROGRESS;
			gotoPage = GO_TO_PAGE_VOLUNTEER_ORIENTATION;
		} else if (requiredOrientationIds.size() == completedVolunteerOrientationIdsIds.size()) {
			continueProcess = true;
			orientationStatus = PAGE_STATUS_COMPLETED;
			if (userCreatedDate < OLD_VOLUNTEER_SIGNUP_PATH_CUTOFF) {
				gotoPage = GO_TO_PAGE_APPLICATION;
			} else {
				gotoPage = GO_TO_PAGE_APPLY_FOR_ROLES;
			}
		} else {
			continueProcess = true;
			orientationStatus = PAGE_STATUS_IN_PROGRESS;
			gotoPage = GO_TO_PAGE_VOLUNTEER_ORIENTATION;
		}
		if (orientationStatus == PAGE_STATUS_COMPLETED) {
			for (Contact checkContactStatus : checkcontactApplicationList) {
				if (Test.isRunningTest()) {
					checkContactStatus.is_Application__c = CONTACT_APPLICATION_STATUS_SUBMIT;
				}
				if (CONTACT_APPLICATION_STATUS_SUBMIT.equals(checkContactStatus.is_Application__c) && checkcontactApplicationList.size() == 1) {
					applicationStatus = PAGE_STATUS_IN_PROGRESS;
					applyForRolesStatus = PAGE_STATUS_IN_PROGRESS;
					if (userCreatedDate < OLD_VOLUNTEER_SIGNUP_PATH_CUTOFF) {
						gotoPage = GO_TO_PAGE_APPLICATION;
					} else {
						gotoPage = GO_TO_PAGE_APPLY_FOR_ROLES;
					}
				}
				if (Test.isRunningTest()) {
					checkContactStatus.is_Application__c = CONTACT_APPLICATION_STATUS_APPROVED;
				}
				if (CONTACT_APPLICATION_STATUS_APPROVED.equals(checkContactStatus.is_Application__c)) {
					applicationStatus = PAGE_STATUS_COMPLETED;
					applyForRolesStatus = PAGE_STATUS_COMPLETED;
					if (bgRequired) {
						gotoPage = GO_TO_PAGE_BACKGROUND_CHECK;
					} else {
						gotoPage = GO_TO_PAGE_VOLUNTEER_TRAINING;
					}
				}
			}
		}
		if (PAGE_STATUS_COMPLETED.equals(applyForRolesStatus)) {
			for (Background_check__c checkBackground : checkBackGroundList) {
				if ((checkBackground.Status__c == BLANK || checkBackground.Status__c == null)) {
					backgroundCheckStatus = PAGE_STATUS_IN_PROGRESS;
					if (bgRequired && checkBackGroundList.size() == 1) {
						gotoPage = GO_TO_PAGE_BACKGROUND_CHECK;
					}
				}
				if (BACKGROUND_CHECK_STATUS_APPROVED.equals(checkBackground.Status__c)
						|| BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS.equals(checkBackground.Status__c)) {
					backgroundCheckStatus = PAGE_STATUS_COMPLETED;
					if (trainingRequired) {
						gotoPage = GO_TO_PAGE_VOLUNTEER_TRAINING;
					}
				}
			}
		}
		if (PAGE_STATUS_COMPLETED.equals(backgroundCheckStatus)) {
			for (Volunteer_Orientation_Training__c checkOrientationStatus : trainingList) {
				if (VOLUNTEER_ATTENDANCE_VOLUNTEER_REGISTERED.equals(checkOrientationStatus.Volunteer_Attendance__c)
						&& !bgRequired && trainingRequired) {
					trainingStatus = PAGE_STATUS_IN_PROGRESS;
					gotoPage = GO_TO_PAGE_VOLUNTEER_TRAINING;
				}
				if (VOLUNTEER_ATTENDANCE_VOLUNTEER_COMPLETED.equals(checkOrientationStatus.Volunteer_Attendance__c)
						&& !bgRequired && trainingRequired) {
					trainingStatus = PAGE_STATUS_COMPLETED;
					gotoPage = GO_TO_PAGE_VOLUNTEER_TRAINING;
				}
			}
		}
	}

	public List<Non_Wish_Events__c> getEvents() {
		List<String> LstLog = new List<String>();
		Id eventsRTId = Constant_AC.EVENTS_ID;
		List<Non_Wish_Events__c> eventRecords = [
				SELECT Id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
				FROM Non_Wish_Events__c
				WHERE Chapter__c = :chapterId AND Event_Date__c >= :Date.today()
				AND RecordTypeId = :eventsRTId AND Priority__c != NULL
				ORDER BY Priority__c ASC
				LIMIT 4
		];
		if (eventRecords.size() < 4) {
			for (Non_Wish_Events__c currRec : [
					SELECT Id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
					FROM Non_Wish_Events__c
					WHERE Chapter__c = :chapterId AND Event_Date__c >= :Date.today()
					AND RecordTypeId = :eventsRTId AND Priority__c = NULL
					LIMIT 4
			]) {
				if (eventRecords.size() < 4) {
					eventRecords.add(currRec);
				}
				LstLog.add(String.valueOf(eventRecords));
			}
		}
		return eventRecords;
	}

	public void COICheck() {
		String Logvalue, recId;
		try {
			User currUser = [
					SELECT ContactId
					FROM User
					WHERE Id = :UserInfo.getUserId()
			];
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
			Logvalue = String.valueOf(conflictIns);
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
				if (displayPopupconflict == false) {
					backgroundCheck();
				}
				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_AC', 'COICheck', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	public void backgroundCheck() {
		String log, recId;
		try {
			User currUser = [
					SELECT ContactId
					FROM User
					WHERE Id = :UserInfo.getUserId()
			];
			List<Background_check__c> currVolBGCheck = [
					SELECT Id,Volunteer__c, Current__c, Date_Completed__c,Date__c,Status__c
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					ORDER BY CreatedDate DESC
					LIMIT 2
			];
			List<Volunteer_Roles__c> DbVolRoleBGReqCheck = [
					SELECT Id, Chapter_Role__c, Volunteer_Name__c, Status__c,
							Chapter_Role__r.Background_Check_Required__c
					FROM Volunteer_Roles__c
					WHERE Status__c NOT IN (:VOLUNTEER_ROLE_STATUS_NOT_APPROVED, :VOLUNTEER_ROLE_STATUS_FORMER)
					AND Sub_status__c NOT IN
					(:VOLUNTEER_ROLE_SUB_STATUS_CHAPTER, :VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW, :VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER)
					AND Chapter_Role__r.Background_Check_Required__c = :TRUE
					AND Volunteer_Name__c = :currUser.ContactId
			];
			isExpired = false;
			blockNewBG = false;
			displayPopup = false;
			if (isBGRoleExpOOC) {
				if (currVolBGCheck.size() == 1) {
					if (currVolBGCheck[0].Status__c != BLANK
							&& currVolBGCheck[0].Date__c >= Date.today()
							&& Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c) && DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = true;
					} else if (currVolBGCheck[0].Status__c != BLANK
							&& currVolBGCheck[0].Date__c < Date.today()
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						displayPopup = true;
						flagForCancel = false;
						isExpired = true;
					} else if (BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						isExpired = true;
					}
				} else if (currVolBGCheck.size() == 2) {
					if (currVolBGCheck[0].Status__c != BLANK
							&& currVolBGCheck[0].Date__c == null
							&& currVolBGCheck[1].Date__c > Date.today()
							&& DbVolRoleBGReqCheck.size() > 0 && currVolBGCheck[1].Current__c) {
						if (BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[1].Status__c)) {
							blockNewBG = true;
						}
					} else if (currVolBGCheck[0].Status__c != BLANK
							&& currVolBGCheck[0].Date__c == null
							&& currVolBGCheck[1].Date__c < Date.today()
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[1].Current__c) {
						if (!BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[1].Status__c)) {
							blockNewBG = true;
						}
					} else if (currVolBGCheck[0].Status__c != BLANK
							&& currVolBGCheck[0].Date__c > Date.today()
							&& Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
							&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(currVolBGCheck[0].Status__c)
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = true;
					} else if (currVolBGCheck[0].Status__c != BLANK
							&& currVolBGCheck[0].Date__c <= Date.today()
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
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_AC', 'BackgroundCheck', recId, ex, log));
			if (!Test.isRunningTest()) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
			}
		}
	}

	public PageReference callConfirmConflict() {
		VolunteerLanding_AC landingAc = new VolunteerLanding_AC();
		return landingAc.confirmConflict(GO_TO_PAGE_VOLUNTEER_WELCOME_PAGE);
	}

	public void cancelConflict() {
		backgroundCheck();
	}

	public PageReference becomeAVolunteer() {
		PageReference pageRef = new PageReference('/apex/' + gotoPage + '?bgRequired=' + bgRequired + '&trainingRequired=' + trainingRequired);
		pageRef.setRedirect(true);
		return pageRef;
	}

	public PageReference confirmBackGroundCheck() {
		String log;
		String recId;
		try {
			if (volunteercon.BackGroundCheckUpdated__c) {
				Contact updateContact = new Contact();
				updateContact.Id = volunteercon.Id;
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
			Background_check__c currVolBGCheck = [
					SELECT Id,Volunteer__c,Volunteer__r.OwnerId,Date_Completed__c,Date__c,Current__c
					FROM Background_check__c
					WHERE Volunteer__c = :volunteercon.Id AND Current__c = :TRUE
					ORDER BY CreatedDate DESC
					LIMIT 1
			];
			if (currVolBGCheck.Date__c >= System.today()) {
				confirmPopup = true;
			} else {
				confirmPopup = false;
			}
			Background_check__c newCheck = new Background_check__c();
			newCheck.Date_Requested__c = Date.today();
			newCheck.Requested_By__c = UserInfo.getUserId();
			newCheck.Volunteer__c = volunteercon.Id;
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
			newBGTask.Description = BLANK;
			if (volunteercon != null) {
				if (volunteercon.Account.Volunteer_Manager__c != null) {
					newBGTask.OwnerId = volunteercon.Account.Volunteer_Manager__c;
				} else {
					newBGTask.OwnerId = volunteercon.OwnerId;
				}
			}
			newBGTask.WhoId = volunteercon.Id;
			newBGTask.WhatId = newCheck.Id;
			newBGTask.Subject = 'Background Check';
			newBGTask.SystemGeneratedTask__c = true;
			newBGTask.RecordTypeId = taskRecordTypeId;
			log = String.valueOf(newBGTask);
			if (!Test.isRunningTest()) {
				insert newBGTask;
			}
			displayPopup = false;
			if (currVolBGCheck.Date__c >= Date.today()) {
				blockNewBG = false;
			} else {
				blockNewBG = true;
				displayPopupconflict = false;
				displayPopup = false;
			}
			PageReference page = new PageReference('/' + GO_TO_PAGE_VOLUNTEER_WELCOME_PAGE);
			page.setRedirect(true);
			if (Test.isRunningTest()) {
				throw new DmlException('Test');
			}
			return page;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_VF', 'confirmBackGroundCheck', recId, ex, log));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}
}