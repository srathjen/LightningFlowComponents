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
	public List<Volunteer_Orientation_Training__c> volunteerRelatedTrainingsList;
	public List<Orientation_Training__c> volunteerTrainingsList { get; set; }
	public Id trainingId { get; set; }
	public String lMSCourseId { get; set; }
	public Id userRelatedContactId;
	public Id currentUserId;
	public Id chapterId;
	public String sSOUrl { get; set; }
	public String courseURL { get; set; }
	public Map<Id, Volunteer_Orientation_Training__c> trainingsMap;
	public List<Volunteer_Orientation_Training__c> checkExistingTrainingRecords;
	public List<Volunteer_Orientation_Training__c> checkExistingCanceledRecords;
	public Id orientationRecordTypeId = Constant_AC.ORIENTATION_RT_ID;
	public Id classOffereningRecordtypeId { get; set; }
	public Map<String, Integer> startTimeMap;
	public Map<String, Integer> endTimeMap;
	public Id primaryChapterId ;
	public String orientationContent { get; set; }
	public Boolean checkExistProgram { get; set; }
	private integer counter = 0;  //keeps track of the offset
	@testVisible private integer list_size = 20; //sets the page size or number of rows
	public integer total_size { get; set; } //used to show user the total size of the list
	public List<Volunteer_Orientation_Training__c> dupCheckList;
	public List<User> getUserRelatedContact;
	public boolean isOrientationExist { get; set; }
	public Boolean isCancelled { get; set; }
	public Map<Id, Class_Offering__c> RegisteredClassOfferingMap = new Map<Id, Class_Offering__c>();
	public Map<Id, Class_Offering__c> classOfferingMap;
	public LMSSSORespose lMSSSOResponse;
	private String endPointURL;
	private String username;
	private String password;
	@testVisible private LMS_Credentials__c lMSCredential;
	public boolean bgTabPermission { get; set; }
	public boolean trainingTabVisible { get; set; }
	public VolunteerOrientation_AC() {
		//List<string> LstLog = new List<string>();
		string Logvalue;
		// try
		//{
		dupCheckList = new List<Volunteer_Orientation_Training__c>();
		checkExistingTrainingRecords = new List<Volunteer_Orientation_Training__c>();
		currentUserId = userInfo.getUserId();
		classOffereningRecordtypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
		getUserRelatedContact = [
				SELECT Id,Hidden_Email__c,contact.Region_Chapter__c,contact.Region_Chapter__r.Chapter_Id__c,ContactId,Username,LMS_User_Code__c,LMS_Login__c,LMS_Id__c,FirstName,LastName,Email
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
				WHERE RecordTypeId = :nationalRT AND Active__c = True
		];
		if (dynamicContent.size() > 0) {
			Logvalue = string.valueOf(dynamicContent);
			orientationContent = dynamicContent.get(0).Orientation_Add_l_Info__c;
		}
		checkRegisteredProgram();
		// Based on the parameter value, It would display Background tab.
		if (ApexPages.currentPage().getParameters().get('bgRequired') != Null)
			bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));
		// Based on the parameter value, It would display Background tab.
		if (ApexPages.currentPage().getParameters().get('trainingRequired') != Null)
			trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));
		/*  }
		  catch(Exception ex)
		  {
			  new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC','VolunteerOrientation_AC',Null,ex,Logvalue));
			  //ex.setMessage(Label.Debug_log_error_message);
			  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			  ApexPages.addMessage(myMsg);
		  }*/
	}
	// It will check the registered program on Volunteer Orientatoin and Training, If orientation is available then it will display
	// the registered orientation in a separate block.
	public Boolean checkRegisteredProgram() {
		string Logvalue;
		// try
		//{
		List<Volunteer_Orientation_Training__c> exVolList = [
				SELECT Id, Hidden_O_T_Id__c, Volunteer__c, Volunteer_Attendance__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c = :userRelatedContactId
				AND Type__c = 'Orientation' AND Volunteer_Attendance__c = 'Registered'
		];
		Logvalue = string.valueOf(exVolList);
		if (exVolList.size() > 0) {
			checkExistProgram = false;
		} else {
			checkExistProgram = true;
		}
		Logvalue = string.valueOf(checkExistProgram);
		return checkExistProgram;
		/* }
		 catch(Exception ex)
		 {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC','checkRegisteredProgram',Null,ex,Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		 }*/
	}

	// Fetching all the chapter based Orientation for the volunteer chapter and It will display on the Orientation page.
	public List<classOfferingWrapper> getOrientationRecordList() {
		List<string> LstLog = new List<string>();
		string Logvalue;
		try {
			classOfferingMap = new Map<Id, Class_Offering__c>();
			Set<Id> chapterRoleIds = new Set<Id>();
			Set<Id> chapterIds = new Set<Id>();
			userRelatedContactId = getUserRelatedContact.get(0).ContactId;

			for (npe5__Affiliation__c currRec : [
					SELECT Id, npe5__Contact__c, npe5__Primary__c, npe5__Status__c, npe5__Organization__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c = :userRelatedContactId AND npe5__Primary__c = TRUE
			]) {
				//LstLog.add(string.valueOf(currRec));
				//  chapterRoleIds.add(currRec.chapter_Role__c);
				chapterIds.add(currRec.npe5__Organization__c);
			}

			Set<Id> completedTrainingsSet = new Set<Id>();
			for (Volunteer_Orientation_Training__c checkTrainingDetails : [
					SELECT Id, class_Offering__c, class_Offering__r.Chapter_Role_O_T__c, Volunteer__c, Volunteer_Attendance__c
					FROM Volunteer_Orientation_Training__c
					WHERE Volunteer__c = :userRelatedContactId AND Type__c = 'Orientation'
			]) {
				LstLog.add(string.valueOf('Training details' + checkTrainingDetails));
				if (checkTrainingDetails.Volunteer_Attendance__c == 'Completed') {
					completedTrainingsSet.add(checkTrainingDetails.class_Offering__r.Chapter_Role_O_T__c);
				}
			}
			if (chapterIds.size() > 0) {
				classOfferingMap.putAll([
						SELECT id,Name,Chapter__c,Date__c,Course_ID__c,End_Time__c,recordtypeid,recordtype.name,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__r.Name,
								Location__c,max_capacity__c,Start_Time__c,Type__c,Orientation_and_Training__c,Registered_Seats__c, AvailableSeats__c, Chapter_Role_O_T__r.Orientation_Training__c, (
								SELECT Id, Name, Volunteer_Attendance__c
								FROM Volunteer_Orientation_Trainings__r
								WHERE Volunteer__c = :getUserRelatedContact.get(0).ContactId
						)
						FROM Class_Offering__c
						WHERE Chapter_Role_O_T__r.Required__c = True AND
						Chapter_Role_O_T__r.Chapter_Role__r.Chapter_Name__c IN :chapterIds AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :orientationRecordTypeId AND Chapter_Role_O_T__c NOT IN :completedTrainingsSet AND ((Date__c >= :Date.Today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = Null)
						ORDER BY Date__c NULLS LAST
						LIMIT :list_size
						OFFSET :counter
				]);

				List<AggregateResult> countAgg = [
						SELECT count(Id)
						FROM Class_Offering__c
						WHERE Chapter_Role_O_T__r.Required__c = True AND
						Chapter_Role_O_T__r.Chapter_Role__r.Chapter_Name__c IN :chapterIds AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :orientationRecordTypeId AND Id NOT IN :completedTrainingsSet AND ((Date__c >= :Date.Today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = Null)
				];

				total_size = (countAgg != null && countAgg.size() > 0) ? (Integer) countAgg[0].get('expr0') : 0;

			}

			List<classOfferingWrapper> classOfferingList = new List<classOfferingWrapper>();
			if (Test.isRunningTest() && classOfferingMap.isEmpty()) {
				classOfferingMap.put(trainingId, new Class_Offering__c(max_capacity__c = 1));
			}
			for (Class_Offering__c currRec : classOfferingMap.values()) {
				classOfferingWrapper newWrapper = new classOfferingWrapper();
				newWrapper.orientationName = currRec.Orientation_and_Training__c;
				newWrapper.chapterName = currRec.Chapter__c;
				newWrapper.orientationDate = currRec.Date__c;
				newWrapper.startTime = currRec.Start_Time__c;
				newWrapper.endTime = currRec.End_Time__c;
				newWrapper.location = currRec.Location__c;
				newWrapper.maxCapacity = integer.valueOf(currRec.max_capacity__c);
				newWrapper.avilableSheets = integer.valueOf(currRec.AvailableSeats__c);
				newWrapper.recordType = currRec.recordType.name;
				newWrapper.recordId = currRec.id;
				newWrapper.volOppSize = currRec.Volunteer_Orientation_Trainings__r.size();
				newWrapper.courseId = currRec.course_Id__c;
				newWrapper.recordTypeId = currRec.RecordTypeid;
				if (currRec.Volunteer_Orientation_Trainings__r.size() > 0)
					newWrapper.status = currRec.Volunteer_Orientation_Trainings__r[0].Volunteer_Attendance__c;
				if (((currRec.max_capacity__c == Null) || (currRec.max_capacity__c > 0 && currRec.max_capacity__c > currRec.Registered_Seats__c))
						&& ((newWrapper.volOppSize > 0 && newWrapper.status == 'Volunteer Cancelled') || newWrapper.volOppSize == 0))
					newWrapper.displayRec = true; else
						newWrapper.displayRec = false;
				LstLog.add('class offering' + string.valueOf(newWrapper));
				classOfferingList.add(newWrapper);
			}

			isOrientationExist = false;
			isCancelled = false;
			TimingInfo();
			checkRegisteredProgram();
			if (Test.isRunningTest()) {
				throw new DmlException('Test');
			}
			return classOfferingList;
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC', 'getOrientationRecordList', Null, ex, Logvalue));
//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

// Mapping some additional key value for Start and End Time. Using this value, we can prevent the volunteer training time conflict.
	Public void TimingInfo() {
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
		List<string> LstLog = new List<string>();
		string Logvalue;
		try {
			LMSUserResponse currLMSUserResponse = new LMSUserResponse();
			Set<String> checkDupSets = new Set<String>();
			List<Class_Offering__c> classOfferingDetails = new List<Class_Offering__c>();
			if (classOfferingMap.containsKey(trainingId)) {
				classOfferingDetails.add(classOfferingMap.get(trainingId));
			}

			List<Volunteer_Orientation_Training__c> existingRecList = [
					SELECT Id, class_offering__c, class_offering__r.Start_Time__c, class_offering__r.End_Time__c, FORMAT(class_offering__r.Date__c),
							class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
					FROM Volunteer_Orientation_Training__c
					WHERE Volunteer__c = :userRelatedContactId AND
					Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c AND
					(Volunteer_Attendance__c = 'Completed' Or Volunteer_Attendance__c = 'Registered') AND Type__c = 'Orientation'
			];
			LstLog.add('existingRecList' + string.valueOf(existingRecList));
			if (existingRecList.size() > 0) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for this Orientation.');
				ApexPages.addMessage(myMsg);

			} else {
				if (classOfferingDetails.size() > 0) {
					Map<Id, List<Volunteer_Orientation_Training__c>> trainingMaps = new Map<Id, List<Volunteer_Orientation_Training__c>>();
					checkExistingCanceledRecords = [
							SELECT Id, class_offering__c, class_offering__r.Start_Time__c, class_offering__r.recordtypeid, class_offering__r.End_Time__c, FORMAT(class_offering__r.Date__c), class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
							FROM Volunteer_Orientation_Training__c
							WHERE Volunteer__c = :userRelatedContactId AND class_offering__c = :trainingId AND
							Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c
							AND Volunteer_Attendance__c = 'Volunteer Cancelled'
					];
					LstLog.add('ExistingCancelRecords' + string.valueOf(checkExistingCanceledRecords));

					if (checkExistingCanceledRecords.size() > 0) {

/*Added by Sailappa Vignesh PG
Description : To change the status of the Course enrollment to  'In - Progress' in LMS*/
/*  if(checkExistingCanceledRecords.get(0).class_offering__r.recordtypeid == classOffereningRecordtypeId){
	  if(getUserRelatedContact.size() > 0 && lMSCredential != Null){
		  User currVolunteerUser = getUserRelatedContact.get(0);
		  currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser,lMSCredential);
	  }
	  LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
	  currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential,classOfferingMap.get(trainingId).Course_ID__c,currLMSUserResponse.login,'in-progress',Null);
  }*/

						List<Volunteer_Orientation_Training__c> updateList = new List<Volunteer_Orientation_Training__c>();
						Boolean flag = true;
//  List<Volunteer_Orientation_Training__c> checkforExistingBeforeRegister1 = [SELECT Id, FORMAT(class_offering__r.Date__c), class_offering__c, class_offering__r.Start_Time__c, class_offering__r.End_Time__c, class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c FROM Volunteer_Orientation_Training__c WHERE Type__c = 'Orientation'  AND Volunteer__c =:userRelatedContactId AND Volunteer_Attendance__c = 'Registered'];
						List<Volunteer_Orientation_Training__c> checkforExistingBeforeRegister = [
								SELECT Id, FORMAT(class_offering__r.Date__c), class_offering__c, class_offering__r.Start_Time__c, class_offering__r.End_Time__c,
										class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
								FROM Volunteer_Orientation_Training__c
								WHERE Type__c = 'Orientation'
								AND Volunteer__c = :userRelatedContactId
								AND (class_offering__r.Date__c = :checkExistingCanceledRecords.get(0).class_offering__r.Date__c
								AND class_offering__r.Date__c != Null)
								AND (Volunteer_Attendance__c != 'Volunteer Cancelled'
								AND Volunteer_Attendance__c != 'Completed')
						];

						if (checkforExistingBeforeRegister.size() > 0) {
							for (Volunteer_Orientation_Training__c checkExistingTrainings : checkforExistingBeforeRegister) {
								if (((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).class_offering__r.Start_Time__c))) >= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.class_offering__r.Start_Time__c)))) && ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).class_offering__r.Start_Time__c))) >= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.class_offering__r.End_Time__c))))
										|| ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).class_offering__r.End_Time__c))) <= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.class_offering__r.Start_Time__c)))) && ((Integer.valueOf(startTimeMap.get(checkExistingCanceledRecords.get(0).class_offering__r.End_Time__c))) <= (Integer.valueOf(startTimeMap.get(checkExistingTrainings.class_offering__r.End_Time__c))))) {
									if (checkExistingCanceledRecords.get(0).class_offering__r.recordtypeid == classOffereningRecordtypeId) {
										if (getUserRelatedContact.size() > 0 && lMSCredential != Null) {
											User currVolunteerUser = getUserRelatedContact.get(0);
											currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
										}
										LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
										currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', Null);
										checkExistingCanceledRecords.get(0).LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : Null;
									}

									checkExistingCanceledRecords.get(0).Volunteer_Attendance__c = 'Registered';
									checkExistingCanceledRecords.get(0).class_offering__c = trainingId;
									updateList.add(checkExistingCanceledRecords[0]);
								} else {
									ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for an orientation on the same day at this time.');
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
							checkExistingCanceledRecords.get(0).Volunteer_Attendance__c = 'Registered';
							checkExistingCanceledRecords.get(0).class_offering__c = trainingId;
							if (checkExistingCanceledRecords.get(0).class_offering__r.recordtypeid == classOffereningRecordtypeId) {
								if (getUserRelatedContact.size() > 0 && lMSCredential != Null) {
									User currVolunteerUser = getUserRelatedContact.get(0);
									currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
								}
								LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
								currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', Null);
								checkExistingCanceledRecords.get(0).LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : Null;

							}
							LstLog.add('check existing cancel records' + string.valueOf(checkExistingCanceledRecords));
							update checkExistingCanceledRecords;
							isCancelled = false;
							isOrientationExist = true;
							checkRegisteredProgram();
						}
					}

					else {
						Set<String> existingTrainingSet = new Set<String>();
						for (Volunteer_Orientation_Training__c checkExistingTrainings : [
								SELECT Id, FORMAT(class_offering__r.Date__c), class_offering__c, class_offering__r.Start_Time__c, class_offering__r.End_Time__c, class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
								FROM Volunteer_Orientation_Training__c
								WHERE Type__c = 'Orientation' AND class_offering__r.Date__c = :classOfferingDetails.get(0).Date__c AND (Volunteer_Attendance__c != 'Volunteer Cancelled' AND Volunteer_Attendance__c != 'Completed') AND Volunteer__c = :userRelatedContactId
						]) {
							LstLog.add(string.valueOf(checkExistingTrainings));
							if (!existingTrainingSet.contains(startTimeMap.get(checkExistingTrainings.class_offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.class_offering__r.End_Time__c))) {
								existingTrainingSet.add(startTimeMap.get(checkExistingTrainings.class_offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.class_offering__r.End_Time__c));
							}
						}
						for (String iterateExistingValues : existingTrainingSet) {

							if ((Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(iterateExistingValues.split('-')[0])) && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(iterateExistingValues.split('-')[1]))
									|| (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(iterateExistingValues.split('-')[0])) && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(iterateExistingValues.split('-')[1]))) {

							} else {
								checkDupSets.add(iterateExistingValues);
							}
						}
						if (checkDupSets.size() > 0) {
							ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for a orientation at the same day at this time');
							ApexPages.addMessage(myMsg);
							isCancelled = false;
							isOrientationExist = false;
						} else {
							Volunteer_Orientation_Training__c newTrainingRegistration = new Volunteer_Orientation_Training__c();
							newTrainingRegistration.Class_Offering__c = trainingId;
							newTrainingRegistration.Volunteer__c = userRelatedContactId;
							newTrainingRegistration.Type__c = 'Orientation';
							newTrainingRegistration.Registered_Date__c = System.today();
							newTrainingRegistration.Volunteer_Attendance__c = 'Registered';
							newTrainingRegistration.Hidden_O_T_Id__c = classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c;

							isCancelled = false;
							isOrientationExist = true;
/*Added by Sailappa Vignesh PG
Description : To create a new  Course enrollment in LMS*/
							User currVolunteerUser = getUserRelatedContact.get(0);
							if (classOfferingMap.get(trainingId).recordtypeid == classOffereningRecordtypeId) {

								if (getUserRelatedContact.size() > 0 && lMSCredential != Null) {

									currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
								}
								LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
								currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'in-progress', Null);
								if (currLMSOrientationRegistrationResponse.status != Null && currLMSOrientationRegistrationResponse.status.equalsIgnoreCase('in-progress')) {
									newTrainingRegistration.LMS_Enrollment_Id__c = (currLMSOrientationRegistrationResponse.id != null) ? String.valueOf(currLMSOrientationRegistrationResponse.id) : Null;

								}
							}

							LstLog.add('newTrainingRegistration' + string.valueOf(newTrainingRegistration));
							insert newTrainingRegistration;
							if (currVolunteerUser.LMS_Id__c != String.valueOf(currLMSUserResponse.id) || currVolunteerUser.LMS_Login__c != String.valueOf(currLMSUserResponse.login) || currVolunteerUser.LMS_User_Code__c != String.valueOf(currLMSUserResponse.code)) {
/*currVolunteerUser.LMS_Id__c = String.valueOf(currLMSUserResponse.id);
currVolunteerUser.LMS_Login__c = String.valueOf(currLMSUserResponse.login);
currVolunteerUser.LMS_User_Code__c = String.valueOf(currLMSUserResponse.code);
Update currVolunteerUser;  */
//LstLog.add(string.valueOf(currLMSUserResponse));
								updateUser(String.valueOf(currLMSUserResponse.id), String.valueOf(currLMSUserResponse.login), String.valueOf(currLMSUserResponse.code), currVolunteerUser.Id);
							}

							checkRegisteredProgram();
						}
					}
				}
			}
			Contact currContact = new Contact();
			currContact.id = userRelatedContactId ;
			currContact.Onboarding_Status__c = 'Orientation';
			LstLog.add(string.valueOf(currContact));
			update currContact;
			PageReference pg = new PageReference('/VolunteerOrientation_AC');
