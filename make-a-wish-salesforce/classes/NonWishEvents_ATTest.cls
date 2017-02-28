/********************************************************
Created by : Vennila Paramasivam
Created Date: 07/24/2016
Description : Unit Test for NonWishEvents_AT
***********************************************************/

@isTest
public class NonWishEvents_ATTest
{

    @TestSetup static void createWishRecord()
    {
      Non_Wish_Events__c  newWish = new Non_Wish_Events__c();
      newWish.Event_Name__c= 'Test 1';
      newWish.Event_Date__c  = Date.Today().addDays(5);
      newWish.Priority__c = '1';
      newWish.chapter__c  = TestClassUtil.createVolunteerAccount().id;
      insert newWish;
    }
    static testmethod void createPastWish()
    {
      Non_Wish_Events__c  newWish = new Non_Wish_Events__c();
      newWish.Event_Name__c= 'Test 1';
      newWish.Event_Date__c  = Date.Today().addDays(-5);
      Database.SaveResult result = Database.Insert(newWish,false);
      //System.assertEquals('Event Date should be greater than Today', result.getErrors()[0].getMessage());
    
    }
    static testmethod void UpdateEventDate()
    {
       Non_Wish_Events__c currWish = [SELECT Id, Event_Date__c FROM Non_Wish_Events__c];
       currWish.Event_Date__c  = Date.Today().addDays(-5);
       Database.SaveResult result = Database.update(currWish,false);
       //System.assertEquals('Event Date should be greater than Today', result.getErrors()[0].getMessage());
        
    }
    static testmethod void UpdatePriority()
    {
       
       Non_Wish_Events__c currWish = [SELECT Id, Event_Date__c,chapter__c FROM Non_Wish_Events__c];
      
       Non_Wish_Events__c  newWish = new Non_Wish_Events__c();
       newWish.Event_Name__c= 'Test 1';
       newWish.Event_Date__c  = Date.Today().addDays(5);
       newWish.Priority__c = '2';
       newWish.chapter__c  = currWish.chapter__c;
       insert newWish;
      
       
       currWish.Priority__c = '2';
       currWish.Event_Date__c  = Date.Today().addDays(5);
       Database.SaveResult result = Database.update(currWish,false);
       System.assertEquals('This Chapter already has event for same priority. Please select some other priority.', result.getErrors()[0].getMessage());
       
    
    }


}