/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeInsertHelper is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnBeforeInsertHelper{
   
   // Update Hidden Email Field    
    public static void UpdateHiddenEmailField(Set<Id> volunteerIds, List<Background_check__c> newRecords)
    {
        Map<Id, Contact> volunteerMap = new Map<Id, Contact>();
        for(Contact currRec : [SELECT Id,OwnerId,AccountId,Account.Name,Account.Phone,Account.Email__c, Email FROM Contact WHERE Id IN :volunteerIds])
        {
            volunteerMap.put(currRec.Id,currRec);
        }
        
        for(Background_check__c currRec : newRecords)
        {
            if(volunteerMap.containsKey(currRec.Volunteer__c)){
                currRec.Hidden_Volunteer_Contact_Email__c = volunteerMap.get(currRec.Volunteer__c).Email;
                currRec.OwnerId = volunteerMap.get(currRec.Volunteer__c).OwnerId;
            }
        }
    }
}