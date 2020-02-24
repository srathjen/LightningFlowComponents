/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : ChapterRole_OnBeforeUpdateHandler is used to update the role name when record is get update.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra 07/11/2018
              
*****************************************************************************************************/
Public class ChapterRole_OnBeforeUpdateHandler {
     public static void onBeforeUpdate(List<Chapter_Role__c> newChapterRoleList,Map<Id,Chapter_Role__c> oldChapterRoleMap){
        Set<Id> roleIdSet = new Set<Id>();
        Map<Id,Role__c> roleMap = new Map<Id,Role__c>();
        for(Chapter_Role__c newChapterRole : newChapterRoleList){
            if(newChapterRole.Role_Name__c != Null && newChapterRole.Role_Name__c != oldChapterRoleMap.get(newChapterRole.Id).Role_Name__c){
                roleIdSet.add(newChapterRole.Role_Name__c);
            }
        }
        
        if(roleIdSet.size() > 0)
            ChapterRole_OnBeforeInsertHelper.populateRoleName(roleIdSet,newChapterRoleList);
    }
}