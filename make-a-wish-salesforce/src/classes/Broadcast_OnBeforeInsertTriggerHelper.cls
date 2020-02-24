/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : Broadcast_OnBeforeInsertTriggerHelper is used to call the Helper class when the
              new Broadcast record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class Broadcast_OnBeforeInsertTriggerHelper{
    /********************************************************************************************
    This method is used to show the validation message when the current logged in user role and record chapter is mismatched.
*********************************************************************************************/
    public static void recordPermission(Set<Id> chapterIdSet , List<Broadcast__c> newBroadcastList){
       Map<String, String> ChapterRoleMap = new Map<String, String>();
       Map<Id,String> chapterNameMap = New Map<Id,String>();
        String userRole = [SELECT UserRole.Name FROM User WHERE id =:userInfo.getUserId() Limit 1].UserRole.Name;
      for(Account currAcc : [SELECT Id,Name FROM Account WHERE Id IN :chapterIdSet]){
           chapterNameMap.put(currAcc.Id,currAcc.Name);
       }
      for(Chapter_Vs_Role__c currChapterRole : [SELECT Chapter_Name__c, Role_Name__c FROM Chapter_Vs_Role__c WHERE Chapter_Name__c IN : chapterNameMap.values()])
      {
          ChapterRoleMap.put(currChapterRole.Chapter_Name__c,currChapterRole.Role_Name__c);
      }
      
       for(Broadcast__c currBroadcast : newBroadcastList){
           if(userRole != ChapterRoleMap.get(chapterNameMap.get(currBroadcast.Chapter_Name__c)) && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && !Test.isRunningTest()){
               currBroadcast.addError('You have no access to create broadcast records for other chapters');
           }
       }
    }
 }