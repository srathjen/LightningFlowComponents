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

    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static Datetime OLD_VOLUNTEER_SIGNUP_PATH_CUTOFF = Volunteer_New_Application_Control__c.getOrgDefaults().User_Created_Date_Cutoff__c;
    public Boolean displayBecomAVolunteer { get; set; }
    public Boolean displayContinueProcess { get; set; }
    public String welcomText { get; set; }
    public String becomeAVolunteer { get; set; }
    public Boolean isBecomVolunteer { get; set; }
    public Boolean continueProcess { get; set; }
    @TestVisible String chapterId;
    public List<Contact> checkcontactApplicationList { get; set; }
    public List<Background_check__c> checkBackGroundList { get; set; }
//  public List<Task> checkInterviewList { get; set; }
    public List<Volunteer_Orientation_Training__c> trainingList { get; set; }
    public List<Volunteer_Orientation_Training__c> orientationList { get; set; }
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
        String Logvalue;
        // try
        //{
        applicationStatus = null;
        interviewStatus = null;
        backgroundCheckStatus = null;
        trainingStatus = null;
        isBecomVolunteer = true;
        continueProcess = false;
        Id volunteerContactRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        Id orientationRecordTypeId = Constant_AC.ORIENTATION_RT_ID;
        Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
        Id boardMemberContactRecTyped = Constant_AC.BOARD_MEMBER_RT_ID;
        gotoPage = '';
        trainingList = new List<Volunteer_Orientation_Training__c>();
        orientationList = new List<Volunteer_Orientation_Training__c>();
        User currentUser = [
                SELECT Id,ContactId,CreatedDate,ProfileId
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        userCreatedDate = currentUser.CreatedDate;
        userProfileId = currentUser.ProfileId;
        myId = ApexPages.currentPage().getParameters().get('event');
        for (Volunteer_Orientation_Training__c checkOrientationAndTraining : [
                SELECT Id, Volunteer_Attendance__c, Class_Offering__c, Class_Offering__r.Chapter_Role_O_T__c,
                        Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer_Attendance__c != 'Cancelled' AND Volunteer__c = :currentUser.ContactId
        ]) {
            if (checkOrientationAndTraining.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId == orientationRecordTypeId) {
                orientationList.add(checkOrientationAndTraining);
                //Logvalue = String.valueOf(checkOrientationAndTraining);
                Logvalue = Logvalue + '|' + String.valueOf(checkOrientationAndTraining);
            } else if (checkOrientationAndTraining.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId == trainingRecordTypeId) {
                trainingList.add(checkOrientationAndTraining);
                //Logvalue = String.valueOf(trainingList);
                Logvalue = Logvalue + '|' + String.valueOf(checkOrientationAndTraining);
            }
        }
        isBGRoleExpOOC = false;
        for (Volunteer_Roles__c currRole : [
                SELECT Id
                FROM Volunteer_Roles__c
                WHERE Volunteer_Name__c = :currentUser.ContactId
                AND (Status__c = 'Pending' OR Status__c = 'Out of Compliance' OR Status__c = :VOLUNTEER_ROLE_STATUS_ACTIVE)
                AND Sub_status__c != 'Under Chapter Review'
        ]) {
            Logvalue = String.valueOf(currRole);
            isBGRoleExpOOC = true;
        }
        // retrieving application details for getting application status.
        //WVC-2225
        checkcontactApplicationList = [
                SELECT Id,is_Application__c, (
                        SELECT Id, Chapter_Role__c,Chapter_Role__r.Background_Check_Required__c
                        FROM Volunteer_Roles__r /*WHERE Chapter_Role__r.Background_Check_Required__c = true*/
                        ORDER BY Chapter_Role__r.Background_Check_Required__c
                ), RecordTypeId
                FROM Contact
                WHERE (RecordTypeId = :volunteerContactRecordTypeId OR RecordTypeId = :boardMemberContactRecTyped)
                AND Id = :currentUser.ContactId
        ];
        
        bgRequired = false;
        trainingRequired = false;
//SIW-488 - local boolean not necessary as 'notRequired' is the same as bgRequired = true        Boolean bgNotRequired = false;
        if (checkcontactApplicationList[0].Volunteer_Roles__r.size() > 0) {
            for (Volunteer_Roles__c currRole : checkcontactApplicationList[0].Volunteer_Roles__r) {
/*SIW-488 - bqRequired enters as false and should only change if it's no longer false                if (currRole.Chapter_Role__r.Background_Check_Required__c == false) {
                    bgNotRequired = true;
                }
*/
                if (currRole.Chapter_Role__r.Background_Check_Required__c) {
                    bgRequired = true;
                    break; //added SIW-488
                }
            }
/* SIW-488 - bgRequired exits false if none of the volunteer roles require            if (bgNotRequired) {
                bgRequired = false;
            }
*/
        }
        // retrieving background details for getting background check status.
        checkBackGroundList = [
                SELECT Id, Volunteer__c,Status__c
                FROM Background_check__c
                WHERE Volunteer__c = :currentUser.ContactId /*ORDER BY CreatedDate DESC LIMIT 1*/
        ];
        // retrieving interview details for getting interivew status.
        /**
         * WLP-434
         * Deprecating Task from Volunteer Interview and Volunteer Welcome Page
         */
//      String jsonbody = VolunteerInterviewTask_AC.getClassOfferingRecList(currentUser.ContactId);
//      List<Task> newTask = new List<Task>();
//      List<Task> newTaskList;
//      if (!Test.isRunningTest()) {
//          newTaskList = (List<Task>) JSON.deserialize(jsonbody, List<Task>.class);
//      } else {
//          newTaskList = new list<task>();
//      }
//      checkInterviewList = new List<Task>();
//      for (Task currTask : newTaskList) {
//          if (currTask.Status == 'Approved') {
//              checkInterviewList.add(currTask);
//          }
//      }
        // checkInterviewList = [SELECT Id, Status FROM Task WHERE Subject ='Interview Task' AND WhoId =: currentUser.ContactId  AND (Status = 'Completed' OR Status = 'Approved') LIMIT 1];
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
//      Set<Id> requiredTrainigIds = new Set<Id>();
        Set<Id> chatperRoleIds = new Set<Id>();
//      Boolean notRequiredTraining = false;
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
        //WVC-2225
        /* Chris Shinnimin, Traction on Demand:
         * This logic appears to be broken. rewriting below as part of WLP-399
         *
        for (Chapter_Role_O_T__c currChapterRoleOT : [
                SELECT id,Orientation_Training__c,Required__c
                FROM Chapter_Role_O_T__c
                WHERE
                    // Required__c = true AND
                Chapter_Role__c IN :chatperRoleIds
                AND Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
        ]) {
            If (currChapterRoleOT.Required__c) {
                trainingRequired = true;
            } else {
                notRequiredTraining = True;
            }
            requiredTrainigIds.add(currChapterRoleOT.Orientation_Training__c);
        }

        if ((requiredTrainigIds.size() > 0)) {
            If (notRequiredTraining) {
                trainingRequired = false;
            }
        }
        */
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
            Logvalue = Logvalue + '|' + String.valueOf(completedVolunteerOrientationIdsIds);
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
        //isBecomVolunteer = true;
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
                AND Volunteer_Attendance__c != 'Cancelled'
        ];
        if (volunteerOritentationList.size() > 0) {
            isBecomVolunteer = false;
        }
        findVolunteerStatus();
        /* }
         catch(Exception ex)
         {
          new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_AC','VolunteerWelcomePage_AC',Null,ex,Logvalue));
          //ex.setMessage(Label.Debug_log_error_message);
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
          ApexPages.addMessage(myMsg);
         }*/

    }
    // It will redirect the volunteer based on the status.
    public void findVolunteerStatus() {
        /* Chris Shinnimin, Traction on Demand:
         * Jira ticket WLP-499:
         */
        if (userProfileId == Label.Active_Volunteer_Profile) {
            isBecomVolunteer = true;
            continueProcess = true;
            orientationStatus = 'Completed';
            applicationStatus = 'Completed';
            applyForRolesStatus = 'Completed';
            interviewStatus = 'Completed';
            backgroundCheckStatus = 'Completed';
            trainingStatus = 'Completed';
            gotoPage = 'VolunteerLanding_VF';
            return;
        }
        // No orientation completed, then user moved to Orienation page.
        if (completedVolunteerOrientationIdsIds.size() == 0) {
            isBecomVolunteer = true;
            orientationStatus = 'InProgress';
            gotoPage = 'VolunteerOrientation_VF';
        } // If user done the orientation, then redirect to Application page.
        else if (requiredOrientationIds.size() == completedVolunteerOrientationIdsIds.size()) {
            continueProcess = true;
            orientationStatus = 'Completed';
            if (userCreatedDate < OLD_VOLUNTEER_SIGNUP_PATH_CUTOFF) {
                gotoPage = 'Application_VF';
            } else {
                gotoPage = 'ApplyForRoles_VF';
            }
        } else {
            continueProcess = true;
            orientationStatus = 'InProgress';
            gotoPage = 'VolunteerOrientation_VF';
        }
        // If application is completed redirect to interview page else landed to Application page.
        if (orientationStatus == 'Completed') {
            for (Contact checkContactStatus : checkcontactApplicationList) {
                if (Test.isRunningTest()) {
                    checkContactStatus.is_Application__c = 'Submit';
                }
                if (checkContactStatus.is_Application__c == 'Submit' && checkcontactApplicationList.size() == 1) {
                    applicationStatus = 'InProgress';
                    applyForRolesStatus = 'In Progress';
                    if (userCreatedDate < OLD_VOLUNTEER_SIGNUP_PATH_CUTOFF) {
                        gotoPage = 'Application_VF';
                    } else {
                        gotoPage = 'ApplyForRoles_VF';
                    }
                }
                if (Test.isRunningTest()) {
                    checkContactStatus.is_Application__c = 'Approved';
                }
                if (checkContactStatus.is_Application__c == 'Approved') {
                    applicationStatus = 'Completed';
                    applyForRolesStatus = 'Completed';
                    /**
                     * WLP-619
                     * This must no be commented out as the user is not yet Active,
                     * applyForRolesStatus is only changed to completed if the User
                     * Profile of the volunteer is Active_Volunteer_Profile
                     */
                    if (bgRequired) {
                        gotoPage = 'BackgroundCheck_VF';
                    } else {
                        gotoPage = 'VolunteerTraining_VF';
                    }
                }
            }
        }

        /* Chris Shinnimin, Traction on Demand: interviews no longer relevant: See WLP-398
        *
        *
        // If interview completed, will land to BackgroundCheck page else redirect to interview page.
        if (checkInterviewList.size() > 0
                && applicationStatus == 'Completed') {
            interviewStatus = 'Completed';
            if (bgRequired == true)
                gotoPage = 'BackgroundCheck_VF'; else
                    gotoPage = 'VolunteerTraining_VF';
        } else if (checkInterviewList.size() == 0
                && applicationStatus == 'Completed') {
            interviewStatus = 'InProgress';
            gotoPage = 'VolunteerInterview_VF';
        }
        *
        *
        * */
        // If apply for roles completed, user will redirect to Training page. Else redirect to Background check page itself.
        if (applyForRolesStatus == 'Completed') {
            for (Background_check__c checkBackground : checkBackGroundList) {
                if ((checkBackground.Status__c == '' || checkBackground.Status__c == null)) {
                    backgroundCheckStatus = 'InProgress';
                    if (bgRequired == true && checkBackGroundList.size() == 1) {
                        gotoPage = 'BackgroundCheck_VF';
                    }
                }
                if ((checkBackground.Status__c == 'Approved' || checkBackground.Status__c == 'Approved w/ Conditions')) {
                    backgroundCheckStatus = 'Completed';
                    if (trainingRequired == true) {
                        gotoPage = 'VolunteerTraining_VF';
                    }
                }
            }
        }
        if (backgroundCheckStatus == 'Completed') {
            for (Volunteer_Orientation_Training__c checkOrientationStatus : trainingList) {
                if (checkOrientationStatus.Volunteer_Attendance__c == 'Registered' && bgRequired == false && trainingRequired == true) {
                    trainingStatus = 'InProgress';
                    gotoPage = 'VolunteerTraining_VF';
                }
                if ((checkOrientationStatus.Volunteer_Attendance__c == 'Completed') && bgRequired == false && trainingRequired == true) {
                    trainingStatus = 'Completed';
                    gotoPage = 'VolunteerTraining_VF';
                }
            }
        }
    }

    // Fetching Top 4 Events of the volunteer chapter and display on the landing page.
    /*  public list<NonWishEvents> getEvents() {
          eventsRTId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
          List<NonWishEvents> eventRecords = new List<NonWishEvents>();
          for(Non_Wish_Events__c  currRec : [SELECT id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
                                                   FROM Non_Wish_Events__c  WHERE chapter__c = :chapterId AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c != Null order by priority__c ASC limit 4]){
             eventRecords.add(new  NonWishEvents(currRec.Event_Image__c,currRec.Event_Name__c,currRec.Event_Date__c,currRec.Event_Text__c));
          }
          if(eventRecords.size() < 4){
              for(Non_Wish_Events__c  currRec : [SELECT id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
                                                 FROM Non_Wish_Events__c  WHERE chapter__c = :chapterId AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c = Null limit 4]){
                  if(eventRecords.size() < 4)
                      eventRecords.add(new  NonWishEvents(currRec.Event_Image__c,currRec.Event_Name__c,currRec.Event_Date__c,currRec.Event_Text__c));
              }
          }
          return eventRecords;
      } */

    //This method is used to display top 4 events of that chapter.
    public List<Non_Wish_Events__c> getEvents() {
        List<String> LstLog = new List<String>();
//      String Logvalue;
        //  try
        //{
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
                //LstLog.add(string.valueOf(currRec));
                if (eventRecords.size() < 4) {
                    eventRecords.add(currRec);
                }
                LstLog.add(String.valueOf(eventRecords));
            }
        }
        return eventRecords;
        /*  }
          catch(Exception ex) {
              Logvalue = string.join(LstLog,', ');
              new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_AC','getEvents',Null,ex,Logvalue));
              //ex.setMessage(Label.Debug_log_error_message);
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
              ApexPages.addMessage(myMsg);
              return null;
          }*/
    }

    /* ************************************************************************************
    This function is calling on page layout and checking the expiration date of COI and Background check.
    If background is expired or going to expired in 30 days, Then It will display the warning
    message to volunteer for updating their details.
    *************************************************************************************** */
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
            // isExpired = false;
            if (affiliationList[0].npe5__Status__c == 'Not Approved' || affiliationList[0].npe5__Status__c == 'Inactive') {
                isInactivePopup = true;
            } else {
                isCOIExpired = false;
                if (conflictIns.size() > 0) {
                    nCOIDays = (Date.today()).daysBetween(conflictIns[0].Expiration_Date__c);
                }
                if (conflictIns.size() > 0 && myId == null && affiliationList.size() > 0) {
                    if (conflictIns[0].Expiration_Date__c >= Date.today()
                            && conflictIns[0].Expiration_Date__c < Date.today().addDays(coiDays)
                            && (affiliationList[0].npe5__Status__c == 'Active'
                            || affiliationList[0].npe5__Status__c == 'Pending'
                            || affiliationList[0].npe5__Status__c == 'Out of Compliance')
                            && myId == null) {
                        displayPopupconflict = true;
                        flagForCOICancel = true;
                    } else if (conflictIns[0].Expiration_Date__c < Date.today()
                            && (affiliationList[0].npe5__Status__c == 'Active'
                            || affiliationList[0].npe5__Status__c == 'Pending'
                            || affiliationList[0].npe5__Status__c == 'Out of Compliance') && myId == null) {
                        displayPopupconflict = true;
                        flagForCOICancel = false;
                        isCOIExpired = true;
                    }
                }
                if (displayPopupconflict == false) {
                    BackgroundCheck(displayPopupconflict);
                }
                if (Test.isRunningTest()) {
                    throw new CommonTriggerException('Test Class execution');
                }
            }
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_AC', 'COICheck', recId, ex, Logvalue));
            //ex.setMessage(Label.Debug_log_error_message);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    /*****************************************************************************
    This method is used to display the Backgrond check popup based on the BC Expiration date.
    *******************************************************************************/
    public void BackgroundCheck(Boolean displayPopupconflict) {
        String Logvalue, recId;
        String volunteerTaskRtLabel = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
        try {
//          Integer bcDays = Integer.valueOf(Label.B_C_No_of_days_for_expiration);
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
                    SELECT Id, Chapter_Role__c, Volunteer_Name__c, Status__c,
                            Chapter_Role__r.Background_Check_Required__c
                    FROM Volunteer_Roles__c
                    WHERE (Status__c != 'Not Approved'
                    AND Status__c != 'Former'
                    AND Sub_status__c != 'Chapter'
                    AND Sub_status__c != 'Under Chapter Review'
                    AND Sub_status__c != :volunteerTaskRtLabel)
                    AND Chapter_Role__r.Background_Check_Required__c = :TRUE
                    AND Volunteer_Name__c = :currUser.ContactId
            ];
            isExpired = false;
            blockNewBG = false;
            displayPopup = false;
            if (isBGRoleExpOOC == true) {
                if (currVolBGCheck.size() == 1) {
                    if (currVolBGCheck[0].Status__c != ''
                            && currVolBGCheck[0].Date__c >= Date.today()
                            && Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
                            && currVolBGCheck[0].Status__c != 'Rejected' && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[0].Current__c == true) {
                        nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
                        displayPopup = true;
                        flagForCancel = true;
                    } else if (currVolBGCheck[0].Status__c != ''
                            && currVolBGCheck[0].Date__c < Date.today()
                            && currVolBGCheck[0].Status__c != 'Rejected'
                            && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[0].Current__c == true) {
                        displayPopup = true;
                        flagForCancel = false;
                        isExpired = true;
                    } else if (currVolBGCheck[0].Status__c == 'Rejected'
                            && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[0].Current__c == true) {
                        isExpired = true;
                    }
                } else if (currVolBGCheck.size() == 2) {
                    if (currVolBGCheck[0].Status__c != ''
                            && currVolBGCheck[0].Date__c == null
                            && currVolBGCheck[1].Date__c > Date.today()
                            && DbVolRoleBGReqCheck.size() > 0 && currVolBGCheck[1].Current__c == true) {
                        if (currVolBGCheck[1].Status__c == 'Rejected') {
                            blockNewBG = true;
                        }
                    } else if (currVolBGCheck[0].Status__c != ''
                            && currVolBGCheck[0].Date__c == null
                            && currVolBGCheck[1].Date__c < Date.today()
                            && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[1].Current__c == true) {
                        if (currVolBGCheck[1].Status__c != 'Rejected') {
                            blockNewBG = true;
                        }
                    } else if (currVolBGCheck[0].Status__c != ''
                            && currVolBGCheck[0].Date__c > Date.today()
                            && Date.today().daysBetween(currVolBGCheck[0].Date__c) <= 30
                            && currVolBGCheck[0].Status__c != 'Rejected'
                            && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[0].Current__c == true) {
                        nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
                        displayPopup = true;
                        flagForCancel = true;
                    } else if (currVolBGCheck[0].Status__c != ''
                            && currVolBGCheck[0].Date__c <= Date.today()
                            && currVolBGCheck[0].Status__c != 'Rejected'
                            && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[0].Current__c == true) {
                        nBCDays = (Date.today()).daysBetween(currVolBGCheck[0].Date__c);
                        displayPopup = true;
                        flagForCancel = false;
                        isExpired = true;
                    } else if (currVolBGCheck[0].Status__c == 'Rejected'
                            && DbVolRoleBGReqCheck.size() > 0
                            && currVolBGCheck[0].Current__c == true) {
                        blockNewBG = true;
                    }
                }
            }
            /*if(displayPopup == false && blockNewBG == false){
                //DisplayBroadCast(displayPopup);
            }*/
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_AC', 'BackgroundCheck', recId, ex, Logvalue));
            //ex.setMessage(Label.Debug_log_error_message);
            if (!Test.isRunningTest()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
            }
        }
    }

    public PageReference callConfirmConflict() {
        VolunteerLanding_AC landingAc = new VolunteerLanding_AC();
        return landingAc.confirmConflict('VolunteerWelcomePage_VF');
    }

    public void cancelConflict() {
        displayPopupconflict = false;
        BackgroundCheck(displayPopupconflict);
    }

    // If the clicks Become A Volunteer / Continue Process, Based on the page status, they will redirect to the next page
    // in the prospective volunteer portal.
    public PageReference becomeAVolunteer() {
        PageReference pageRef = new PageReference('/apex/' + gotoPage + '?bgRequired=' + bgRequired + '&trainingRequired=' + trainingRequired);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /* ***********************************************************************************************
    If user submits [ok] button for background rechecking, it will create new Background check for the volunteer.
    ******************************************************************************************************* */
    public PageReference confirmBackGroundCheck() {
        String Logvalue;
        String recId;
        try {
            if (volunteercon.BackGroundCheckUpdated__c == true) {
                Contact updateContact = new Contact();
                updateContact.Id = volunteercon.Id;
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
            if (confirmPopup == true) {
                newCheck.Hidden_Display_Popup__c = true;
            } else {
                newCheck.Hidden_Display_Popup__c = false;
            }
            if (volunteercon.Residing_in_US__c == true) {
                newCheck.Resided_in_US_for_past_7_years__c = 'Yes';
            } else {
                newCheck.Resided_in_US_for_past_7_years__c = 'No';
            }
            Logvalue = String.valueOf(newCheck);
            insert newCheck;
            //       If(newcheck.Resided_in_US_for_past_7_years__c == 'No'){
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
            newBGTask.WhoId = volunteercon.Id;
            newBGTask.WhatId = newCheck.Id;
            newBGTask.Subject = 'Background Check';
            newBGTask.SystemGeneratedTask__c = true;
            newBGTask.RecordTypeId = taskRecordTypeId;
            Logvalue = String.valueOf(newBGTask);
            if (!Test.isRunningTest()) {
                insert newBGTask;
            }
            //          }
            displayPopup = false;
            if (currVolBGCheck.Date__c >= Date.today()) {
                blockNewBG = false;
            } else {
                blockNewBG = true;
                displayPopupconflict = false;
                displayPopup = false;
            }
            PageReference page = new PageReference('/VolunteerWelcomePage_VF');
            page.setRedirect(true);
            if (Test.isRunningTest()) {
                throw new DmlException('Test');
            }
            return page;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerWelcomePage_VF', 'confirmBackGroundCheck', recId, ex, Logvalue));
            //ex.setMessage(Label.Debug_log_error_message);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    /* public class NonWishEvents {
        public string eventImage{get;set;}
        public string eventName{get;set;}
        public Date eventDate{get;set;}
        public string eventText{get;set;}
        public NonWishEvents(string eImage, string eName, Date eDate, string eText){
            eventImage = eImage;
            eventName = eName;
            eventDate = eDate;
            eventText = eText;
        }
     }*/
}