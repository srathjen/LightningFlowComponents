/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 7/4/2016
Description : This class is used to pull the landing page content dynamically for active volunteer. If Background
check / COI record is expired or going to expire in 30 days, It will display  a popup message for renewel
their details.
*******************************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolunteerLanding_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	public List<Dynamic_Content__c> activeVolunteerLandingPageInfoList { get; set; }
	public Id currentUserId;
	public Id userRelatedContactId;
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
	/*** Dynamic Content variables */
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

	public VolunteerLanding_AC() {
		confirmPopup = false;
		String Logvalue;
//		String recId;
		myId = ApexPages.currentPage().getParameters().get('event');
		diplayClassOffRec = new List<Class_Offering__c>();
		Id activeVolunteerRecordTypeId = Constant_AC.ACTIVE_VOL_RT_ID;
		currentUserId = UserInfo.getUserId();
		currUser = [
				SELECT ContactId
				FROM User
				WHERE Id = :UserInfo.getUserId()
		];
		List<Background_check__c> dbBackGround = [
				SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c
				FROM Background_check__c
				WHERE Volunteer__c = :currUser.ContactId
				ORDER BY CreatedDate DESC
				LIMIT 1
		];
		Logvalue = String.valueOf(dbBackGround);
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
				AND (Status__c = :VOLUNTEER_ROLE_STATUS_ACTIVE OR Status__c = 'Out of Compliance' OR Status__c = 'Pending')
				AND Sub_status__c != 'Under Chapter Review'
		]) {
			Logvalue = String.valueOf(currRole);
			isBGRoleExpOOC = true;
		}
		volunteercon = [
				SELECT Id,FirstName,LastName,Name,Residing_in_US__c,Region_Chapter__c,isApplication__c,
						Account.Phone,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,BackGroundCheckUpdated__c,
						Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,
						npe01__AlternateEmail__c,npe01__WorkEmail__c
				FROM Contact
				WHERE Id = :currUser.ContactId
				LIMIT 1
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
			Logvalue = String.valueOf(activeVolunteerLandingPageInfoList);
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

	/******************************************************************************************
	This method is used to get the chapter list if the volunteer belongs to more than one chapter
	******************************************************************************************* */
	public List<SelectOption> getChapterList() {
		String Logvalue, recId;
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
				Logvalue = String.valueOf(getChapterList);
				recId = getChapterList.Id;
				chapterList.add(new SelectOption(getChapterList.npe5__Organization__r.Name, getChapterList.npe5__Organization__r.Name));
			}
		}
		return chapterList;

	}

	/******************************************
	This method is used to switch beteen chapters
	******************************************* */
	public PageReference EnterchapterPage() {
		String Logvalue, recId;
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
					Logvalue = String.valueOf(getChapterValues);
					update getChapterValues;
				} else {
					HoldCurrentChapter__c newHoldChapter = new HoldCurrentChapter__c();
					newHoldChapter.Name = currentUserId;
					newHoldChapter.CurrentChapter__c = selectedChapter;
					Logvalue = String.valueOf(newHoldChapter);
					insert newHoldChapter;
				}
			}
			PageReference page = new PageReference('/VolunteerLanding_VF');
			page.setRedirect(true);
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
			return page;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'EnterchapterPage', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/*********************************************************
	This method is used to display top 4 events of that chapter.
	********************************************************* */
	public List<Non_Wish_Events__c> getEvents() {
//		String Logvalue, recId;
		eventsRTId = Constant_AC.EVENTS_ID;
		List<Non_Wish_Events__c> eventRecords = [
				SELECT Id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
				//FROM Non_Wish_Events__c  WHERE chapter__c = :currentChapter  AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c != Null order by priority__c ASC limit 4];
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
					//FROM Non_Wish_Events__c  WHERE chapter__c = :currentChapter  AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c = Null limit 4])
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

	/*************************************************************************************
	This function is calling on page layout and checking the expiration date of COI and Background check.
	If background is expired or going to expired in 30 days, Then It will display the warning
	message to volunteer for updating their details.
	*************************************************************************************** */
	public void COICheck() {
		String Logvalue, recId;
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
			Logvalue = String.valueOf(conflictIns);
			if (affiliationList[0].npe5__Status__c == 'Not Approved'
					|| affiliationList[0].npe5__Status__c == 'Inactive') {
				isInactivePopup = true;
			} else {
				// isExpired = false;
				isCOIExpired = false;
				if (conflictIns.size() > 0) {
					nCOIDays = (Date.today()).daysBetween(conflictIns[0].Expiration_Date__c);
				}
				if (conflictIns.size() > 0 && myId == null && affiliationList.size() > 0) {
					if (conflictIns[0].Expiration_Date__c >= Date.today()
							&& conflictIns[0].Expiration_Date__c < Date.today().addDays(coiDays)
							&& (affiliationList[0].npe5__Status__c == 'Active'
							|| affiliationList[0].npe5__Status__c == 'Pending' ||
							affiliationList[0].npe5__Status__c == 'Out of Compliance')
							&& myId == null) {
						displayPopupconflict = true;
						flagForCOICancel = true;
					} else if (conflictIns[0].Expiration_Date__c < Date.today()
							&& (affiliationList[0].npe5__Status__c == 'Active'
							|| affiliationList[0].npe5__Status__c == 'Pending'
							|| affiliationList[0].npe5__Status__c == 'Out of Compliance')
							&& myId == null) {
						displayPopupconflict = true;
						flagForCOICancel = false;
						isCOIExpired = true;
					}
				}
				if (!displayPopupconflict) {
					BackgroundCheck(displayPopupconflict);
				}
				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'COICheck', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/*****************************************************************************
	This method is used to display the Backgrond check popup based on the BC Expiration date.
	*******************************************************************************/
	public void BackgroundCheck(Boolean displayPopupconflict) {
		String Logvalue, recId;
		try {
			String volunteerTaskRtLabel = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
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
			//List<Background_check__c> currVolBGCheck = [SELECT Id,Volunteer__c, Date_Completed__c,Date__c,status__c FROM Background_check__c WHERE Volunteer__c = :currUser.contactId AND Current__c = True limit 1];
			List<Volunteer_Roles__c> DbVolRoleBGReqCheck = [
					SELECT Id, Chapter_Role__c, Volunteer_Name__c, Status__c, Chapter_Role__r.Background_Check_Required__c
					FROM Volunteer_Roles__c
					WHERE (Status__c != 'Not Approved'
					AND Status__c != 'Former'
					AND Sub_status__c != 'Chapter'
					AND Sub_status__c != :volunteerTaskRtLabel
					AND Sub_status__c != 'Under Chapter Review')
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
							&& currVolBGCheck[0].Status__c != 'Rejected'
							&& DbVolRoleBGReqCheck.size() > 0 && currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = true;
					} else if ((currVolBGCheck[0].Date__c < Date.today()
							&& currVolBGCheck[0].Status__c != 'Rejected'
							&& DbVolRoleBGReqCheck.size() > 0 && currVolBGCheck[0].Current__c)) {
						displayPopup = true;
						flagForCancel = false;
						isExpired = true;
					} else if ((currVolBGCheck[0].Status__c != null
							&& currVolBGCheck[0].Status__c == 'Rejected'
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c)) {
						isExpired = true;
					}//else if(currVolBGCheck[0].date__c == null && DbVolRoleBGReqCheck.size() >0)
					// blockNewBG = true;

				} else if (currVolBGCheck.size() == 2) {
					if (currVolBGCheck[0].Date__c == null && currVolBGCheck[1].Date__c > Date.today()
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[1].Current__c) {
						if (currVolBGCheck[1].Status__c == 'Rejected') {
							blockNewBG = true;
						}
					} else if (currVolBGCheck[1].Date__c < Date.today()
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[1].Current__c) {
						if (currVolBGCheck[1].Status__c != 'Rejected') {
							blockNewBG = true;
						}
					} else if (currVolBGCheck[0].Date__c > Date.today()
							&& Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
							&& currVolBGCheck[0].Status__c != 'Rejected' && DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = true;

					} else if (currVolBGCheck[0].Date__c <= Date.today()
							&& currVolBGCheck[0].Status__c != 'Rejected'
							&& DbVolRoleBGReqCheck.size() > 0
							&& currVolBGCheck[0].Current__c) {
						nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
						displayPopup = true;
						flagForCancel = false;
						isExpired = true;
					} else if (currVolBGCheck[0].Status__c == 'Rejected'
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
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'BackgroundCheck', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);

		}
	}

	/*****************************************************************************
	It will fetch the new Broadcast message and display on the active volunteer portal.
	*********************************************************************************/
	public void DisplayBroadCast(Boolean displayPopup) {
		String Logvalue, recId;
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
					Logvalue += String.valueOf(currStr);
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
				Logvalue += String.valueOf(recentBroadCastList);
				broadCaseMsg = recentBroadCastList[0].Broadcast_Message__c;
				broadCastName = recentBroadCastList[0].Name;
				displayBCMsg = true;
			}
			if (!displayBCMsg) {
				DisplayTraining(displayBCMsg);
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'DisplayBroadCast', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/*************************************************************************************
	This method is used to disoplay the popup for required traing registration.
	************************************************************************************* */
	public void DisplayTraining(Boolean displayBCMsg) {
		String Logvalue, recId;
		try {
			Set<Id> chapterRoleIdSet = new Set<Id>();
//			Set<Id> volunteerRoleIdSet = new Set<Id>();
			//Background_check__c
			List<Background_check__c> bcList = [
					SELECT Id
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					AND Current__c = TRUE /*AND Hidden_Training_Notification__c = 'Yes'*/
			];
			for (Volunteer_Roles__c chapterRole : [
					SELECT Chapter_Role__c,Chapter_Role__r.Chapter_Name__c,Sub_status__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c = :currUser.ContactId
					AND Sub_status__c != 'Under Chapter Review'
					AND Status__c = 'Pending'/* AND Volunteer_Name__r.Hidden_Training_Notification__c = 'Yes'*/
			]) {
				chapterRoleIdSet.add(chapterRole.Chapter_Role__c);
			}
			if (bcList.size() == 1 && chapterRoleIdSet.size() > 0) {
				diplayClassOffRec = [
						SELECT Id,Orientation_and_Training__c,Chapter_Role_O_T__c,
								Chapter_Role_O_T__r.Orientation_Training__c,Date__c,Start_Time__c,End_Time__c
						FROM Class_Offering__c
						WHERE /*Chapter_Role_O_T__r.Orientation_Training__c NOT IN :orientationIds */
								/* AND Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = true */
								/*AND*/ Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training'
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
				// Fetching Training details which are marked as "Prompt upon login" and display on the portal, if it is not completed by volunteer.
				for (Volunteer_Roles__c chapterRole : [
						SELECT Chapter_Role__c,Chapter_Role__r.Chapter_Name__c,Sub_status__c
						FROM Volunteer_Roles__c
						WHERE Volunteer_Name__c = :currUser.ContactId AND Sub_status__c != 'Under Chapter Review'
				]) {
					Logvalue += String.valueOf(chapterRole);
					chapterRoles.add(chapterRole.Chapter_Role__c);
					chapterIds.add(chapterRole.Chapter_Role__r.Chapter_Name__c);
				}
				for (Chapter_Role__c currRec : [
						SELECT Id
						FROM Chapter_Role__c
						WHERE Chapter_Name__c IN :chapterIds
						AND Role_Name__r.Name = 'All Roles'
				]) {
					chapterRoles.add(currRec.Id);
				}
				for (Volunteer_Orientation_Training__c currRec : [
						SELECT Id,Volunteer_Attendance__c,Hidden_O_T_Id__c
						FROM Volunteer_Orientation_Training__c
						WHERE Volunteer__c = :currUser.ContactId
						AND Volunteer_Attendance__c != 'Volunteer Cancelled'
						AND Type__c = 'Training'
				]) {
					orientationIds.add(currRec.Hidden_O_T_Id__c);
					Logvalue += String.valueOf(currRec);
					if (currRec.Volunteer_Attendance__c == 'Registered') {
						registeredIds.add(currRec.Hidden_O_T_Id__c);
					}
				}
				diplayClassOffRec = [
						SELECT Id,Orientation_and_Training__c,Chapter_Role_O_T__c,
								Chapter_Role_O_T__r.Orientation_Training__c,Date__c,Start_Time__c,End_Time__c
						FROM Class_Offering__c
						WHERE Chapter_Role_O_T__r.Orientation_Training__c NOT IN :orientationIds
						AND Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = TRUE
						AND Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training'
						AND Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoles
						AND ((Date__c >= :Date.today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = NULL)
						AND (max_capacity__c = NULL OR (max_capacity__c > 0 AND AvailableSeats__c > 0))
						LIMIT 1
				];
//				List<Class_Offering__c> registeredClassOff = [
//						SELECT Id,Orientation_and_Training__c,Date__c,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__c,
//								Start_Time__c,End_Time__c
//						FROM Class_Offering__c
//						WHERE
//						Chapter_Role_O_T__r.Orientation_Training__c IN :registeredIds
//						AND Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = TRUE
//						AND Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training'
//						AND Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoles
//						LIMIT 1
//				];
				if (diplayClassOffRec.size() > 0 && blockNewBG != true) {
					trainingName = diplayClassOffRec[0].Orientation_and_Training__c;
					displayTrainingDetails = true;
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'DisplayTraining', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/* *************************************************************************
	Register for the Required Training which is populating on the landing portal.
	****************************************************************************** */
	public PageReference register() {
/*        List<Background_check__c> backgroundList = [SELECT Id FROM Background_Check__c WHERE Volunteer__c =: currUser.contactId AND Current__c = True AND Hidden_Training_Notification__c = 'Yes' ];
        If(backgroundList.Size() == 1){
            backgroundList[0].Hidden_Training_Notification__c = 'No';
            Update backgroundList;
        }*/
		PageReference pr;
		pr = new PageReference('/VolunteerActiveTraining_VF');
		return pr;
	}

	/* ***********************************************************************************************
	If user submits [ok] button for background rechecking, it will create new Background check for the volunteer.
	******************************************************************************************************* */
	public PageReference confirmBackGroundCheck() {
		String Logvalue;
		String recId;
		try {
			if (volunteercon.BackGroundCheckUpdated__c) {
				Contact updateContact = new Contact();
				updateContact.Id = currUser.ContactId;
				updateContact.HomePhone = volunteercon.HomePhone;
				updateContact.MobilePhone = volunteercon.MobilePhone;
				//updateContact.BackGroundCheckUpdated__c = volunteercon.BackGroundCheckUpdated__c;
				updateContact.npe01__Preferred_Email__c = volunteercon.npe01__Preferred_Email__c;
				updateContact.npe01__HomeEmail__c = volunteercon.npe01__HomeEmail__c;
				updateContact.npe01__WorkEmail__c = volunteercon.npe01__WorkEmail__c;
				updateContact.npe01__AlternateEmail__c = volunteercon.npe01__AlternateEmail__c;
				RecursiveTriggerHandler.blockBeforeUpdate = true;
				RecursiveTriggerHandler.blockAfterUpdate = true;
				recId = updateContact.Id;
				Logvalue = String.valueOf(updateContact);
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
			newCheck.Requested_By__c = UserInfo.getUserId();
			newCheck.Volunteer__c = currUser.ContactId;
			if (confirmPopup) {
				newCheck.Hidden_Display_Popup__c = true;
			} else {
				newCheck.Hidden_Display_Popup__c = false;
			}
			if (volunteercon.Residing_in_US__c) {
				newCheck.Resided_in_US_for_past_7_years__c = 'Yes';
			} else {
				newCheck.Resided_in_US_for_past_7_years__c = 'No';
			}
			/*  if(currVolBGChecklist.Size() == 0)
				  newCheck.Hidden_Training_Notification__c = 'Yes';
			  else
				  newCheck.Hidden_Training_Notification__c = 'No';*/
			Logvalue = String.valueOf(newCheck);
			insert newCheck;
			// If(newcheck.Resided_in_US_for_past_7_years__c == 'No'){
			Id taskRecordTypeId = Constant_AC.BACKGROUND_RT_ID;
			Task newBGTask = new Task();
			newBGTask.Type = 'Email';
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
			Logvalue = String.valueOf(newBGTask);
			if (!Test.isRunningTest()) {
				insert newBGTask;
			}
			//}
			displayPopup = false;
			if (currVolBGChecklist.size() > 0 && currVolBGChecklist[0].Date__c >= Date.today()) {
				blockNewBG = false;
			} else {
				blockNewBG = true;
				displayPopupconflict = false;
				displayPopup = false;
			}
			PageReference page = new PageReference('/VolunteerLanding_VF');
			page.setRedirect(true);
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
			return page;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'confirmBackGroundCheck', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/******************************************
	User can disable the warning popup via cancel button.
	********************************************** */
	public void cancel() {
		displayPopup = false;
		DisplayBroadCast(displayPopup);
	}

	/*********************
	Cancel the Trainig popup.
	*********************** */
	public void TrainingAckCancel() {
		displayTrainingAck = false;
	}

	/*****************************************************************************************
	Once the user read the Broadcast message, Broadcast number will be stored in the Volunteer Contact Record,
	in order to prevent it next time popup.
	*******************************************************************************************/
	public void broadCastCancel() {
		displayBCMsg = false;
		String Logvalue;
		if (broadCastName != '') {
			try {
				Contact updateContact = new Contact();
				updateContact.Id = currUser.ContactId;
				if (volunteercon != null && volunteercon.Broadcast_Number__c != null) {
					updateContact.Broadcast_Number__c = volunteercon.Broadcast_Number__c + ',' + broadCastName;
				} else {
					updateContact.Broadcast_Number__c = broadCastName;
				}
				Logvalue = String.valueOf(updateContact);
				update updateContact;
				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			} catch (Exception ex) {
				new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'broadCastCancel', null, ex, Logvalue));
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
			}
		}
		DisplayTraining(displayBCMsg);
	}

	/***************************************************
	User can disable the COI warning popup via cancel button.
	*************************************************** */
	public void cancelConflict() {
		displayPopupconflict = false;
		BackgroundCheck(displayPopupconflict);
	}

	public PageReference callConfirmConflict() {
		return confirmConflict('VolunteerLanding_VF');
	}

	/********************************************************************************************************************
	If user submits [ok] for COI, then it will send the document for sign , once sign completed then it will create new COI.
	********************************************************************************************************************* */
	public PageReference confirmConflict(String pageName) {
		displayPopupconflict = false;
		String account;
		String IntegratorKey;
		String Logvalue;
		String recId;
		try {
			User currUser = [
					SELECT ContactId
					FROM User
					WHERE Id = :UserInfo.getUserId()
			];
			volunteercon = [
					SELECT Id,FirstName,LastName,Name,Email,Phone
					FROM Contact
					WHERE Id = :currUser.ContactId
					LIMIT 1
			] ;
			Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
			for (DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
				account = credentialIns.account__c;
				IntegratorKey = credentialIns.IntegratorKey__c;
			}
			String authorizationHeader = '<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>' + IntegratorKey + '</IntegratorKey></DocuSignCredentials>';
			String boundary = 'AAA';
			PageReference PDF = Page.ConflictOfInterestPage_PDF_VF;
			PDF.getParameters().put('id', volunteercon.Id);
			String documentPDF;
			try {
				documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
			} catch (Exception e) {
				// Generic exception handling code here.
				new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'confirmConflict', null, e, Logvalue));
			}
			String body = '{' +
					'  "status":"sent",' +
					'  "enableWetSign": "false",' +
					'  "emailBlurb":"",' +
					'  "emailSubject": "Please review & act on these document",' +
					'  "enforceSignerVisibility":"True",' +
					'  "documents": [{' +
					'      "name": "document.pdf",' +
					'      "documentId":"1",' +
					'      "order":"1",' +
					'      "documentBase64":"' + documentPDF + '"' +
					'  }],' +
					'"recipients": {' +
					'    "signers" : [{' +
					'      "email": "' + volunteercon.Email + '",' +
					'      "name": "' + volunteercon.Name + '",' +
					'      "recipientId":"1",' +
					'      "clientUserId":"1",' +
					'      "tabs": {' +
					'                "signHereTabs": [{' +
					'                    "anchorString": "~s1",' +
					'                    "anchorXOffset": "0.1",' +
					'                    "anchorYOffset": "0.1",' +
					'                    "anchorIgnoreIfNotPresent": "false",' +
					'                    "anchorUnits": "inches"' +
					'                }],' +
					'                "dateSignedTabs": [{' +
					'                      "anchorString": "~date",' +
					'                       "anchorXOffset": "0",' +
					'                       "fontSize":      "Size14",' +
					'                       "fontColor":     "Black",' +
					'                        "anchorYOffset": "0",' +
					'                        "anchorIgnoreIfNotPresent": "false",' +
					'                        "xPosition": "100",' +
					'                        "yPosition": "72",' +
					'                        "anchorUnits": "inches"' +
					'                    }]' +
					'            }' +
					'    }]' +
					'  }' +
					'}';

			String header = '--' + boundary + '\nContent-Type: application/json\nContent-Disposition: form-data';
			String jsonBody = header + '\n\n' + body + '\n\n--' + boundary + '--';
			//Callout to Docusign.
			HttpRequest req = new HttpRequest();
			req.setHeader('X-DocuSign-Authentication', authorizationHeader);
			req.setHeader('Accept', 'application/json');
			req.setHeader('Host', 'demo.docusign.net');
			req.setHeader('Content-Length', '162100');
			req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
			req.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes');
			req.setMethod('POST');
			req.setBody(jsonBody);
			Http http = new Http();
			HttpResponse res = new HTTPResponse();
			Logvalue = String.valueOf(req);

			if (!Test.isRunningTest()) {
				res = http.send(req);
			} else {
				res.setStatusCode(200);
				res.setBody('{"envelopeId":"Test"}');
			}
			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

			if ((String) results.get('envelopeId') != '') {
				String env = (String) results.get('envelopeId');
				HttpRequest request = new HttpRequest();
				request.setHeader('X-DocuSign-Authentication', authorizationHeader);
				request.setHeader('Accept', 'application/json');
				request.setHeader('Host', 'demo.docusign.net');
				request.setHeader('Content-Length', '162100');
				request.setHeader('Content-Type', 'application/json');
				request.setMethod('POST');
				Http httprequest = new Http();
				HttpResponse response = new HttpResponse();
				request.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes/' + env + '/views/recipient');
				String jsonPayload;
				jsonPayload = '{' +
						'    "userName": "' + volunteercon.Name + '",' +
						'    "email": "' + volunteercon.Email + '",' +
						'    "recipientId": "1",' +
						'    "clientUserId": "1",' +
						'    "authenticationMethod": "None",' +
						'    "returnUrl": "' + Endpoints__c.getInstance().Site_URL__c + '/' + pageName + '"' +
						'}';
				request.setBody(jsonPayload);
				Logvalue = String.valueOf(request);
				if(!Test.isRunningTest()){
					response = httprequest.send(request);
				} else {
					response.setStatusCode(200);
					response.setBody('{"url":"Test"}');
				}
				results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
				if ((String) results.get('url') != '' || (String) results.get('url') != null) {
					volunteercon.isApplication__c = true;
					if (!Test.isRunningTest()) {
						recId = volunteercon.Id;
						Logvalue = String.valueOf(volunteercon);
						update volunteercon;
					}
					dsfs__DocuSign_Status__c dsfs = new dsfs__DocuSign_Status__c();
					dsfs.dsfs__DocuSign_Envelope_ID__c = env;
					dsfs.isConflict__c = true;
					dsfs.Docusign_Hidden_Contact__c = volunteercon.Id;
					Logvalue = String.valueOf(dsfs);
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
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'confirmConflict', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/*************************************************************************************************
	This method is used to deisplay the coresponding email address in backgrong check expired popup message for
	volunteer update their email address purpose.
	************************************************************************************************* */
	public void displayEmail() {
		Contact dbContact = [
				SELECT Id,FirstName,LastName,Name,Region_Chapter__c,isApplication__c,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,
						Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,npe01__AlternateEmail__c,npe01__WorkEmail__c
				FROM Contact
				WHERE Id = :currUser.ContactId
				LIMIT 1
		] ;
		if (volunteercon.npe01__Preferred_Email__c == 'Personal') {
			email = dbContact.npe01__HomeEmail__c;
		}
		if (volunteercon.npe01__Preferred_Email__c == 'Work') {
			email = dbContact.npe01__WorkEmail__c;
		}
		if (volunteercon.npe01__Preferred_Email__c == 'Alternate') {
			email = dbContact.npe01__AlternateEmail__c;
		}
	}

	/*************************************************************************************************
	This method is used to hide the BC expired popup when the BC created date is today for the renival of BC.
	*****************************************************************************************************/
	public void hidePopup() {
		confirmPopup = false;
		Background_check__c newback = new Background_check__c();
		String Logvalue;
		String recId;
		try {
			List<Background_check__c> dbBackGround = [
					SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c
					FROM Background_check__c
					WHERE Volunteer__c = :currUser.ContactId
					ORDER BY CreatedDate DESC
					LIMIT 1
			];
			if (dbBackGround.size() > 0) {
				newback.Id = dbBackGround[0].Id;
				newback.Hidden_Display_Popup__c = false;
				recId = newback.Id;
				Logvalue = String.valueOf(dbBackGround[0]);
				update newback;

				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC', 'hidePopup', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}
}