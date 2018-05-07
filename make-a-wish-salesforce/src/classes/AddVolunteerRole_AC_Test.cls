/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : AddVolunteerRole_AC_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
//AddVolunteerRole_AC_Test class is used to the unit testing of the AddVolunteerRole_AC class functionality
//This class has the four test methods to do the both possitive and negative testing
//This class is created by Kanagaraj
@isTest
public class AddVolunteerRole_AC_Test{
    
    /* This method is used to create number of NonWishEvent Volunteer Opportunity count */
    //This method will create chapter account
    //This method will created volunteer contact 
    //This method will update the volunteer contact
    public testmethod static void createNonWishEvent(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        Role__c nonWishRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,nonWishRole.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
        AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
        PageReference pageRef = Page.AddVolunteerRole_VF;
        pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
        Test.setCurrentPage(pageRef);
        Volunteer_Count__c  volnteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
        OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);
        addRole.addRow();
        addRole.RoleName = 'WishGranter';
        addRole.VolunteerCount = 3;
        addRole.isCommunity = false;
        Volunteer_Count__c   VolunteerNeededCount = [SELECT Id,Volunteer_Needed__c  FROM Volunteer_Count__c WHERE Id =: volnteerCount.Id Limit 50000];
        VolunteerNeededCount.Volunteer_Needed__c  = 2;
        update VolunteerNeededCount;
        addRole.EditRec();
        addRole.saveRec();
        addRole.cancelRec();
        addRole.ChapterRoleId = chapterRole.Id;
        addRole.register();
        System.assertEquals( VolunteerNeededCount.Volunteer_Needed__c, 2, 'Count does not Match');
        System.assert(VolunteerNeededCount.Volunteer_Needed__c == 2, 'The value of VolunteerNeededCount.Volunteer_Needed__c is: ' +VolunteerNeededCount.Volunteer_Needed__c + ' and the value of actual count is: 2');

        
    }
    
    /*This method is used to remove the volunteer contact from NonWishEvent Volunteer Opportunity*/
    
    public testmethod static void removeVolunteerContactonNonwishEvent(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        Role__c nonWishRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,nonWishRole.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
        AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
        PageReference pageRef = Page.AddVolunteerRole_VF;
        pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
        Test.setCurrentPage(pageRef);
        Volunteer_Count__c  volnteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
        OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);
        addRole.addRow();
        addRole.RoleName = 'WishGranter';
        addRole.VolunteerCount = 3;
        addRole.isCommunity = false;
        Volunteer_Count__c   VolunteerNeededCount = [SELECT Id,Volunteer_Needed__c  FROM Volunteer_Count__c WHERE Id =: volnteerCount.Id Limit 50000];
        VolunteerNeededCount.Volunteer_Needed__c  = 2;
        update VolunteerNeededCount;
        addRole.EditRec();
        if(addRole.volunteerCountToUpdateList.size() > 0)
        {
            addRole.volunteerCountToUpdateList.get(0).Chapter_Role__c = null;
        }
        addRole.saveRec();
        addRole.cancelRec();
        addRole.ChapterRoleId = chapterRole.Id;
        addRole.register();
        System.assertEquals(  addRole.VolunteerCount, 3, 'Count does not match');
        System.assert( addRole.VolunteerCount == 3, 'The value of  addRole.VolunteerCount is: ' + addRole.VolunteerCount + ' and the value of actual count is: 3');

        
    }
    
    /* This method is used to update number of NonWishEvent Volunteer Opportunity count */
    
    public testmethod static void updateNonWishEvent(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        Role__c nonWishRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,nonWishRole.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
        OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
        AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
        PageReference pageRef = Page.AddVolunteerRole_VF;
        pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
        Test.setCurrentPage(pageRef);
        OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
        OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);
        addRole.addRow();
        addRole.RoleName = 'WishGranter';
        addRole.VolunteerCount = 3;
        addRole.isCommunity = false;
        addRole.saveRec();
        addRole.EditRec();
        addRole.cancelRec();
        addRole.ChapterRoleId = chapterRole.Id;
        addRole.register();
        System.assertEquals(  addRole.ChapterRoleId, chapterRole.Id, 'Id does not match');
        System.assert(  addRole.ChapterRoleId == chapterRole.Id, 'The value of  addRole.ChapterRoleId is: ' + addRole.VolunteerCount + ' and the value chapterRole.Id is: '+ chapterRole.Id);

        
    }
    
    /* This method is used to Register the volunteer contact to NonWishEvent Volunteer Opportunity */
    
    public testmethod static void registerVolunteerContact(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        Role__c nonWishRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,nonWishRole.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
        OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);
        
        
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.ChapterName__c = chapterAccount.Id;
        update parentCase;
        
        
        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c(Chapter_Name__c = chapterAccount.Id, Chapter_Role_Opportunity__c = chapterRole.Id, Wish__c = parentCase.Id);
        insert volOpp;
        List<Volunteer_Opportunity__c> volOppList = new List<Volunteer_Opportunity__c>();
        volOppList.add(volOpp);
        ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
        AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
        PageReference pageRef = Page.AddVolunteerRole_VF;
        pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
        Test.setCurrentPage(pageRef);
        Non_Wish_Events__c nonWishEventRec = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        OrientationandTrainingUtil.createVolunteerCount(nonWishEventRec.Id,chapterRole.Id,3);
        OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEventRec.Id);
        addRole.addRow();
        addRole.addRow();
        addRole.RoleName = 'WishGranter';
        addRole.VolunteerCount = 3;
        addRole.isCommunity = false;
        addRole.saveRec();
        addRole.EditRec();
        addRole.cancelRec();
        addRole.ChapterRoleId = chapterRole.Id;
        addRole.register();
        addRole.allowRegisteration(volOppList);
        addRole.getChapterRoleOanTStatus(chapterRole.Id);
        addRole.sameValue = true;
        addRole.dateMessage = true;
        addRole.boolValue = true;
        addRole.displayErrorMsg();
        System.assertEquals(  addRole.ChapterRoleId, chapterRole.Id, 'Id does not match');
        System.assert(  addRole.ChapterRoleId == chapterRole.Id, 'The value of  addRole.ChapterRoleId is: ' + addRole.VolunteerCount + ' and the value chapterRole.Id is: '+ chapterRole.Id);

        
    }
    
}