/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 5/23/2016
Description : This controller referred in the BackgroundCheck_Vf page. Volunteer will submit their details for Background 
verification.When Volunteer submits Background check, It will create Background check record as well
as Background check task for the chatper staff.
*******************************************************************************************************************/
public class BackgroundCheck_AC {
    
    public Contact con{get;set;}
    public Background_check__c backGroundCheck{get;set;}
    public Boolean statusValue{get;set;}
    public User currUser;
    public String taskRecordTypeId;
    List<Background_check__c> existingBGCheckRecList{get;set;}
    public Boolean isBGFinished{get;set;}
    public String residingInPast7Years{get;set;}
    public String whyNeedBGCheck{get;set;}
    public Boolean bgTabPermission{get;set;}
    public Boolean trainingTabVisible{get;set;}
    public String areYouinUS7Yrs{get;set;}
    
    public BackgroundCheck_AC() {
        currUser = [SELECT Id, ContactId, Contact.Account.Volunteer_Manager__c, Contact.OwnerId 
                    FROM User 
                    WHERE Id = :userInfo.getUserId()];
        backGroundCheck = new Background_check__c();
        existingBGCheckRecList = [SELECT Id, Resided_in_US_for_past_7_years__c 
                                  FROM Background_check__c 
                                  WHERE VOLUNTEER__c = :currUser.ContactId 
                                  ORDER BY CreatedDate DESC];
        if(!existingBGCheckRecList.isEmpty()) {
            isBGFinished = true;
            residingInPast7Years = existingBGCheckRecList[0].Resided_in_US_for_past_7_years__c;
        }
        Id nationalRT = Constant_AC.NATIONAL_RT_ID;
        List<Dynamic_Content__c> currContent = [SELECT Id, Why_Need_Background_Check__c 
                                                FROM Dynamic_Content__c 
                                                WHERE RecordTypeId = :nationalRT 
                                                AND Active__c = true];
        if(!currContent.isEmpty())
            whyNeedBGCheck = currContent[0].Why_Need_Background_Check__c;
        if(ApexPages.currentPage().getParameters().get('bgRequired') != null)
            bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));     
        if(ApexPages.currentPage().getParameters().get('trainingRequired') != null)
            trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));   
    }
    
    /**
    * Create background check for logged in volunteer and task for volunteer manager
    * @return
    */
    public PageReference saveRec() {
        List<string> LstLog = new List<string>();
        try {
            backGroundCheck.Date_Requested__c = System.today();
            backGroundCheck.Volunteer__c = currUser.ContactId; 
            backGroundCheck.Resided_in_US_for_past_7_years__c = areYouinUS7Yrs;
            backGroundCheck.OwnerId = currUser.Contact.OwnerId;
            if(backGroundCheck.Resided_in_US_for_past_7_years__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select a value for: Have you resided in the US for the past 7 years?'));
            } else {
                statusValue = true;
                if(backGroundCheck.Id != null) {
                    backGroundCheck.Id = null;
                }
                LstLog.add(string.valueOf(backGroundCheck));
                insert backGroundCheck;
                
                taskRecordTypeId = Constant_AC.BACKGROUND_RT_ID;
                Task newBGTask = new Task();
                newBGTask.Type = Constant_AC.TASK_TYPE_EMAIL;
                newBGTask.Description = ''; 
                if(currUser.Contact.Account != null 
                   && currUser.Contact.Account.Volunteer_Manager__c != null) {
                    newBGTask.OwnerId = currUser.Contact.Account.Volunteer_Manager__c;
                } else {
                    newBGTask.OwnerId = currUser.Contact.OwnerId;
                }
                newBGTask.WhoId = currUser.ContactId; 
                newBGTask.WhatId = backGroundCheck.Id;
                newBGTask.Subject = Constant_AC.TASK_SUBJECT_BACKGROUND_CHECK;
                newBGTask.SystemGeneratedTask__c = true;
                newBGTask.RecordTypeId = taskRecordTypeId;
                LstLog.add(string.valueOf(newBGTask));
                insert newBGTask;
                
                Contact updateContact = new Contact();
                updateContact.Id = currUser.ContactId;
                updateContact.Onboarding_Status__c = Constant_AC.CONTACT_ONBOARDING_STATUS_BACKGROUND_CHECK;
                LstLog.add(string.valueOf(updateContact));
                update updateContact;
                
                LstLog.add(string.valueOf(bgTabPermission));
                LstLog.add(string.valueOf(trainingTabVisible));
                PageReference pageRef = new PageReference('/apex/BackgroundCheck_VF?bgRequired='+bgTabPermission+'&trainingRequired='+trainingTabVisible);
                pageRef.setRedirect(true);
                return pageRef;
            }
            return null;
        } catch(Exception ex) {
            String Logvalue = string.join(LstLog,', ');
            if(!Test.isRunningTest()) {
                new ApexDebugLog().createLog(new ApexDebugLog.Error('BackgroundCheck_AC', 'saveRec', con.Id, ex, Logvalue));
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
        
    /**
    * Returns list of picklist values for Resided_in_US_for_past_7_years__c
    * @return
    */
    public List<SelectOption> getResidedValues() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  BackGround_Check__c.Resided_in_US_for_past_7_years__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select')); 
        for(Schema.PicklistEntry currVal : picklistValues) {      
            options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
        }
        return options;
    }   
}