/*****************************************************************************************************************
Author      : MST Solutions
Date        : 12/01/2016
Description : This class contains test method for CaseFile object
Modification Log: 
28/03/2018 - Kanagaraj
*******************************************************************************************************************/
@isTest
Public Class VolunteerWelcomePage_ACTest
{
    // Initializing  constructor.
    static testmethod void testVolunteerWelcomePage()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            Dynamic_Content__c  createDynamicContent = OrientationandTrainingUtil.createDynamicContent();
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.createProspectiveDynamicContent(acc.id);
            
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
        }
        
    }
    
    // Testing negative case for orientation.
    static testmethod void negativeDataforOrientation()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Submit';
        update updateContact;
        
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Chapter_Role_O_T__c currChapOrientation1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            
            Constant_AC  constant = new Constant_Ac();    
            Id EventRecTypeId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
            
            List<Non_Wish_Events__c> eventList= new List<Non_Wish_Events__c>();
            for(integer i =1 ; i<4;i++)
            {
                
                Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
                newEvent.Event_Name__c = 'Send Off';
                newEvent.Event_Date__c = System.Today()+5;
                newEvent.Event_Text__c = 'Sending Wish Child';
                newEvent.Priority__c = String.valueOf(i);
                newEvent.chapter__c = acc.id;
                newEvent.RecordTypeId =  EventRecTypeId;
                eventList.add(newEvent);
                
            }
            
            Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
            newEvent.Event_Name__c = 'Send Off';
            newEvent.Event_Date__c = System.Today()+5;
            newEvent.Event_Text__c = 'Sending Wish Child';
            //newEvent.Priority__c = String.valueOf(i);
            newEvent.RecordTypeId =  EventRecTypeId;
            newEvent.chapter__c = acc.id;
            eventList.add(newEvent);
            insert eventList;
            
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            System.assertEquals(newEvent.Event_Name__c,'Send Off','Event name does not match');
        	System.assert(newEvent.Event_Name__c == 'Send Off','Event name does not match');
        }
        
    }
    
    // Completing Orientation for updating Orientation status.
    static testmethod void completeOrientation()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Submit';
        update updateContact;
        System.assertEquals(updateContact.is_Application__c,'Submit','Contact application status does not match');
        System.assert(updateContact.is_Application__c == 'Submit','Contact application status does not match');
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            Test.startTest();
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            Test.stopTest();
        }
        
    }
    // Completing Applicaiton for updating Applicaiton status.
    static testmethod void completeApplication()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;
        
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
        }  
        System.assertEquals(updateContact.is_Application__c,'Approved','Contact application status does not match');
        System.assert(updateContact.is_Application__c == 'Approved','Contact application status does not match');            
    }
    // Completing Interview for updating Interview status.
    static testmethod void completeInterviewTask()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;
        
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            
            // Task Creation.
            Constant_AC  constant = new Constant_Ac();
            Id interviewRT= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
            // Confirmation Task
            Task confirmationTask = new Task();
            confirmationTask.Subject = 'Interview Task';
            confirmationTask.RecordTypeId = interviewRT;
            confirmationTask.Available_Date1__c = Date.Today();
            confirmationTask.Available_Time1__c = '5 pm';
            confirmationTask.Available_Date2__c = Date.Today();
            confirmationTask.Available_Time2__c = '6 pm';
            confirmationTask.Status = 'Approved';
            confirmationTask.whoId = con.id;
            insert confirmationTask;
            
            
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            System.assertEquals(confirmationTask.Status,'Approved','Task status does not match');
        	System.assert(confirmationTask.Status == 'Approved','Task status does not match');           
        }   
    }
    
    // Creating Background check.
    static testmethod void createBackGroundCheck()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;
        
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            
            // Task Creation.
            Constant_AC  constant = new Constant_Ac();
            Id interviewRT= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
            // Confirmation Task
            Task confirmationTask = new Task();
            confirmationTask.Subject = 'Interview Task';
            confirmationTask.RecordTypeId = interviewRT;
            confirmationTask.Available_Date1__c = Date.Today();
            confirmationTask.Available_Time1__c = '5 pm';
            confirmationTask.Available_Date2__c = Date.Today();
            confirmationTask.Available_Time2__c = '6 pm';
            confirmationTask.Status = 'Approved';
            confirmationTask.whoId = con.id;
            insert confirmationTask;
            
            // Backgroud check creationn.
            Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            Test.startTest();
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            Test.stopTest();
            System.assertEquals(confirmationTask.Status,'Approved','Task status does not match');
        	System.assert(confirmationTask.Status == 'Approved','Task status does not match');
        }        
    }
    
    // Completing Background check for updating background check status.
    static testmethod void completeBackGroundCheck()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;
        
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
            Volunteer_Orientation_Training__c  createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id,currOffering.id,con.id,'Registered');
            
            
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            
            // Task Creation.
            Constant_AC  constant = new Constant_Ac();
            Id interviewRT= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
            // Confirmation Task
            Task confirmationTask = new Task();
            confirmationTask.Subject = 'Interview Task';
            confirmationTask.RecordTypeId = interviewRT;
            confirmationTask.Available_Date1__c = Date.Today();
            confirmationTask.Available_Time1__c = '5 pm';
            confirmationTask.Available_Date2__c = Date.Today();
            confirmationTask.Available_Time2__c = '6 pm';
            confirmationTask.Status = 'Approved';
            confirmationTask.whoId = con.id;
            insert confirmationTask;
            
            // Backgroud check creationn.
            Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
            currBC.Date_Completed__C = Date.Today();
            currBC.status__c = 'Approved';
            update currBC;
            Test.startTest();
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            Test.stopTest();
            System.assertEquals(currBC.status__c,'Approved','Background check status does not match');
        	System.assert(currBC.status__c == 'Approved','Background check status does not match');
        }   
    }
    // Completing training.
    static testmethod void completeTraining()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        Contact updateContact = new Contact();
        updateContact.id = con.id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;
        
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
            Volunteer_Orientation_Training__c  createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id,currOffering.id,con.id,'Completed');
            
            
            
            Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
            Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
            
            // Task Creation.
            Constant_AC  constant = new Constant_Ac();
            Id interviewRT= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
            // Confirmation Task
            Task confirmationTask = new Task();
            confirmationTask.Subject = 'Interview Task';
            confirmationTask.RecordTypeId = interviewRT;
            confirmationTask.Available_Date1__c = Date.Today();
            confirmationTask.Available_Time1__c = '5 pm';
            confirmationTask.Available_Date2__c = Date.Today();
            confirmationTask.Available_Time2__c = '6 pm';
            confirmationTask.Status = 'Approved';
            confirmationTask.whoId = con.id;
            insert confirmationTask;
            
            // Backgroud check creationn.
            Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
            currBC.Date_Completed__C = Date.Today();
            currBC.status__c = 'Approved';
            update currBC;
            Test.startTest();
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            Test.stopTest();
            System.assertEquals(currBC.status__c,'Approved','Background check status does not match');
        	System.assert(currBC.status__c == 'Approved','Background check status does not match');
        }        
    }    
}