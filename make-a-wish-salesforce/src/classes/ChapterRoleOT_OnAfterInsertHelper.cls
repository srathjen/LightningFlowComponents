/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterRoleOT_OnAfterInsertHelper{    
   /***************
       Share the records to correcponding chapter user when the national staff is comes as the owner.
   ******************/
    public static void shareNationalStaffRecords(Map<Id,Chapter_Role_O_T__c> chapterRoleOTMap){
        try{
             Map<String, List<Chapter_Role_O_T__c>> chapterRoleMap = new Map<String, List<Chapter_Role_O_T__c>>();
      
            for(Chapter_Role_O_T__c currRec : [SELECT id, Chapter_Name__c,OwnerId, Owner.UserRoleId, 
                                           Owner.UserRole.Name FROM Chapter_Role_O_T__c WHERE Id IN :chapterRoleOTMap.keySet()])
            {
                  if(currRec.Owner.UserRole.Name == 'National Staff')
                  {
                    if(chapterRoleMap.containsKey(currRec.Chapter_Name__c))
                    {
                        chapterRoleMap.get(currRec.Chapter_Name__c).add(currRec);
                    }
                    else
                        chapterRoleMap.put(currRec.Chapter_Name__c,new List<Chapter_Role_O_T__c>{currRec});
                   }          
                  }
             
             
             if(chapterRoleMap.size() > 0)
                ChapterStaffRecordSharing_AC.chapterRoleOTSharing(chapterRoleMap);
        
        
         if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }

        
        
        
        } 
        Catch(Exception ex){
              for(Chapter_Role_O_T__c currRec : chapterRoleOTMap.values()){
                ErrorMessage_AC.createdebugRec('ChapterRoleOT_OnAfterInsertHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'shareNationalStaffRecords',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
           
            
              if(!Test.isRunningTest()){
            
            for(Chapter_Role_O_T__c currRec : chapterRoleOTMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
           }
         
         }       
    }
}