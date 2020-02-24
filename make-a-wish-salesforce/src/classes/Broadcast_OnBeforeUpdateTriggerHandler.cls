/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : Broadcast_OnBeforeInsertTriggerHelper is used to call the Helper class when the
              new Broadcast record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class Broadcast_OnBeforeUpdateTriggerHandler{
     public static void OnBeforeUpdate(List<Broadcast__c> newBroadcastList, Map<Id,Broadcast__c> oldBroadCastMap){        
           String userRole = [SELECT UserRole.Name FROM User WHERE id =:userInfo.getUserId() Limit 1].UserRole.Name;
           Set<Id> chapterIdSet = new Set<Id>();       
           if(userRole != 'National Staff'){
               for(Broadcast__c currBroadcast : newBroadcastList){
                   if(currBroadcast.Chapter_Name__c != Null &&  currBroadcast.Chapter_Name__c != oldBroadCastMap.get(currBroadcast.Id).Chapter_Name__c)
                       chapterIdSet.add(currBroadcast.Chapter_Name__c);
               }
               if(chapterIdSet.Size() > 0){
                   Broadcast_OnBeforeInsertTriggerHelper.recordPermission(chapterIdSet,newBroadcastList);
               }
          }
     }
}