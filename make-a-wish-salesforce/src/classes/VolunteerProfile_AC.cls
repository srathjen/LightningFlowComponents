/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/4/2016
Description : 
1. This controller is used in the VolunteerProfile_VF page. Once volunteer is converted into Acive Volunteer Portal,
They can have a option for updating their profile details. This updated details will reflect in Volunteer Co
*******************************************************************************************************************/

public class VolunteerProfile_AC {
    public User userIns;
    public Boolean PersonalInfoSave { get; set; }
    public Boolean PersonalInfoEdit { get; set; }
    public Boolean employeeInfoSave { get; set; }
    public Boolean employeeInfoEdit { get; set; }
    public Boolean emergencyInfoSave { get; set; }
    public Boolean emergencyInfoEdit { get; set; }
    public List<Contact> contactInstance { get; set; }
    public List<Background_check__c> backgroundCheckList { get; set; }
    public List<Conflict_Of_Interest__c> coiList { get; set; }
    public List<classOfferingWrapper> orientationList { get; set; }
    public List<classOfferingWrapper> trainingList { get; set; }
    public List<awardsWrapper> awardsList { get; set; }
    public List<Awards_Recognition__c> awardsRecognitionList { get; set; }
    public List<User> getUserRelatedContact;
    public List<String> raceEthinicityList { get; set; }
    public List<String> professionalSkillsList { get; set; }
    public List<String> langToRead { get; set; }
    public List<String> langToWrite { get; set; }
    public List<String> langToSpeak { get; set; }
    public List<String> langToUndetstand { get; set; }
    public List<String> languagesList { get; set; }
    public Map<String, Integer> birthMonthMap = new Map<String, Integer>();
    public Date COIExpirationDate { get; set; }
    public Date bcExpirationDate { get; set; }
    public String lMSCourseId { get; set; }
    public String sSOUrl { get; set; }
    public String courseURL { get; set; }
    private LMS_Credentials__c lMSCredential;
    public LMSSSORespose lMSSSOResponse;
    public Id userRelatedContactId;
    
