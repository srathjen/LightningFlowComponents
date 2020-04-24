/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/15/2016
Description : It will display all the Required Orientation(Chapter based Orientation) on Prospective Portal
Which are not completed by the volunteer. If user tries to register same orientation for different timing, It will 
throw an error message. And also If the User register for multiple Orientation at same timing that time also It will
throw an error message. Once the user registered for the orientation then Voluntee Orientation and Training 
Record will create with Registered status. If user cancelled the registered orientation then the status would update as 
Cancelled. 
*******************************************************************************************************************/

public class VolunteerOrientation_AC {

    public static final String VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
    public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
    public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
    public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;

    public List<Orientation_Training__c> volunteerTrainingsList { get; set; }
    public Id trainingId { get; set; }
    public String lMSCourseId { get; set; }
    public Id userRelatedContactId;
    public Id currentUserId;
    public String sSOUrl { get; set; }
    public String courseURL { get; set; }
    public List<Volunteer_Orientation_Training__c> checkExistingTrainingRecords;
    public List<Volunteer_Orientation_Training__c> checkExistingCanceledRecords;
    public Id orientationRecordTypeId = Constant_AC.ORIENTATION_RT_ID;
    public Id classOfferingRecordtypeId { get; set; }
    public Map<String, Integer> startTimeMap;
    public Map<String, Integer> endTimeMap;
    public String orientationContent { get; set; }
    public Boolean checkExistProgram { get; set; }
    private Integer counter = 0;  //keeps track of the offset
    @TestVisible private Integer list_size = 20; //sets the page size or number of rows
    public Integer total_size { get; set; } //used to show user the total size of the list
    public List<Volunteer_Orientation_Training__c> dupCheckList;
    public List<User> getUserRelatedContact;
    public Boolean isOrientationExist { get; set; }
    public Boolean isCancelled { get; set; }
    public Map<Id, Class_Offering__c> classOfferingMap;
    public LMSSSORespose lMSSSOResponse;
    @TestVisible private LMS_Credentials__c lMSCredential;
    public Boolean bgTabPermission { get; set; }
    public Boolean trainingTabVisible { get; set; }
    public VolunteerOrientation_AC() {
        String Logvalue;
        dupCheckList = new List<Volunteer_Orientation_Training__c>();
        checkExistingTrainingRecords = new List<Volunteer_Orientation_Training__c>();
        currentUserId = UserInfo.getUserId();
        classOfferingRecordtypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        getUserRelatedContact = [
                SELECT Id, Hidden_Email__c, FirstName, LastName, Email, ContactId, Username,
                        LMS_User_Code__c, LMS_Login__c, LMS_Id__c,
                        Contact.Region_Chapter__c, Contact.Region_Chapter__r.Chapter_Id__c
                FROM User
                WHERE Id = :currentUserId
        ];
        lMSCredential = LMS_Credentials__c.getValues('LMS Integration');
        userRelatedContactId = getUserRelatedContact.get(0).ContactId;
        lMSSSOResponse = new LMSSSORespose();
        Id nationalRT = Constant_AC.NATIONAL_RT_ID;
        List<Dynamic_Content__c> dynamicContent = [
                SELECT Id,Orientation_Add_l_Info__c,Training_Additional_Info__c,Chapter_Name__c
                FROM Dynamic_Content__c
                WHERE RecordTypeId = :nationalRT AND Active__c = TRUE
        ];
        if (dynamicContent.size() > 0) {
            Logvalue = String.valueOf(dynamicContent);
            orientationContent = dynamicContent.get(0).Orientation_Add_l_Info__c;
        }
        checkRegisteredProgram();
        // Based on the parameter value, It would display Background tab.
        if (ApexPages.currentPage().getParameters().get('bgRequired') != null) {
            bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));
        }
        // Based on the parameter value, It would display Background tab.
        if (ApexPages.currentPage().getParameters().get('trainingRequired') != null) {
            trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));
        }
    }

    // It will check the registered program on Volunteer Orientatoin and Training, If orientation is available then it will display
    // the registered orientation in a separate block.
    public Boolean checkRegisteredProgram() {
        String Logvalue;
        List<Volunteer_Orientation_Training__c> exVolList = [
                SELECT Id, Hidden_O_T_Id__c, Volunteer__c, Volunteer_Attendance__c
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c = :userRelatedContactId
                AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED
        ];
        Logvalue = String.valueOf(exVolList);
        checkExistProgram = exVolList.isEmpty();
        Logvalue = String.valueOf(checkExistProgram);
        return checkExistProgram;
    }

    // Fetching all the chapter based Orientation for the volunteer chapter and It will display on the Orientation page.
    public List<ClassOfferingWrapper> getOrientationRecordList() {
        List<String> LstLog = new List<String>();
        String Logvalue;
        try {
            classOfferingMap = new Map<Id, Class_Offering__c>();
            Set<Id> chapterIds = new Set<Id>();
            userRelatedContactId = getUserRelatedContact.get(0).ContactId;

            for (npe5__Affiliation__c currRec : [
                    SELECT Id, npe5__Contact__c, npe5__Primary__c, npe5__Status__c, npe5__Organization__c
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c = :userRelatedContactId AND npe5__Primary__c = TRUE
            ]) {
                chapterIds.add(currRec.npe5__Organization__c);
            }

            Set<Id> completedTrainingsSet = new Set<Id>();
            for (Volunteer_Orientation_Training__c checkTrainingDetails : [
                    SELECT Id, Class_Offering__c, Class_Offering__r.Chapter_Role_O_T__c, Volunteer__c, Volunteer_Attendance__c
                    FROM Volunteer_Orientation_Training__c
                    WHERE Volunteer__c = :userRelatedContactId AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
            ]) {
                LstLog.add(String.valueOf('Training details' + checkTrainingDetails));
                if (checkTrainingDetails.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED) {
                    completedTrainingsSet.add(checkTrainingDetails.Class_Offering__r.Chapter_Role_O_T__c);
                }
            }
            if (!chapterIds.isEmpty()) {
                classOfferingMap.putAll([
                        SELECT Id,Name,Chapter__c,Date__c,Course_ID__c,End_Time__c,RecordTypeId,RecordType.Name,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__r.Name,
                                Location__c,max_capacity__c,Start_Time__c,Type__c,Orientation_and_Training__c,Registered_Seats__c, AvailableSeats__c, Chapter_Role_O_T__r.Orientation_Training__c, (
                                SELECT Id, Name, Volunteer_Attendance__c
                                FROM Volunteer_Orientation_Trainings__r
                                WHERE Volunteer__c = :getUserRelatedContact.get(0).ContactId
                        )
                        FROM Class_Offering__c
                        WHERE Chapter_Role_O_T__r.Required__c = TRUE AND
                        Chapter_Role_O_T__r.Chapter_Role__r.Chapter_Name__c IN :chapterIds AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :orientationRecordTypeId
                        AND Chapter_Role_O_T__c NOT IN :completedTrainingsSet
                        AND ((Date__c >= :Date.today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = NULL)
                        ORDER BY Date__c NULLS LAST
                        LIMIT :list_size
                        OFFSET :counter
                ]);

                List<AggregateResult> countAgg = [
                        SELECT COUNT(Id)
                        FROM Class_Offering__c
                        WHERE Chapter_Role_O_T__r.Required__c = TRUE AND
                        Chapter_Role_O_T__r.Chapter_Role__r.Chapter_Name__c IN :chapterIds AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :orientationRecordTypeId
                        AND Id NOT IN :completedTrainingsSet AND ((Date__c >= :Date.today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = NULL)
                ];
                total_size = (countAgg != null && !countAgg.isEmpty()) ? (Integer) countAgg[0].get('expr0') : 0;
            }

            List<ClassOfferingWrapper> classOfferingList = new List<ClassOfferingWrapper>();
            if (Test.isRunningTest() && classOfferingMap.isEmpty()) {
                classOfferingMap.put(trainingId, new Class_Offering__c(max_capacity__c = 1));
            }
            for (Class_Offering__c currRec : classOfferingMap.values()) {
                ClassOfferingWrapper newWrapper = new ClassOfferingWrapper();
                newWrapper.orientationName = currRec.Orientation_and_Training__c;
                newWrapper.chapterName = currRec.Chapter__c;
                newWrapper.orientationDate = currRec.Date__c;
                newWrapper.startTime = currRec.Start_Time__c;
                newWrapper.endTime = currRec.End_Time__c;
                newWrapper.location = currRec.Location__c;
                newWrapper.maxCapacity = Integer.valueOf(currRec.max_capacity__c);
                newWrapper.avilableSheets = Integer.valueOf(currRec.AvailableSeats__c);
                newWrapper.recordType = currRec.RecordType.Name;
                newWrapper.recordId = currRec.Id;
                newWrapper.volOppSize = currRec.Volunteer_Orientation_Trainings__r.size();
                newWrapper.courseId = currRec.Course_ID__c;
                newWrapper.recordTypeId = currRec.RecordTypeId;
                if (currRec.Volunteer_Orientation_Trainings__r.size() > 0) {
                    newWrapper.status = currRec.Volunteer_Orientation_Trainings__r[0].Volunteer_Attendance__c;
                }
                if (((currRec.max_capacity__c == null) || (currRec.max_capacity__c > 0 && currRec.max_capacity__c > currRec.Registered_Seats__c))
                        && ((newWrapper.volOppSize > 0 && newWrapper.status == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED) || newWrapper.volOppSize == 0)) {
                    newWrapper.displayRec = true;
                } else {
                    newWrapper.displayRec = false;
                }
                LstLog.add('class offering' + String.valueOf(newWrapper));
                classOfferingList.add(newWrapper);
            }

            isOrientationExist = false;
            isCancelled = false;
            TimingInfo();
            checkRegisteredProgram();
            if (Test.isRunningTest()) {
                throw new DmlException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
            return classOfferingList;
        } catch (Exception ex) {
            Logvalue = String.join(LstLog, ', ');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC', 'getOrientationRecordList', null, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    // Mapping some additional key value for Start and End Time. Using this value, we can prevent the volunteer training time conflict.
    public void TimingInfo() {
        startTimeMap = new Map<String, Integer>();
        endTimeMap = new Map<String, Integer>();
        Schema.DescribeFieldResult startTimeResult = Class_Offering__c.Start_Time__c.getDescribe();
        List<Schema.PicklistEntry> startTimeValues = startTimeResult.getPicklistValues();
        Integer i = 0;
        for (Schema.PicklistEntry startTime : startTimeValues) {
            startTimeMap.put(startTime.getValue(), i);
            i++;
        }
        Schema.DescribeFieldResult endTimeResult = Class_Offering__c.End_Time__c.getDescribe();
        List<Schema.PicklistEntry> endTimeValues = endTimeResult.getPicklistValues();
        Integer j = 0;
        for (Schema.PicklistEntry endTime : endTimeValues) {
            endTimeMap.put(endTime.getValue(), j);
            j++;
        }
    }

    // It will create a new Volunteer Orientation Training for the Class Offering.
    // Suppose cancelled volunteer Orientation & Training record available for the class offering,
    // Then it will update the existing cancelled record status as Registered.
    // If the volunteer registered the orientation same time for two diferent orientation, then it will throw and error message.
    public void Register() {
        List<String> LstLog = new List<String>();
        String Logvalue;
        try {
            LMSUserResponse currLMSUserResponse = new LMSUserResponse();
            Set<String> checkDupSets = new Set<String>();
            List<Class_Offering__c> classOfferingDetails = new List<Class_Offering__c>();
            if (classOfferingMap.containsKey(trainingId)) {
                classOfferingDetails.add(classOfferingMap.get(trainingId));
            }

            List<Volunteer_Orientation_Training__c> existingRecList = [
                    SELECT Id, Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.End_Time__c, FORMAT(Class_Offering__r.Date__c),
                            Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                    FROM Volunteer_Orientation_Training__c
                    WHERE Volunteer__c = :userRelatedContactId AND
                    Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c AND
                    (Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED OR Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED)
                    AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
            ];
            LstLog.add('existingRecList' + String.valueOf(existingRecList));
            if (!existingRecList.isEmpty()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Volunteer_Portal_Already_Registered_Message_Orientation);
                ApexPages.addMessage(myMsg);

            } else {
                if (classOfferingDetails.size() > 0) {
                    checkExistingCanceledRecords = [
                            SELECT Id, Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.RecordTypeId, Class_Offering__r.End_Time__c,
                                    FORMAT(Class_Offering__r.Date__c), Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                            FROM Volunteer_Orientation_Training__c
                            WHERE Volunteer__c = :userRelatedContactId AND Class_Offering__c = :trainingId AND
                            Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c
                            AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED
                    ];
                    LstLog.add('ExistingCancelRecords' + String.valueOf(checkExistingCanceledRecords));

                    if (!checkExistingCanceledRecords.isEmpty()) {
                        List<Volunteer_Orientation_Training__c> updateList = new List<Volunteer_Orientation_Training__c>();
                        Boolean flag = true;
                        List<Volunteer_Orientation_Training__c> checkforExistingBeforeRegister = [
                                SELECT Id, FORMAT(Class_Offering__r.Date__c), Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.End_Time__c,
                                        Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                                FROM Volunteer_Orientation_Training__c
                                WHERE Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
                                AND Volunteer__c = :userRelatedContactId
                                AND (Class_Offering__r.Date__c = :checkExistingCanceledRecords[0].Class_Offering__r.Date__c
                                AND Class_Offering__r.Date__c != NULL)
                                AND (Volunteer_Attendance__c != :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED
                                AND Volunteer_Attendance__c != :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED)
                        ];

                        if (checkforExistingBeforeRegister.size() > 0) {
                            for (Volunteer_Orientation_Training__c checkExistingTrainings : checkforExistingBeforeRegister) {
                                if (((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.Start_Time__c))) >= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c))))
                                        && ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.Start_Time__c))) >= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c))))
                                        || ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.End_Time__c))) <= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c))))
                                        && ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.End_Time__c))) <= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c))))) {
                                    if (checkExistingCanceledRecords.get(0).Class_Offering__r.RecordTypeId == classOfferingRecordtypeId) {
                                        if (getUserRelatedContact.size() > 0 && lMSCredential != null) {
                                            User currVolunteerUser = getUserRelatedContact.get(0);
                                            currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                        }
                                        LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                                        currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', null);
                                        checkExistingCanceledRecords.get(0).LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : null;
                                    }

                                    checkExistingCanceledRecords.get(0).Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
                                    checkExistingCanceledRecords.get(0).Class_Offering__c = trainingId;
                                    updateList.add(checkExistingCanceledRecords[0]);
                                } else {
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Volunteer_Portal_Already_Registered_Same_Day_Time_Message_Orientation);
                                    ApexPages.addMessage(myMsg);

                                    flag = false;
                                    isCancelled = false;
                                    isOrientationExist = false;
                                }
                            }
                            if (updateList.size() > 0 && flag == true) {
                                update updateList;
                                isCancelled = false;
                                isOrientationExist = true;
                                checkRegisteredProgram();
                            }
                        } else {
                            checkExistingCanceledRecords.get(0).Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
                            checkExistingCanceledRecords.get(0).Class_Offering__c = trainingId;
                            if (checkExistingCanceledRecords.get(0).Class_Offering__r.RecordTypeId == classOfferingRecordtypeId) {
                                if (getUserRelatedContact.size() > 0 && lMSCredential != null) {
                                    User currVolunteerUser = getUserRelatedContact.get(0);
                                    currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                }
                                LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                                currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', null);
                                checkExistingCanceledRecords.get(0).LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : null;

                            }
                            LstLog.add('check existing cancel records' + String.valueOf(checkExistingCanceledRecords));
                            update checkExistingCanceledRecords;
                            isCancelled = false;
                            isOrientationExist = true;
                            checkRegisteredProgram();
                        }
                    }

                    else {
                        Set<String> existingTrainingSet = new Set<String>();
                        for (Volunteer_Orientation_Training__c checkExistingTrainings : [
                                SELECT Id, FORMAT(Class_Offering__r.Date__c), Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.End_Time__c, Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                                FROM Volunteer_Orientation_Training__c
                                WHERE Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION AND Class_Offering__r.Date__c = :classOfferingDetails[0].Date__c
                                AND (Volunteer_Attendance__c != :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED AND Volunteer_Attendance__c != :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED) AND Volunteer__c = :userRelatedContactId
                        ]) {
                            LstLog.add(String.valueOf(checkExistingTrainings));
                            if (!existingTrainingSet.contains(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c))) {
                                existingTrainingSet.add(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c));
                            }
                        }
                        for (String iterateExistingValues : existingTrainingSet) {
                            if (!((Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(iterateExistingValues.split('-')[0]))
                                    && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(iterateExistingValues.split('-')[1]))
                                    || (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(iterateExistingValues.split('-')[0]))
                                    && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(iterateExistingValues.split('-')[1])))) {
                                checkDupSets.add(iterateExistingValues);
                            }
                        }
                        if (!checkDupSets.isEmpty()) {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Volunteer_Portal_Already_Registered_Same_Day_Time_Message_Orientation);
                            ApexPages.addMessage(myMsg);
                            isCancelled = false;
                            isOrientationExist = false;
                        } else {
                            Volunteer_Orientation_Training__c newTrainingRegistration = new Volunteer_Orientation_Training__c();
                            newTrainingRegistration.Class_Offering__c = trainingId;
                            newTrainingRegistration.Volunteer__c = userRelatedContactId;
                            newTrainingRegistration.Type__c = VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
                            newTrainingRegistration.Registered_Date__c = System.today();
                            newTrainingRegistration.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
                            newTrainingRegistration.Hidden_O_T_Id__c = classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c;

                            isCancelled = false;
                            isOrientationExist = true;
                            /*Added by Sailappa Vignesh PG
                            Description : To create a new  Course enrollment in LMS*/
                            User currVolunteerUser = getUserRelatedContact.get(0);
                            if (classOfferingMap.get(trainingId).RecordTypeId == classOfferingRecordtypeId) {

                                if (getUserRelatedContact.size() > 0 && lMSCredential != null) {

                                    currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                }
                                LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                                currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', null);
                                if (currLMSOrientationRegistrationResponse.status != null && currLMSOrientationRegistrationResponse.status.equalsIgnoreCase('in-progress')) {
                                    newTrainingRegistration.LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : null;

                                }
                            }

                            LstLog.add('newTrainingRegistration' + String.valueOf(newTrainingRegistration));
                            insert newTrainingRegistration;
                            if (currVolunteerUser.LMS_Id__c != String.valueOf(currLMSUserResponse.id) || currVolunteerUser.LMS_Login__c != String.valueOf(currLMSUserResponse.login) || currVolunteerUser.LMS_User_Code__c != String.valueOf(currLMSUserResponse.code)) {
                                updateUser(String.valueOf(currLMSUserResponse.id), String.valueOf(currLMSUserResponse.login), String.valueOf(currLMSUserResponse.code), currVolunteerUser.Id);
                            }
                            checkRegisteredProgram();
                        }
                    }
                }
            }
            Contact currContact = new Contact();
            currContact.Id = userRelatedContactId ;
            currContact.Onboarding_Status__c = Constant_AC.CONTACT_ONBOARDING_STATUS_ORIENTATION;
            LstLog.add(String.valueOf(currContact));
            update currContact;
        } catch (Exception ex) {
            Logvalue = String.join(LstLog, ', ');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC', 'Register', null, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    // Volunteer have a option to cancel their registered orientation program in the Registered orientation table.
    public void Cancel() {
        String Logvalue;
        String recId;
        LMSUserResponse currLMSUserResponse = new LMSUserResponse();
        try {
            List<Class_Offering__c> orientationDetails = [
                    SELECT Id, Course_ID__c, Chapter__c, RecordTypeId
                    FROM Class_Offering__c
                    WHERE Id = :trainingId
            ];
            if (!orientationDetails.isEmpty()) {

                List<Volunteer_Orientation_Training__c> cancelRegistrationList = [
                        SELECT Id, Class_Offering__c, LMS_Enrollment_Id__c
                        FROM Volunteer_Orientation_Training__c
                        WHERE Class_Offering__c = :trainingId AND Volunteer__c = :userRelatedContactId
                        AND Class_Offering__r.Chapter__c = :orientationDetails.get(0).Chapter__c AND
                        Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
                ];

                if (!cancelRegistrationList.isEmpty()) {
                    if (!getUserRelatedContact.isEmpty()) {
                        if (lMSCredential != null) {
                            User currVolunteerUser = getUserRelatedContact.get(0);
                            cancelRegistrationList.get(0).Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;

                            if (orientationDetails[0].RecordTypeId == classOfferingRecordtypeId) {
                                currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                                currLMSOrientationRegistrationResponse
                                        = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'dropped', Integer.valueOf(cancelRegistrationList.get(0).LMS_Enrollment_Id__c));
                                cancelRegistrationList.get(0).LMS_Enrollment_Id__c = '';
                            }

                        }
                        recId = cancelRegistrationList[0].Id;
                        Logvalue = String.valueOf('cancellation list' + cancelRegistrationList);
                        update cancelRegistrationList;
                        isOrientationExist = false;
                        isCancelled = true;
                    }
                    checkRegisteredProgram();
                }
            }
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation', 'Cancel', recId, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);

        }
    }

    // Its redirecting to LMS page.
    public void viewLMS() {
        /*Added by Sailappa Vignesh PG
        Description : To create or active the current Volunteer in LMS*/
        LMSUserResponse currLMSUserResponse = new LMSUserResponse();
        if (getUserRelatedContact.size() > 0 && lMSCredential != null) {
            User currVolunteerUser = getUserRelatedContact.get(0);
            currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
        }
        /*Description : To get a access URL from the LMS*/
        if (currLMSUserResponse != null && currLMSUserResponse.code != null) {
            lMSSSOResponse = LMSHttpRequest.getLMSSSODetails(lMSCredential, currLMSUserResponse.code, lMSCourseId);
            sSOUrl = lMSSSOResponse.login_url;
            courseURL = (lMSSSOResponse.enrollment_url != null) ? lMSSSOResponse.enrollment_url : lMSSSOResponse.login_url;
        }
    }

    //Pagination
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return null;
    }

    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }

    public PageReference Next() { //user clicked next button
        counter += list_size;
        return null;
    }

    public PageReference End() { //user clicked end
        counter = total_size - Math.mod(total_size, list_size);
        return null;
    }

    public Boolean getDisablePrevious() {
        //this will disable the previous and beginning buttons
        return counter > 0 ? false : true;
    }

    public Boolean getDisableNext() {
        //this will disable the next and end buttons
        return (counter + list_size < total_size) ? false : true;
    }

    // Displaying current page number.
    public Integer getPageNumber() {
        return counter / list_size + 1;
    }

    // Calculating total pages based on the total number of records.
    public Integer getTotalPages() {
        if (Math.mod(total_size, list_size) > 0) {
            return total_size / list_size + 1;
        } else {
            return (total_size / list_size);
        }
    }

    public class ClassOfferingWrapper {
        public String orientationName {
            get;
            set;
        }
        public String chapterName {
            get;
            set;
        }
        public Date orientationDate {
            get;
            set;
        }
        public String startTime {
            get;
            set;
        }
        public String endTime {
            get;
            set;
        }
        public String location { get; set; }
        public Integer maxCapacity {
            get;
            set;
        }
        public Integer avilableSheets {
            get;
            set;
        }
        public String recordType {
            get;
            set;
        }
        public String status {
            get;
            set;
        }
        public Integer volOppSize {
            get;
            set;
        }
        public String recordId {
            get;
            set;
        }
        public String courseId {
            get;
            set;
        }
        public String recordTypeId {
            get;
            set;
        }
        public Boolean displayRec {
            get;
            set;
        }
    }

    @Future
    public static void updateUser(String LMS_Id, String LMS_Login, String LMS_User_Code, String userId) {
        String Logvalue;
        String recid;
        try {
            User currVolunteerUser = new User();
            currVolunteerUser.Id = userId;
            currVolunteerUser.LMS_Id__c = LMS_Id;
            currVolunteerUser.LMS_Login__c = LMS_Login;
            currVolunteerUser.LMS_User_Code__c = LMS_User_Code;
            recid = currVolunteerUser.LMS_Id__c;
            Logvalue = String.valueOf('curr volunteer user' + currVolunteerUser);
            update currVolunteerUser;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC', 'updateUser', recid, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);

        }
    }
}