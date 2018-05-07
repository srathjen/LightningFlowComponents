/******************************************************
Modification Log:
1. 12/04/2018 - Yuvraj - IME-77 Line No: 237

*******************************************************/
global class LeadWishFamilyDupe {
    
    webservice static String FindFamilyContactDupe(Id leadId){
        Constant_AC  constant = new Constant_AC();
        Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id wishFamilyRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id medicalProfessionalRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        String Logvalue;
       // try{
        Lead currLead =  [SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c, 
                          Email, DOB__c ,Phone,chapterName__c, 
                          City, State, Street, PostalCode, Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c,
                          Medical_Professional_Phone__c, Medical_Professional_Email__c, Treating_Medical_Professional_First_Name__c,
                          Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Phone__c, Treating_Medical_Professional_Email__c , 
                          Best_contact_for_Physician_Email__c,Best_Contact_for_Physician_Last_Name__c ,Best_Contact_for_Physician_First_Name__c,
                          Additional_Parent_City__c,Additional_Parent_Email__c,Alternate2MedProfessionalLastName__c,Alternate2MedProfessionalPhone__c,Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,
                          Additional_Parent_Phone__c,Alternate2MedProfessionalEmail__c,Alternate2MedProfessionalFirstName__c,Alternate1MedicalProfessionalEmail__c,Alternate1MedProfessionalPhone__c,Alternate1MedProfessionalLastName__c,Alternate1MedProfessionalFirstName__c,Additional_Parent_Postal_Code__c,Additional_Parent_State__c,Additional_Parent_Street__c FROM Lead
                          WHERE id = :leadId limit 1];
        
        
        Logvalue = String.valueof(currLead);
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
        
        List<Contact> dupBestContactPhysicians = [SELECT id,FirstName,LastName,Email FROM Contact 
                                                  WHERE LastName =: currLead.Best_Contact_for_Physician_Last_Name__c AND FirstName=: currLead.Best_Contact_for_Physician_First_Name__c AND
                                                  Email=: currLead.Best_contact_for_Physician_Email__c AND  RecordTypeId = :MedicalProfessionalRT ]; 
        
        List<Contact> alternate1MedProfessionl = [SELECT id,FirstName,LastName,Email FROM Contact 
                                                  WHERE LastName =: currLead.Alternate1MedProfessionalLastName__c AND FirstName=: currLead.Alternate1MedProfessionalFirstName__c AND
                                                  Email=: currLead.Alternate1MedicalProfessionalEmail__c AND  RecordTypeId = :MedicalProfessionalRT ]; 
        
        List<Contact> alternate2MedProfessionl = [SELECT id,FirstName,LastName,Email FROM Contact 
                                                  WHERE LastName =: currLead.Alternate2MedProfessionalLastName__c AND FirstName=: currLead.Alternate2MedProfessionalFirstName__c AND
                                                  Email=: currLead.Alternate2MedProfessionalEmail__c AND  RecordTypeId = :MedicalProfessionalRT ]; 
        
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
                                                                                         AND Phone = :currLead.Phone))) AND RecordTypeId = :wishFamilyRT];  
        List<Contact> dupAdditionalFamilyContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                                                     MailingState, MailingPostalCode FROM Contact
                                                     WHERE (FirstName = :currLead.Additional_Parent_First_Name__c AND LastName = :currLead.Additional_Parent_Last_Name__c AND 
                                                            (((Email = :currLead.Additional_Parent_Email__c OR Phone = :currLead.Additional_Parent_Phone__c) 
                                                              AND (MailingStreet = :currLead.Additional_Parent_Street__c AND MailingState = :currLead.Additional_Parent_State__c
                                                                   AND MailingPostalCode = :currLead.Additional_Parent_Postal_Code__c
                                                                   AND MailingCity = :currLead.Additional_Parent_City__c))  
                                                             OR ((Phone = :currLead.Additional_Parent_Phone__c OR (MailingStreet = :currLead.Additional_Parent_Street__c  AND MailingState = :currLead.Additional_Parent_State__c
                                                                                                                   AND MailingPostalCode = :currLead.Additional_Parent_Postal_Code__c
                                                                                                                   AND MailingCity = :currLead.Additional_Parent_City__c))
                                                                 AND Email = :currLead.Additional_Parent_Email__c )  OR (((MailingStreet = :currLead.Additional_Parent_Street__c AND MailingState = :currLead.Additional_Parent_State__c
                                                                                                                           AND MailingPostalCode = :currLead.Additional_Parent_Postal_Code__c
                                                                                                                           AND MailingCity = :currLead.Additional_Parent_City__c) OR (Email = :currLead.Additional_Parent_Email__c ) )
                                                                                                                         AND Phone = :currLead.Additional_Parent_Phone__c ))) AND RecordTypeId = :wishFamilyRT];  
        
        
        if((dupMedicalContacts.size() > 0 || dupTreatingContacts.size() >0 || alternate1MedProfessionl.size() > 0 || alternate2MedProfessionl.size() > 0) && (dupFamilyContacts.size() > 0 || dupAdditionalFamilyContacts.Size() >0)) 
            return 'There might be an existing Wish Family and Medical Professional. Please click on [OK] to review the existing record.';                   
        else if(dupMedicalContacts.size() > 0 || dupTreatingContacts.size() >0 || alternate1MedProfessionl.size() > 0 || alternate2MedProfessionl.size() > 0)     
            return 'There might be an existing Medical Professional. Please click on [OK] to review the existing record.';
        else if(dupFamilyContacts.size() > 0)
            return 'There might be an existing Wish Family. Please click on [OK] to review the existing record.';
        else if(dupAdditionalFamilyContacts.Size() > 0)
            return 'There might be an existing Additional Parent/Guardian. Please click on [OK] to review the existing record.'; 
        else if(dupBestContactPhysicians.Size() > 0)
            return 'There might be an existing Best Physician Contact. Please click on [OK] to review the existing record.';
        else return null;
    /* }
     
     catch(Exception ex){
         String recId = leadId;
         new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadWishFamilyDupe','FindFamilyContactDupe',recId,ex,Logvalue)); 
         return Label.Debug_log_error_message;
     }*/
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
        String Logvalue;
        Constant_Ac constant = new Constant_AC();
        String wishChild = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        
        try{
        List<Lead> leadList =  [SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c, 
                                Email, DOB__c ,Phone,chapterName__c,
                                City, State, Street, PostalCode, Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c,
                                Medical_Professional_Phone__c, Medical_Professional_Email__c, Treating_Medical_Professional_First_Name__c,
                                Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Phone__c, Treating_Medical_Professional_Email__c FROM Lead
                                WHERE id = :leadId AND isConverted = false limit 1];
        
        Logvalue = String.valueof(leadList);
        
        List<Lead> exLeads = [SELECT Id,LastName,Street,FirstName, Email, chapterName__c,Phone, DOB__c,
                              City,State,PostalCode FROM Lead 
                              WHERE (LastName = :leadList[0].LastName OR FirstName = :leadList[0].firstName OR DOB__c =:leadList[0].DOB__c
                                     OR Phone =:leadList[0].Phone OR Email =:leadList[0].Email OR (State =:leadList[0].State AND Postalcode =:leadList[0].PostalCode AND city =:leadList[0].City)) 
                              AND ChapterName__c =:leadList[0].ChapterName__c
                              AND Id != :leadList[0].id AND isConverted = false];
        
        
        List<Contact> exContacts = [SELECT Id, LastName,AccountId,MailingStreet,FirstName, Email, Phone, BirthDate,Region_Chapter__r.Name,
                                    MailingCity, MailingState, MailingPostalCode
                                    FROM Contact WHERE (LastName =:leadList[0].LastName OR FirstName =:leadList[0].firstName OR BirthDate =:leadList[0].DOB__c
                                                        OR ((MailingState =:leadList[0].State AND MailingPostalCode =:leadList[0].PostalCode AND MailingCity =:leadList[0].City) OR 
                                                            Phone =:leadList[0].Phone OR Email =:leadList[0].Email)) AND Region_Chapter__c =: leadList[0].ChapterName__c AND RecordTypeId = :wishChild];   
        
        
        for(Lead currLead : leadList)
        {
            
            for(Lead exLead : exLeads)
            {
                
                if(currLead.ChapterName__c == exLead.ChapterName__c)
                {
                    if(currLead.FirstName == exLead.FirstName && currLead.LastName == exLead.LastName)
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    } 
                    
                    else if((currLead.FirstName == exLead.FirstName || currLead.LastName == exLead.LastName) && 
                            ((currLead.Street == exLead.Street && currLead.State == exLead.State && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode) 
                             || currLead.Phone == exLead.Phone || currLead.Email == exLead.Email))
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                        
                    }
                    
                    else if((currLead.DOB__c == exLead.DOB__c) && 
                            ((currLead.Street == exLead.Street && currLead.State == exLead.State && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode) 
                             || currLead.Phone == exLead.Phone || currLead.Email == exLead.Email))
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    }
                    
                    else if((currLead.DOB__c == exLead.DOB__c) && (currLead.FirstName == exLead.FirstName || currLead.LastName == exLead.LastName))
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    }   
                    
                    
                }
            }
            
            for(Contact exCon : exContacts)
            {
                if(currLead.ChapterName__c == exCon.Region_Chapter__c)
                {
                    if(currLead.FirstName == exCon.FirstName && currLead.LastName == exCon.LastName)
                    { 
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    } 
                    
                    else if((currLead.FirstName == exCon.FirstName || currLead.LastName == exCon.LastName) && 
                            ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState && currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode) 
                             || currLead.Phone == exCon.Phone || currLead.Email == exCon.Email))
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    }
                    
                    else if((currLead.DOB__c == exCon.BirthDate) && 
                            ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState && currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode) 
                             || currLead.Phone == exCon.Phone || currLead.Email == exCon.Email))
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    }
                    
                    else if((currLead.DOB__c == exCon.BirthDate) && (currLead.FirstName == exCon.FirstName || currLead.LastName == exCon.LastName))
                    {
                        return 'There might be a duplicate Wish Child. Please click [OK] to review the duplicates.';
                    }   
                    
                    
                }
            }
        }                               
      }
      catch(Exception ex){
         String recId = leadId;
         new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadWishFamilyDupe','FindLeadDupe',recId,ex,Logvalue)); 
         return Label.Debug_log_error_message;
       }
        return null;
    } 
    
    webservice static String resetDVMedicalSummary(Id leadId) {
        String Logvalue;
        try{
        List<Lead> leadRec = [SELECT Id,Of_Times_Email_Sent__c, Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c, PD_Condition_Description__c, PD_ICD_Code__c, Part_A_Sent__c, Part_A_Received__c, Hidden_DV_form_Medical_professional_Type__c,  Sub_Status__c,Treating_Medical_Professional_Email__c,HiddenMedicalProfessionalEmail__c, Status, Part_A_Form_Password__c FROM Lead WHERE Id =: leadId LIMIT 1];
        Logvalue = String.valueOf(leadRec);
        leadRec[0].Sub_Status__c='Pending Diagnosis Verification';
        if( leadRec[0].Of_Times_Email_Sent__c == Null ) {
            leadRec[0].Of_Times_Email_Sent__c =  0;
        }
        leadRec[0].Pending_Diagnosis_Date__c = Date.today();//IME-77
        leadRec[0].PD_ICD_Code__c = leadRec[0].ICD_Given_By_Referrer__c;
        leadRec[0].PD_Condition_Description__c = leadRec[0].Diagnosis_Given_By_Referrer__c;
        leadRec[0].Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
        leadRec[0].HiddenMedicalProfessionalEmail__c = leadRec[0].Treating_Medical_Professional_Email__c;
        
        leadRec[0].Part_A_Form_Password__c = Lead_OnBeforeInsertTriggerHandler.getRandom();
        leadRec[0].Of_Times_Email_Sent__c= leadRec[0].Of_Times_Email_Sent__c + 1; 
        leadRec[0].MAW_Name__c = '';
        leadRec[0].Part_A_Received__c = null;
        leadRec[0].Part_A_Sent__c = Date.today();
        leadRec[0].I_am_Recognized_To_Practice_As_a__c = '';
        leadRec[0].I_m_Part_of_The_Treating_HealthCare_Team__c = '';
        leadRec[0].Is_in_a_Comatose_Vegetative_State__c = '';
        //leadRec[0].Communication__c = '';
        leadRec[0].Why_do_you_feel_would_be_eligible_Wish__c = '';
        leadRec[0].Is_We_Need_To_Expedite_The_Process__c = '';
        leadRec[0].Please_Explain__c = '';
        leadRec[0].Will_Child_s_Condition_Deteriorate__c = '';
        leadRec[0].Please_Explain_Deteriorate__c = '';
        leadRec[0].Provider_Signature__c = '';
        leadRec[0].Current_Condition_Label__c = '';
        //leadRec[0].Treatment_Subspecialty__c = '';
        leadRec[0].Provided_additional_information__c = '';
        leadRec[0].Current_Condition__c = '';
        leadRec[0].This_Statement_Describes_My_Patient__c = '';
        leadRec[0].Child_will_ultimately_die_prematurely__c = false;
        leadRec[0].Treatment_may_be_feasible_but_can_fail__c = false;
        leadRec[0].Treatment_may_prolong_normal_activities__c = false;
        leadRec[0].Debilitation_may_extend_over_many_years__c = false;
        leadRec[0].Increased_probability_of_premature_death__c = false;
        leadRec[0].Risk_of_complications_premature_death__c = false;
        leadRec[0].Responds_to_treatment_with_normal_health__c = false;
        leadRec[0].None_of_these_statements_describes_Child__c = false;
        leadRec[0].SD1_ICD_Code__c = null;
        leadRec[0].SD1_Condition_Description__c = '';
        leadRec[0].SD2_ICD_Code__c = null;
        leadRec[0].SD2_Condition_Description__c = '';
        leadRec[0].SD3_ICD_Code__c = null;
        leadRec[0].SD3_Condition_Description__c = '';
        leadRec[0].SD4_ICD_Code__c = null;
        leadRec[0].SD4_Condition_Description__c = '';
        leadRec[0].Current_Condition_label__c = '';
        leadRec[0].Chronic_Hepatitis__c = '';
        leadRec[0].Pulmonary_Hypertension__c = '';
        leadRec[0].Strokes__c = '';
        leadRec[0].Convulsive_Disorders__c = '';
        leadRec[0].Congenital_Heart_Disease__c = '';
        leadRec[0].Chronic_Heart_Failure__c = '';
        leadRec[0].Heart_Failure__c = '';
        leadRec[0].Arrhythmia__c = '';
        leadRec[0].Angina__c = '';
        leadRec[0].Ventilator__c = '';
        leadRec[0].lung_disease__c = '';
        leadRec[0].Current_Condition__c = '';
        leadRec[0].Travel_algorithm__c = '';
        leadRec[0].Current_Condition_Label__c = '';
        leadRec[0].isSign__c = false;
        leadRec[0].Status = 'Referred';
        leadRec[0].RFI_Form_Info_Hidden__c = leadRec[0].Status;
        //leadRec[0].Hidden_DV_form_Medical_professional_Type__c = '';
        update leadRec;
        DELETE[SELECT Id FROM Diagnosis_Verification__c WHERE Lead__c =: leadId];
        Map<Id, dsfs__DocuSign_Status__c> docusignDeleteList = new Map<Id, dsfs__DocuSign_Status__c>();
        for(dsfs__DocuSign_Status__c docusignRec : [SELECT Id, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Lead__c =: leadId]) {
            docusignDeleteList.put(docusignRec.Id, docusignRec);
        }
        List<Attachment> attachmentList = new List<Attachment>();
        for(Attachment attachment : [SELECT Id FROM Attachment WHERE ParentId IN : docusignDeleteList.keySet()]) {
            attachmentList.add(attachment);
        }
        List<Case> caseDVList = [SELECT Id, Lead__c FROM Case WHERE Lead__c =: leadId AND RecordType.Name = 'Diagnosis Verification Review'];
        if(caseDVList.size() > 0) {
           Delete caseDVList; 
        }
        if(attachmentList.size() > 0) {
            Delete attachmentList;
        }
        if(docusignDeleteList.size() > 0) {
            Delete docusignDeleteList.values();
        }
        List<Lead_File__c> leadFileList = new List<Lead_File__c>();
        for(Lead_File__c leadF : [SELECT Id FROM Lead_File__c WHERE Parent__c =: leadId AND Content_Type__c != 'Folder']) {
            leadFileList.add(leadF);
        }
        if(leadFileList.size() > 0) {
            Delete leadFileList; 
        }
      }
       catch(Exception ex){
         String recId = leadId;
         new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadWishFamilyDupe','resetDVMedicalSummary',recId,ex,Logvalue)); 
         return Label.Debug_log_error_message;
       }
        return null;
    }
    
}