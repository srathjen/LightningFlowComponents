/****************************************
Created by : Vennila Paramasivam
Created Date : 07/24/2016.
Author : Mst Solutions.
Description : Unit Test for DynamicContent_AT Trigger.
****************************************/

@isTest
Public class DynamicContent_ATTest
{
    static testmethod void createDynamicContent()
    {
      Dynamic_Content__c dynamicContent1 = TestClassUtil.createDynamicContent();
      Dynamic_Content__c dynamicContent2 = TestClassUtil.createDynamicContent();
      
      dynamicContent1.Active__c = True;
      Database.SaveResult result = Database.Update(dynamicContent1,false);
      System.assertEquals('Active National Record already exist', result.getErrors()[0].getMessage());
    
    }
    static testmethod void createProspectDynamicContent()
    {
      Dynamic_Content__c dynamicContent1 = TestClassUtil.createProspectiveDynamicContent();
      Dynamic_Content__c dynamicContent2 = TestClassUtil.createProspectiveDynamicContent();
      dynamicContent1.Active__c = True;
      Database.SaveResult result = Database.Update(dynamicContent1,false);
      System.assertEquals('Active record already exist for this chapter and record type', result.getErrors()[0].getMessage());
    
    }

}