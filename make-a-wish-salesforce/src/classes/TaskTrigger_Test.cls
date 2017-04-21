/************************************************************************************
Created by : Vennila Paramasivam
Created Date : 07/25/2016
Author : Mst Solutions
Description : Unit Test for TaskTrigger_AT and TaskTriggerHandler
*************************************************************************************/

@isTest

Public class TaskTrigger_Test
{
    static testmethod void createBirthDayTask()
    {
        Case currCase = TestClassUtil.CreateParentCase();
        String contactId;
        caseteamrole cr=new caseteamrole();
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            TestClassUtil.createProspectiveVolunteerUser();
        }
        System.RunAs(TestClassUtil.newProspectiveVolunteerUser)
        {
            User currUser = [SELECT id, contactId FROM User WHERE Id = :userInfo.getUserId()];
            contactId = currUser.contactId;
            
        }
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            
            cr.accesslevel='edit';
            cr.name='Test';
            cr.PreferencesVisibleInCSP=true;
            insert(cr);
        }
        CaseTeamMember currMember = new CaseTeamMember();
        currMember.ParentId = currCase.id;
        currMember.memberId = contactId;
        currMember.TeamRoleId = cr.id;
        insert currMember;
        
        
        // Create Birthday Task
        Task newTask = new Task();
        newTask.whatId = currCase.id;
        newTask.subject = 'Wish Child Birthday Reminder';
        newTask.OwnerId = userInfo.getUserId();
        insert newTask;
        
        
    }
    
    static testmethod void createRecurranceTask()
    {
        Case currCase = TestClassUtil.CreateParentCase();
        String contactId;
        caseteamrole cr=new caseteamrole();
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            TestClassUtil.createProspectiveVolunteerUser();
        }
        System.RunAs(TestClassUtil.newProspectiveVolunteerUser)
        {
            User currUser = [SELECT id, contactId FROM User WHERE Id = :userInfo.getUserId()];
            contactId = currUser.contactId;
            
        }
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            
            cr.accesslevel='edit';
            cr.name='test';
            cr.PreferencesVisibleInCSP=true;
            insert(cr);
        }
        CaseTeamMember currMember = new CaseTeamMember();
        currMember.ParentId = currCase.id;
        currMember.memberId = contactId;
        currMember.TeamRoleId = cr.id;
        insert currMember;
        
        Chapter_Action_Track__c currTrack = TestClassUtil.CreateChapterActionTrack();
        currTrack.Chapter_Name__c = TestClassUtil.createVolunteerAccount().id;
        currTrack.sort_order__c = 2;
        insert currTrack;
        
        Case updateCase = new Case();
        updateCase.id = currCase.id;
        updateCase.wish_type__c = 'Standard';
        updateCase.subject = 'Wish Determination';
        updateCase.ChapterName__c =currTrack.Chapter_Name__c ;
        update updateCase;
        
        // Create Birthday Task
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Task newTask = new Task();
        newTask.whatId = currCase.id;
        newTask.subject = 'Wish Determination';
        newTask.WhoId = wishChild.Id;
        
        insert newTask;
        
        newTask.Status = 'Completed';
        update newTask;
        
    }
    
    
    static testMethod void createInterviewTask()
    {
        Task newTask = TaskTrigger_Test.createTask();
        newTask.Confirmed_Date__c = Date.Today();
        Database.saveResult result = Database.Update(newTask,false);
        System.assertEquals('Please Enter Venue',result.getErrors()[0].getMessage());
        
    }
    static testMethod void UpdateInterviewTask()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        Conflict_Of_Interest__c  createCOI = OrientationandTrainingUtil.createCOI(con.id);
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
        
        Task newTask = TaskTrigger_Test.createTask();
        newTask.Confirmed_Date__c = Date.Today().addDays(2);
        newTask.Confirmed_Time__c = '2 PM';
        newTask.Venue__c = 'Test';
        Update newTask;
        newTask.Status = 'Approved';
        newTask.whoId = con.id;
        update newTask;
    }
    
    static testMethod void UpdateVolReoleStatus()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        Conflict_Of_Interest__c  createCOI = OrientationandTrainingUtil.createCOI(con.id);
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
        currChapRole.Background_Check_Required__c  = True;
        update currChapRole;
        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
        Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
        Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
        Task newTask = TaskTrigger_Test.createTask();
        newTask.Confirmed_Date__c = Date.Today().addDays(2);
        newTask.Confirmed_Time__c = '2 PM';
        newTask.Venue__c = 'Test';
        Update newTask;
        newTask.Status = 'Approved';
        newTask.whoId = con.id;
        update newTask;
    }
    static testMethod void UpdateToDeclineStatus()
    {
        String contactId;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            TestClassUtil.createProspectiveVolunteerUser();
        }
        System.RunAs(TestClassUtil.newProspectiveVolunteerUser)
        {
            User currUser = [SELECT id, contactId FROM User WHERE Id = :userInfo.getUserId()];
            contactId = currUser.contactId;
            
        }
        TaskTrigger_Test.CreateAffiliation(contactId, 'active');
        Task newTask = TaskTrigger_Test.createTask();
        newTask.Confirmed_Date__c = Date.Today().addDays(2);
        newTask.Confirmed_Time__c = '2 PM';
        newTask.Venue__c = 'Test';
        Update newTask;
        newTask.Status = 'Declined';
        newTask.whoId = contactId;
        update newTask;
        
    }
    
    Static task createTask()
    { 
        Constant_AC  constant = new Constant_Ac();
        Id interviewRT= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
        Task currTask = new Task();
        currTask.Available_Date2__c  = Date.Today().addDays(2);
        currTask.Available_Time2__c  = '7 pm';
        currTask.Available_Date1__c  = Date.Today().addDays(2);
        currTask.Available_Time1__c  = '6pm';
        currTask.RecordTypeId = interviewRT;
        currTask.Subject = 'Interview Task';
        currTask.Availability_Time_Other1__c = 'Hi';
        currTask.Availability_Time_Other2__c = 'Hi';
        currTask.Available_Date3__c  = Date.Today().addDays(3);
        currTask.Available_Time1__c  = '6pm';
        currTask.Availability_Time_Other3__c = 'Hi';
        insert currTask;
        return currTask;
    }
    
    
    
    static npe5__Affiliation__c CreateAffiliation(Id contactId, String status)
    {
        
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c  = contactId;
        neworgAffiliation.npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = status;
        insert neworgAffiliation;
        return neworgAffiliation;
        
    }
    //Used to create checkin task for wish child family
    static testMethod void checkinTask() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task checkinTask = OrientationandTrainingUtil.createFamilyCheckinTask(parentCase.Id);
        checkinTask.Status = 'Completed';
        update checkinTask;
    }
    
    //Used to create Flight booking task for wish child family
    static testMethod void flightBookingTask() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task checkinTask = OrientationandTrainingUtil.createFightBookingTask(parentCase.Id);
        checkinTask.Status = 'Completed';
        update checkinTask;
    }
    
    //Used to create Budget task for wish child family
    static testMethod void budgetTask() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task checkinTask = OrientationandTrainingUtil.createBudgetTask(parentCase.Id);
        checkinTask.Status = 'Completed';
        update checkinTask;
    }
    
    //Used to create Passport Request task for wish child family
    static testMethod void passportRequestTask() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task checkinTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        checkinTask.Status = 'Completed';
        update checkinTask;
    }
    
    //Used to create upload task for volunteer
    static testMethod void createUploadTask() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.Subject = 'Review photos/videos';
        uploadTask.Status = 'Completed';
        update uploadTask;
    }
    
    //Used to create Wish Granted Task
    static testMethod void createWishGrantedTask() {
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.Subject = 'Wish Granted Task';
        uploadTask.RecordTypeId = wishGrantTaskRT;
        uploadTask.Status = 'Completed';
        update uploadTask;
    }
    
    //Used to create Wish Granted Task
    static testMethod void createFollowupTask() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.Subject = 'Volunteer wish follow-up activities not complete';
        uploadTask.Status = 'Completed';
        update uploadTask;
    }
    
    //Used to create Wish Granted Task
    static testMethod void WishPresentationDateEntered() {
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.Subject = 'wish presentation date entered';
        uploadTask.Status = 'Completed';
        update uploadTask;
    }
    
    static testMethod void closeTaskValidationMethod(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case parentUpdate = new Case();
        parentUpdate.Id = parentCase.Id;
        parentUpdate.Presentation_Date__c = Date.today();
        parentUpdate.Wish_Presentation_Set__c = true;
        update parentUpdate;
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
         Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        wishGrantedCase.Presentation_Date__c = System.today();
        wishGrantedCase.Wish_Presentation_Set__c = True;
        wishGrantedCase.Time__c = '1:30';
        wishGrantedCase.Location_Address__c = 'Sample';
        wishGrantedCase.Name_of_Location__c = 'Sample';
        update wishGrantedCase;
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.RecordTypeId = wishGrantTaskRT;
        uploadTask.Subject = 'Wish Presentation not set';
        uploadTask.Status = 'Completed';
        update uploadTask;
       
       
    }
    
    static testMethod void wishConceptApprovalTask(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case parentUpdate = new Case();
        parentUpdate.Id = parentCase.Id;
        parentUpdate.Presentation_Date__c = Date.today();
        parentUpdate.Wish_Presentation_Set__c = true;
        parentUpdate.Status = 'Wish Determined';
         parentUpdate.Sub_Status__c = 'Within Policy';
        
        update parentUpdate;
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
         Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        wishGrantedCase.Presentation_Date__c = System.today();
        wishGrantedCase.Wish_Presentation_Set__c = True;
        wishGrantedCase.Time__c = '1:30';
        wishGrantedCase.Location_Address__c = 'Sample';
        wishGrantedCase.Name_of_Location__c = 'Sample';
        update wishGrantedCase;
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.RecordTypeId = wishGrantTaskRT;
        uploadTask.Subject = 'Wish concept approval';
        uploadTask.Status = 'Completed';
        update uploadTask;
       
       
    }
    
   /*static testMethod void wishNotClosed(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case parentUpdate = new Case();
        parentUpdate.Id = parentCase.Id;
        parentUpdate.Presentation_Date__c = Date.today();
        parentUpdate.Wish_Presentation_Set__c = true;
       parentUpdate.Diagnosis_Verification_Receive_Date__c = Date.today();
       parentUpdate.Referral_Date__c = Date.today();
        parentUpdat.Status = 'Closed';
        update parentUpdate;
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
         Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        wishGrantedCase.Presentation_Date__c = System.today();
        wishGrantedCase.Wish_Presentation_Set__c = True;
        update wishGrantedCase;
        Task uploadTask = OrientationandTrainingUtil.passportRequestTask(parentCase.Id);
        uploadTask.RecordTypeId = wishGrantTaskRT;
        uploadTask.Subject = 'Wish not closed';
        uploadTask.Status = 'Completed';
        update uploadTask;
       
       
    }*/
}