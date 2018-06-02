/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeUpdateHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnBeforeUpdateHandler{

     public static void OnBeforeUpdate(List<Background_check__c> newBCList,Map<Id,Background_check__c> oldBCMap){
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> volContactIdSet = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        for(Background_check__c currRec : newBCList)
        {   
            volunteerIds.add(currRec.volunteer__c);
            if(currRec.Date_Completed__c != null && currRec.Date_Completed__c != oldBCMap.get(currRec.id).Date_Completed__c )
            {
                currRec.Date__c = currRec.Date_Completed__c.addYears(3);
            }
            
            if((currRec.Date_Completed__c != null && CurrRec.Date_Completed__c != oldBCMap.get(currRec.id).Date_Completed__c) 
               && (currRec.Status__c != Null) && currRec.Status__c != oldBCMap.get(currRec.id).status__c)
            {
                currRec.current__c = True;
            }
            
            
            if(currRec.current__c == True && oldBCMap.get(currRec.id).current__c == false)
            { 
                newRecordIds.add(currRec.id);
                volContactIdSet.add(currRec.volunteer__c);
            }
            
            
            
        }
        if(volunteerIds.size() > 0)
        {
            BackGroundCheck_OnBeforeInsertHelper.UpdateHiddenEmailField(volunteerIds,newBCList);
        }
        
        /*  List<Background_check__c> exActiveRecList = [SELECT Id FROM Background_check__c WHERE current__c = True AND ID NOT IN :newRecordIds];
        
        for(Background_check__c currRec : Trigger.new)
        {
        
        if(currRec.current__c == True && Trigger.oldMap.get(currRec.id).current__c == false)
        {
        if(exActiveRecList.size() > 0 && volContactIdSet.contains(currRec.volunteer__c))
        currRec.addError('Active Background Check Already Exist'); 
        }
        
        }*/
     }
}