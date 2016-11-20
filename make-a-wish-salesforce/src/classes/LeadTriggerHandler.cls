/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : LeadTriggerHandler is used to assign the case owner as a queue dynamically based on the lead state.And also if any duplicate records available in leads or contact then it displayed as a duplicate leads and contacts.
And also it is used to call the approval process automatically when the record is created. And also convert the lead automatically when approver 
approve the record.
*******************************************************************************************************************/

Public Class LeadTriggerHandler{
    
    /* When the lead is create it check if any duplicate records available in leads or contact then it displayed as a duplicate leads and contacts.
And also Assign the case owner as a queue dynamically based on the lead state. */
    Constant_AC  constant = new Constant_AC();
    public Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    public Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    public Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    public Id organizationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.OrganizationRT).getRecordTypeId();
    public Id parentwishRecTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    public Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();
    public boolean falg = true;
    Map<String,Account> newAccountMap = new Map<String,Account>();
    Map<String,Account> medicalAccountMap = new Map<String,Account>();
    List<Lead>convertedLeadList = new List<Lead>();
    
   /*Convert the lead records when it is approved.*/
    public void onAfterUpdate(List<Lead> newLeads){
        
        Map<Id,Lead> convertedAccountMap = new Map<Id,Lead>();
        List<Account> updateAcccountList = new List<Account>();
        Map<id,Contact> conMap = new Map<Id,Contact>();
        Map<Id,Lead> LeadMap = new Map<id,Lead>();
        Map<Id,Lead> leadFamilyMap = new Map<Id,Lead>();
        Set<Id> convertedLeadIds = new Set<Id>();
        set<Id> conId = new set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Case>caseList = new List<Case>();
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
        Id ChapterId;
        for(Lead processNewLeads: newLeads){
            Database.LeadConvert lc = new Database.LeadConvert();
            LeadMap.put(processNewLeads.Id,processNewLeads);
            lc.setLeadId(processNewLeads.Id);
            lc.setDoNotCreateOpportunity(true); 
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);
        }
        System.debug('Lead Convertion start1:');
        if (!leadConverts.isEmpty()) {
         System.debug('Lead Convertion start2:');

            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
            //List<String> SiblingList = new List<String>();
            Map<Id,Lead> convertedLeadMap = new Map<Id,Lead>();
            for(Database.LeadConvertResult convertLeads :lcr){
                accountIds.add(convertLeads.getAccountId());
                conId.add(convertLeads.getContactId());
                convertedLeadIds.add(convertLeads.getLeadId());
                
                
            }
            
            for(Lead convertedLeads : [SELECT Id,Name,DOB__c,FirstName,LastName,createdDate,Sibling_Detail__c,Medical_Provider_Category__c,ChapterName__r.Name,ChapterName__c,ConvertedContactId,ConvertedAccountId,
                                       Parent_First_Name__c,Parent_Last_Name__c,Email,Phone,City,CountryCode,PostalCode,StateCode,Street,Treating_Medical_Professional_Contact_Id__c,Medical_Professional_ContactId__c,Wish_Family_ContactId__c FROM Lead WHERE Id IN: convertedLeadIds]){
                                           leadFamilyMap .put(convertedLeads.Id,convertedLeads);
                                           convertedLeadMap .put(convertedLeads.ConvertedContactId,convertedLeads);
                                           convertedAccountMap .put(convertedLeads.ConvertedAccountId,convertedLeads);
                                           chapterIdSet.add(convertedLeads.ChapterName__c);
                                           leadFamilyFirstNameSet.add(convertedLeads.FirstName);
                                           leadFamilyLastNameSet.add(convertedLeads.LastName);
                                           leadFamilyEmailSet.add(convertedLeads.Email);
                                           leadFamilyPhoneSet.add(convertedLeads.Phone);
                                           
                                           if(convertedLeads.Treating_Medical_Professional_Contact_Id__c != Null){
                                               
                                               npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                                               newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                                               newRelationShip.npe4__Type__c = 'Medical Professional';
                                               newRelationShip.Referring_Medical_Professional__c = true;
                                               newRelationShip.npe4__RelatedContact__c = convertedLeads.Treating_Medical_Professional_Contact_Id__c;
                                               newRelationShip.npe4__Status__c = 'Active';
                                               relationShipList.add(newRelationShip);
                                               
                                           }
                                           else{
                                               leadIdSet.add(convertedLeads.Id);
                                           }
                                           if(convertedLeads.Medical_Professional_ContactId__c != Null ){
                                               
                                               npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                                               newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                                               newRelationShip.npe4__Type__c = 'Medical Professional';
                                               newRelationShip.Qualifying_Medical_Professional__c = true;
                                               newRelationShip.npe4__RelatedContact__c = convertedLeads.Medical_Professional_ContactId__c ;
                                               newRelationShip.npe4__Status__c = 'Active';
                                               relationShipList.add(newRelationShip);
                                               
                                           }
                                           else{
                                               leadIdSet.add(convertedLeads.Id);
                                           }
                                           if(convertedLeads.Wish_Family_ContactId__c != Null){
                                               npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                                               newRelationShip.npe4__Contact__c = convertedLeads.ConvertedContactId;
                                               newRelationShip.npe4__Type__c = 'Family';
                                               newRelationShip.npe4__RelatedContact__c = convertedLeads.Wish_Family_ContactId__c;
                                               newRelationShip.npe4__Status__c = 'Active';
                                               relationShipList.add(newRelationShip);
                                           }
                                           
                                           else{
                                               leadIdSet.add(convertedLeads.Id);
                                           }
                                       }
            if(chapterIdSet.size() > 0){
                for(Account dbChapterAccount : [SELECT Id,Name,Volunteer_Manager__c,Volunteer_Manager__r.Name,Volunteer_Manager__r.Email FROM Account WHERE Id IN: chapterIdSet]){
                    ChapterId = dbChapterAccount.Id;
                    chapterUserMap.put(dbChapterAccount.Id,dbChapterAccount);
                    
                }
            }
            
            for(Account conAccount : [SELECT Id,Name FROM Account Where Id IN: accountIds]){
                if(convertedAccountMap.containsKey(conAccount .Id)){
                    if(convertedAccountMap.get(conAccount.Id).FirstName == Null){
                        conAccount.Name = convertedAccountMap.get(conAccount.Id).LastName + ' '+ ' & '+' ' +'Family Household';
                    }
                    else{
                        conAccount.Name = convertedAccountMap.get(conAccount.Id).FirstName + ' ' +convertedAccountMap.get(conAccount.Id).LastName + ' '+ ' & '+' ' +'Family Household';
                    }
                    updateAcccountList.add(conAccount );
                }
            }
            
            List<cg__ContactFile__c> ContactFileFolders = new List<cg__ContactFile__c>();
            for(contact con : [SELECT Id,FirstName,Birthdate,Lead_Created_Date__c,Parent_Guardian_Name__c,RecordTypeId,AccountId,LastName,MailingCity,OwnerId,MailingState,MailingPostalCode FROM Contact WHERE Id in:conId]){
                IF(convertedLeadMap.containsKey(con.Id)){
                    
                    con.Lead_Created_Date__c = Date.valueOf(convertedLeadMap.get(con.Id).createdDate);
                    con.Birthdate = convertedLeadMap.get(con.Id).DOB__c;
                    con.RecordTypeId = wishChildRecordTypeId;
                    con.Chapter_Name__c = convertedLeadMap.get(con.Id).ChapterName__r.Name;
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
                    newTask.Subject = 'Send Welcome Letter/Make Welcome Call';
                    newTask.WhoId = con.Id;
                    newTask.Description = 'Send Welcome Letter/Make Welcome Call';
                    newTask.Status = 'In Progress';
                    newTask.ActivityDate = system.today() + 10;
                    rushReminderList.add(newTask);   
                }
            }
            
            for(Database.LeadConvertResult convertLeads :lcr){
                if(leadFamilyMap.containsKey(convertLeads.getLeadId())){
                    if(leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c != Null){
                        if(leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.contains('<br>')){
                            system.debug('@@@@@@ Sibilingdetails @@@@@@'+leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c);
                            for(String currsiblings : leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.split('<br>')){
                                
                                if(currsiblings.contains('|')){
                                    List<String>siblingdetails = currsiblings.split('\\|');
                                    if(siblingdetails.size() == 3){ 
                                        Contact newFamily = new Contact();
                                        newFamily .FirstName = siblingdetails [0];
                                        newFamily .lastName = siblingdetails [1];
                                        newFamily.Sibling_Age__c = siblingdetails[2];
                                        newFamily.Wish_Child_Id_Hidden__c = convertLeads.getcontactId();
                                        newFamily.RecordTypeId = wishFamilyRecordTypeId;
                                        newFamily.AccountId = convertLeads.getAccountId();
                                        siblingList.add(newFamily);    
                                        system.debug('!!!!!!! MorethanOneSibling 4 !!!!!!'+siblingList);
                                        
                                    }
                                }
                            }
                            
                        }
                        else if(leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.contains('|')){
                            list<String> siblingdetails = leadFamilyMap.get(convertLeads.getLeadId()).Sibling_Detail__c.split('\\|');
                            system.debug('@@@@@@ Sibilingdetails @@@@@@'+siblingdetails);
                            if(siblingdetails .size() == 3){
                                Contact newFamily = new Contact();
                                newFamily .FirstName = siblingdetails [0];
                                newFamily .lastName = siblingdetails [1];
                                newFamily.Sibling_Age__c = siblingdetails[2];
                                newFamily.Wish_Child_Id_Hidden__c = convertLeads.getcontactId();
                                newFamily.RecordTypeId = wishFamilyRecordTypeId;
                                newFamily.AccountId = convertLeads.getAccountId();
                                siblingList.add(newFamily);
                                
                            }
                        }
                        
                    }
                    
                }
                
                if(LeadMap.containsKey(convertLeads.getLeadId())) {
                    case newcase = new case();
                    newcase .RecordTypeId = parentwishRecTypeId;
                    newcase.contactId = convertLeads.getcontactId();
                    if(conMap.containsKey(convertLeads.getcontactId()))
                    {
                        newcase.ownerId = conMap.get(convertLeads.getcontactId()).ownerId;
                       //newCase.Chapter_Name__c = conMap.get(convertLeads.getcontactId()).chapter_Name__c;
                        newCase.ChapterName__c = LeadMap.get(convertLeads.getLeadId()).chapterName__c;
                        newCase.Hidden_Primary_Diagnosis__c = LeadMap.get(convertLeads.getLeadId()).Primary_Diagnosis__c;
                        
                        System.debug('Parent Wishes 123' + LeadMap.get(convertLeads.getLeadId()).chapterName__c);
                    }
                    newcase.AccountId = convertLeads.getAccountId();
                    
                    Date myDate = Date.ValueOf( LeadMap.get(convertLeads.getLeadId()).CreatedDate);
                    String dateval = String.valueof(myDate);
                    if(LeadMap.get(convertLeads.getLeadId()).FirstName != NULL){
                        newcase.Subject = LeadMap.get(convertLeads.getLeadId()).FirstName + ' ' + LeadMap.get(convertLeads.getLeadId()).LastName + ' ' +dateval.removeEnd(' 00:00:00');
                    }
                    else{
                        newcase.Subject = LeadMap.get(convertLeads.getLeadId()).LastName + ' ' +myDate;
                    }
                    if(chapterUserMap.size() > 0){
                        if(chapterUserMap.get(ChapterId).Volunteer_Manager__r.Name != Null && chapterUserMap.get(ChapterId).Volunteer_Manager__r.Email != Null){
                            newcase.VOlunteer_Manager_Name__c = chapterUserMap.get(ChapterId).Volunteer_Manager__r.Name;
                            newcase.Volunteer_Manager_Email__c =chapterUserMap.get(ChapterId).Volunteer_Manager__r.Email;
                        }
                    }
                    newcase.Status = 'Qualified';
                    newcase.Origin = 'Web';
                    if(LeadMap.get(convertLeads.getLeadId()).Referred_Date__c != null)
                      newCase.Referral_Date__c = LeadMap.get(convertLeads.getLeadId()).Referred_Date__c;
                    if(LeadMap.get(convertLeads.getLeadId()).Inquiry_Date__c!= null)
                      newCase.Inquiry_Date__c= LeadMap.get(convertLeads.getLeadId()).Inquiry_Date__c;
                      newCase.diagnosis_verificaion_receive_date__c = LeadMap.get(convertLeads.getLeadId()).Part_A_Received__c;
                      newCase.diagnosis_verificaion_sent_date__c = LeadMap.get(convertLeads.getLeadId()).Part_A_Sent__c;
                    
                    
                    caseList.add(newcase);
                }
            }
            
            for(Case dbPartAcase : [SELECT Id,CaseNumber,Lead__c,ContactId FROM Case WHERE Lead__c IN:convertedLeadIds]){
                if(leadFamilyMap .containsKey(dbPartAcase.Lead__c)){
                    dbPartAcase.ContactId = leadFamilyMap.get(dbPartAcase.Lead__c).ConvertedContactId;
                    partACaseList.add(dbPartAcase);
                }
            }
            
            for(dsfs__DocuSign_Status__c dbdsfsLead : [SELECT Id,dsfs__Lead__c,dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c  WHERE dsfs__Lead__c IN: convertedLeadIds AND dsfs__Envelope_Status__c =: 'Completed']){
                if(leadFamilyMap .containsKey(dbdsfsLead.dsfs__Lead__c)){
                    dbdsfsLead.dsfs__Contact__c = leadFamilyMap.get(dbdsfsLead.dsfs__Lead__c).ConvertedContactId;
                    dsfsList.add(dbdsfsLead );
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
                                        Version_Id__c, WIP__c from Lead_File__c where Parent__c in: convertedLeadIds]){
               
                cg__ContactFile__c cFile=new cg__ContactFile__c();
                
                cFile.cg__Contact__c = leadFamilyMap.get(leadFile.Parent__c).ConvertedContactId;
                cFile.cg__Content_Type__c = leadFile.Content_Type__c;
                cFile.cg__Description__c = leadFile.Description__c;
                cFile.cg__File_Name__c = leadFile.File_Name__c;
                //cFile.cg__File_Size__c = leadFile.File_Size__c;
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
        
        if(ConFileList.size() > 0)
        {
            insert ConFileList;
        }
        if(siblingList.size() > 0)
            insert siblingList;
        
        if(siblingList.size() > 0){
            for(Contact processsiblingList : siblingList){
                npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                newRelationShip.npe4__Contact__c = processsiblingList .Id;
                newRelationShip.npe4__Type__c = 'Sibling';
                newRelationShip.npe4__RelatedContact__c = processsiblingList.Wish_Child_Id_Hidden__c;
                newRelationShip.npe4__Status__c = 'Active';
                relationShipList.add(newRelationShip);
            }
        }
        if(updateAcccountList.size() > 0)
            update updateAcccountList;
        if(dsfsList.size() > 0)
            update dsfsList;
        if(partACaseList.Size() > 0)
            update partACaseList;
        if(conMap.size() > 0)
            update conMap.values();
        if(caseList.size() > 0)
            insert caseList;
        if(relationShipList.size() > 0)
            insert relationShipList;
        if(rushReminderList.size() > 0)
            insert rushReminderList;
        if(leadIdSet.size() > 0){
            dupeCheckonAccount(convertedLeadIds);
        }
    } 
    
    
    public void dupeCheckonAccount(Set<Id> convertedLeadIds){
        Set<String> medicalfacilytySet = new Set<String>();
        Set<String> treatingfacilytySet = new Set<String>();
        for(Lead  processconvertedLeads : [SELECT ID,Name,Hospital_Treatment_Facility__c,Medical_Provider_Category__c,Hospital_Treatment_Facility_Treating__c,Medical_Professional_Last_Name__c,Medical_Professional_Phone__c,
                                           Medical_Professional_Email__c,Medical_Professional_First_Name__c,Treating_Medical_Professional_First_Name__c,Treating_Medical_Professional_Last_Name__c,
                                           Treating_Medical_Professional_Phone__c,Treating_Medical_Professional_Email__c,ConvertedContactId,ConvertedAccountId,Parent_First_Name__c,Parent_Last_Name__c,Email,Phone,CountryCode,  
                                           Street,StateCode,City,PostalCode,Wish_Family_ContactId__c,Treating_Medical_Professional_Contact_Id__c,Medical_Professional_ContactId__c FROM Lead WHERE Id IN:convertedLeadIds ]){
                                               
                                               medicalfacilytySet.add(processconvertedLeads.Hospital_Treatment_Facility__c);
                                               treatingfacilytySet.add(processconvertedLeads.Hospital_Treatment_Facility_Treating__c);
                                               convertedLeadList.add(processconvertedLeads);
                                           }
        for(Account dbAccount : [SELECT id,Name,RecordTypeId FROM Account WHERE RecordTypeId =: organizationRecordTypeId AND (Name IN: medicalfacilytySet OR Name IN: treatingfacilytySet)]){
            medicalAccountMap.put(dbAccount.Name,dbAccount);
            
        }
        
        for(Lead  processconvertedLeads :  [SELECT ID,Name,Hospital_Treatment_Facility__c,Hospital_Treatment_Facility_Treating__c FROM Lead WHERE Id IN:convertedLeadIds]){
            
            if(processconvertedLeads.Hospital_Treatment_Facility__c != processconvertedLeads.Hospital_Treatment_Facility_Treating__c){
                if(processconvertedLeads.Hospital_Treatment_Facility__c != Null){
                    if(!medicalAccountMap.containsKey(processconvertedLeads.Hospital_Treatment_Facility__c)){
                        Account newAccount = new Account();
                        newAccount.Name = processconvertedLeads.Hospital_Treatment_Facility__c;
                        newAccount.RecordTypeId = organizationRecordTypeId;
                        newAccountMap.put(newAccount.Name,newAccount);
                    }
                }
                if(processconvertedLeads.Hospital_Treatment_Facility_Treating__c!= Null){
                    if(!medicalAccountMap.containsKey(processconvertedLeads.Hospital_Treatment_Facility_Treating__c)){
                        Account newAccount = new Account();
                        newAccount.Name = processconvertedLeads.Hospital_Treatment_Facility_Treating__c;
                        newAccount.RecordTypeId = organizationRecordTypeId;
                        newAccountMap.put(newAccount.Name,newAccount);
                    }
                }
            }
            
            else{
                
                if(!medicalAccountMap.containsKey(processconvertedLeads.Hospital_Treatment_Facility_Treating__c)){
                    if(processconvertedLeads.Hospital_Treatment_Facility_Treating__c != Null){
                    Account newAccount = new Account();
                    newAccount.Name = processconvertedLeads.Hospital_Treatment_Facility_Treating__c;
                    newAccount.RecordTypeId = organizationRecordTypeId;
                    newAccountMap.put(newAccount.Name,newAccount);
                    }
                }
                
            }
        }
        
        if(newAccountMap.Size() > 0){
            insert newAccountMap.Values();
            dupeCheckonContact(convertedLeadList);
        }
        if(medicalAccountMap.size() > 0){
            dupeCheckonContact(convertedLeadList);
        }
        
    }
     public void dupeCheckonContact(List<Lead>convertedLeadList)
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
        Set<String> FamilyContactLastNameSet = new Set<String>();
        List<Contact> referringContact = new List<Contact>();
        List<Contact> newSameContact = new List<Contact>();
        List<Contact> qualifyingContact = new List<Contact>();
        List<Contact> WishFamilyContactList = new List<Contact>();
        List<npe4__Relationship__c> relationList = new List<npe4__Relationship__c>();
        Id convertedConId;
        for(Lead processConvertedLead : convertedLeadList){
            convertedConId = processConvertedLead.ConvertedContactId;
            if(processConvertedLead.Treating_Medical_Professional_First_Name__c == processConvertedLead.Medical_Professional_First_Name__c && processConvertedLead.Treating_Medical_Professional_Last_Name__c == processConvertedLead.Medical_Professional_Last_Name__c && 
               (processConvertedLead.Treating_Medical_Professional_Phone__c == processConvertedLead.Medical_Professional_Phone__c ||processConvertedLead.Treating_Medical_Professional_Email__c == processConvertedLead.Medical_Professional_Email__c)){
                   
                   sameReferringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                   sameReferringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                   sameReferringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                   sameReferringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
               }
            else{
                if(processConvertedLead.Treating_Medical_Professional_Last_Name__c != Null && processConvertedLead.Treating_Medical_Professional_Contact_Id__c == Null){
                    referringFirstNameSet.add(processConvertedLead.Treating_Medical_Professional_First_Name__c);
                    referringLastNameSet.add(processConvertedLead.Treating_Medical_Professional_Last_Name__c);
                    referringPhoneNameSet.add(processConvertedLead.Treating_Medical_Professional_Phone__c);
                    referringEmailNameSet.add(processConvertedLead.Treating_Medical_Professional_Email__c);
                }
                
                if(processConvertedLead.Medical_Professional_Last_Name__c != Null && processConvertedLead.Medical_Professional_ContactId__c == Null){
                    qualifyFirstNameSet.add(processConvertedLead.Medical_Professional_First_Name__c); 
                    qualifyLastNameSet.add(processConvertedLead.Medical_Professional_Last_Name__c);
                    qualifyPhoneNameSet.add(processConvertedLead.Medical_Professional_Phone__c);
                    qualifyEmailNameSet.add(processConvertedLead.Medical_Professional_Email__c); 
                }
            }
            
            if(processConvertedLead.Parent_Last_Name__c != Null && processConvertedLead.Wish_Family_ContactId__c == Null){
                FamilyContactLastNameSet.add(processConvertedLead.Parent_Last_Name__c);
            }
        }
        
        if(FamilyContactLastNameSet.size() > 0){
            for(Lead processConvertedLead : convertedLeadList){
                Contact newWishFamily = new Contact();
                newWishFamily.FirstName= processConvertedLead.Parent_First_Name__c;
                newWishFamily.LastName = processConvertedLead.Parent_Last_Name__c;
                newWishFamily.Email = processConvertedLead.Email;
                newWishFamily.Phone = processConvertedLead.Phone;
                newWishFamily.MailingCountryCode = processConvertedLead.CountryCode;
                newWishFamily.MailingStreet = processConvertedLead.Street;
                newWishFamily.MailingStateCode = processConvertedLead.StateCode;
                newWishFamily.MailingCity= processConvertedLead.City;
                newWishFamily.MailingPostalCode = processConvertedLead.PostalCode;
                newWishFamily.Wish_Child_Id_Hidden__c = processConvertedLead .ConvertedContactId;
                newWishFamily.AccountId = processConvertedLead.ConvertedAccountId;
                newWishFamily.RecordTypeId = wishFamilyRecordTypeId;
                WishFamilyContactList.add(newWishFamily);
            }
            if(WishFamilyContactList.size() > 0){
                insert WishFamilyContactList;
                
                for(Contact processFamilyContact : WishFamilyContactList){
                    
                    npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                    newRelationShip.npe4__Contact__c = processFamilyContact .Id;
                    newRelationShip.npe4__Type__c = 'Family';
                    newRelationShip.npe4__RelatedContact__c = processFamilyContact.Wish_Child_Id_Hidden__c;
                    newRelationShip.npe4__Status__c = 'Active';
                    relationList.add(newRelationShip);
                }
                
            }
        }
        if(sameReferringFirstNameSet.Size()>0 && sameReferringLastNameSet.size() > 0 && (sameReferringPhoneNameSet.size() > 0 || sameReferringEmailNameSet.size() > 0)){
            List<npe4__Relationship__c> sameNameRelationList = new List<npe4__Relationship__c>();
            for(Lead processConvertedLead : convertedLeadList){
                contact newMedicalcon = new contact();
                newMedicalcon.FirstName = processConvertedLead.Treating_Medical_Professional_First_Name__c;
                newMedicalcon.LastName = processConvertedLead.Treating_Medical_Professional_Last_Name__c;
                if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
                    newMedicalcon.AccountId = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                if(newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
                    newMedicalcon.AccountId = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                newMedicalcon.Phone = processConvertedLead.Treating_Medical_Professional_Phone__c;
                newMedicalcon.Email = processConvertedLead.Treating_Medical_Professional_Email__c;
                newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                newSameContact.add(newMedicalcon);
            }
            
            
            if(newSameContact .size() > 0){
                insert newSameContact ;
                for(Contact proccessSameContact : newSameContact ){
                    npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                    newRelationShip.npe4__Contact__c = convertedConId;
                    newRelationShip.npe4__Type__c = 'Medical Professional';
                    newRelationShip.Referring_Medical_Professional__c = true;
                    newRelationShip.Qualifying_Medical_Professional__c = true;
                    newRelationShip.npe4__RelatedContact__c = proccessSameContact.Id;
                    newRelationShip.npe4__Status__c = 'Active';
                    relationList.add(newRelationShip);
                    
                }
                
            }
        }  
        if(referringFirstNameSet.size() > 0 && referringLastNameSet.Size() > 0 && (referringPhoneNameSet.Size() > 0 || referringEmailNameSet.Size() > 0)){
            List<npe4__Relationship__c> referringRelationList = new List<npe4__Relationship__c>();
            for(Lead processConvertedLead : convertedLeadList){
                contact newMedicalcon = new contact();
                newMedicalcon.FirstName = processConvertedLead.Treating_Medical_Professional_First_Name__c;
                newMedicalcon.LastName = processConvertedLead.Treating_Medical_Professional_Last_Name__c;
                if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
                    newMedicalcon.AccountId = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                if(newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility_Treating__c))
                    newMedicalcon.AccountId = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility_Treating__c).Id;
                newMedicalcon.Phone = processConvertedLead.Treating_Medical_Professional_Phone__c;
                newMedicalcon.Email = processConvertedLead.Treating_Medical_Professional_Email__c;
                newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                referringContact.add(newMedicalcon);
            }
            
            
            if(referringContact .size() > 0){
                insert referringContact ;
                for(Contact proccessSameContact : referringContact ){
                    npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                    newRelationShip.npe4__Contact__c = convertedConId;
                    newRelationShip.npe4__Type__c = 'Medical Professional';
                    newRelationShip.Qualifying_Medical_Professional__c = true;
                    newRelationShip.npe4__RelatedContact__c = proccessSameContact.Id;
                    newRelationShip.npe4__Status__c = 'Active';
                    relationList.add(newRelationShip);
                    
                }
                
                
            }
        }
        
        
        
        if(qualifyFirstNameSet.size() > 0 && qualifyLastNameSet.Size() > 0 && (qualifyPhoneNameSet.Size() > 0 || qualifyEmailNameSet.Size() > 0)){
            List<npe4__Relationship__c> qualifyingRelationList = new List<npe4__Relationship__c>();
            for(Lead processConvertedLead : convertedLeadList){
                contact newMedicalcon = new contact();
                newMedicalcon.FirstName = processConvertedLead.Medical_Professional_First_Name__c;
                newMedicalcon.LastName = processConvertedLead.Medical_Professional_Last_Name__c;
                if(medicalAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility__c))
                    newMedicalcon.AccountId = medicalAccountMap.get(processConvertedLead .Hospital_Treatment_Facility__c).Id;
                if(newAccountMap.containsKey(processConvertedLead .Hospital_Treatment_Facility__c))
                    newMedicalcon.AccountId = newAccountMap.get(processConvertedLead .Hospital_Treatment_Facility__c).Id;
                newMedicalcon.Phone = processConvertedLead.Medical_Professional_Phone__c;
                newMedicalcon.Email = processConvertedLead.Medical_Professional_Email__c;
                newMedicalcon.Provider_Type__c  = processConvertedLead.Medical_Provider_Category__c;
                newMedicalcon.RecordTypeId = medicalProfessionalRecordTypeId;
                qualifyingContact.add(newMedicalcon);
            }
            
            
            if(qualifyingContact.size() > 0){
                insert qualifyingContact;
                for(Contact proccessSameContact : qualifyingContact ){
                    npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
                    newRelationShip.npe4__Contact__c = convertedConId;
                    newRelationShip.npe4__Type__c = 'Medical Professional';
                    newRelationShip.Referring_Medical_Professional__c = true;
                    newRelationShip.npe4__RelatedContact__c = proccessSameContact.Id;
                    newRelationShip.npe4__Status__c = 'Active';
                    relationList.add(newRelationShip);
                }
                
            }
        } 
        if(relationList.size() > 0)
            insert relationList;
    }
    public static void UpdateChatperName(Set<String> postalCodesSet,List<Lead> updateChapterOnLeadList)
    {
        Map<String,String> zipCodeChapterMap = new Map<String,String>();
        for(Zip_Code__c currZipCode :  [SELECT id, Name,Office__r.Chapter__c FROM Zip_Code__c WHERE Name IN :postalCodesSet])
        {
            zipCodeChapterMap.put(currZipCode.Name,currZipCode.Office__r.Chapter__c);
        }
        
        for(Lead currLead : updateChapterOnLeadList)
        {
            if(zipCodeChapterMap.containsKey(currLead.PostalCode))
            {
                currLead.ChapterName__c = zipCodeChapterMap.get(currLead.PostalCode);
            }
            else
            {
                currLead.ChapterName__c = Null;
            }
        }
        
    }
    
    Public static void ToUpdateMedicalInfo(Set<String> conditionDescriptionsSet,Set<String> icdCodesSet,List<Lead> leadUpdateToMedicalInfoList)
    {
        if(icdCodesSet.size() > 0)
        {
            Map<String, ICD_Codes__c> icdCodesMap = new Map<String, ICD_Codes__c>();
            for(ICD_Codes__c currRec : [SELECT Id,Name, Long_Description__c, Short_Description__c, Condition_Description__r.MAW_Name__c,Group1__c,
                                        Condition_Description__c, Condition_Description__r.Code_to_Use__c,Condition_Description__r.Name
                                        FROM ICD_Codes__c WHERE Name IN :icdCodesSet])
            {
                icdCodesMap.put(currRec.Name,currRec);
            }
            for(Lead currLead : leadUpdateToMedicalInfoList)
            {
                if(icdCodesMap.containsKey(currLead.ICD_10_Code__c))
                {
                    currLead.Short_Description__c = icdCodesMap.get(currLead.ICD_10_Code__c).Short_Description__c;
                    currLead.Long_Description__c = icdCodesMap.get(currLead.ICD_10_Code__c).Long_Description__c;
                    currLead.Group_1__c  = icdCodesMap.get(currLead.ICD_10_Code__c).Group1__c ;
                    if(icdCodesMap.get(currLead.ICD_10_Code__c).Condition_Description__c != Null)
                    {
                        currLead.Primary_Diagnosis__c = icdCodesMap.get(currLead.ICD_10_Code__c).Condition_Description__r.Name;
                        currLead.Childs_Qualifying_Diagnosis__c = icdCodesMap.get(currLead.ICD_10_Code__c).Condition_Description__r.Code_to_Use__c;
                    }
                }
            }
        }
        if(conditionDescriptionsSet.size() > 0)
        {
            Map<String, Condition_Description__c> descriptionMap = new Map<String, Condition_Description__c>();
            for(Condition_Description__c currRec : [SELECT Id, MAW_Name__c, Name FROM Condition_Description__C WHERE Name IN :conditionDescriptionsSet])
            {
                descriptionMap.put(currRec.Name,currRec);
            }
            for(Lead currLead : leadUpdateToMedicalInfoList)
            {
                if(descriptionMap.containsKey(currLead.Primary_Diagnosis__c))
                {
                    currLead.Maw_Name__c = descriptionMap.get(currLead.Primary_Diagnosis__c).MAW_Name__c;
                    
                }
            }
        }
        
    }
    
    public static void findDuplicateRecords(List<Lead> leadList)
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
        
        for(Lead currLead : leadList)
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
                           AND Id NOT IN :leadIds])
        {
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
        for(Contact exContact : [SELECT Id, LastName,AccountId, FirstName, Email, Phone, BirthDate, chapter_Name__C,
                                 MailingCity, MailingState, MailingPostalCode 
                                 FROM Contact WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR BirthDate IN :leadbDaysSet
                                                     OR ((MailingState IN :stateSet AND MailingPostalCode IN :zipCodesSet AND MailingCity IN :citySet) OR 
                                                         Phone IN :phoneSet OR Email IN :emailsSet)) AND chapter_Name__C = :chaptersSet])
        {
            if(exContact.FirstName != Null)
                exFNamesSet.add(exContact.FirstName+'-'+exContact.chapter_Name__c);
            if(exContact.LastName != Null)
                exLNamesSet.add(exContact.LastName+'-'+exContact.chapter_Name__c);
            if(exContact.BirthDate != Null)
                exbDaysSet.add(exContact.BirthDate);
            if(exContact.MailingCity != Null && exContact.MailingState != Null && exContact.MailingPostalCode != Null)
                exAddressSet.add(exContact.MailingCity+'-'+exContact.MailingState+'-'+exContact.MailingPostalCode+'-'+exContact.chapter_Name__c);
            if(exContact.phone != Null)
                exPhoneSet.add(exContact.phone+'-'+exContact.chapter_Name__C);
            if(exContact.Email != Null)
                exemailsSet.add(exContact.Email+'-'+exContact.chapter_Name__C);
        }
        
        for(Lead newLead : leadList)
        {  
        
           if(newLead.id == Null)
           {
             if(exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c) && exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c) && 
                exbDaysSet.contains(newLead.Dob__c) && ((exAddressSet.contains(newLead.City+'-'+newLead.State+'-'+newLead.PostalCode+'-'+newLead.chapterName__c))
                || exPhoneSet.contains(newLead.Phone+'-'+newLead.chapterName__c) 
                || exemailsSet.contains(newLead.Email+'-'+newLead.chapterName__c)))
              {
                newLead.addError('There might be a duplicate Wish Child. If you want to create a record, Please choose No Duplicate Found field.');
              }
           }
            
            else if(newLead.id != Null && exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c) &&  (exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c)))
            {
               newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            else if(newLead.id != Null && ((exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c) ||  exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c)) 
                    && ((exAddressSet.contains(newLead.City+'-'+newLead.State+'-'+newLead.PostalCode+'-'+newLead.chapterName__c) 
                         || exPhoneSet.contains(newLead.Phone+'-'+newLead.chapterName__c) || exemailsSet.contains(newLead.Email+'-'+newLead.chapterName__c)))))
            {
                newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            
            else if(newLead.id != Null && (exbDaysSet.contains(newLead.Dob__c) &&  ((exAddressSet.contains(newLead.City+'-'+newLead.State+'-'+newLead.PostalCode+'-'+newLead.chapterName__c) 
                                                              || exPhoneSet.contains(newLead.Phone+'-'+newLead.chapterName__c) || exemailsSet.contains(newLead.Email+'-'+newLead.chapterName__c)))))
            {
               newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            else if(newLead.id != Null && ((exbDaysSet.contains(newLead.Dob__c) && exLNamesSet.contains(newLead.LastName+'-'+newLead.chapterName__c))))
            { 
                newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
            
            else if(newLead.id != Null && (exbDaysSet.contains(newLead.Dob__c) && exFNamesSet.contains(newLead.FirstName+'-'+newLead.chapterName__c)))
            {
               newLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'>here </a> to review the duplicates.',false); 
            }
        }
        
    } 
    
    
    public void CreateNewCase(List<Lead> LeadList){
        List<Case> newCaseList = new List<Case>();
        Map<Id,String> accountEmailMap = new Map<Id,String>();
        set<Id> accountIdSet = new Set<Id>();
        
        for(Lead processLead : LeadList){
            
            case newcase = new case();
            newCase.status = 'Open';
            newCase.origin = 'Email';
            newCase.recordTypeId = partARecordTypeId;
            newCase.OwnerId = processLead.OwnerId;
            newCase.Lead__c = processLead.id;
            newCase.AccountId = processLead.ChapterName__c;
            newCaseList.add(newcase);
        }
        
        if(newCaseList.Size() > 0)
            insert newCaseList;
    }
    public String getRandom()
    {
        Integer len=6;
        final String chars='0123456789';
        String randStr='';
        While(randStr.length() < len)
        {
            Integer idx=Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    public void updateLeadStatus(List<Lead> medicalList){
        System.debug('MedicalList>>>>>>>>>');
        List<Lead> updateLeadList = new List<Lead>();
        Lead newLead = new Lead();
        for(Lead processMedicalQuestion :medicalList){
            String medicalQuestion = processMedicalQuestion.Medical_Questions__c;
            
            if(medicalQuestion.contains('Yes')){
                System.debug('Yes>>>>>>>>>');
                processMedicalQuestion.RFI_Form_Info_Hidden__c = 'Qualified';
                updateLeadList.add(processMedicalQuestion);
            }
            else{
                System.debug('No>>>>>>>>>');
                processMedicalQuestion.RFI_Form_Info_Hidden__c = 'Not Qualified';
                updateLeadList.add(processMedicalQuestion);
            }
        }
        
        
    }
    
}