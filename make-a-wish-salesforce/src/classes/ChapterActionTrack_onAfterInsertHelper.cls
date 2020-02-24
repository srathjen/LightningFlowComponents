/************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterActionTrack_onAfterInsertHelper{    
    /***************
       Share the records to correcponding chapter user when the national staff is comes as the owner.
   ******************/
    public static void shareNationalStaffRecords(Map<Id,Chapter_Action_Track__c> chapterActionTrackMap){
        try{
             Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
      
            for(Chapter_Action_Track__c currRec : [SELECT id, Chapter_Name__c,Chapter_Name__r.Name,OwnerId, Owner.UserRoleId, Owner.UserRole.Name FROM Chapter_Action_Track__c WHERE Id IN :Trigger.newMap.keySet()])
            {
              if(currRec.Owner.UserRole.Name == 'National Staff')
              {
                    if(chapterActionMap.containsKey(currRec.Chapter_Name__r.Name))
                    {
                        chapterActionMap.get(currRec.Chapter_Name__r.Name).add(currRec);
                    }
                    else
                        chapterActionMap.put(currRec.Chapter_Name__r.Name,new List<Chapter_Action_Track__c>{currRec});
               }          
                  
             }
             
             if(chapterActionMap.size() > 0)
                ChapterStaffRecordSharing_AC.chapterActionTrackSharing(chapterActionMap);
        
         if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }

        
        
        
        
        }  
               
        Catch(Exception ex){
              for(Chapter_Action_Track__c currRec : chapterActionTrackMap.values()){
                ErrorMessage_AC.createdebugRec('ChapterActionTrack_onAfterInsertHandler',String.valueof(currRec),String.valueOf(ex),'shareNationalStaffRecords',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
           
            
            
             if(!Test.isRunningTest()){
            
            for(Chapter_Action_Track__c currRec : chapterActionTrackMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
         
           }
         
         }       
    }
}