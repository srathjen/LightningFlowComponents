@isTest
public class VolunteerLanding_AC_Test {
    
    // Capturing Dynamic content and Events. 
    static testmethod void createDynamicContent()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
            
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
            
            VolunteerLanding_AC controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.getEvents();
            controller.EnterchapterPage();
            
        }
        
    }
    // Create custom setting value.
    static testmethod void CreateHoldChapterValue()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        System.RunAs(currUser)
        {
            Dynamic_Content__c  createDynamicContent = OrientationandTrainingUtil.createDynamicContent();
            
            VolunteerLanding_AC controller = new VolunteerLanding_AC();
            controller.EnterchapterPage();
            
            
        }
    }
    
    // Display Promop upon login Training.
    static testmethod void checkBGandCOI()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        con.Broadcast_Number__c = '1234';
        update con;
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        VolunteerLanding_AC controller;
        Conflict_Of_Interest__c currCOI;
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
            Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            
            currCOI = OrientationandTrainingUtil.createCOI(con.id);
          }
            currCOI.Expiration_Date__c  = System.Today()+5;
            update currCOI;
            
           
        System.RunAs(currUser)
        {
            Broadcast__c currBroad = new Broadcast__c();
            currBroad.Broadcast_Message__c = 'Test';
            currBroad.Date__c = Date.Today() + 5;
            currBroad.Chapter_Name__c = acc.id;
            insert currBroad;
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            currOandT.Prompt_upon_login__c = True;
            update currOandT;
            
            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
            
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            controller.BackgroundCheck(false);
            controller.DisplayTraining(false);
            controller.register();
           // controller.confirmBackGroundCheck();
            controller.cancel();
            controller.cancelConflict();
            OrientationandTrainingUtil.insertDocusignSetting();
            controller.TrainingAckCancel();
            Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
            Test.StartTest();
            controller.confirmConflict();
            Test.StopTest();
        }
        controller.broadCastCancel();
    }
    // Background verfication and New BroadCast policy created.
    static testmethod void checkBackgroundCheck()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        con.Broadcast_Number__c = '1234';
        update con;
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        VolunteerLanding_AC controller;
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
            Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            
            Broadcast__c currBroad = new Broadcast__c();
            currBroad.Broadcast_Message__c = 'Test';
            currBroad.Date__c = Date.Today() + 5;
            currBroad.Chapter_Name__c = acc.id;
            insert currBroad;
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            currOandT.Prompt_upon_login__c = True;
            update currOandT;
            
            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
            
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            
            
        }
        controller.broadCastCancel();
    }
    // Background check and COI is interms of going to expired in 30 days.
    static testmethod void checkCOI()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        con.Broadcast_Number__c = '1234';
        update con;
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        VolunteerLanding_AC controller;
        Conflict_Of_Interest__c currCOI;
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
            currCOI = OrientationandTrainingUtil.createCOI(con.id);
         }
            currCOI.Expiration_Date__c  = System.Today()+5;
            update currCOI;
            
       System.RunAs(currUser)
        {   
            Broadcast__c currBroad = new Broadcast__c();
            currBroad.Broadcast_Message__c = 'Test';
            currBroad.Date__c = Date.Today() + 5;
            currBroad.Chapter_Name__c = acc.id;
            insert currBroad;
            
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
            
            Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            currOandT.Prompt_upon_login__c = True;
            update currOandT;
            
            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
            Volunteer_Orientation_Training__c  createVolOrientation = VolunteerLanding_AC_Test.createVolOrientation(currOandT.id,currOffering.id,con.id,'Registered');
            
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            
            
        }
        controller.broadCastCancel();
    }
    
    //Confict Of Interest Expired.
    static testmethod void checkCOIisExpired()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        VolunteerLanding_AC controller;
        Conflict_Of_Interest__c currCOI;
        
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
           currCOI = OrientationandTrainingUtil.createCOI(con.id);
        }
            currCOI.Expiration_Date__c  = System.Today()-5;
            update currCOI;
            
         System.RunAs(currUser)
        {   
            
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            
            
        }
        
    }
    // Backgroundcheck expired.
    static testmethod void checkBGisExpired()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        VolunteerLanding_AC controller;
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
            Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            currBG.Date__c = Date.Today()-5;
          //  update currBG;
            
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            
            
        }
        
    }
    // Registered the Background Verfication.But Verifiation pending status.
    static testmethod void checkBGStatus()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId()))
        {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        VolunteerLanding_AC controller;
        System.RunAs(currUser)
        {
            
            Dynamic_Content__c  createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(acc.id);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.id;
            currVal.CurrentChapter__c = acc.Name;
            insert currVal;
            
            Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            Background_check__c currBG1 = OrientationandTrainingUtil.createBackgroundCheck(con.id);
            currBG.Date__c = Date.Today().addYears(3);
            
           // update currBG;
           
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            
            
        }
        
    }
    
    // Creating Volunteer Traing based on the input parameter.
    static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId,Id volunteer,string status)
    {
        Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
        createNewVol.class_offering__c = ClassOfferingId;
        createNewVol.Orientation_Training__c = OrienationId;
        createNewVol.Registered_Date__c = Date.Today();
        createNewVol.Volunteer__c = volunteer;
        createNewVol.Volunteer_Attendance__c = status;
        createNewVol.Type__c = 'Training';
        insert createNewVol;
        return createNewVol;
    }     
}