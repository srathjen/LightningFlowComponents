/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for WishTaskRecurrence_AC controller
*************************************************************************************/
@isTest
public class WishTaskRecurrence_AC_Test {
    
    @testSetup static void setup(){  
        Case parentCase = TestClassUtil.CreateParentCase();
        Contact wishChild = TestClassUtil.CreateWishChild();
        Account newchapterAccount = TestClassUtil.createchapterAccount();
        Chapter_Action_Track__c newAction = TestClassUtil.CreateChapterActionTrack();
        newAction.Chapter_Name__c = newchapterAccount.Id;
        insert newAction;
    }
    
    //This method is used to create recurrence task
    @isTest static void DeterminationCaseProcess() {
        Contact newContact = [SELECT Id FROM Contact];
        Case newCase = [SELECT Id FROM Case];
        
        Case newWishDeterminatonWish = TestClassUtil.DeterminationCaseProcess();
        newWishDeterminatonWish.ParentId = newCase.Id;
        newWishDeterminatonWish.ContactId = newContact.Id;
        insert newWishDeterminatonWish;
        
        Task newTask = TestClassUtil.CreateNewTask();
        newTask.WhatId = newWishDeterminatonWish.Id;
        insert newTask;
        
        Task anotherTask = TestClassUtil.CreateNewTask();
        anotherTask.WhatId = newWishDeterminatonWish.Id;
        anotherTask.Status = 'Completed';
        insert anotherTask;
        Test.setCreatedDate(anotherTask.Id, System.today()-1);
        
        Task anotherTask1 = TestClassUtil.CreateNewTask();
        anotherTask1.WhatId = newWishDeterminatonWish.Id;
        anotherTask1.Status = 'Completed';
        insert anotherTask1;
        Test.setCreatedDate(anotherTask1.Id, System.today()-1);
        
        Test.startTest();
        WishTaskRecurrence_AC c = new WishTaskRecurrence_AC();
        Database.executeBatch(c);
        Test.stopTest();
    }
}