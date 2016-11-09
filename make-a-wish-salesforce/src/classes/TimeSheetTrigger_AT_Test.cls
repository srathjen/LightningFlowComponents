/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 5/23/2016
Description : This TimeSheetTrigger_AT_Test is used to calculate the total hours spent by volunteer to close the wish and 
Non-wish & Event.
*******************************************************************************************************************/
@isTest
public class TimeSheetTrigger_AT_Test {
       
       /*Create Wish volunteer Opportunity time sheet*/
      public testmethod static void InsertWishTimeSheet(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,2);
        OrientationandTrainingUtil.crateWishTimeSheet(wishVolunteerOpportunityList);
        OrientationandTrainingUtil.crateWishTimeSheet(wishVolunteerOpportunityList );
        List<Time_sheet__c> updateTimeSheetList = new List<Time_sheet__c>();
        List<Time_sheet__c> timeSheetList = [SELECT Id,Volunteer_Opportunity__c,Volunteer_Opportunity__r.Wish__c,Hours_spent__c  FROM Time_sheet__c WHERE Volunteer_Opportunity__r.Wish__c =: parentCase.Id];
        for(Time_sheet__c processTimeSheetRec : timeSheetList){
            processTimeSheetRec.Hours_spent__c = 10.30;
            updateTimeSheetList.add(processTimeSheetRec);
        }
        
        update updateTimeSheetList;
        
        delete updateTimeSheetList;
      }
      
      /*Create Non Wish Volunteer Opportunity time sheet*/
       public testmethod static void InsertNonWishTimeSheet(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Non_Wish_Events__c nonWishEventId = OrientationandTrainingUtil.CreateEvent(chapterAccount.Id);
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        List<Volunteer_Opportunity__c> nonWishVolunteerOpportunityList =OrientationandTrainingUtil.NewnonWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,nonWishEventId.id,1);
        OrientationandTrainingUtil.crateNonWishTimeSheet(nonWishVolunteerOpportunityList,2);
        OrientationandTrainingUtil.crateNonWishTimeSheet(nonWishVolunteerOpportunityList,2);
       
        List<Time_sheet__c> updateTimeSheetList = new List<Time_sheet__c>();
        List<Time_sheet__c> timeSheetList = [SELECT Id,Volunteer_Opportunity__c,Volunteer_Opportunity__r.Non_Wish_Event__c,Hours_spent__c  FROM Time_sheet__c WHERE Volunteer_Opportunity__r.Wish__c =: nonWishEventId.Id];
        for(Time_sheet__c processTimeSheetRec : timeSheetList){
            processTimeSheetRec.Hours_spent__c = 10.45;
            updateTimeSheetList.add(processTimeSheetRec);
        }
        
        update updateTimeSheetList;
        
        delete updateTimeSheetList;
      }
     
   }