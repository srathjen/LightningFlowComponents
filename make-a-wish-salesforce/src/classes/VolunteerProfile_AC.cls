/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/4/2016
Description : 
1. This controller is used in the VolunteerProfile_VF page. Once volunteer is converted into Acive Volunteer Portal,
They can have a option for updating their profile details. This updated details will reflect in Volunteer Co
*******************************************************************************************************************/

public class VolunteerProfile_AC{
    public User userIns;
    public Boolean PersonalInfoSave{get;set;}
    public Boolean PersonalInfoEdit{get;set;}
    public Boolean employeeInfoSave{get;set;}
    public Boolean employeeInfoEdit{get;set;}
    public Boolean emergencyInfoSave{get;set;}
    public Boolean emergencyInfoEdit{get;set;}
    Public list<Contact> contactInstance{get;set;}
    public list<Background_check__c> backgroundCheckList{get;set;}
    public list<Conflict_Of_Interest__c> coiList{get;set;}
    Public list<classofferingwrapper> orientationList{get;set;}
    public list<classofferingwrapper> trainingList{get;set;}
    public list<Awards_Recognition__c> awardsRecognitionList{get;set;}  
    public Map<string,integer> birthMonthMap = new Map<string,integer>();
    public list<string> raceEthinicityList{get;set;}
    public list<String> professionalSkillsList{get;set;}
    public list<String> langToRead{get;set;}
    public list<String> langToWrite{get;set;}
    public list<String> langToSpeak{get;set;}
    public list<String> langToUndetstand{get;set;}
    public list<String> languagesList{get;set;}
    Public Map<String, String> otherCountriesMap = new Map<String,String>();
    Public Map<String, String> otherStatesMap = new Map<String,String>();
    Public Map<String, String> mailingCountriesMap = new Map<String,String>();
    Public Map<String, String> mailingStatesMap = new Map<String,String>();
    public boolean isDisabled;
    public boolean isAwardEmpty{get;set;}    
          
    
    // Initialyzing variables.
    public VolunteerProfile_AC(){
        PersonalInfoSave = true;
        PersonalInfoEdit = false;
        employeeInfoSave = true;
        employeeInfoEdit = false;
        emergencyInfoSave = true;
        emergencyInfoEdit = false;
        isDisabled = true;
        isAwardEmpty = false;
        langToRead = new List<String>();
        langToSpeak = new List<String>();
        langToWrite = new List<String>();
        langToUndetstand = new List<String>();
        languagesList  = new List<String>();
        raceEthinicityList= new List<String>();
        professionalSkillsList = new List<String>();
        
        birthMonthMap.put('January',1);
        birthMonthMap.put('February',2);
        birthMonthMap.put('March',3);
        birthMonthMap.put('April',4);
        birthMonthMap.put('May',5);
        birthMonthMap.put('June',6);
        birthMonthMap.put('July',7);
        birthMonthMap.put('August',8);
        birthMonthMap.put('September',9);
        birthMonthMap.put('October',10);
        birthMonthMap.put('November',11);
        birthMonthMap.put('December',12);
        
        orientationList = new List<classofferingwrapper>();
        trainingList = new list<classofferingwrapper>();
        userIns  = [SELECT Id,ContactId FROM User WHERE Id =: userInfo.getUserId() Limit 1];
        for(Volunteer_Orientation_Training__c currentRecord : [SELECT Id,Volunteer__c,Volunteer_Attendance__c,Orientation_Training__c, Orientation_Training__r.Name, 
                                                               Orientation_Training__r.RecordType.Name, Class_Offering__r.Type__c,Class_Offering__r.Location__c,
                                                               Class_Offering__r.Date__c,Class_Offering__r.Start_Time__c,Class_Offering__r.End_Time__c,Type__c,
                                                               Class_Offering__r.Chapter__c,class_Offering__r.RecordType.name
                                                               FROM Volunteer_Orientation_Training__c WHERE Volunteer__c =:userIns.ContactId AND
                                                               (Volunteer_Attendance__c ='completed' OR Volunteer_Attendance__c = 'Registered')]){
            if(currentRecord.Type__c == 'Orientation'){
               classofferingwrapper orientation = new classofferingwrapper();
               orientation.OrientationName = currentRecord.Orientation_Training__r.Name;
               orientation.chapterName = currentRecord.Class_Offering__r.Chapter__c;
               orientation.orientationDate = currentRecord.Class_Offering__r.Date__c;
               orientation.startTime = currentRecord.Class_Offering__r.Start_Time__c;
               orientation.endTime = currentRecord.Class_Offering__r.End_Time__c;
               orientation.location = currentRecord.Class_Offering__r.Location__c;
               orientation.recordTypeName = currentRecord.Class_Offering__r.RecordType.name;
               orientation.attendance = currentRecord.Volunteer_Attendance__c;
               orientationList.add(orientation);
            }
            
            if(currentRecord.Type__c == 'Training'){
               
                classofferingwrapper training = new classofferingwrapper();
                training.OrientationName = currentRecord.Orientation_Training__r.Name;
                training.chapterName = currentRecord.Class_Offering__r.Chapter__c;
                training.orientationDate = currentRecord.Class_Offering__r.Date__c;
                training.startTime = currentRecord.Class_Offering__r.Start_Time__c;
                training.endTime = currentRecord.Class_Offering__r.End_Time__c;
                training.location = currentRecord.Class_Offering__r.Location__c;
                training.recordTypeName = currentRecord.Class_Offering__r.RecordType.name;
                training.attendance = currentRecord.Volunteer_Attendance__c;
                trainingList.add(training);
            }
        }
        
        
        contactInstance = new list<Contact>();
        backgroundCheckList = new list<Background_check__c>();
        coiList = new list<Conflict_Of_Interest__c>();
        
        backgroundCheckList = [SELECT ID,date__c,Volunteer__c FROM Background_check__c WHERE Volunteer__c =: userIns.ContactId Order by CreatedDate DESC Limit 1 ];
        coiList = [SELECT ID,Expiration_Date__c,Volunteer_Contact__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c =: userIns.ContactId Order by CreatedDate DESC Limit 1];
        
        contactInstance = [SELECT id,Name,Gender__c,Birth_Day__c,County__c,Birth_Month__c,Birth_Year__c,Birthdate,Current_Age__c,Work_Phone__c,Phone,HomePhone,MobilePhone,Preferred_Phone_Types__c,What_is_your_race_ethnicity__c,RecordTypeId,FirstName,Middle_Name__c,LastName,
                           Email,MailingStreet,MailingCity,mailingstatecode,mailingstate,MailingCountrycode,MailingPostalCode,Race_Ethnicity__c,Emergency_Contact_Relationship__c,
                           Employer__c,Street_Employer__c,Zip_emp__c,City_Employer__c,npe01__HomeEmail__c,State_Employer__c,Fax,Professional_Skills__c,Language__c,npe01__AlternateEmail__c,npe01__PreferredPhone__c,npe01__Preferred_Email__c,Zip_Employer__c,May_We_Contact_You_at_Work__c,Interested_involved_with_Make_A_Wish__c,
                           Emergency_Contact__c,Emergency_Contact_Phone__c,npe01__Primary_Address_Type__c,Read__c, Write__c,Understand__c, Speak__c, Language_Notes__c,otherPhone,Alternate_Phone_Type__c,
                           OtherCountryCode,OtherStateCode,OtherCity,Professional_Skills_Other_Notes__c,OtherCountry,OtherStreet,OtherPostalCode,OtherState FROM Contact WHERE Id =: userIns.ContactId];
      
           
          
          if(contactInstance[0].read__c!= Null)
            {
                for(String read: contactInstance[0].read__c.split(';'))
                {
                    langToRead.add(read);
                }
            }
            else
            {
            
                langToRead.add('English');

            }
            if(contactInstance[0].Speak__c!= Null)
            {
                for(String speak: contactInstance[0].Speak__c.split(';'))
                {
                    langToSpeak.add(speak);
                }
            }
            else
            {
                langToSpeak.add('English');
            }
            
            if(contactInstance[0].Write__c != Null)
            {
                for(String write : contactInstance[0].Write__c.split(';'))
                {
                    langToWrite.add(write);
                }
            }
            else
            {
               langToWrite.add('English');
            }
          
            if(contactInstance[0].Understand__c != Null)
            {
                for(String understand : contactInstance[0].Understand__c.split(';'))
                {
                    langToUndetstand.add(understand);
                }
            }
            else
            {
                langToUndetstand.add('English');
            }
            
            if(contactInstance[0].Language__c != Null)
            {
                for(String lang: contactInstance[0].Language__c.split(';'))
                {
                    languagesList.add(lang);
                }
            }
            else
            {
                 languagesList.add('English');
            }
          
            if(contactInstance[0].Professional_Skills__c!= Null)
            {
                for(String mwa: contactInstance[0].Professional_Skills__c.split(';'))
                {
                    professionalSkillsList.add(mwa);
                }
            }
        
           if(contactInstance[0].Race_Ethnicity__c != Null)
            {
                for(String mwa: contactInstance[0].Race_Ethnicity__c.split(';'))
                {
                    raceEthinicityList.add(mwa);
                }
            }
            
        //Used to display volunteer award details       
        awardsRecognitionList = [SELECT Award_Name__c,Award_Type__c,Chapter_Name__r.Name,Comment__c,Date_Field__c FROM Awards_Recognition__c WHERE Volunteer_Contact__c =: userIns.ContactId ];
      
    
    
    }
    
