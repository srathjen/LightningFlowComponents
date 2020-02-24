/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : Broadcast_OnAfterInsertTriggerHandler is used to call the Helper class when the
              new Broadcast record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class Broadcast_OnAfterInsertTriggerHandler{
    /********************************************************************************************
    This method is used to show the validation message when the current logged in user role and record chapter is mismatched.
*********************************************************************************************/
    public static void onAfterInsert(Map<Id,Broadcast__c> newBroadcastMap){
        Map<String, List<Broadcast__c>> broadCastMap = new Map<String, List<Broadcast__c>>();
      
        for(Broadcast__c currRec : [SELECT id, Chapter_Name__c,Chapter_Name__r.Name,OwnerId, Owner.UserRoleId, Owner.UserRole.Name FROM Broadcast__c WHERE Id IN : newBroadcastMap.keySet()])
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
         
         if(broadCastMap.size() > 0)
            ChapterStaffRecordSharing_AC.broadRecordSharing(broadCastMap);
   }
}