/*************************************************************************************************************************************************
Created by: Pavithra
Author : MST Solutions
CreateDate : 10/05/2016
Description :Batch_UpdateVolunteerStatus_Test is used to increase the code coverage for Batch_UpdateVolunteerStatus_AC class.
*************************************************************************************************************************************************/

@isTest
public class Batch_UpdateVolunteerStatus_Test{
     static testmethod void  updateVolunteerStatus(){
         Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
         npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
         affiliation.npe5__Status__c = 'Active';
         Update affiliation;
         
         
         
         Background_check__c bc = OrientationandTrainingUtil.createBackgroundCheckRec(volunteerContact.Id);
         Conflict_Of_Interest__c conOfIntrest = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
         
         Role__c wishGranterRole = OrientationandTrainingUtil.createRole();
         Role__c nonWishRole = OrientationandTrainingUtil.createNonWishRole();
         Role__C boardMemberRole =  OrientationandTrainingUtil.createRole();
         boardMemberRole.Name = 'Board Member';
         Update boardMemberRole;
        
         Chapter_Role__c wishGranterChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id,wishGranterRole.Id);
         Chapter_Role__c nonWishChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id,nonWishRole.Id);
         Chapter_Role__c boardMemberChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id,boardMemberRole.Id);
        
         Volunteer_Roles__c wishGranterVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id,wishGranterChapterRole.Id);
         Volunteer_Roles__c nonWishVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id,nonWishChapterRole.Id);
         Volunteer_Roles__c boardMemberVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id,boardMemberChapterRole.Id);
         
         Database.executeBatch(new Batch_UpdateVolunteerStatus_AC());
        
        system.assertEquals(boardMemberRole.Name,'Board Member','Role is not board member');
        system.assert(affiliation.npe5__Status__c == 'Active','status updated incorrectly' );
    }
      static testmethod void  updateVolunteerSingleActiveStatus(){
        Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
         npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
         affiliation.npe5__Status__c = 'Active';
         Update affiliation;
        
        //Chapter_Role__c singleDayChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id,wishGranterRole.Id);
        Role__C singleDayEventRole =  OrientationandTrainingUtil.createRole();
        singleDayEventRole.Name = 'Single Day Event Volunteer';
        Update singleDayEventRole;
        
        Chapter_Role__c singleDayChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id,singleDayEventRole.Id);
        Volunteer_Roles__c singleDayVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id,singleDayChapterRole.Id); 
       
        Non_Wish_Events__c event = OrientationandTrainingUtil.CreateEventRec(singleDayChapterRole.Id,chapterAc.Id);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Volunteer_Opportunity__c  wishVolOpp = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(chapterAc.Id,singleDayChapterRole.Id,wish.Id);
        Volunteer_Opportunity__c  nonWishVolOpp = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAc.Id,singleDayChapterRole.Id,event.Id);
        List<Volunteer_Opportunity__c> volOppList =  new List<Volunteer_Opportunity__c>();
        wishVolOpp.Volunteer_Name__c = volunteerContact.Id;
        nonWishVolOpp.Volunteer_Name__c = volunteerContact.Id;
        volOppList.add(wishVolOpp);
        volOppList.add(nonWishVolOpp);
        Update volOppList;
        Database.executeBatch(new Batch_UpdateVolunteerStatus_AC());
        
        system.assertEquals(volOppList[0].Volunteer_Name__c ,volunteerContact.Id,'Contact id does not match');
        system.assert(singleDayEventRole.Name == 'Single Day Event Volunteer','Role name does not match' );
     }
    
    
}