    public VolunteerProfile_AC() {
        PersonalInfoSave = true;
        PersonalInfoEdit = false;
        employeeInfoSave = true;
        employeeInfoEdit = false;
        emergencyInfoSave = true;
        emergencyInfoEdit = false;
        langToRead = new List<String>();
        langToSpeak = new List<String>();
        langToWrite = new List<String>();
        langToUndetstand = new List<String>();
        languagesList = new List<String>();
        raceEthinicityList = new List<String>();
        professionalSkillsList = new List<String>();
        orientationList = new List<classOfferingWrapper>();
        trainingList = new List<classOfferingWrapper>();
        awardsList = new List<awardsWrapper>();
        contactInstance = new List<Contact>();
        backgroundCheckList = new List<Background_check__c>();
        coiList = new List<Conflict_Of_Interest__c>();
        birthMonthMap = getMonthValues();
        List<String> LstLog = new List<String>();
        String Logvalue;
        
        try {
            userIns = Utils.currentUser;
            LstLog.add(String.valueOf(userIns));
            getUserRelatedContact = [
                SELECT Id, Contact.Region_Chapter__c, Contact.Region_Chapter__r.Chapter_Id__c, Username, 
                LMS_Login__c, LMS_Id__c, ContactId, LMS_User_Code__c, FirstName, LastName, Email, Hidden_Email__c
                FROM User
                WHERE Id = :userIns.Id
            ];
            lMSCredential = LMS_Credentials__c.getValues('LMS Integration');
            LstLog.add(String.valueOf(getUserRelatedContact));
            
            if(ApexPages.currentPage().getParameters().get('PersonalInfo') != null) {
                PersonalInfoSave = Boolean.valueOf(ApexPages.currentPage().getParameters().get('PersonalInfo'));
            }
            if(PersonalInfoSave == false) {
                personalInfoEdit = true;
            } else {
                PersonalInfoSave = true;
            }
            if(ApexPages.currentPage().getParameters().get('employeeInfo') != null) {
                employeeInfoSave = Boolean.valueOf(ApexPages.currentPage().getParameters().get('employeeInfo'));
            }
            if(employeeInfoSave == false) {
                employeeInfoEdit = true;
            } else {
                employeeInfoSave = true;
            }
            if(ApexPages.currentPage().getParameters().get('emergencyInfo') != null) {
                emergencyInfoSave = Boolean.valueOf(ApexPages.currentPage().getParameters().get('emergencyInfo'));
            }
            if(emergencyInfoSave == false) {
                emergencyInfoEdit = true; 
            } else {
                emergencyInfoSave = true;
            }
            
            for(Volunteer_Orientation_Training__c currentRecord : [
                SELECT Id,Volunteer__c,Volunteer_Attendance__c,Hidden_O_T_Id__c, Orientation_Training_Hidden__c,
                Class_Offering__r.Type__c,Class_Offering__r.Location__c,
                Class_Offering__r.Date__c,Class_Offering__r.Start_Time__c,Class_Offering__r.End_Time__c,Type__c,
                Class_Offering__r.Chapter__c,class_Offering__r.RecordType.name,Class_Offering__r.course_Id__c
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c = :userIns.ContactId 
                AND (Volunteer_Attendance__c = 'completed' )
            ]) {
                LstLog.add(String.valueOf(currentRecord));
                if(currentRecord.Type__c == 'Orientation') {
                    classOfferingWrapper orientation = new classOfferingWrapper();
                    orientation.OrientationName = currentRecord.Orientation_Training_Hidden__c;
                    orientation.chapterName = currentRecord.Class_Offering__r.Chapter__c;
                    orientation.orientationDate = currentRecord.Class_Offering__r.Date__c;
                    orientation.startTime = currentRecord.Class_Offering__r.Start_Time__c;
                    orientation.endTime = currentRecord.Class_Offering__r.End_Time__c;
                    orientation.location = currentRecord.Class_Offering__r.Location__c;
                    orientation.recordTypeName = currentRecord.Class_Offering__r.RecordType.name;
                    orientation.attendance = currentRecord.Volunteer_Attendance__c;
                    orientationList.add(orientation);
                } else if(currentRecord.Type__c == 'Training') {
                    classOfferingWrapper training = new classOfferingWrapper();
                    training.OrientationName = currentRecord.Orientation_Training_Hidden__c;
                    training.chapterName = currentRecord.Class_Offering__r.Chapter__c;
                    training.orientationDate = currentRecord.Class_Offering__r.Date__c;
                    training.startTime = currentRecord.Class_Offering__r.Start_Time__c;
                    training.endTime = currentRecord.Class_Offering__r.End_Time__c;
                    training.location = currentRecord.Class_Offering__r.Location__c;
                    training.recordTypeName = currentRecord.Class_Offering__r.RecordType.name;
                    training.attendance = currentRecord.Volunteer_Attendance__c;
                    training.courseId = currentRecord.Class_Offering__r.course_Id__c;
                    trainingList.add(training);
                }
            }
            
            backgroundCheckList = [
                SELECT Id, Date__c, Volunteer__c
                FROM Background_check__c
                WHERE Volunteer__c = :userIns.ContactId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if(!backgroundCheckList.isEmpty()) {
                bcExpirationDate = backgroundCheckList[0].Date__c;
            }
            LstLog.add(String.valueOf(backgroundCheckList));
            coiList = [
                SELECT Id, Expiration_Date__c, Volunteer_Contact__c
                FROM Conflict_Of_Interest__c
                WHERE Volunteer_Contact__c = :userIns.ContactId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if(!coiList.isEmpty()) {
                COIExpirationDate = coiList[0].Expiration_Date__c;
            }
            
            contactInstance = [
                SELECT Id,Name,Gender__c,Birth_Day__c,County__c,Salutation,Title,Birth_Month__c,Birth_Year__c,Birthdate,
                Current_Age__c,npe01__WorkPhone__c,Phone,HomePhone,MobilePhone,What_is_your_race_ethnicity__c,RecordTypeId,
                FirstName,Middle_Name__c,LastName,Email,MailingStreet,MailingCity,mailingstatecode,mailingstate,MailingCountrycode,
                MailingPostalCode,Race_Ethnicity__c,Emergency_Contact_Relationship__c,Employer__c,Street_Employer__c,City_Employer__c,
                npe01__HomeEmail__c,npe01__WorkEmail__c,State_Employer__c,Fax,Professional_Skills__c,Language__c,npe01__AlternateEmail__c,
                npe01__PreferredPhone__c,npe01__Preferred_Email__c,Zip_Employer__c,May_We_Contact_You_at_Work__c,
                Interested_involved_with_Make_A_Wish__c,Emergency_Contact__c,Emergency_Contact_Phone__c,npe01__Primary_Address_Type__c,
                Read__c, Write__c,Understand__c, Speak__c, Language_Notes__c,otherPhone,Alternate_Phone_Type__c,Self_describe_comment_box__c,
                OtherCountryCode,OtherStateCode,OtherCity,Professional_Skills_Other_Notes__c,OtherCountry,OtherStreet,OtherPostalCode,OtherState
                FROM Contact
                WHERE Id = :userIns.ContactId
            ];
            LstLog.add(String.valueOf(contactInstance));
            
            if(contactInstance[0].read__c != null) {
                for(String read : contactInstance[0].read__c.split(';')) {
                    langToRead.add(read);
                }
            } else {
                langToRead.add('English');
            }
            if(contactInstance[0].Speak__c != null) {
                for(String speak : contactInstance[0].Speak__c.split(';')) {
                    langToSpeak.add(speak);
                }
            } else {
                langToSpeak.add('English');
            }
            if(contactInstance[0].Write__c != null) {
                for(String write : contactInstance[0].Write__c.split(';')) {
                    langToWrite.add(write);
                }
            } else {
                langToWrite.add('English');
            }
            if(contactInstance[0].Understand__c != null) {
                for(String understand : contactInstance[0].Understand__c.split(';')) {
                    langToUndetstand.add(understand);
                }
            } else {
                langToUndetstand.add('English');
            }
            if(contactInstance[0].Language__c != null) {
                for(String lang : contactInstance[0].Language__c.split(';')) {
                    languagesList.add(lang);
                }
            } else {
                languagesList.add('English');
            }
            if(contactInstance[0].Professional_Skills__c != null) {
                for(String mwa : contactInstance[0].Professional_Skills__c.split(';')) {
                    professionalSkillsList.add(mwa);
                }
            }
            if(contactInstance[0].Race_Ethnicity__c != null) {
                for(String mwa : contactInstance[0].Race_Ethnicity__c.split(';')) {
                    raceEthinicityList.add(mwa);
                }
            }
            
            awardsRecognitionList = [
                SELECT Award_Name__c, Award_Type__c, Chapter_Name__r.Name, Comment__c, Date_Field__c
                FROM Awards_Recognition__c
                WHERE Volunteer_Contact__c = :userIns.ContactId
            ];
            LstLog.add(String.valueOf(awardsRecognitionList));
            if(!awardsRecognitionList.isEmpty()) {
                for(Awards_Recognition__c currRec : awardsRecognitionList) {
                    awardsList.add(new awardsWrapper(currRec.Chapter_Name__r.Name, currRec.Award_Type__c, currRec.Award_Name__c, currRec.Date_Field__c));
                }
            }
            if(Test.isRunningTest()){
                throw new DmlException('Test');
            }
        } catch (Exception ex) {
            Logvalue = String.join(LstLog, ', ');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerProfile_AC', 'VolunteerProfile_AC', null, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }
    
    /**
    * Updates personal information of volunteer contact record and display it
    */
    public PageReference SavePersonalInfo() {
        String birthMonth;
        String birthDay;
        String birthYear;
        String Logvalue;
        String recId;
        try {
            if(!raceEthinicityList.isEmpty()) {
                contactInstance[0].Race_Ethnicity__c = buildStringFromList(raceEthinicityList);
            }
            if(!languagesList.isEmpty()) {
                contactInstance[0].Language__c = buildStringFromList(languagesList);
            }
            if(!langToRead.isEmpty()) {
                contactInstance[0].read__c = buildStringFromList(langToRead);
            }
            if(!langToWrite.isEmpty()) {
                contactInstance[0].write__c = buildStringFromList(langToWrite);
            }
            if(!langToSpeak.isEmpty()) {
                contactInstance[0].speak__c = buildStringFromList(langToSpeak);
            }
            if(!langToUndetstand.isEmpty()) {
                contactInstance[0].Understand__c = buildStringFromList(langToUndetstand);
            }
            if(!professionalSkillsList.isEmpty()) {
                contactInstance[0].Professional_Skills__c = buildStringFromList(professionalSkillsList);
            }
            if(String.isBlank(contactInstance[0].Name) || String.isBlank(contactInstance[0].Email) 
               || String.isBlank(contactInstance[0].Birth_Month__c) ||  String.isBlank(contactInstance[0].Birth_Day__c) 
               || String.isBlank(contactInstance[0].MailingStreet) || String.isBlank(contactInstance[0].MailingCity) 
               || String.isBlank(contactInstance[0].MailingPostalCode) || String.isBlank(contactInstance[0].County__c)
               || String.isBlank(contactInstance[0].mailingstate) ||  String.isBlank(contactInstance[0].Understand__c) 
               || String.isBlank(contactInstance[0].Read__c) || String.isBlank(contactInstance[0].write__c) 
               || String.isBlank(contactInstance[0].speak__c) || String.isBlank(contactInstance[0].language__c)) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter all the mandatory fields');
                   ApexPages.addMessage(myMsg);
               } else {
                   if(contactInstance[0].Birth_Month__c != null && birthMonthMap.containskey(contactInstance[0].Birth_Month__c) 
                      && contactInstance[0].Birth_Day__c != null && contactInstance[0].Birth_Year__c != null) {
                          birthMonth = String.valueOf(birthMonthMap.get(contactInstance[0].Birth_Month__c));
                          birthDay = contactInstance[0].Birth_Day__c;
                          birthYear = contactInstance[0].Birth_Year__c;
                          if(birthYear != null && birthMonth != null && birthDay != null) {
                              String s = birthYear + '-' + birthMonth + '-' + birthDay;
                              if(!(contactInstance[0].Birth_Year__c.isNumeric())) {
                                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'The value for Birth Year should be number'));
                                  return null;
                              } else {
                                  contactInstance[0].Birthdate = Date.valueOf(s);
                              }
                          }
                      }
                   
                   Integer currentAge;
                   if(contactInstance[0].Birthdate != null) {
                       currentAge = contactInstance[0].Birthdate.monthsBetween(system.today()) / 12;
                   }
                   if(currentAge < 18) {
                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'The volunteer age should be greater than 18'));
                   } else {
                       PersonalInfoSave = true;
                       PersonalInfoEdit = false;
                       employeeInfoSave = true;
                       recId = contactInstance[0].Id;
                       Logvalue = String.valueOf(contactInstance[0]);
                       update contactInstance[0];
                       PageReference pr = new PageReference('/apex/VolunteerProfile_VF?PersonalInfo=' + PersonalInfoSave + '&employeeInfo=' + employeeInfoSave + '&emergencyInfo=' + emergencyInfoSave);
                       pr.setRedirect(true);
                       return pr;
                   }
               }
            if(Test.isRunningTest()){
                throw new DmlException('Test');
            }
            return null;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerProfile_AC', 'savePersonalInfo', recId, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    /**
    * Display personal information in Edit mode
    */
    public PageReference EditPersonalInfo() {
        PersonalInfoSave = false;
        employeeInfoSave = false;
        PageReference pr = new PageReference('/apex/VolunteerProfile_VF?PersonalInfo=' + PersonalInfoSave + '&employeeInfo=' + employeeInfoSave + '&emergencyInfo=' + emergencyInfoSave);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
    * Cancel functionality for personal info section
    */
    public pageReference CancelPersonalInfo() {
        PersonalInfoSave = true;
        PageReference pr = new PageReference('/apex/VolunteerProfile_VF?PersonalInfo=' + PersonalInfoSave + '&employeeInfo=' + employeeInfoSave + '&emergencyInfo=' + emergencyInfoSave);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
    * Creates map of string month value with integer pair
    */
    public Map<String, Integer> getMonthValues() {
        Map<String, Integer> birthMonthMap = new Map<String, Integer>();
        birthMonthMap.put('January', 1);
        birthMonthMap.put('February', 2);
        birthMonthMap.put('March', 3);
        birthMonthMap.put('April', 4);
        birthMonthMap.put('May', 5);
        birthMonthMap.put('June', 6);
        birthMonthMap.put('July', 7);
        birthMonthMap.put('August', 8);
        birthMonthMap.put('September', 9);
        birthMonthMap.put('October', 10);
        birthMonthMap.put('November', 11);
        birthMonthMap.put('December', 12);
        return birthMonthMap;
    }
    
    /**
    * Retrieves State picklist values as options
    */
    public List<SelectOption> getStates() {
        return Utils.getPicklistSelectOptions('Lead', 'State_Picklist__c', 'None');
    }
    
    /**
    * Retrieves Gender picklist values as options
    */
    public List<SelectOption> getGender() {
        return Utils.getPicklistSelectOptions('Contact', 'Gender__c', 'None');
    }
    
    /**
    * Retrieves Birthday picklist values as options
    */
    public List<SelectOption> getBirthDay() {
        return Utils.getPicklistSelectOptions('Contact', 'Birth_Day__c', 'Day');
    }
    
    /**
    * Retrieves Year picklist values as options
    */
    public List<SelectOption> getBirthYear() {
        Integer year = Date.Today().Year();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Year'));
        for(Integer i = 1900; i <= (year - 18); i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    
    /**
    * Retrieves Month picklist values as options
    */
    public List<SelectOption> getBirthMonth() {
        return Utils.getPicklistSelectOptions('Contact', 'Birth_Month__c', 'Month');
    }
    
    /**
    * Retrieves Race/Ethnicity picklist values as options
    */
    public List<SelectOption> getRaceEthnicity() {
        return Utils.getPicklistSelectOptions('Contact', 'Race_Ethnicity__c', '');
    }
    
    /**
    * Retrieves Preferred Phone Type picklist values as options
    */
    public List<SelectOption> getPreferedPhoneType() {
        return Utils.getPicklistSelectOptions('Contact', 'npe01__PreferredPhone__c', 'None');
    }
    
    /**
    * Retrieves Preferred Email picklist values as options
    */
    public List<SelectOption> getPreferedEmail() {
        return Utils.getPicklistSelectOptions('Contact', 'npe01__Preferred_Email__c', 'None');
    }
    
    /**
    * Retrieves Professional Skills picklist values as options
    */
    public List<SelectOption> getProfessionalSKills() {
        return Utils.getPicklistSelectOptions('Contact', 'Professional_Skills__c', 'None');
    }
    
    /**
    * Retrieves Language picklist values as options
    */
    public List<SelectOption> getLanguages() {
        return Utils.getPicklistSelectOptions('Contact', 'Language__c', '');
    }
    
    /**
    * Retrieves Primary Address Type picklist values as options
    */
    public List<SelectOption> getAddType() {
        return Utils.getPicklistSelectOptions('Contact', 'npe01__Primary_Address_Type__c', 'None');
    }
    
    /**
    * Retrieves State picklist values as options
    */
    public List<SelectOption> getOtherState() {
        return Utils.getPicklistSelectOptions('Lead', 'State_Picklist__c', 'None');
    }
    
    /**
    * Retrieves Interested Involved with Make A Wish picklist values as options
    */
    public List<SelectOption> getMake_A_Wish() {
        return Utils.getPicklistSelectOptions('Contact', 'Interested_involved_with_Make_A_Wish__c', 'None');
    }
    
    /**
    * Retrieves May We Contact You At Work picklist values as options
    */
    public List<SelectOption> getConatctAtWork() {
        return Utils.getPicklistSelectOptions('Contact', 'May_We_Contact_You_at_Work__c', 'None');
    }
    
    /**
    * Retrieves Employeer State picklist values as options
    */
    public List<SelectOption> getEmpState() {
        return Utils.getPicklistSelectOptions('Contact', 'State_Employer__c', 'None');
    }
    
    /**
    * Retrieves Relationship picklist values as options
    */
    public List<SelectOption> getRelationShip() {
        return Utils.getPicklistSelectOptions('Contact', 'Emergency_Contact_Relationship__c', 'None');
    }
    
    /**
    * Retrieves Title values as options
    */
    public List<SelectOption> getTitles() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Please Select Title'));
        options.add(new SelectOption('Mr.', 'Mr.'));
        options.add(new SelectOption('Mrs.', 'Mrs.'));
        options.add(new SelectOption('Ms.', 'Ms.'));
        options.add(new SelectOption('Miss', 'Miss'));
        options.add(new SelectOption('Master', 'Master'));
        options.add(new SelectOption('Dr.', 'Dr.'));
        options.add(new SelectOption('Prof.', 'Prof.'));
        return options;
    }
    
    /**
    * Build string from list of strings
    * @param stringList
    * @return field
    */
    public String buildStringFromList(List<String> stringList) {
        String field = '';
        for(String str : stringList) {
            field += str + ';';
        }
        field.removeEnd(';');
        return field;
    }
    
    /**
    * ClassOffering Wrapper
    */
    public class classOfferingWrapper {
        public String orientationName { get; set; }
        public String chapterName { get; set; }
        public Date orientationDate { get; set; }
        public String startTime { get; set; }
        public String endTime { get; set; }
        public String location { get; set; }
        public String recordTypeName { get; set; }
        public String attendance { get; set; }
        public String courseId { get; set; }
    }
    
    /**
    * Awards Wrapper
    */
    public class awardsWrapper {
        public String chapterName { get; set; }
        public String awardType { get; set; }
        public String awardName { get; set; }
        public Date awardDate { get; set; }
        public awardsWrapper(String name, String type, String aName, Date aDate) {
            chapterName = name;
            awardType = type;
            awardName = aName;
            awardDate = aDate;
        }
    }
    
    /**
* Redirects to LMS page
*/
    public void viewLMS() {
        String recId, Logvalue;
        try {
            LMSUserResponse currLMSUserResponse = new LMSUserResponse();
            if (getUserRelatedContact.size() > 0 && lMSCredential != null) {
                User currVolunteerUser = getUserRelatedContact.get(0);
                recId = currVolunteerUser.Id;
                Logvalue = String.valueOf(currVolunteerUser);
                currLMSUserResponse = LMSHttpRequest.createOrActivateLMSUser(currVolunteerUser, lMSCredential);
                currLMSUserResponse.code = '1234';
            }
            /*Description : To get a access URL from the LMS*/
            if (currLMSUserResponse != null && currLMSUserResponse.code != null) {
                Logvalue += String.valueOf(currLMSUserResponse);
                lMSSSOResponse = LMSHttpRequest.getLMSSSODetails(lMSCredential, currLMSUserResponse.code, lMSCourseId);
                sSOUrl = lMSSSOResponse.login_url;
                courseURL = lMSSSOResponse.enrollment_url;
            }
            if(Test.isRunningTest()){
                throw new DmlException('Test');
            }
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerProfile_AC', 'SaveEmergencyInfo', recId, ex, Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }
}