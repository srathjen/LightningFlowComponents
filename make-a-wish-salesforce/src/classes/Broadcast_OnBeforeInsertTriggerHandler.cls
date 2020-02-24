/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : Broadcast_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new Broadcast record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class Broadcast_OnBeforeInsertTriggerHandler{
    /********************************************************************************************
    this method process the all records in before insert.
*********************************************************************************************/
    public static void OnBeforeInsert(List<Broadcast__c> newBroadcastList){
           String userRole = [SELECT UserRole.Name FROM User WHERE id =:userInfo.getUserId() Limit 1].UserRole.Name;
           Set<Id> chapterIdSet = new Set<Id>();
           Map<String, String> ChapterRoleMap = new Map<String, String>();
           Map<Id,String> chapterNameMap = New Map<Id,String>();
           //Prevent the user to create broadcast records for other chapters.
           if(userRole != 'National Staff'){
           for(Broadcast__c currBroadcast : newBroadcastList){
               if(currBroadcast.Chapter_Name__c != Null  )
                   chapterIdSet.add(currBroadcast.Chapter_Name__c);
           }
           if(chapterIdSet.Size() > 0){
               Broadcast_OnBeforeInsertTriggerHelper.recordPermission(chapterIdSet,newBroadcastList);
           }
        }
   }
}