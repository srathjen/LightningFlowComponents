/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : COI_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new COI record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class COI_OnBeforeUpdateTriggerHandler{
    /********************************************************************************************
    This method is used to create a task when the lead record is created. And share the lead
    record based on the chapter.
*********************************************************************************************/
    public static void OnBeforeUpdate(List<Conflict_Of_Interest__c > newCOIList,Map<Id,Conflict_Of_Interest__c> oldCOIMap){
        Set<Id> volContactIdSet = new Set<Id>();        
        for(Conflict_Of_Interest__c newCOI : newCOIList){
                if(newCOI.Account_Name__c == Null || newCOI.Account_Phone__c == Null || newCOI.Hidden_Volunteer_Contact_Email__c == Null)
                    volContactIdSet.add(newCOI.Volunteer_Contact__c);
                if (newCOI.Signed_Date__c != oldCOIMap.get(newCOI.id).Signed_Date__c && newCOI.Signed_Date__c != Null )
                {
                    newCOI.Expiration_Date__c = newCOI.Signed_Date__c.addYears(1);
                    if(newCOI.current__c == False)
                       newCOI.current__c = True;
                }
        }
         If(volContactIdSet.Size() > 0){
            COI_OnBeforeInsertTriggerHelper.mapAccountDetails(newCOIList,volContactIdSet);
        }       
    }
}