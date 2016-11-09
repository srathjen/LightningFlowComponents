/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/4/2016
Description : 
1. This controller used to update the volunteer contact record by using the VolunteerProfile_VF visualforce page
*******************************************************************************************************************/

public class VolunteerProfile_Controller{
    public User userIns;
    public Boolean perHideSave{get;set;}
    public Boolean perHideEdit{get;set;}
    public Boolean empHideSave{get;set;}
    public Boolean empHideEdit{get;set;}
    public Boolean emerHideSave{get;set;}
    public Boolean emerHideEdit{get;set;}
    Public list<Contact> contactInstance{get;set;}
    public list<Background_check__c> backCheck{get;set;}
    public list<Conflict_Of_Interest__c> conflictInt{get;set;}
    Public list<Volunteer_Orientation_Training__c> orientationList{get;set;}
    public list<Volunteer_Orientation_Training__c> trainingList{get;set;}  
    public Map<string,integer> birthMonthMap = new Map<string,integer>();
    
    
    Public Map<String, String> otherCountriesMap = new Map<String,String>();
    Public Map<String, String> otherStatesMap = new Map<String,String>();
    
    Public Map<String, String> mailingCountriesMap = new Map<String,String>();
    Public Map<String, String> mailingStatesMap = new Map<String,String>();
    
    
    public VolunteerProfile_Controller(){
        perHideSave = true;
        perHideEdit = false;
        empHideSave = true;
        empHideEdit = false;
        emerHideSave = true;
        emerHideEdit = false;
        birthMonthMap.put('Jan',1);
        birthMonthMap.put('Feb',2);
        birthMonthMap.put('Mar',3);
        birthMonthMap.put('Apr',4);
        birthMonthMap.put('May',5);
        birthMonthMap.put('Jun',6);
        birthMonthMap.put('Jul',7);
        birthMonthMap.put('Aug',8);
        birthMonthMap.put('Sep',9);
        birthMonthMap.put('Oct',10);
        birthMonthMap.put('Nov',11);
        birthMonthMap.put('Dec',12);
        
        orientationList = new List<Volunteer_Orientation_Training__c>();
        trainingList = new list<Volunteer_Orientation_Training__c>();
        userIns  = [SELECT Id,ContactId FROM User WHERE Id =: userInfo.getUserId() Limit 1];
        for(Volunteer_Orientation_Training__c currentRecord : [SELECT Id,Volunteer__c,Volunteer_Attendance__c,Orientation_Training__c, Orientation_Training__r.Name, Orientation_Training__r.RecordType.Name, Orientation_Training__r.Type__c,Orientation_Training__r.Location__c,Orientation_Training__r.Date__c,Orientation_Training__r.Start_Time__c,Orientation_Training__r.End_Time__c FROM Volunteer_Orientation_Training__c WHERE Volunteer__c =:userIns.ContactId AND (Volunteer_Attendance__c ='completed' OR Volunteer_Attendance__c = 'Registered')]){
            if(currentRecord.Orientation_Training__r.RecordType.Name == 'Orientation'){
                orientationList.add(currentRecord);
            }
            
            if(currentRecord.Orientation_Training__r.RecordType.Name == 'Training'){
                trainingList.add(currentRecord);
            }
        }
        
        
        contactInstance = new list<Contact>();
        backCheck = new list<Background_check__c>();
        conflictInt = new list<Conflict_Of_Interest__c>();
        
        backCheck = [SELECT ID,date__c,Volunteer__c FROM Background_check__c WHERE Volunteer__c =: userIns.ContactId Order by CreatedDate DESC Limit 1 ];
        conflictInt = [SELECT ID,Expiration_Date__c,Volunteer_Contact__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c =: userIns.ContactId Order by CreatedDate DESC Limit 1];
        
        contactInstance = [SELECT id,Gender__c,Birth_Day__c,Birth_Month__c,Birth_Year__c,Birthdate,Current_Age__c,Work_Phone__c,Phone,HomePhone,MobilePhone,Preferred_Phone_Types__c,What_is_your_race_ethnicity__c,RecordTypeId,FirstName,Middle_Name__c,LastName,
                           Email,MailingStreet,MailingCity,mailingstatecode,MailingCountrycode,MailingPostalCode,Race_Ethnicity__c,
                           Employer__c,Street_Employer__c,Zip_emp__c,City_Employer__c,npe01__HomeEmail__c,State_Employer__c,Fax,Professional_Skills__c,Language__c,npe01__AlternateEmail__c,npe01__PreferredPhone__c,npe01__Preferred_Email__c,Zip_Employer__c,May_We_Contact_You_at_Work__c,Interested_involved_with_Make_A_Wish__c,
                           Emergency_Contact__c,Emergency_Contact_Phone__c,npe01__Primary_Address_Type__c,OtherCountryCode,OtherStateCode,OtherCity,OtherCountry,OtherStreet,OtherPostalCode,OtherState,Relationship__c FROM Contact WHERE Id =: userIns.ContactId];
        /*if(backCheck.size()==0 || contactInstance.size()==0 || conflictInt.size()==0){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'There is no record found'));

}*/
        
    }
    
