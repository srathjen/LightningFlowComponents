/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 21/09/2016
Description : RelationshipsViewer_AC is used when the volunteer update the wish child or wish family demographic information then
wish contact are send to approval process once the volunteer manager approve the changes submitted by the volunteer
then these updated values are reflected in the record.
*****************************************************************************************************/




public class RelationshipsViewer_AC{
    public Id caseId {get;set;}
    Public Case parentWish{get;set;}
    public list<Contact> contactList {get;set;}
    Public list<Contact>wishChildContactList{get;set;}
    Public List<Contact> dbRelatedContactList{get;set;} 
    Public List<npe4__Relationship__c > dbRelationshipList {get;set;}
    public List<Contact> clonedFamilyContactList {get;set;}
    string contactId;
    public List<String> options {get;set;}
    Public boolean outPutMode{get;set;}
    Public boolean inputMode{get;set;}
    public boolean isSave{get;set;}
    public boolean isWishFamily{get;set;}
    
    public RelationshipsViewer_AC(){
        outPutMode = true;
        Constant_AC  constant = new Constant_AC();
        Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        caseId = Apexpages.currentPage().getParameters().get('recId');
        if(caseId != Null){
            contactList = new List<Contact>();
            dbRelationshipList = new List<npe4__Relationship__c>();
            parentWish = new Case();
            parentWish = [SELECT ID,ContactId,OwnerId FROM Case WHERE ID = : caseId];
            if(parentWish.Id != Null ) {
                
                contactList = [SELECT ID,Old_Update_Contact_Values__c,FirstName,LastName,Name,MailingCity,MailingStreet,MailingState,MailingCountry,MailingPostalCode,Phone,Email FROM Contact WHERE ID = : parentWish.ContactId];
                
                
                dbRelationshipList  = [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__Type__c, npe4__RelatedContact__r.RecordTypeId,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.FirstName,npe4__RelatedContact__r.LastName,npe4__RelatedContact__r.Phone,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.MailingCity,npe4__RelatedContact__r.MailingStreet,npe4__RelatedContact__r.MailingState,
                                       npe4__RelatedContact__r.MailingCountry,npe4__RelatedContact__r.MailingPostalCode FROM npe4__Relationship__c WHERE npe4__Contact__c =: contactList[0].Id AND npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId ];
                
                if(dbRelationshipList.size() > 0){
                    isWishFamily = true;
                    
                    dbRelatedContactList = new List<Contact>();
                    for(npe4__Relationship__c  dbRelatedWishFamily : dbRelationshipList){
                        
                        Contact relatedFamilyCon = new Contact();
                        relatedFamilyCon.FirstName = dbRelatedWishFamily.npe4__RelatedContact__r.FirstName;
                        relatedFamilyCon.LastName=  dbRelatedWishFamily.npe4__RelatedContact__r.LastName;
                        relatedFamilyCon.Phone = dbRelatedWishFamily.npe4__RelatedContact__r.Phone;
                        relatedFamilyCon.Email = dbRelatedWishFamily.npe4__RelatedContact__r.Email;
                        relatedFamilyCon.MailingStreet = dbRelatedWishFamily.npe4__RelatedContact__r.MailingStreet;
                        relatedFamilyCon.MailingCity= dbRelatedWishFamily.npe4__RelatedContact__r.MailingCity;
                        relatedFamilyCon.MailingState = dbRelatedWishFamily.npe4__RelatedContact__r.MailingState;
                        relatedFamilyCon.MailingCountry= dbRelatedWishFamily.npe4__RelatedContact__r.MailingCountry;
                        relatedFamilyCon.MailingPostalCode = dbRelatedWishFamily.npe4__RelatedContact__r.MailingPostalCode;
                        relatedFamilyCon.Id = dbRelatedWishFamily.npe4__RelatedContact__c;
                        dbRelatedContactList.add(relatedFamilyCon);
                        
                    }
                    
                    
                }
            }
            
        }
        
        else{
            
        }
        
    }
    
    
    
