/**************************************************************************************
Description : This trigger will restrict the volunteer role updates from outside chapter stafff.
***************************************************************************************/

trigger VolunteerRole_AT on Volunteer_Roles__c (before update) 
{
   Set<String> chapterNamesSet = new Set<String>();
   for(Volunteer_Roles__c currRec : Trigger.new)
   {
        chapterNamesSet.add(currRec.Chapter_Name__c); 
   }
   
   Map<String, String> chapterRoleMap = new Map<String,String>();
   
   if(chapterNamesSet.size() > 0)
     chapterRoleMap = ChapterStaffRecordSharing_AC.FindChapterRole(chapterNamesSet);
     
   List<User> currUser = [SELECT id,UserRole.Name,Profile.Name FROM User WHERE id = :userInfo.getUserId() limit 1];  
   
   for(Volunteer_Roles__c currRec : Trigger.new)
   {
      if(chapterRoleMap.get(currRec.Chapter_Name__c) != currUser[0].UserRole.Name && currUser[0].UserRole.Name != 'National Staff' && currUser[0].profile.Name != 'System Administrator')
      {
         currRec.addError('Insufficient previlege to update this record. Please contact system administrator.');
      
      }
   } 
}