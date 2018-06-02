/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnAfterInsertHelper is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnAfterInsertHelper{

  //Deactivate the primary if there are any existing record is primary  active.  
      public static void DeactivateExistingRecords(Set<Id> newRecordIds, Set<Id> volunteerIds,List<Background_check__c> exceptionList)
      {
        try{
            List<Background_check__c> deactivateExRecords = new List<Background_check__c>();
            for(Background_check__c exRec : [SELECT id,current__c FROM Background_check__c WHERE current__c = True AND Id NOT IN :newRecordIds AND Volunteer__c IN :volunteerIds])
            {
                Background_check__c updateRec = new Background_check__c();
                updateRec.current__c = false;
                updateRec.id = exRec.id;
                deactivateExRecords.add(updateRec);
                
            }
            
            if(deactivateExRecords.size() > 0)
            {
                Update deactivateExRecords;
            }
        }
        catch(Exception ex){
            for(Background_check__c currRec : exceptionList){
                ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterInsertHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'DeactivateExistingRecords',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(Background_check__c currRec : exceptionList){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
      // Updating most recent BC Expiration Date on Volunteer Contact.
    public static void UpdateVolunteerExpirationDate(Map<Id,Background_check__c>   expirationDateMap)
    {
        try{
            List<Contact> volunteerListToUpdate = new List<Contact>();
            for(Background_check__c currBGRec : expirationDateMap.values())
            {
                if(currBGRec.volunteer__c != Null)
                {
                    Contact updateVolunteer = new Contact();
                    updatevolunteer.id = currBGRec.volunteer__c;
                    updateVolunteer.B_C_Expiration_Date__c = currBGRec.Date__c;
                    volunteerListToUpdate.add(updateVolunteer);
                }
            }
            
            if(volunteerListToUpdate.size() > 0)
                update volunteerListToUpdate;
        }
        catch(Exception ex){
           for(Background_check__c currRec : expirationDateMap.Values()){
                ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterInsertHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdateVolunteerExpirationDate',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(Background_check__c currRec : expirationDateMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            } 
        }
        
    }
}