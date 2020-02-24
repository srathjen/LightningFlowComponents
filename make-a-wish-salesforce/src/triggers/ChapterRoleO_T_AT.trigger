/***********************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
************************************************************************************************************/
trigger ChapterRoleO_T_AT on Chapter_Role_O_T__c (After insert, After update) 
{
   if(Trigger.isUpdate && Trigger.isAfter)
   {
     ChapterRoleOT_OnAfterUpdateHandler.afterUpdate(Trigger.newMap,Trigger.OldMap);   
   }
   If(Trigger.isInsert && Trigger.isAfter){
       ChapterRoleOT_OnAfterInsertHandler.afterInsert(Trigger.newMap);  
   }

}