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
    Public Id WishChildId{get;set;}
    Public Case parentWish{get;set;}
    public list<Contact> contactList {get;set;}
    Public list<Contact>wishChildContactList{get;set;}
    Public List<Contact> dbRelatedContactList{get;set;} 
    Public List<npe4__Relationship__c > dbRelationshipList {get;set;}
    public List<Contact> clonedFamilyContactList {get;set;}
    public Map<Id,npe4__Relationship__c> preferredConMap{get;set;}
    public Map<Id,npe4__Relationship__c> preferredConMapClone{get;set;}
    public Map<Id,npe4__Relationship__c> oldPrfConRelMap = new Map<Id,npe4__Relationship__c>();
    string contactId;
    Public boolean outPutMode{get;set;}
    Public boolean inputMode{get;set;}
    public boolean isSave{get;set;}
    public boolean isWishFamily{get;set;}
    public boolean isMessage; 
    public boolean isChildSuccessMessage; 
    public List<contact> originalWishChildList{get;set;}
     
    /***************************************************************************************
     This is the constructor method it will call when ever the page is loaded. 
     it query the wish child contact and related contact to the corresponding parent case.
     ***************************************************************************************/
    public RelationshipsViewer_AC(){
        outPutMode = true;
        Constant_AC  constant = new Constant_AC();
        Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        caseId = Apexpages.currentPage().getParameters().get('recId');
        if(caseId != Null){
            contactList = new List<Contact>();
            dbRelationshipList = new List<npe4__Relationship__c>();
            preferredConMap = new Map<Id,npe4__Relationship__c>();
            parentWish = new Case();
            parentWish = [SELECT ID,ContactId,OwnerId FROM Case WHERE ID = : caseId];
            WishChildId = parentWish.ContactId;
            if(parentWish.Id != Null ) {
                contactList = [SELECT ID,Old_Update_Contact_Values__c,FirstName,LastName,Name,MailingCity,MailingStreet,MailingState,MailingCountry,MailingPostalCode,Phone,Homephone,OtherPhone,MobilePhone,Email,Hidden_Preferred_Contact_Rel_Id__c,Hidden_Current_Pref_Con_Rel_Id__c,npsp__Deceased__c FROM Contact WHERE ID = : parentWish.ContactId Limit 1];
                
                dbRelationshipList  = [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__Type__c,Hidden_Preferred_Contact__c, npe4__RelatedContact__r.RecordTypeId,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.FirstName,npe4__RelatedContact__r.LastName,npe4__RelatedContact__r.Phone,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.MailingCity,npe4__RelatedContact__r.MailingStreet,npe4__RelatedContact__r.MailingState,Decead__c,npe4__RelatedContact__r.HomePhone,
                                       npe4__RelatedContact__r.MailingCountry,npe4__RelatedContact__r.OtherPhone,npe4__RelatedContact__r.MobilePhone,npe4__RelatedContact__r.npe01__PreferredPhone__c,npe4__RelatedContact__r.npe01__WorkPhone__c,npe4__RelatedContact__r.MailingPostalCode,npe4__RelatedContact__r.Use_as_Household_Address__c,npe4__RelatedContact__r.Same_as_Household_Address__c,npe4__RelatedContact__r.Hidden_Current_Pref_Con_Rel_Id__c FROM npe4__Relationship__c WHERE 
                                       npe4__Contact__c =: contactList[0].Id AND npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId Limit 10];
                                       
                
                if(contactList.size() > 0)
                {
                    originalWishChildList = new List<Contact>();
                    for(contact con : contactList){
                        Contact childContact = new Contact();
                        childContact.FirstName = con.FirstName;
                        childContact.LastName=  con.LastName;
                        childContact.HomePhone =con.HomePhone;
                        childContact.Email = con.Email;
                        childContact.MailingStreet = con.MailingStreet;
                        childContact.MailingCity= con.MailingCity;
                        childContact.MailingState = con.MailingState;
                        childContact.MailingCountry= con.MailingCountry;
                        childContact.MailingPostalCode = con.MailingPostalCode;
                        childContact.OtherPhone = con.OtherPhone;
                        childContact.MobilePhone = con.MobilePhone;
                        childContact.Hidden_Current_Pref_Con_Rel_Id__c  = con.Hidden_Current_Pref_Con_Rel_Id__c;
                        childContact.npsp__Deceased__c = con.npsp__Deceased__c;
                        childContact.Id = con.id;
                        originalWishChildList.add(childContact);
                    }
                }      
                if(dbRelationshipList.size() > 0){
                    isWishFamily = true;
                    dbRelatedContactList = new List<Contact>();
                    for(npe4__Relationship__c  dbRelatedWishFamily : dbRelationshipList){
                        Contact relatedFamilyCon = new Contact();
                        preferredConMap.put(dbRelatedWishFamily.npe4__RelatedContact__c,dbRelatedWishFamily);
                        oldPrfConRelMap.put(dbRelatedWishFamily.Id,dbRelatedWishFamily);
                        relatedFamilyCon.FirstName = dbRelatedWishFamily.npe4__RelatedContact__r.FirstName;
                        relatedFamilyCon.LastName=  dbRelatedWishFamily.npe4__RelatedContact__r.LastName;
                        relatedFamilyCon.HomePhone = dbRelatedWishFamily.npe4__RelatedContact__r.HomePhone;
                        relatedFamilyCon.Email = dbRelatedWishFamily.npe4__RelatedContact__r.Email;
                        relatedFamilyCon.MailingStreet = dbRelatedWishFamily.npe4__RelatedContact__r.MailingStreet;
                        relatedFamilyCon.MailingCity= dbRelatedWishFamily.npe4__RelatedContact__r.MailingCity;
                        relatedFamilyCon.MailingState = dbRelatedWishFamily.npe4__RelatedContact__r.MailingState;
                        relatedFamilyCon.MailingCountry= dbRelatedWishFamily.npe4__RelatedContact__r.MailingCountry;
                        relatedFamilyCon.MailingPostalCode = dbRelatedWishFamily.npe4__RelatedContact__r.MailingPostalCode;
                        relatedFamilyCon.Id = dbRelatedWishFamily.npe4__RelatedContact__c;
                        relatedFamilyCon.Wish_Family_Type__c = dbRelatedWishFamily.npe4__Type__c;
                        relatedFamilyCon.Use_as_Household_Address__c  = dbRelatedWishFamily.npe4__RelatedContact__r.Use_as_Household_Address__c ;
                        relatedFamilyCon.Same_as_Household_Address__c = dbRelatedWishFamily.npe4__RelatedContact__r.Same_as_Household_Address__c;
                        relatedFamilyCon.OtherPhone = dbRelatedWishFamily.npe4__RelatedContact__r.OtherPhone;
                        relatedFamilyCon.MobilePhone = dbRelatedWishFamily.npe4__RelatedContact__r.MobilePhone;
                        relatedFamilyCon.npe01__WorkPhone__c = dbRelatedWishFamily.npe4__RelatedContact__r.npe01__WorkPhone__c;
                        relatedFamilyCon.npe01__PreferredPhone__c = dbRelatedWishFamily.npe4__RelatedContact__r.npe01__PreferredPhone__c;
                        dbRelatedContactList.add(relatedFamilyCon);
                    }
                }
            }
        }
    }
    
    /******************************************************************************************
     This UpdateContactInfo() is will call when the user click the update button on the page. 
     It create a cloned list of contact for wish child and wish family contacts.
    *****************************************************************************************/
    public void UpdateContactInfo(){
        Constant_AC  constant = new Constant_AC();
        outPutMode = false;
        inputMode = true;
        isSave = true;
        preferredConMapClone = new Map<Id,npe4__Relationship__c>();    
        preferredConMapClone = preferredConMap.deepClone();    
        wishChildContactList = new List<Contact>();
        wishChildContactList = originalWishChildList.deepClone(true,false,false);
        if(dbRelatedContactList != Null  && dbRelatedContactList.size() > 0  ){
            isWishFamily = true;
            clonedFamilyContactList = new List<Contact>();
            clonedFamilyContactList = dbRelatedContactList.deepClone(true,false,false);
        }
    }
    
    /******************************************************************************************
     This getStates() is used to get the all the state values from US, and 
     user can update the state value from list of displyed state values.
    *****************************************************************************************/
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
    
    /******************************************************************************************************
     This SaveUpdatedContact() will call when the user update theri information then that updated
     information are stored in the back end fields and the wish child contact is going to approval process. 
     Once chappter staff approved this chages then the updated chages are stored into corresponding fields.
    ********************************************************************************************************/
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
        String newOtherPhone;
        String oldOtherPhone;
        String newMobilePhone;
        String oldMobilePhone;
        String newPrfRelId;
        String newPreferredCon;
        Integer noOfPrefContact;
        String newWorkPhone;
        String oldWorkPhone;
        String newPhoneType;
        String oldPhoneType;
        Boolean prefMsg = False;
        Boolean prefMsgPhone = False;
        integer i = 0;
        integer j =0;
        integer k;
        List<Contact> firstUseAsAddressList = new List<Contact>();
        List<Contact> secondUseAsAddressList = new List<Contact>();
        Constant_AC  constant = new Constant_AC();
        string contactInfo = 'Following contact information(s) have been updated by the volunteer :' + '<Br/>';
        Map<Id,Contact> updateContactMap = new Map<Id,Contact>();
        List<Task> demogarphicTaskList = new List<Task>();
        isSave = false;
        noOfPrefContact = 0;
        for(npe4__Relationship__c prefCon : preferredConMapClone.values()){
            if(prefCon.Hidden_Preferred_Contact__c){
                noOfPrefContact +=1;
                newPreferredCon = prefCon.npe4__RelatedContact__c;
                newPrfRelId = prefCon.Id;
                system.debug('newprfconId pref'+newPreferredCon);
                system.debug('newprfconId newPrfRelId'+newPrfRelId);
            }
            
        }
        
        if(noOfPrefContact >= 2){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select only one Preferred Contact.'));
            inputMode = true;
            outPutMode = false;
            isSave = true;
            return Null;
        }
        for(Contact familyCon : clonedFamilyContactList){
            if(newPreferredCon == familyCon.Id){
               if(familyCon.npe01__PreferredPhone__c == Null)
                    prefMsg = True;
                else{
                    if(familyCon.npe01__PreferredPhone__c != Null && familyCon.npe01__PreferredPhone__c == 'Home' && familyCon.HomePhone == Null)
                         prefMsgPhone = True;
                    else if(familyCon.npe01__PreferredPhone__c != Null && familyCon.npe01__PreferredPhone__c == 'Mobile' && familyCon.MobilePhone == Null)
                         prefMsgPhone = True;
                    else if(familyCon.npe01__PreferredPhone__c != Null && familyCon.npe01__PreferredPhone__c == 'Work' && familyCon.npe01__WorkPhone__c == Null)
                         prefMsgPhone = True;
                    else if(familyCon.npe01__PreferredPhone__c != Null && familyCon.npe01__PreferredPhone__c == 'Other' && familyCon.otherPhone == Null)
                         prefMsgPhone = True;
                }
            }
        }
        if(prefMsg == True){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter preferred phone for the preferred contact.'));
            inputMode = true;
            outPutMode = false;
            isSave = true;
            return Null;
        }
        if(prefMsgPhone == True){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter the phone number for the preferred contact.'));
            inputMode = true;
            outPutMode = false;
            isSave = true;
            return Null;
        }
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId,ProcessInstance.Status,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: parentWish.ContactId AND  ProcessInstance.Status =: 'Pending'];
        if(piwi.size() > 0){
            Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
            req1.setAction('Removed');        
            req1.setWorkitemId(piwi.get(0).Id);
            Approval.process(req1,false);
        }
        
        
        for(Contact oldwishChildCon : wishChildContactList){
            for(Contact newWishChildCon : originalWishChildList){
                if(oldwishChildCon.Id == newWishChildCon.Id){
                    if((oldwishChildCon.HomePhone != newWishChildCon.HomePhone) || (oldwishChildCon.Email != newWishChildCon.Email) || (oldwishChildCon.MailingStreet !=newWishChildCon.MailingStreet) ||
                       (oldwishChildCon.MailingCity != newWishChildCon.MailingCity) ||  (oldwishChildCon.MailingState!= newWishChildCon.MailingState)  || (oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry) ||
                       (oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode) || (oldwishChildCon.OtherPhone != newWishChildCon.OtherPhone) || (oldwishChildCon.MobilePhone != newWishChildCon.MobilePhone) || (newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c != newPrfRelId)){
                           contactInfo  =  contactInfo +'<Br/>' + 'Name :'+' '+ '  '+newWishChildCon.FirstName+' '+newWishChildCon.LastName+ '  '+' ; '+'<Br/><Br/>';
                           
                           system.debug('newprfconId iside loop'+newPrfRelId);
                           if( oldwishChildCon.HomePhone != newWishChildCon.HomePhone){
                               newWishChildCon .Hidden_Phone__c  = oldwishChildCon.HomePhone;
                               if(newWishChildCon.Phone != Null)
                                   oldPhone = newWishChildCon.HomePhone;
                               if(newWishChildCon.Hidden_Phone__c != Null){
                                   newPhone = newWishChildCon .Hidden_Phone__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon .Hidden_Phone__c == Null){
                                   newPhone = newWishChildCon.Hidden_Phone__c;
                                   newWishChildCon.Hidden_Phone__c = '9912121313';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.HomePhone != Null && newWishChildCon.Hidden_Phone__c != Null && newWishChildCon.Hidden_Phone__c != '9912121313')
                                   contactInfo += '<Br/>' +'Old Phone Value :'+ ' '+oldphone +'<Br/>' +' New Phone Value :' +' '+newPhone + '; ' + '<Br/>';
                               else{
                                   if((!String.isBlank(newPhone )) && String.isBlank(oldphone))
                                       contactInfo += '<Br/>'+'New Phone Value :'+' '+ newPhone + '; '+'<Br/>';
                                   if((String.isBlank(newPhone )) && (!String.isBlank(oldphone)))
                                       contactInfo += '<Br/>'+'New Phone Value :'+' '+ newPhone + '; '+'<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }
                           if( oldwishChildCon.MobilePhone != newWishChildCon.MobilePhone){
                               newWishChildCon.HiddenMobilePhone__c= oldwishChildCon.MobilePhone;
                               
                               if(newWishChildCon.MobilePhone!= Null)
                                   oldMobilePhone = newWishChildCon.MobilePhone;
                               if(newWishChildCon .HiddenMobilePhone__c!= Null){
                                   newMobilePhone= newWishChildCon.HiddenMobilePhone__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon .HiddenMobilePhone__c== Null){
                                   newMobilePhone = newWishChildCon.HiddenMobilePhone__c;
                                   newWishChildCon.HiddenMobilePhone__c = '9912121313';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.MobilePhone!= Null && newWishChildCon.HiddenMobilePhone__c!= Null && newWishChildCon.HiddenMobilePhone__c != '9912121313')
                                   contactInfo += '<Br/>' +'Old Mobile Phone Value :'+ ' '+oldMobilePhone+'<Br/>' +' New Mobile Phone Value :' +' '+newMobilePhone+ '; ' + '<Br/>';
                               else{
                                   if((!String.isBlank(newMobilePhone)) && String.isBlank(oldMobilePhone))
                                       contactInfo += '<Br/>'+'New Mobile Phone Value :'+' '+ newMobilePhone+ '; '+'<Br/>';
                                   if((String.isBlank(newMobilePhone)) && (!String.isBlank(oldMobilePhone)))
                                       contactInfo += '<Br/>'+'New Mobile Phone Value :'+' '+ newMobilePhone+ '; '+'<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }
                           if( oldwishChildCon.otherPhone != newWishChildCon.otherPhone ){
                               newWishChildCon.HiddenOtherPhone__c = oldwishChildCon.otherPhone ;
                               
                               if(newWishChildCon.otherPhone != Null)
                                   oldOtherPhone = newWishChildCon.otherPhone;
                               if(newWishChildCon .HiddenOtherPhone__c!= Null){
                                   newOtherPhone = newWishChildCon.HiddenOtherPhone__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon .HiddenOtherPhone__c == Null){
                                   newOtherPhone = newWishChildCon .HiddenOtherPhone__c;
                                   newWishChildCon.HiddenOtherPhone__c = '9912121313';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.otherPhone != Null && newWishChildCon.HiddenOtherPhone__c!= Null && newWishChildCon.HiddenOtherPhone__c != '9912121313')
                                   contactInfo += '<Br/>' +'Old Other Phone Value :'+ ' '+oldOtherPhone+'<Br/>' +' New Other Phone Value :' +' '+newOtherPhone+ '; ' + '<Br/>';
                               else{
                                   if((!String.isBlank(newOtherPhone)) && String.isBlank(oldOtherPhone))
                                       contactInfo += '<Br/>'+'New Other Phone Value :'+' '+ newOtherPhone+ '; '+'<Br/>';
                                   if((String.isBlank(newOtherPhone)) && (!String.isBlank(oldOtherPhone)))
                                       contactInfo += '<Br/>'+'New Other Phone Value :'+' '+ newOtherPhone+ '; '+'<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }
                           if(oldwishChildCon.Email != newWishChildCon.Email){
                               newWishChildCon .Hidden_Email__c = oldwishChildCon.Email;
                               if(newWishChildCon.Email != Null)
                                   oldEmail = newWishChildCon.Email;
                               if(newWishChildCon .Hidden_Email__c != Null){
                                   newEmail = newWishChildCon .Hidden_Email__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.Hidden_Email__c == Null){
                                   newEmail = newWishChildCon .Hidden_Email__c;
                                   newWishChildCon.Hidden_Email__c = 'kanagumca_jcet@hotmail.com';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.Email != Null && newWishChildCon .Hidden_Email__c != Null && newWishChildCon.Hidden_Email__c != 'kanagumca_jcet@hotmail.com')
                                   contactInfo += '<Br/>'+ 'Old Email Value:'+ ' '+ oldEmail +'<Br/>' +' New Email Value:' + ' '+ newEmail+ '; '+'<Br/>';
                               else{
                                   if((!String.isBlank(newEmail)) && String.isBlank(oldEmail))
                                       contactInfo  += '<Br/>' +'New Email Value :' +' '+ newEmail+';' + '<Br/>';
                                   if((String.isBlank(newEmail)) && (!String.isBlank(oldEmail)))
                                       contactInfo  += '<Br/>' +'New Email Value :' +' '+ newEmail+';' + '<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           } 
                           if(oldwishChildCon.MailingStreet != newWishChildCon.MailingStreet){
                               
                               newWishChildCon .Hidden_Street__c = oldwishChildCon.MailingStreet;
                               if(newWishChildCon.MailingStreet != Null)
                                   oldStreet = newWishChildCon.MailingStreet;
                               if(newWishChildCon .Hidden_Street__c != Null){
                                   newStreet = newWishChildCon .Hidden_Street__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon .Hidden_Street__c == Null){
                                   newStreet = newWishChildCon .Hidden_Street__c;
                                   newWishChildCon.Hidden_Street__c = 'kanagumca_jcet@hotmail.com';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.MailingStreet != Null && newWishChildCon .Hidden_Street__c != Null && newWishChildCon.Hidden_Street__c != 'kanagumca_jcet@hotmail.com')
                                   contactInfo  +='<Br/>'+ 'Old Street Value:'+ ' '+ oldStreet +'<Br/>'+' New Street Value:' + ' '+ newStreet + '; ' + '<Br/>';
                               else{
                                   if((!String.isBlank(newStreet)) && String.isBlank(oldStreet))
                                       contactInfo  += '<Br/>'+'New Street Value:'+' '+ newStreet+';' + '<Br/>';
                                   if((String.isBlank(newStreet)) && (!String.isBlank(oldStreet)))
                                       contactInfo  += '<Br/>'+'New Street Value:'+' '+ newStreet+';' + '<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           } 
                           if(oldwishChildCon.MailingCity != newWishChildCon.MailingCity){
                               newWishChildCon .Hidden_city__c = oldwishChildCon.MailingCity;
                               if(newWishChildCon.MailingCity != Null)
                                   oldCity = newWishChildCon.MailingCity;
                               if(newWishChildCon.Hidden_city__c != Null){
                                   newCity =newWishChildCon .Hidden_city__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.Hidden_city__c == Null){
                                   newCity =newWishChildCon.Hidden_city__c;
                                   newWishChildCon.Hidden_city__c = 'kanagumca_jcet@hotmail.com';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.MailingCity != Null && newWishChildCon .Hidden_city__c != Null && newWishChildCon.Hidden_city__c != 'kanagumca_jcet@hotmail.com')
                                   contactInfo  += '<Br/>'+ 'Old City Value:'+' '+oldCity +'<Br/>' + 'New City Value:'+ ' '+newCity + '; ' + '<Br/>';
                               else{
                                   if((!String.isBlank(newCity)) && String.isBlank(oldCity)){
                                       contactInfo  += '<Br/>'+'New City Value:'+' '+ newCity+';' + '<Br/>';
                                   }
                                   if((String.isBlank(newCity)) && (!String.isBlank(oldCity))){
                                       contactInfo  += '<Br/>'+'New City Value:'+' '+ newCity+';' + '<Br/>';
                                   }
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }  
                           if(oldwishChildCon.MailingState!= newWishChildCon.MailingState){
                               newWishChildCon .Hidden_State__c = oldwishChildCon.MailingState;
                               if(newWishChildCon.MailingState != Null)
                                   oldState = newWishChildCon.MailingState;
                               if(newWishChildCon .Hidden_State__c != Null){
                                   newState = newWishChildCon .Hidden_State__c;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.Hidden_State__c == Null){
                                   newState = newWishChildCon .Hidden_State__c;
                                   newWishChildCon.Hidden_State__c = 'kanagumca_jcet@hotmail.com';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon .Hidden_State__c != Null && newWishChildCon.Hidden_State__c != 'kanagumca_jcet@hotmail.com')
                                   contactInfo += '<Br/>' + 'Old State Value:'+' '+oldState +'<Br/>'+' New State Value:' +' '+'  '+newState + '; ' + '<Br/>';
                               else{
                                   if((!String.isBlank(newState)) &&  String.isBlank(oldState))
                                       contactInfo += '<Br/>'+'New State Value:'+' '+'  '+newState+';' + '<Br/>';
                                   if((String.isBlank(newState)) &&  (!String.isBlank(oldState)))
                                       contactInfo += '<Br/>'+'New State Value:'+' '+'  '+newState+';' + '<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }   
                           if(oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry){
                               newWishChildCon .Hidden_Country__c = oldwishChildCon.MailingCountry;
                               if(newWishChildCon.MailingCountry != Null)
                                   oldCountry = newWishChildCon.MailingCountry;
                               if(newWishChildCon .Hidden_Country__c != Null){
                                   newCountry = newWishChildCon .Hidden_Country__c; 
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.Hidden_Country__c == Null){
                                   newCountry = newWishChildCon .Hidden_Country__c;
                                  // newWishChildCon.Hidden_Country__c = 'United States'; 
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.MailingCountry != Null && newWishChildCon.Hidden_Country__c != 'kanagumca_jcet@hotmail.com')
                                   contactInfo  += '<Br/>' + 'Old Country Value:'+' '+'  '+oldCountry +'<Br/>'+' New Country Value:' +' '+ '  '+ newCountry + '; '+'<Br/>';
                               else{
                                   if((!String.isBlank(newCountry )) && String.isBlank(oldCountry))
                                       contactInfo  += '<Br/>' + 'New Country Value:'+' '+ '  '+newCountry +';'+'<Br/>';
                                   if((String.isBlank(newCountry )) && (!String.isBlank(oldCountry)))
                                       contactInfo  += '<Br/>' + 'New Country Value:'+' '+ '  '+newCountry +';'+'<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }   
                           if(oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode){
                               newWishChildCon .Hidden_Zip_Code__c  = oldwishChildCon.MailingPostalCode; 
                               if(newWishChildCon.MailingPostalCode != Null)
                                   oldPostalCode =  newWishChildCon.MailingPostalCode;
                               if(newWishChildCon .Hidden_Zip_Code__c != Null){
                                   newPostalCode = newWishChildCon .Hidden_Zip_Code__c ;
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.Hidden_Zip_Code__c == Null){
                                   newPostalCode = newWishChildCon .Hidden_Zip_Code__c ;
                                   newWishChildCon.Hidden_Zip_Code__c = '11111';
                                   isChildSuccessMessage = true;
                               }
                               if(newWishChildCon.MailingPostalCode != Null && newWishChildCon.Hidden_Zip_Code__c != 'kanagumca_jcet@hotmail.com')
                                   contactInfo  += '<Br/>'+ 'Old Zip Code Value:'+' '+ '  '+oldPostalCode +'<Br/>'+' New Zip Code Value:' +' '+'  '+newPostalCode + '; '+'<Br/>';
                               else{
                                   if((!String.isBlank(newPostalCode )) && String.isBlank(oldPostalCode))
                                       contactInfo += '<Br/>' +' New Zip Code Value:'+' '+newPostalCode +';'+'<Br/>';
                                   if((String.isBlank(newPostalCode )) && (!String.isBlank(oldPostalCode)))
                                       contactInfo += '<Br/>' +' New Zip Code Value:'+' '+newPostalCode +';'+'<Br/>';
                               }
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);  
                           }
                           system.debug('newprfconId(outside)'+newPreferredCon);
                           if(oldwishChildCon.Hidden_Current_Pref_Con_Rel_Id__c != newPrfRelId){
                               system.debug('newprfconId(inside)'+newPreferredCon);
                               if(newPreferredCon != Null)
                                    newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = preferredConMapClone.get(newPreferredCon).Id;
                                else if(newPreferredCon == Null || newPreferredCon == '' )                                    
                                    newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
                               
                               //newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = newPreferredCon; 
                               if((String.isBlank(newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c) && newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c == Null) && (!String.isBlank(newPreferredCon))){
                                   contactInfo  += '<Br/>'+ 'Old Preferred Contact:'+' '+ 'Null'+'<Br/>'+' New Preferred Contact:' +' '+'  '+preferredConMapClone.get(newPreferredCon).npe4__RelatedContact__r.Name+ '; '+'<Br/>';
                                   newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = preferredConMapClone.get(newPreferredCon).id;
                                   //contactInfo += '<Br/>' +' New Preferred Contact:'+' '+preferredConMapClone.get(newPreferredCon).npe4__RelatedContact__r.Name+';'+'<Br/>';
                               }
                               else if((String.isBlank(newPreferredCon)) && (!String.isBlank(newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c))){
                                   contactInfo  += '<Br/>'+ 'Old Preferred Contact:'+' '+ '  '+oldPrfConRelMap.get(newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c).npe4__RelatedContact__r.Name+'<Br/>'+' New Preferred Contact:' +' '+'Null'+ '; '+'<Br/>';
                                    newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
                               }
                               else{
                                   newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = preferredConMapClone.get(newPreferredCon).Id;
                                   system.debug('REl Id**'+newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c);
                                   system.debug('REl IdMap**'+preferredConMapClone.keyset());
                                   contactInfo  += '<Br/>'+ 'Old Preferred Contact:'+' '+ '  '+oldPrfConRelMap.get(newWishChildCon.Hidden_Current_Pref_Con_Rel_Id__c).npe4__RelatedContact__r.Name+'<Br/>'+' New Preferred Contact:' +' '+'  '+preferredConMapClone.get(newPreferredCon).npe4__RelatedContact__r.Name+ '; '+'<Br/>';
                               }
                              // newWishChildCon.Hidden_Preferred_Contact_Rel_Id__c = newPreferredCon;
                               isChildSuccessMessage = true;
                               updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                           }
                       }
                } 
            }
        }
        for(Contact orderUseAsAddressList : clonedFamilyContactList){
            if(orderUseAsAddressList.Use_as_Household_Address__c  == true)
                firstUseAsAddressList.add(orderUseAsAddressList);
            else
                secondUseAsAddressList.add(orderUseAsAddressList);
            
        }
        for(contact sortAddress :secondUseAsAddressList){
            firstUseAsAddressList.add(sortAddress);
        }
        if(dbRelatedContactList != Null && dbRelatedContactList.size() > 0){
            for(Contact oldwishChildCon : firstUseAsAddressList){
                if(oldwishChildCon.Use_as_Household_Address__c == true){
                    i++;
                }
                if(oldwishChildCon.Same_as_Household_Address__c == true){
                    j++;
                }
                if(oldwishChildCon.Use_as_Household_Address__c == true && oldwishChildCon.Same_as_Household_Address__c == true){
                    k =1;
                }
                for(Contact newWishChildCon : dbRelatedContactList ){
                    if(oldwishChildCon.Id == newWishChildCon.Id){
                        if((oldwishChildCon.HomePhone != newWishChildCon.HomePhone && oldwishChildCon.Phone !=''  ) || (oldwishChildCon.Email != newWishChildCon.Email && oldwishChildCon.Email != '') || (oldwishChildCon.MailingStreet != newWishChildCon.MailingStreet && oldwishChildCon.MailingStreet != '') ||
                           (oldwishChildCon.MailingCity != newWishChildCon.MailingCity && oldwishChildCon.MailingCity != '' ) ||  (oldwishChildCon.MailingState!= newWishChildCon.MailingState && oldwishChildCon.MailingState !='')  || (oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry && oldwishChildCon.MailingCountry!= '') ||
                           (oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode && oldwishChildCon.MailingPostalCode != '') || (oldwishChildCon.Same_as_Household_Address__c != newWishChildCon.Same_as_Household_Address__c)|| (oldwishChildCon.Use_as_Household_Address__c  != newWishChildCon.Use_as_Household_Address__c) ||
                           (oldwishChildCon.MobilePhone != newWishChildCon.MobilePhone ) || (oldwishChildCon.OtherPhone != newWishChildCon.OtherPhone)|| (oldwishChildCon.npe01__WorkPhone__c != newWishChildCon.npe01__WorkPhone__c) || (oldwishChildCon.npe01__PreferredPhone__c != newWishChildCon.npe01__PreferredPhone__c ))
                        {
                            contactInfo  += '<Br/>' + 'Name :'+' '+'  '+newWishChildCon.FirstName+'  '+'  '+newWishChildCon.LastName+'  '+' ; '+'<Br/>';
                            if(oldwishChildCon.Use_as_Household_Address__c == true ){ 
                                newWishChildCon.Hidden_Use_as_Household_Address__c = oldwishChildCon.Use_as_Household_Address__c ;
                                if(oldwishChildCon.MailingStreet == newWishChildCon.MailingStreet && oldwishChildCon.MailingCity == newWishChildCon.MailingCity
                                   && oldwishChildCon.MailingState == newWishChildCon.MailingState && oldwishChildCon.MailingCountry == newWishChildCon.MailingCountry 
                                   && oldwishChildCon.MailingPostalCode == newWishChildCon.MailingPostalcode){
                                       
                                       newStreet = oldwishChildCon.MailingStreet;
                                       if((!String.isBlank(newStreet)) && String.isBlank(oldStreet ))
                                           contactInfo  +='<Br/>' +'New Street Value:'+newStreet+';'+'<Br/>';
                                       newCity = oldwishChildCon.MailingCity;
                                       if((!String.isBlank(newCity)) && String.isBlank(oldCity))
                                           contactInfo  +='<Br/>' +'New City Value:'+newCity+';'+'<Br/>';
                                       newState = oldwishChildCon.MailingState;
                                       if((!String.isBlank(newState)) && String.isBlank(oldState ))
                                           contactInfo  +='<Br/>' +'New State Value:'+newState+';'+'<Br/>';
                                       newCountry = oldwishChildCon.MailingCountry;
                                       if((!String.isBlank(newCountry )) && String.isBlank(oldCountry))
                                           contactInfo  += '<Br/>'+ 'New Country Value:'+newCountry +';'+'<Br/>';
                                       newPostalCode = newWishChildCon.MailingPostalCode;
                                       if((!String.isBlank(newPostalCode))  && String.isBlank(oldPostalCode))
                                           contactInfo += '<Br/>'+'New Zip Code Value:'+ '  '+ '  '+newPostalCode +';'+'<Br/>';
                                   }
                                newWishChildCon.Hidden_Use_as_Household_Address__c = oldwishChildCon.Use_as_Household_Address__c ;
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon); 
                                isChildSuccessMessage = true;
                            }
                            if(oldwishChildCon.Use_as_Household_Address__c == false){ 
                                isChildSuccessMessage = true;
                                newWishChildCon.Hidden_Use_as_Household_Address__c = oldwishChildCon.Use_as_Household_Address__c ;
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            }
                            if(oldwishChildCon.Use_as_Household_Address__c != newWishChildCon.Hidden_Use_as_Household_Address__c){ 
                                if(oldwishChildCon.Use_as_Household_Address__c == true){
                                    isChildSuccessMessage = true;
                                    newWishChildCon.Hidden_Use_as_Household_Address__c = oldwishChildCon.Use_as_Household_Address__c ;
                                    updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                }
                                if(oldwishChildCon.Use_as_Household_Address__c == false){
                                    isChildSuccessMessage = true;
                                    newWishChildCon.Hidden_Use_as_Household_Address__c = oldwishChildCon.Use_as_Household_Address__c ;
                                    updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                }
                            }
                            if(oldwishChildCon.Same_as_Household_Address__c == true){
                                isChildSuccessMessage = true;
                                newWishChildCon.Hidden_Same_Address__c = oldwishChildCon.Same_as_Household_Address__c ;
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                if(oldwishChildCon.MailingStreet == newWishChildCon.MailingStreet && oldwishChildCon.MailingCity == newWishChildCon.MailingCity
                                   && oldwishChildCon.MailingState == newWishChildCon.MailingState && oldwishChildCon.MailingCountry == newWishChildCon.MailingCountry 
                                   && oldwishChildCon.MailingPostalCode == newWishChildCon.MailingPostalcode){
                                       oldStreet = newWishChildCon.MailingStreet;
                                       if((!String.isBlank(oldStreet)) && (!String.isBlank(newStreet )))
                                           contactInfo += '<Br/>' + 'Old Street Value:'+  ' '+ '  '+oldStreet +' ' +'<Br/>' +' New Street Value:' + ' '+ '  '+ newStreet + '; '+'<Br/>';
                                       
                                       else{
                                           if((!String.isBlank(newStreet)) && String.isBlank(oldStreet))
                                               contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>'+'Old Street Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                            if(String.isBlank(newStreet) && (!String.isBlank(oldStreet)))
                                               contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>'+'Old Street Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                       }
                                       
                                       oldCity = newWishChildCon.MailingCity;
                                       if((!String.isBlank(oldCity)) && (!String.isBlank(newCity)))
                                           contactInfo  += '<Br/>'+ 'Old City Value:'+ ' '+ '  '+ oldCity +'<Br/>' + 'New City Value:' +' '+'  '+newCity + '; '+'<Br/>';
                                       
                                       else{
                                           if((!String.isBlank(newCity)) && String.isBlank(oldCity))
                                               contactInfo += '<Br/>' +'New City Value:'+'  '+'  '+newCity+';'+'<Br/>'+'Old City Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                           if(String.isBlank(newCity) && (!String.isBlank(oldCity)))
                                               contactInfo += '<Br/>' +'New City Value:'+'  '+'  '+newCity+';'+'<Br/>'+'Old City Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                       }
                                       oldState = newWishChildCon.MailingState;
                                       if((!String.isBlank(oldState)) && (!String.isBlank(newState )))
                                           contactInfo += '<Br/>'+'Old State Value:'+' '+'  '+ oldState +'<Br/>' +' New State Value:' +' '+ '  '+ newState + '; '+'<Br/>';
                                       
                                       else{
                                           if((!String.isBlank(newState)) && String.isBlank(oldState))
                                               contactInfo += '<Br/>' +'New State Value:'+'  '+'  '+newState+';'+'<Br/>'+'Old State Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                           if(String.isBlank(newState) && (!String.isBlank(oldState)))
                                               contactInfo += '<Br/>' +'New State Value:'+'  '+'  '+newState+';'+'<Br/>'+'Old State Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                       }
                                       oldCountry = newWishChildCon.MailingCountry;
                                       if((!String.isBlank(oldCountry )) && (!String.isBlank(newCountry)))
                                           contactInfo  += '<Br/>'+ 'Old Country Value:'+' ' + '  '+oldCountry +'<Br/>' +' New Country Value:' +' '+ '  '+ newCountry + '; '+'<Br/>';
                                       
                                       else{
                                           if((!String.isBlank(newCountry)) && String.isBlank(oldCountry))
                                               contactInfo += '<Br/>' +'New Country Value:'+'  '+'  '+newCountry+';'+'<Br/>'+'Old Country Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                           if(String.isBlank(newCountry) && (!String.isBlank(oldCountry)))
                                               contactInfo += '<Br/>' +'New Country Value:'+'  '+'  '+newCountry+';'+'<Br/>'+'Old Country Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                       }
                                       oldPostalCode = newWishChildCon.MailingPostalCode;
                                       if((!String.isBlank(oldPostalCode))  && (!String.isBlank(newPostalCode)))
                                           contactInfo  += '<Br/>'  + 'Old Zip Code Value:'+' '+ '  '+ oldPostalCode +'<Br/> '+' New Zip Code Value:'+' '+ '  '+ newPostalCode + '; '+'<Br/>';
                                       
                                       else{
                                           if((!String.isBlank(newPostalCode)) && String.isBlank(oldPostalCode))
                                               contactInfo += '<Br/>' +'New Zip Code Value:'+'  '+'  '+newPostalCode+';'+'<Br/>'+'Old Zip Code Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                           if(String.isBlank(newPostalCode) && (!String.isBlank(oldPostalCode)))
                                               contactInfo += '<Br/>' +'New Zip Code Value:'+'  '+'  '+newPostalCode+';'+'<Br/>'+'Old Zip Code Value:'+' '+' '+'Blank'+';'+'<Br/>';
                                       }
                                   }
                            }
                            if(oldwishChildCon.Same_as_Household_Address__c == false){
                                isChildSuccessMessage = true;
                                newWishChildCon.Hidden_Same_Address__c = oldwishChildCon.Same_as_Household_Address__c ;
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            }
                            if(oldwishChildCon.Same_as_Household_Address__c != newWishChildCon.Same_as_Household_Address__c ){ 
                                if(oldwishChildCon.Same_as_Household_Address__c  == true){
                                    isChildSuccessMessage = true;
                                    newWishChildCon.Hidden_Same_Address__c = oldwishChildCon.Same_as_Household_Address__c ;
                                    updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                }
                                if(oldwishChildCon.Same_as_Household_Address__c  == false){
                                    isChildSuccessMessage = true;
                                    newWishChildCon.Hidden_Same_Address__c = oldwishChildCon.Same_as_Household_Address__c ;
                                    updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                }
                            }
                            if(oldwishChildCon.HomePhone != newWishChildCon.HomePhone){
                                newWishChildCon.Hidden_Phone__c  = oldwishChildCon.HomePhone;
                                if(newWishChildCon.HomePhone != Null)
                                    oldPhone = newWishChildCon.HomePhone;
                                if(newWishChildCon .Hidden_Phone__c != Null){
                                    newPhone = newWishChildCon.Hidden_Phone__c;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.Hidden_Phone__c == Null){
                                    newPhone = newWishChildCon.Hidden_Phone__c;
                                    newWishChildCon.Hidden_Phone__c = '9912121313';
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.HomePhone != Null && oldphone != Null)
                                    contactInfo  += '<Br/>'+ 'Old phone Value :'+' '+'  '+ oldphone +'<Br/>' +' New Phone Value :' + ' '+  '  '+newPhone + '; '+'<Br/>';
                                else{
                                    if((!String.isBlank(newPhone)) && String.isBlank(oldphone))
                                        contactInfo  += '<Br/>'+'New Phone Value :' + '  '+ '  '+ newPhone + '; '+'<Br/>';
                                    if(String.isBlank(newPhone) && (!String.isBlank(oldphone)))
                                        contactInfo  += '<Br/>'+'New Phone Value :' + '  '+ '  '+ newPhone + '; '+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            }                                                       
                            
                            if(oldwishChildCon.npe01__WorkPhone__c != newWishChildCon.npe01__WorkPhone__c){
                                newWishChildCon.Hidden_Work_Phone__c  = oldwishChildCon.npe01__WorkPhone__c;
                                if(newWishChildCon.npe01__WorkPhone__c != Null)
                                    oldWorkPhone = newWishChildCon.npe01__WorkPhone__c;
                                if(newWishChildCon .Hidden_Work_Phone__c != Null){
                                    newWorkPhone = newWishChildCon.Hidden_Work_Phone__c;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.Hidden_Work_Phone__c == Null){
                                    newWorkPhone = newWishChildCon.Hidden_Work_Phone__c;
                                    newWishChildCon.Hidden_Work_Phone__c = '9912121313';
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.npe01__WorkPhone__c != Null && oldWorkphone != Null)
                                    contactInfo  += '<Br/>'+ 'Old Work phone Value :'+' '+'  '+ oldWorkphone +'<Br/>' +' New Work Phone Value :' + ' '+  '  '+newWorkPhone + '; '+'<Br/>';
                                else{
                                    if((!String.isBlank(newWorkPhone)) && String.isBlank(oldWorkphone))
                                        contactInfo  += '<Br/>'+'New Work Phone Value :' + '  '+ '  '+ newWorkPhone + '; '+'<Br/>';
                                    if(String.isBlank(newWorkPhone) && (!String.isBlank(oldWorkphone)))
                                        contactInfo  += '<Br/>'+'New Work Phone Value :' + '  '+ '  '+ newWorkPhone + '; '+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            } 
                            
                          /*  if(oldwishChildCon.npe01__PreferredPhone__c != newWishChildCon.npe01__PreferredPhone__c){
                                newWishChildCon.Hidden_Preferred_Phone_Types__c = oldwishChildCon.npe01__PreferredPhone__c;
                                if(newWishChildCon.npe01__PreferredPhone__c != Null)
                                    oldphoneType = newWishChildCon.npe01__PreferredPhone__c;
                                if(newWishChildCon .Hidden_Preferred_Phone_Types__c != Null){
                                    newPhoneType = newWishChildCon.Hidden_Preferred_Phone_Types__c;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.Hidden_Preferred_Phone_Types__c == Null){
                                    newPhoneType = newWishChildCon.Hidden_Preferred_Phone_Types__c;
                                    newWishChildCon.Hidden_Preferred_Phone_Types__c = 'kanagumca_jcet@hotmail.com';
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.npe01__PreferredPhone__c != Null && newWishChildCon.Hidden_Preferred_Phone_Types__c != Null)
                                    contactInfo  += '<Br/>'+ 'Old Preferred phone Type:'+' '+'  '+ oldphoneType+'<Br/>' +' New  Preferred phone Type :' + ' '+  '  '+newPhoneType + '; '+'<Br/>';
                                else{
                                    if((!String.isBlank(newPhoneType)) && String.isBlank(oldphoneType))
                                        contactInfo  += '<Br/>'+'New Preferred phone Type :' + '  '+ '  '+ newPhoneType + '; '+'<Br/>';
                                    if(String.isBlank(newPhoneType) && (!String.isBlank(oldphoneType)))
                                        contactInfo  += '<Br/>'+'New Preferred phone Type :' + '  '+ '  '+ newPhoneType + '; '+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            } 
                            */
                             if(oldwishChildCon.npe01__PreferredPhone__c != newWishChildCon.npe01__PreferredPhone__c){
                                
                                newWishChildCon.Hidden_Preferred_Phone_Types__c = oldwishChildCon.npe01__PreferredPhone__c;
                                if(newWishChildCon.npe01__PreferredPhone__c != Null)
                                    oldphoneType = newWishChildCon.npe01__PreferredPhone__c;
                                if(newWishChildCon .Hidden_Preferred_Phone_Types__c != Null){
                                    newPhoneType = newWishChildCon .Hidden_Preferred_Phone_Types__c;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon .Hidden_Preferred_Phone_Types__c == Null){
                                    newPhoneType = newWishChildCon .Hidden_Preferred_Phone_Types__c;
                                    newWishChildCon.Hidden_Preferred_Phone_Types__c = Label.Dummy_Email;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.npe01__PreferredPhone__c != Null && newWishChildCon .Hidden_Preferred_Phone_Types__c != Null)
                                    contactInfo  += '<Br/>'  + 'Old Preferred phone Type:'+ ' '+oldphoneType +' ' +'<Br/>' +' New Preferred phone Type:' + '  '+ '  '+ newPhoneType+ '; '+'<Br/>';
                                else{
                                    if((!String.isBlank(newPhoneType)) && String.isBlank(oldphoneType))
                                        contactInfo += '<Br/>'+'New Preferred phone Type:' + '  '+ '  '+newPhoneType+';'+'<Br/>';
                                    if(String.isBlank(newPhoneType) && (!String.isBlank(oldphoneType)))
                                        contactInfo += '<Br/>'+'New Preferred phone Type:' + '  '+ '  '+newPhoneType+';'+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            } 


                            if( oldwishChildCon.MobilePhone != newWishChildCon.MobilePhone){
                                newWishChildCon.HiddenMobilePhone__c= oldwishChildCon.MobilePhone;
                                if(newWishChildCon.MobilePhone!= Null)
                                    oldMobilePhone = newWishChildCon.MobilePhone;
                                if(newWishChildCon.HiddenMobilePhone__c != Null){
                                    newMobilePhone= newWishChildCon.HiddenMobilePhone__c;
                                    isChildSuccessMessage = true;
                                }
                                
                                if(newWishChildCon.HiddenMobilePhone__c == Null){
                                    newMobilePhone= newWishChildCon.HiddenMobilePhone__c;
                                    newWishChildCon.HiddenMobilePhone__c = '9912121313';
                                    isChildSuccessMessage = true;
                                }
                                
                                if(newWishChildCon.MobilePhone!= Null && newWishChildCon.HiddenMobilePhone__c!= Null)
                                    contactInfo += '<Br/>' +'Old Mobile Phone Value :'+ ' '+oldMobilePhone+'<Br/>' +' New Mobile Phone Value :' +' '+newMobilePhone+ '; ' + '<Br/>';
                                else{
                                    if((!String.isBlank(newMobilePhone)) && String.isBlank(oldMobilePhone))
                                        contactInfo += '<Br/>'+'New Mobile Phone Value :'+' '+ newMobilePhone+ '; '+'<Br/>';
                                    if(String.isBlank(newMobilePhone) && (!String.isBlank(oldMobilePhone)))
                                        contactInfo += '<Br/>'+'New Mobile Phone Value :'+' '+ newMobilePhone+ '; '+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                
                            }
                            
                            if( oldwishChildCon.otherPhone != newWishChildCon.otherPhone ){
                                newWishChildCon.HiddenOtherPhone__c = oldwishChildCon.otherPhone ;
                                if(newWishChildCon.otherPhone != Null)
                                    oldOtherPhone = newWishChildCon.otherPhone;
                                if(newWishChildCon.HiddenOtherPhone__c!= Null){
                                    newOtherPhone = newWishChildCon.HiddenOtherPhone__c;
                                    isChildSuccessMessage = true;
                                }
                                
                                if(newWishChildCon.HiddenOtherPhone__c == Null ){
                                    newOtherPhone = newWishChildCon.HiddenOtherPhone__c;
                                    newWishChildCon.HiddenOtherPhone__c = '9912121313';
                                    isChildSuccessMessage = true;
                                }
                                
                                if(newWishChildCon.otherPhone != Null && newWishChildCon.HiddenOtherPhone__c!= Null)
                                    contactInfo += '<Br/>' +'Old Other Phone Value :'+ ' '+oldOtherPhone+'<Br/>' +' New Other Phone Value :' +' '+newOtherPhone+ '; ' + '<Br/>';
                                else{
                                    if((!String.isBlank(newOtherPhone)) && String.isBlank(oldOtherPhone))
                                        contactInfo += '<Br/>'+'New Other Phone Value :'+' '+ newOtherPhone+ '; '+'<Br/>';
                                    if(String.isBlank(newOtherPhone) && (!String.isBlank(oldOtherPhone)))
                                        contactInfo += '<Br/>'+'New Other Phone Value :'+' '+ newOtherPhone+ '; '+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                                
                            }
                            if(oldwishChildCon.Email != newWishChildCon.Email){
                                
                                newWishChildCon.Hidden_Email__c = oldwishChildCon.Email;
                                if(newWishChildCon.Email != Null)
                                    oldEmail = newWishChildCon.Email;
                                if(newWishChildCon .Hidden_Email__c != Null){
                                    newEmail = newWishChildCon .Hidden_Email__c;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon .Hidden_Email__c == Null){
                                    newEmail = newWishChildCon .Hidden_Email__c;
                                    newWishChildCon.Hidden_Email__c = 'kanagumca_jcet@hotmail.com';
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.Email != Null && newWishChildCon .Hidden_Email__c != Null)
                                    contactInfo  += '<Br/>'  + 'Old Email Value:'+ ' '+oldEmail +' ' +'<Br/>' +' New Email Value:' + '  '+ '  '+ newEmail+ '; '+'<Br/>';
                                else{
                                    if((!String.isBlank(newEmail)) && String.isBlank(oldEmail))
                                        contactInfo += '<Br/>'+'New Email Value :' + '  '+ '  '+newEmail+';'+'<Br/>';
                                    if(String.isBlank(newEmail) && (!String.isBlank(oldEmail)))
                                        contactInfo += '<Br/>'+'New Email Value :' + '  '+ '  '+newEmail+';'+'<Br/>';
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            } 
                            if(oldwishChildCon.MailingStreet !=newWishChildCon.MailingStreet){
                                newWishChildCon .Hidden_Street__c = oldwishChildCon.MailingStreet;
                                if(newWishChildCon.MailingStreet != Null)
                                    oldStreet = newWishChildCon.MailingStreet;
                                if(newWishChildCon.Hidden_Street__c != Null){
                                    newStreet = newWishChildCon .Hidden_Street__c;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.Hidden_Street__c == Null){
                                    newStreet = newWishChildCon.Hidden_Street__c;
                                    newWishChildCon.Hidden_Street__c = 'kanagumca_jcet@hotmail.com';
                                    isChildSuccessMessage = true;
                                }
                                if(oldwishChildCon.Use_as_Household_Address__c == true){
                                    if(newWishChildCon.MailingStreet != Null && newWishChildCon .Hidden_Street__c != Null)
                                        contactInfo += '<Br/>' + 'Old Street Value:'+  ' '+ '  '+oldStreet +' ' +'<Br/>' +' New Street Value:' + ' '+ '  '+ newStreet + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newStreet)) && String.isBlank(oldStreet))
                                            contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>';
                                         if(String.isBlank(newStreet) && (!String.isBlank(oldStreet)))
                                            contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>';
                                    }
                                }
                                else{
                                    if(newWishChildCon.MailingStreet != Null && newWishChildCon .Hidden_Street__c != Null)
                                        contactInfo += '<Br/>' + 'Old Street Value:'+  ' '+ '  '+oldStreet +' ' +'<Br/>' +' New Street Value:' + ' '+ '  '+ newStreet + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newStreet)) && String.isBlank(oldStreet))
                                            contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>';
                                         if(String.isBlank(newStreet) && (!String.isBlank(oldStreet)))
                                            contactInfo += '<Br/>' +'New Street Value:'+'  '+'  '+newStreet+';'+'<Br/>';
                                    }
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            } 
                            if(oldwishChildCon.MailingCity != newWishChildCon.MailingCity){
                                isChildSuccessMessage = true;
                                newWishChildCon .Hidden_city__c = oldwishChildCon.MailingCity;
                                if(newWishChildCon.MailingCity != Null)
                                    oldCity = newWishChildCon.MailingCity;
                                if(newWishChildCon.Hidden_city__c != Null){
                                    newCity =newWishChildCon .Hidden_city__c;
                                    isChildSuccessMessage = true;
                                }
                                 if(newWishChildCon.Hidden_city__c == Null){
                                    newCity =newWishChildCon .Hidden_city__c;
                                    newWishChildCon .Hidden_city__c = 'kanagumca_jcet@hotmail.com';
                                    isChildSuccessMessage = true;
                                }
                                if(oldwishChildCon.Use_as_Household_Address__c == true){
                                    if(newWishChildCon.MailingCity != Null && oldCity  != Null)
                                        contactInfo  += '<Br/>'+ 'Old City Value:'+ ' '+ '  '+ oldCity +'<Br/>' + 'New City Value:' +' '+'  '+newCity + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newCity))  && String.isBlank(oldCity)){
                                            contactInfo  += '<Br/>' +'New City Value:'+ '  '+ '  '+newCity+';'+'<Br/>';
                                        }
                                        if(String.isBlank(newCity)  && (!String.isBlank(oldCity))){
                                            contactInfo  += '<Br/>' +'New City Value:'+ '  '+ '  '+newCity+';'+'<Br/>';
                                        }
                                    }
                                }
                                else{
                                    if(newWishChildCon.MailingCity != Null && oldCity  != Null)
                                        contactInfo  += '<Br/>'+ 'Old City Value:'+ ' '+ '  '+ oldCity +'<Br/>' + 'New City Value:' +' '+'  '+newCity + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newCity))  && String.isBlank(oldCity)){
                                            contactInfo  += '<Br/>' +'New City Value:'+ '  '+ '  '+newCity+';'+'<Br/>';
                                        }
                                        if(String.isBlank(newCity)  && (!String.isBlank(oldCity))){
                                            contactInfo  += '<Br/>' +'New City Value:'+ '  '+ '  '+newCity+';'+'<Br/>';
                                        }
                                    }
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            }  
                            if(oldwishChildCon.MailingState!= newWishChildCon.MailingState){
                                newWishChildCon.Hidden_State__c = oldwishChildCon.MailingState;
                                if(newWishChildCon.MailingState != Null)
                                    oldState = newWishChildCon.MailingState;
                                if(newWishChildCon .Hidden_State__c != Null || newWishChildCon.Hidden_State__c == Null){
                                    newState = newWishChildCon .Hidden_State__c;
                                    isChildSuccessMessage = true;  
                                }
                                if(newWishChildCon.Hidden_State__c == Null){
                                    newState = newWishChildCon .Hidden_State__c;
                                    newWishChildCon .Hidden_State__c = 'kanagumca_jcet@hotmail.com';
                                    isChildSuccessMessage = true;  
                                }
                                if(oldwishChildCon.Use_as_Household_Address__c == true){
                                    if(newWishChildCon .Hidden_State__c != Null && newWishChildCon.MailingState != Null)
                                        contactInfo += '<Br/>'+'Old State Value:'+' '+'  '+ oldState +'<Br/>' +' New State Value:' +' '+ '  '+ newState + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newState)) && String.isBlank(oldState ))
                                            contactInfo  +='<Br/>' +'New State Value:'+newState+';'+'<Br/>';
                                        if(String.isBlank(newState) && (!String.isBlank(oldState )))
                                            contactInfo  +='<Br/>' +'New State Value:'+newState+';'+'<Br/>';
                                    }
                                }
                                else{
                                    if(newWishChildCon .Hidden_State__c != Null && newWishChildCon.MailingState != Null)
                                        contactInfo += '<Br/>'+'Old State Value:'+' '+'  '+ oldState +'<Br/>' +' New State Value:' +' '+ '  '+ newState + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newState)) && String.isBlank(oldState ))
                                            contactInfo  +='<Br/>' +'New State Value:'+newState+';'+'<Br/>';
                                        if(String.isBlank(newState) && (!String.isBlank(oldState )))
                                            contactInfo  +='<Br/>' +'New State Value:'+newState+';'+'<Br/>';
                                    }
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            }   
                            if(oldwishChildCon.MailingCountry!= newWishChildCon.MailingCountry){
                                newWishChildCon .Hidden_Country__c = oldwishChildCon.MailingCountry;
                                if(newWishChildCon.MailingCountry != Null)
                                    oldCountry = newWishChildCon.MailingCountry;
                                if(newWishChildCon .Hidden_Country__c != Null){
                                    newCountry = newWishChildCon .Hidden_Country__c;
                                    isChildSuccessMessage = true;
                                } 
                                if(newWishChildCon .Hidden_Country__c == Null){
                                    newCountry = newWishChildCon .Hidden_Country__c;
                                    newWishChildCon.Hidden_Country__c = 'United States';
                                    isChildSuccessMessage = true;
                                } 
                                if(oldwishChildCon.Use_as_Household_Address__c == true){
                                    if(newWishChildCon.MailingCountry != Null && newWishChildCon .Hidden_Country__c != Null)
                                        contactInfo  += '<Br/>'+ 'Old Country Value:'+' ' + '  '+oldCountry +'<Br/>' +' New Country Value:' +' '+ '  '+ newCountry + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newCountry )) && String.isBlank(oldCountry))
                                            contactInfo  += '<Br/>'+ 'New Country Value:'+newCountry +';'+'<Br/>';
                                        if(String.isBlank(newCountry ) && (!String.isBlank(oldCountry)))
                                            contactInfo  += '<Br/>'+ 'New Country Value:'+newCountry +';'+'<Br/>';
                                    }
                                }
                                else{
                                    if(newWishChildCon.MailingCountry != Null && newWishChildCon .Hidden_Country__c != Null)
                                        contactInfo  += '<Br/>'+ 'Old Country Value:'+' ' + '  '+oldCountry +'<Br/>' +' New Country Value:' +' '+ '  '+ newCountry + '; '+'<Br/>';
                                    else{
                                        
                                        if((!String.isBlank(newCountry )) && String.isBlank(oldCountry))
                                            contactInfo  += '<Br/>'+ 'New Country Value:'+newCountry +';'+'<Br/>';
                                        if(String.isBlank(newCountry ) && (!String.isBlank(oldCountry)))
                                            contactInfo  += '<Br/>'+ 'New Country Value:'+newCountry +';'+'<Br/>';
                                    }
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);
                            }   
                            if(oldwishChildCon.MailingPostalCode != newWishChildCon.MailingPostalCode){
                                newWishChildCon.Hidden_Zip_Code__c  = oldwishChildCon.MailingPostalCode; 
                                if(newWishChildCon.MailingPostalCode != Null)
                                    oldPostalCode =  newWishChildCon.MailingPostalCode;
                                if(newWishChildCon .Hidden_Zip_Code__c != Null){
                                    newPostalCode = newWishChildCon.Hidden_Zip_Code__c ;
                                    isChildSuccessMessage = true;
                                }
                                if(newWishChildCon.Hidden_Zip_Code__c  == Null){
                                    newPostalCode = newWishChildCon.Hidden_Zip_Code__c ;
                                    newWishChildCon.Hidden_Zip_Code__c  = '11111'; 
                                    isChildSuccessMessage = true;
                                }
                                if(oldwishChildCon.Use_as_Household_Address__c == true){
                                    if(newWishChildCon.MailingPostalCode != Null && newWishChildCon .Hidden_Zip_Code__c != Null)
                                        contactInfo  += '<Br/>'  + 'Old Zip Code Value:'+' '+ '  '+ oldPostalCode +'<Br/> '+' New Zip Code Value:'+' '+ '  '+ newPostalCode + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newPostalCode))  && String.isBlank(oldPostalCode))
                                            contactInfo += '<Br/>'+'New Zip Code Value:'+ '  '+ '  '+newPostalCode +';'+'<Br/>';
                                         if(String.isBlank(newPostalCode)  && (!String.isBlank(oldPostalCode)))
                                            contactInfo += '<Br/>'+'New Zip Code Value:'+ '  '+ '  '+newPostalCode +';'+'<Br/>';
                                    }
                                }
                                
                                else{
                                    if(newWishChildCon.MailingPostalCode != Null && newWishChildCon .Hidden_Zip_Code__c != Null)
                                        contactInfo  += '<Br/>'  + 'Old Zip Code Value:'+' '+ '  '+ oldPostalCode +'<Br/> '+' New Zip Code Value:'+' '+ '  '+ newPostalCode + '; '+'<Br/>';
                                    else{
                                        if((!String.isBlank(newPostalCode))  && String.isBlank(oldPostalCode))
                                            contactInfo += '<Br/>'+'New Zip Code Value:'+ '  '+ '  '+newPostalCode +';'+'<Br/>';
                                         if(String.isBlank(newPostalCode)  && (!String.isBlank(oldPostalCode)))
                                            contactInfo += '<Br/>'+'New Zip Code Value:'+ '  '+ '  '+newPostalCode +';'+'<Br/>';
                                    }
                                }
                                updateContactMap.put(newWishChildCon.Id,newWishChildCon);  
                            }
                            
                        }
                    }
                }
            }
            if(i > 1){
                isMessage = false;
                DisplayErrorMessage();
            }
            if(i == 0 && j > 0){
                isMessage = false;
                ErrorMessage();
            }
            if(k == 1){
                isMessage = false;
                SameErrorMessage();
            }
        }
        if(updateContactMap.size() > 0){
            update updateContactMap.Values();
            system.debug('rec Id***************Map'+updateContactMap.values());
            if(isChildSuccessMessage == true){
                Id updateContactTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.updateContactRT).getRecordTypeId();
                Id staffRt = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
                isMessage = false;
                String message = 'Thank you for updating the contact information! Your changes have been recorded and sent to the chapter staff for approval.'+'\r\n'+
                    +'Please click on Return to Wish to navigate to the previous screen.';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,message));
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Review contact information updated by the volunteer');
                req.setObjectId(parentWish.ContactId);
                req.setProcessDefinitionNameOrId('Update_Contact_Info_Process');
                req.setSkipEntryCriteria(true);
                req.setNextApproverIds(new Id[]{parentWish.OwnerId});
                Approval.ProcessResult result = Approval.process(req);
                
                Task newContactTask = new Task();
                newContactTask.WhoId = parentWish.ContactId;
                newContactTask.OwnerId = parentWish.OwnerId;
                newContactTask.ActivityDate = System.today() + 1;
                newContactTask.RecordTypeId = staffRt;
                newContactTask.SystemGeneratedTask__c = true;
                newContactTask .Subject = 'Review contact information updated by the volunteer';
                demogarphicTaskList.add(newContactTask );
                insert   demogarphicTaskList; 
            }
        }
        if(contactList.size()>0){
            contactList[0].Old_Update_Contact_Values__c = contactInfo;
            Id relId;            
            /*for(npe4__Relationship__c  checkedRel : preferredConMapClone.values()){
                if(checkedRel.Hidden_Preferred_Contact__c){
                relId = checkedRel.id;
                system.debug('rec Id***************'+checkedRel.Id);
                }
                system.debug('rec Id***************');
            }*/
           /* if(newPreferredCon != Null)
                contactList[0].Hidden_Preferred_Contact_Rel_Id__c = preferredConMapClone.get(newPreferredCon).Id;
            else if(newPreferredCon == Null)
                contactList[0].Hidden_Preferred_Contact_Rel_Id__c = Null;*/
            update contactList;
        }
        return null;     
    }
    
    /******************************************************************************************************
     close() will fire if the user click the cancle button on RelationShipViewer page.
    ********************************************************************************************************/
    public void close(){
        outPutMode = true;
        inputMode = false;
    }
    
    
    /******************************************************************************************************
     DisplayErrorMessage() will fire if the user update the address details and if they not select use as household 
     address.
    ********************************************************************************************************/
     public pageReference DisplayErrorMessage(){
        inputMode = true;
        outPutMode = false;
        isSave = true;
        
        if(isMessage == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select one Use as household address.'));
            isChildSuccessMessage = false;
        }
        return null;
    }
    
    /******************************************************************************************************
     ErrorMessage() will fire if the user update the address details and if they not select use as household 
     address.
    ********************************************************************************************************/
     public pageReference ErrorMessage(){
        inputMode = true;
        outPutMode = false;
        isSave = true;
        
        if(isMessage == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Use as household address.'));
            isChildSuccessMessage = false;
        }
        return null;
    }
    
    /******************************************************************************************************
     SameErrorMessage() will fire if the user check the use as household and same as house hold check box on 
     same record.
    ********************************************************************************************************/
     public pageReference SameErrorMessage(){
        inputMode = true;
        outPutMode = false;
        isSave = true;
        
        if(isMessage == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You cannot select Use as household address and same as household address for same record'));
            isChildSuccessMessage = false;
        }
        return null;
    }
    
    /******************************************************************************************************
     ReturnToWish() will fire when the user click Return to wish link in RelationshipViewer page.
    ********************************************************************************************************/
    public pageReference ReturnToWish(){
        PageReference reference=new PageReference('/'+caseId);
        reference.setRedirect(true);     
        return reference;
        
    }
}