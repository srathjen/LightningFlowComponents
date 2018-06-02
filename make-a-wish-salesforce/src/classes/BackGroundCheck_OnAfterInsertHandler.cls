/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnAfterInsertHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnAfterInsertHandler{

     public static void OnAfterInsert(List<Background_check__c> newBCList){
         
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        Map<String,List<Background_check__c>> bgcMap = new Map<String,List<Background_check__c>>();
        Map<Id,Background_check__c>   expirationDateMap = new Map<Id,Background_check__c>(); 
        
        for(Background_check__c currRec : newBCList)
        {
            ownerIds.add(currRec.OwnerId);
        }
        
        Map<Id,String> userRoleMap = UserRoleUtility.getUserRole(ownerIds);
        
        //  Map<String,List<Background_check__c>> bgcMap = new Map<String,List<Background_check__c>>();
        for(Background_check__c  currRec : newBCList)
        {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {
                if(currRec.current__c == True)
                {
                    newRecordIds.add(currRec.id);
                    volunteerIds.add(currRec.Volunteer__c);
                }
                
                if(currRec.Account_Name__c != Null && userRoleMap.get(currRec.OwnerId) == 'National Staff')
                {  
                    if(bgcMap.containsKey(currRec.Account_Name__c))
                    {
                        bgcMap.get(currRec.Account_Name__c).add(currRec);
                    }
                    else
                        bgcMap.put(currRec.Account_Name__c,new List<Background_check__c>{currRec});
                }
                
                if(currRec.Date__c != Null && currRec.current__c == True)
                {
                    expirationDateMap.put(currRec.id,currRec);
                }
                
            }
            
        }
        if(newRecordIds.size() > 0 && volunteerIds.size() > 0)
        {
            BackGroundCheck_OnAfterInsertHelper.DeactivateExistingRecords(newRecordIds,volunteerIds,newBCList);
        }
        
        if(bgcMap.size() > 0)
        {
            ChapterStaffRecordSharing_AC.BGCRecordSharing(bgcMap);
        }
        
        if(expirationDateMap.size() > 0)
        {
            BackGroundCheck_OnAfterInsertHelper.UpdateVolunteerExpirationDate(expirationDateMap);
        }
     }
}