/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Vennila Paramasivam
Date        : 7/28/2016
Description : It will display all the Required and Non Required Training(Chapter Role based Training) on Active Portal
Which are not completed by the volunteer. If user tries to register same training for different timing, It will
throw an error message. And also If the User register for multiple training at same timing that time also It will
throw an error message. Once the user registered for the training then VolunteerOpportunity Orientation and Training
Record will create with Registered status. If user cancelled the registered training then the status would update as
Cancelled.
*******************************************************************************************************************/

public class VolunteerActiveTraining_AC {

    public Id trainingId { get; set; }
    public Id userRelatedContactId;
    public Id currentUserId;
    public String lMSCourseId { get; set; }
    public String sSOUrl { get; set; }
    public String courseURL { get; set; }
    public Id classOffereningRecordtypeId { get; set; }
    public List<Volunteer_Orientation_Training__c> checkExistingTrainingRecords;
    public List<Volunteer_Orientation_Training__c> checkExistingCanceledRecords;
    public Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
    public Map<String, Integer> startTimeMap;
    public Map<String, Integer> endTimeMap;
    public String orientationContent { get; set; }
    public Boolean checkExistProgram { get; set; }
    private Integer counter = 0;  //keeps track of the offset
    private Integer list_size = 20; //sets the page size or number of rows
    public Integer total_size { get; set; } //used to show user the total size of the list
    public List<Volunteer_Orientation_Training__c> dupCheckList;
    List<User> getUserRelatedContact;
    public Boolean isTrainingExist { get; set; }
    public Boolean isCancelled { get; set; }
    public Boolean isCompleted { get; set; }
    public Map<Id, Class_Offering__c> classOfferingMap;
    public Boolean bgTabPermission { get; set; }
    public Boolean trainingTabVisible { get; set; }
    public LMSSSORespose lMSSSOResponse;
    private LMS_Credentials__c lMSCredential;

    public VolunteerActiveTraining_AC() {
        isCompleted = false;
        String Logvalue;
        dupCheckList = new List<Volunteer_Orientation_Training__c>();
        checkExistingTrainingRecords = new List<Volunteer_Orientation_Training__c>();
        currentUserId = UserInfo.getUserId();
        classOffereningRecordtypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        getUserRelatedContact = [
                SELECT Id, Contact.Region_Chapter__c, Hidden_Email__c, Contact.Region_Chapter__r.Chapter_Id__c,
                        Username, LMS_Login__c, LMS_Id__c, ContactId, LMS_User_Code__c, FirstName, LastName, Email
                FROM User
                WHERE Id = :currentUserId
        ];
        lMSCredential = LMS_Credentials__c.getValues('LMS Integration');
        userRelatedContactId = getUserRelatedContact.get(0).ContactId;
        Logvalue = String.valueOf(userRelatedContactId);
        Id nationalRT = Constant_AC.NATIONAL_RT_ID;

        // Displaying the Dynamic content on the portal.
        List<Dynamic_Content__c> dynamicContent = [
                SELECT Id, Training_Additional_Info__c,Chapter_Name__c
                FROM Dynamic_Content__c
                WHERE RecordTypeId = :nationalRT AND Active__c = TRUE
        ];
        if (!dynamicContent.isEmpty()) {
            orientationContent = dynamicContent.get(0).Training_Additional_Info__c;
            Logvalue = String.valueOf(orientationContent);
        }
        checkRegisteredProgram();
    }

    // It will check the registered program on Volunteer Orientatoin and Training, If training is available then it will display
    // the registered training in a separate block.
    public Boolean checkRegisteredProgram() {
        String Logvalue;
        List<Volunteer_Orientation_Training__c> exVolList = [
                SELECT Id, Hidden_O_T_Id__c, Volunteer__c, Volunteer_Attendance__c
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c = :userRelatedContactId AND Type__c = 'Training'
                AND (Volunteer_Attendance__c = 'Registered' OR Volunteer_Attendance__c = 'Completed')
        ];
        Logvalue = String.valueOf(exVolList);
        checkExistProgram = exVolList.isEmpty();
        Logvalue = String.valueOf(checkExistProgram);
        return checkExistProgram;
    }

