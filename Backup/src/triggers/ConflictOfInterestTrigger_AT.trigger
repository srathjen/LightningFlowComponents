/*******************************************************************************
Description : Mapping fields from Contact to Conflict Of Interest. These fields are mail merge fields in email template.
*********************************************************************************/

trigger ConflictOfInterestTrigger_AT on Conflict_Of_Interest__c (before insert,before update,after update) {
    
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
        }
     }
     
     // Updating COI Expiration Date on Volunteer Contact.
     if(Trigger.isAfter && Trigger.isUpdate)
     {
       List<Contact> updateVolunteerContact = new List<Contact>();
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
        }
        
        
        if(updateVolunteerContact.size() > 0)
          update updateVolunteerContact;
     }

}