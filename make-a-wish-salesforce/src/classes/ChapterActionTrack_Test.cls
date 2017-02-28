/************************************************************************************
Created Date :  8/8/2016
Author : Mst Solutions
Description : Unit Test for Chapter_Action_Track__c and ChapterActionTrackHandler
*************************************************************************************/
@isTest
public class ChapterActionTrack_Test {
  /*  
    //Used to create chapter and chapter action record
    @testSetup static void setup(){  
        Account newchapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Chapter_Action_Track__c newAction = OrientationandTrainingUtil.createChapterActionTrack();
        newAction.Chapter_Name__c = newchapterAccount.Id;
        newAction.Sort_Order__c = 1;
        insert newAction;
    }
    
    // Used to test validation if recurring frequency set to null
    @isTest static void updateChapterAction(){ 
        Chapter_Action_Track__c chapterAction =  [SELECT Id, Wish_type__c, Sort_Order__c, Recurring_Frequency__c, Recurring__c, Due_Date__c, Chapter_Name__c, Case_Type_Stage__c FROM Chapter_Action_Track__c];
        chapterAction.Sort_Order__c = 3;
        chapterAction.Recurring__c = true;
        chapterAction.Recurring_Frequency__c = null;
        chapterAction.Wish_type__c = 'Disney';
        chapterAction.Case_Type_Stage__c = 'Wish Planning & Anticipation';
        Database.saveResult result = Database.update(chapterAction,false);
        System.assertEquals('Recurring Frequency cannot be blank for Recurring Task',result.getErrors()[0].getMessage());
      
    }
    
    // Used to test validation if sort order set to null
    @isTest static void sortOrderAsNull(){ 
        Chapter_Action_Track__c chapterAction =  [SELECT Id, Wish_type__c, Sort_Order__c, Recurring_Frequency__c, Recurring__c, Due_Date__c, Chapter_Name__c, Case_Type_Stage__c FROM Chapter_Action_Track__c];
        chapterAction.Recurring__c = true;
        chapterAction.Sort_Order__c = null;
        chapterAction.Recurring_Frequency__c = 10;
        chapterAction.Wish_type__c = 'Disney';
        chapterAction.Case_Type_Stage__c = 'Wish Planning & Anticipation';
        Database.saveResult result = Database.update(chapterAction,false);
        System.assertEquals('Please Enter Sort Order',result.getErrors()[0].getMessage());
    }
    
    // Used to test validation if sort order set to zero
    @isTest static void sortOrderSizeCheck(){ 
        Chapter_Action_Track__c chapterAction =  [SELECT Id, Wish_type__c, Sort_Order__c, Recurring_Frequency__c, Recurring__c, Due_Date__c, Chapter_Name__c, Case_Type_Stage__c FROM Chapter_Action_Track__c];
        chapterAction.Recurring__c = true;
        chapterAction.Sort_Order__c = 0;
        chapterAction.Recurring_Frequency__c = 10;
        chapterAction.Wish_type__c = 'Disney';
        chapterAction.Case_Type_Stage__c = 'Wish Planning & Anticipation';
        Database.saveResult result = Database.update(chapterAction,false);
        System.assertEquals('Please Enter Sort Order greater than 0',result.getErrors()[0].getMessage());
        
    }
    
    // Used to test validation if wish stage set to null
    @isTest static void wishStageCheck(){ 
        Chapter_Action_Track__c chapterAction =  [SELECT Id, Wish_type__c, Sort_Order__c, Recurring_Frequency__c, Recurring__c, Due_Date__c, Chapter_Name__c, Case_Type_Stage__c FROM Chapter_Action_Track__c];
        chapterAction.Recurring__c = true;
        chapterAction.Sort_Order__c = 0;
        chapterAction.Recurring_Frequency__c = 10;
        chapterAction.Wish_type__c = 'Disney';
        chapterAction.Case_Type_Stage__c = null;
        Database.saveResult result = Database.update(chapterAction,false);
        System.assertEquals('Please Choose Wish Stage',result.getErrors()[0].getMessage());
    }
    
    // Used to test validation if role set to null
    @isTest static void roleNullCheck(){ 
        Chapter_Action_Track__c chapterAction =  [SELECT Id, Wish_type__c, Sort_Order__c, Recurring_Frequency__c, Recurring__c, Due_Date__c, Chapter_Name__c, Case_Type_Stage__c FROM Chapter_Action_Track__c];
        chapterAction.Recurring__c = true;
        chapterAction.Sort_Order__c = 0;
        chapterAction.Recurring_Frequency__c = 10;
        chapterAction.Wish_type__c = 'Disney';
        chapterAction.Case_Type_Stage__c = 'Wish Planning & Anticipation';
        chapterAction.Assigned_To__c=null;
        Database.saveResult result = Database.update(chapterAction,false);
        System.assertEquals('Please Choose Role',result.getErrors()[0].getMessage());
    }
    
    // Used to test duplicate record creation
    @isTest static void dupCheck(){ 
        Account chapterAccount = [SELECT Id FROM Account LIMIT 1];
        Chapter_Action_Track__c newAction = OrientationandTrainingUtil.createChapterActionTrack();
        newAction.Chapter_Name__c = chapterAccount.Id;
        newAction.Sort_Order__c = 2;
        insert newAction;
        Chapter_Action_Track__c updateSortOrder = [SELECT Id, Sort_Order__c FROM Chapter_Action_Track__c WHERE Sort_Order__c = 2 LIMIT 1];
        updateSortOrder.Sort_Order__c = 1;
        Database.SaveResult result = Database.update(updateSortOrder,false);
        System.assertEquals('Duplicate Exists',result.getErrors()[0].getMessage());
    }
    
    */
}