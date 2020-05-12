/**********************************************************
Created by: Manoj Tammineny
Created Date : 04/05/2020
Description : Spanish version of WishReferral form to capture lead details
***********************************************************/

global Class WishReferralFormSpanish_AC {
    Public string remailOne{get;set;}
    Public string remailTwo{get;set;}
    Public Lead currLead{get;set;}
    public string diagnosisFilter{get;set;}
    public String selectedDiagnosis{get; set;}
    public boolean displayChildFrm{get;set;}{displayChildFrm=false;}
    public String lastName{get;set;}
    public boolean displayAckMsg{get;set;}
    public List<siblingWrapper> currList;
    public String warningMsg{get;set;}
    public boolean displayWarningPopup{get;set;}
    public boolean copyReferrerInfo{get;set;}
    public boolean copyReferrerInfoToWish{get;set;}
    public string currState{get;set;}
    public string diagnosisMonth{get;set;}
    public string diagnosisYear{get;set;}
    public List<string> communictionList{get;set;}
    public List<String> languageList{get;set;}
    public string additionalParentState{get;set;}
    public static string icdOrPcd;
    public string refChildFormParent{get;set;}
    public string referralComment{get;set;}
    public string formTitle{get;set;}
    public String referralRush {get;set;}
    public string selectedLang{get;set;}
    public WishReferralForm_Translation__mdt formLabels{get;set;}        
    public WishReferralFormSpanish_AC()
    {
        selectedLang = 'es';
        communictionList = new List<String>();
        languageList = new List<String>();
        currLead = new Lead();
        copyReferrerInfoToWish =false;
        copyReferrerInfo =false;
        icdOrPcd = '';
        formTitle = 'Relationship with child';
        
        if(ApexPages.currentPage().getParameters().get('isSuccess') != Null)
            displayAckMsg = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSuccess'));
        
        formLabels = [SELECT MasterLabel,City__c,First_Name__c,Is_the_family_aware_of_the_referral__c,
                      Last_Name__c,Medical_professional_category__c,Phone__c,Postal_Code__c,Provide_your_relationship_to_the_child__c,
                      Referrer_information__c,Relationship_to_child__c,Additional_information__c,Age__c,
                      Age_Requirement__c,Approximate_diagnosis_date__c,Continue__c,Date_of_Birth__c,
                      Family_information__c,Gender__c,Gender_description__c,Hospital_or_treatment_facility__c,
                      Question_Has_the_child_ever_received__c,Medical_information__c,
                      Middle_initial__c,Number_of_siblings__c,Over_18_years_old__c,Parent_or_Guardian_1__c,
                      Please_provide_the_best_person__c,Primary_diagnosis__c,Primary_phone_number__c,
                      Question_Is_there_a_medical_reason__c,Remove_if_no_Parent_Guardian_2__c,
                      Same_address_as_Parent_or_Guardian_1__c,Sibling_information__c,State__c,Street_Address__c,
                      Submit__c,Treating_medical_professional_informatio__c,Wish_child_information__c,Name__c,
                      How_did_you_hear_about_Make_A_Wish__c,Has_this_child_ever_received__c,Self_Describe_selected__c,
                      Address__c,Email_Address__c,What_is_the_family_s_primary__c,Other_Language__c,Add_Parent_Legal_Guardian__c,
                      Parent_or_Guardian_2__c,Primary_Diagnosis_Description__c,Other_Not_Listed_Diagnosis_Selected__c,
                      ICD_Code__c,Is_there_a_medical_reason__c,Same_as_Referrer_Information__c,Form_Security__c,
                      Security_Checkbox__c,If_you_are_human__c,Do_not__c,Check_this__c,Do_not_change_this_field__c,
                      Security_Input__c,Thank_you_for_submitting_a_referral__c,spanishCommunication__c,spanishLanguage__c,Fact_Communication__c
                      
                      FROM WishReferralForm_Translation__mdt WHERE MasterLabel = 'es' LIMIT 1];
        
    }
    
    // Creating new Lead.
    Public PageReference CreateLead(){
    // SIW-14 START update for adding Email to referral email on lead object. Jan2019
    system.debug('Date '+currLead.DOB__c);
        currLead.Relationship_to_child__c = 'Other';
        currLead.Referrer_Email__c = remailOne;
        // SIW-14 END
     String LogValue;
     String recId;
     List<string> LstLog = new List<string>();
     try{             
         currLead.PCD_ICD__c = icdOrPcd;
         if(currLead.Relationship_to_child__c != Null)
             currLead.Relationship_to_child__c = currLead.Relationship_to_child__c.trim();
         currLead.Country = 'United States';
         List<ICD_Codes__c> icdCodeInfoList = [SELECT Id, Long_Description__c, Condition_Description__r.PR_Diagnosis__c,Group1__c,
                                               Condition_Description__c, Condition_Description__r.Code_to_Use__c
                                               FROM ICD_Codes__c WHERE Name =: diagnosisFilter LIMIT 1];
         if(icdCodeInfoList.size() > 0) {
             currLead.PD_ICD_Code__c = icdCodeInfoList[0].Id;
             currLead.ICD_Given_By_Referrer__c = icdCodeInfoList[0].Id;
         }        
         currLead.Diagnosis_Given_By_Referrer__c = 'Not Listed';
         currLead.PD_Condition_Description__c = 'Not Listed';
         currLead.Company = 'Make-A-Wish';
         currLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
         currLead.LastName = lastName;
         String zipCode='';
         String label = '';
         Boolean flag = True;
         CurrLead.State = currState;
         currLead.LeadSource = 'Online';
         CurrLead.Additional_Parent_State__c = additionalParentState;       
         
         
         if(currLead.Has_this_child_ever_received_prior_wish__c != Null)
             currLead.Has_this_child_ever_received_prior_wish__c = currLead.Has_this_child_ever_received_prior_wish__c.trim();
         
         if(currLead.Any_medical_reason_for_moving_quickly__c == 'Yes')
         {
             currLead.Any_medical_reason_for_moving_quickly__c = '<font color="Red">'+currLead.Any_medical_reason_for_moving_quickly__c +'</font>';
             currLead.Rush__c = true;
             currLead.Referrer_Rush_Reason__c = referralRush;
         }
         if(currLead.Any_medical_reason_for_moving_quickly__c != null){
             currLead.Hidden_Potential_Rush__c = currLead.Any_medical_reason_for_moving_quickly__c;
         }
         if(currLead.Has_this_child_ever_received_prior_wish__c == 'Yes')
         {
             currLead.Has_this_child_ever_received_prior_wish__c = '<font color="Red">'+currLead.Has_this_child_ever_received_prior_wish__c+'</font>';
         }
         if(currLead.Relationship_to_child__c == Null || currLead.Relationship_to_child__c == '')
         {
             system.debug('1');
             flag = false;
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Relationship To Child');
             ApexPages.addMessage(msg);
             return null;
         }
         
         
         if(flag == false)
         {
             if(label != '')
             {
                system.debug('2');
                 label = label.removeEnd(',');
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please complete following mandatory fields : ' +label );
                 ApexPages.addMessage(msg);
                 return null;
             }
         } 
         if(flag == True)
         {
             if(currLead.Postalcode!= Null && currLead.Postalcode !='')
                 zipCode = currLead.Postalcode;
             else
                 zipCode = currLead.Referrer_Zip__c;
             
             if(currLead.PD_ICD_Code__c != Null)
             {
                 if(icdCodeInfoList.size() > 0)
                 {                   
                     
                 }                           
             }
             
             if(currLead.PD_Condition_Description__c != Null)
             {
                 List<Condition_Description__c> descriptionList = [SELECT Id, PR_Diagnosis__c
                                                                   FROM Condition_Description__c WHERE Name = :currLead.PD_Condition_Description__c limit 1];
                 
                 if(descriptionList.size() > 0)
                 {
                     
                 }                           
             }
             
             if(currList!=Null)
             {
                 for(siblingWrapper currVal : currList)
                 {
                     
                     if(currLead.Sibling_Detail__c== Null)
                     {
                         currLead.Sibling_Detail__c='';
                     }
                     if(currVal.fName != Null && currVal.fName != '')
                     {
                         currLead.Sibling_Detail__c+= currVal.fName+' | ';
                     }
                     else
                     {
                         currLead.Sibling_Detail__c+= '-'+' | ';  
                     }
                     if(currVal.lName!= Null && currVal.lName != '')
                     {
                         currLead.Sibling_Detail__c+=currVal.lName+' | ';
                     }
                     else
                     {
                         currLead.Sibling_Detail__c+= '-'+' | ';  
                     }
                     if(currVal.age!= Null && currVal.age != '')
                     {
                         currLead.Sibling_Detail__c+=currVal.age+'<br>';
                     }
                     else
                     {
                         currLead.Sibling_Detail__c+= '-'+'<br>';  
                     }  
                 }
             }  
             
             
             
             // Route to Chapter.
             List<Zip_Code__c> findChapterviaZipCode = new List<Zip_Code__c>();
             if(zipCode != '')
                 findChapterViaZipCode = [SELECT id, Office__c, Office__r.Chapter__c,Office__r.Chapter__r.Intake_Manager__c 
                                          FROM Zip_Code__c WHERE Name = :zipCode limit 1]; 
             
             String intakeManagerId = '';
             if(findChapterviaZipCode.size()>0)
             {
                 if(findChapterviaZipCode[0].Office__c != Null)
                     currLead.chapterName__c = findChapterviaZipCode[0].Office__r.Chapter__c;
                 if(findChapterviaZipCode[0].Office__r.chapter__c != Null)
                 {
                     if(findChapterviaZipCode[0].Office__r.chapter__r.Intake_Manager__c != Null) {
                         currLead.OwnerId = findChapterviaZipCode[0].Office__r.chapter__r.Intake_Manager__c;
                         intakeManagerId = findChapterviaZipCode[0].Office__r.chapter__r.Intake_Manager__c;
                     }

                 }
             }
             else
             {
                 List<Account> currAccount = [SELECT id,Intake_Manager__c FROM Account Where Name = 'Make-A-Wish America' limit 1];
                 if(currAccount.size() > 0)
                 {
                     currLead.chapterName__c = currAccount[0].id;
                     if(currAccount[0].Intake_Manager__c != Null) {
                         currLead.OwnerId = currAccount[0].Intake_Manager__c;
                         intakeManagerId = currAccount[0].Intake_Manager__c;
                     }
                 }
                 
             }
             
             List<Contact> contactDupCheck = [SELECT id,OwnerId, AccountId FROM CONTACT WHERE LastName = :currLead.LastName AND 
                                              FirstName = :currLead.FirstName AND Birthdate = :currLead.DOB__c AND
                                              ((Phone = :currLead.Phone OR Email = :currLead.Email OR 
                                                (MailingCity = :currLead.City AND MailingState = :currLead.State 
                                                 AND MailingPostalCode = :currLead.PostalCode))) limit 1];
             
             List<Lead> leadDupCheck = [SELECT id, OwnerId, ChapterName__c, Status FROM Lead WHERE (LastName = :currLead.LastName AND 
                                                                                                    FirstName = :currLead.FirstName AND DOB__c = :currLead.DOB__c) AND
                                        ((Phone = :currLead.Phone OR Email = :currLead.Email OR 
                                          (City = :currLead.City AND State = :currLead.State 
                                           AND PostalCode = :currLead.PostalCode)))
                                        AND isConverted=false limit 1];
             boolean redirection;                                
         
             {
                 
                 if(currLead.Relationship_To_child__c == 'Other' || currLead.Child_Age__c == 'Under 2.5')
                 {
                     currLead.Status = 'Inquiry';
                     currLead.RFI_Form_Info_Hidden__c = 'Inquiry';
                 }
                 else
                 {
                     currLead.Status = 'Referred';
                     currLead.RFI_Form_Info_Hidden__c = 'Referred';
                     
                     System.debug('currLead.RFI_Form_Info_Hidden__c ++++++++++++++++++++++ ' + currLead.RFI_Form_Info_Hidden__c);
                 }
                 
                 if(currLead.Relationship_To_Child__c == 'Medical Professional'){
                     System.debug('RefComment>>>>>>!!!!'+referralComment);
                     currLead.ReferralComment__c = referralComment;
                 } else {
                     System.debug('RefComment>>>>>>!!!!>>>>>');
                     currLead.ReferralComment__c = '';
                 }
                 
                 if(currLead.Relationship_To_Child__c == 'Medical Professional' && 
                    (currLead.Medical_Provider_Category__c  == 'Nurse Practitioner' || currLead.Medical_Provider_Category__c == 'Physician Assistant' || currLead.Medical_Provider_Category__c == 'Physician'))
                 {
                     currLead.Medical_Professional_First_Name__c = currLead.Referrer_FirstName__c;
                     currLead.Medical_Professional_Last_Name__c = currLead.Referrer_Last_Name__c;
                     currLead.Medical_Professional_Phone__c = currLead.Referrer_Phone__c;
                     currLead.Medical_Professional_Email__c = currLead.Referrer_Email__c;
                     currLead.Hospital_Treatment_Facility__c = currLead.Hospital_Treatment_Facility_Treating__c;
                     
                     
                 }
                 
                 if(!(string.isBlank(diagnosisYear)) ){
                     system.debug('Dia Year'+diagnosisYear);
                     if(String.isBlank(diagnosisMonth))
                         currLead.Approximate_Diagnosis_Date__c = diagnosisYear;                            
                     else
                         currLead.Approximate_Diagnosis_Date__c = diagnosisMonth +'   '+diagnosisYear;
                     
                 }
                 String communications = '';
                 if(communictionList != Null){
                     for(String s:communictionList){
                         communications +=s+';';
                     }
                 }
                 
                 currLead.communication__C = communications;
                 
                 // IME-157 - starts
                 String languages = '';
                 if(languageList != null){
                     for(String l : languageList){
                         languages +=l+';';
                     }
                 }
                 currLead.What_is_the_family_s_primary_spoken_lang__c = languages;
                 //IME-157 Ends
                 
                 LstLog.add('LastName: '+currLead.LastName);
                 LstLog.add('State: '+currState);
                 LstLog.add('Zipcode: '+Zipcode);
                 LstLog.add('Diagnosis Month: '+diagnosisMonth);
                 LstLog.add('Diagnosis Year: '+diagnosisYear);
                 LstLog.add('Lead Source: '+currLead.LeadSource);
                 LstLog.add('pd condition: '+currLead.PD_Condition_Description__c);
                 LstLog.add('diagnosis by referrer: '+currLead.Diagnosis_Given_By_Referrer__c);
                 LstLog.add('Prior Wish Received: '+currLead.Has_this_child_ever_received_prior_wish__c);
                 LstLog.add('Any Reason to move quickly: '+currLead.Any_medical_reason_for_moving_quickly__c);
                 LstLog.add('Relationship to child: '+currLead.Relationship_to_child__c);
                 LstLog.add('Siblings count: '+currLead.of_Siblings__c);
                 LstLog.add('Siblings Detail: '+currLead.Sibling_Detail__c);
                 LstLog.add('Condition Description: '+currLead.PR_Diagnosis__c);
                 LstLog.add('Chapter Name: '+currLead.ChapterName__c);
                 LstLog.add('Lead Status: '+currLead.Status);
                 LstLog.add('MedProf FirstName: '+currLead.Medical_Professional_First_Name__c);
                 LstLog.add('MedProf LastName: '+currLead.Medical_Professional_Last_Name__c);
                 LstLog.add('MedProf Phone: '+currLead.Medical_Professional_Phone__c);
                 LstLog.add('MedProf Email: '+currLead.Medical_Professional_Email__c);
                 LstLog.add('Hospital: '+currLead.Hospital_Treatment_Facility_Treating__c);
                 LstLog.add('Referral Comment: ' +currLead.ReferralComment__c);
                 LstLog.add('Parent FirstName: ' +currLead.Parent_First_Name__c);
                 LstLog.add('Parent LastName: ' +currLead.Parent_Last_Name__c);
                 LstLog.add('Parent Email: ' +currLead.Email);
                 LstLog.add('Parent Phone: ' +currLead.Phone);
                 insert currLead;
                 if(currLead.id != Null)
                     redirection = true;
             }
             
             if(redirection == true) {
                 
                    
                 //SIW-193 
                    string arg;
                    if(ApexPages.currentPage().getParameters().get('alt') == 't') {
                        arg = '&alt=t';}
                    
                    PageReference reference=new PageReference('/apex/WishReferralForm_Spanish_VF?isSuccess=True&chid='+refChildFormParent + '&rel=' + currLead.Relationship_to_child__c + arg);
                    reference.setRedirect(true);
                    return reference;
             }
         }
         
     }
     
     Catch(Exception ex){
        system.debug('3');
         Logvalue = string.join(LstLog,', ');
         new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','CreateLead',recId,ex,Logvalue));
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
         ApexPages.addMessage(myMsg);  
     }
     return null;
     
    }
    
    // Auto Complete the ICD Code values.
    @RemoteAction
    global static List<ICD_Codes__c> searchDiagnosis(String searchTerm) {
        string recId;
        string Logvalue;
        try{
        icdOrPcd = 'ICD';
        List<ICD_Codes__c> icdCodes = Database.query('Select Id, Name,Condition_Description__c, Short_Description__c, Condition_Description__r.Name, Condition_Description__r.InActive__c from ICD_Codes__c where Condition_Description__r.InActive__c != true and Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Hidden_ICD_Code__c = false');
        Logvalue = string.valueOf(icdCodes);
        return icdCodes;
         }
        catch(Exception ex){
            system.debug('4');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','searchCondition',recId,ex,Logvalue));
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null; 
        }
    } 
    
    // Auto Complete the Dianosis field value.
    @RemoteAction
    global static List<Condition_Description__c> searchCondition(String searchTerm) {
        string recId;
        string Logvalue;
        try{
        icdOrPcd = 'PCD';
                List<Condition_Description__c> conditionDescriptions = Database.query('Select Id, Name, Code_To_Use__c, InActive__c from Condition_Description__c where InActive__c != true and Not_Listed = True');
        if(!(conditionDescriptions.size() > 0))
        {
            conditionDescriptions =[Select Id, Name, Code_To_Use__c from Condition_Description__c WHERE Not_Listed__c = True];
        }
        Logvalue = string.valueOf(conditionDescriptions);
        return conditionDescriptions;
        }
        catch(Exception ex){
            system.debug('5');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','searchCondition',recId,ex,Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null; 
        }
    } 
    
    // Fetch the relationship picklist values from Relationship_To_child field and displaying as a Radio Button.
    public List<SelectOption> getRelationships(){
        string recId;
        string Logvalue;
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Self', 'Yo mismo/a'));
            options.add(new SelectOption('Medical Professional', 'Profesional Médico'));
            options.add(new SelectOption('Parent/Guardian', 'Padre/Madre/Custodio'));
            options.add(new SelectOption('Family Member/Relative', 'Miembro de la Familia/Pariente'));
            options.add(new SelectOption('Other', 'Otro'));
            currLead.Relationship_to_child__c = 'Other';            
            return options;
        }
        catch(Exception ex){
            system.debug('6');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','getRelationships',recId,ex,Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null; 
        }
    }   
    
    public List<SelectOption> getHearWish(){
        string recId;
        string Logvalue;
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', 'Por favor seleccione una opción'));
            options.add(new SelectOption('Social Worker', 'Trabajadora social'));
            options.add(new SelectOption('Family Member', 'Miembro de la familia'));
            options.add(new SelectOption('Nurse', 'Enfermero(a)'));
            options.add(new SelectOption('Physician', 'Médico'));
            options.add(new SelectOption('Friend', 'Amigo(a)'));
            options.add(new SelectOption('Brochure at the Doctor\'s Office', 'Folleto en el consultorio'));
            options.add(new SelectOption('Email', 'Correo Electronico'));
            options.add(new SelectOption('Event', 'Evento'));
            options.add(new SelectOption('Make-A-Wish Hospital Presence', 'Presencia de Make-A-Wish en el Hospital'));
            options.add(new SelectOption('Make-A-Wish Staff/Volunteer', 'Personal / Voluntaria Make-A-Wish'));    
            options.add(new SelectOption('Newspaper', 'Periódico'));
            options.add(new SelectOption('Other Make-A-Wish Family', 'Otra familia Make-A-Wish'));
            options.add(new SelectOption('Radio', 'Radio'));
            options.add(new SelectOption('School – Kids For Wish Kids', 'Escuela - Programa Wish for Wish Kids'));
            options.add(new SelectOption('Social Media', 'Medios de comunicación social'));
            options.add(new SelectOption('Support Group', 'Grupo de apoyo'));
            options.add(new SelectOption('Television', 'Televisión'));
            options.add(new SelectOption('Web Search', 'Búsqueda Web'));
            options.add(new SelectOption('Other', 'Otro'));           
            return options;
        }
        catch(Exception ex){           
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','getHearWish',recId,ex,Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null; 
        }
    }   
    public List<SelectOption> getRelationshipsToChild(){
        string recId;
        string Logvalue;
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', 'Por favor seleccione una opción'));
            options.add(new SelectOption('Father', 'Padre'));
            options.add(new SelectOption('Mother', 'Madre'));
            options.add(new SelectOption('Sister', 'Hermana'));
            options.add(new SelectOption('Brother', 'Hermano'));
            options.add(new SelectOption('Guardian', 'Tutor'));
            options.add(new SelectOption('Grandmother', 'Abuela'));
            options.add(new SelectOption('Grandfather', 'Abuelo'));
            options.add(new SelectOption('Stepmother', 'Madrastra'));
            options.add(new SelectOption('Stepfather', 'Padrastro'));
            options.add(new SelectOption('Stepsister', 'Hermanastra'));    
            options.add(new SelectOption('Stepbrother', 'Hermanastro'));
            options.add(new SelectOption('Half Sister', 'Media hermana'));
            options.add(new SelectOption('Half Brother', 'Medio hermano'));
            options.add(new SelectOption('Foster Mother', 'Madre en adopción temporal'));
            options.add(new SelectOption('Foster Father', 'Padre en adopción temporal'));
            options.add(new SelectOption('Foster Sister', 'Hermana en adopción temporal'));
            options.add(new SelectOption('Foster Brother', 'Hermano en adopción temporal'));
            options.add(new SelectOption('Aunt', 'Tia'));
            options.add(new SelectOption('Uncle', 'Tío'));    
            options.add(new SelectOption('Cousin', 'Primo'));
            options.add(new SelectOption('Husband', 'Marido'));
            options.add(new SelectOption('Wife', 'Esposa'));
            options.add(new SelectOption('Partner', 'Compañero'));
            options.add(new SelectOption('Friend', 'Amigo'));
            options.add(new SelectOption('Neighbor', 'Vecino'));
            options.add(new SelectOption('Family', 'Familia'));
            options.add(new SelectOption('Coworker', 'Compañera de trabajo'));
            options.add(new SelectOption('Son', 'Hijo'));    
            options.add(new SelectOption('Daughter', 'Hija'));
            options.add(new SelectOption('Grandson', 'Nieto'));
            options.add(new SelectOption('Granddaughter', 'Nieta'));
            options.add(new SelectOption('Employer', 'Empleador'));
            options.add(new SelectOption('Employee', 'Empleado'));
            options.add(new SelectOption('Other', 'Otro'));
            options.add(new SelectOption('Parent', 'Padre/Madre'));
            options.add(new SelectOption('Sibling', 'Hermano'));
            options.add(new SelectOption('Grandparent', 'Abuelo(a)')); 
            options.add(new SelectOption('Parent/Guardian', 'Padre/Madre/Custodio'));           
            return options;
        }
        catch(Exception ex){           
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','getRelationshipsToChild',recId,ex,Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null; 
        }
    }   
    
    
    // Based on the Family Aware of Referral field, Child form would render.
    public void disPlayChildForm()
    {
        
        if(currLead.Relationship_To_Child__c != 'Medical Professional')
        {
            currLead.Medical_Provider_Category__c = '';
            copyReferrerInfo = false;
        }
        
        if(currLead.Relationship_To_Child__c == 'Self' && currLead.is_Family_Aware_of_Referral__c=='Yes')
        {
            
            currLead.FirstName = currLead.Referrer_FirstName__c;
            lastName = currLead.Referrer_Last_Name__c;
        }
        
        if(currLead.Relationship_To_Child__c == 'Parent/Guardian' && currLead.is_Family_Aware_of_Referral__c=='Yes')
        { 
            
            
            currLead.Parent_First_Name__c = currLead.Referrer_FirstName__c;
            currLead.Parent_Last_Name__c = currLead.Referrer_Last_Name__c;
            currLead.City = currLead.Referrer_City__c;
            currLead.PostalCode =  currLead.Referrer_Zip__c;
            currLead.Email = currLead.Referrer_Email__c;
            currLead.Phone = currLead.Referrer_Phone__c;
        }
        
        if(currLead.Medical_Provider_Category__c != 'Nurse Practitioner' &&  currLead.Medical_Provider_Category__c != 'Physician' && currLead.Medical_Provider_Category__c != 'Physician Assistant')
        {
            copyReferrerInfo=false;
        }
        
        if(currLead.of_Siblings__c != Null && currLead.of_Siblings__c != '0' && currLead.Of_Siblings__c != 'Unknown')
        {
            
            getSiblingList();
        }
        
        
        
    }
    
    
    // Referrer and Medical Provider is same, then Referrer details would display on Medical Provider section also.
    public void CopyReferralInfo()
    {
        if(currLead.Relationship_To_Child__c != 'Self' && copyReferrerInfo == True)
        {
            currLead.Treating_Medical_Professional_First_Name__c= currLead.Referrer_FirstName__c;
            currLead.Treating_Medical_Professional_Last_Name__c= currLead.Referrer_Last_Name__c;
            currLead.Treating_Medical_Professional_Phone__c= currLead.Referrer_Phone__c;
            currLead.Treating_Medical_Professional_Email__c= currLead.Referrer_Email__c;
            currLead.Medical_Professional_First_Name__c = currLead.Referrer_FirstName__c;
            currLead.Medical_Professional_Last_Name__c = currLead.Referrer_Last_Name__c;
            currLead.Medical_Professional_Phone__c = currLead.Referrer_Phone__c;
            currLead.Medical_Professional_Email__c = currLead.Referrer_Email__c;
        }
        else
        {
            currLead.Treating_Medical_Professional_First_Name__c='';
            currLead.Treating_Medical_Professional_Last_Name__c= '';
            currLead.Treating_Medical_Professional_Phone__c= '';
            currLead.Treating_Medical_Professional_Email__c= '';
            currLead.Medical_Professional_First_Name__c = '';
            currLead.Medical_Professional_Last_Name__c = '';
            currLead.Medical_Professional_Phone__c = '';
            currLead.Medical_Professional_Email__c = '';
        }
        
        
        
    } 
    
    // Based on the number of siblings field, data entry data table would display.
    Public List<siblingWrapper> getSiblingList()
    {
        
        string recId;
        string Logvalue;
//        try{
            currList = new List<siblingWrapper>();
            System.debug('currLead.of_Siblings__c++++++++++++++++++++++++++++ ' +currLead.of_Siblings__c);
            if(currLead.of_Siblings__c != Null && currLead.Of_Siblings__c != 'Unknown')
            {
                for(integer i=0;i<integer.valueOf(currLead.of_Siblings__c);i++)
                {
                    currList.add(new siblingWrapper());
                }
            }
            Logvalue = string.valueOf(currList);
            return currList;         
    }
    
    //Capturing State Picklist values.   
    public List<SelectOption> getStates() {
        string recId;
        string Logvalue;
       // try{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult =  Lead.State_Picklist__c.getDescribe();
            options.add(new SelectOption('', 'Select an option')); 
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry currVal : picklistValues){
                options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
                
            }
            Logvalue = string.valueOf(options);        
            return options;
      
    }  
    public List<SelectOption> getChildagesp() {      
       // try{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult =  Lead.Child_Age__c.getDescribe();
            options.add(new SelectOption('', 'Select an option')); 
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry currVal : picklistValues){
                if(currVal.getValue() == 'Under 2.5'){
                    options.add(new SelectOption('Under 2.5', 'Menos de 2.5'));
                }
                else if(currVal.getValue() == '18 & Above'){
                    options.add(new SelectOption('18 & Above', '18 & Más'));
                }
                else{
                    options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
                }  
            }
            return options;
     
    }  
    
   
    
    //Capturing Parent Relationship to child Picklist values.   
    public List<SelectOption> getHereAboutMAW() {
        string recId;
        string Logvalue;
      //  try{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult =  Lead.How_Did_you_hear_about_Make_A_Wish__c.getDescribe();
            options.add(new SelectOption('', 'Por favor seleccione una opción')); 
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry currVal : picklistValues){
                options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
                
            }
            Logvalue = string.valueOf(options);    
            return options;
     
    }  
    
    /* ************************************
Capturing Communication Picklist values.
************************************* */   
    public List<SelectOption> getCommunication() {
        List<SelectOption> options = new List<SelectOption>();
        String lang= formLabels.spanishCommunication__c;
        List<String> str = lang.split(';');
        options.add(new SelectOption('', 'Seleccione una opción')); 
        for(String s : str){
            List<String> val = s.split(':');
            options.add(new SelectOption(val[0], val[1]));
        }
       
            return options;
      
    }  
    
    //IME-157 Start
    public List<SelectOption> getlanguage() {
       //string recId;
        //string Logvalue;
        List<SelectOption> options = new List<SelectOption>();
        String lang= formLabels.spanishLanguage__c;
        List<String> str = lang.split(',');
        options.add(new SelectOption('', 'Select an option')); 
        for(String s : str){
            List<String> val = s.split(':');
            options.add(new SelectOption(val[0], val[1]));
        }
        
        return options;
    }      
    //IME-157 Ends
    

    
    //diaYear
    public List<SelectOption> getdiaYear() {
        string recId;
        string Logvalue;
      //  try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', 'Año')); 
            for( Integer i=Date.Today().Year(); i>=Date.Today().Year()-18; i--){
                options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));                
            }
            Logvalue = string.valueOf(options);  
            return options;
     
    }  
    
    
    
    
    //Capturing State Picklist values.   
    public List<SelectOption> getNoOfSiblings() {
        string recId;
        string Logvalue;
      //  try{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult =  Lead.of_Siblings__c.getDescribe();
            options.add(new SelectOption('', 'Please Select')); 
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry currVal : picklistValues){
                if(currVal.getValue() == 'Unknown'){
                    options.add(new SelectOption('Unknown', 'Desconocido')); 
                }
                else{
                    options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
                }  
            } 
            
            Logvalue = string.valueOf(options); 
            return options;
     
    } 
    
    // Self Fieldset, it holds the mandatory fields of Self relationship.
    public List<Schema.FieldSetMember> getSelfRequiredFields() {
        return SObjectType.Lead.FieldSets.Self_Required_Fields.getFields();
    }
    // Medical Referral Field set contains the mandatory fields of Medical Professional.
    public List<Schema.FieldSetMember> getNonMedicalReqFields() {
        return SObjectType.Lead.FieldSets.Non_Medical_Referral_Required_Fields.getFields();
    }
    // Non Medical Referral field set contains the mandatory fields of Non Medical Professional.
    public List<Schema.FieldSetMember> getMedicalRequiredFields() {
        return SObjectType.Lead.FieldSets.Medical_Referral_Required_Form.getFields();
    }
    
    
    // Creating Task 
    
    private static Task createTask(Id whoId,Id ownerId,Id whatId, String subject, Id recordTypeId)
    {  
        List<string> LstLog = new List<string>();
        string Logvalue;
        string recId;
        try{
            Id taskRT = Constant_AC.TASK_RT_ID;
            Task newTask = new Task();
            newTask.Subject = subject;
            newTask.SystemGeneratedTask__c = TRUE;
            newTask.RecordTypeId = recordTypeId;
            newTask.OwnerId = UserInfo.getUserId();
            newTask.whoId = whoId;
            newTask.Status = 'Not Started';
            newTask.activityDate = Date.Today() + 10;
            if(ownerId != Null)
                newTask.OwnerId = ownerId;
            
            //newTask.whatId = whatId;
            newTask.RecordTypeId = taskRT;
            LstLog.add('Subject: '+newTask.Subject);
            LstLog.add('RecordTypeId: '+newTask.RecordTypeId);
            LstLog.add('OwnerId: '+newTask.OwnerId);
            LstLog.add('whoId: '+newTask.whoId);
            LstLog.add('Status: '+newTask.Status);
            LstLog.add('activityDate: '+newTask.activityDate);
            LstLog.add('OwnerId: '+ownerId);
            insert newTask;
            System.debug('newTask.id +++++++++++++++++++++++++++++++ ' + newTask.id);
            return newTask;
        }
        catch(Exception ex){
            system.debug('7');
            // String objType = String.valueOf(newTask);
            Logvalue = string.join(LstLog,', ');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralFormSpanish_AC','createTask',whoId,ex,Logvalue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
    }
    // Wrapper for capturing n number of sibling details.   
    public class siblingWrapper
    {
        public string fName{get;set;}
        public string lName{get;set;}
        public string age{get;set;}
        
    }   
    
    
}