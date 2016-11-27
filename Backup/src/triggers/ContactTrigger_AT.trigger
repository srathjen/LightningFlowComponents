/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : ContactTrigger_AT is used to assign the account Name for Volunteer contact. Based on the current logged in user role.
Updating Affiliation status based on the application status.
*****************************************************************************************************/

trigger ContactTrigger_AT on Contact(Before Insert, after insert, Before Update,After update,After delete) {
    
    Constant_AC  constant = new Constant_AC();
    Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
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
        /*if(contactList.size() > 0){
            ContactTriggerHandler handlerIns = new ContactTriggerHandler();
            handlerIns.updateAccountName(contactList);
        }*/
    }
    // Birthdate concatenation at before update.
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> wishChildIdSet = new Set<Id>();
        Map<Id,Contact> wishFamilyMap = new Map<Id,Contact>();
        Set<Id> wishFamliySet = new Set<Id>();
        set<Id> recallWishChild = new Set<Id>();
        
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
            
            if(newContact.RecordTypeId == wichChildRecordTypeId && newContact.IsContactInfoUpdated__c == true){
                if(newContact.Hidden_First_Name__c != Null){
                    newContact.FirstName =  newContact.Hidden_First_Name__c;
                    newContact.Hidden_First_Name__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_Last_Name__c != Null){
                    newContact.LastName  =  newContact.Hidden_Last_Name__c;
                    newContact.Hidden_Last_Name__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_Phone__c != Null){
                    newContact.Phone =   newContact.Hidden_Phone__c; 
                    newContact.Hidden_Phone__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_Email__c != Null){
                    newContact.Email  =   newContact.Hidden_Email__c;
                    newContact.Hidden_Email__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                } 
                if(newContact.Hidden_Street__c != Null){
                    newContact.MailingStreet =   newContact.Hidden_Street__c; 
                    newContact.Hidden_Street__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_city__c != Null){
                    newContact.MailingCity =   newContact.Hidden_city__c;
                    newContact.Hidden_city__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_State__c != Null){
                    newContact.MailingState =   newContact.Hidden_State__c; 
                    newContact.Hidden_State__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_Country__c != Null){
                    newContact.MailingCountry =   newContact.Hidden_Country__c;
                    newContact.Hidden_Country__c  = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                if(newContact.Hidden_Zip_Code__c != Null){
                    newContact.MailingPostalCode =   newContact.Hidden_Zip_Code__c; 
                    newContact.Hidden_Zip_Code__c = Null;
                    newContact.IsContactInfoUpdated__c = false;
                    
                }
                else{
                    wishChildIdSet.add(newContact.Id);
                    newContact.IsContactInfoUpdated__c = false;
                }
                
            }
            
            
            
            
            if(newContact.RecordTypeId == wichChildRecordTypeId && newContact.IsRejected_Contact_Info__c == true || newContact.isRecall_Contact_Info__c == true){
                if(newContact.Hidden_First_Name__c != Null || newContact.Hidden_Last_Name__c != Null ||  newContact.Hidden_Phone__c != Null|| 
                   newContact.Hidden_Email__c != Null || newContact.Hidden_Street__c != Null ||  newContact.Hidden_State__c != Null || 
                   newContact.Hidden_Country__c != Null ||   newContact.Hidden_Zip_Code__c != Null ||  newContact.Hidden_city__c != Null){ 
                       
                       newContact.Hidden_First_Name__c = Null;
                       newContact.Hidden_Last_Name__c = Null;
                       newContact.Hidden_Phone__c = Null;
                       newContact.Hidden_Email__c = Null;
                       newContact.Hidden_Street__c = Null;
                       newContact.Hidden_State__c = Null;
                       newContact.Hidden_Country__c  = Null;
                       newContact.Hidden_Zip_Code__c = Null;
                       newContact.Hidden_city__c = Null;
                   }
                else
                {
                    recallWishChild .add(newContact.Id);
                    newContact.IsRejected_Contact_Info__c  = false;
                    newContact.isRecall_Contact_Info__c = false;
                }
            }
            
        }
        
        if(wishChildIdSet.size() > 0){
            for(npe4__Relationship__c dbRelationShip : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c FROM npe4__Relationship__c WHERE npe4__Contact__c IN: wishChildIdSet AND npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId]){
                wishFamliySet.add(dbRelationShip.npe4__RelatedContact__c);  
                system.debug('@@@@@@@@@@@@@@ dbRelationShip  @@@@@@@@@@@@@@@'+dbRelationShip);                    
            }
            
            for(Contact dbWishFamily : [SELECT Id,Name,FirstName,LastName,Phone,Email,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Hidden_First_Name__c,
                                        Hidden_Last_Name__c,Hidden_Street__c,Hidden_Phone__c ,Hidden_Email__c,Hidden_city__c,Hidden_State__c,Hidden_Country__c,Hidden_Zip_Code__c  From Contact WHERE Id IN: wishFamliySet]){
                                            
                                            if(dbWishFamily.Hidden_First_Name__c != Null){
                                                dbWishFamily .FirstName =  dbWishFamily.Hidden_First_Name__c;
                                                dbWishFamily.Hidden_First_Name__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_Last_Name__c != Null){
                                                dbWishFamily.LastName  =  dbWishFamily.Hidden_Last_Name__c;
                                                dbWishFamily.Hidden_Last_Name__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_Phone__c != Null){
                                                dbWishFamily.Phone =   dbWishFamily.Hidden_Phone__c; 
                                                dbWishFamily.Hidden_Phone__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_Email__c != Null){
                                                dbWishFamily.Email  =   dbWishFamily.Hidden_Email__c;
                                                dbWishFamily.Hidden_Email__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_Street__c != Null){
                                                dbWishFamily.MailingStreet =   dbWishFamily.Hidden_Street__c; 
                                                dbWishFamily.Hidden_Street__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_city__c != Null){
                                                dbWishFamily.MailingCity =   dbWishFamily.Hidden_city__c;
                                                dbWishFamily.Hidden_city__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_State__c != Null){
                                                dbWishFamily.MailingState =   dbWishFamily.Hidden_State__c; 
                                                dbWishFamily.Hidden_State__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_Country__c != Null){
                                                dbWishFamily.MailingCountry =   dbWishFamily.Hidden_Country__c;
                                                dbWishFamily.Hidden_Country__c  = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                            if(dbWishFamily.Hidden_Zip_Code__c != Null){
                                                dbWishFamily.MailingPostalCode =   dbWishFamily.Hidden_Zip_Code__c; 
                                                dbWishFamily.Hidden_Zip_Code__c = Null;
                                                wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                            }
                                        }
            
            if(wishFamilyMap.size() > 0)
                update wishFamilyMap.Values();
        }
        
        
        if(recallWishChild.size() > 0){
            for(npe4__Relationship__c dbRelationShip : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c FROM npe4__Relationship__c WHERE npe4__Contact__c IN: recallWishChild AND npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId]){
                
                wishFamliySet.add(dbRelationShip.npe4__RelatedContact__c);  
                
            }
            for(Contact dbWishFamily : [SELECT Id,Name,FirstName,LastName,Phone,Email,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Hidden_First_Name__c,
                                        Hidden_Last_Name__c,Hidden_Street__c,Hidden_Phone__c ,Hidden_Email__c ,Hidden_city__c ,Hidden_State__c,Hidden_Country__c,Hidden_Zip_Code__c  From Contact WHERE Id IN: wishFamliySet]){
                                            if(dbWishFamily.Hidden_First_Name__c != Null || dbWishFamily .Hidden_Last_Name__c != Null ||  dbWishFamily.Hidden_Phone__c != Null|| 
                                               dbWishFamily.Hidden_Email__c != Null || dbWishFamily .Hidden_Street__c != Null ||  dbWishFamily.Hidden_State__c != Null || 
                                               dbWishFamily.Hidden_Country__c != Null ||   dbWishFamily .Hidden_Zip_Code__c != Null ||  dbWishFamily.Hidden_city__c != Null){ 
                                                   
                                                   dbWishFamily.Hidden_First_Name__c = Null;
                                                   dbWishFamily.Hidden_Last_Name__c = Null;
                                                   dbWishFamily.Hidden_Phone__c = Null;
                                                   dbWishFamily.Hidden_Email__c = Null;
                                                   dbWishFamily.Hidden_Street__c = Null;
                                                   dbWishFamily.Hidden_State__c = Null;
                                                   dbWishFamily.Hidden_Country__c  = Null;
                                                   dbWishFamily.Hidden_Zip_Code__c = Null;
                                                   dbWishFamily.Hidden_city__c = Null;
                                                   wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                                                   
                                               }
                                            
                                        }
            
            if(wishFamilyMap.size() > 0)
                update wishFamilyMap.Values();
            
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
} */ 
    
    // Affiliation Status update whenever Application status is changed.
    // creating task for volunteer manager whenever zipcode has been changed.
    // Whenever volunteer role has been changed on volunteer role field, volunteer rold record has created/deleted based on that.
    // This after update trigger is used to update the wish child contact's recipient name and email if it is changed in related contact
    if(Trigger.isAfter && Trigger.isupdate){
        system.debug('************ Inside after update');
        set<Id> volunteercontactSet = new Set<Id>();
        Map<Id,Contact> volunteerContactMap = new Map<Id,Contact>();
        Set<Id> rejectedApplicationIds = new Set<Id>();
        list<Contact> updateEmailContact = new list<Contact>();
        Set<String> zipCodesSet = new Set<String>();
        Map<Id,Contact> contactMap = new Map<Id, Contact>();
        set<string> contactIdsForEmailChange = new set<string>();
        map<string,contact> m1 = new map<string,contact>();
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
            if(newContact.Email != Null && trigger.oldMap.get(newContact.id).Email != newContact.Email && trigger.oldMap.get(newContact.id).Email != Null){
                
                contactIdsForEmailChange.add(newContact.id);
                string temp,fname,lname;
                fname= trigger.oldMap.get(newContact.id).Firstname != null ? trigger.oldMap.get(newContact.id).Firstname :'';
                temp= fname+' '+trigger.oldMap.get(newContact.id).lastname+'-'+trigger.oldMap.get(newContact.id).email;
                m1.put(temp,newContact);                       
                
            }
            
        }
        if(contactIdsForEmailChange.size()>0){
            system.debug('************ contactIdsForEmailChange size' + contactIdsForEmailChange.size());
            string temp;
            string temp1;
            for(npe4__Relationship__c newRelationShip : [SELECT ID,Name,Wish_Family_participants__c,npe4__RelatedContact__c,npe4__RelatedContact__r.LastName,npe4__RelatedContact__r.FirstName,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Contact__c,
                                                         npe4__Contact__r.Recipient_Email__c,npe4__Contact__r.Second_Recipient_Email__c,npe4__Contact__r.First_Recipient_Name__c,
                                                         npe4__Contact__r.Second_Recipient_Name__c FROM npe4__Relationship__c WHERE Wish_Family_participants__c =: 'Parent/Guardian'
                                                         AND npe4__RelatedContact__c IN:contactIdsForEmailChange]){
                                                             
                                                             
                                                             
                                                             temp = newRelationShip.npe4__Contact__r.First_Recipient_Name__c+'-'+newRelationShip.npe4__Contact__r.Recipient_Email__c;
                                                             temp1 = newRelationShip.npe4__Contact__r.Second_Recipient_Name__c+'-'+newRelationShip.npe4__Contact__r.Second_Recipient_Email__c;
                                                             if(m1.containsKey(temp)){
                                                                 contact con = new contact();
                                                                 con.id = newRelationShip.npe4__Contact__c;
                                                                 con.Recipient_Email__c = m1.get(temp).Email;
                                                                 //con.First_Recipient_Name__c = m1.get(temp).Name;
                                                                 updateEmailContact.add(con);
                                                             }
                                                             else if(m1.containsKey(temp1)){
                                                                 
                                                                 contact con = new contact();
                                                                 con.id = newRelationShip.npe4__Contact__c;
                                                                 con.second_Recipient_Email__c = m1.get(temp1).Email;
                                                                // con.Second_Recipient_Name__c = m1.get(temp1).Name;
                                                                 updateEmailContact.add(con);
                                                             }
                                                             
                                                         }
        }
        if(updateEmailContact.size()>0){
            Update updateEmailContact;
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