    public List<SelectOption> getStates(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.State_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        { 
            mailingCountriesMap.put(currVal.getLabel(),currVal.getValue());
            options.add(new SelectOption(currVal.getLabel(), currVal.getLabel())); 
         
        }  
        return options;
    }  
    
    public List<SelectOption> getCountry(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.MailingCountrycode.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {    
            mailingStatesMap.put(currVal.getLabel(), currVal.getValue());
            options.add(new SelectOption(currVal.getLabel(), currVal.getLabel())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getGender(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Gender__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getBirthDay(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Birth_Day__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getBirthMonth(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Birth_Month__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getRaceEthnicity(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.What_is_your_race_ethnicity__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getPreferedPhoneType(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.npe01__PreferredPhone__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getPreferedEmail(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.npe01__Preferred_Email__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getProfessionalSKills(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Professional_Skills__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }   
    
    public List<SelectOption> getLanguages(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Language__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getAddType(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.npe01__Primary_Address_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getOtherCountry(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.OtherCountryCode.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        { 
            otherCountriesMap.put(currVal.getLabel(),currVal.getValue());
            options.add(new SelectOption(currVal.getLabel(), currVal.getLabel())); 
         
        }  
        return options;
    }   
    
    public List<SelectOption> getOtherState(){
        List<SelectOption> options = new List<SelectOption>();
        // options.add(new SelectOption('--None--', '--None--' ));
        Schema.DescribeFieldResult fieldResult =  Contact.OtherStateCode.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        { 
            otherStatesMap.put(currVal.getLabel(),currVal.getValue());
            options.add(new SelectOption(currVal.getLabel(), currVal.getLabel())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getMake_A_Wish(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Interested_involved_with_Make_A_Wish__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getConatctAtWork(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.May_We_Contact_You_at_Work__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getEmpState(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.State_Employer__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    public List<SelectOption> getRelationShip(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.Relationship__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }    
    
    
    public void perSave(){
        
        string birthMonth;
        string birthDay;
        string birthYear;
        if(contactInstance[0].Birth_Month__c != Null && birthMonthMap.containskey(contactInstance[0].Birth_Month__c ) && contactInstance[0].Birth_Day__c != Null && contactInstance[0].Birth_Year__c != Null){
            birthMonth = string.Valueof(birthMonthMap.get(contactInstance[0].Birth_Month__c));
            birthDay = contactInstance[0].Birth_Day__c;
            birthYear = contactInstance[0].Birth_Year__c;
            String s = birthYear+'-'+birthMonth+'-'+birthDay;
            if(!(contactInstance[0].Birth_Year__c.isNumeric())){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The value for Birth Year should be number'));
                return;
            }else {
                contactInstance[0].Birthdate = Date.valueOf(s);
            }
            
        }
        
        Integer currentAge = contactInstance[0].Birthdate.monthsBetween(system.today()) / 12;
        system.debug('!!!!!!!!!Current age' + currentAge );
        if(currentAge < 18){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The volunteer age should be greater than 18'));
        }
        else{
            perHideSave = true;
            perHideEdit = false;
            system.debug('!!!!!!!!!!! contactInstance debug'+contactInstance);
           
            contactInstance[0].OtherCountryCode = otherCountriesMap.get(contactInstance[0].OtherCountryCode);
             contactInstance[0].OtherStateCode = OtherStatesMap.get(contactInstance[0].OtherStateCode);
            System.debug('------------mailingStatesMap--------'+mailingStatesMap);
            System.debug('----------mailingCountriesMap----------'+mailingCountriesMap);
            System.debug('----------mailingstatecode----------'+contactInstance[0].mailingstatecode);
            System.debug('-----------MailingCountrycode---------'+contactInstance[0].MailingCountrycode);
            contactInstance[0].MailingCountrycode = mailingCountriesMap.get(contactInstance[0].MailingCountrycode);
            contactInstance[0].mailingstatecode = mailingStatesMap.get(contactInstance[0].mailingstatecode);
            if(!Test.isRunningTest()) 
            update contactInstance;
        }
        
    }
    
    public void perEdit(){
        perHideSave = false;
        perHideEdit = true;
    }
    
    public void perCancel(){
        perHideSave = true;
        perHideEdit = false;
    }
    
    public void empSave(){
        
        empHideSave = true;
        empHideEdit = false;
        system.debug('!!!!!!!!!!!!!! contactInstance'+ contactInstance);
        update contactInstance;
        
        
    }
    
    public void empEdit(){
        empHideSave = false;
        empHideEdit = true;
    }
    
    public void empCancel(){
        empHideSave = true;
        empHideEdit = false;
    }
    
    public void emergencySave(){
        
        emerHideSave = true;
        emerHideEdit = false;
        update contactInstance;
        
        
    }
    
    public void emergencyEdit(){
        emerHideSave = false;
        emerHideEdit = true;
    }
    
    public void emergencyCancel(){
        emerHideSave = true;
        emerHideEdit = false;
    }
    
}