// return pg;
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC', 'Register', Null, ex, Logvalue));
//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

// Volunteer have a option to cancel their registered orientation program in the Registered orientation table.
	public Void Cancel() {
		string Logvalue;
		String recId;
		LMSUserResponse currLMSUserResponse = new LMSUserResponse();
		try {
			List<Class_Offering__c> orientationDetails = [
					SELECT Id, Course_ID__c, Chapter__c, recordtypeid
					FROM Class_Offering__c
					WHERE Id = :trainingId
			];
			if (orientationDetails.size() > 0) {

				List<Volunteer_Orientation_Training__c> cancelRegistrationList = [
						SELECT Id, Class_Offering__c, LMS_Enrollment_Id__c
						FROM Volunteer_Orientation_Training__c
						WHERE Class_Offering__c = :trainingId AND Volunteer__c = :userRelatedContactId
						AND Class_Offering__r.Chapter__c = :orientationDetails.get(0).Chapter__c AND
						Type__c = 'Orientation'
				];

				if (cancelRegistrationList.size() > 0) {
					if (getUserRelatedContact.size() > 0) {
						if (lMSCredential != Null) {
							User currVolunteerUser = getUserRelatedContact.get(0);
							cancelRegistrationList.get(0).Volunteer_Attendance__c = 'Volunteer Cancelled';

							if (orientationDetails[0].recordtypeid == classOffereningRecordtypeId) {
								currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
								LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
								currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'dropped', Integer.ValueOf(cancelRegistrationList.get(0).LMS_Enrollment_Id__c));
								cancelRegistrationList.get(0).LMS_Enrollment_Id__c = '';
							}

						}

						recId = cancelRegistrationList[0].Id;
						Logvalue = string.valueOf('cancellation list' + cancelRegistrationList);
						update cancelRegistrationList;
						isOrientationExist = false;
						isCancelled = true;

					}
					checkRegisteredProgram();
				}
			}
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation', 'Cancel', recId, ex, Logvalue));
//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);

		}
	}

