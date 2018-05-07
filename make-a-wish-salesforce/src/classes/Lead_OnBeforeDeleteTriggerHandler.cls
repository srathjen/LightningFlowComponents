/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : Lead_OnBeforeDeleteTriggerHandler is invoke when the lead record is deleted.
*****************************************************************************************************/

Public Class Lead_OnBeforeDeleteTriggerHandler{
/*********************************************************************************************************************
Lead_OnBeforeDeleteTriggerHandler is used to display an error message when you are going to delete lead record if the
lead file object will have the record.
************************************************************************************************************************/
  public static void onBeforeDelete(List<Lead> oldLeadList){
      Set<Id> ids = new Set<Id>();
      Set<Id> leadIdSet = new Set<Id>();
        for(Lead obj : oldLeadList)
        {    
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)        
                ids.add(obj.Id);     
        }  
        if(ids.size() > 0){           
        for(Lead_File__c  tempCount : [Select Id, Parent__c from Lead_File__c where Lead_File__c.WIP__c = false and Parent__c in:ids Limit 50000]){
            leadIdSet.add(tempCount.Parent__c);
        }
        }
        
        for(Lead obj : oldLeadList){
            if(leadIdSet.contains(obj.Id)){
                obj .addError('There are files attached to object. You need to first delete files manually and then delete the object!');
            }
        }
    }
}