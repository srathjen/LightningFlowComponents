/*******************************************************************************
Description : Sharing Records to Inside Chapter Staff.
*********************************************************************************/

trigger AwardsRecognition_AT on Awards_Recognition__c (after insert,after update) 
{
  
   Map<String, List<Awards_Recognition__c>> awardsRegMap = new Map<String, List<Awards_Recognition__c>>();
    
   for(Awards_Recognition__c currRec :[SELECT id, ownerId, owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c, 
                                       Chapter_Name__r.Name FROM Awards_Recognition__c WHERE Id IN :Trigger.newMap.keySet()])
   {
     if(currRec.Chapter_Name__c != Null && currRec.Owner.userRole.Name == 'National Staff') 
         {
                if(awardsRegMap.containsKey(currRec.Chapter_Name__r.Name))
                   awardsRegMap.get(currRec.Chapter_Name__r.Name).add(currRec);
                else
                   awardsRegMap.put(currRec.Chapter_Name__r.Name, new List<Awards_Recognition__c>{currRec});
         }
   } 
   
   if(awardsRegMap.size() > 0)
           ChapterStaffRecordSharing_AC.awardsRegRecordSharing(awardsRegMap);
    
}