    // Fetching all the chapter role based training for the volunteer chapter and It will display on the Training page
    // If that training not done by Volunteer.
    public List<ClassOfferingWrap> getTrainingRecordList() {
        List<String> LstLog = new List<String>();
        classOfferingMap = new Map<Id, Class_Offering__c>();
        Set<Id> chapterIds = new Set<Id>();
        Set<Id> chapterRoles = new Set<Id>();
        userRelatedContactId = getUserRelatedContact.get(0).ContactId;

        for (Volunteer_Roles__c currRec : [
                SELECT Id, Chapter_Role__c,Chapter_Role__r.Chapter_Name__c
                FROM Volunteer_Roles__c
                WHERE Volunteer_Name__c = :userRelatedContactId AND Sub_status__c != 'Under Chapter Review'
        ]) {
            LstLog.add(String.valueOf(currRec));
            chapterIds.add(currRec.Chapter_Role__r.Chapter_Name__c);
            chapterRoles.add(currRec.Chapter_Role__c);
        }
        for (Chapter_Role__c currRec : [
                SELECT Id
                FROM Chapter_Role__c
                WHERE Chapter_Name__c IN :chapterIds AND Role_Name__r.Name = 'All Roles'
        ]) {
            chapterRoles.add(currRec.Id);
        }
        Set<Id> completedTrainingsSet = new Set<Id>();
        for (Volunteer_Orientation_Training__c checkTrainingDetails : [
                SELECT Id, Class_Offering__c, Class_Offering__r.Chapter_Role_O_T__c, Volunteer__c, Volunteer_Attendance__c
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c = :userRelatedContactId AND Type__c = 'Training'
        ]) {
            LstLog.add(String.valueOf(checkTrainingDetails));
            if (checkTrainingDetails.Volunteer_Attendance__c == 'Completed') {
                completedTrainingsSet.add(checkTrainingDetails.Class_Offering__r.Chapter_Role_O_T__c);
            }
        }

        if (!chapterIds.isEmpty()) {
            classOfferingMap.putAll([
                    SELECT Id, Name,Chapter__c,Date__c,End_Time__c,Course_ID__c,RecordTypeId, RecordType.Name,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__r.Name,Chapter_Role_O_T__r.Chapter_Role__r.Background_Check_Required__c,
                            Location__c,max_capacity__c,Start_Time__c,Type__c,Orientation_and_Training__c,Registered_Seats__c, AvailableSeats__c, Chapter_Role_O_T__r.Orientation_Training__c, (
                            SELECT Id, Name, Volunteer_Attendance__c
                            FROM Volunteer_Orientation_Trainings__r
                            WHERE Volunteer__c = :getUserRelatedContact.get(0).ContactId
                    )
                    FROM
                            Class_Offering__c
                    WHERE
                    Chapter_Role_O_T__r.Chapter_Role__r.Chapter_Name__c IN :chapterIds
                    AND Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoles
                    AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
                    AND ((Date__c >= :Date.today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = NULL)
                    ORDER BY Name
                    LIMIT :list_size
                    OFFSET :counter
            ]);

            List<AggregateResult> countAgg = [
                    SELECT COUNT(Id)
                    FROM Class_Offering__c
                    WHERE Chapter_Role_O_T__r.Required__c = TRUE AND
                    Chapter_Role_O_T__r.Chapter_Role__r.Chapter_Name__c IN :chapterIds
                    AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId AND Date__c = NEXT_N_DAYS:180
            ];

            total_size = (countAgg != null && !countAgg.isEmpty()) ? (Integer) countAgg[0].get('expr0') : 0;
        }
        List<ClassOfferingWrap> classOfferingList = new List<ClassOfferingWrap>();
        for (Class_Offering__c currRec : classOfferingMap.values()) {
            ClassOfferingWrap newWrapper = new ClassOfferingWrap();
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
                    && ((newWrapper.volOppSize > 0 && newWrapper.status == 'Volunteer Cancelled') || newWrapper.volOppSize == 0)) {
                newWrapper.displayRec = true;
            } else {
                newWrapper.displayRec = false;
            }
            LstLog.add(String.valueOf(newWrapper));
            classOfferingList.add(newWrapper);
        }

        isTrainingExist = false;
        isCancelled = false;
        TimingInfo();

        checkRegisteredProgram();
        return classOfferingList;
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
    // If the volunteer registered the training same time for two diferent training, then it will throw and error message.
    public void Register() {
        List<String> LstLog = new List<String>();
        String Logvalue;
        String recId;
        try {

            LMSUserResponse currLMSUserResponse = new LMSUserResponse();
            Set<String> checkDupSets = new Set<String>();
            List<Class_Offering__c> classOfferingDetails = new List<Class_Offering__c>();
            Boolean activeBC = false;

            if (classOfferingMap.containsKey(trainingId)) {
                classOfferingDetails.add(classOfferingMap.get(trainingId));

            }
            Date todayDate = Date.today();
            List<Background_check__c> backgroundCheckList = [
                    SELECT Id,Status__c,Date__c,Current__c
                    FROM Background_check__c
                    WHERE Volunteer__c = :userRelatedContactId
            ];

            //WVC-2225 starts
            for (Background_check__c currentBC : backgroundCheckList) {
                if (currentBC.Current__c && currentBC.Status__c == 'Approved' && currentBC.Date__c > todayDate) {
                    activeBC = true;
                }
            }
            if (classOfferingMap.containsKey(trainingId) && classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Chapter_Role__r.Background_Check_Required__c && (backgroundCheckList.isEmpty())) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The training you have selected requires a completed background check.');
                ApexPages.addMessage(myMsg);
            } else if (classOfferingMap.containsKey(trainingId) && classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Chapter_Role__r.Background_Check_Required__c && (!backgroundCheckList.isEmpty()) && !activeBC) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You will receive an email from First Advantage, our background check provider, with specific details on how to complete the criminal background check process.');
                ApexPages.addMessage(myMsg);
            }
            //WVC-2225 end
            else {
                List<Volunteer_Orientation_Training__c> existingRecList = [
                        SELECT Id, Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.End_Time__c,FORMAT(Class_Offering__r.Date__c), Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                        FROM Volunteer_Orientation_Training__c
                        WHERE Volunteer__c = :userRelatedContactId AND Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c
                        AND (Volunteer_Attendance__c = 'Completed' OR Volunteer_Attendance__c = 'Registered') AND Type__c = 'Training'
                ];

                if (existingRecList.size() > 0 && !isCompleted) {
                    for (Volunteer_Orientation_Training__c currRec : existingRecList) {
                        LstLog.add(String.valueOf(currRec));
                        if (currRec.Volunteer_Attendance__c == 'Completed') {
                            isCompleted = true;
                        }
                    }
                    if (!(isCompleted)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for a training.');
                        ApexPages.addMessage(myMsg);
                    }
                }

                else {
                    if (classOfferingDetails.size() > 0) {
                        Map<Id, List<Volunteer_Orientation_Training__c>> trainingMaps = new Map<Id, List<Volunteer_Orientation_Training__c>>();
                        checkExistingCanceledRecords = [
                                SELECT Id, Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.RecordTypeId, Class_Offering__r.End_Time__c,FORMAT(Class_Offering__r.Date__c), Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c,LMS_Enrollment_Id__c
                                FROM Volunteer_Orientation_Training__c
                                WHERE Volunteer__c = :userRelatedContactId AND Class_Offering__c = :trainingId AND Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c AND Volunteer_Attendance__c = 'Volunteer Cancelled'
                        ];
                        if (!checkExistingCanceledRecords.isEmpty()) {
                            List<Volunteer_Orientation_Training__c> updateList = new List<Volunteer_Orientation_Training__c>();
                            Set<String> c = new Set<String>();
                            List<Volunteer_Orientation_Training__c> checkforExistingBeforeRegister = [
                                    SELECT Id, FORMAT(Class_Offering__r.Date__c), Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.End_Time__c, Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                                    FROM Volunteer_Orientation_Training__c
                                    WHERE Type__c = 'Training' AND Volunteer__c = :userRelatedContactId AND Class_Offering__r.Date__c = :checkExistingCanceledRecords.get(0).Class_Offering__r.Date__c AND (Volunteer_Attendance__c != 'Volunteer Cancelled' AND Volunteer_Attendance__c != 'Completed')
                            ];
                            if (checkforExistingBeforeRegister.size() > 0) {
                                for (Volunteer_Orientation_Training__c checkExistingTrainings : checkforExistingBeforeRegister) {

                                    if (((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.Start_Time__c))) >= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c)))) && ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.Start_Time__c))) >= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c))))
                                            || ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.End_Time__c))) <= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c)))) && ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).Class_Offering__r.End_Time__c))) <= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c))))) {
                                        checkExistingCanceledRecords.get(0).Volunteer_Attendance__c = 'Registered';
                                        checkExistingCanceledRecords.get(0).Class_Offering__c = trainingId;

                                        if (checkExistingCanceledRecords.get(0).Class_Offering__r.RecordTypeId == classOffereningRecordtypeId) {

                                            if (getUserRelatedContact.size() > 0 && lMSCredential != null) {
                                                User currVolunteerUser = getUserRelatedContact.get(0);
                                                currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                            }
                                            LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                                            currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', Null);
                                            checkExistingCanceledRecords.get(0).LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.Id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.Id) : Null;
                                        }

                                        updateList.add(checkExistingCanceledRecords[0]);

                                    } else {
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for a training on the same day at this time');
                                        ApexPages.addMessage(myMsg);
                                    }
                                }
                                if (updateList.size() > 0) {
                                    recId = checkExistingCanceledRecords[0].Id;
                                    LstLog.add(String.valueOf(updateList));
                                    update updateList;
                                    isCancelled = false;
                                    isTrainingExist = true;
                                    isCompleted = false;
                                    checkRegisteredProgram();
                                }

                            } else {
                                checkExistingCanceledRecords.get(0).Volunteer_Attendance__c = 'Registered';
                                checkExistingCanceledRecords.get(0).Class_Offering__c = trainingId;
                                if (checkExistingCanceledRecords.get(0).Class_Offering__r.RecordTypeId == classOffereningRecordtypeId) {
                                    if (getUserRelatedContact.size() > 0 && lMSCredential != null) {
                                        User currVolunteerUser = getUserRelatedContact.get(0);
                                        currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                    }
                                    LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                                    currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', null);
                                    checkExistingCanceledRecords.get(0).LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.Id) : null;
                                }
                                recId = checkExistingCanceledRecords[0].Id;
                                LstLog.add(String.valueOf(checkExistingCanceledRecords));
                                update checkExistingCanceledRecords;
                                isCancelled = false;
                                isCompleted = false;
                                isTrainingExist = true;
                                checkRegisteredProgram();
                            }
                        }

                        else {
                            Set<String> existingTrainingSet = new Set<String>();
                            for (Volunteer_Orientation_Training__c checkExistingTrainings : [
                                    SELECT Id, FORMAT(Class_Offering__r.Date__c), Class_Offering__c, Class_Offering__r.Start_Time__c, Class_Offering__r.End_Time__c, Class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
                                    FROM Volunteer_Orientation_Training__c
                                    WHERE Type__c = 'Training' AND Class_Offering__r.Date__c = :classOfferingDetails.get(0).Date__c AND (Volunteer_Attendance__c != 'Volunteer Cancelled' AND Volunteer_Attendance__c != 'Completed') AND Volunteer__c = :userRelatedContactId
                            ]) {

                                if (!existingTrainingSet.contains(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c))) {
                                    existingTrainingSet.add(startTimeMap.get(checkExistingTrainings.Class_Offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.Class_Offering__r.End_Time__c));
                                }
                            }
                            for (String iterateExistingValues : existingTrainingSet) {
                                if (classOfferingDetails.get(0).Start_Time__c != null && classOfferingDetails.get(0).End_Time__c != null) {
                                    if ((Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(iterateExistingValues.split('-')[0])) && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(iterateExistingValues.split('-')[1]))
                                            || (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(iterateExistingValues.split('-')[0])) && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(iterateExistingValues.split('-')[1]))) {

                                    } else {
                                        checkDupSets.add(iterateExistingValues);
                                    }
                                }
                            }
                            if (checkDupSets.size() > 0) {
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for a training on the same day at this time');
                                ApexPages.addMessage(myMsg);
                                isCancelled = false;
                                isTrainingExist = false;
                                isCompleted = false;
                            }

                            else {
                                Volunteer_Orientation_Training__c newTrainingRegistration = new Volunteer_Orientation_Training__c();
                                newTrainingRegistration.Class_Offering__c = trainingId;
                                newTrainingRegistration.Volunteer__c = userRelatedContactId;
                                newTrainingRegistration.Type__c = 'Training';
                                newTrainingRegistration.Registered_Date__c = System.today();
                                newTrainingRegistration.Volunteer_Attendance__c = 'Registered';
                                newTrainingRegistration.Hidden_O_T_Id__c = classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c;

                                User currVolunteerUser = getUserRelatedContact.get(0);
                                if (classOfferingMap.get(trainingId).RecordTypeId == classOffereningRecordtypeId) {
                                    if (!getUserRelatedContact.isEmpty() && lMSCredential != null) {
                                        currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                                    }
                                    LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();

                                    currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', null);
                                    if (currLMSOrientationRegistrationResponse.status != null && currLMSOrientationRegistrationResponse.status.equalsIgnoreCase('in-progress')) {
                                        newTrainingRegistration.LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : null;
                                    }
                                }

                                LstLog.add(String.valueOf(newTrainingRegistration));
                                insert newTrainingRegistration;
                                if (currVolunteerUser.LMS_Id__c != String.valueOf(currLMSUserResponse.id) || currVolunteerUser.LMS_Login__c != String.valueOf(currLMSUserResponse.login) || currVolunteerUser.LMS_User_Code__c != String.valueOf(currLMSUserResponse.code)) {
                                    updateUser(String.valueOf(currLMSUserResponse.id), String.valueOf(currLMSUserResponse.login), String.valueOf(currLMSUserResponse.code), currVolunteerUser.Id);
                                }
                                isCancelled = false;
                                isTrainingExist = true;
                                isCompleted = false;
                                checkRegisteredProgram();
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            Logvalue = String.join(LstLog, ', ');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActiveTraining_AC', 'Register', recId, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    // Volunteer have a option to cancel their registered trainig program in the Registered Training table.
    public void Cancel() {
        LMSUserResponse currLMSUserResponse = new LMSUserResponse();
        String Logvalue;
        String recId;
        try {
            List<Class_Offering__c> orientationDetails = [
                    SELECT Id, Course_ID__c, RecordTypeId, Chapter__c
                    FROM Class_Offering__c
                    WHERE Id = :trainingId
            ];
            if (!orientationDetails.isEmpty()) {
                List<Volunteer_Orientation_Training__c> cancelRegistrationList = [
                        SELECT Id, LMS_Enrollment_Id__c, Class_Offering__c
                        FROM Volunteer_Orientation_Training__c
                        WHERE Class_Offering__c = :trainingId AND Volunteer__c = :userRelatedContactId
                        AND Class_Offering__r.Chapter__c = :orientationDetails.get(0).Chapter__c AND Type__c = 'Training'
                ];
                if (!cancelRegistrationList.isEmpty() && !getUserRelatedContact.isEmpty() && lMSCredential != null) {
                    User currVolunteerUser = getUserRelatedContact.get(0);
                    cancelRegistrationList.get(0).Volunteer_Attendance__c = 'Volunteer Cancelled';
                    /*Added by Sailappa Vignesh PG
                    Description : To Update the Course enrollment status to 'dropped' in LMS*/
                    if (orientationDetails[0].RecordTypeId == classOffereningRecordtypeId) {
                        currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                        LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
                        currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'dropped', Integer.valueOf(cancelRegistrationList.get(0).LMS_Enrollment_Id__c));
                        cancelRegistrationList.get(0).LMS_Enrollment_Id__c = '';
                    }
                    recId = cancelRegistrationList[0].Id;
                    Logvalue = String.valueOf(cancelRegistrationList);
                    update cancelRegistrationList;
                    isTrainingExist = false;
                    isCancelled = true;
                    checkRegisteredProgram();
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActiveTraining_AC', 'Cancel', recId, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
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
        return (counter > 0) ? false : true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
        return (counter + list_size < total_size) ? false : true;
    }

    // Displaying current page number.
    public Integer getPageNumber() {
        return counter / list_size + 1;
    }

    public PageReference No() {
        PageReference pg = new PageReference('/VolunteerActiveTraining_VF');
        return pg;
    }

    // Calculating total pages based on the total number of records.
    public Integer getTotalPages() {
        try {
            if (Math.mod(total_size, list_size) > 0) {
                return total_size / list_size + 1;
            } else {
                return (total_size / list_size);
            }
        } catch (Exception e) {
            return 0;
        }
    }

    // Its redirecting to LMS page.
    public void viewLMS() {
        String recId;
        String Logvalue;
        try {
            LMSUserResponse currLMSUserResponse = new LMSUserResponse();
            if (!getUserRelatedContact.isEmpty() && lMSCredential != null) {
                User currVolunteerUser = getUserRelatedContact.get(0);
                recId = currVolunteerUser.Id;
                Logvalue = String.valueOf(currVolunteerUser);
                currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
            }

            /*Description : To get a access URL from the LMS*/
            if (currLMSUserResponse != null && currLMSUserResponse.code != null) {
                Logvalue += String.valueOf(currLMSUserResponse);
                lMSSSOResponse = LMSHttpRequest.getLMSSSODetails(lMSCredential, currLMSUserResponse.code, lMSCourseId);
                sSOUrl = lMSSSOResponse.login_url;
                courseURL = lMSSSOResponse.enrollment_url;

            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception e) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActiveTraining_AC', 'viewLMS', recId, e, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }

    }

    public class ClassOfferingWrap {
        public String orientationName { get; set; }
        public String chapterName { get; set; }
        public Date orientationDate { get; set; }
        public String startTime { get; set; }
        public String endTime { get; set; }
        public String location { get; set; }
        public Integer maxCapacity { get; set; }
        public Integer avilableSheets { get; set; }
        public String recordType { get; set; }
        public String status { get; set; }
        public Integer volOppSize { get; set; }
        public String recordId { get; set; }
        public String courseId { get; set; }
        public String recordTypeId { get; set; }
        public Boolean displayRec { get; set; }
    }

    @Future
    public static void updateUser(String LMS_Id, String LMS_Login, String LMS_User_Code, String userId) {
        String Logvalue;
        try {
            User currVolunteerUser = new User();
            currVolunteerUser.Id = userId;
            currVolunteerUser.LMS_Id__c = LMS_Id;
            currVolunteerUser.LMS_Login__c = LMS_Login;
            currVolunteerUser.LMS_User_Code__c = LMS_User_Code;
            Logvalue = String.valueOf(currVolunteerUser);
            update currVolunteerUser;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerActiveTraining_AC', 'updateUser', userId, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }
}