/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 14/07/2016
Description : 
1. VolunteerOrientatioTrainingTrigger_AT  is used when the volunteer Attendance is completed then the 
corresponding volunteer contact status will be Active in the organization affiliation object.
*****************************************************************************************************/

trigger VolunteerOrientatioTrainingTrigger_AT on Volunteer_Orientation_Training__c (Before insert,Before update,After insert,After update) {
    
    if(trigger.isAfter && Trigger.isInsert)
    {
        Set<Id> contactId=new Set<Id>();
        Set<Id> trainingRegisteredVolIdsSet = new Set<Id>();
        List<User> userUpdateList=new List<User>();
        List<Contact> contactCompletedUpdate=new List<Contact>();
        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingList = new List<Volunteer_Orientation_Training__c>();
        for(Volunteer_Orientation_Training__c newVolInsert : Trigger.new)
        {
            if(newVolInsert.Type__c == 'Orientation' && newVolInsert.Volunteer_Attendance__c == 'Registered'){
                contactId.add(newVolInsert.Volunteer__c);
            }
                
            if(newVolInsert.Type__c == 'Training' && newVolInsert.Volunteer_Attendance__c == 'Registered' ){
                trainingRegisteredVolIdsSet.add(newVolInsert.Volunteer__c);
            }
        }
        
        if(trainingRegisteredVolIdsSet.size() > 0){
            VolunteerOandTTriggerHandler.updateVolunteerHiddenVolOTStatus(trainingRegisteredVolIdsSet, 'training');
        }
        
        system.debug('contactId ----->'+ contactId);
        if(contactId.size() > 0){
          //  VolunteerOandTTriggerHandler.updateVolunteerHiddenVolOTStatus(contactId, 'Orientation');
            VolunteerOandTTriggerHandler.updateUserVolunteerStatus(contactId, 'Registered');
        }
    }
    
    if(trigger.isAfter && Trigger.isUpdate)
    {
        
        Set<Id> volnteerContactIdSet = new Set<Id>();
        Set<Id> cancelContactId=new Set<Id>();
        Set<Id> registerdCountId=new Set<Id>();
        Set<Id> userUpdateContactId=new Set<Id>();
        Set<Id> contactUpdateContactId=new Set<Id>(); 
        Set<Id> completedCountId=new Set<Id>();
        List<User> updateUserList=new List<User>();
        List<Contact> updateContactList=new List<Contact>(); 
        Set<Id> completedContactSet=new Set<Id>();
        Set<Id> RegisteredVolunteer=new Set<Id>();
        Set<Id> registeredVolunteerIds =new Set<Id>();
        Set<Id> notRegistered=new Set<Id>();
        List<Contact> contactCompletedUpdate=new List<Contact>();
        
        
        for(Volunteer_Orientation_Training__c newVOL : Trigger.new)
        {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {
                if(newVOL.Volunteer_Attendance__c != Null && newVOL.Volunteer_Attendance__c == 'Completed' && newVol.Type__c == 'Training' )
                {
                    volnteerContactIdSet.add(newVOL.Volunteer__c);
                }
            }
            Volunteer_Orientation_Training__c oldVol = Trigger.oldMap.get(newVOL.Id);
            if(newVOL.Volunteer_Attendance__c == 'Completed' && newVol.Type__c == 'Orientation' && oldVol.Volunteer_Attendance__c!='Completed')
            {
                completedContactSet.add(newVOL.Volunteer__c);
                system.debug('after update volunteer Completed');
            }
            if(newVOL.Volunteer_Attendance__c == 'Registered' && newVol.Type__c == 'Orientation' && oldVol.Volunteer_Attendance__c!='Registered')
            {   system.debug('after update Registered'+ newVOL.Volunteer_Attendance__c);
                registeredVolunteerIds.add(newVOL.Volunteer__c);
            }
            
            if(newVOL.Volunteer_Attendance__c=='Volunteer Cancelled' && newVOL.Type__c=='Orientation' && oldVol.Volunteer_Attendance__c!='Volunteer Cancelled')
            {   system.debug('after update volunteer cancelled'+ newVOL.Volunteer_Attendance__c); 
                cancelContactId.add(newVOL.Volunteer__c);
            }
        }
        
        if(completedContactSet.size() > 0){
            // VolunteerOandTTriggerHandler.updateContact(completedContactSet); 
             system.debug('after update volunteer Completed ****'); 
             system.debug('after update volunteer Completed ****'+completedContactSet);
            for(Contact contactCompleted:[SELECT Id,Hidden_Volunteer_OT_Status__c FROM Contact WHERE Id in:completedContactSet])
            {
                Contact contactUpdate=new Contact();
                contactUpdate.Id=contactCompleted.Id;
                contactUpdate.Hidden_Volunteer_OT_Status__c='Orientation With Completed';
                contactCompletedUpdate.add(contactUpdate);
            }
        }
        
        
        if(registeredVolunteerIds.size() > 0){
            VolunteerOandTTriggerHandler.updateUserVolunteerStatus(registeredVolunteerIds, 'Registered');
        }
        
        If(volnteerContactIdSet.size() > 0){
            VolunteerOandTTriggerHandler.UpdateAffiliationStatusAsActive(volnteerContactIdSet);
        }
        
        
        // AggregateResult[] ARs=[SELECT Volunteer__c cntid, Count(id)cnt FROM Volunteer_Orientation_Training__c where Volunteer__c in:cancelContactId and Volunteer_Attendance__c='Registered' GROUP BY Volunteer__c ];
        for (AggregateResult ar : [SELECT Volunteer__c cntid, Count(id)cnt FROM Volunteer_Orientation_Training__c where Volunteer__c in:cancelContactId and Volunteer_Attendance__c='Registered' GROUP BY Volunteer__c ])
        {
            registerdCountId.add((Id)ar.get('cntid'));
        }
        
        for (AggregateResult ar : [SELECT Volunteer__c cntid, Count(id)cnt FROM Volunteer_Orientation_Training__c where Volunteer__c in:cancelContactId and Volunteer_Attendance__c='Completed' GROUP BY Volunteer__c ])
        {
            completedCountId.add((Id)ar.get('cntid'));
        }
        for(Volunteer_Orientation_Training__c votcancelupdate : Trigger.new)
        {
            if(cancelContactId.contains(votcancelupdate.Volunteer__c) && !registerdCountId.contains(votcancelupdate.Volunteer__c) && !completedCountId.contains(votcancelupdate.Volunteer__c))
            {
                userUpdateContactId.add(votcancelupdate.Volunteer__c);
            }
            else if(cancelContactId.contains(votcancelupdate.Volunteer__c) && registerdCountId.contains(votcancelupdate.Volunteer__c) && !completedCountId.contains(votcancelupdate.Volunteer__c))
            {
                contactUpdateContactId.add(votcancelupdate.Volunteer__c);
            }
        }
        system.debug('userUpdateContactId'+userUpdateContactId);
        
        if(contactUpdateContactId.size()>0)
        {
           // VolunteerOandTTriggerHandler.updateContact(contactUpdateContactId);          
            for(Contact contactUpdate:[SELECT Id,Hidden_Volunteer_OT_Status__c FROM Contact where Id in:contactUpdateContactId ])
            {
                Contact contactUpdation=new Contact();
                contactUpdation.Id=contactUpdate.Id;
                contactUpdation.Hidden_Volunteer_OT_Status__c='Orientation Without Completed';
                // userUpdation.Hidden_Volunteer_Cancelled__c=True;
                updateContactList.add(contactUpdation);
            }
        }
        if(userUpdateContactId.size()>0)
        {
            VolunteerOandTTriggerHandler.updateUserVolunteerStatus(userUpdateContactId, 'Volunteer Cancelled');
        }
        
        system.debug('updateUserList'+updateUserList);
        update updateContactList;
        update contactCompletedUpdate;
    }
    
    
    //This is used to map the acount name,phone,email values and merge those field in email template to send an email when volunteer reigster,cancel or completed the orientation and training
    if((trigger.isBefore && Trigger.isInsert) ||(trigger.isBefore  && trigger.isUpdate))
    {
        set<string> volOTSet = new set<string>();
        set<Id> oriandTrainingSet = new set<Id>();
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        Map<Id,Volunteer_Orientation_Training__c> volOriandTraingInfoMap = new Map<Id,Volunteer_Orientation_Training__c>();
        list<Contact> contacttList = new list<Contact>();
        Set<String> classOfferingIdSet = new Set<String>();
        Map<String,String> orientationIdMap = new Map<String,String>();
        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingList = new List<Volunteer_Orientation_Training__c>();  
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
                
                if( currRec.Volunteer__c != Null && currRec.Class_Offering__c != Null && (Trigger.isInsert || Trigger.oldMap.get(currRec.Id).Class_Offering__c  != currRec.Class_Offering__c )){
                    classOfferingIdSet.add(currRec.Class_Offering__c);
                }
                
                if(currRec.Type__c == 'Training' && currRec.Volunteer_Attendance__c == 'Registered'){
                    volunteerOrientationTrainingList.add(currRec);
                }
                
                if(currRec.Type__c == 'Training' && (currRec.Volunteer_Attendance__c == 'Completed' ||currRec.Volunteer_Attendance__c == 'Volunteer Cancelled')){
                    volunteerOrientationTrainingList.add(currRec);
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
        
        if(classOfferingIdSet.Size() > 0){
            for(Class_Offering__c currRec : [SELECT Id,Chapter_Role_O_T__r.Orientation_Training__c FROM Class_Offering__c WHERE Id IN : classOfferingIdSet]){
                orientationIdMap.put(currRec.Id,currRec.Chapter_Role_O_T__r.Orientation_Training__c);
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
                
                //Update the hidden O&T Id field with the orientation and training Id.
                if(currRec.Class_Offering__c != Null && currRec.Class_Offering__c!= Null  && orientationIdMap.containsKey(currRec.Class_Offering__c)){
                    currRec.Hidden_O_T_Id__c = orientationIdMap.get(currRec.Class_Offering__c);
                }
            }
        }
        
        if(volunteerOrientationTrainingList.size() > 0){
            VolunteerOandTTriggerHandler.UpdateContactRec(volunteerOrientationTrainingList);
        }
    }
}