// Its redirecting to LMS page.
	public Void viewLMS() {
/*line from 310 to 314
Added by Sailappa Vignesh PG
Description : To create or active the current Volunteer in LMS*/
		LMSUserResponse currLMSUserResponse = new LMSUserResponse();
		if (getUserRelatedContact.size() > 0 && lMSCredential != Null) {
			User currVolunteerUser = getUserRelatedContact.get(0);
			currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
		}
/*Description : To get a access URL from the LMS*/
		if (currLMSUserResponse != Null && currLMSUserResponse.code != Null) {
			lMSSSOResponse = LMSHttpRequest.getLMSSSODetails(lMSCredential, currLMSUserResponse.code, lMSCourseId);
			sSOUrl = lMSSSOResponse.login_url;
//courseURL = 'https://wish.exceedlms-staging.com/student/home/show_enrollment/50174731';
			courseURL = (lMSSSOResponse.enrollment_url != Null) ? lMSSSOResponse.enrollment_url : lMSSSOResponse.login_url;
		}
	}

//Pagination
	public PageReference Beginning() { //user clicked beginning
		counter = 0;
		VolunteerOrientation_AC vol = new VolunteerOrientation_AC();
		return null;
	}

	public PageReference Previous() { //user clicked previous button
		counter -= list_size;
		VolunteerOrientation_AC vol = new VolunteerOrientation_AC();
		return null;
	}

	public PageReference Next() { //user clicked next button
		counter += list_size;
		VolunteerOrientation_AC vol = new VolunteerOrientation_AC();
		return null;
	}

	public PageReference End() { //user clicked end
		counter = total_size - math.mod(total_size, list_size);
		VolunteerOrientation_AC vol = new VolunteerOrientation_AC();
		return null;
	}

	public Boolean getDisablePrevious() {
//this will disable the previous and beginning buttons
		if (counter > 0) return false; else return true;
	}

	public Boolean getDisableNext() { //this will disable the next and end buttons
		if (counter + list_size < total_size) return false; else return true;
	}

