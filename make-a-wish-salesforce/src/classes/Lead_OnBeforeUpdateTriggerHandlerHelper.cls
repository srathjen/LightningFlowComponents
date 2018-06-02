/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description :

Modification Log:
1. 26/03/2018 - Vignesh SM - IME 18 - Line No 221
2. 27/03/2018 - Yuvraj - IME-60 Line No 566-616
3. 29/03/2018 - Vignesh - IME 58 - Line No 637-657
4. 06/04/2018 - Vignesh SM - IME 9 - Line No 242-249
5. 17/04/2018 - Vignesh SM - IME 97 - Line No.225
6. 23/04/2018 - Vignesh SM - IME 110
*****************************************************************************************************/
Public class Lead_OnBeforeUpdateTriggerHandlerHelper{
    
    /****************************************************************************************
Used to update the hidden chapter name value.
******************************************************************************************/  
    public static void updateHiddenchapterName(Set<id> accountIdSet,List<Lead> leadList){
        Map<Id,Account> accountNameMap = new Map<Id,Account>();
        try{
            for(Account currAcc  : [SELECT id,Name,Intake_Manager__r.Email,Intake_Manager__c FROM Account WHERE Id IN :accountIdSet Limit 50000]){
                accountNameMap.put(currAcc.Id,currAcc);
            }
            for(Lead currLead :leadList){
                if(accountNameMap.containsKey(currLead.ChapterName__c)){
                    currLead.Hidden_Chapter_Name__c = accountNameMap.get(currLead.ChapterName__c).Name;
                    
                }
                
            }
        }
        
        catch(Exception ex){
            for(Lead currRec : leadList){
               ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateHiddenchapterName',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec : leadList){
               currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /****************************************************************************************
Used to populated Condition Description based on ICD Code values
******************************************************************************************/  
    public static void MatchConditionDescription(Map<Id, Set<Integer>> icdInfoMap, List<Lead> leadRecList, Set<Id> icdCodeRecSet) {
        Map<Id, ICD_Codes__c> icdCodeDetails = new Map<Id, ICD_Codes__c>();
        try{
            for(ICD_Codes__c icdInfo : [SELECT Id, Name, Group1__c,
                                        Condition_Description__c, Condition_Description__r.Code_to_Use__c, Condition_Description__r.Name
                                        FROM ICD_Codes__c WHERE Id IN : icdCodeRecSet]){
                                            icdCodeDetails.put(icdInfo.Id, icdInfo);
                                        }
            for(Lead updatePD : leadRecList) {
                if(icdInfoMap.containsKey(updatePD.Id)) {
                    for(Integer icdField : icdInfoMap.get(updatePD.Id)) {
                        if(icdField == 1 && icdCodeDetails.containsKey(updatePD.SD1_ICD_Code__c)) {
                            updatePD.SD1_Condition_Description__c = icdCodeDetails.get(updatePD.SD1_ICD_Code__c).Condition_Description__r.Name;
                        } if(icdField == 2 && icdCodeDetails.containsKey(updatePD.SD2_ICD_Code__c)) {
                            updatePD.SD2_Condition_Description__c = icdCodeDetails.get(updatePD.SD2_ICD_Code__c).Condition_Description__r.Name;
                        } if(icdField == 3 && icdCodeDetails.containsKey(updatePD.SD3_ICD_Code__c)) {
                            updatePD.SD3_Condition_Description__c = icdCodeDetails.get(updatePD.SD3_ICD_Code__c).Condition_Description__r.Name;
                        } if(icdField == 4 && icdCodeDetails.containsKey(updatePD.SD4_ICD_Code__c)) {
                            updatePD.SD4_Condition_Description__c = icdCodeDetails.get(updatePD.SD4_ICD_Code__c).Condition_Description__r.Name;
                        }
                    }
                }
            }
        }
        
        catch(Exception ex){
            
            for(Lead currRec : leadRecList){
             ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'MatchConditionDescription',currRec.Id,ex.getStackTraceString(),'Error');
            }
           for(Lead currRec : leadRecList){
             currRec.addError(Label.Debug_log_error_message);
           }
        }
    }
    
    /***************************************************************************************************
This updateLeadOwner method is used to update the lead owner when the lead chapter name is updated.
***************************************************************************************************/
    public static void updateLeadOwner(List<Lead> leadsToupdateList, Set<String> chaptersSet)
    {
        Map<Id,Account> chapterMap = new Map<Id,Account>([SELECT id,Intake_Manager__c FROM Account WHERE id IN :chaptersSet]);
        
        try{
            for(Lead currLead : leadsToUpdateList)
            {
                if(chapterMap.containsKey(currLead.ChapterName__c))
                {
                    if(chapterMap.get(currLead.ChapterName__c).Intake_Manager__c != Null)
                        currLead.OwnerId = chapterMap.get(currLead.ChapterName__c).Intake_Manager__c;
                    else
                        currLead.OwnerId = label.Salesforce_Support_User_Id;
                }
            }
        }
        
        catch(Exception ex){
           
            for(Lead currRec : leadsToUpdateList){
             ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateLeadOwner',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec : leadsToUpdateList){
             currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /*****************************************************************************************************
This ToUpdateMedicalInfo() method is used to update the chaptername on medical proff contact. 
if the zipcode value is updated.
* ***************************************************************************************************/
    Public static void ToUpdateMedicalInfo(Set<String> conditionDescriptionsSet,Set<String> icdCodesSet,List<Lead> leadUpdateToMedicalInfoList)
    {
        
        Map<Id, String> conditionInfoMap = new Map<Id, String>();
        Set<Id> conditionDescriptionIdSet = new Set<Id>();
        Map<String, ICD_Codes__c> icdCodesMap = new Map<String, ICD_Codes__c>();
        try{
            if(icdCodesSet.size() > 0)
            {   
                
                for(ICD_Codes__c currRec : [SELECT Id,Name, Condition_Description__r.PR_Diagnosis__c,Group1__c,
                                            Condition_Description__c, Condition_Description__r.Code_to_Use__c,Condition_Description__r.Name
                                            FROM ICD_Codes__c WHERE Id IN :icdCodesSet])
                {
                    icdCodesMap.put(currRec.Id,currRec);
                    if(currRec.Condition_Description__c != null) {
                        conditionDescriptionIdSet.add(currRec.Condition_Description__c);
                    }
                }
                Map<Id,Set<Id>> iCDforCondionDescMap = new Map<Id, Set<Id>>();
                for(ICD_Codes__c icdInfo : [SELECT Id, Condition_Description__c FROM ICD_Codes__c WHERE Condition_Description__c IN :conditionDescriptionIdSet]) {
                    if(iCDforCondionDescMap.containsKey(icdInfo.Condition_Description__c)) {
                        iCDforCondionDescMap.get(icdInfo.Condition_Description__c).add(icdInfo.Id);
                    } else {
                        iCDforCondionDescMap.put(icdInfo.Condition_Description__c, new Set<Id>{icdInfo.Id});
                    }
                }
                for(Lead currLead : leadUpdateToMedicalInfoList)
                {
                    if(icdCodesMap.containsKey(currLead.Qualifying_ICD__c ))
                    {   //Removed Childs_Qualifying_Diagnosis__c as per IME-120
                        if(icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c != Null)
                        {
                            currLead.Qualifying_Diagnosis__c = icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__r.Name;
                            //currLead.Childs_Qualifying_Diagnosis__c = icdCodesMap.get(currLead.PD_ICD_Code__c).Condition_Description__r.Code_to_Use__c;
                        } else {
                            currLead.Qualifying_Diagnosis__c = '';
                            //currLead.Childs_Qualifying_Diagnosis__c = icdCodesMap.get(currLead.PD_ICD_Code__c).Condition_Description__r.Code_to_Use__c;
                        }
                    }
                    if(currLead.Qualifying_ICD__c != null) {
                        if(icdCodesMap.containsKey(currLead.Qualifying_ICD__c) && icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c != null) {
                            currLead.PR_Diagnosis__c = icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__r.PR_Diagnosis__c;
                            if(iCDforCondionDescMap.containsKey(icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c)) {
                                if(iCDforCondionDescMap.get(icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c).contains(currLead.Qualifying_ICD__c)) {
                                    currLead.Qualifying_Diagnosis__c = icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__r.Name;
                                }
                            }
                        }
                    }
                }
            }
            if(conditionDescriptionsSet.size() > 0){
                Map<String, Condition_Description__c> descriptionMap = new Map<String, Condition_Description__c>();
                for(Condition_Description__c currRec : [SELECT Id, PR_Diagnosis__c, Name
                                                        FROM Condition_Description__C
                                                        WHERE Name IN :conditionDescriptionsSet])
                {
                    descriptionMap.put(currRec.Name,currRec);
                }
                for(Lead currLead : leadUpdateToMedicalInfoList)
                {
                    if(descriptionMap.containsKey(currLead.Qualifying_Diagnosis__c))
                    {
                        currLead.PR_Diagnosis__c = descriptionMap.get(currLead.Qualifying_Diagnosis__c).PR_Diagnosis__c;
                    }
                }
            }
        }
        
        catch(Exception ex){
            
            for(Lead currRec : leadUpdateToMedicalInfoList){
               ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'ToUpdateMedicalInfo',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec : leadUpdateToMedicalInfoList){
                  currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /*********************************************************************************************************
This CreateNewCase method is used to create a new elegibility review case when the lead status is updated
as elegibility review.
***********************************************************************************************************/
    public static void CreateNewCase(List<Lead> LeadList){
        Constant_AC  constant = new Constant_AC();
        List<Case> newCaseList = new List<Case>();
        Map<Id,String> accountEmailMap = new Map<Id,String>();
        set<Id> accountIdSet = new Set<Id>();
        Map<Id,String> emailMap = new Map<Id,String>();
        Id chapterecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
        Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();
        //IME-1
        String nationalAdviser = System.Label.MedicalAdviser;
        Id nationAdvisorQueueId = [Select Id from Group where name = :nationalAdviser].id;
        try{
            for(Lead process : LeadList){
                accountIdSet.add(process.ChapterName__c);
            }
            if(accountIdSet.size() > 0){
                for(Account dbChapterAcc : [SELECT Id,MAC_Email_del__c,RecordTypeId FROM Account WHERE Id IN:accountIdSet AND RecordTypeId =: chapterecordTypeId]){
                    emailMap.put(dbChapterAcc.Id,dbChapterAcc.MAC_Email_del__c);
                }
            }
            for(Lead processLead : LeadList){
                system.debug('@@@ processLead.Name @@@'+processLead);
                case newcase = new case();
                newCase.status = 'New'; //Modified as per IME 18 
                newCase.origin = 'Email';
                newCase.Subject = processLead.FirstName+' '+processLead.LastName+ ' - Eligibility Review'; //Modified as per IME 97
                newCase.recordTypeId = partARecordTypeId;
                //newCase.OwnerId = processLead.OwnerId; 
                newCase.OwnerId = nationAdvisorQueueId; //Assigning case owner to queue as per IME-1.
                newCase.Hidden_Why_do_you_feel__c = processLead.Why_do_you_feel_would_be_eligible_Wish__c;
                if(emailMap.containsKey(processLead.ChapterName__c)){
                    newCase.MAC_Email__c = emailMap.get(processLead.ChapterName__c);
                }
                newCase.Lead__c = processLead.id;
                newCase.AccountId = processLead.ChapterName__c;
                newCase.ChapterName__c = processLead.ChapterName__c;
                //IME-107 - Changed Is_We_Need_To_Expedite_The_Process__c to Any_medical_reason_for_moving_quickly__c
                if(processLead.Any_medical_reason_for_moving_quickly__c == 'Yes') {
                    newCase.Rush__c = True;
                    newCase.Rush_Explanation__c = processLead.Please_Explain__c;
                    newCase.Rush_Timeframe__c = 'Select timeframe';
                    newCase.Diagnosis_Verification_Receive_Date__c = processLead.Part_A_Received__c;               
                }
                //IME 9
                if(processlead.Any_medical_reason_for_moving_quickly__c != null){                                        
                    String medicalReason = processlead.Any_medical_reason_for_moving_quickly__c;
                    if(medicalReason.contains('Yes')){
                        newCase.Rush__c = true;
                    }
                }
                newCaseList.add(newcase);
            }
            if(newCaseList.Size() > 0)
                insert newCaseList;
        }
        
        catch(Exception ex){
        List<ErrorMessage__e> errorMessageList = new List<ErrorMessage__e>();
            for(Lead currRec : LeadList){
               ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'CreateNewCase',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec : LeadList){
                  currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /************************************************************************************************************
This findDuplicateRecords() method is fire if the lead status is "Reffered" and sub status is "Pending dignose verification".
It will display error message if any duplicate wishchild or wish family or medical proff contact is there.
*************************************************************************************************************/
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
        List<lead> noDupLeadRec = new List<Lead>();
        Constant_Ac constant = new Constant_AC();
        String wishChild = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        String instanceUrl = label.Instance_Url;
        User u = [Select ID,UserPreferencesLightningExperiencePreferred from User where id=:UserInfo.getUserId() LIMIT 1];

        try{
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
            List<Lead> exLeads = [SELECT Id,LastName,Street,FirstName, Email, chapterName__c,Phone, DOB__c,
                                  City,State,PostalCode FROM Lead 
                                  WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR DOB__c IN :leadbDaysSet
                                         OR Phone IN :phoneSet OR Email IN :emailsSet OR (State IN :stateSet AND Postalcode IN :zipCodesSet AND city IN :citySet)) 
                                  AND ChapterName__c IN :chaptersSet
                                  AND Id NOT IN :leadIds AND isConverted = false];
            
            List<Contact> exContacts = [SELECT Id, LastName,AccountId,MailingStreet,FirstName, Email, Phone, BirthDate,Region_Chapter__r.Name,
                                        MailingCity, MailingState, MailingPostalCode 
                                        FROM Contact WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR BirthDate IN :leadbDaysSet
                                                            OR ((MailingState IN :stateSet AND MailingPostalCode IN :zipCodesSet AND MailingCity IN :citySet) OR 
                                                                Phone IN :phoneSet OR Email IN :emailsSet)) AND Region_Chapter__c =: chaptersSet AND RecordTypeId = :wishChild]; 
            
            
            for(Lead currLead : leadList)
            {
                boolean isDuplicate = false;
                for(Lead exLead : exLeads)
                {
                    if(currLead.ChapterName__c == exLead.ChapterName__c)
                    {
                        if(currLead.FirstName == exLead.FirstName && currLead.LastName == exLead.LastName)
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        } 
                        else if((currLead.FirstName == exLead.FirstName || currLead.LastName == exLead.LastName) && 
                                ((currLead.Street == exLead.Street && currLead.State == exLead.State && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode) 
                                 || currLead.Phone == exLead.Phone || currLead.Email == exLead.Email))
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        }
                        else if((currLead.DOB__c == exLead.DOB__c) && 
                                ((currLead.Street == exLead.Street && currLead.State == exLead.State && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode) 
                                 || currLead.Phone == exLead.Phone || currLead.Email == exLead.Email))
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        }
                        else if((currLead.DOB__c == exLead.DOB__c) && (currLead.FirstName == exLead.FirstName || currLead.LastName == exLead.LastName))
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        }   
                    }
                }
                for(Contact exCon : exContacts)
                {
                    if(currLead.ChapterName__c == exCon.Region_Chapter__c)
                    {
                        if(currLead.FirstName == exCon.FirstName && currLead.LastName == exCon.LastName)
                        { 
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        } 
                        else if((currLead.FirstName == exCon.FirstName || currLead.LastName == exCon.LastName) && 
                                ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState && currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode) 
                                 || currLead.Phone == exCon.Phone || currLead.Email == exCon.Email))
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        }
                        else if((currLead.DOB__c == exCon.BirthDate) && 
                                ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState && currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode) 
                                 || currLead.Phone == exCon.Phone || currLead.Email == exCon.Email))
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        }
                        else if((currLead.DOB__c == exCon.BirthDate) && (currLead.FirstName == exCon.FirstName || currLead.LastName == exCon.LastName))
                        {
                            isDuplicate = True;
                            if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                                currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.',false); 
                            else
                                currLead.addError('There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+currLead.id+'>here </a> to review the duplicates.',false); 
                        }   
                    }
                }
                if(isDuplicate == false)
                    noDupLeadRec.add(currLead);
            }                           
            if(noDupLeadRec.size() > 0)
            {
                FindDupContacts(noDupLeadRec);
            }
        }
        catch(Exception ex){
       
            for(Lead currRec : leadList){
             ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'findDuplicateRecords',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Lead currRec :leadList){
             currRec.addError(Label.Debug_log_error_message);
            }
        }                       
    } 
    
    /************************************************************************************************************
This FindDupContacts() method is fire if the lead status is "Reffered" and sub status is "Pending dignose verification".
It will display error message if any duplicate wishchild or wish family or medical proff contact is there.
***************************************************************************************************************/
    public static void FindDupContacts(List<Lead> leadRecords)
    {
        Constant_AC  constant = new Constant_AC();
        Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id wishFamilyRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id medicalProfessionalRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Set<String> mProfessionalFName = new Set<String>();
        Set<String> mProfessionalLName = new Set<String>();
        Set<String> mProfessionalPhone = new Set<String>();
        Set<String> mProfessionalEmail = new Set<String>();
        Set<String> tProfessionalFName = new Set<String>();
        Set<String> tProfessionalLName = new Set<String>();
        Set<String> tProfessionalPhone = new Set<String>();
        Set<String> tProfessionalEmail = new Set<String>();
        Set<string> bestPhysicianFName = new Set<String>();
        Set<string> bestPhysicianLName = new Set<String>();
        Set<string> bestPhysicianEmail = new Set<String>();
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
        String instanceUrl = label.Instance_Url;
        User u = [Select ID,UserPreferencesLightningExperiencePreferred from User where id=:UserInfo.getUserId() LIMIT 1];
        
        try{
            for(Lead newLead : leadRecords)
            {
                mProfessionalFName.add(newLead.Medical_Professional_First_Name__c);
                mProfessionalLName.add(newLead.Medical_Professional_Last_Name__c);
                mProfessionalPhone.add(newLead.Medical_Professional_Phone__c);
                mProfessionalEmail.add(newLead.Medical_Professional_Email__c);
                tProfessionalFName.add(newLead.Treating_Medical_Professional_First_Name__c);
                tProfessionalLName.add(newLead.Treating_Medical_Professional_Last_Name__c);
                tProfessionalPhone.add(newLead.Treating_Medical_Professional_Phone__c);
                tProfessionalEmail.add(newLead.Treating_Medical_Professional_Email__c);
                leadFNamesSet.add(newLead.Parent_First_Name__c);
                leadLNamesSet.add(newLead.Parent_Last_Name__c);
                emailsSet.add(newLead.Email);
                phoneSet.add(newLead.Phone);
                zipCodesSet.add(newLead.PostalCode);
                stateSet.add(newLead.State);
                AddressSet.add(newLead.Street);
                citySet.add(newLead.City);
                leadbDaysSet.add(newLead.DOB__c);
                chaptersSet.add(newLead.chapterName__c);
                bestPhysicianFName.add(newLead.Best_Contact_for_Physician_First_Name__c);
                bestPhysicianLName.add(newLead.Best_Contact_for_Physician_Last_Name__c);
                bestPhysicianEmail.add(newLead.Best_contact_for_Physician_Email__c);
            }
            
            List<Contact> dupMedicalContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                                                MailingState, MailingPostalCode FROM Contact
                                                WHERE (FirstName IN :mProfessionalFName AND LastName IN :mProfessionalLName 
                                                       AND (Phone = :mProfessionalPhone Or Email IN :mProfessionalEmail) 
                                                       AND RecordTypeId = :MedicalProfessionalRT)];
            
            List<Contact> dupTreatingContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                                                 MailingState, MailingPostalCode FROM Contact
                                                 WHERE (FirstName IN :tProfessionalFName AND 
                                                        LastName IN :tProfessionalLName
                                                        AND (Phone = :tProfessionalPhone Or Email =: tProfessionalEmail) 
                                                        AND RecordTypeId = :MedicalProfessionalRT)]; 
            
            List<Contact> dupPhysicianContacts = [SELECT id,FirstName,LastName,Name,Email FROM Contact WHERE
                                                  FirstName IN :bestPhysicianFName AND LastName IN :bestPhysicianLName AND
                                                  Email IN:bestPhysicianEmail AND RecordTypeId = :MedicalProfessionalRT];
            
            List<Contact> dupFamilyContacts = [SELECT id, FirstName,Name, LastName, Email, Phone, MailingCity, BirthDate,
                                               MailingState, MailingPostalCode,MailingStreet FROM Contact
                                               WHERE (FirstName IN :leadFNamesSet AND LastName IN :leadLNamesSet AND 
                                                      (((Email IN :emailsSet OR Phone IN :phoneSet) 
                                                        AND (MailingStreet IN :AddressSet AND MailingState IN :stateSet 
                                                             AND MailingPostalCode IN :zipCodesSet 
                                                             AND MailingCity IN :citySet))  
                                                       OR ((Phone IN :phoneSet OR (MailingStreet IN :AddressSet AND MailingState = :stateSet 
                                                                                   AND MailingPostalCode IN :zipCodesSet 
                                                                                   AND MailingCity = :citySet))
                                                           AND Email = :emailsSet)  OR (((MailingStreet = :AddressSet AND MailingState = :stateSet 
                                                                                          AND MailingPostalCode = :zipCodesSet 
                                                                                          AND MailingCity = :citySet) OR (Email = :emailsSet) )
                                                                                        AND Phone = :phoneSet))) AND RecordTypeId = :wishFamilyRT];  
            
            for(Lead newLead : leadRecords)
            { 
                Boolean medicalFlag = false;
                boolean treatingFlag = false;
                boolean familyFlag = false;
                boolean physicianFlag = false;
                for(Contact medicalCon : dupMedicalContacts)
                {
                    if(medicalCon.FirstName == newLead.Medical_Professional_First_Name__c && 
                       medicalCon.LastName == newLead.Medical_Professional_Last_Name__c && 
                       (medicalCon.Phone == newLead.Medical_Professional_Phone__c || medicalCon.Email == newLead.Medical_Professional_Email__c))
                    {
                        medicalFlag = true;
                    }
                }  
                
                for(Contact treatingCon : dupTreatingContacts)
                {
                    if(treatingCon.FirstName == newLead.Treating_Medical_Professional_First_Name__c && 
                       treatingCon.LastName == newLead.Treating_Medical_Professional_Last_Name__c && 
                       (treatingCon.Phone == newLead.Treating_Medical_Professional_Phone__c || treatingCon.Email == newLead.Treating_Medical_Professional_Email__c))
                        
                    {
                        treatingFlag = true;
                    }
                }  
                for(Contact physicianCon : dupPhysicianContacts){
                    
                    if(physicianCon.FirstName == newLead.Best_Contact_for_Physician_First_Name__c && physicianCon.LastName == newLead.Best_Contact_for_Physician_Last_Name__c && physicianCon.Email== newLead.Best_Contact_for_Physician_Email__c ){
                        physicianFlag = True;   
                    }
                }
                for(Contact familyCon : dupFamilyContacts)
                {
                    if(familyCon.FirstName == newLead.Parent_First_Name__c && familyCon.LastName == newLead.Parent_Last_Name__c 
                       && (((familyCon.Phone == newLead.Phone || familyCon.Email == newLead.Email) 
                            && (familyCon.MailingStreet == newLead.Street
                                && familyCon.MailingState == newLead.State && familyCon.MailingCity == newLead.City 
                                && familyCon.MailingPostalCode == newLead.PostalCode)) || ((familyCon.Phone==newLead.Phone || (familyCon.MailingStreet == newLead.Street 
                                                                                                                               && familyCon.MailingState == newLead.State && familyCon.MailingPostalCode==newLead.PostalCode && familyCon.MailingCity == newLead.City))
                                                                                           && familyCon.Email == newLead.Email) || (((familyCon.MailingStreet == newLead.Street && familyCon.MailingState == newLead.State 
                                                                                                                                      && familyCon.MailingPostalCode == newLead.PostalCode && familyCon.MailingCity == newLead.City) || (familyCon.Email == newLead.Email) )
                                                                                                                                    && familyCon.Phone == newLead.Phone)))
                    {
                        familyFlag = true;
                    }
                }  
                if((medicalFlag == True || treatingFlag == True) && familyFlag == True && physicianFlag == True){
                    if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                        newLead.addError('There might be an existing Wish Family and Medical Professional. Please click Send Diagnosis Verification button to review the existing record.',false); 
                    else
                        newLead.addError('There might be an existing Wish Family and Medical Professional.Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'&wishFamily=true&manual=true'+'>here </a> to review the existing record.',false); 
                }
                else if(medicalFlag == True || treatingFlag == True) {
                    if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                        newLead.addError('There might be an existing Medical Professional. Please click Send Diagnosis Verification button to review the existing record.',false); 
                    else
                        newLead.addError('There might be an existing Medical Professional. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'&wishFamily=true&manual=true'+'>here </a> to review the existing record.',false); 
                }    
                
                else if(physicianFlag){
                    if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                        newLead.addError('There might be an existing Best Physician Contact. Please click Send Diagnosis Verification button to review the existing record.',false); 
                    else
                        newLead.addError('There might be an existing Best Physician Contact. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'&wishFamily=true&manual=true'+'>here </a> to review the existing record.',false); 
                }
                else if(familyFlag == True){
                    if(u.UserPreferencesLightningExperiencePreferred) //Modified as per IME 110
                        newLead.addError('There might be an existing Wish Family. Please click Send Diagnosis Verification button to review the existing record.',false); 
                    else
                        newLead.addError('There might be an existing Wish Family.Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newlead.id+'&wishFamily=true&manual=true'+'>here </a> to review the existing record.',false); 
                }                
            }                        
        }
        
        catch(Exception ex){
         
            for(Lead currRec : leadRecords){
               ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'FindDupContacts',currRec.Id,ex.getStackTraceString(),'Error');
            }
            
           for(Lead currRec : leadRecords){
                  currRec.addError(Label.Debug_log_error_message);
           }
        }
    }
    
    /***********************************************************************************************************
    IME-60 - This method will fire to check the specific fields are null/blank if the lead status changed to "Qualified"
    ***********************************************************************************************************/
    public static void preQualifiedRequired(List<Lead> leadList){
        String message = '';        
        
        for(Lead le : leadList){
            if(le.FirstName == null){ 
                if(message == '' || message == Null)
                    message = 'First Name';
            } 
            if(le.DOB__c == null){
                if(message == '' || message == Null)
                    message = 'DOB';
                else
                    message = message+', '+'DOB';
            }
            //Removed as per IME-120
            /*if(le.Childs_Qualifying_Diagnosis__c == null){
                if(message == '' || message == Null)
                    message = 'Child\'s Qualifying Diagnosis';
                else
                    message= message+', '+'Child\'s Qualifying Diagnosis';
            }*/
            if(le.Any_medical_reason_for_moving_quickly__c == null){
                if(message == '' || message == Null)
                    message = 'Potential Rush';
                else
                    message= message+', '+'Potential Rush'; 
            }
            if(le.Part_A_Received__c == null){
                if(message == '' || message == Null)
                    message = 'Diagnosis Verification Received';
                else
                    message= message+', '+'Diagnosis Verification Received'; 
            }
            if(le.I_am_Recognized_To_Practice_As_a__c == null){
                if(message == '' || message == Null)
                    message = 'I Am Recognized To Practice As A';
                else
                    message= message+', '+'I Am Recognized To Practice As A';
            }
            
            if(!String.isBlank(message)){
                for(Lead leadTemp : leadList){
                    if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                        leadTemp.addError('Please enter the values for the following fields - '+message+'.');
                    }  
                }
            }
        }
    }
    
     /****************************************************************************
    This getRandom() this method is used to generate random number. when the lead
    status is "Reffered" and sub status is "Pending dignouses verification"
    ****************************************************************************/
    public static String getRandom()
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
    //IME 58
    public static void createRushTask(List<Lead> leadList){
        Set<String> chapterName = new Set<String>();
        List<Task> newTaskList = new List<Task>();
        Map<String, Chapter_Name_Settings__c> chapterMap = Chapter_Name_Settings__c.getAll();
        
        for(Chapter_Name_Settings__c chapter: chapterMap.values()){
            chapterName.add(chapter.Name);
        }        
        for(Lead processLead: leadList){   
            if(chapterName.contains(processLead.Hidden_Chapter_Name__c)){                
                Task newRushTask = new Task(Description = 'New RUSH referral qualified',
                                            Priority = 'Normal', 
                                            Status = 'Completed',
                                            Subject = 'Lead ET : New Rush Qualified', 
                                            OwnerId =  label.Salesforce_Support_User_Id,
                                            ActivityDate = System.today(),
                                            WhoId = processLead.Id);
                newTaskList.add(newRushTask);
            }
        }       
        if(newTaskList.size() > 0){
            insert newTaskList;
        }        
    }
    
    //IME-107
    public static void createPotentialRushTask(List<Lead> leadList){
        List<Task> newTaskList = new List<Task>();
        for(Lead processLead: leadList){ 
            System.debug('IME 107 in for loop');
            Task newRushTask = new Task(Priority = 'Normal',
                                        Status = 'Not Started',
                                        Subject = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary', 
                                        OwnerId =  processLead.OwnerId,
                                        ActivityDate = System.today()+3,
                                        SystemGeneratedTask__c = true,
                                        WhoId = processLead.Id);
            newTaskList.add(newRushTask);
        }     
        if(newTaskList.size() > 0){
            insert newTaskList;
        }
    }
    //IME-120
    public static void updateQualifingDiagnosis(String ICDCode, List<Lead> leadList){
        List<ICD_Codes__c> icdCodeSet = [SELECT Id,Name,Condition_Description__r.Name,
                                         Condition_Description__r.PR_Diagnosis__c 
                                         FROM ICD_Codes__c WHERE Name =: ICDCode AND Group1__c = true LIMIT 1];
        if(IcdCodeSet.size() > 0){
            for(Lead newLead : leadList){
                newLead.Qualifying_ICD__c = icdCodeSet[0].Id;
                newLead.Qualifying_Diagnosis__c = icdCodeSet[0].Condition_Description__r.Name;
                newLead.PR_Diagnosis__c = icdCodeSet[0].Condition_Description__r.PR_Diagnosis__c; 
            }
        }
    }
}