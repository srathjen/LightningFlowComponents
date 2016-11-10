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
            cr.name='test';
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
        newTask.Sort_Order__c = 1;
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
}