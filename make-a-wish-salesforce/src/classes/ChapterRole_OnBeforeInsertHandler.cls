/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : ChapterRole_OnBeforeInsertHelper  is used to update the role name when record is get inserted.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra 07/11/2018
              
*****************************************************************************************************/
Public class ChapterRole_OnBeforeInsertHandler {
     public static void onBeforeInsert(List<Chapter_Role__c> newChapterRoleList){
        Set<Id> roleIdSet = new Set<Id>();
        Map<Id,Role__c> roleMap = new Map<Id,Role__c>();
        for(Chapter_Role__c newChapterRole : newChapterRoleList){            
            if(newChapterRole.Role_Name__c != Null){
                roleIdSet.add(newChapterRole.Role_Name__c);
            }
        }        
        if(roleIdSet.size() > 0)
            ChapterRole_OnBeforeInsertHelper.populateRoleName(roleIdSet,newChapterRoleList);
     }
}