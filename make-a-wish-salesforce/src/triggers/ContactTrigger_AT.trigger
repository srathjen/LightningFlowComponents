/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : ContactTrigger_AT is used to assign the account Name for Volunteer contact. Based on the current logged in user role.
              Updating Affiliation status based on the application status.
*****************************************************************************************************/

trigger ContactTrigger_AT on Contact(Before Insert, after insert, Before Update,After update) {
    
    Constant_AC  constant = new Constant_AC();
    Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    List<Contact> contactList= new List<Contact>();
    Set<Id> volunteerIdSet = new Set<Id>();
    Map<String, String> monthValMap = new Map<String, String>();
    monthValMap.put('January','1');
    monthValMap.put('February','2');
    monthValMap.put('March','3');
    monthValMap.put('April','4');
    monthValMap.put('May','5');
    monthValMap.put('June','6');
    monthValMap.put('July','7');
    monthValMap.put('August','8');
    monthValMap.put('September','9');
    monthValMap.put('October','10');
    monthValMap.put('November','11');
    monthValMap.put('December','12');
    
    
    // Birthdate concatenation.
    if(Trigger.isBefore && Trigger.isInsert){
        for(Contact newContact : Trigger.new){
            
            if(newContact.RecordTypeId == volunteerRecordTypeId){
                
                contactList.add(newContact );
            }
            
            if(newContact.birth_day__c != Null && newContact.birth_year__c != Null && newContact.birth_month__c != Null)
            {
                date dtConverted = Date.valueOf(newContact.birth_year__c+'-'+monthValMap.get(newContact.birth_month__c)+'-'+newContact.birth_day__c);
                newContact.BirthDate = dtConverted ;
            }
        }
        if(contactList.size() > 0){
            ContactTriggerHandler handlerIns = new ContactTriggerHandler();
            handlerIns.updateAccountName(contactList);
        }
    }
    // Birthdate concatenation at before update.
    if(Trigger.isBefore && Trigger.isUpdate){
              
        for(Contact newContact : Trigger.new){
            if(newContact.Birth_Month__c != Null && newContact.Birth_Day__c != Null && newContact.Birth_Year__c != Null){
                
                if(newContact.Birth_Year__c != trigger.oldmap.get(newContact.Id).Birth_Year__c || newContact.Birth_Month__c != trigger.oldmap.get(newContact.Id).Birth_Month__c || newContact.Birth_Day__c != trigger.oldmap.get(newContact.Id).Birth_Day__c ){
                    contactList.add(newContact );
                }
                if(newContact.birth_day__c != Null && newContact.birth_year__c != Null && newContact.birth_month__c != Null)
                {System.debug('>>>>'+newContact.birth_month__c);
                 date dtConverted = Date.valueOf(newContact.birth_year__c+'-'+monthValMap.get(newContact.birth_month__c)+'-'+newContact.birth_day__c);
                 newContact.BirthDate = dtConverted ;
                }
            }
           
        }
       
      
    }
  
 /* if(Trigger.isAfter && Trigger.isInsert){
      List<cg__ContactFile__c> lstContactFile = new List<cg__ContactFile__c>();
      for(Contact newContact : Trigger.new){
          if(newContact.RecordTypeId == wichChildRecordTypeId){
                cg__ContactFile__c picFolder =new cg__ContactFile__c();
                picFolder.cg__Contact__c = newContact.Id;
                picFolder.cg__Content_Type__c = 'Folder';
                picFolder.cg__File_Name__c = 'Photos';
                picFolder.cg__WIP__c = false;
                lstContactFile.add(picFolder);
                
                cg__ContactFile__c docFolder =new cg__ContactFile__c();
                docFolder.cg__Contact__c = newContact.Id  ;
                docFolder.cg__Content_Type__c = 'Folder';
                docFolder.cg__File_Name__c = 'Documents';
                docFolder.cg__WIP__c = false;
                lstContactFile.add(docFolder);
                
                cg__ContactFile__c videosFolder =new cg__ContactFile__c();
                videosFolder.cg__Contact__c = newContact.Id  ;
                videosFolder.cg__Content_Type__c = 'Folder';
                videosFolder.cg__File_Name__c = 'Videos';
                videosFolder.cg__WIP__c = false;
                lstContactFile.add(videosFolder);
          }
      } 
      insert lstContactFile;
  }*/
    // Affiliation Status update whenever Application status is changed.
    // creating task for volunteer manager whenever zipcode has been changed.
    // Whenever volunteer role has been changed on volunteer role field, volunteer rold record has created/deleted based on that.
    if(Trigger.isAfter && Trigger.isupdate){
       
        set<Id> volunteercontactSet = new Set<Id>();
        Map<Id,Contact> volunteerContactMap = new Map<Id,Contact>();
        Set<Id> rejectedApplicationIds = new Set<Id>();
        
        Set<String> zipCodesSet = new Set<String>();
        Map<Id,Contact> contactMap = new Map<Id, Contact>();
        for(Contact newContact : trigger.new){
           
            if(newContact.is_Application__c == 'Complete' && newContact.is_Application__c != trigger.oldmap.get(newContact.id).is_Application__c){
                volunteercontactSet.add(newContact.Id);
                
            }
            if(newContact.is_Application__c == 'Rejected' && newContact.is_Application__c != trigger.oldmap.get(newContact.id).is_Application__c)
            {
                rejectedApplicationIds.add(newContact.id);
            }
            
            if((newContact.recordTypeId == volunteerRecordTypeId) && newContact.Volunteer_Role__c != Null && (newContact.Volunteer_Role__c != Trigger.oldMap.get(newContact.id).Volunteer_Role__c))
            {
                volunteerContactMap.put(newContact.id, newContact);
            }
            
            if(newContact.MailingPostalCode != Trigger.oldMap.get(newContact.id).MailingPostalCode && newContact.RecordTypeId == volunteerRecordTypeId)
            {
              contactMap.put(newContact.id, newContact);
              zipCodesSet.add(newContact.MailingPostalCode);
            }
        }
      
        if(volunteercontactSet.size() > 0){
            ContactTriggerHandler.updateOrgAffiliationStatustopending(volunteercontactSet);
        }
        if(rejectedApplicationIds.size() > 0)
        {
            ContactTriggerHandler.updateOrgAffiliationStatustoDeclined(rejectedApplicationIds);
        }
        
        if(volunteerContactMap.size() > 0)
            ContactTriggerHandler.CreateVolunteerRoles(volunteerContactMap);
        
        if(zipCodesSet.size() > 0)
            ContactTriggerHandler.CreateZipcodeUpdateTask(zipCodesSet,contactMap);
       
    }
    
        
}