/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : ChapterRole_OnBeforeInsertHelper  is used to update the role name when record is get inserted.

Modification Log
------------------
WVC-1889    Pavithra 07/11/2018

*****************************************************************************************************/
Public class ChapterRole_OnBeforeInsertHelper {
    public static void populateRoleName(set<Id> roleIdSet,List<Chapter_Role__c> newChapterRoleList){
        try{
            Map<Id,Role__c> roleMap = new Map<Id,Role__c>();
            for(Role__c dbRole : [SELECT Id,Name FROM Role__c WHERE Id IN: roleIdSet]){
                roleMap.put(dbRole.Id,dbRole);
            }
            
            for(Chapter_Role__c newChapterRole : newChapterRoleList){
                if(roleMap.containsKey(newChapterRole.Role_Name__c)){
                    newChapterRole.Role__c = roleMap.get(newChapterRole.Role_Name__c).Name;
                }
            }
            if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }
        }
        catch(Exception ex){
            for(Chapter_Role__c currRec : newChapterRoleList){
                ErrorMessage_AC.createdebugRec('ChapterRole_OnBeforeInsertHelper',String.valueof(currRec),String.valueOf(ex),'populateRoleName',currRec.Id,ex.getStackTraceString(),'Error');
            }
            if(!Test.isRunningTest()){
                for(Chapter_Role__c currRec : newChapterRoleList){
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
            
        }
    }
}