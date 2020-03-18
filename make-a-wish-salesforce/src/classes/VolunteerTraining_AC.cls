/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan 
Date        : 6/15/2016
Description : It will display all the Required Training(Chapter Role based Training) on Prospective Portal
Which are not completed by the volunteer. If user tries to register same training for different timing, It will 
throw an error message. And also If the User register for multiple training at same timing that time also It will
throw an error message. Once the user registered for the training then VolunteerOpportunity Orientation and Training 
Record will create with Registered status. If user cancelled the registered training then the status would update as 
Cancelled. 
*******************************************************************************************************************/

public class VolunteerTraining_AC {

	public List<Volunteer_Orientation_Training__c> volunteerRelatedTrainingsList;
	public List<Orientation_Training__c> volunteerTrainingsList { get; set; }
	public Id trainingId { get; set; }
	public Id userRelatedContactId;
	public Id currentUserId;
	public Id chapterId;
	public String lMSCourseId { get; set; }
	public String sSOUrl { get; set; }
	public String courseURL { get; set; }
	public Id classOffereningRecordtypeId { get; set; }
	public Map<Id, Volunteer_Orientation_Training__c> trainingsMap;
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
	public Map<Id, Class_Offering__c> RegisteredClassOfferingMap = new Map<Id, Class_Offering__c>();
	public Map<Id, Class_Offering__c> classOfferingMap;
	public Boolean bgTabPermission { get; set; }
	public Boolean trainingTabVisible { get; set; }
	public LMSSSORespose lMSSSOResponse;
	private String endPointURL;
	private String username;
	private String password;
	private LMS_Credentials__c lMSCredential;

