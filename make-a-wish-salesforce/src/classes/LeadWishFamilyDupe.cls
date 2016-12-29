global class LeadWishFamilyDupe {

  webservice static String FindFamilyContactDupe(Id leadId){
        Constant_AC  constant = new Constant_AC();
        Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id wishFamilyRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id medicalProfessionalRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
       
        Lead currLead =  [SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c, 
                             Email, DOB__c ,Phone,chapterName__c, 
                             City, State, Street, PostalCode, Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c,
                             Medical_Professional_Phone__c, Medical_Professional_Email__c, Treating_Medical_Professional_First_Name__c,
                             Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Phone__c, Treating_Medical_Professional_Email__c FROM Lead
                             WHERE id = :leadId limit 1];
                             
                             
        
        List<Contact> dupMedicalContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                         MailingState, MailingPostalCode FROM Contact
                         WHERE (FirstName = :currLead.Medical_Professional_First_Name__c AND LastName = :currLead.Medical_Professional_Last_Name__c 
                         AND (Phone = :currLead.Medical_Professional_Phone__c Or Email =: currLead.Medical_Professional_Email__c) 
                         AND RecordTypeId = :MedicalProfessionalRT)];
                         
        List<Contact> dupTreatingContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                         MailingState, MailingPostalCode FROM Contact
                         WHERE (FirstName = :currLead.Treating_Medical_Professional_First_Name__c AND 
                         LastName = :currLead.Treating_Medical_Professional_Last_Name__c 
                         AND (Phone = :currLead.Treating_Medical_Professional_Phone__c Or Email =: currLead.Treating_Medical_Professional_Email__c) 
                         AND RecordTypeId = :MedicalProfessionalRT)]; 
                         
        List<Contact> dupFamilyContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                         MailingState, MailingPostalCode FROM Contact
                         WHERE (FirstName = :currLead.Parent_First_Name__c AND LastName = :currLead.Parent_Last_Name__c AND 
                               (((Email = :currLead.Email OR Phone = :currLead.Phone) 
                               AND (MailingStreet = :currLead.Street AND MailingState = :currLead.State 
                               AND MailingPostalCode = :currLead.PostalCode 
                               AND MailingCity = :currLead.City))  
                               OR ((Phone = :currLead.Phone OR (MailingStreet = :currLead.Street AND MailingState = :currLead.State 
                               AND MailingPostalCode = :currLead.PostalCode 
                               AND MailingCity = :currLead.City))
                               AND Email = :currLead.Email)  OR (((MailingStreet = :currLead.Street AND MailingState = :currLead.State 
                               AND MailingPostalCode = :currLead.PostalCode 
                               AND MailingCity = :currLead.City) OR (Email = :currLead.Email) )
                               AND Phone = :currLead.Email))) AND RecordTypeId = :wishFamilyRT];  
           
                              
          if((dupMedicalContacts.size() > 0 || dupTreatingContacts.size() >0) && dupFamilyContacts.size() > 0) 
             return 'There might be an existing Wish Family and Medical Professional. Please click on [OK] to review the existing record.';                   
          else if(dupMedicalContacts.size() > 0 || dupTreatingContacts.size() >0)     
             return 'There might be an existing Medical Professional. Please click on [OK] to review the existing record.';
          else if(dupFamilyContacts.size() > 0)
             return 'There might be an existing Wish Family. Please click on [OK] to review the existing record.';
          else return null;
                         
                                                             
                         
  }
  
    webservice static String FindLeadDupe(Id leadId)
    {
        Set<String> leadFNamesSet = new Set<String>();
        Set<String> leadLNamesSet = new Set<String>();
        Set<Date> leadbDaysSet = new Set<Date>();
        Set<String> AddressSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> zipCodesSet = new Set<String>();
        Set<String> citySet = new Set<String>();
        Set<String> emailsSet = new Set<String>();
        Set<String> stateSet = new Set<String>();
        Set<Id> leadIds = new Set<Id>();
        Set<String> chaptersSet = new Set<String>();
        set<String> exFNamesSet = new Set<String>();
        Set<String> exLNamesSet = new Set<String>();
        Set<Date> exbDaysSet = new Set<Date>();
        Set<String> exAddressSet = new Set<String>();
        Set<String> exphoneSet = new Set<String>();
        Set<String> exemailsSet = new Set<String>();
        
        String instanceUrl = label.Instance_Url;
        
        List<Lead> leadList =  [SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c, 
                             Email, DOB__c ,Phone,chapterName__c, 
                             City, State, Street, PostalCode, Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c,
                             Medical_Professional_Phone__c, Medical_Professional_Email__c, Treating_Medical_Professional_First_Name__c,
                             Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Phone__c, Treating_Medical_Professional_Email__c FROM Lead
                             WHERE id = :leadId AND isConverted = false limit 1];
        
        for(Lead currLead :leadList)
        {
            if(currLead.FirstName != Null)
                leadFNamesSet.add(currLead.FirstName);
            if(currLead.LastName != Null)
                leadLNamesSet.add(currLead.LastName);
            if(currLead.DOB__c != Null)
                leadbDaysSet.add(currLead.DOB__c);
            
            addressSet.add(currLead.City+'-'+currLead.State+'-'+currLead.PostalCode);
            if(currLead.PostalCode != Null)
                zipCodesSet.add(currLead.PostalCode);
            if(currLead.city!= Null)
                citySet.add(currLead.city);
            if(currLead.State!= Null)
                stateSet.add(currLead.State);
            if(currLead.Phone!= Null)
                phoneSet.add(currLead.Phone);
            if(currLead.Email!= Null)
                emailsSet.add(currLead.Email);
            
            chaptersSet.add(currLead.chapterName__c);
            if(currLead.id != Null)    
                leadIds.add(currLead.id);
            
        }
        
        for(Lead exLead : [SELECT Id,LastName, FirstName, Email, chapterName__c,Phone, DOB__c,
                           City,State,PostalCode FROM Lead 
                           WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR DOB__c IN :leadbDaysSet
                                  OR Phone IN :phoneSet OR Email IN :emailsSet OR (State IN :stateSet AND Postalcode IN :zipCodesSet AND city IN :citySet)) 
                           AND ChapterName__c IN :chaptersSet
                           AND Id NOT IN :leadIds AND isConverted = false])
        {
        
            System.debug('exLead.id +++++++++++++++++++++++++++++++++++++++++++++++== ' +exLead.id);
            if(exLead.FirstName != Null)
                exFNamesSet.add(exLead.FirstName+'-'+exLead.chapterName__c);
            if(exLead.LastName != Null)
                exLNamesSet.add(exLead.LastName+'-'+exLead.chapterName__c);
            if(exLead.DOB__c != Null)
                exbDaysSet.add(exLead.DOB__c);
            if(exLead.City != Null && exLead.State != Null && exLead.PostalCode != Null)
                exAddressSet.add(exLead.City+'-'+exLead.State+'-'+exLead.PostalCode+'-'+exLead.chapterName__c);
            if(exLead.phone != Null)
                exPhoneSet.add(exLead.phone+'-'+exLead.chapterName__c);
            if(exLead.Email != Null)
                exemailsSet.add(exLead.Email+'-'+exLead.chapterName__c);
        }
    
        
        for(Lead newLead : leadList)
        {  
            
           if(newLead.id != Null && exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c) &&  (exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c)))
            {
                  return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                //newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            else if(newLead.id != Null && ((exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c) ||  exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c)) 
                                           && ((exAddressSet.contains(newLead.City+'-'+newLead.State+'-'+newLead.PostalCode+'-'+newLead.chapterName__c) 
                                                || exPhoneSet.contains(newLead.Phone+'-'+newLead.chapterName__c) || exemailsSet.contains(newLead.Email+'-'+newLead.chapterName__c)))))
            {
                  return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                //newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            
            else if(newLead.id != Null && (exbDaysSet.contains(newLead.Dob__c) &&  ((exAddressSet.contains(newLead.City+'-'+newLead.State+'-'+newLead.PostalCode+'-'+newLead.chapterName__c) 
                                                                                     || exPhoneSet.contains(newLead.Phone+'-'+newLead.chapterName__c) || exemailsSet.contains(newLead.Email+'-'+newLead.chapterName__c)))))
            {    
                  return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                //newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            else if(newLead.id != Null && ((exbDaysSet.contains(newLead.Dob__c) && exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c))))
            { 
                  return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
               // newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            
            else if(newLead.id != Null && (exbDaysSet.contains(newLead.Dob__c) && exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c)))
            {
                  return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
               // newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
      
        }
        
        return null;
    } 
    
}