    // Getting State picklist value.
    public List<SelectOption> getStates(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.State_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
      
        options.add(new SelectOption('', 'None'));
        for(Schema.PicklistEntry currVal : picklistValues)
        { 
            mailingCountriesMap.put(currVal.getLabel(),currVal.getValue());
            options.add(new SelectOption(String.valueOf(currVal.getLabel()), currVal.getValue())); 
         
        }  
        return options;
     }  
    
   
   // Fetching Gender picklist values. 
    public List<SelectOption> getGender(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Gender__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None',isDisabled));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
     // Fetching Year picklist value.
    public List<SelectOption> getBirthDay(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Birth_Day__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Day' ));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    // Fetching Year picklist value.
    public List<SelectOption> getBirthYear()
    {
    
       integer year = Date.Today().Year();
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'Year' ));
       for(integer i = 1900; i<= (year-18);i++)
       {
         options.add(new SelectOption(String.valueOf(i), String.valueOf(i))); 
       }
      return options;
    
    }
    // Fetching month picklist value.
    public List<SelectOption> getBirthMonth(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Birth_Month__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Month' ));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Fetching picklist value of Race/Ethnicity.
    public List<SelectOption> getRaceEthnicity(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Race_Ethnicity__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    // Fetching the picklist value of Preferred Phone Type.
    public List<SelectOption> getPreferedPhoneType(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.npe01__PreferredPhone__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None' ));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Fetching picklist value of Preferred Email.
    public List<SelectOption> getPreferedEmail(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.npe01__Preferred_Email__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None' ));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Fetching picklist value of Professional skills.
    public List<SelectOption> getProfessionalSKills(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Professional_Skills__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None' ));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }   
    
    // Fetching picklist value of Language.
    public List<SelectOption> getLanguages(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Language__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Fetching picklist value of Primary Address Type.
    public List<SelectOption> getAddType(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.npe01__Primary_Address_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
       // if(contactInstance[0].npe01__Primary_Address_Type__c == Null || contactInstance[0].npe01__Primary_Address_Type__c =='')
            options.add(new SelectOption('', 'None'));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
   
    // Fetching picklist value of state field.
    public List<SelectOption> getOtherState(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =  Lead.State_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None'));
        for( Schema.PicklistEntry currVal : picklistValues)
        { 
            otherStatesMap.put(currVal.getLabel(),currVal.getValue());
            options.add(new SelectOption(currVal.getLabel(),currVal.getvalue())); 
         
        }  
        return options;
    }    
    
     // Fetching picklist value of Interested involved with Make A wish field.
    public List<SelectOption> getMake_A_Wish(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Interested_involved_with_Make_A_Wish__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Fetching picklist value of May we contact you at work custom field.
    public List<SelectOption> getConatctAtWork(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.May_We_Contact_You_at_Work__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Getting Employeer State picklist values.
    public List<SelectOption> getEmpState(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.State_Employer__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(),currVal.getValue())); 
         
        }  
        return options;
    }    
    
    // Fetching Relationship picklist values.
    public List<SelectOption> getRelationShip(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Emergency_Contact_Relationship__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'None'));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    
    
    // It will update personal information in volunteer contact record then will display output mode of Personal information.
    public void SavePersonalInfo(){
        
        string birthMonth;
        string birthDay;
        string birthYear;
        
         if(raceEthinicityList != Null)
            {
               
                String race='';
                for(String s : (raceEthinicityList))
                {
                  race+=s+';';
                }
                contactInstance[0].Race_Ethnicity__c = race.removeEnd(';');
            }
               
            if(languagesList != Null)
            {
              
                String language ='';
                for(String s : (languagesList))
                {
                  language+=s+';';
                }
                contactInstance[0].Language__c  = language.removeEnd(';');
            }
            
            if(langToRead!= Null)
            {
                String read ='';
                for(String s : langToRead)
                {
                  read+=s+';';
                }
                contactInstance[0].read__c= read.removeEnd(';');
            }
            if(langToWrite != Null)
            {
                String write ='';
                for(String s : langToWrite)
                {
                  write+=s+';';
                }
                contactInstance[0].write__c = write.removeEnd(';');
            }
            if(langToSpeak!= Null)
            {
               
                String speak='';
                for(String s : langToSpeak)
                {
                  speak+=s+';';
                }
                contactInstance[0].speak__c= speak.removeEnd(';');
            }
            if(langToUndetstand!= Null)
            {
              
                String understand='';
                for(String s : (langToUndetstand))
                {
                  understand+=s+';';
                }
                contactInstance[0].Understand__c= understand.removeEnd(';');
            }
            if(professionalSkillsList != Null)
            {
              
                String skill ='';
                for(String s : (professionalSkillsList))
                {
                  skill+=s+';';
                }
                contactInstance[0].Professional_Skills__c= skill.removeEnd(';');
            }
            
            if(contactInstance[0].Preferred_Phone_Types__c == 'Home' && contactInstance[0].Alternate_Phone_Type__c == 'Mobile'){
                contactInstance[0].HomePhone = contactInstance[0].HomePhone;
                contactInstance[0].MobilePhone  = contactInstance[0].MobilePhone ;
                if(contactInstance[0].OtherPhone != Null)
                contactInstance[0].OtherPhone = Null;
            }
            
            if(contactInstance[0].Preferred_Phone_Types__c == 'Home' && contactInstance[0].Alternate_Phone_Type__c == Null){
                contactInstance[0].HomePhone = contactInstance[0].HomePhone;
                contactInstance[0].MobilePhone  = Null ;
                if(contactInstance[0].OtherPhone != Null)
                contactInstance[0].OtherPhone = Null;
            }
            
             if(contactInstance[0].Preferred_Phone_Types__c == 'Mobile' && contactInstance[0].Alternate_Phone_Type__c == Null){
                contactInstance[0].MobilePhone  = contactInstance[0].HomePhone;
                contactInstance[0].HomePhone = Null ;
                if(contactInstance[0].OtherPhone != Null)
                contactInstance[0].OtherPhone = Null;
            }
            
            if(contactInstance[0].Preferred_Phone_Types__c == 'Mobile' && contactInstance[0].Alternate_Phone_Type__c == 'Home'){
                String mobileNo = contactInstance[0].MobilePhone;
                contactInstance[0].MobilePhone = contactInstance[0].HomePhone;
                contactInstance[0].HomePhone = mobileNo;
                if(contactInstance[0].OtherPhone != Null)
                contactInstance[0].OtherPhone = Null;
            }
            
            
            if(contactInstance[0].Preferred_Phone_Types__c == 'Home' && contactInstance[0].Alternate_Phone_Type__c == 'Home'){
                contactInstance[0].HomePhone = contactInstance[0].HomePhone;
                contactInstance[0].OtherPhone = contactInstance[0].MobilePhone;
                contactInstance[0].MobilePhone = Null;
                
            }
            
             if(contactInstance[0].Preferred_Phone_Types__c == 'Mobile' && contactInstance[0].Alternate_Phone_Type__c == 'Mobile'){
                contactInstance[0].MobilePhone = contactInstance[0].MobilePhone ;
                contactInstance[0].OtherPhone = contactInstance[0].HomePhone;
                contactInstance[0].HomePhone = Null;
            }
           
        if((contactInstance[0].Name== Null || contactInstance[0].Name == '') || (contactInstance[0].Email == Null || contactInstance[0].Email == '')
           || (contactInstance[0].Birth_Month__c == Null || contactInstance[0].Birth_Month__c == '') || (contactInstance[0].Birth_Day__c == '' || contactInstance[0].Birth_Day__c == '') ||
           (contactInstance[0].HomePhone == Null || contactInstance[0].HomePhone == '')  ||
           (contactInstance[0].MailingStreet == NULL || contactInstance[0].MailingStreet == '') || (contactInstance[0].MailingCity == NULL || contactInstance[0].MailingCity == '') || 
           (contactInstance[0].MailingPostalCode== NULL || contactInstance[0].MailingPostalCode == '') ||  (contactInstance[0].County__c == NULL || contactInstance[0].County__c == '')
           || (contactInstance[0].mailingstate == NULL || contactInstance[0].mailingstate == '') || (contactInstance[0].Understand__c == NULL || contactInstance[0].Understand__c == '') ||
           (contactInstance[0].Read__c == NULL || contactInstance[0].Read__c == '') || (contactInstance[0].write__c == NULL || contactInstance[0].write__c == '') || 
           (contactInstance[0].speak__c == NULL || contactInstance[0].speak__c == '') || (contactInstance[0].language__c == NULL || contactInstance[0].language__c == ''))
               
        {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter all the mandatory fields');
             ApexPages.addMessage(myMsg);
        }
        
        else
        {
        
         
        if(contactInstance[0].Birth_Month__c != Null && birthMonthMap.containskey(contactInstance[0].Birth_Month__c ) && contactInstance[0].Birth_Day__c != Null && contactInstance[0].Birth_Year__c != Null){
            birthMonth = string.Valueof(birthMonthMap.get(contactInstance[0].Birth_Month__c));
            birthDay = contactInstance[0].Birth_Day__c;
            birthYear = contactInstance[0].Birth_Year__c;
            if(birthYear != Null && birthMonth != Null && birthDay != Null)
            {
                String s = birthYear+'-'+birthMonth+'-'+birthDay;
                if(!(contactInstance[0].Birth_Year__c.isNumeric())){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The value for Birth Year should be number'));
                    return;
                }else {
                    contactInstance[0].Birthdate = Date.valueOf(s);
                }
            }
        }
        
        Integer currentAge;
        if(contactInstance[0].Birthdate != Null)
            currentAge = contactInstance[0].Birthdate.monthsBetween(system.today()) / 12;
        
        
        if(currentAge < 18){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The volunteer age should be greater than 18'));
        }
        else{
            PersonalInfoSave = true;
            PersonalInfoEdit = false;
           try{
            update contactInstance;
            }
           catch(Exception ex){
           }
               
        }
      }  
    }
    
    // It will display personal information as Edit mode.
    public void EditPersonalInfo(){
        PersonalInfoSave = false;
        PersonalInfoEdit = true;
    }
    
    // Cancel Functionality for Personal info section.
    public pageReference CancelPersonalInfo(){
        pageReference  pr;
        PersonalInfoSave = true;
        PersonalInfoEdit = false;
        pr = new PageReference('/VolunteerProfile_VF');
        return pr;
    }
    
    // update employee details in volunteer contact and display employee section as output mode.
    public void SaveEmployeeInfo(){
        
        employeeInfoSave = true;
        employeeInfoEdit = false;
        system.debug('!!!!!!!!!!!!!! contactInstance'+ contactInstance);
        update contactInstance;
        
    }
    
    // Will Display Employee section as input mode.
    public void EditEmployeeInfo(){
        employeeInfoSave = false;
        employeeInfoEdit = true;
    }
    
    // Cancel Functionality for employee info section.
    public void CancelEmpInfo(){
        employeeInfoSave = true;
        employeeInfoEdit = false;
    }
    
    // Update Emergency Details and Display Emergency Info as output mode.
    public PageReference SaveEmergencyInfo(){
        
      
        if((contactInstance[0].Emergency_Contact_Relationship__c == Null || contactInstance[0].Emergency_Contact_Relationship__c == '') || 
           (contactInstance[0].Emergency_Contact__c == Null || contactInstance[0].Emergency_Contact__c == '') || (contactInstance[0].Emergency_Contact_Phone__c == Null || contactInstance[0].Emergency_Contact_Phone__c == ''))
        {
        
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter all the mandatory fields');
             ApexPages.addMessage(myMsg);
             return null;
        }
       else
        {
            emergencyInfoSave = true;
            emergencyInfoEdit = false;
            update contactInstance;
        }
         return null;
    }
    
    // Display Emergency info as a input mode.
    public void EditEmergencyInfo(){
        emergencyInfoSave = false;
        emergencyInfoEdit = true;
    }
    
    // Cancel Functionality for Emergency info section.
    public void CancelEmergencyInfo(){
        emergencyInfoSave = true;
        emergencyInfoEdit = false;
    }
    
   
   
    public class classofferingwrapper
    {
        public string orientationName{get;set;}
        public string chapterName{get;set;}
        public Date orientationDate{get;set;}
        public string startTime{get;set;}
        public string endTime{get;set;}
        public string location{get;set;}
        public string recordTypeName{get;set;}
        public string attendance{get;set;}
        
    
    }
    
}