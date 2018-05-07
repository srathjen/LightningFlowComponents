/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : Lead_OnAfterUpdateTriggerHandlerHelper is used to assign the case owner as a queue dynamically based on the lead state.And also if any duplicate records available in leads or contact then it displayed as a duplicate leads and contacts.
And also it is used to call the approval process automatically when the record is created. And also convert the lead automatically when approver 
approve the record.

Modification Log:
1. Vignesh SM - IME 58 Line No 395-409
1. 06/04/2018 - Vignesh SM - IME 9 - Line No. 1467-1480
2. 06/04/2018 - Yuvraj - IME-81 - Line No: 558-560
3. 12/04/2018 - Yuvraj - IME-86 - Line No: 134,327,764,783,1183-1185, 1120-1222, 1250-1252, 1287-1289, 1321-1323
*******************************************************************************************************************/

Public class Lead_OnAfterUpdateTriggerHandlerHelper{
    
    static Constant_AC  constant = new Constant_AC();
    static Id staffTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
    static Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    static Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    static Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    static Id organizationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.OrganizationRT).getRecordTypeId();
    static Id HouseholdRT=Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.HouseholdRT).getRecordTypeId();
    static Id parentwishRecTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    static Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();
    static Id DVCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    static Id chapterecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    static Id hospitalTreatMentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.hospitalTreatment).getRecordTypeId();
    
    public boolean falg = true;
    static Map<String,Account> newAccountMap = new Map<String,Account>();
    static Map<String,Account> medicalAccountMap = new Map<String,Account>();
    //    static Map<String,Boolean> qualifyingMap = new Map<String,Boolean>();
    List<Lead>convertedLeadList = new List<Lead>();
    static Map<Id,Lead> convertedLeadMap = new Map<Id,Lead>();
    static String convertedAccId;
    // static Savepoint sp = Database.setSavepoint();
    /**********************************************************************************************************
This onAfterUpdate() method is used to convert the lead when the lead status is "Qualyfied".
When the lead is converted it create a new wish child, wish family and medical proffecinal contact
while converting lead it aslo done dupe check for wish child, wish family and medical proffecinal contact
if any contact already exists then it create new relationship record. else it create contact record and 
aslo create new relationship record and it associate with wish child record.
***********************************************************************************************************/
    public static void leadConvertion(Map<Id,Lead> toconvertLeadMap){
        RecursiveTriggerHandler.isFirstTime = false;
        Constant_AC  constant = new Constant_AC();
        Map<Id,Id> leadContactMap = new Map<Id, Id>();
        Map<Id,Lead> convertedAccountMap = new Map<Id,Lead>();
        List<Account> updateAcccountList = new List<Account>();
        Map<id,Contact> conMap = new Map<Id,Contact>();
        Map<Id,Lead> LeadMap = new Map<id,Lead>();
        Map<Id,Lead> leadFamilyMap = new Map<Id,Lead>();
        Set<Id> convertedLeadIds = new Set<Id>();
        set<Id> conId = new set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Case>caseList = new List<Case>();
        Map<Id,Case> insertCaseMap = new Map<Id,Case>();
        List<cg__ContactFile__c> ConFileList = new List<cg__ContactFile__c>();
        List<npe4__Relationship__c> wishFamilyRelationList = new List<npe4__Relationship__c>();
        List<Contact> siblingList = new List<Contact>();
        LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        List<Case> partACaseList = new List<Case>();
        List<dsfs__DocuSign_Status__c > dsfsList = new List<dsfs__DocuSign_Status__c>();
        Set<String> leadFamilyFirstNameSet = new Set<String>();
        Set<String> leadFamilyLastNameSet = new Set<String>();
        Set<String> leadFamilyEmailSet = new Set<String>();
        Set<String> leadFamilyPhoneSet = new Set<String>();
        Set<Id> chapterIdSet = new Set<Id>();
        set<Id> leadIdSet = new Set<Id>();
        List<npe4__Relationship__c> relationShipList = new List<npe4__Relationship__c>();
        Map<Id,Account> chapterUserMap = new Map<Id,Account>();
        Map<String,Contact> contactFamilyNameMap = new Map<String,Contact>();
        Map<String,Contact> contactFamilyEmailMap = new Map<String,Contact>();
        Map<String,Contact> contactFamilyPhoneMap = new Map<String,Contact>();
        Map<String,Contact> contactFamilyAddressMap = new Map<String,Contact>();
        List<Task> rushReminderList = new List<Task>();
        Map<Id,Lead> existingMedicalProfIdMap = new Map<Id,Lead>();
        Id ChapterId;
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Id wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
        //sp = Database.setSavepoint();
        try{
            for(Lead processNewLeads: toconvertLeadMap.values()){
                
                Database.LeadConvert lc = new Database.LeadConvert();
                LeadMap.put(processNewLeads.Id,processNewLeads);
                lc.setLeadId(processNewLeads.Id);
                lc.setDoNotCreateOpportunity(true); 
                lc.setConvertedStatus(convertStatus.MasterLabel);
                leadConverts.add(lc);
            }
            System.debug('Lead Convertion start1:');
            if (!leadConverts.isEmpty()) {
                List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
                for(Database.LeadConvertResult convertLeads :lcr){
                    leadContactMap.put(convertLeads.getLeadId(),convertLeads.getContactId());
                    accountIds.add(convertLeads.getAccountId());
                    conId.add(convertLeads.getContactId());
                    convertedLeadIds.add(convertLeads.getLeadId());
                }
                if(leadContactMap.size() > 0) {
                    List<Diagnosis_Verification__c> diagnosisList = new List<Diagnosis_Verification__c>();
                    for(Diagnosis_Verification__c diagnosisInfo : [SELECT Id, Contact__c, Lead__c FROM Diagnosis_Verification__c WHERE Lead__c IN : leadContactMap.keySet() Limit 50000]) {
                        diagnosisInfo.Contact__c = leadContactMap.get(diagnosisInfo.Lead__c);
                        diagnosisList.add(diagnosisInfo);
                    }
                    if(diagnosisList.size() > 0) {
                        update diagnosisList;
                    }
                    updateDocusignStatus(leadContactMap);
                }
                for(Lead convertedLeads : [SELECT Id,Name,DOB__c,FirstName, Why_do_you_feel_would_be_eligible_Wish__c, LastName,createdDate,Migrated_Record__c,I_am_Recognized_To_Practice_As_a__c,Sibling_Detail__c,Medical_Provider_Category__c,ChapterName__r.Name,ChapterName__c,Treating_Medical_Professional_First_Name__c,ConvertedContactId,ConvertedAccountId,
                                           Other_Relationship_To_Child__c,Relationship_to_child__c,LeadSource,Treating_Medical_Professional_Phone__c,Treating_Medical_Professional_Email__c,
                                           is_Family_Aware_of_Referral__c,Treating_Medical_Professional_Last_Name__c,Referrer_City__c,
                                           Referrer_Email__c,Referrer_FirstName__c,Referrer_Last_Name__c,Referrer_Phone__c,Referrer_Zip__c,
                                           Parent_First_Name__c,Alternate1MedProfessionalPhone__c,Alternate1MedicalProfessionalEmail__c,
                                           Alternate1MedProfessionalFirstName__c,Alternate1MedProfessionalLastName__c,What_is_the_family_s_primary_spoken_lang__c,Parent_Last_Name__c,Email,
                                           Phone,City,Alternate2MedProfessionalFirstName__c,Alternate2MedProfessionalEmail__c,
                                           Alternate2MedProfessionalLastName__c,Alternate2MedProfessionalPhone__c,
                                           CountryCode,PostalCode,StateCode,Street,Treating_Medical_Professional_Contact_Id__c,
                                           Medical_Professional_ContactId__c,Wish_Family_ContactId__c,Best_contact_for_Physician_Email__c,
                                           Best_Contact_for_Physician_First_Name__c,Best_Contact_for_Physician_Last_Name__c,
                                           Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,Additional_Parent_City__c,
                                           Additional_Parent_Email__c,Additional_Parent_Phone__c,Additional_Parent_Postal_Code__c,
                                           Additional_Parent_State__c,Additional_Parent_Street__c,Hidden_Additional_Parent_Id__c,
                                           Hidden_Best_Contact_Person_Id__c,Parent_Relationship_to_Child__c,HiddenAlternate1MedProfessionalId__c,
                                           HiddenAlternate2MedProfessionalId__c,Self_describe_comment_box__c,Child_Age__c,Gender__c,Hidden_DV_form_Medical_professional_Type__c,
                                           Additional_Parent_Relationship_to_Child__c,How_Did_you_hear_about_Make_A_Wish__c,Other_Medical_Provider_Category__c,
                                           Any_medical_reason_for_moving_quickly__c, Department__c
                                           FROM Lead WHERE Id IN: convertedLeadIds Limit 50000])
                {   
                    system.debug('@@@@@@@@@ convertedLeads.ConvertedContactId @@@@@@@@@@@@'+convertedLeads.ConvertedContactId);
                    if(convertedLeadIds.contains(convertedLeads.Id)){
                        leadFamilyMap.put(convertedLeads.Id,convertedLeads);
                        convertedLeadMap.put(convertedLeads.ConvertedContactId,convertedLeads);
                        convertedAccountMap.put(convertedLeads.ConvertedAccountId,convertedLeads);
                        chapterIdSet.add(convertedLeads.ChapterName__c);
                        leadFamilyFirstNameSet.add(convertedLeads.FirstName);
                        leadFamilyLastNameSet.add(convertedLeads.LastName);
                        leadFamilyEmailSet.add(convertedLeads.Email);
                        leadFamilyPhoneSet.add(convertedLeads.Phone);
                        if(convertedLeads.Treating_Medical_Professional_Contact_Id__c != Null){
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                            newRelationShip.npe4__Type__c = 'Medical Professional';
                            If(convertedLeads.Treating_Medical_Professional_First_Name__c == convertedLeads.Referrer_FirstName__c
                               && convertedLeads.Treating_Medical_Professional_Last_Name__c == convertedLeads.Referrer_Last_Name__c && 
                               (convertedLeads.Treating_Medical_Professional_Phone__c == convertedLeads.Referrer_Phone__c 
                                || convertedLeads.Treating_Medical_Professional_Email__c == convertedLeads.Referrer_Email__c)){
                                    newRelationShip.Referring_Medical_Professional__c = true;
                                }
                            If(convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Treating Medical Professional')
                                newRelationShip.Qualifying_Medical_Professional__c = True;
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.Treating_Medical_Professional_Contact_Id__c;
                            newRelationShip.npe4__Status__c = 'Active';
                            newRelationShip.Treating_HCP__c = True;
                            relationShipList.add(newRelationShip);
                            system.debug('@@@@@@ newRelationShip @@@@@@@@'+relationShipList);
                            if(convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Best contact for Physician' || convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Treating Medical Professional')
                                existingMedicalProfIdMap.put(convertedLeads.Treating_Medical_Professional_Contact_Id__c,convertedLeads);
                        }
                        else{
                            leadIdSet.add(convertedLeads.Id);
                        }
                        if(convertedLeads.Medical_Professional_ContactId__c != Null ){
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;                                               
                            newRelationShip.npe4__Type__c = 'Medical Professional';
                            newRelationShip.Referring_Medical_Professional__c = true;
                            If(convertedLeads.Treating_Medical_Professional_First_Name__c == convertedLeads.Referrer_FirstName__c
                               && convertedLeads.Treating_Medical_Professional_Last_Name__c == convertedLeads.Referrer_Last_Name__c && 
                               (convertedLeads.Treating_Medical_Professional_Phone__c == convertedLeads.Referrer_Phone__c 
                                || convertedLeads.Treating_Medical_Professional_Email__c == convertedLeads.Referrer_Email__c)){
                                    
                                    newRelationShip.Treating_HCP__c = True;
                                    If(convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Treating Medical Professional')
                                        newRelationShip.Qualifying_Medical_Professional__c = True; 
                                }
                            
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.Medical_Professional_ContactId__c ;
                            newRelationShip.npe4__Status__c = 'Active';
                            relationShipList.add(newRelationShip);
                            system.debug('@@@@@@ newRelationShip1 @@@@@@@@'+relationShipList);
                            existingMedicalProfIdMap.put(convertedLeads.Medical_Professional_ContactId__c ,convertedLeads);
                        }
                        else{
                            leadIdSet.add(convertedLeads.Id);
                        }
                        if(convertedLeads.HiddenAlternate1MedProfessionalId__c != Null ){
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;                                               
                            newRelationShip.npe4__Type__c = 'Medical Professional';                    
                            
                            If(convertedLeads.Alternate1MedProfessionalFirstName__c == convertedLeads.Referrer_FirstName__c
                               && convertedLeads.Alternate1MedProfessionalLastName__c == convertedLeads.Referrer_Last_Name__c && 
                               (convertedLeads.Alternate1MedProfessionalPhone__c == convertedLeads.Referrer_Phone__c 
                                || convertedLeads.Alternate1MedicalProfessionalEmail__c == convertedLeads.Referrer_Email__c)){
                                    
                                    newRelationShip.Referring_Medical_Professional__c = true;
                                }    
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.HiddenAlternate1MedProfessionalId__c ;
                            newRelationShip.npe4__Status__c = 'Active';                    
                            system.debug('@@@@@@ newRelationShip1 @@@@@@@@'+relationShipList);
                            if( convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Alternate 1 Medical Professional'){
                                existingMedicalProfIdMap.put(convertedLeads.HiddenAlternate1MedProfessionalId__c ,convertedLeads);
                                newRelationShip.Qualifying_Medical_Professional__c = True; 
                            }
                            relationShipList.add(newRelationShip);
                        }
                        else{
                            leadIdSet.add(convertedLeads.Id);
                        }
                        if(convertedLeads.HiddenAlternate2MedProfessionalId__c != Null ){
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;                                               
                            newRelationShip.npe4__Type__c = 'Medical Professional';                    
                            // newRelationShip.Referring_Medical_Professional__c = true;
                            If(convertedLeads.Alternate2MedProfessionalFirstName__c == convertedLeads.Referrer_FirstName__c
                               && convertedLeads.Alternate2MedProfessionalLastName__c == convertedLeads.Referrer_Last_Name__c && 
                               (convertedLeads.Alternate2MedProfessionalPhone__c == convertedLeads.Referrer_Phone__c 
                                || convertedLeads.Alternate2MedProfessionalEmail__c == convertedLeads.Referrer_Email__c)){
                                    
                                    newRelationShip.Referring_Medical_Professional__c = True; 
                                }
                            
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.HiddenAlternate2MedProfessionalId__c ;
                            newRelationShip.npe4__Status__c = 'Active';                    
                            system.debug('@@@@@@ newRelationShip2 @@@@@@@@'+relationShipList);
                            if( convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Alternate 2 Medical Professional'){
                                existingMedicalProfIdMap.put(convertedLeads.HiddenAlternate2MedProfessionalId__c,convertedLeads);
                                newRelationShip.Qualifying_Medical_Professional__c = True; 
                            }
                            relationShipList.add(newRelationShip);
                        }
                        else{
                            leadIdSet.add(convertedLeads.Id);
                        }
                        if(convertedLeads.Wish_Family_ContactId__c != Null){
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                            newRelationShip.npe4__Type__c = convertedLeads.Parent_Relationship_to_Child__c;
                            newRelationShip.Hidden_isparentFirst__c = True;
                            newRelationShip.Parent_Legal_Guardian__c = True;
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.Wish_Family_ContactId__c;
                            newRelationShip.npe4__Status__c = 'Active';
                            if(ConvertedLeads.Relationship_to_Child__c == 'Parent/Guardian')
                                newRelationShip.Referring_Medical_Professional__c=True;
                            relationShipList.add(newRelationShip);
                            system.debug('@@@@@@ newRelationShip3 @@@@@@@@'+relationShipList);
                        }
                        else{
                            leadIdSet.add(convertedLeads.Id);
                        }
                        if(convertedLeads.Hidden_Additional_Parent_Id__c!= Null){
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                            newRelationShip.Hidden_isparentFirst__c = false;
                            newRelationShip.Parent_Legal_Guardian__c = True;
                            newRelationShip.npe4__Type__c = convertedLeads.Additional_Parent_Relationship_to_Child__c;
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.Hidden_Additional_Parent_Id__c;
                            newRelationShip.npe4__Status__c = 'Active';
                            relationShipList.add(newRelationShip);
                        }
                        else{
                            leadIdSet.add(convertedLeads.Id);
                        }
                        if(convertedLeads.Hidden_Best_Contact_Person_Id__c!= Null)
                        {
                            npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                            newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                            newRelationShip.npe4__Type__c = 'Medical Professional';
                            newRelationShip.npe4__RelatedContact__c = convertedLeads.Hidden_Best_Contact_Person_Id__c;
                            newRelationShip.npe4__Status__c = 'Active';
                            newRelationShip.Best_Contact__c = True;
                            if(convertedLeads.Best_Contact_for_Physician_First_Name__c == convertedLeads.Referrer_FirstName__c
                               && convertedLeads.Best_Contact_for_Physician_Last_Name__c == convertedLeads.Referrer_Last_Name__c && 
                               (convertedLeads.Best_contact_for_Physician_Email__c == convertedLeads.Referrer_Email__c))
                            {
                                newRelationShip.Referring_Medical_Professional__c = true;
                            }
                            if(convertedLeads.Treating_Medical_Professional_First_Name__c == convertedLeads.Best_Contact_for_Physician_First_Name__c
                               && convertedLeads.Treating_Medical_Professional_Last_Name__c == convertedLeads.Best_Contact_for_Physician_Last_Name__c && 
                               (convertedLeads.Treating_Medical_Professional_Email__c == convertedLeads.Best_contact_for_Physician_Email__c)){
                                   newRelationShip.Treating_HCP__c = True;
                               }
                            if(convertedLeads.Hidden_DV_form_Medical_professional_Type__c == 'Best contact for Physician')
                                newRelationShip.Qualifying_Medical_Professional__c = True;
                            
                            relationShipList.add(newRelationShip);
                            system.debug('@@@@@@ newRelationShip3 @@@@@@@@'+relationShipList);
                        }
                        else
                        {
                            leadIdSet.add(convertedLeads.Id);
                        }
                    }
                }
                
                if(accountIds.size() > 0){
                    for(Account conAccount : [SELECT Id,Name,Volunteer_Manager__c,Intake_Manager__c,Volunteer_Manager__r.Name,Volunteer_Manager__r.Email,
                                              RecordTypeId FROM Account Where Id IN: accountIds Limit 50000]){
                        if(chapterIdSet.contains(conAccount.Id)){
                            ChapterId = conAccount.Id;
                            chapterUserMap.put(conAccount.Id,conAccount);
                        }
                        if(convertedAccountMap.containsKey(conAccount.Id)){
                            if(convertedAccountMap.get(conAccount.Id).FirstName == Null){
                                conAccount.Name = convertedAccountMap.get(conAccount.Id).LastName + ' '+ ' & '+' ' +'Family Household';
                                conAccount.RecordTypeId=HouseholdRT;
                                conAccount.PrimaryLanguage__c = convertedAccountMap.get(conAccount .Id).What_is_the_family_s_primary_spoken_lang__c;
                            }
                            else{
                                conAccount.Name = convertedAccountMap.get(conAccount.Id).FirstName + ' ' +convertedAccountMap.get(conAccount.Id).LastName + ' '+ ' & '+' ' +'Family Household';
                                conAccount.PrimaryLanguage__c = convertedAccountMap.get(conAccount .Id).What_is_the_family_s_primary_spoken_lang__c;
                                conAccount.RecordTypeId=HouseholdRT;
                            }
                            updateAcccountList.add(conAccount );
                        }
                    }
                }
                List<cg__ContactFile__c> ContactFileFolders = new List<cg__ContactFile__c>();
                for(contact con : [SELECT Id,FirstName,Birthdate,Department,Provider_Type__c ,Language__c,
                                   Self_describe_comment_box__c,Migrated_Record__C,Lead_Created_Date__c,Relationship_to_Wish_Child__c,
                                   Referrer_FirstName__c,Referrer_Last_Name__c,Referrer_Phone__c,Referrer_Email__c,Referrer_City__c,Referrer_Zip__c,
                                   Relationship__c,Inquiry_Referral_Method__c,Is_Family_Aware_of_Referral__c,Parent_Guardian_Name__c,RecordTypeId,AccountId,
                                   LastName,MailingCity,OwnerId,MailingState,MailingPostalCode,Wish_How_Did_you_hear_about_Make_A_Wish__c,
                                   Other_Medical_Provider_Category__c FROM Contact WHERE Id in:conId Limit 50000]){
                    IF(convertedLeadMap.containsKey(con.Id)){
                        con.Lead_Created_Date__c = Date.valueOf(convertedLeadMap.get(con.Id).createdDate);
                        con.Birthdate = convertedLeadMap.get(con.Id).DOB__c;
                        con.RecordTypeId = wishChildRecordTypeId;
                        con.Provider_Type__c =convertedLeadMap.get(con.Id).Medical_Provider_Category__c;
                        con.Self_describe_comment_box__c = convertedLeadMap.get(con.Id).Self_describe_comment_box__c;
                        con.Language__c = convertedLeadMap.get(con.Id).What_is_the_family_s_primary_spoken_lang__c;
                        con.Region_Chapter__c =  convertedLeadMap.get(con.Id).ChapterName__c;
                        con.Inquiry_Referral_Method__c =convertedLeadMap.get(con.Id).Leadsource;
                        con.Referrer_City__c =convertedLeadMap.get(con.Id).Referrer_City__c;
                        con.Referrer_Email__c =convertedLeadMap.get(con.Id).Referrer_Email__c;
                        con.Referrer_FirstName__c =convertedLeadMap.get(con.Id).Referrer_FirstName__c;
                        con.Referrer_Last_Name__c =convertedLeadMap.get(con.Id).Referrer_Last_Name__c;   
                        con.Referrer_Phone__c =convertedLeadMap.get(con.Id).Referrer_Phone__c;
                        con.Referrer_Zip__c =convertedLeadMap.get(con.Id).Referrer_Zip__c;
                        con.Relationship__c =convertedLeadMap.get(con.Id).Relationship_to_child__c;
                        con.Other_Medical_Provider_Category__c =convertedLeadMap.get(con.Id).Other_Medical_Provider_Category__c;
                        con.Relationship_to_Wish_Child__c=convertedLeadMap.get(con.Id).Other_Relationship_To_Child__c;
                        con.Is_Family_Aware_of_Referral__c =convertedLeadMap.get(con.Id).Is_Family_Aware_of_Referral__c;
                        con.migrated_Record__c = convertedLeadMap.get(con.Id).migrated_record__c;
                        con.Wish_How_Did_you_hear_about_Make_A_Wish__c = convertedLeadMap.get(con.Id).How_Did_you_hear_about_Make_A_Wish__c;
                        con.Relationship_Type__c = 'Wish Child';
                        if (convertedLeadMap.get(con.Id).DOB__c != Null){
                            Date dob = convertedLeadMap.get(con.Id).DOB__c;
                            Integer age; 
                            If(Date.newInstance(2000 , dob.Month(), dob.Day() ) <= Date.newInstance( 2000 , Date.TODAY().Month() , Date.TODAY().Day())){
                                age = Date.Today().Year() - dob.Year();
                            }
                            else
                                age = Date.Today().Year() - dob.Year() -1;                    
                            if((age < 16) && convertedLeadMap.get(con.Id).Gender__c == 'Male')
                                con.Salutation = 'Master';
                            else if((age  >= 16 ) && convertedLeadMap.get(con.Id).Gender__c == 'Male')
                                con.Salutation = 'Mr.';
                            else if((age  < 16 ) && convertedLeadMap.get(con.Id).Gender__c == 'Female')
                                con.Salutation = 'Miss';
                            else if( (age >=16 ) && convertedLeadMap.get(con.Id).Gender__c == 'Female')
                                con.Salutation = 'Ms.';
                            else
                                con.Salutation = '';
                        }
                        con.Hidden_Medical_Physician__c = convertedLeadMap.get(con.Id).Treating_Medical_Professional_First_Name__c+' '+convertedLeadMap.get(con.Id).Treating_Medical_Professional_Last_Name__c;
                        conMap.put(con.Id,con);
                        cg__ContactFile__c picFolder =new cg__ContactFile__c();
                        picFolder.cg__Contact__c = con.Id;
                        picFolder.cg__Content_Type__c = 'Folder';
                        picFolder.cg__File_Name__c = 'Photos';
                        picFolder.cg__WIP__c = false;
                        ContactFileFolders.add(picFolder);
                        
                        cg__ContactFile__c docFolder =new cg__ContactFile__c();
                        docFolder.cg__Contact__c = con.Id;
                        docFolder.cg__Content_Type__c = 'Folder';
                        docFolder.cg__File_Name__c = 'Documents';
                        docFolder.cg__WIP__c = false;
                        ContactFileFolders.add(docFolder);
                        
                        cg__ContactFile__c videosFolder =new cg__ContactFile__c();
                        videosFolder.cg__Contact__c = con.Id;
                        videosFolder.cg__Content_Type__c = 'Folder';
                        videosFolder.cg__File_Name__c = 'Videos';
                        videosFolder.cg__WIP__c = false;
                        ContactFileFolders.add(videosFolder);  
                        
                        Task newTask = new Task();
                        newTask.OwnerId = con.OwnerId;
                        newTask.SystemGeneratedTask__c = True;
                        newTask.Subject = 'Send Welcome Letter/Make Welcome Call';
                        newTask.WhoId = con.Id;
                        newTask.Description = 'Send Welcome Letter/Make Welcome Call';
                        newTask.Status = 'In Progress';
                        newTask.ActivityDate = system.today() + 10;
                        newTask.RecordTypeId = staffTaskRT;
                        rushReminderList.add(newTask); 
                        
                        //IME 58
                        string medicalReason = convertedLeadMap.get(con.Id).Any_medical_reason_for_moving_quickly__c;
                        if (medicalReason.contains('Yes')){                        
                            Task newRushTask = new Task(Description = 'New RUSH referral qualified',
                                                        Priority = 'Normal', 
                                                        Status = 'Completed',
                                                        Subject = 'Lead ET : New Rush Qualified', 
                                                        OwnerId =  label.Salesforce_Support_User_Id,
                                                        ActivityDate = System.today(),
                                                        WhoId = con.Id);                            
                            rushReminderList.add(newRushTask); 
                        }                          
                    }
                }
                for(Database.LeadConvertResult convertLeads :lcr){
                    if(leadFamilyMap.containsKey(convertLeads.getLeadId())){
                        if(leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c != Null){
                            if(leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.contains('<br>')){
                                for(String currsiblings : leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.split('<br>')){
                                    if(currsiblings.contains('|') ){
                                        List<String>siblingdetails = currsiblings.split('\\|');
                                        if(siblingdetails.size() == 3){
                                            Contact newFamily = new Contact();
                                            newFamily.FirstName = siblingdetails [0].trim();
                                            newFamily.lastName = siblingdetails [1].trim();
                                            newFamily.Sibling_Age__c = siblingdetails [2].trim();
                                            newFamily.Wish_Child_Id_Hidden__c = convertLeads.getcontactId();
                                            newFamily.RecordTypeId = wishFamilyRecordTypeId;
                                            newFamily.AccountId = convertLeads.getAccountId();
                                            newFamily.Region_Chapter__c = leadFamilyMap.get(convertLeads.getLeadId()).ChapterName__c;
                                            newFamily.Language__c = leadFamilyMap.get(convertLeads.getLeadId()).What_is_the_family_s_primary_spoken_lang__c;
                                            if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.isNumeric()){
                                                siblingList.add(newFamily);
                                            }
                                            if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && newFamily.LastName.containsOnly('-') && newFamily.Sibling_Age__c.isNumeric()){
                                                newFamily.LastName = 'Unknown';
                                                siblingList.add(newFamily);
                                            }
                                            if(newFamily.FirstName.containsOnly('-') && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.isNumeric()){
                                                newFamily.FirstName = '';
                                                siblingList.add(newFamily);
                                            }
                                            if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.containsOnly('-')){
                                                newFamily.Sibling_Age__c = Null;
                                                siblingList.add(newFamily);
                                            }
                                            if(newFamily.FirstName.containsOnly('-') && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.containsOnly('-')){
                                                newFamily.FirstName = '';
                                                newFamily.Sibling_Age__c = Null;
                                                siblingList.add(newFamily);
                                            }
                                            if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && newFamily.LastName.containsOnly('-')  && newFamily.Sibling_Age__c.containsOnly('-')){
                                                newFamily.LastName = 'Unknown';
                                                newFamily.Sibling_Age__c = Null;
                                                siblingList.add(newFamily);
                                            }
                                        }
                                    }
                                }
                            }
                            else if(leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.contains('|')){
                                list<String> siblingdetails = leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.split('\\|');
                                if(siblingdetails .size() == 3){
                                    Contact newFamily = new Contact();
                                    newFamily.FirstName = siblingdetails [0].trim();
                                    newFamily.lastName = siblingdetails [1].trim();
                                    newFamily.Sibling_Age__c = siblingdetails[2].trim();
                                    newFamily.Wish_Child_Id_Hidden__c = convertLeads.getcontactId();
                                    newFamily.RecordTypeId = wishFamilyRecordTypeId;
                                    newFamily.AccountId = convertLeads.getAccountId();
                                    newFamily.Region_Chapter__c = leadFamilyMap.get(convertLeads.getLeadId()).ChapterName__c;
                                    newFamily.Language__c = leadFamilyMap.get(convertLeads.getLeadId()).What_is_the_family_s_primary_spoken_lang__c;
                                    if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.isNumeric()){
                                        siblingList.add(newFamily);
                                    }
                                    if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && newFamily.LastName.containsOnly('-') && newFamily.Sibling_Age__c.isNumeric()){
                                        newFamily.LastName = 'Unknown';
                                        siblingList.add(newFamily);
                                    }
                                    if(newFamily.FirstName.containsOnly('-') && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.isNumeric()){
                                        newFamily.FirstName = '';
                                        siblingList.add(newFamily);
                                    }
                                    if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.containsOnly('-')){
                                        newFamily.Sibling_Age__c = Null;
                                        siblingList.add(newFamily);
                                    }
                                    if(newFamily.FirstName.containsOnly('-') && (!newFamily.LastName.containsOnly('-') && newFamily.LastName != Null) && newFamily.Sibling_Age__c.containsOnly('-')){
                                        newFamily.FirstName = '';
                                        newFamily.Sibling_Age__c = Null;
                                        siblingList.add(newFamily);
                                    }
                                    if((!newFamily.FirstName.containsOnly('-') && newFamily.FirstName != Null) && newFamily.LastName.containsOnly('-')  && newFamily.Sibling_Age__c.containsOnly('-')){
                                        newFamily.LastName = 'Unknown';
                                        newFamily.Sibling_Age__c = Null;
                                        siblingList.add(newFamily);
                                    }
                                }
                            }
                        }
                    }
                    if(LeadMap.containsKey(convertLeads.getLeadId())) {
                        case newcase = new case();
                        newcase .RecordTypeId = parentwishRecTypeId;
                        newcase.contactId = convertLeads.getcontactId();
                        newCase.Hidden_Lead_Id__c = convertLeads.getLeadId();
                        newCase.Qualified_Date__c= System.today();
                        newCase.Migrated_Record__c = LeadMap.get(convertLeads.getLeadId()).Migrated_Record__c; 
                        newCase.Qualifying_Medical_Professional_Name__c=LeadMap.get(convertLeads.getLeadId()).Treating_Medical_Professional_First_Name__c +' '+LeadMap.get(convertLeads.getLeadId()).Treating_Medical_Professional_Last_Name__c;
                        newcase.Qualifying_Medical_Professional_Email__c=LeadMap.get(convertLeads.getLeadId()).Treating_Medical_Professional_Email__c;
                        if(conMap.containsKey(convertLeads.getcontactId()))
                        {
                            newcase.ownerId = conMap.get(convertLeads.getcontactId()).ownerId;
                            newCase.ChapterName__c = LeadMap.get(convertLeads.getLeadId()).chapterName__c;
                            newCase.Hidden_Primary_Diagnosis__c = LeadMap.get(convertLeads.getLeadId()).PD_Condition_Description__c ;
                        }
                        newcase.AccountId = convertLeads.getAccountId();
                        Date myDate = Date.ValueOf( LeadMap.get(convertLeads.getLeadId()).CreatedDate);
                        String dateval = String.valueof(myDate);
                        if(LeadMap.get(convertLeads.getLeadId()).FirstName != NULL){
                            newcase.Subject = LeadMap.get(convertLeads.getLeadId()).FirstName + ' ' + LeadMap.get(convertLeads.getLeadId()).LastName;
                        }
                        else{
                            newcase.Subject = LeadMap.get(convertLeads.getLeadId()).LastName;
                        }
                        if(chapterUserMap.size() > 0){
                            if(chapterUserMap.get(ChapterId).Volunteer_Manager__r.Name != Null && chapterUserMap.get(ChapterId).Volunteer_Manager__r.Email != Null){
                                newcase.VOlunteer_Manager_Name__c = chapterUserMap.get(ChapterId).Volunteer_Manager__r.Name;
                                newcase.Volunteer_Manager_Email__c =chapterUserMap.get(ChapterId).Volunteer_Manager__r.Email;
                            }
                            if(chapterUserMap.get(ChapterId).Intake_Manager__c != Null)
                            { 
                                newCase.OwnerId = chapterUserMap.get(ChapterId).Intake_Manager__c;
                            }
                        }
                        newcase.Status = 'Qualified';
                        newcase.Hidden_Why_do_you_feel__c = LeadMap.get(convertLeads.getLeadId()).Why_do_you_feel_would_be_eligible_Wish__c;
                        newcase.Origin = 'Web';
                        if(LeadMap.get(convertLeads.getLeadId()).Is_We_Need_To_Expedite_The_Process__c == 'Yes') {
                            newCase.Rush__c = true;
                            newCase.Rush_Explanation__c = LeadMap.get(convertLeads.getLeadId()).Please_Explain__c;
                            newCase.Rush_Timeframe__c = 'Select timeframe';
                        }
                        if(LeadMap.get(convertLeads.getLeadId()).Referred_Date__c != null)
                            newCase.Referral_Date__c = LeadMap.get(convertLeads.getLeadId()).Referred_Date__c;
                        if(LeadMap.get(convertLeads.getLeadId()).Inquiry_Date__c!= null)
                            newCase.Inquiry_Date__c= LeadMap.get(convertLeads.getLeadId()).Inquiry_Date__c;
                        newCase.Diagnosis_Verification_Receive_Date__c = LeadMap.get(convertLeads.getLeadId()).Part_A_Received__c;
                        newCase.Diagnosis_Verification_Sent_Date__c = LeadMap.get(convertLeads.getLeadId()).Part_A_Sent__c;
                        //IME-81
                        if(LeadMap.get(convertLeads.getLeadId()).Out_of_Territory__c != null){
                            newCase.Out_of_Territory__c = LeadMap.get(convertLeads.getLeadId()).Out_of_Territory__c;
                        }
                        if(LeadMap.get(convertLeads.getLeadId()).unique_wish_identifier__c!= null) {
                            newcase.Lead__c = LeadMap.get(convertLeads.getLeadId()).Id;
                            newcase.Unique_Wish_Record_Identifier__c= LeadMap.get(convertLeads.getLeadId()).unique_wish_identifier__c;
                            newcase.Fund_Id__c = LeadMap.get(convertLeads.getLeadId()).unique_wish_identifier__c;
                            newcase.UWISource__c = 'Lead';
                            newcase.Wish_Assist__c= true;
                        }
                        caseList.add(newcase);
                        insertCaseMap.put(convertLeads.getLeadId(),newCase);
                    }
                }
                for(Case dbPartAcase : [SELECT Id,CaseNumber,Lead__c,ContactId,RecordTypeId FROM Case WHERE Lead__c IN:convertedLeadIds AND RecordTypeId =: partARecordTypeId Limit 50000]){
                    if(leadFamilyMap.containsKey(dbPartAcase.Lead__c)){
                        dbPartAcase.ContactId = leadFamilyMap.get(dbPartAcase.Lead__c).ConvertedContactId;
                        partACaseList.add(dbPartAcase);                    
                    }
                    if(insertCaseMap.containsKey(dbPartAcase.Lead__c)){
                        case rushCase = new Case();
                        rushCase = insertCaseMap.get(dbPartAcase.Lead__c);
                        if(rushCase.Rush__c  == True)
                            rushCase.Hidden_already_send_rush_wish__c = True;
                        insertCaseMap.put(dbPartAcase.Lead__c,rushCase);
                    }   
                }
                if(convertedLeadIds.size() > 0){
                    for(dsfs__DocuSign_Status__c dbdsfsLead : [SELECT Id,dsfs__Lead__c,dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c  WHERE dsfs__Lead__c IN: convertedLeadIds AND dsfs__Envelope_Status__c =: 'Completed']){
                        if(leadFamilyMap .containsKey(dbdsfsLead.dsfs__Lead__c)){
                            dbdsfsLead.dsfs__Contact__c = leadFamilyMap.get(dbdsfsLead.dsfs__Lead__c).ConvertedContactId;
                            dsfsList.add(dbdsfsLead );
                        }
                    }
                }
                if(ContactFileFolders.size() > 0)
                {
                    insert  ContactFileFolders;
                }
                Map<Id, Id> docFolderContactsMAP = new Map<Id, Id>();
                for(cg__ContactFile__c contactFile: [SELECT Id, cg__Contact__c from cg__ContactFile__c where cg__File_Name__c =: 'Documents' and cg__Contact__c in: conId]){
                    docFolderContactsMAP.put(contactFile.cg__Contact__c, contactFile.Id);                                              
                }                                                
                for(Lead_File__c leadFile: [SELECT Id, Content_Type__c, Description__c, File_Name__c, File_Size__c,
                                            Is_Latest_Version__c, Key__c, Parent__c, Parent_Folder_Id__c, Private__c, Version_Description__c,
                                            Version_Id__c, WIP__c from Lead_File__c where Parent__c in: convertedLeadIds Limit 50000]){
                                                cg__ContactFile__c cFile=new cg__ContactFile__c();
                                                cFile.cg__Contact__c = leadFamilyMap.get(leadFile.Parent__c).ConvertedContactId;
                                                cFile.cg__Content_Type__c = leadFile.Content_Type__c;
                                                cFile.cg__Description__c = leadFile.Description__c;
                                                cFile.cg__File_Name__c = leadFile.File_Name__c;
                                                cFile.cg__Is_Latest_Version__c =  leadFile.Is_Latest_Version__c;
                                                cFile.cg__Key__c = leadFile.Key__c;
                                                cFile.cg__Parent_Folder_Id__c = docFolderContactsMAP.get(leadFamilyMap.get(leadFile.Parent__c).ConvertedContactId);
                                                cFile.cg__Private__c = leadFile.Private__c;
                                                cFile.cg__Version_Description__c = leadFile.Version_Description__c;
                                                cFile.cg__Version_Id__c = leadFile.Version_Id__c;
                                                cFile.cg__WIP__c = leadFile.WIP__c;
                                                ConFileList.add(cFile); 
                                            }
            } 
            RecursiveTriggerHandler.blockBeforeUpdate = true;
            RecursiveTriggerHandler.blockAfterUpdate = true;
            
            
            if(ConFileList.size() > 0)
            {
                insert ConFileList;
            }
            if(siblingList.size() > 0){
                insert siblingList;
            }
            if(siblingList.size() > 0){
                for(Contact processsiblingList : siblingList){
                    npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                    newRelationShip.npe4__Contact__c = processsiblingList .Id;
                    newRelationShip.npe4__Type__c = 'Sibling';
                    newRelationShip.npe4__RelatedContact__c = processsiblingList.Wish_Child_Id_Hidden__c;
                    newRelationShip.npe4__Status__c = 'Active';
                    relationShipList.add(newRelationShip);
                    system.debug('@@@@@@ newRelationShip4 @@@@@@@@'+relationShipList);
                }
            }
            RecursiveTriggerHandler.blockBeforeUpdate = true;
            RecursiveTriggerHandler.blockAfterUpdate = true;
            if(updateAcccountList.size() > 0)
                update updateAcccountList;
            if(dsfsList.size() > 0)
                update dsfsList;
            if(partACaseList.Size() > 0)
                update partACaseList;
            if(conMap.size() > 0)
                update conMap.values();
            /* if(caseList.size() > 0)
insert caseList;*/
            if(insertCaseMap.Size() > 0)
                Insert insertCaseMap.values();
            if(relationShipList.size() > 0)
            {
                insert relationShipList;
            }
            if(rushReminderList.size() > 0)
                insert rushReminderList;
            if(leadIdSet.size() > 0){
                dupeCheckonAccount(convertedLeadIds);
            }
            List<npe5__Affiliation__c> affliationList = new List<npe5__Affiliation__c>();
            List<Case> childCaseList = new List<Case>();
            if(existingMedicalProfIdMap.Size()> 0 || conMap.size() > 0){
                for(npe5__Affiliation__c currRec : [SELECT npe5__Organization__c,npe5__Organization__r.RecordTypeId,npe5__Contact__c,Constituent_Code__c  From npe5__Affiliation__c WHERE (npe5__Organization__r.RecordTypeId =: hospitalTreatMentRecordTypeId OR Constituent_Code__c ='Wish Family')]){
                    if(existingMedicalProfIdMap.containsKey(currRec.npe5__Contact__c) && currRec.npe5__Organization__r.RecordTypeId == hospitalTreatMentRecordTypeId){
                        npe5__Affiliation__c newaff = new npe5__Affiliation__c();
                        newAff.npe5__Contact__c = existingMedicalProfIdMap.get(currRec.npe5__Contact__c).convertedContactId;
                        newAff.Treating_Facility__c = 'Current';
                        newAff.npe5__Organization__c = currRec.npe5__Organization__c;
                        affliationList.add(newAff);
                    }
                    if(conMap.containsKey(currRec.npe5__Contact__c) && currRec.Constituent_Code__c == 'Wish Family'){
                        currRec.Constituent_Code__c ='Wish Child';
                        affliationList.add(currRec);
                    }
                }
                if(affliationList.Size() > 0){
                    RecursiveTriggerHandler.blockBeforeUpdate = true;
                    RecursiveTriggerHandler.blockAfterUpdate = true;
                    Upsert affliationList;
                }
            }
            /************************************************************************
Create Subcase when the lead is converted.Here we are processing parent 
Case record then we created a sub cases.
*************************************************************************/
            system.debug('@@@@@@@ convertedLeadMap @@@@@@'+convertedLeadMap);
            if(caseList.size() > 0){
                for(Case processParentCase : caseList){
                    for(Integer i = 0; i <= 3; i++){
                        Case createChildCase = new Case();
                        createChildCase.ParentId = processParentCase.Id;
                        createChildCase.Origin = 'Web';
                        createChildCase.OwnerId = processParentCase.OwnerId;
                        createChildCase.Wish_Type__c = 'Standard';
                        if(i == 0){
                            createChildCase.Subject = 'Wish Determination - ' +convertedLeadMap.get(processParentCase.ContactId).Name;
                            createChildCase.RecordTypeId = wishDeterminationRecordTypeId  ;
                        }
                        if(i == 1){
                            createChildCase.Subject = 'Wish Planning - '+convertedLeadMap.get(processParentCase.ContactId).Name;
                            createChildCase.RecordTypeId = wishPlanningRecordTypeId;
                        }
                        if(i == 2){
                            createChildCase.Subject = 'Wish Granting - '+convertedLeadMap.get(processParentCase.ContactId).Name;
                            createChildCase.RecordTypeId = wishGrantRecordTypeId;
                        }
                        if(i == 3){
                            createChildCase.Subject = 'Wish Impact - '+convertedLeadMap.get(processParentCase.ContactId).Name;
                            createChildCase.RecordTypeId = wishEffectRecordTypeId;
                        }
                        childCaseList.add(createChildCase );
                    }
                }
                if(childCaseList.size() > 0){
                    RecursiveTriggerHandler.blockBeforeUpdate = true;
                    RecursiveTriggerHandler.blockAfterUpdate = true;
                    insert childCaseList;
                }
            }
        }
        
        catch(Exception ex){
            
            for(Lead currRec : toconvertLeadMap.values()){
                ErrorMessage_AC.createdebugRec('Lead_OnAfterUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'leadConvertion',currRec.Id,ex.getStackTraceString(),'Error');
            }
            //Database.rollback(sp);
            
            for(Lead currRec : toconvertLeadMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    } 
    
    /*************************************************************************************************************
This dupeCheckonAccount() method will fire when the lead is converted. While lead is convert
it create new household, hospital treatement account will create. if account name is already
exsist then it create new affiliation record. 
***************************************************************************************************************/
    @future
    public static void dupeCheckonAccount(Set<Id> convertedLeadIds){
        Constant_AC  constant = new Constant_AC();
        //Id hospitalTreatMentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.hospitalTreatment).getRecordTypeId();
        Lead_OnAfterUpdateTriggerHandlerHelper leadHandIns = new Lead_OnAfterUpdateTriggerHandlerHelper();
        String convertedAccId;
        Set<String> medicalfacilytySet = new Set<String>();
        Set<String> treatingfacilytySet = new Set<String>();
        List<Lead>convertedLeadList = new List<Lead>();
        
        for(Lead  processconvertedLeads : [SELECT ID,Name,Hospital_Treatment_Facility__c,I_am_Recognized_To_Practice_As_a__c,Medical_Provider_Category__c,Hospital_Treatment_Facility_Treating__c,Medical_Professional_Last_Name__c,Medical_Professional_Phone__c,
                                           Medical_Professional_Email__c,Medical_Professional_First_Name__c,Treating_Medical_Professional_First_Name__c,Treating_Medical_Professional_Last_Name__c,
                                           Treating_Medical_Professional_Phone__c,Treating_Medical_Professional_Email__c,ConvertedContactId,ConvertedAccountId,Parent_First_Name__c,Parent_Last_Name__c,Email,Phone,CountryCode,  
                                           Street,StateCode,City,PostalCode,Wish_Family_ContactId__c,ChapterName__c,Treating_Medical_Professional_Contact_Id__c,Medical_Professional_ContactId__c,What_is_the_family_s_primary_spoken_lang__c,
                                           Referrer_FirstName__c,Referrer_Last_Name__c,Referrer_Phone__c,Referrer_Email__c,Relationship_to_child__c,Migrated_Record__c,
                                           Best_Contact_for_Physician_First_Name__c,Best_Contact_for_Physician_Last_Name__c,Best_contact_for_Physician_Email__c,HiddenAlternate1MedProfessionalId__c,HiddenAlternate2MedProfessionalId__c,
                                           Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,Additional_Parent_City__c,Alternate1MedProfessionalFirstName__c,Alternate1MedProfessionalLastName__c,
                                           Additional_Parent_Email__c,Additional_Parent_Phone__c,Additional_Parent_Postal_Code__c,Alternate1MedProfessionalPhone__c,Alternate1MedicalProfessionalEmail__c,
                                           Additional_Parent_State__c,Additional_Parent_Street__c,Hidden_Additional_Parent_Id__c,Alternate2MedProfessionalFirstName__c,Alternate2MedProfessionalLastName__c,
                                           Hidden_Best_Contact_Person_Id__c,Parent_Relationship_to_Child__c,Additional_Parent_Relationship_to_Child__c,Alternate2MedProfessionalPhone__c,Alternate2MedProfessionalEmail__c,
                                           Alternate1HospitalTreatmentFacility__c,Alternate2HospitalTreatmentFacility__c,Hidden_DV_form_Medical_professional_Type__c, Department__c
                                           FROM Lead WHERE Id IN:convertedLeadIds  Limit 50000]){
                                               
                                               convertedAccId = processconvertedLeads.ConvertedAccountId;
                                               Lead_OnAfterUpdateTriggerHandlerHelper.convertedAccId = processconvertedLeads.ConvertedAccountId;
                                               treatingfacilytySet.add(processconvertedLeads.Hospital_Treatment_Facility_Treating__c);
                                               if(processconvertedLeads.Alternate1HospitalTreatmentFacility__c != Null)
                                                   treatingfacilytySet.add(processconvertedLeads.Alternate1HospitalTreatmentFacility__c);
                                               if(processconvertedLeads.Alternate2HospitalTreatmentFacility__c != Null)
                                                   treatingfacilytySet.add(processconvertedLeads.Alternate2HospitalTreatmentFacility__c);
                                               
                                               convertedLeadList.add(processconvertedLeads);
                                               Lead_OnAfterUpdateTriggerHandlerHelper.convertedLeadMap.put(processconvertedLeads.Id,processconvertedLeads);
                                           }
        for(Account dbAccount : [SELECT id,Name,RecordTypeId FROM Account WHERE RecordTypeId =: Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatMentRecordTypeId AND Name IN: treatingfacilytySet Limit 50000]){
            Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.put(dbAccount.Name,dbAccount);
        }
        for(Lead  processconvertedLeads :  [SELECT ID,Name,Alternate1HospitalTreatmentFacility__c,Alternate2HospitalTreatmentFacility__c,
                                            Hospital_Treatment_Facility__c,Migrated_Record__c,Hospital_Treatment_Facility_Treating__c,ChapterName__c,
                                            Department__c FROM Lead WHERE Id IN:convertedLeadIds Limit 50000]){
            if(!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processconvertedLeads.Hospital_Treatment_Facility_Treating__c)){
                if(processconvertedLeads.Hospital_Treatment_Facility_Treating__c != Null){
                    Account newAccount = new Account();
                    newAccount.Name = processconvertedLeads.Hospital_Treatment_Facility_Treating__c;
                    newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatMentRecordTypeId;
                    newAccount.Migrated_Record__c = processconvertedLeads.Migrated_Record__c;
                    Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name,newAccount);
                }
            }
            if(!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processconvertedLeads.Alternate1HospitalTreatmentFacility__c)){
                if(processconvertedLeads.Alternate1HospitalTreatmentFacility__c != Null){
                    Account newAccount = new Account();
                    newAccount.Name = processconvertedLeads.Alternate1HospitalTreatmentFacility__c;
                    newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatMentRecordTypeId;
                    newAccount.Migrated_Record__c = processconvertedLeads.Migrated_Record__c;
                    Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name,newAccount);
                }
            }
            if(!Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.containsKey(processconvertedLeads.Alternate2HospitalTreatmentFacility__c)){
                if(processconvertedLeads.Alternate2HospitalTreatmentFacility__c != Null){
                    Account newAccount = new Account();
                    newAccount.Name = processconvertedLeads.Alternate2HospitalTreatmentFacility__c;
                    newAccount.RecordTypeId = Lead_OnAfterUpdateTriggerHandlerHelper.hospitalTreatMentRecordTypeId;
                    newAccount.Migrated_Record__c = processconvertedLeads.Migrated_Record__c;
                    Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.put(newAccount.Name,newAccount);
                }
            }
        }
        if(Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.Size() > 0){
            system.debug('@@@@@@@@@ Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap @@@@@@@@@@@'+Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap);
            RecursiveTriggerHandler.blockBeforeUpdate = true;
            RecursiveTriggerHandler.blockAfterUpdate = true;
            insert Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.Values();
        }
        if(Lead_OnAfterUpdateTriggerHandlerHelper.medicalAccountMap.size() > 0 || Lead_OnAfterUpdateTriggerHandlerHelper.newAccountMap.Size() >0 ){
            Lead_OnAfterUpdateTriggerHandlerHelper.dupeCheckonContact(Lead_OnAfterUpdateTriggerHandlerHelper.convertedLeadMap);
        }
    }
    
    
    
    /**************************************************************************************************************
This dupeCheckonContact() method is used to create a wish child and wish family and medical profff 
contact when the lead is converted and also it create a new relationship record.
* ************************************************************************************************************/
    public static void dupeCheckonContact(Map<Id,Lead> convertedLeadMap)
    {
        
        Set<String> qualifyFirstNameSet = new Set<String>();
        Set<String> qualifyLastNameSet = new Set<String>();
        Set<String> qualifyPhoneNameSet = new Set<String>();
        Set<String> qualifyEmailNameSet = new Set<String>();
        Set<String> referringFirstNameSet = new Set<String>();
        Set<String> referringLastNameSet = new Set<String>();
        Set<String> referringPhoneNameSet = new Set<String>();
        Set<String> referringEmailNameSet = new Set<String>();
        Set<String> sameReferringFirstNameSet = new Set<String>();
        Set<String> sameReferringLastNameSet = new Set<String>();
        Set<String> sameReferringPhoneNameSet = new Set<String>();
        Set<String> sameReferringEmailNameSet = new Set<String>();
        Set<String> alternate1MedPofFirstNameSet = new Set<String>();
        Set<String> alternate1MedPofLastNameSet = new Set<String>();
        Set<String> alternate1MedPofPhone = new Set<String>();
        Set<String> alternate1MedPofEmail = new Set<String>();
        Set<String> alternate2MedPofFirstNameSet = new Set<String>();
        Set<String> alternate2MedPofLastNameSet = new Set<String>();
        Set<String> alternate2MedPofPhone = new Set<String>();
        Set<String> alternate2MedPofEmail = new Set<String>();
        Set<String> bestPersonFirstNameSet = new Set<String>();
        Set<String> bestPersonLastNameSet = new Set<String>();
        Set<String> bestPersonEmailNameSet = new Set<String>();
        Set<String> familyContactLastNameSet = new Set<String>();
        Set<String> additionalParentLastNameSet = new Set<String>();
        List<Contact> referringContact = new List<Contact>();
        List<Contact> newSameContact = new List<Contact>();
        List<Contact> qualifyingContact = new List<Contact>();
        List<Contact> WishFamilyContactList = new List<Contact>();
        List<npe4__Relationship__c> relationList = new List<npe4__Relationship__c>();
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        Set<Id> WishFamilyContactIdSet = new Set<Id>();
        Set<Id> additionalFamilyConIdSet = new Set<Id>();
        String WishFmailyConId;
        List<npe5__Affiliation__c> updateaffiliationList = new List<npe5__Affiliation__c>();
        Id convertedConId;
        List<Contact> newContactList = new List<Contact>();
        Map<String,String> relationshipTypeMap = new Map<String,String>();
        Map<string,Boolean> firstParentMap = new Map<string,Boolean>();
        Map<String,Boolean> qualifyingMap = new Map<String,Boolean>();
        Set<String> parentGuardianNameSet = new Set<String>();
        String parentName;
        String additionalParentName;
        //sp = Database.setSavepoint();
        try{
            for(Lead processConvertedLead : convertedLeadMap.Values()){
                parentName = processConvertedLead.Parent_First_Name__c + '-' + processConvertedLead.Parent_Last_Name__c + '-' + wishFamilyRecordTypeId;
                additionalParentName = processConvertedLead.Additional_Parent_First_Name__c + '-' + processConvertedLead.Additional_Parent_Last_Name__c + '-' + wishFamilyRecordTypeId;
                parentGuardianNameSet.add(parentName);
                parentGuardianNameSet.add(additionalParentName);
                system.debug('@@@@@@@@@ parentGuardianNameSet dupeCheckonContact @@@@@@@@@@@'+parentGuardianNameSet);
                convertedConId = processConvertedLead.ConvertedContactId;
                if(processConvertedLead.HiddenAlternate1MedProfessionalId__c == Null && processConvertedLead.Alternate1MedProfessionalLastName__c != Null){
                    alternate1MedPofLastNameSet.add(processConvertedLead.Alternate1MedProfessionalLastName__c);
                }
                if(processConvertedLead.HiddenAlternate2MedProfessionalId__c == Null && processConvertedLead.Alternate2MedProfessionalLastName__c != Null){
                    alternate2MedPofLastNameSet.add(processConvertedLead.Alternate2MedProfessionalLastName__c);
                }
                if(((processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Referrer_FirstName__c) 
                    && (processConvertedLead.Referrer_FirstName__c == processConvertedLead.Best_Contact_for_Physician_First_Name__c)&&
                    (processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Best_Contact_for_Physician_First_Name__c))  
                   && ((processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Referrer_Last_Name__c)
                       && (processConvertedLead.Referrer_Last_Name__c == processConvertedLead.Best_Contact_for_Physician_Last_Name__c) 
                       && (processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Best_Contact_for_Physician_Last_Name__c))
                   && ((processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Referrer_Phone__c)
                       || (processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Referrer_Email__c)) 
                   && (processConvertedLead.Referrer_Email__c == processConvertedLead.Best_contact_for_Physician_Email__c)
                   && (processConvertedLead.Treating_Medical_Professional_Email__c  == processConvertedLead.Best_contact_for_Physician_Email__c))
                {
                    if(processConvertedLead.Relationship_to_child__c == 'Medical Professional' && processConvertedLead.Medical_Professional_ContactId__c == Null &&
                       processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null && processConvertedLead.Hidden_Best_Contact_Person_Id__c == Null){
                           sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                           sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                           sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                           sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
                       }
                }
                else if(processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Referrer_FirstName__c
                        && processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Referrer_Last_Name__c && 
                        (processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Referrer_Phone__c 
                         || processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Referrer_Email__c))
                {
                    if(processConvertedLead.Relationship_to_child__c == 'Medical Professional' && (processConvertedLead.Medical_Professional_ContactId__c == Null && processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null ))
                    {
                        sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                        sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                        sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                        sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
                    }
                    if(processConvertedLead.Best_Contact_for_Physician_Last_Name__c != Null && processConvertedLead.Hidden_Best_Contact_Person_Id__c == Null){
                        if(processConvertedLead.Relationship_to_child__c == 'Medical Professional'){
                            bestPersonFirstNameSet.add(processConvertedLead.Best_Contact_for_Physician_First_Name__c); 
                            bestPersonLastNameSet.add(processConvertedLead.Best_Contact_for_Physician_Last_Name__c);
                            bestPersonEmailNameSet.add(processConvertedLead.Best_contact_for_Physician_Email__c);
                        } 
                    }
                }
                else if(processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Best_Contact_for_Physician_First_Name__c
                        && processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Best_Contact_for_Physician_Last_Name__c  &&
                        (processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Best_contact_for_Physician_Email__c))
                {
                    if(processConvertedLead.Relationship_to_child__c == 'Medical Professional' && processConvertedLead.Hidden_Best_Contact_Person_Id__c == Null &&  processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null)
                    {
                        sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                        sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                        sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                        sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
                    }
                    if(processConvertedLead.Referrer_Last_Name__c != Null && processConvertedLead.Medical_Professional_ContactId__c == Null){
                        if(processConvertedLead.Relationship_to_child__c == 'Medical Professional'){
                            qualifyFirstNameSet.add(processConvertedLead.Referrer_FirstName__c ); 
                            qualifyLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
                            qualifyPhoneNameSet.add(processConvertedLead.Referrer_Phone__c );
                            qualifyEmailNameSet.add(processConvertedLead.Referrer_Email__c);
                        } 
                    }
                }
                else if(processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
                        && processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c && 
                        (processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c))
                {
                    if(processConvertedLead.Relationship_to_child__c == 'Medical Professional' && processConvertedLead.Medical_Professional_ContactId__c == Null && processConvertedLead.Hidden_Best_Contact_Person_Id__c == Null)
                    {
                        sameReferringFirstNameSet.add(processConvertedLead.Referrer_FirstName__c);
                        sameReferringLastNameSet.add(processConvertedLead.Referrer_Last_Name__c );
                        sameReferringPhoneNameSet.add(processConvertedLead.Referrer_Phone__c);
                        sameReferringEmailNameSet.add(processConvertedLead.Referrer_Email__c);
                    }
                    if(processConvertedLead.Treating_Medical_Professional_Last_Name__c != Null && processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null)
                    {
                        referringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                        referringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                        referringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                        referringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
                    }
                }
                else{
                    if(processConvertedLead.Treating_Medical_Professional_Last_Name__c != Null && processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null){
                        referringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                        referringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                        referringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                        referringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
                    }
                    
                    if(processConvertedLead.Referrer_Last_Name__c != Null && processConvertedLead.Medical_Professional_ContactId__c == Null){
                        if(processConvertedLead.Relationship_to_child__c == 'Medical Professional'){
                            qualifyFirstNameSet.add(processConvertedLead.Referrer_FirstName__c ); 
                            qualifyLastNameSet.add(processConvertedLead.Referrer_Last_Name__c);
                            qualifyPhoneNameSet.add(processConvertedLead.Referrer_Phone__c );
                            qualifyEmailNameSet.add(processConvertedLead.Referrer_Email__c);
                        } 
                    }
                    if(processConvertedLead.Best_Contact_for_Physician_Last_Name__c != Null && processConvertedLead.Hidden_Best_Contact_Person_Id__c== Null){
                        if(processConvertedLead.Relationship_to_child__c == 'Medical Professional'){
                            bestPersonFirstNameSet.add(processConvertedLead.Best_Contact_for_Physician_First_Name__c); 
                            bestPersonLastNameSet.add(processConvertedLead.Best_Contact_for_Physician_Last_Name__c);
                            bestPersonEmailNameSet.add(processConvertedLead.Best_contact_for_Physician_Email__c);
                        } 
                    }
                }
                if(processConvertedLead.Parent_Last_Name__c != Null && processConvertedLead.Wish_Family_ContactId__c == Null){
                    FamilyContactLastNameSet.add(processConvertedLead.Parent_Last_Name__c);
                }
                if(processConvertedLead.Parent_Last_Name__c != Null && processConvertedLead.Wish_Family_ContactId__c != Null)
                { 
                    WishFamilyContactIdSet.add(processConvertedLead.Wish_Family_ContactId__c);
                }
                if(processConvertedLead.Additional_Parent_Last_Name__c!= Null && processConvertedLead.Hidden_Additional_Parent_Id__c == Null){
                    additionalParentLastNameSet.add(processConvertedLead.Additional_Parent_Last_Name__c);
                }
                if(processConvertedLead.Additional_Parent_Last_Name__c!= Null && processConvertedLead.Hidden_Additional_Parent_Id__c!= Null)
                { 
                    WishFamilyContactIdSet.add(processConvertedLead.Hidden_Additional_Parent_Id__c);
                }
                if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c != Null) {
                    
                    npe5__Affiliation__c newAff = new npe5__Affiliation__c();
                    newAff.npe5__Contact__c = processConvertedLead.convertedContactId;
                    newAff.Treating_Facility__c = 'Current';
                    if( processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == 'Alternate 2 Medical Professional' && (newAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c) || medicalAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)) && processConvertedLead.HiddenAlternate2MedProfessionalId__c == Null){
                        if(medicalAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c))
                            newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
                        else
                            newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
                        affiliationList.add(newAff);
                    }
                    else if( processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == 'Alternate 1 Medical Professional' && (newAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c) || medicalAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)) && processConvertedLead.HiddenAlternate1MedProfessionalId__c == Null){
                        if(medicalAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c))
                            newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
                        else
                            newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
                        affiliationList.add(newAff);
                    }
                    else if((processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == 'Best contact for Physician' || processConvertedLead.Hidden_DV_form_Medical_professional_Type__c == 'Treating Medical Professional') && (newAccountMap.containsKey(processConvertedLead.Hospital_Treatment_Facility_Treating__c) || medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)) &&  processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null){
                        if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
                            newAff.npe5__Organization__c = medicalAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
                        else
                            newAff.npe5__Organization__c = newAccountMap.get(processConvertedLead.Hospital_Treatment_Facility_Treating__c).Id;
                        affiliationList.add(newAff);
                    }
                }
            }
            
            if (WishFamilyContactIdSet.Size() > 0){
                for(npe5__Affiliation__c dbFamilyContactAffiliation : [SELECT Id,npe5__Contact__c,npe5__Organization__c,npe5__Primary__c 
                                                                       FROM npe5__Affiliation__c WHERE 
                                                                       npe5__Contact__c =: WishFamilyContactIdSet 
                                                                       AND npe5__Primary__c =: true Limit 50000]){
                                                                           npe5__Affiliation__c updateAffliRec = new npe5__Affiliation__c();
                                                                           updateAffliRec.Id = dbFamilyContactAffiliation.Id;
                                                                           updateAffliRec.npe5__Primary__c = false;
                                                                           /*if(!Test.isRunningTest()){
updateAffliRec.npe5__Contact__c = dbFamilyContactAffiliation.npe5__Contact__c;
updateAffliRec.npe5__Organization__c = dbFamilyContactAffiliation.npe5__Organization__c;
//}*/
                                                                           updateaffiliationList.add(updateAffliRec);
                                                                           
                                                                           npe5__Affiliation__c newAff = new npe5__Affiliation__c();
                                                                           newAff.npe5__Contact__c = dbFamilyContactAffiliation.npe5__Contact__c;
                                                                           newAff.npe5__Organization__c = convertedAccId;
                                                                           newAff.npe5__StartDate__c = Date.Today();
                                                                           newAff.npe5__Status__c = 'Active';
                                                                           newAff.npe5__Primary__c = true;
                                                                           affiliationList.add(newAff);
                                                                       }
            }  
            if(FamilyContactLastNameSet.size() > 0){
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    Contact newWishFamily = new Contact();
                    newWishFamily.FirstName= processConvertedLead.Parent_First_Name__c;
                    newWishFamily.LastName = processConvertedLead.Parent_Last_Name__c;
                    newWishFamily.Email = processConvertedLead.Email;
                    newWishFamily.Phone = '';
                    newWishFamily.MobilePhone = processConvertedLead.Phone;
                    newWishFamily.MailingCountryCode = processConvertedLead.CountryCode;
                    newWishFamily.MailingStreet = processConvertedLead.Street;
                    newWishFamily.MailingStateCode = processConvertedLead.StateCode;
                    newWishFamily.MailingCity= processConvertedLead.City;
                    newWishFamily.MailingPostalCode = processConvertedLead.PostalCode;
                    newWishFamily.Wish_Child_Id_Hidden__c = processConvertedLead .ConvertedContactId;
                    newWishFamily.AccountId = processConvertedLead.ConvertedAccountId;
                    newWishFamily.RecordTypeId = wishFamilyRecordTypeId;
                    newWishFamily.Relationship_Type__c =  'Parent/Legal Guardian';
                    newWishFamily.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newWishFamily.Language__c = processConvertedLead.What_is_the_family_s_primary_spoken_lang__c;
                    newWishFamily.Relationship__c = processConvertedLead.Relationship_to_child__c;
                    newWishFamily.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    if( processConvertedLead.Relationship_to_child__c == 'Parent/Guardian')
                        newWishFamily.Type_Of_Contact__c = 'Parent/Guardian';
                    newContactList.add(newWishFamily);
                    firstParentMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email+ '-' + newWishFamily.Phone,true);
                    relationshipTypeMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email+ '-' + newWishFamily.Phone,processConvertedLead.Parent_Relationship_to_Child__c);
                }
            }
            if(additionalParentLastNameSet.size() > 0){
                List<Contact> additionalContactList = new List<Contact>();
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    Contact newWishFamily = new Contact();
                    newWishFamily.FirstName= processConvertedLead.Additional_Parent_First_Name__c;
                    newWishFamily.LastName = processConvertedLead.Additional_Parent_Last_Name__c;
                    newWishFamily.Email = processConvertedLead.Additional_Parent_Email__c;
                    newWishFamily.Phone = '';
                    newWishFamily.MobilePhone = processConvertedLead.Additional_Parent_Phone__c;
                    newWishFamily.MailingCountryCode = processConvertedLead.CountryCode;
                    newWishFamily.MailingStreet = processConvertedLead.Additional_Parent_Street__c;
                    newWishFamily.MailingState = processConvertedLead.Additional_Parent_State__c;
                    newWishFamily.MailingCity= processConvertedLead.Additional_Parent_City__c;
                    newWishFamily.Relationship_Type__c =  'Parent/Legal Guardian';
                    newWishFamily.MailingPostalCode = processConvertedLead.Additional_Parent_Postal_Code__c;
                    newWishFamily.Wish_Child_Id_Hidden__c = processConvertedLead .ConvertedContactId;
                    newWishFamily.AccountId = processConvertedLead.ConvertedAccountId;
                    newWishFamily.RecordTypeId = wishFamilyRecordTypeId;
                    newWishFamily.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newWishFamily.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    firstParentMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email+ '-' + newWishFamily.Phone,false);
                    relationshipTypeMap.put(newWishFamily.FirstName + '-' + newWishFamily.LastName + '-' + newWishFamily.Email+ '-' + newWishFamily.Phone,processConvertedLead.Additional_Parent_Relationship_to_Child__c);
                    newContactList.add(newWishFamily);
                }
            }
            if(sameReferringFirstNameSet.Size()>0 && sameReferringLastNameSet.size() > 0 && (sameReferringPhoneNameSet.size() > 0 || sameReferringEmailNameSet.size() > 0)){
                List<npe4__Relationship__c> sameNameRelationList = new List<npe4__Relationship__c>();
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    contact newMedicalcon = new contact();
                    newMedicalcon.FirstName = processConvertedLead.Referrer_FirstName__c;
                    newMedicalcon.LastName = processConvertedLead.Referrer_Last_Name__c ;
                    if((processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Referrer_FirstName__c
                        && processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Referrer_Last_Name__c && 
                        (processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Referrer_Phone__c 
                         || processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Referrer_Email__c)) || (processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
                                                                                                                                        && processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c && 
                                                                                                                                        (processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c))){
                                                                                                                                            if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
                                                                                                                                            {
                                                                                                                                                newMedicalcon.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                                                                                                                                            }
                                                                                                                                            if(newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)){
                                                                                                                                                newMedicalcon.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                                                                                                                                            }
                                                                                                                                            if(processConvertedLead.Best_Contact_for_Physician_First_Name__c == processConvertedLead.Referrer_FirstName__c
                                                                                                                                               && processConvertedLead.Best_Contact_for_Physician_Last_Name__c == processConvertedLead.Referrer_Last_Name__c && 
                                                                                                                                               (processConvertedLead.Best_contact_for_Physician_Email__c == processConvertedLead.Referrer_Email__c)){
                                                                                                                                                   newMedicalcon.Type_Of_Contact__c = 'Referrer&Best';
                                                                                                                                                   if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c =='Best contact for Physician' && processConvertedLead.I_am_Recognized_To_Practice_As_a__c != Null)
                                                                                                                                                       newMedicalcon.Provider_Type__c  = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
                                                                                                                                                   else
                                                                                                                                                       newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;                            
                                                                                                                                               }
                                                                                                                                            else{
                                                                                                                                                newMedicalcon.Type_Of_Contact__c = 'Referrer&Treating';
                                                                                                                                                if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c =='Treating Medical Professional' && processConvertedLead.I_am_Recognized_To_Practice_As_a__c != Null)
                                                                                                                                                    newMedicalcon.Provider_Type__c  = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
                                                                                                                                                else
                                                                                                                                                    newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c; 
                                                                                                                                            }
                                                                                                                                        }
                    qualifyingMap.put(processConvertedLead.Referrer_FirstName__c+ '-' + processConvertedLead.Referrer_Last_Name__c + '-' + processConvertedLead.Referrer_Email__c,True);
                    newMedicalcon.AccountId = processConvertedLead.ChapterName__c;
                    newMedicalcon.npe01__WorkPhone__c = processConvertedLead.Referrer_Phone__c;
                    newMedicalcon.Phone = '';
                    newMedicalcon.Email = Null;
                    newMedicalcon.npe01__HomeEmail__c = '';
                    newMedicalcon.npe01__Preferred_Email__c ='Work';
                    newMedicalcon.npe01__WorkEmail__c= processConvertedLead.Referrer_Email__c;                  
                    newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                    newMedicalcon.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newMedicalcon.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    
                    newContactList.add(newMedicalcon);
                }
            }  
            if(referringFirstNameSet.size() > 0 && referringLastNameSet.Size() > 0 && (referringPhoneNameSet.Size() > 0 || referringEmailNameSet.Size() > 0)){
                List<npe4__Relationship__c> referringRelationList = new List<npe4__Relationship__c>();
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    contact newMedicalcon = new contact();
                    newMedicalcon.FirstName = processConvertedLead.Treating_Medical_Professional_First_Name__c;
                    newMedicalcon.LastName = processConvertedLead.Treating_Medical_Professional_Last_Name__c;
                    if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                    }
                    if(newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                    }
                    newMedicalcon.AccountId = processConvertedLead.ChapterName__c;
                    newMedicalcon.Phone = '';
                    newMedicalcon.npe01__WorkPhone__c = processConvertedLead.Treating_Medical_Professional_Phone__c;
                    newMedicalcon.Email = '';
                    newMedicalcon.npe01__WorkEmail__c = processConvertedLead.Treating_Medical_Professional_Email__c;
                    newMedicalcon.Email = Null;
                    newMedicalcon.npe01__HomeEmail__c = '';
                    newMedicalcon.npe01__Preferred_Email__c ='Work';
                    //IME-86
                    if(processConvertedLead.Department__c != null){
                        newMedicalcon.Department = processConvertedLead.Department__c;
                    }                    
                    if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c =='Treating Medical Professional'){
                        newMedicalcon.Provider_Type__c  = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
                        qualifyingMap.put(processConvertedLead.Treating_Medical_Professional_First_Name__c+ '-' + processConvertedLead.Treating_Medical_Professional_Last_Name__c+ '-' + processConvertedLead.Treating_Medical_Professional_Email__c,True);
                    }
                    else
                        qualifyingMap.put(processConvertedLead.Treating_Medical_Professional_First_Name__c+ '-' + processConvertedLead.Treating_Medical_Professional_Last_Name__c+ '-' + processConvertedLead.Treating_Medical_Professional_Email__c,False);
                    newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                    
                    newMedicalcon.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newMedicalcon.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    newMedicalcon.Type_Of_Contact__c = 'Treating';
                    newContactList.add(newMedicalcon);
                }
            }
            if(qualifyFirstNameSet.size() > 0 && qualifyLastNameSet.Size() > 0 && (qualifyPhoneNameSet.Size() > 0 || qualifyEmailNameSet.Size() > 0)){
                List<npe4__Relationship__c> qualifyingRelationList = new List<npe4__Relationship__c>();
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    contact newMedicalcon = new contact();
                    newMedicalcon.FirstName = processConvertedLead.Referrer_FirstName__c;
                    newMedicalcon.LastName = processConvertedLead.Referrer_Last_Name__c;
                    newMedicalcon.AccountId = processConvertedLead.ChapterName__c;
                    newMedicalcon.Phone = '';
                    newMedicalcon.npe01__WorkPhone__c = processConvertedLead.Referrer_Phone__c;
                    newMedicalcon.Email = '';
                    newMedicalcon.npe01__WorkEmail__c = processConvertedLead.Referrer_Email__c;
                    newMedicalcon.Email = Null;
                    newMedicalcon.npe01__HomeEmail__c = '';
                    newMedicalcon.npe01__Preferred_Email__c ='Work';
                    newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                    newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                    newMedicalcon.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newMedicalcon.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    newMedicalcon.Type_Of_Contact__c = 'Referring';
                    //IME-86
                    if(processConvertedLead.Department__c != null){
                        newMedicalcon.Department = processConvertedLead.Department__c;
                    }
                    // qualifyingMap.put(processConvertedLead.Referrer_FirstName__c+ '-' + processConvertedLead.Referrer_Last_Name__c + '-' + processConvertedLead.Referrer_Email__c,processConvertedLead.Hidden_DV_form_Medical_professional_Type__c);               
                    newContactList.add(newMedicalcon);
                }
            } 
            if(bestPersonFirstNameSet.size() > 0 && bestPersonLastNameSet.Size() > 0){
                List<contact> bestPhysicanConList = new List<contact>();
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    contact newMedicalcon = new contact();
                    newMedicalcon.FirstName = processConvertedLead.Best_Contact_for_Physician_First_Name__c;
                    newMedicalcon.LastName = processConvertedLead.Best_Contact_for_Physician_Last_Name__c;
                    newMedicalcon.AccountId = processConvertedLead.ChapterName__c;
                    if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                    }
                    if(newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                    }
                    newMedicalcon.Email = '';
                    newMedicalcon.npe01__HomeEmail__c = '';
                    newMedicalcon.npe01__Preferred_Email__c ='Work';
                    newMedicalcon.npe01__WorkEmail__c = processConvertedLead.Best_contact_for_Physician_Email__c;
                    //newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                    newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                    newMedicalcon.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newMedicalcon.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    newMedicalcon.Type_Of_Contact__c = 'BestContact';
                    //IME-86
                    if(processConvertedLead.Department__c != null){
                        newMedicalcon.Department = processConvertedLead.Department__c;
                    }
                    if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c =='Best contact for Physician'){
                        newMedicalcon.Provider_Type__c  = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
                        qualifyingMap.put(processConvertedLead.Best_Contact_for_Physician_First_Name__c+ '-' + processConvertedLead.Best_Contact_for_Physician_Last_Name__c+ '-' + processConvertedLead.Best_contact_for_Physician_Email__c,True);
                    }
                    else
                        qualifyingMap.put(processConvertedLead.Best_Contact_for_Physician_First_Name__c+ '-' + processConvertedLead.Best_Contact_for_Physician_Last_Name__c+ '-' + processConvertedLead.Best_contact_for_Physician_Email__c,False);
                    
                    newContactList.add(newMedicalcon);
                }
            } 
            if(alternate1MedPofLastNameSet.Size() > 0){
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    contact newMedicalcon = new contact();
                    if(processConvertedLead.Alternate1MedProfessionalFirstName__c != Null)
                        newMedicalcon.FirstName = processConvertedLead.Alternate1MedProfessionalFirstName__c;
                    newMedicalcon.LastName = processConvertedLead.Alternate1MedProfessionalLastName__c;
                    newMedicalcon.AccountId = processConvertedLead.ChapterName__c;                
                    if(medicalAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
                        
                    }
                    if(newAccountMap.containsKey(processConvertedLead .Alternate1HospitalTreatmentFacility__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Alternate1HospitalTreatmentFacility__c).Id;
                    }
                    if(processConvertedLead.Alternate1MedicalProfessionalEmail__c != Null)               
                        newMedicalcon.npe01__WorkEmail__c = processConvertedLead.Alternate1MedicalProfessionalEmail__c;
                    
                    newMedicalcon.npe01__WorkPhone__c = processConvertedLead.Alternate1MedProfessionalPhone__c;
                    newMedicalcon.Email = Null;
                    newMedicalcon.npe01__HomeEmail__c = '';
                    newMedicalcon.npe01__Preferred_Email__c ='Work';
                    //newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                    newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                    //IME-86
                    if(processConvertedLead.Department__c != null){
                        newMedicalcon.Department = processConvertedLead.Department__c;
                    }
                    newMedicalcon.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newMedicalcon.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c =='Alternate 1 Medical Professional'){
                        newMedicalcon.Provider_Type__c  = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
                        qualifyingMap.put(processConvertedLead.Alternate1MedProfessionalFirstName__c+ '-' + processConvertedLead.Alternate1MedProfessionalLastName__c+ '-' + processConvertedLead.Alternate1MedicalProfessionalEmail__c,True);
                    }
                    else
                        qualifyingMap.put(processConvertedLead.Alternate1MedProfessionalFirstName__c+ '-' + processConvertedLead.Alternate1MedProfessionalLastName__c+ '-' + processConvertedLead.Alternate1MedicalProfessionalEmail__c,False);
                    newContactList.add(newMedicalcon);
                }
            }
            if(alternate2MedPofLastNameSet.Size() > 0){
                for(Lead processConvertedLead : convertedLeadMap.Values()){
                    contact newMedicalcon = new contact();
                    if(processConvertedLead.Alternate2MedProfessionalFirstName__c != Null)
                        newMedicalcon.FirstName = processConvertedLead.Alternate2MedProfessionalFirstName__c;
                    newMedicalcon.LastName = processConvertedLead.Alternate2MedProfessionalLastName__c;
                    newMedicalcon.AccountId = processConvertedLead.ChapterName__c;
                    if(medicalAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = medicalAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
                    }
                    if(newAccountMap.containsKey(processConvertedLead .Alternate2HospitalTreatmentFacility__c)){
                        newMedicalcon.Hidden_Hospital_Account__c = newAccountMap.get(processConvertedLead.Alternate2HospitalTreatmentFacility__c).Id;
                    }
                    if(processConvertedLead.Alternate2MedProfessionalEmail__c != Null)                    
                        newMedicalcon.npe01__WorkEmail__c = processConvertedLead.Alternate2MedProfessionalEmail__c;
                    newMedicalcon.Email = '';
                    newMedicalcon.Email = Null;
                    newMedicalcon.npe01__HomeEmail__c = '';
                    newMedicalcon.npe01__Preferred_Email__c ='Work';
                    //IME-86
                    if(processConvertedLead.Department__c != null){
                        newMedicalcon.Department = processConvertedLead.Department__c;
                    }
                    newMedicalcon.npe01__WorkPhone__c = processConvertedLead.Alternate2MedProfessionalPhone__c;
                    //newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                    newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                    newMedicalcon.Region_Chapter__c = processConvertedLead.ChapterName__c;
                    newMedicalcon.Migrated_Record__c = processConvertedLead.Migrated_Record__c;
                    if(processConvertedLead.Hidden_DV_form_Medical_professional_Type__c =='Alternate 2 Medical Professional'){
                        newMedicalcon.Provider_Type__c  = processConvertedLead.I_am_Recognized_To_Practice_As_a__c;
                        qualifyingMap.put(processConvertedLead.Alternate2MedProfessionalFirstName__c+ '-' + processConvertedLead.Alternate2MedProfessionalLastName__c+ '-' + processConvertedLead.Alternate2MedProfessionalEmail__c,True);
                    }
                    else
                        qualifyingMap.put(processConvertedLead.Alternate2MedProfessionalFirstName__c+ '-' + processConvertedLead.Alternate2MedProfessionalLastName__c+ '-' + processConvertedLead.Alternate2MedProfessionalEmail__c,False);
                    newContactList.add(newMedicalcon);
                }
            }
            if(newContactList.size() > 0)
            {   RecursiveTriggerHandler.blockBeforeUpdate = true;
             RecursiveTriggerHandler.blockAfterUpdate = true;
             insert newContactList;
             
             for(Contact currContact: newContactList)
             {
                 npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                 newRelationShip.npe4__Contact__c = convertedConId;
                 if(currContact.RecordTypeId == medicalProfessionalRecordTypeId)
                 {
                     System.debug('qualifyingMap.keyset()'+qualifyingMap.keyset());
                     System.debug('keyset'+currContact.FirstName+ '-' + currContact.LastName + '-' + currContact.npe01__WorkEmail__c);
                     System.debug('qualifyingMap'+qualifyingMap);
                     newRelationShip.npe4__Type__c = 'Medical Professional';
                     If(qualifyingMap.ContainsKey(currContact.FirstName+ '-' + currContact.LastName + '-' + currContact.npe01__WorkEmail__c)){
                         newRelationShip.Qualifying_Medical_Professional__c = qualifyingMap.get(currContact.FirstName+ '-' + currContact.LastName + '-' + currContact.npe01__WorkEmail__c);
                     }
                     
                 }
                 else if(currContact.RecordTypeId == wishFamilyRecordTypeId)
                 {
                     newRelationShip.Hidden_isparentFirst__c = firstParentMap.get(currContact.FirstName+ '-' + currContact.LastName + '-' + currContact.Email+ '-' +currContact.Phone);
                     newRelationShip.npe4__Type__c = relationshipTypeMap.get(currContact.FirstName+ '-' + currContact.LastName + '-' + currContact.Email+ '-' +currContact.Phone);
                     system.debug('parentGuardianNameSet ---------->'+parentGuardianNameSet);
                     system.debug('Current Record Value ---------->'+ currContact.FirstName + '-'+ currContact.LastName + '-' + wishFamilyRecordTypeId);
                     if(parentGuardianNameSet.contains(currContact.FirstName + '-'+ currContact.LastName + '-' + wishFamilyRecordTypeId)){
                         newRelationShip.Parent_Legal_Guardian__c = true;
                     }
                 }
                 if(currContact.Type_Of_Contact__c == 'Referring' || currContact.Type_Of_Contact__c == 'Parent/Guardian')
                     newRelationShip.Referring_Medical_Professional__c = true;
                 else if(currContact.Type_Of_Contact__c == 'Treating'){
                     
                     newRelationShip.Treating_HCP__c = true;
                 }
                 else if(currContact.Type_Of_Contact__c == 'Referrer&Treating')
                 {
                     newRelationShip.Referring_Medical_Professional__c = true;
                     newRelationShip.Treating_HCP__c = true;
                 }
                 else if(currContact.Type_Of_Contact__c == 'Referrer&Best')
                 {
                     newRelationShip.Referring_Medical_Professional__c = true;
                     newRelationShip.Best_Contact__c = True;
                 }   
                 else if(currContact.Type_Of_Contact__c == 'BestContact')
                 {
                     newRelationShip.Best_Contact__c = True;
                 }                           
                 newRelationShip.npe4__RelatedContact__c = currContact.Id;
                 newRelationShip.npe4__Status__c = 'Active';
                 relationList.add(newRelationShip);
                 
             }
            }
            
            if(relationList.size() > 0){
                RecursiveTriggerHandler.blockBeforeUpdate = true;
                RecursiveTriggerHandler.blockAfterUpdate = true;
                insert relationList;
            }
            if(updateaffiliationList.size() > 0){
                RecursiveTriggerHandler.blockBeforeUpdate = true;
                RecursiveTriggerHandler.blockAfterUpdate = true;
                update updateaffiliationList;
                
            }
            if(affiliationList.size() > 0){
                RecursiveTriggerHandler.blockBeforeUpdate = true;
                RecursiveTriggerHandler.blockAfterUpdate = true;
                insert affiliationList;
            }
        }
        
        catch(Exception ex){
            
            for(Lead currRec : convertedLeadMap.Values()){
                ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'dupeCheckonContact',currRec.Id,ex.getStackTraceString(),'Error');
            }
            
            // Database.rollback(sp);
            for(Lead currRec : convertedLeadMap.Values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        } 
        
    }
    
    /****************************************************************************
This updateDocusignStatus() this method is used update the electronic signer
in lead related docusign status record.
****************************************************************************/  
    @future    
    public static void updateDocusignStatus(Map<Id, Id> leadContactMap) {
        List<dsfs__DocuSign_Status__c> docusignStatusList = new List<dsfs__DocuSign_Status__c>();
        try{
            for(dsfs__DocuSign_Status__c docusignStatus : [SELECT Id, dsfs__Lead__c, dsfs__Envelope_Status__c, dsfs__Contact__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Lead__c IN : leadContactMap.keySet() AND dsfs__Subject__c = 'Diagnosis Verification Form']) {
                if(docusignStatus.dsfs__Contact__c == null) {
                    docusignStatus.dsfs__Contact__c = leadContactMap.get(docusignStatus.dsfs__Lead__c);
                    docusignStatusList.add(docusignStatus);
                }
            }
            if(docusignStatusList.size() > 0) {
                RecursiveTriggerHandler.blockBeforeUpdate = true;
                RecursiveTriggerHandler.blockAfterUpdate = true;
                update docusignStatusList;
            }
        }
        catch(Exception ex){
            for(Lead currRec : [SELECT Id,LastName FROM Lead WHERE Id IN:leadContactMap.KeySet()]){
                ErrorMessage_AC.createdebugRec('Lead_OnAfterUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateDocusignStatus',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec : [SELECT Id,LastName FROM Lead WHERE Id IN:leadContactMap.KeySet()]){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
        
    }
    /****************************************************************************************
Create and assign the task to lead intake user when the lead status is updated with DNQ.
******************************************************************************************/  
    //Commented for IME-2
    /*public static void createTaskforDNQLeads(Map<Lead,Id> lead_ChapterIdMap){
        Constant_AC  constant = new Constant_Ac();
        Id staffTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
        Map<Id,Id> leadIntakeUserMap = new Map<Id,Id>();
        
        try{
            for(Account currRec : [SELECT Id, Intake_Manager__c FROM Account WHERE Id IN :lead_ChapterIdMap.Values() AND Intake_Manager__c != NULL]){
                leadIntakeUserMap.put(currRec.Id,currRec.Intake_Manager__c);
            }
            Task newTask;
            List<Task> newTaskList = new List<Task>();
            for(Lead currLead: lead_ChapterIdMap.keyset()){
                newTask = new Task();
                newTask.Subject='Referral DNQ';
                newTask.SystemGeneratedTask__c = TRUE;
                newTask.ActivityDate=System.today().addDays(3);
                if(leadIntakeUserMap.containsKey(currLead.ChapterName__c)) {
                    newTask.OwnerId=leadIntakeUserMap.get(currLead.ChapterName__c);
                } else {
                    newTask.OwnerId= currLead.OwnerId;
                }
                newTask.WhoId=currLead.Id;
                newTask.RecordTypeId = staffTaskRT;
                newTaskList.add(newTask);
            }
            if(newTaskList.Size() > 0){
                Insert newTaskList;
            }
        }
        
        catch(Exception ex){
            
            for(Lead currRec : lead_ChapterIdMap.KeySet()){
                ErrorMessage_AC.createdebugRec('Lead_OnAfterUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'createTaskforDNQLeads',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec : lead_ChapterIdMap.KeySet()){
                currRec.addError(Label.Debug_log_error_message);
            }
            
        } 
    } */
    
    /* IME 9
	This method update DV case, the rush checkbox is checked when any medical reason is true
	*/
    public static void updateRushInDVCase(Map<Id,Boolean> rushLeadMap){
        List<Case> updateCase = new List<Case>();
        Set<Id> leadIds = rushLeadMap.keySet();
        
        for(Case processCase: [SELECT Id, Rush__c, Lead__c from Case WHERE Lead__c IN :leadIds AND recordTypeId = :DVCaseRecordTypeId LIMIT 50000]){
            processCase.Rush__c = rushLeadMap.get(processCase.Lead__c);
            updateCase.add(processCase);
        }
        if(updateCase.size() > 0){
            update updateCase;
        }
    }
    
}