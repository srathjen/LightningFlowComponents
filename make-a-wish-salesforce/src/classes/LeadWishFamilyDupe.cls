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
}