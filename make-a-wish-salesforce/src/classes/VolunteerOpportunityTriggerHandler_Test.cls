@isTest
public class VolunteerOpportunityTriggerHandler_Test {
     /*Submit volunteer Opportunity to approval process*/
    
   //Update the NonWish Volunteer Opportunity count 
    
    public testmethod static void  UpdateNeededOpportunityCount(){   
        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        Role__c nonWishRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,nonWishRole.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
        Volunteer_Opportunity__c volOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);     
        Volunteer_Opportunity__c nonWishvolOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);     
        User volunteerUser;
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> volIdSet = new Set<Id>();
        Volunteer_Count__c  volunteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,2);
         Volunteer_Opportunity__c  volOpp = [SELECT Id,Volunteer_Name__c ,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Id=:volOpportunity.Id LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())){
             volunteerUser =  OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
              volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c+String.Valueof(volOpp.Non_Wish_Event__c);
             Update volunteerUser;             
        }  
        volOpportunity.Volunteer_Name__c  = volunteerContact.Id;
        volOpportunity.Status__c = 'Approved';
        test.startTest();
        update volOpportunity;
        Volunteer_Opportunity__c  deleteOpportunity = new Volunteer_Opportunity__c ();
        deleteOpportunity.Id = volOpportunity.Id;
       // deleteOpportunity.Volunteer_Name__c  = Null;
        deleteOpportunity.Status__c = 'Approved'; 
        deleteOpportunity.Hidden_VolunteerCount_Desc__c  = 'test';
        // deleteOpportunity.Volunteer_Needed__c = 2;    
        update deleteOpportunity;
       
          System.runAs(new User(Id = UserInfo.getUserId())){
            volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c+String.Valueof(volOpp.Non_Wish_Event__c);
             //Update volunteerUser;
            // System.AssertEquals(volunteerUser.Hidden_Role_Name_Id__c ,'');
        }
       delete deleteOpportunity;
       userIdSet.add(deleteOpportunity.Id);
       volIdSet.add(volunteerContact.Id);
      // VolOpportunity_OnBefore_Delete_Helper.updateUserRoleId(userIdSet,volIdSet );
        test.stopTest();
    }
    
     public testmethod static void  DeleteOpportunityCount(){   
        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser;
             
        Role__c nonWishRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,nonWishRole.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
       Volunteer_Opportunity__c volOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);     
        Set<Id> userIdset = new Set<Id>();
        Set<Id> volId = new Set<ID>();
        Set<Id> nonWishEventIdsSet = new Set<Id>();
        Volunteer_Count__c  volunteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,2);
        List<Volunteer_Opportunity__c> volOppList = new List<Volunteer_Opportunity__c>();
        volOppList.add(volOpportunity);
        nonWishEventIdsSet.add(nonWishEvent.id);
        volId.add(volOpportunity.id);
        
         Volunteer_Opportunity__c  volOpp = [SELECT Id,Volunteer_Name__c ,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Id=:volOpportunity.Id LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())){
            volunteerUser =  OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
             volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c+String.Valueof(volOpp.Non_Wish_Event__c);
             Update volunteerUser;
            userIdset.add(volunteerUser.id);
             VolOpportunity_OnAfter_Update_Helper.updateUserRoleId(volId,userIdset);
           
        }  
        OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id,chapterRole.Id,3);
       // Volunteer_Opportunity__c volOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id,chapterRole.Id,nonWishEvent.Id);     
        volOpportunity.Volunteer_Name__c  = volunteerContact.Id;
        update volOpportunity;
        Volunteer_Opportunity__c  deleteOpportunity = new Volunteer_Opportunity__c ();
        System.runAs(new User(Id = UserInfo.getUserId())){
            volunteerUser.Hidden_Role_Name_Id__c =volOpportunity.Chapter_Role_Opportunity__r.Role_Name__c+String.Valueof(volOpportunity.Non_Wish_Event__c);
             Update volunteerUser;
        }
        volunteerCount.Volunteer_Needed__c = 2;
        Update volunteerCount;
        deleteOpportunity.Id = volOpportunity.Id;
        VolOpportunity_OnAfter_Update_Helper.updateVolunteerRegisterdCount(volOppList,nonWishEventIdsSet,true);
        VolOpportunity_OnAfter_Delete_Hepler.updateVolunteerRegisterdCount(volOppList,volId,true);
        //deleteOpportunity.Volunteer_Name__c  = Null;
        test.startTest();
       // update deleteOpportunity;
        delete deleteOpportunity;
        test.stopTest();
    }
}