    public void UpdateContactInfo(){
        Constant_AC  constant = new Constant_AC();
        outPutMode = false;
        inputMode = true;
        isSave = true;
        
        wishChildContactList = new List<Contact>();
        wishChildContactList = contactList.deepClone(true,false,false);
        
        if(dbRelatedContactList != Null  && dbRelatedContactList.size() > 0  ){
            
            isWishFamily = true;
            
            clonedFamilyContactList = new List<Contact>();
            clonedFamilyContactList = dbRelatedContactList.deepClone(true,false,false);
            
        }
        
    }
    
    
    public List<SelectOption> getStates(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.State_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Please select state')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }  
    
    public pageReference SaveUpdatedContact(){
        outPutMode = true;
        inputMode = false;
        String newPhone;
        String oldPhone;
        String newEmail;
        String oldEmail;
        String newCity;
        String oldCity;
        String newStreet;
        String oldStreet;
        String newState;
        String oldState;
        String newCountry;
        String oldCountry;
        String newPostalCode;
        String oldPostalCode;
        string contactInfo = 'Following contact information(s) have been updated by the volunteer :' + '<Br/>';
        
        Map<Id,Contact> updateContactMap = new Map<Id,Contact>();
        List<Task> demogarphicTaskList = new List<Task>();
        isSave = false;
        
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: parentWish.ContactId];
        if(piwi.size() > 0){
            Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
            req1.setAction('Removed');        
            req1.setWorkitemId(piwi.get(0).Id);
            Approval.process(req1,false);
        }
        
        
        for(Contact oldwishChildCon : wishChildContactList){
            
            for(Contact newWishChildCon : contactList){

                
                if(oldwishChildCon.Id == newWishChildCon.Id){
                    
                    if((oldwishChildCon.Phone != newWishChildCon.Phone) || (oldwishChildCon.Email != newWishChildCon.Email) || (oldwishChildCon.MailingStreet !=newWishChildCon.MailingStreet) ||
                       (oldwishChildCon.MailingCity != newWishChildCon.MailingCity) ||  (oldwishChildCon.MailingState!= newWishChildCon.MailingState)  || (oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry) ||
                       (oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode)){
                        system.debug('@@@@@@@ oldWishChildCon @@@@@@@@@'+oldwishChildCon);
                    
                    contactInfo  =  contactInfo +'<Br/>' + 'Name :'+' '+ '  '+oldwishChildCon.Name+ '  '+' ; '+'<Br/><Br/>';
                    if(newWishChildCon.Phone != Null && oldwishChildCon.Phone != newWishChildCon.Phone){
                        newWishChildCon .Hidden_Phone__c  = oldwishChildCon.Phone;
                        
                        if(newWishChildCon.Phone != Null)
                            oldPhone = newWishChildCon.Phone;
                        if(newWishChildCon .Hidden_Phone__c != Null)
                            newPhone = newWishChildCon .Hidden_Phone__c;
                        if(newWishChildCon.Phone != Null && newWishChildCon.Hidden_Phone__c != Null)
                            contactInfo += '<Br/>' +'Old Phone Value :'+ ' '+oldphone +'<Br/>' +' New Phone Value :' +' '+newPhone + '; ' + '<Br/>';
                        else{
                            if((!String.isBlank(newPhone )) && String.isBlank(oldphone))
                                contactInfo += '<Br/>'+'New Phone Value :'+' '+ newPhone + '; '+'<Br/>';
                        }
                    }
                        updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                     
                       }
                    if(oldwishChildCon.Email != newWishChildCon.Email){
                        newWishChildCon .Hidden_Email__c = oldwishChildCon.Email;
                        
                        
                        if(newWishChildCon.Email != Null)
                            oldEmail = newWishChildCon.Email;
                        if(newWishChildCon .Hidden_Email__c != Null)
                            newEmail = newWishChildCon .Hidden_Email__c;
                        if(newWishChildCon.Email != Null && newWishChildCon .Hidden_Email__c != Null)
                            contactInfo += '<Br/>'+ 'Old Email Value:'+ ' '+ oldEmail +'<Br/>' +' New Email Value:' + ' '+ newEmail+ '; '+'<Br/>';
                        else{
                            if((!String.isBlank(newEmail)) && String.isBlank(oldEmail))
                                contactInfo  += '<Br/>' +'New Phone Value :' +' '+ newEmail+';' + '<Br/>';
                        }
                        updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                    } 
                    if(oldwishChildCon.MailingStreet != newWishChildCon.MailingStreet){
                        newWishChildCon .Hidden_Street__c = oldwishChildCon.MailingStreet;
                        if(newWishChildCon.MailingStreet != Null)
                            oldStreet = newWishChildCon.MailingStreet;
                        if(newWishChildCon .Hidden_Street__c != Null)
                            newStreet = newWishChildCon .Hidden_Street__c;
                        if(newWishChildCon.MailingStreet != Null && newWishChildCon .Hidden_Street__c != Null)
                            contactInfo  +='<Br/>'+ 'Old Street Value:'+ ' '+ oldStreet +'<Br/>'+' New Street Value:' + ' '+ newStreet + '; ' + '<Br/>';
                        else{
                            if((!String.isBlank(newStreet)) && String.isBlank(oldStreet))
                                contactInfo  += '<Br/>'+'New Street Value:'+' '+ newStreet+';' + '<Br/>';
                        }
                        updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                    } 
                    if(oldwishChildCon.MailingCity != newWishChildCon.MailingCity){
                        newWishChildCon .Hidden_city__c = oldwishChildCon.MailingCity;
                        if(newWishChildCon.MailingCity != Null)
                            oldCity = newWishChildCon.MailingCity;
                        if(newWishChildCon .Hidden_city__c != Null)
                            newCity =newWishChildCon .Hidden_city__c;
                        if(newWishChildCon.MailingCity != Null && newWishChildCon .Hidden_city__c != Null)
                            contactInfo  += '<Br/>'+ 'Old City Value:'+' '+oldCity +'<Br/>' + 'New City Value:'+ ' '+newCity + '; ' + '<Br/>';
                        else{
                            if((!String.isBlank(newCity)) && String.isBlank(oldCity)){
                                contactInfo  += '<Br/>'+'New City Value:'+' '+ newCity+';' + '<Br/>';
                            }
                        }
                        updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                    }  
                    if(oldwishChildCon.MailingState!= newWishChildCon.MailingState){
                        newWishChildCon .Hidden_State__c = oldwishChildCon.MailingState;
                        if(newWishChildCon.MailingState != Null)
                            oldState = newWishChildCon.MailingState;
                        if(newWishChildCon .Hidden_State__c != Null)
                            newState = newWishChildCon .Hidden_State__c;
                        if(newWishChildCon .Hidden_State__c != Null )
                            contactInfo += '<Br/>' + 'Old State Value:'+' '+oldState +'<Br/>'+' New State Value:' +' '+'  '+newState + '; ' + '<Br/>';
                        else{
                            if((!String.isBlank(newState)) &&  String.isBlank(oldState))
                                contactInfo += '<Br/>'+'New State Value:'+' '+'  '+newState+';' + '<Br/>';
                        }
                    }   
                    if(oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry){
                        newWishChildCon .Hidden_Country__c = oldwishChildCon.MailingCountry;
                        if(newWishChildCon.MailingCountry != Null)
                            oldCountry = newWishChildCon.MailingCountry;
                        if(newWishChildCon .Hidden_Country__c != Null)
                            newCountry = newWishChildCon .Hidden_Country__c; 
                        if(newWishChildCon.MailingCountry != Null)
                            contactInfo  += '<Br/>' + 'Old Country Value:'+' '+'  '+oldCountry +'<Br/>'+' New Country Value:' +' '+ '  '+ newCountry + '; '+'<Br/>';
                        else{
                            
                            if((!String.isBlank(newCountry )) && String.isBlank(oldCountry))
                                contactInfo  += '<Br/>' + 'New Country Value:'+' '+ '  '+newCountry +';'+'<Br/>';
                        }
                        
                        updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                        
                    }   
                    if(oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode){
                        newWishChildCon .Hidden_Zip_Code__c  = oldwishChildCon.MailingPostalCode; 
                        
                        if(newWishChildCon.MailingPostalCode != Null)
                            oldPostalCode =  newWishChildCon.MailingPostalCode;
                        if(newWishChildCon .Hidden_Zip_Code__c != Null)
                            newPostalCode = newWishChildCon .Hidden_Zip_Code__c ;
                        if(newWishChildCon.MailingPostalCode != Null)
                            contactInfo  += '<Br/>'+ 'Old Zip Code Value:'+' '+ '  '+oldPostalCode +'<Br/>'+' New Zip Code Value:' +' '+'  '+newPostalCode + '; '+'<Br/>';
                        else{
                            if((!String.isBlank(newPostalCode )) && String.isBlank(oldPostalCode))
                                contactInfo += '<Br/>' +' New Zip Code Value:'+' '+newPostalCode +';'+'<Br/>';
                        }
                        updateContactMap.put(newWishChildCon.Id,newWishChildCon);  
                    }
                }
                
            }
            
        }
        if(dbRelatedContactList != Null && dbRelatedContactList.size() > 0){
            for(Contact oldwishChildCon : clonedFamilyContactList){
                
                for(Contact newWishChildCon : dbRelatedContactList ){
                    
                    if(oldwishChildCon.Id == newWishChildCon.Id){
                        
                        if((oldwishChildCon.Phone != newWishChildCon.Phone && oldwishChildCon.Phone !=''  ) || (oldwishChildCon.Email != newWishChildCon.Email && oldwishChildCon.Email != '') || (oldwishChildCon.MailingStreet != newWishChildCon.MailingStreet && oldwishChildCon.MailingStreet != '') ||
                          (oldwishChildCon.MailingCity != newWishChildCon.MailingCity && oldwishChildCon.MailingCity != '' ) ||  (oldwishChildCon.MailingState!= newWishChildCon.MailingState && oldwishChildCon.MailingState !='')  || (oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry && oldwishChildCon.MailingCountry!= '') ||
                          (oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode && oldwishChildCon.MailingPostalCode != ''))
                        {
                            System.debug('@@@@@@@@@@@@Old'+oldwishChildCon.MailingCity+'@@@@@@New'+newWishChildCon.MailingCity);
                            contactInfo  += '<Br/>' + 'Name :'+' '+'  '+newWishChildCon.FirstName+'  '+'  '+newWishChildCon.LastName+'  '+' ; '+'<Br/>';
                        
                        if(oldwishChildCon.Phone != newWishChildCon.Phone){
                            newWishChildCon .Hidden_Phone__c  = oldwishChildCon.Phone;
                            
                            if(newWishChildCon.Phone != Null)
                                oldPhone = newWishChildCon.Phone;
                            if(newWishChildCon .Hidden_Phone__c != Null)
                                newPhone = newWishChildCon .Hidden_Phone__c;
                            if(newWishChildCon.Phone != Null && oldphone != Null)
                                contactInfo  += '<Br/>'+ 'Old phone Value :'+' '+'  '+ oldphone +'<Br/>' +' New Phone Value :' + ' '+  '  '+newPhone + '; '+'<Br/>';
                            else{
                                if((!String.isBlank(newPhone)) && String.isBlank(oldphone))
                                    contactInfo  += '<Br/>'+'New Phone Value :' + '  '+ '  '+ newPhone + '; '+'<Br/>';
                            }
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                        } 
                        if(oldwishChildCon.Email != newWishChildCon.Email){
                            newWishChildCon .Hidden_Email__c = oldwishChildCon.Email;
                            
                            
                            if(newWishChildCon.Email != Null)
                                oldEmail = newWishChildCon.Email;
                            if(newWishChildCon .Hidden_Email__c != Null)
                                newEmail = newWishChildCon .Hidden_Email__c;
                            if(newWishChildCon.Email != Null && newWishChildCon .Hidden_Email__c != Null)
                                contactInfo  += '<Br/>'  + 'Old Email Value:'+ ' '+oldEmail +' ' +'<Br/>' +' New Email Value:' + '  '+ '  '+ newEmail+ '; '+'<Br/>';
                            else{
                                if((!String.isBlank(newEmail)) && String.isBlank(oldEmail))
                                    contactInfo += '<Br/>'+'New Email Value :' + '  '+ '  '+newEmail+';'+'<Br/>';
                            }
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                        } 
                        if(oldwishChildCon.MailingStreet !=newWishChildCon.MailingStreet){
                            newWishChildCon .Hidden_Street__c = oldwishChildCon.MailingStreet;
                            if(newWishChildCon.MailingStreet != Null)
                                oldStreet = newWishChildCon.MailingStreet;
                            if(newWishChildCon .Hidden_Street__c != Null)
                                newStreet = newWishChildCon .Hidden_Street__c;
                            if(newWishChildCon.MailingStreet != Null && newWishChildCon .Hidden_Street__c != Null)
                                contactInfo += '<Br/>' + 'Old Street Value:'+  ' '+ '  '+oldStreet +' ' +'<Br/>' +' New Street Value:' + ' '+ '  '+ newStreet + '; '+'<Br/>';
                            else{
                                if((!String.isBlank(newStreet)) && String.isBlank(oldStreet))
                                    contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>';
                            }
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                        } 
                        if(oldwishChildCon.MailingCity != newWishChildCon.MailingCity){
                            newWishChildCon .Hidden_city__c = oldwishChildCon.MailingCity;
                            if(newWishChildCon.MailingCity != Null)
                                oldCity = newWishChildCon.MailingCity;
                            if(newWishChildCon .Hidden_city__c != Null)
                                newCity =newWishChildCon .Hidden_city__c;
                            if(newWishChildCon.MailingCity != Null && oldCity  != Null)
                                contactInfo  += '<Br/>'+ 'Old City Value:'+ ' '+ '  '+ oldCity +'<Br/>' + 'New City Value:' +' '+'  '+newCity + '; '+'<Br/>';
                            else{
                                if((!String.isBlank(newCity))  && String.isBlank(oldCity)){
                                    contactInfo  += '<Br/>' +'New City Value:'+ '  '+ '  '+newCity+';'+'<Br/>';
                                }
                            }
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                        }  
                        if(oldwishChildCon.MailingState!= newWishChildCon.MailingState){
                            newWishChildCon .Hidden_State__c = oldwishChildCon.MailingState;
                            if(newWishChildCon.MailingState != Null)
                                oldState = newWishChildCon.MailingState;
                            if(newWishChildCon .Hidden_State__c != Null)
                                newState = newWishChildCon .Hidden_State__c;
                            if(newWishChildCon .Hidden_State__c != Null && newWishChildCon.MailingState != Null)
                                contactInfo += '<Br/>'+'Old State Value:'+' '+'  '+ oldState +'<Br/>' +' New State Value:' +' '+ '  '+ newState + '; '+'<Br/>';
                            else{
                                if((!String.isBlank(newState)) && String.isBlank(oldState ))
                                    contactInfo  +='<Br/>' +'New State Value:'+newState+';'+'<Br/>';
                            }
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                        }   
                        if(oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry){
                            newWishChildCon .Hidden_Country__c = oldwishChildCon.MailingCountry;
                            if(newWishChildCon.MailingCountry != Null)
                                oldCountry = newWishChildCon.MailingCountry;
                            if(newWishChildCon .Hidden_Country__c != Null)
                                newCountry = newWishChildCon .Hidden_Country__c; 
                            if(newWishChildCon.MailingCountry != Null && newWishChildCon .Hidden_Country__c != Null)
                                contactInfo  += '<Br/>'+ 'Old Country Value:'+' ' + '  '+oldCountry +'<Br/>' +' New Country Value:' +' '+ '  '+ newCountry + '; '+'<Br/>';
                            else{
                                
                                if((!String.isBlank(newCountry )) && String.isBlank(oldCountry))
                                    contactInfo  += '<Br/>'+ 'New Country Value:'+newCountry +';'+'<Br/>';
                            }
                            
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            
                        }   
                        if(oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode){
                            newWishChildCon .Hidden_Zip_Code__c  = oldwishChildCon.MailingPostalCode; 
                            
                            if(newWishChildCon.MailingPostalCode != Null)
                                oldPostalCode =  newWishChildCon.MailingPostalCode;
                            if(newWishChildCon .Hidden_Zip_Code__c != Null)
                                newPostalCode = newWishChildCon.Hidden_Zip_Code__c ;
                            if(newWishChildCon.MailingPostalCode != Null && newWishChildCon .Hidden_Zip_Code__c != Null)
                                contactInfo  += '<Br/>'  + 'Old Zip Code Value:'+' '+ '  '+ oldPostalCode +'<Br/> '+' New Zip Code Value:'+' '+ '  '+ newPostalCode + '; '+'<Br/>';
                            else{
                                if((!String.isBlank(newPostalCode))  && String.isBlank(oldPostalCode))
                                    contactInfo += '<Br/>'+'New Zip Code Value:'+ '  '+ '  '+newPostalCode +';'+'<Br/>';
                            }
                            updateContactMap.put(newWishChildCon.Id,newWishChildCon);  
                        }
                    }
                    }
                    
                }
            }
            
        }
        
        if(updateContactMap.size() > 0){
            update updateContactMap.Values();
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setComments(contactInfo);
            req.setObjectId(parentWish.ContactId);
            req.setProcessDefinitionNameOrId('Update_Contact_Info_Process');
            req.setSkipEntryCriteria(true);
            req.setNextApproverIds(new Id[]{parentWish.OwnerId});
            Approval.ProcessResult result = Approval.process(req);
            
            Task newTask = new Task();
            newTask.WhatId = parentWish.Id;
            newTask.OwnerId = parentWish.OwnerId;
            newTask.ActivityDate = System.today() + 1;
            newTask.Subject = 'Review contact information updated by the volunteer';
            demogarphicTaskList.add(newTask);
            
            
            Task newContactTask = new Task();
            newContactTask.WhoId = parentWish.ContactId;
            newContactTask.OwnerId = parentWish.OwnerId;
            newContactTask.ActivityDate = System.today() + 1;
            newContactTask .Subject = 'Review contact information updated by the volunteer';
            demogarphicTaskList.add(newContactTask );
            
            insert   demogarphicTaskList;     
            
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Thank you for updating the contact information! Your changes have been recorded and sent to the Chapter Staff for approval.'));
        if(contactList.size()>0){
            contactList[0].Old_Update_Contact_Values__c = contactInfo;
            update contactList;
        }
        
        return null;     
    }
    
    
    
    
    public void close(){
        outPutMode = true;
        inputMode = false;
    }
}