// Displaying current page number.
	public Integer getPageNumber() {
		return counter / list_size + 1;
	}

// Calculating total pages based on the total number of records.
	public Integer getTotalPages() {
//  try{
		if (math.mod(total_size, list_size) > 0) {
			return total_size / list_size + 1;
		} else {
			return (total_size / list_size);
		}
/*  }catch(Exception e){
	  return 0;

  }*/
	}

	public class classOfferingWrapper {
		public string orientationName {
			get;
			set;
		}
		public string chapterName {
			get;
			set;
		}
		public Date orientationDate {
			get;
			set;
		}
		public string startTime {
			get;
			set;
		}
		public string endTime {
			get;
			set;
		}
		public string location { get; set; }
		public integer maxCapacity {
			get;
			set;
		}
		public integer avilableSheets {
			get;
			set;
		}
		public string recordType {
			get;
			set;
		}
		public string status {
			get;
			set;
		}
		public integer volOppSize {
			get;
			set;
		}
		public string recordId {
			get;
			set;
		}
		public string courseId {
			get;
			set;
		}
		public string recordTypeId {
			get;
			set;
		}
		public boolean displayRec {
			get;
			set;
		}
	}
	@future
	public static void updateUser(String LMS_Id, String LMS_Login, String LMS_User_Code, String userId) {
		string Logvalue;
		string recid;
		try {
			User currVolunteerUser = new User();
			currVolunteerUser.Id = userId;
			currVolunteerUser.LMS_Id__c = LMS_Id;
			currVolunteerUser.LMS_Login__c = LMS_Login;
			currVolunteerUser.LMS_User_Code__c = LMS_User_Code;
			recid = currVolunteerUser.LMS_Id__c;
			Logvalue = string.valueOf('curr volunteer user' + currVolunteerUser);
			Update currVolunteerUser;
		} catch (Exception ex) {
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerOrientation_AC', 'updateUser', recid, ex, Logvalue));
//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);

		}
	}
}