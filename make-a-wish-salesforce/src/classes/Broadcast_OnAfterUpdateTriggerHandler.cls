/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : Broadcast_OnAfterInsertTriggerHandler is used to call the Helper class when the
              new Broadcast record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class Broadcast_OnAfterUpdateTriggerHandler{
    /********************************************************************************************
    This method is used to share the record when the current logged in user role is National staff.
*********************************************************************************************/
    public static void onAfterUpdate(Map<Id,Broadcast__c> newBroadcastMap,Map<Id,Broadcast__c> OldBroadcastMap){
        Map<String, List<Broadcast__c>> broadCastMap = new Map<String, List<Broadcast__c>>();
      
         for(Broadcast__c currRec : [SELECT id, Chapter_Name__c,Chapter_Name__r.Name,OwnerId, Owner.UserRoleId, Owner.UserRole.Name FROM Broadcast__c WHERE Id IN :Trigger.newMap.keySet()])
        {
             if( currRec.OwnerId != OldBroadcastMap.get(currRec.id).OwnerId)
             {
                  if(currRec.Owner.UserRole.Name == 'National Staff')
                  {
                        if(broadCastMap.containsKey(currRec.Chapter_Name__r.Name))
                        {
                            broadCastMap.get(currRec.Chapter_Name__r.Name).add(currRec);
                        }
                        else
                            broadCastMap.put(currRec.Chapter_Name__r.Name,new List<Broadcast__c>{currRec});
                   }          
              }
         }
         
         if(broadCastMap.size() > 0)
            ChapterStaffRecordSharing_AC.broadRecordSharing(broadCastMap);
   }
}