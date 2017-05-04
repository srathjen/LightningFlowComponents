/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 14/07/2016
Description : 
1. VolunteerOrientatioTrainingTrigger_AT  is used when the volunteer Attendance is completed then the 
corresponding volunteer contact status will be Active in the organization affiliation object.
*****************************************************************************************************/

trigger VolunteerOrientatioTrainingTrigger_AT on Volunteer_Orientation_Training__c (Before insert,Before update,After insert,After update) {
    
    if(trigger.isAfter && Trigger.isUpdate)
    {
        
        Set<Id> volnteerContactIdSet = new Set<Id>();
        for(Volunteer_Orientation_Training__c newVOL : Trigger.new)
        {
          if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
          {
            if(newVOL.Volunteer_Attendance__c != Null && newVOL.Volunteer_Attendance__c == 'Completed' && newVol.Type__c == 'Training')
            {
                volnteerContactIdSet.add(newVOL.Volunteer__c);
            }
          }
            
        }
        
        If(volnteerContactIdSet.size() > 0){
            VolunteerOandTTriggerHandler.UpdateAffiliationStatusAsActive(volnteerContactIdSet);
        }
        
    }
    
   
    //This is used to map the acount name,phone,email values and merge those field in email template to send an email when volunteer reigster,cancel or completed the orientation and training
    if((trigger.isBefore && Trigger.isInsert) ||(trigger.isBefore  && trigger.isUpdate))
    {
        set<string> volOTSet = new set<string>();
        set<Id> oriandTrainingSet = new set<Id>();
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        Map<Id,Volunteer_Orientation_Training__c> volOriandTraingInfoMap = new Map<Id,Volunteer_Orientation_Training__c>();
        list<Contact> contacttList = new list<Contact>();
        for(Volunteer_Orientation_Training__c currRec : Trigger.new)
        {
           if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
           {
                if(currRec.Volunteer__c != Null){
                    volOTSet.add(currRec.Volunteer__c);
                }
                if(currRec.Hidden_O_T_Id__c!= Null){
                    oriandTrainingSet.add(currRec.Id);
                }
            }
        }
        
        
        for(Contact getContactInfo : [SELECT ID, Name, Account.Name, Account.Phone,Email,Account.Email__c FROM contact 
                                      where id IN:volOTSet]) 
        {
            if(!contactInfoMap.containsKey(getContactInfo.Id)) {
                contactInfoMap.put(getContactInfo.Id, getContactInfo);
            }
        
        }
        
      for(Volunteer_Orientation_Training__c currRec : Trigger.new){
         if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
          {
            if(currRec.Volunteer__c != Null && contactInfoMap.containsKey(currRec.Volunteer__c)){
                currRec.Account_Name__c = contactInfoMap.get(currRec.Volunteer__c).Account.Name;
                currRec.Account_Phone__c = contactInfoMap.get(currRec.Volunteer__c).Account.Phone;
                currRec.VolunteerHidden_Email__c =  contactInfoMap.get(currRec.Volunteer__c).Email;
                currRec.Account_Email__c =  contactInfoMap.get(currRec.Volunteer__c).Account.Email__c;
            }
          }
             
        }
        
   }
    
}