	public VolunteerTraining_AC() {
		List<string> LstLog = new List<string>();
		string Logvalue;
		//  try
		//  {
		dupCheckList = new List<Volunteer_Orientation_Training__c>();
		checkExistingTrainingRecords = new List<Volunteer_Orientation_Training__c>();
		currentUserId = userInfo.getUserId();
		classOffereningRecordtypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
		getUserRelatedContact = [
				SELECT Id,Hidden_Email__c,contact.Region_Chapter__c,contact.Region_Chapter__r.Chapter_Id__c,Username, LMS_Login__c, LMS_Id__c, ContactId, LMS_User_Code__c,FirstName,LastName,Email
				FROM User
				WHERE Id = :currentUserId
		];
		lMSCredential = LMS_Credentials__c.getValues('LMS Integration');
		LstLog.add(string.valueOf(getUserRelatedContact));
		userRelatedContactId = getUserRelatedContact.get(0).ContactId;
		Id nationalRT = Constant_AC.NATIONAL_RT_ID;
		List<Dynamic_Content__c> dynamicContent = [
				SELECT Id, Training_Additional_Info__c,Chapter_Name__c
				FROM Dynamic_Content__c
				WHERE RecordTypeId = :nationalRT AND Active__c = True
		];
		LstLog.add(string.valueOf(dynamicContent));
		// Based on the parameter value, It would display Background tab.
		if (ApexPages.currentPage().getParameters().get('bgRequired') != Null)
			bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));

		if (ApexPages.currentPage().getParameters().get('trainingRequired') != Null)
			trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));
		if (dynamicContent.size() > 0) {
			orientationContent = dynamicContent.get(0).Training_Additional_Info__c;
		}
		checkRegisteredProgram();
		/*   }
			catch(Exception ex)
		   {
			   Logvalue = string.join(LstLog,', ');
			   new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC','VolunteerTraining_AC',Null,ex,Logvalue));
			   //ex.setMessage(Label.Debug_log_error_message);
			   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);            ApexPages.addMessage(myMsg);
		   }  */
	}

	// It will check the registered program on Volunteer Orientatoin and Training, If training is available then it will display
	// the registered training in a separate block.
	public Boolean CheckRegisteredProgram() {
		List<string> LstLog = new List<string>();
		string Logvalue;
		//  try
		//{
		List<Volunteer_Orientation_Training__c> exVolList = [
				SELECT Id, Hidden_O_T_Id__c, Volunteer__c, Volunteer_Attendance__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c = :userRelatedContactId
				AND Type__c = 'Training' AND Volunteer_Attendance__c = 'Registered'
		];
		LstLog.add(string.valueOf(exVolList));
		if (exVolList.size() > 0) {
			checkExistProgram = false;
		} else {
			checkExistProgram = true;
		}
		LstLog.add(string.valueOf(checkExistProgram));
		return checkExistProgram;
		/* }
		  catch(Exception ex)
		 {
			 Logvalue = string.join(LstLog,', ');
			 new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC','CheckRegisteredProgram',Null,ex,Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			 ApexPages.addMessage(myMsg);
			 return null;
		 } */
	}

	// Fetching all the chapter role based training for the volunteer chapter and It will display on the Training page
	// If that training not done by Volunteer.
	public List<classOfferingWrapper> getTrainingRecordList() {
		classOfferingMap = new Map<Id, Class_Offering__c>();
		Set<Id> chapterRoleIds = new Set<Id>();
		userRelatedContactId = getUserRelatedContact.get(0).ContactId;
		List<string> LstLog = new List<string>();
		string Logvalue;
		try {
			for (Volunteer_Roles__c currRec : [
					SELECT id, Chapter_Role__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c = :userRelatedContactId AND Sub_Status__c != 'Under Chapter Review'
			]) {
				LstLog.add(string.valueOf(currRec));
				chapterRoleIds.add(currRec.chapter_Role__c);
			}

			Set<Id> completedTrainingsSet = new Set<Id>();
			for (Volunteer_Orientation_Training__c checkTrainingDetails : [
					SELECT Id, class_Offering__c, class_Offering__r.Chapter_Role_O_T__c, Volunteer__c, Volunteer_Attendance__c
					FROM Volunteer_Orientation_Training__c
					WHERE Volunteer__c = :userRelatedContactId AND Type__c = 'Training'
			]) {
				LstLog.add(string.valueOf(checkTrainingDetails));
				if (checkTrainingDetails.Volunteer_Attendance__c == 'Completed') {
					completedTrainingsSet.add(checkTrainingDetails.class_Offering__r.Chapter_Role_O_T__c);
				}
			}

			if (chapterRoleIds.size() > 0) {
				classOfferingMap.putAll([
						SELECT id,Name,Chapter__c,Date__c,End_Time__c,Course_ID__c,recordtypeid,recordtype.name,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__r.Name,
								Location__c,max_capacity__c,Start_Time__c,Type__c,Orientation_and_Training__c,Registered_Seats__c, AvailableSeats__c, Chapter_Role_O_T__r.Orientation_Training__c, (
								SELECT Id, Name, Volunteer_Attendance__c
								FROM Volunteer_Orientation_Trainings__r
								WHERE Volunteer__c = :getUserRelatedContact.get(0).ContactId
						)
						FROM
								Class_Offering__c
						WHERE Chapter_Role_O_T__r.Required__c = true AND
						Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIds AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId AND Chapter_Role_O_T__c NOT IN :completedTrainingsSet AND ((Date__c >= :Date.Today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = Null)
						ORDER BY Date__c Nulls Last
						LIMIT :list_size
						OFFSET :counter
				]);

				List<AggregateResult> countAgg = [
						SELECT count(Id)
						FROM Class_Offering__c
						WHERE Chapter_Role_O_T__r.Required__c = true AND
						Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIds AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId AND Id NOT IN :completedTrainingsSet AND ((Date__c >= :Date.Today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = Null)
				];
				total_size = (countAgg != null && countAgg.size() > 0) ? (Integer) countAgg[0].get('expr0') : 0;
				LstLog.add(string.valueOf(total_size));
			}
			List<classOfferingWrapper> classOfferingList = new List<classOfferingWrapper>();
			for (Class_Offering__c currRec : classOfferingMap.values()) {
				LstLog.add(string.valueOf(currRec));
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
				classOfferingList.add(newWrapper);
			}

			isTrainingExist = false;
			isCancelled = false;
			TimingInfo();
			checkRegisteredProgram();
			return classOfferingList;
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC', 'getTrainingRecordList', Null, ex, Logvalue));
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
	// If the volunteer registered the training same time for two diferent training, then it will throw and error message.
	public void Register() {
		LMSUserResponse currLMSUserResponse = new LMSUserResponse();
		List<string> LstLog = new List<string>();
		String Logvalue;
		String recId;
		try {
			Set<String> checkDupSets = new Set<String>();
			List<Class_Offering__c> classOfferingDetails = new List<Class_Offering__c>();
			List<Volunteer_Orientation_Training__c> existingRecList;

			if (classOfferingMap.containsKey(trainingId)) {
				classOfferingDetails.add(classOfferingMap.get(trainingId));
				existingRecList = [
						SELECT Id, class_offering__c, class_offering__r.Start_Time__c, class_offering__r.End_Time__c, FORMAT(class_offering__r.Date__c), class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
						FROM Volunteer_Orientation_Training__c
						WHERE Volunteer__c = :userRelatedContactId AND Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c AND (Volunteer_Attendance__c = 'Completed' Or Volunteer_Attendance__c = 'Registered') AND Type__c = 'Training'
				];
				LstLog.add(string.valueOf(existingRecList));
			}

			if (existingRecList.size() > 0) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for this training.');
				ApexPages.addMessage(myMsg);
			}

			else {
				if (classOfferingDetails.size() > 0) {
					Map<Id, List<Volunteer_Orientation_Training__c>> trainingMaps = new Map<Id, List<Volunteer_Orientation_Training__c>>();
					checkExistingCanceledRecords = [
							SELECT Id, class_offering__c, class_offering__r.Start_Time__c, class_offering__r.recordtypeid, class_offering__r.End_Time__c,FORMAT(class_offering__r.Date__c), class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
							FROM Volunteer_Orientation_Training__c
							WHERE Volunteer__c = :userRelatedContactId AND class_offering__c = :trainingId AND Hidden_O_T_Id__c = :classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c AND Volunteer_Attendance__c = 'Volunteer Cancelled'
					];
					if (checkExistingCanceledRecords.size() > 0) {
						LstLog.add(string.valueOf(checkExistingCanceledRecords.get(0)));
						/* if(checkExistingCanceledRecords.get(0).class_offering__r.recordtypeid == classOffereningRecordtypeId){
							 if(getUserRelatedContact.size() > 0 && lMSCredential != Null){
								 User currVolunteerUser = getUserRelatedContact.get(0);
								 currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser,lMSCredential);
							 }
							 LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
							 currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential,classOfferingMap.get(trainingId).Course_ID__c,currLMSUserResponse.login,'in-progress',Null);
						 }*/

						List<Volunteer_Orientation_Training__c> updateList = new List<Volunteer_Orientation_Training__c>();
						Set<String> c = new Set<String>();
						List<Volunteer_Orientation_Training__c> checkforExistingBeforeRegister = [
								SELECT Id, FORMAT(class_Offering__r.Date__c), class_Offering__c, class_Offering__r.Start_Time__c, class_Offering__r.End_Time__c, class_Offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
								FROM Volunteer_Orientation_Training__c
								WHERE Type__c = 'Training' AND Volunteer__c = :userRelatedContactId AND (class_offering__r.Date__c = :checkExistingCanceledRecords.get(0).class_offering__r.Date__c AND class_offering__r.Date__c != Null) AND (Volunteer_Attendance__c != 'Volunteer Cancelled' AND Volunteer_Attendance__c != 'Completed')
						];
						if (checkforExistingBeforeRegister.size() > 0) {
							for (Volunteer_Orientation_Training__c checkExistingTrainings : checkforExistingBeforeRegister) {
								LstLog.add(string.valueOf(checkExistingTrainings));
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
									ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for a training on the same day at this time');
									ApexPages.addMessage(myMsg);
									// return null;
								}
							}
							if (updateList.size() > 0) {
								recId = checkExistingCanceledRecords[0].id;
								LstLog.add(string.valueOf(checkExistingCanceledRecords));
								update updateList;
								isCancelled = false;
								isTrainingExist = true;
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
							recId = checkExistingCanceledRecords[0].id;
							LstLog.add(string.valueOf(checkExistingCanceledRecords));
							update checkExistingCanceledRecords;
							isCancelled = false;
							isTrainingExist = true;
							checkRegisteredProgram();
						}

					} else {
						Set<String> existingTrainingSet = new Set<String>();
						for (Volunteer_Orientation_Training__c checkExistingTrainings : [
								SELECT Id, FORMAT(class_offering__r.Date__c), class_offering__c, class_offering__r.Start_Time__c, class_offering__r.End_Time__c, class_offering__r.Chapter__c, Volunteer__c, Volunteer_Attendance__c
								FROM Volunteer_Orientation_Training__c
								WHERE Type__c = 'Training' AND class_offering__r.Date__c = :classOfferingDetails.get(0).Date__c AND (Volunteer_Attendance__c != 'Volunteer Cancelled' AND Volunteer_Attendance__c != 'Completed') AND Volunteer__c = :userRelatedContactId
						]) {
							LstLog.add(string.valueOf(checkExistingTrainings));
							if (!existingTrainingSet.contains(startTimeMap.get(checkExistingTrainings.class_offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.class_offering__r.End_Time__c))) {
								existingTrainingSet.add(startTimeMap.get(checkExistingTrainings.class_offering__r.Start_Time__c) + '-' + endTimeMap.get(checkExistingTrainings.class_offering__r.End_Time__c));
							}
						}
						for (String exstingTraining : existingTrainingSet) {
							LstLog.add(string.valueOf(exstingTraining));
							if ((Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(exstingTraining.split('-')[0])) && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).Start_Time__c)) >= Integer.valueOf(exstingTraining.split('-')[1]))
									|| (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(exstingTraining.split('-')[0])) && (Integer.valueOf(startTimeMap.get(classOfferingDetails.get(0).End_Time__c)) <= Integer.valueOf(exstingTraining.split('-')[1]))) {
							} else {
								checkDupSets.add(exstingTraining);
							}
						}
						if (checkDupSets.size() > 0) {
							ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already registered for a training on the same day at this time.');
							ApexPages.addMessage(myMsg);
							isCancelled = false;
							isTrainingExist = false;
						} else {
							Volunteer_Orientation_Training__c newTrainingRegistration = new Volunteer_Orientation_Training__c();
							newTrainingRegistration.Class_Offering__c = trainingId;
							newTrainingRegistration.Volunteer__c = userRelatedContactId;
							newTrainingRegistration.Type__c = 'Training';
							newTrainingRegistration.Registered_Date__c = System.today();
							newTrainingRegistration.Volunteer_Attendance__c = 'Registered';
							newTrainingRegistration.Hidden_O_T_Id__c = classOfferingMap.get(trainingId).Chapter_Role_O_T__r.Orientation_Training__c;

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

							try {
								insert newTrainingRegistration;
								if (currVolunteerUser.LMS_Id__c != String.valueOf(currLMSUserResponse.id) || currVolunteerUser.LMS_Login__c != String.valueOf(currLMSUserResponse.login) || currVolunteerUser.LMS_User_Code__c != String.valueOf(currLMSUserResponse.code)) {
									updateUser(String.valueOf(currLMSUserResponse.id), String.valueOf(currLMSUserResponse.login), String.valueOf(currLMSUserResponse.code), currVolunteerUser.Id);
								}
								isCancelled = false;
								isTrainingExist = true;
							} catch (Exception ex) {
								System.debug('ex' + ex.getmessage());
								//return 'Exception caused, Please retry again or contact System Adminstrator';
							}
							checkRegisteredProgram();
						}
					}
				}
			}
			Contact currContact = new Contact();
			currContact.id = userRelatedContactId ;
			currContact.Onboarding_Status__c = 'Training';
			recId = currContact.id;
			LstLog.add(string.valueOf(currContact));
			update currContact;
			PageReference pg = new PageReference('/VolunteerTraining_VF');
			// return pg;
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC', 'Register', recId, ex, Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}

	}

	// Volunteer have a option to cancel their registered trainig program in the Registered Training table.
	public Void Cancel() {
		LMSUserResponse currLMSUserResponse = new LMSUserResponse();
		List<string> LstLog = new List<string>();
		string Logvalue;
		string recId;
		try {
			List<Class_Offering__c> orientationDetails = [
					SELECT Id, Course_ID__c,recordtypeid, Chapter__c
					FROM Class_Offering__c
					WHERE Id = :trainingId
			];
			if (orientationDetails.size() > 0) {
				LstLog.add(string.valueOf(orientationDetails[0]));
				List<Volunteer_Orientation_Training__c> cancelRegistrationList = [
						SELECT Id,LMS_Enrollment_Id__c,Class_Offering__c /*Orientation_Training__r.Chapter_Name__c*/
						FROM Volunteer_Orientation_Training__c
						WHERE Class_Offering__c = :trainingId AND Volunteer__c = :userRelatedContactId AND Class_Offering__r.Chapter__c = :orientationDetails.get(0).Chapter__c AND Type__c = 'Training'
				];
				if (cancelRegistrationList.size() > 0) {
					if (getUserRelatedContact.size() > 0 && lMSCredential != Null) {
						User currVolunteerUser = getUserRelatedContact.get(0);
						recId = cancelRegistrationList[0].id;
						cancelRegistrationList.get(0).Volunteer_Attendance__c = 'Volunteer Cancelled';
						cancelRegistrationList.get(0).LMS_Enrollment_Id__c = '';
						/*Added by Sailappa Vignesh PG
	Description : To Update the Course enrollment status to 'dropped' in LMS*/
						if (orientationDetails[0].recordtypeid == classOffereningRecordtypeId) {
							currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
							LMSOrientationRegistrationResponse currLMSOrientationRegistrationResponse = new LMSOrientationRegistrationResponse();
							currLMSOrientationRegistrationResponse = LMSHttpRequest.createOrUpdateEnrollment(lMSCredential, classOfferingMap.get(trainingId).Course_ID__c, currLMSUserResponse.login, 'dropped', Integer.ValueOf(cancelRegistrationList.get(0).LMS_Enrollment_Id__c));
						}
						LstLog.add(string.valueOf(cancelRegistrationList));
						update cancelRegistrationList;
						isTrainingExist = false;
						isCancelled = true;
					}
					checkRegisteredProgram();

				}
			}
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC', 'Cancel', recId, ex, Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	//Pagination
	public PageReference Beginning() { //user clicked beginning
		counter = 0;
		VolunteerTraining_AC vol = new VolunteerTraining_AC();
		return null;
	}

	public PageReference Previous() { //user clicked previous button
		counter -= list_size;
		VolunteerTraining_AC vol = new VolunteerTraining_AC();
		return null;
	}

	public PageReference Next() { //user clicked next button
		counter += list_size;
		VolunteerTraining_AC vol = new VolunteerTraining_AC();
		return null;
	}

	public PageReference End() { //user clicked end
		counter = total_size - math.mod(total_size, list_size);
		VolunteerTraining_AC vol = new VolunteerTraining_AC();
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
		string Logvalue;
		string recId;
		//   try{
		if (math.mod(total_size, list_size) > 0) {
			return total_size / list_size + 1;
		} else {
			return (total_size / list_size);
		}
		/* }catch(Exception ex){

			 new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC','getTotalPages',recId,ex,Logvalue));
			 //ex.setMessage(Label.Debug_log_error_message);
			 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			 ApexPages.addMessage(myMsg);
			 return null;
	 }*/
	}
	public void getLMSSSODetails(String volunteerLMSId) {
		string Logvalue;
		string recId;
		if (lMSCredential != Null) {
			HttpRequest request = new HttpRequest();
			request = LMSHttpRequest.createLMSHttpRequest(lMSCredential, lMSCredential.SSOEndPoint__c + volunteerLMSId, 'GET');
			Http http = new Http();
			HTTPResponse response;
			try {
				response = http.send(request);
				lMSSSOResponse = LMSSSORespose.parse(response.getBody());
				System.debug('lMSSSOResponse' + lMSSSOResponse);
			} catch (Exception ex) {

				new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC', 'getLMSSSODetails', recId, ex, Logvalue));
				//ex.setMessage(Label.Debug_log_error_message);
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
			}
		}
	}

	// Its redirecting to LMS page.
	public Void viewLMS() {
		string Logvalue;
		string recId;
		try {
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
				courseURL = lMSSSOResponse.enrollment_url;

			}
		} catch (Exception ex) {
			//Logvalue = string.join(LstLog,', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC', 'viewLMS', recId, ex, Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	public class classOfferingWrapper {
		public string orientationName { get; set; }
		public string chapterName { get; set; }
		public Date orientationDate { get; set; }
		public string startTime { get; set; }
		public string endTime { get; set; }
		public string location { get; set; }
		public integer maxCapacity { get; set; }
		public integer avilableSheets { get; set; }
		public string recordType { get; set; }
		public string status { get; set; }
		public integer volOppSize { get; set; }
		public string recordId { get; set; }
		public string courseId { get; set; }
		public string recordTypeId { get; set; }
		public boolean displayRec { get; set; }
	}

	@future
	public static void updateUser(String LMS_Id, String LMS_Login, String LMS_User_Code, String userId) {
		List<string> LstLog = new List<string>();
		string Logvalue;
		try {
			User currVolunteerUser = new User();
			currVolunteerUser.Id = userId;
			currVolunteerUser.LMS_Id__c = LMS_Id;
			currVolunteerUser.LMS_Login__c = LMS_Login;
			currVolunteerUser.LMS_User_Code__c = LMS_User_Code;
			LstLog.add(string.valueOf(currVolunteerUser));
			Update currVolunteerUser;
		} catch (Exception ex) {
			Logvalue = string.join(LstLog, ', ');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerTraining_AC', 'updateUser', userId, ex, Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}
}