/*******************************************************************************
Description : Mapping fields from Contact to Conflict Of Interest. These fields are mail merge fields in email template.
*********************************************************************************/

trigger ConflictOfInterestTrigger_AT on Conflict_Of_Interest__c (before insert,before update,after update,after insert) {
    
    if((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isupdate))
    {
        Set<Id> volContactIdSet = new Set<Id>();
        Map<Id,Contact> conMap = new Map<Id, Contact>();
        for(Conflict_Of_Interest__c newCOI : Trigger.new){
                if(newCOI.Account_Name__c == Null || newCOI.Account_Phone__c == Null || newCOI.Hidden_Volunteer_Contact_Email__c == Null)
                volContactIdSet.add(newCOI.Volunteer_Contact__c);
        }
        
        for(Contact VoluContact : [SELECT Id,Email,AccountId,Account.Name,Account.Phone,Account.Email__c FROM Contact WHERE Id IN : volContactIdSet]){
            conMap.put(VoluContact.Id,VoluContact);
        }
        
        for(Conflict_Of_Interest__c newCOI : Trigger.new){
            if(conMap.containsKey(newCOI.Volunteer_Contact__c)){
                newCOI.Account_Name__c = conMap.get(newCOI.Volunteer_Contact__c).Account.Name;
                newCOI.Account_Phone__c= conMap.get(newCOI.Volunteer_Contact__c).Account.Phone;
                newCOI.Hidden_Volunteer_Contact_Email__c = conMap.get(newCOI.Volunteer_Contact__c).Email;
                newCOI.Account_Email__c = conMap.get(newCOI.Volunteer_Contact__c).Account.Email__c;
            }
            
            if(newCOI.Signed_Date__c != Null && (Trigger.isInsert || (Trigger.isUpdate && newCOI.Signed_Date__c != Trigger.oldMap.get(newCOI.id).Signed_Date__c)))
            {
                newCOI.Expiration_Date__c = newCOI.Signed_Date__c.addYears(1);
                if(newCOI.Active__c == False)
                   newCOI.Active__c = True;
            }
        }
     }
     
     if(Trigger.isInsert && Trigger.isAfter)
     {
         Set<Id> recordIds = new Set<Id>();
         Set<Id> volunteerIds = new Set<Id>();
         
         for(Conflict_Of_Interest__c  currCOI : Trigger.new)
         {
            if(currCOI.Active__c == True)
            {
                recordIds.add(currCOI.Id);
                volunteerIds.add(currCOI.Volunteer_Contact__c);
            }
         }
         
        if(volunteerIds.size() > 0 && recordIds.size() > 0)
        {
          UpdateExistingRecords(recordIds,volunteerIds);
        }
     }
     
     // Updating COI Expiration Date on Volunteer Contact.
     if(Trigger.isAfter && Trigger.isUpdate)
     {
       List<Contact> updateVolunteerContact = new List<Contact>();
       Set<Id> recordIds = new Set<Id>();
       Set<Id> volunteerIds = new Set<Id>();
        for(Conflict_Of_Interest__c  currCOI : Trigger.new)
        {
           if(currCOI.Expiration_Date__c  != Trigger.oldMap.get(currCOI.id).Expiration_Date__c && currCOI.Expiration_Date__c != Null)
           {
                if(currCOI.Volunteer_Contact__c != Null)
                {
                   Contact updateVolunteer = new Contact();
                   updateVolunteer.Id = currCOI.Volunteer_Contact__c;
                   updateVolunteer.COI_Expiration_Date__c = currCOI.Expiration_Date__c;
                   updateVolunteerContact.add(updateVolunteer);
                }
           }
           
           if(currCOI.Active__c == True && Trigger.oldMap.get(currCOI.id).Active__c == False)
            {
                recordIds.add(currCOI.Id);
                volunteerIds.add(currCOI.Volunteer_Contact__c);
                
            }
        }
        
        
        if(updateVolunteerContact.size() > 0)
          update updateVolunteerContact;
          
        if(volunteerIds.size() > 0 && recordIds.size() > 0)
        {
          UpdateExistingRecords(recordIds,volunteerIds);
        }
     }
     
     
     
     Static void UpdateExistingRecords(Set<Id> recordIds, Set<Id> volunteerIds)
     {
         List<Conflict_Of_Interest__c>  recordsToUpdate = new List<Conflict_Of_Interest__c>();
         for(Conflict_Of_Interest__c currRec : [SELECT id from Conflict_Of_Interest__c WHERE Volunteer_Contact__c IN :volunteerIds AND Id NOT IN :recordIds AND Active__c = True])
         {
             Conflict_Of_Interest__c newRec = new Conflict_Of_Interest__c();
             newRec.id = currRec.id;
             newRec.Active__c = false;
             recordsToUpdate.add(newRec);
             
         }
         
         if(recordsToUpdate.size() > 0)
             update recordsToUpdate;
     }

}