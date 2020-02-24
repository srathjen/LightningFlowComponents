/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : COI_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new COI record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class COI_OnBeforeInsertTriggerHelper{
    /********************************************************************************************
    This method is used to create a task when the lead record is created. And share the lead
    record based on the chapter.
*********************************************************************************************/
    public static void mapAccountDetails(List<Conflict_Of_Interest__c > newCOIList,Set<Id> volContactIdSet){
        // try{
             Map<Id,Contact> conMap = new Map<Id, Contact>();
             for(Contact VoluContact : [SELECT Id,Email,AccountId,OwnerId,Region_Chapter__r.Name,Region_Chapter__r.Phone,Region_Chapter__r.Email__c,Region_Chapter__c FROM Contact WHERE Id IN : volContactIdSet]){
                conMap.put(VoluContact.Id,VoluContact);
            }
            
            for(Conflict_Of_Interest__c newCOI : newCOIList){
                if(conMap.containsKey(newCOI.Volunteer_Contact__c)){
                    newCOI.Account_Name__c = conMap.get(newCOI.Volunteer_Contact__c).Region_Chapter__r.Name;
                    newCOI.Account_Phone__c= conMap.get(newCOI.Volunteer_Contact__c).Region_Chapter__r.Phone;
                    newCOI.Hidden_Volunteer_Contact_Email__c = conMap.get(newCOI.Volunteer_Contact__c).Email;
                    newCOI.Account_Email__c = conMap.get(newCOI.Volunteer_Contact__c).Region_Chapter__r.Email__c;
                    newCOI.ownerId = conMap.get(newCOI.Volunteer_Contact__c).OwnerId;
                } 
           } 
      // }
       /* catch(Exception ex){
          for(Conflict_Of_Interest__c  currRec : newCOIList){
                ErrorMessage_AC.createdebugRec('COI_OnBeforeInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'mapAccountDetails',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
           
            for(Conflict_Of_Interest__c  currRec : newCOIList){
                currRec.addError(Label.Debug_log_error_message);
            }
       }*/
    }
}