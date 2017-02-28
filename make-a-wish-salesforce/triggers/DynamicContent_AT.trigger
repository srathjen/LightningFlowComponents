/*********************************************************************************************
Created by: Vennila Paramasivam
Author : MST Solutions
Created DAte:07/08/2015
Description : Dynamic Content should be just 1 national record and 63 chapter prospective and 63 chapter active (one for each chapter). 
So we can add an Active flag on the record. if we are creating a new national record or new chapter prospective record for Arizona 
(or any other chapter), then the previous record needs to inactive and the new one would be active.
**********************************************************************************************/

trigger DynamicContent_AT on Dynamic_Content__c (before insert,before update,after insert) {
    
     Set<Id> recordIdsSet = new Set<Id>(); 
     Set<String> recordTypesSet = new Set<String>();
     Set<String> chaptersSet = new Set<String>();
    
   
   // Updating Active flag as True by default.
   
   If(Trigger.isInsert && Trigger.isBefore)
   {
       for(Dynamic_Content__c currRec : Trigger.new)
       {
          currRec.active__c = True;
       }
   }
   
   // Preventing duplicate active flag updates.
   if(Trigger.isBefore && Trigger.isUpdate)
   {
       for(Dynamic_Content__c currRec : Trigger.new)
       {
         if(currRec.Active__c == True && Trigger.oldMap.get(currRec.id).active__c == false)
         {
            recordTypesSet.add(currRec.RecordTypeId);
            chaptersSet.add(currRec.chapter_Name__c);
            
         }
       }
   }
   
   if(recordTypesSet.size() > 0)
      DynamicContentHanlder.PreventingActiveUpdate(recordTypesSet,chaptersSet,Trigger.new);
   
   
   // Updating Active flag as False for previous records.
   if(Trigger.isInsert && Trigger.isAfter)
   { 
       
        for(Dynamic_Content__c currRec : Trigger.new)
        {
          if(currRec.active__c == True)
          {
             recordIdsSet.add(currRec.id);
             chaptersSet.add(currRec.chapter_Name__c);
             recordTypesSet.add(currRec.RecordTypeId);
          }
        }
   }
   
   if(recordIdsSet.size() > 0 && recordTypesSet.size() > 0)
      DynamicContentHanlder.UpdateActiveFlagAsFalse(recordIdsSet,chaptersSet,recordTypesSet);

}