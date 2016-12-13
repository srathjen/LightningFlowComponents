/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : This form is for Medical Professionals to fill up the Medical Summary Reports about the Wish child
whom they are treating.
*******************************************************************************************************************/

public class DiagnosisVerification_AC {
    
    public List<medicalWrapper> medicalPicklistValWrapper {get; set;}
    public List<medicalWrapper> medicalPicklistOtherWrapper1 {get; set;}
    public List<medicalWrapper> medicalPicklistOtherWrapper2 {get; set;}
    public List<medicalWrapper> medicalPicklistOtherWrapper3 {get; set;}
    public List<medicalWrapper> medicalPicklistOtherWrapper4 {get; set;}
    public String identifyICDPCD {get; set;}
    Public String medicalSummaryDownloadPath {get;set;}
    public String wishChildMedicalSummaryNameText;
    Public String medicalFileNames {get;set;}
    Public String wishChildEligibilityNotes {get;set;}
    public PartAFormWrapper wrapCls{get;set;}
    Public String wishChildMedicalSummary {get;set;}
    public String wishStatus {get;set;}
    public String epilepsyClass {get;set;}
    public String epilepsyVal {get;set;}
    public Attachment newAttachment{get;set;}
    Public List<Lead_File__c> leadFileList {get;set;}
    //public List<travelWrapper> travelAlgorithmWarapperList;
    public List<Medical_Questions__c> medicalQuestionsList{get;set;}
    Public boolean login{get;set;}
    Public String password{get;set;}
    public Lead currLead{get;set;}
    public String getQuestioList {get;set;}
    public string mulCon1 {get;set;}
    public String selectedItemValue {get;set;}
    public String vId {get;set;}
    public List<String> communicationList {get;set;}
    public Set<String> conditionDesSet;
    public String epilepsyPick {get;set;}
    public String epilepsyRadio {get;set;}
    Map<String,String> travelVal = new Map<String,String>();
    Map<String,String> travelLabel = new Map<String, String>();
    Map<String,String> travelMap = new Map<String,String>();
    Map<String,String> travelAlgorithmMap = new Map<String,String>();
    public String explainDeteriorate {get;set;}
    //Used to get the lead records based on the parameter passed in the URL
  
    public DiagnosisVerification_AC () 
    { 
        communicationList = new List<String>();
        leadFileList = new List<Lead_File__c>();
        wrapCls = new PartAFormWrapper();
        wrapCls.displayMedicalQuestion = false;
        wrapCls.displayMedicalQuestion1 = false;
        wrapCls.displayMedicalQuestion2 = false;
        wrapCls.displayMedicalQuestion3 = false;
        wrapCls.displayMedicalQuestion4 = false;
        wrapCls.offsetCount = 0;
        wrapCls.notEligibleForWish = false;
        wrapCls.otherDiagnosis = false;
        wrapCls.otherDiagnosis1 = false;
        wrapCls.otherDiagnosis2 = false;
        wrapCls.fileSection = false;        
        login = false;
        wrapCls.infectious = false;
        wrapCls.airborne = false;
        wrapcls.pneumothorax = false;
        wrapCls.convulsiveDisorders = new List<String>();
        wrapCls.congenitalHeartDiseaseString = new List<String>();
        wrapCls.chronicHeartFailureString = new List<String>();
        wrapCls.heartFailureString = new List<String>();
        wrapCls.ArrhythmiaString = new List<String>();
        wrapCls.anginaString= new List<String>();
        wrapCls.ventilatorString= new List<String>();
        wrapCls.lungDiseaseString = new List<String>();
        medicalPicklistValWrapper = new List<medicalWrapper>();
        medicalPicklistOtherWrapper1 = new List<medicalWrapper>();
        medicalPicklistOtherWrapper2 = new List<medicalWrapper>();
        medicalPicklistOtherWrapper3 = new List<medicalWrapper>();
        medicalPicklistOtherWrapper4 = new List<medicalWrapper>();
        newAttachment = new Attachment();
        init();
        if(ApexPages.currentPage().getParameters().get('leadId') != Null)
            wrapCls.leadId = ApexPages.currentPage().getParameters().get('leadId');
        
        if(wrapCls.leadId != Null)
        {
            medicalSummaryDownloadPath = '';
            String leadId = wrapCls.leadId;
            
            String  query = 'SELECT FirstName,RFI_Form_Info_Hidden__c,Override_Dupe_Check__c,Please_Explain_Deteriorate__c, LastName ,Email, Phone, Name, id, ';
            for(Schema.FieldSetMember currField :getPartAFields()) {
                query+=currField.getFieldPath()+',';
            }
            query=query.removeEnd(',');
            query+=' FROM Lead WHERE Id =:leadId';
            currLead = Database.query(query);
            
            for(Medical_Questions__c medicalQues : [SELECT Id, Current_Condition__c, Recommendation_to_Chapter__c FROM Medical_Questions__c WHERE RecordType.Name = 'Travel Algorithm']) {
                travelAlgorithmMap.put(medicalQues.Current_Condition__c,medicalQues.Recommendation_to_Chapter__c);
            }
            wishStatus = currLead.RFI_Form_Info_Hidden__c;
            if(wishStatus == 'Qualified') {
                wrapCls.eligibleForWish = true;
            } else if(wishStatus == 'Not Qualified') {
                wrapCls.notEligibleForWish = true;
            }
        }
        wrapCls.travelAgroithmList = new List<String>();
        wrapCls.travelSet = new Set<String>();
        wrapCls.diagnosisFilter = currLead.PD_ICD_Code__c;
        wrapCls.selectedPrimaryDiagnosis = currLead.PD_Condition_Description__c;
        wrapCls.gender = currLead.Gender__c;
        wishChildEligibilityNotes = currLead.Why_do_you_feel_would_be_eligible_Wish__c;
        wrapCls.age = currLead.Child_Age__c;
        wrapCls.dateOfBirth = currLead.DOB__c;
        wrapCls.diagnosisFilter1 = currLead.SD1_ICD_Code__c;
        wrapCls.diagnosisFilterVal1 = currLead.SD1_Condition_Description__c;
        wrapCls.diagnosisFilter2 = currLead.SD2_ICD_Code__c;
        wrapCls.diagnosisFilterVal2 = currLead.SD2_Condition_Description__c;
        wrapCls.diagnosisFilter3 = currLead.SD3_ICD_Code__c;
        wrapCls.diagnosisFilterVal3 = currLead.SD3_Condition_Description__c;
        wrapCls.diagnosisFilter4 = currLead.SD4_ICD_Code__c;
        wrapCls.diagnosisFilterVal4 = currLead.SD4_Condition_Description__c;
        
        if(currLead != Null)
        {
            List<Diagnosis_Verification__c> diagnosisVerificationList = [SELECT Id, Reason_for_Need__c ,Epilepsy_Value__c, ICD_Code__c, Lead__c,  Medical_Question__c, Medical_Question__r.Picklist_values__c, Medical_Question_Answer__c, Order__c, Primary_Diagnosis__c 
                                                                         FROM Diagnosis_Verification__c WHERE Lead__c =: wrapCls.leadId];
            if(diagnosisVerificationList.size() > 0 ) {
                if(currLead.PD_ICD_Code__c != null || currLead.PD_Condition_Description__c != null) {
                    if(currLead.SD1_ICD_Code__c == null && currLead.SD1_Condition_Description__c == null && currLead.RFI_Form_Info_Hidden__c != 'Qualified') {
                        wrapCls.otherDiagnosis = true;
                    } else if(currLead.SD2_ICD_Code__c == null && currLead.SD2_Condition_Description__c == null && currLead.RFI_Form_Info_Hidden__c != 'Qualified') {
                        wrapCls.otherDiagnosis1 = true;
                    } else if(currLead.SD3_ICD_Code__c == null && currLead.SD3_Condition_Description__c == null && currLead.RFI_Form_Info_Hidden__c != 'Qualified') {
                        wrapCls.otherDiagnosis2 = true;
                    } else if(currLead.SD4_ICD_Code__c == null && currLead.SD4_Condition_Description__c == null && currLead.RFI_Form_Info_Hidden__c != 'Qualified') {
                        wrapCls.otherDiagnosis4 = true;
                    }
                }
                medicalPicklistValWrapper = new List<medicalWrapper>();
                Set<Id> diagnosisIdSet = new Set<Id>();
                Map<Id,Medical_Questions__c> diagnosisMedicalQuestionsMap = new Map<Id,Medical_Questions__c>();
                for(Diagnosis_Verification__c getRecords : diagnosisVerificationList) {
                    diagnosisIdSet.add(getRecords.Medical_Question__c);
                }
                for(Medical_Questions__c getMedicalDetails : [SELECT Id,Epilepsy_picklist__c,Condition_Description__c,Condition_Description__r.Name,Question__c,Data_Type__c,Picklist_values__c FROM Medical_Questions__c WHERE Id IN : diagnosisIdSet]) {
                    diagnosisMedicalQuestionsMap.put(getMedicalDetails.Id, getMedicalDetails);
                }
                for(Diagnosis_Verification__c sendVerificationTOWrapper : diagnosisVerificationList) {
                    medicalWrapper editRecords = new medicalWrapper(diagnosisMedicalQuestionsMap.get(sendVerificationTOWrapper.Medical_Question__c),sendVerificationTOWrapper.Primary_Diagnosis__c,sendVerificationTOWrapper.ICD_Code__c,Integer.valueOf(sendVerificationTOWrapper.Order__c));
                    editRecords.selectedPickVal = sendVerificationTOWrapper.Medical_Question_Answer__c;
                    editRecords.epilepsySelectedPickVal = sendVerificationTOWrapper.Epilepsy_Value__c;
                    editRecords.reasonForNeed = sendVerificationTOWrapper.Reason_for_Need__c;
                    if(Integer.valueOf(sendVerificationTOWrapper.Order__c) == 1)
                    {
                        wrapCls.displayMedicalQuestion = true;
                        medicalPicklistValWrapper.add(editRecords);
                    }
                    else if(Integer.valueOf(sendVerificationTOWrapper.Order__c) == 2)
                    {
                        wrapCls.otherDiagnosis = true;
                        wrapCls.displayMedicalQuestion1 = true;
                        medicalPicklistOtherWrapper1.add(editRecords);
                    }
                    else if(Integer.valueOf(sendVerificationTOWrapper.Order__c) == 3)
                    {   
                        wrapCls.otherDiagnosis1 = true;
                        wrapCls.displayMedicalQuestion2 = true;
                        medicalPicklistOtherWrapper2.add(editRecords);
                    }
                    else if(Integer.valueOf(sendVerificationTOWrapper.Order__c) == 4)
                    {
                        wrapCls.otherDiagnosis2 = true;
                        wrapCls.displayMedicalQuestion3 = true;
                        medicalPicklistOtherWrapper3.add(editRecords);
                    }
                    else if(Integer.valueOf(sendVerificationTOWrapper.Order__c) == 5)
                    {
                        wrapCls.otherDiagnosis3 = true;
                        wrapCls.displayMedicalQuestion4 = true;
                        medicalPicklistOtherWrapper4.add(editRecords);
                    }
                }
            }         
            
            //Retriving Medical Summary report of wish child if it exists
            wishChildMedicalSummary = currLead.FirstName + ' ' +currLead.LastName + '_';
            wishChildMedicalSummaryNameText = currLead.FirstName + ' ' +currLead.LastName + '_%';
            
            //List<Lead_File__c> medicalSummaryList = [SELECT Id, Parent__c, File_Path__c, Description__c, File_Name__c FROM Lead_File__c WHERE Parent__c =: wrapCls.leadId AND File_Name__c LIKE : wishChildMedicalSummaryNameText order by CreatedDate desc];
            List<Lead_File__c> medicalSummaryList = [SELECT Id, Parent__c, File_Path__c, Description__c, File_Name__c FROM Lead_File__c WHERE Parent__c =: wrapCls.leadId ORDER BY CreatedDate desc];
            if(medicalSummaryList.size() > 0 ) {
                medicalFileNames = '';
                for(Lead_File__c getAttachmentName : medicalSummaryList) {
                    leadFileList.add(getAttachmentName);
                    //medicalFileNames += getAttachmentName.File_Name__c+',';
                    //if(String.isEmpty(medicalSummaryDownloadPath)) {
                        //medicalSummaryDownloadPath = getAttachmentName.File_Path__c;
                    //}
                }
                //wishChildEligibilityNotes = medicalSummaryList.get(0).Description__c;
                //newAttachment.Name = medicalSummaryList.get(0).File_Name__c;
            }
            System.debug('>>>>>>>>>>>>>>>>>leadFileList>>>>>>>>>>>'+leadFileList);
            if(currLead.Communication__c != null)
            {
                for(String com : currLead.Communication__c.split(';'))
                {
                    communicationList.add(com);
                }
            }
            
            explainDeteriorate = currLead.Please_Explain_Deteriorate__c;
            wrapCls.treatingFName =  currLead.Treating_Medical_Professional_First_Name__c;
            wrapCls.treatingLName = currLead.Treating_Medical_Professional_Last_Name__c;
            wrapCls.treatingPhone = currLead.Treating_Medical_Professional_Phone__c;
            wrapCls.treatingEmail = currLead.Treating_Medical_Professional_Email__c;
            wrapCls.treatingHospital = currLead.Hospital_Treatment_Facility_Treating__c;
            wrapCls.expediteTheProcess = currLead.Is_We_Need_To_Expedite_The_Process__c;
            wrapCls.plzExplain = currLead.Please_Explain__c;
            wrapCls.conditioDeteriorate = currLead.Will_Child_s_Condition_Deteriorate__c;
            wrapCls.communication = currLead.Communication__c;
            if(currLead.Child_will_ultimately_die_prematurely__c == true) {
                wrapCls.describePatient = '1';
            } else if(currLead.Treatment_may_be_feasible_but_can_fail__c == true) {
                wrapCls.describePatient = '2';
            } else if(currLead.Treatment_may_prolong_normal_activities__c == true) {
                wrapCls.describePatient = '3';
            } else if(currLead.Debilitation_may_extend_over_many_years__c == true) {
                wrapCls.describePatient = '4';
            } else if(currLead.Increased_probability_of_premature_death__c == true) {
                wrapCls.describePatient = '5';
            } else if(currLead.Risk_of_complications_premature_death__c == true) {
                wrapCls.describePatient = '6';
            } else if(currLead.Responds_to_treatment_with_normal_health__c == true) {
                wrapCls.describePatient = '7';
            } else if(currLead.None_of_these_statements_describes_Child__c == true) {
                wrapCls.describePatient = '8';
            }
            if(currLead.Travel_algorithm__c != null) {
                wrapCls.algList = currLead.Travel_algorithm__c.removeEnd(';');
                
                if(wrapCls.algList.contains(';')) {
                    for(String travel : wrapCls.algList.split(';')) {
                        wrapCls.travelSet.add(travel);
                    }
                } else {
                    wrapCls.travelSet.add(wrapCls.algList);
                }
            }
            
            if(currLead.Communication__c != null)
            {
                for(String com : currLead.Communication__c.split(';'))
                {
                    communicationList.add(com);
                }
            }
            
            wrapCls.recognizationPickValSelected = currLead.I_am_Recognized_To_Practice_As_a__c;
            wrapCls.healthCareWork = currLead.I_m_Part_of_The_Treating_HealthCare_Team__c;
            wrapCls.vegetativeState = currLead.Is_in_a_Comatose_Vegetative_State__c;
            String jsonString = json.serialize(wrapCls);
            Map<String,Object> wrapClsMap = new Map<String,Object>();
            wrapClsMap = (Map<String,Object>)json.deserializeuntyped(jsonString);            
            if(currLead.Current_Condition_Label__c != Null)
            {
                for(String s : (currLead.Current_Condition_Label__c.split(';')))
                {
                    if(travelMap.containsKey(s))
                    {
                        String fieldName = travelMap.get(s);
                        if(fieldName != null) {
                            wrapClsMap.put(fieldName,true);
                        }
                    }
                }
                String jsonString1 = json.serialize(wrapClsMap);
                wrapCls = (PartAformWrapper)json.deserialize(jsonString1,PartAformWrapper.class); 
            }
            if(currLead.Chronic_Hepatitis__c != Null)
                wrapCls.chronicHepatitisString = currLead.Chronic_Hepatitis__c;
            if(currLead.Pulmonary_Hypertension__c != Null)
                wrapCls.pulmonaryHypertensionString = currLead.Pulmonary_Hypertension__c;
            if(currLead.Strokes__c != Null)
                wrapCls.strokesType = currLead.Strokes__c;
            if(currLead.Convulsive_Disorders__c != Null)
            {
                for(String s : currLead.Convulsive_Disorders__c.split(';'))
                {
                    wrapCls.convulsiveDisorders.add(s);
                }
            }
            if(currLead.Congenital_Heart_Disease__c!= Null)
            {
                for(String s : currLead.Congenital_Heart_Disease__c.split(';'))
                {
                    wrapCls.congenitalHeartDiseaseString.add(s);
                }
            }
            if(currLead.Chronic_Heart_Failure__c!= Null)
            {
                for(String s : currLead.Chronic_Heart_Failure__c.split(';'))
                {
                    wrapCls.chronicHeartFailureString.add(s);
                }
            }
            if(currLead.Heart_Failure__c!= Null)
            {
                for(String s : currLead.Heart_Failure__c.split(';'))
                {
                    wrapCls.heartFailureString.add(s);
                }
            }
            if(currLead.Arrhythmia__c!= Null)
            {
                for(String s : currLead.Arrhythmia__c.split(';'))
                {
                    wrapCls.ArrhythmiaString.add(s);
                }
            }
            if(currLead.Ventilator__c != Null)
            {
                wrapCls.ventilatorText = currLead.Ventilator__c;
            }
            if(currLead.Angina__c!= Null)
            {
                
                for(String s : currLead.Angina__c.split(';'))
                {
                    wrapCls.anginaString.add(s);
                }
            } 
            
            if(currLEad.Lung_Disease__c != Null)
            {
                for(String s : currLead.Lung_Disease__c.split(';'))
                {
                    wrapCls.lungDiseaseString.add(s);
                }
            }
            
        }
    }
    
    //Used to get current condition and recomendation to chapter
    public void init()
    {
        Constant_AC  constant = new Constant_AC();
        Id algorithmRecordTypeId = Schema.SObjectType.Medical_questions__c.getRecordTypeInfosByName().get(constant.travelAlgmRT).getRecordTypeId();
        
        for(Medical_Questions__c currRec : [SELECT Current_Condition__c,Recommendation_to_Chapter__c,Wrapper_Variable__c 
                                            FROM Medical_Questions__c WHERE RecordtypeId = :algorithmRecordTypeId ])
        {
            if(currRec.Wrapper_Variable__c != Null)
            {
                travelLabel.put(currRec.Wrapper_Variable__c,currRec.Current_Condition__c);
                travelVal.put(currRec.Wrapper_Variable__c, currRec.Recommendation_to_Chapter__c);
            }
            if(currRec.Current_Condition__c!= Null)
                travelMap.put(currRec.Current_Condition__c,currRec.Wrapper_Variable__c);
        }
    }
    
    //Used to validate password and whether the document is already signed
    public pagereference submit(){
        if(currLead.isSign__c == true) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Document already reviewed, Please contact chapter staff for access');
            ApexPages.addMessage(myMsg);
        } else if(password != currLead.Part_A_Form_Password__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Inccorect password');
            ApexPages.addMessage(myMsg);
        } else if(password == currLead.Part_A_Form_Password__c){
            login = true;
        } 
        return null;
    }
    
    //Used to get state recognization picklist values
    Public List<SelectOption> getStateRecognizationPicklistValues(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Lead.I_am_Recognized_To_Practice_As_a__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Please Select'));
        for(Schema.PicklistEntry fieldValue : picklistValues){
            options.add(new SelectOption(fieldValue.getLabel(), fieldValue.getValue()));
        } 
        return options;           
    }
    
    // If primary diagonis has group1 record and the medical question is satisfied the condition then the wish would consider as eligible. If not, then submitter would be asked for secoundary diagnosis and verification process will occur similar to the previous one.
    public void primaryDiagnosisEligibility() {
        identifyICDPCD = Apexpages.currentPage().getParameters().get('identifyFieldValue');
        medicalPicklistValWrapper.clear();
        if(!String.isEmpty(identifyICDPCD) && identifyICDPCD == 'ICD') {
            List<ICD_Codes__c> icdConditionDescriptionCheck = [SELECT Id, Condition_Description__c, Condition_Description__r.Name, Group1__c FROM ICD_Codes__c WHERE Name =: wrapCls.diagnosisFilter];
            if(icdConditionDescriptionCheck.size() > 0) {
                MediacalQuestions(icdConditionDescriptionCheck[0].Condition_Description__r.Name+'_'+(icdConditionDescriptionCheck[0]).Group1__c, null, wrapCls.diagnosisFilter, 1,identifyICDPCD);
            }
        } else if(!String.isEmpty(identifyICDPCD) && identifyICDPCD == 'PCD'){
            List<Condition_Description__c> conditionDescriptionCheck = [SELECT Id,Group1__c, Name FROM Condition_Description__c WHERE Name =: wrapCls.selectedPrimaryDiagnosis];
                if(conditionDescriptionCheck.size() > 0) {
                    MediacalQuestions(wrapCls.selectedPrimaryDiagnosis+'_'+conditionDescriptionCheck[0].Group1__c, null,wrapCls.diagnosisFilter, 1,identifyICDPCD);
                }
        } else {
            wrapCls.otherDiagnosis = true;
            wrapCls.eligibleForWish = false;
        }
    }    
    
    // Other diagnosis condition1 eligibility check
    public void otherDiagnosisEligibilityCondition1() {
        medicalPicklistOtherWrapper1.clear();
        if(!String.isEmpty(wrapCls.diagnosisFilterVal1)) {
            List<ICD_Codes__c> icdConditionDescriptionCheck = [SELECT Id, Condition_Description__c, Group1__c FROM ICD_Codes__c WHERE Condition_Description__r.Name =: wrapCls.diagnosisFilterVal1];
            if(icdConditionDescriptionCheck.size() > 0) {
                MediacalQuestions(wrapCls.diagnosisFilterVal1+'_'+(icdConditionDescriptionCheck[0]).Group1__c, null, wrapCls.diagnosisFilter1, 2,identifyICDPCD);
            } else if(icdConditionDescriptionCheck.size() == 0) {               
                List<Condition_Description__c> conditionDescriptionCheck = [SELECT Id,Group1__c, Name FROM Condition_Description__c WHERE Name =: wrapCls.diagnosisFilterVal1];
                if(conditionDescriptionCheck.size() > 0) {                      
                    MediacalQuestions(wrapCls.diagnosisFilterVal1+'_'+conditionDescriptionCheck[0].Group1__c, null,wrapCls.diagnosisFilter1, 2,identifyICDPCD);
                } else if(conditionDescriptionCheck.size() == 0) {                       
                    wrapCls.otherDiagnosis1 = true;
                    wrapCls.eligibleForWish = false;
                }
            }
        } else {
            wrapCls.otherDiagnosis1 = true;
            wrapCls.eligibleForWish = false;
        }
    }
    
    // Other diagnosis condition2 eligibility check
    public void otherDiagnosisEligibilityCondition2() {
        medicalPicklistOtherWrapper2.clear();
        if(!String.isEmpty(wrapCls.diagnosisFilterVal2)) {
            List<ICD_Codes__c> icdConditionDescriptionCheck = [SELECT Id, Condition_Description__c, Group1__c FROM ICD_Codes__c WHERE Condition_Description__r.Name =: wrapCls.diagnosisFilterVal2];
            if(icdConditionDescriptionCheck.size() > 0) {               
                MediacalQuestions(wrapCls.diagnosisFilterVal2+'_'+(icdConditionDescriptionCheck[0]).Group1__c, null, wrapCls.diagnosisFilter2, 3,identifyICDPCD);
            } else if(icdConditionDescriptionCheck.size() == 0) {              
                List<Condition_Description__c> conditionDescriptionCheck = [SELECT Id,Group1__c, Name FROM Condition_Description__c WHERE Name =: wrapCls.diagnosisFilterVal2];
                if(conditionDescriptionCheck.size() > 0) {         
                    MediacalQuestions(wrapCls.diagnosisFilterVal2+'_'+conditionDescriptionCheck[0].Group1__c, null,wrapCls.diagnosisFilter2, 3,identifyICDPCD);
                } else if(conditionDescriptionCheck.size() == 0) {
                    wrapCls.otherDiagnosis2 = true;
                    wrapCls.eligibleForWish = false;
                }
            }
        } else {
            wrapCls.otherDiagnosis2 = true;
            wrapCls.eligibleForWish = false;
        }
    }
    
    // Other diagnosis condition3 eligibility check
    public void otherDiagnosisEligibilityCondition3() {
        medicalPicklistOtherWrapper3.clear();
        if(!String.isEmpty(wrapCls.diagnosisFilterVal3)) {
            List<ICD_Codes__c> icdConditionDescriptionCheck = [SELECT Id, Condition_Description__c, Group1__c FROM ICD_Codes__c WHERE Condition_Description__r.Name =: wrapCls.diagnosisFilterVal3];
            if(icdConditionDescriptionCheck.size() > 0) {
                MediacalQuestions(wrapCls.diagnosisFilterVal3+'_'+(icdConditionDescriptionCheck[0]).Group1__c, null, wrapCls.diagnosisFilter3, 4,identifyICDPCD);
            } else if(icdConditionDescriptionCheck.size() == 0) {
                List<Condition_Description__c> conditionDescriptionCheck = [SELECT Id,Group1__c, Name FROM Condition_Description__c WHERE Name =: wrapCls.diagnosisFilterVal3];
                if(conditionDescriptionCheck.size() > 0) {
                    MediacalQuestions(wrapCls.diagnosisFilterVal3+'_'+conditionDescriptionCheck[0].Group1__c, null,wrapCls.diagnosisFilter3, 4,identifyICDPCD);
                } else if(conditionDescriptionCheck.size() == 0) {
                    wrapCls.otherDiagnosis3 = true;
                    wrapCls.eligibleForWish = false;
                }
            }
        } else {
            wrapCls.otherDiagnosis3 = true;
            wrapCls.eligibleForWish = false;
        }
    }
    
    
    // Other diagnosis condition4 eligibility check
    public void otherDiagnosisEligibilityCondition4() {
        medicalPicklistOtherWrapper4.clear();
        if(!String.isEmpty(wrapCls.diagnosisFilterVal4)) {
            List<ICD_Codes__c> icdConditionDescriptionCheck = [SELECT Id, Condition_Description__c, Group1__c FROM ICD_Codes__c WHERE Condition_Description__r.Name =: wrapCls.diagnosisFilterVal4];
            if(icdConditionDescriptionCheck.size() > 0) {
                MediacalQuestions(wrapCls.diagnosisFilterVal4+'_'+(icdConditionDescriptionCheck[0]).Group1__c, null, wrapCls.diagnosisFilter4, 5,identifyICDPCD);
            } else if(icdConditionDescriptionCheck.size() == 0) {
                List<Condition_Description__c> conditionDescriptionCheck = [SELECT Id,Group1__c, Name FROM Condition_Description__c WHERE Name =: wrapCls.diagnosisFilterVal4];
                if(conditionDescriptionCheck.size() > 0) {
                    MediacalQuestions(wrapCls.diagnosisFilterVal4+'_'+conditionDescriptionCheck[0].Group1__c, null,wrapCls.diagnosisFilter4, 5,identifyICDPCD);
                } else if(conditionDescriptionCheck.size() == 0) {
                    wrapCls.notEligibleForWish = true;
                    wrapCls.eligibleForWish = false;
                }
            }
        } else {
            wrapCls.notEligibleForWish = true;
            wrapCls.eligibleForWish = false;
        }
    }
    
    //Secondary diagnosis1 verification visibility check method
    public pageReference groupQuestions() {
        if(wrapCls.ansForQes != null && wrapCls.ansForQes == 'Yes') {
            wrapCls.eligibleForWish = true;
            wishStatus = 'Qualified';
            wrapCls.otherDiagnosis = false;
            wrapCls.displayMedicalQuestion1 = false;
            wrapCls.notEligibleForWish = false;
        } else if((wrapCls.ansForQes != null && wrapCls.ansForQes == 'No') || wrapCls.ansForQes == 'ShowNext') {
            wrapCls.otherDiagnosis = true;
            wrapCls.eligibleForWish = false;
            wishStatus = '';
        }
        return null; 
    }
    
    //Secondary diagnosis2 verification visibility check method
    public pageReference groupQuestions1() {
        if(wrapCls.ansForQes1 != null && wrapCls.ansForQes1 == 'Yes') {
            wrapCls.eligibleForWish = true;
            wishStatus = 'Qualified';
            wrapCls.notEligibleForWish = false;
            wrapCls.otherDiagnosis1 = false;
            wrapCls.displayMedicalQuestion2 = false;
        } else if((wrapCls.ansForQes1 != null && wrapCls.ansForQes1 == 'No') || wrapCls.ansForQes1 == 'ShowNext') {
            System.debug('Ans1');
            wrapCls.otherDiagnosis1 = true;
            wrapCls.eligibleForWish = false;
            wishStatus = '';
        }
        return null; 
    }
    
    //Secondary diagnosis3 verification visibility check method
    public pageReference groupQuestions2() {
        if(wrapCls.ansForQes2 != null && wrapCls.ansForQes2 == 'Yes') {
            wrapCls.eligibleForWish = true;
            wishStatus = 'Qualified';
            wrapCls.notEligibleForWish = false;
            wrapCls.otherDiagnosis2 = false;
            wrapCls.displayMedicalQuestion3 = false;
        } else if((wrapCls.ansForQes2 != null && wrapCls.ansForQes2 == 'No') || wrapCls.ansForQes2 == 'ShowNext') {
            wrapCls.otherDiagnosis2 = true;
            wrapCls.eligibleForWish = false;
            wishStatus = '';
        }
        return null; 
    }
    
    //Secondary diagnosis4 verification visibility check method
    public pageReference groupQuestions3() {
        if(wrapCls.ansForQes3 != null && wrapCls.ansForQes3 == 'Yes') {
            wrapCls.eligibleForWish = true;
            wishStatus = 'Qualified';
            wrapCls.notEligibleForWish = false;
            wrapCls.otherDiagnosis3 = false;
            wrapCls.displayMedicalQuestion4 = false;
        } else if((wrapCls.ansForQes3 != null && wrapCls.ansForQes3 == 'No') || wrapCls.ansForQes3 == 'ShowNext') {
            wrapCls.otherDiagnosis3 = true;
            wrapCls.eligibleForWish = false;
            wishStatus = '';
        }
        return null; 
    }
    
    //To check whether wish is qualified or not qualified
    public pageReference groupQuestions4() {
        if(wrapCls.ansForQes4 != null && wrapCls.ansForQes4 == 'Yes') {
            wrapCls.eligibleForWish = true;
            wishStatus = 'Qualified';
            wrapCls.notEligibleForWish = false;
        } else if((wrapCls.ansForQes4 != null && wrapCls.ansForQes4 == 'No') || wrapCls.ansForQes4 == 'ShowNext') {
            wrapCls.notEligibleForWish = true;
            wishStatus = 'Not Qualified';
            wrapCls.eligibleForWish = false;
        }
        return null; 
    }
    
    //Medical Questions new Logics
    public List<medicalWrapper> MediacalQuestions(String conditionDescriptionName, Set<String> conditionSet, String ICDCode, Integer order, String blockValue) {
        System.debug('Condition Description>>>>>>>>>>>>'+conditionDescriptionName.split('_')[0]);
        if(blockValue == 'ICD' && conditionDescriptionName.split('_')[0] != null) {
            medicalQuestionsList = [SELECT Name, Epilepsy_picklist__c, Question__c, Data_Type__c, Picklist_values__c, Condition_Description__c, Condition_Description__r.Name FROM Medical_Questions__c WHERE Condition_Description__r.Name =: conditionDescriptionName.split('_')[0] AND RecordType.Name = 'Medical Questions' ORDER BY Sort_Order__c ASC];
        } else if(blockValue == 'PCD') {
            medicalQuestionsList = [SELECT Name, Epilepsy_picklist__c, Question__c, Data_Type__c, Picklist_values__c, Condition_Description__c, Condition_Description__r.Name FROM Medical_Questions__c WHERE Condition_Description__r.Name =: conditionDescriptionName.split('_')[0] AND RecordType.Name = 'Medical Questions' ORDER BY Sort_Order__c ASC];
        }
        
        if(blockValue == 'ICD') {
            System.debug('ICD>>>>>>>>>>>>>>'+medicalQuestionsList.size());
             wishStatus = '';
            if((medicalQuestionsList.size() > 0) && (conditionDescriptionName.split('_')[0] != 'Intractable Epileptic Spasms' && conditionDescriptionName.split('_')[0] != 'Intractable Epileptic Spasms with status epilepticus' && conditionDescriptionName.split('_')[0] != 'Cardiomyopathy' && conditionDescriptionName.split('_')[0] != 'Epilepsy' && conditionDescriptionName.split('_')[0] != 'Hypertrophic Cardiomyopathy' && conditionDescriptionName.split('_')[0] != 'Restrictive CardioMyopathy' && conditionDescriptionName.split('_')[0] != 'Arrhythmogenic Right Ventricular Cardiomyopathy (ARVC)' && conditionDescriptionName.split('_')[0] != 'Right Ventricular Cardiomyopathy' && conditionDescriptionName.split('_')[0] != 'Ventricular Cardiomyopathy' && conditionDescriptionName.split('_')[0] != 'Intractable Epilepsy' && conditionDescriptionName.split('_')[0] != 'Intractable Epilepsy, complex, symptomatic' && conditionDescriptionName.split('_')[0] != 'Intractable Epilepsy, simple, symptomatic' && conditionDescriptionName.split('_')[0] != 'Epilepsy - Refractory')) {
                System.debug('Not Group1 Record>>>>');
                wrapCls.eligibleForWish = false;
                if(order == 1) {
                    wrapCls.displayMedicalQuestion = true;
                } else if(order == 2) {
                    wrapCls.displayMedicalQuestion1 = true;
                } else if(order == 3) {
                    wrapCls.displayMedicalQuestion2 = true;
                } else if(order == 4) {
                    wrapCls.displayMedicalQuestion3 = true;
                } else if(order == 5) {
                    wrapCls.displayMedicalQuestion4 = true;
                }
                
            } else if(medicalQuestionsList.size() > 0  && (conditionDescriptionName.split('_')[0] == 'Intractable Epileptic Spasms' && conditionDescriptionName.split('_')[0] == 'Intractable Epileptic Spasms with status epilepticus' ||conditionDescriptionName.split('_')[0] == 'Cardiomyopathy' || conditionDescriptionName.split('_')[0] == 'Epilepsy' || conditionDescriptionName.split('_')[0] == 'Hypertrophic Cardiomyopathy' || conditionDescriptionName.split('_')[0] == '	Restrictive CardioMyopathy' || conditionDescriptionName.split('_')[0] == 'Arrhythmogenic Right Ventricular Cardiomyopathy (ARVC)' || conditionDescriptionName.split('_')[0] == 'Right Ventricular Cardiomyopathy' || conditionDescriptionName.split('_')[0] == 'Ventricular Cardiomyopathy' || conditionDescriptionName.split('_')[0] == 'Intractable Epilepsy' || conditionDescriptionName.split('_')[0] == 'Intractable Epilepsy, complex, symptomatic' || conditionDescriptionName.split('_')[0] == 'Intractable Epilepsy, simple, symptomatic' || conditionDescriptionName.split('_')[0] == 'Epilepsy - Refractory')) {
                if(conditionDescriptionName.split('_')[1] == 'true') {
                    System.debug('Eligible for Wish>>>>>>>>>>>');
                    wrapCls.eligibleForWish = true;
                    wrapCls.notEligibleForWish = false;
                    if(order == 1) {
                        wrapCls.displayMedicalQuestion = false;
                    } else if(order == 2) {
                        wrapCls.displayMedicalQuestion1 = false;
                    } else if(order == 3) {
                        wrapCls.displayMedicalQuestion2 = false;
                    } else if(order == 4) {
                        wrapCls.displayMedicalQuestion3 = false;
                    } else if(order == 5) {
                        wrapCls.displayMedicalQuestion4 = false;
                    }
                } else if(conditionDescriptionName.split('_')[1] != 'true') {
                    System.debug('Not Eligible for Wish>>>>>>>>>>>');
                    wrapCls.eligibleForWish = false;
                    if(order == 1) {
                        wrapCls.displayMedicalQuestion = true;
                    } else if(order == 2) {
                        wrapCls.displayMedicalQuestion1 = true;
                    } else if(order == 3) {
                        wrapCls.displayMedicalQuestion2 = true;
                    } else if(order == 4) {
                        wrapCls.displayMedicalQuestion3 = true;
                    } else if(order == 5) {
                        wrapCls.displayMedicalQuestion4 = true;
                    }
                } else if(medicalQuestionsList.size() == 0 && conditionDescriptionName.split('_')[1] == 'true') {
                    System.debug('Medical Question 0>>>>>>>>>>>');
                    wrapCls.eligibleForWish = true;
                    wrapCls.notEligibleForWish = false;
                } else {
                    System.debug('No Eligible Records>>>>>>');
                    wrapCls.eligibleForWish = false;
                    if(order == 1) {
                        wrapCls.otherDiagnosis = true;
                    } else if(order == 2) {
                        wrapCls.otherDiagnosis1 = true;
                    } else if(order == 3) {
                        wrapCls.otherDiagnosis2 = true;
                    } else if(order == 4) {
                        wrapCls.otherDiagnosis3 = true;
                    } else if(order == 5) {
                        wrapCls.otherDiagnosis4 = true;
                    }
                }
            }
            
        } else if(blockValue == 'PCD') {
            wishStatus = '';
            if(conditionDescriptionName.split('_')[1] == 'true') {
                wrapCls.eligibleForWish = true;
                wrapCls.notEligibleForWish = false;
                if(order == 1) {
                    wrapCls.displayMedicalQuestion = false;
                } else if(order == 2) {
                    wrapCls.displayMedicalQuestion2 = false;
                } else if(order == 3) {
                    wrapCls.displayMedicalQuestion2 = false;
                } else if(order == 4) {
                    wrapCls.displayMedicalQuestion3 = false;
                } else if(order == 5) {
                    wrapCls.displayMedicalQuestion4 = false;
                }
                
            } else if(medicalQuestionsList.size() > 0) {
                wrapCls.eligibleForWish = true;
                wrapCls.notEligibleForWish = false;
                if(order == 1) {
                    wrapCls.displayMedicalQuestion = true;
                } else if(order == 2) {
                    wrapCls.displayMedicalQuestion1 = true;
                } else if(order == 3) {
                    wrapCls.displayMedicalQuestion2 = true;
                } else if(order == 4) {
                    wrapCls.displayMedicalQuestion3 = true;
                } else if(order == 5) {
                    wrapCls.displayMedicalQuestion4 = true;
                }
            } else {
                wrapCls.eligibleForWish = true;
                wrapCls.notEligibleForWish = false;
                if(order == 1) {
                    wrapCls.otherDiagnosis = true;
                } else if(order == 2) {
                    wrapCls.otherDiagnosis1 = true;
                } else if(order == 3) {
                    wrapCls.otherDiagnosis2 = true;
                } else if(order == 4) {
                    wrapCls.otherDiagnosis3 = true;
                } else if(order == 5) {
                    wrapCls.notEligibleForWish = true;
                }
            }
        }
        
        
        
        
        if(medicalQuestionsList.size() > 0) {
            for(Medical_Questions__c mediQues : medicalQuestionsList) {
                medicalWrapper mergePicklistVal = new medicalWrapper(mediQues,conditionDescriptionName,ICDCode,order);
                if(order == 1)
                {   
                    if(medicalPicklistValWrapper.size() == 0) {
                        medicalPicklistValWrapper = new List<medicalWrapper>();
                    }
                    medicalPicklistValWrapper.add(mergePicklistVal);
                }
                if(order == 2)
                {
                    if(medicalPicklistOtherWrapper1.size() == 0) {
                        medicalPicklistOtherWrapper1 = new List<medicalWrapper>();
                    }
                    medicalPicklistOtherWrapper1.add(mergePicklistVal);
                }
                if(order == 3)
                {
                    if(medicalPicklistOtherWrapper2.size() == 0) {
                        medicalPicklistOtherWrapper2= new List<medicalWrapper>();
                    }
                    medicalPicklistOtherWrapper2.add(mergePicklistVal);
                }
                if(order == 4)
                {
                    if(medicalPicklistOtherWrapper3.size() == 0) {
                        medicalPicklistOtherWrapper3= new List<medicalWrapper>();
                    }
                    medicalPicklistOtherWrapper3.add(mergePicklistVal);
                }
                if(order == 5)
                {
                    if(medicalPicklistOtherWrapper4.size() == 0) {
                        medicalPicklistOtherWrapper4= new List<medicalWrapper>();
                    }
                    medicalPicklistOtherWrapper4.add(mergePicklistVal);
                }
            }
        }
        return medicalPicklistValWrapper;
    }
    
    //To check for qualified epilepsy value
    public void epilepsy() {
        if(epilepsyClass == 'epilepsyRadio' && epilepsyVal != 'Not Intractable' && Integer.valueOf(wrapCls.describePatient) <= 5) {
            wrapCls.eligibleForWish = true;
            wishStatus = 'Qualified';
            wrapCls.notEligibleForWish = false;
            wrapCls.otherDiagnosis = false;
        } else if(epilepsyClass == 'epilepsyRadio') {
            wrapCls.otherDiagnosis = true;
            wrapCls.eligibleForWish = false;
        }       
    }
    
    //Used to update the describe patient values
    public void changePatientValue() {
        wrapCls.describePatient = selectedItemValue;
    }
    
    //To set wish is not eligible
    public void notEligibleWish(){
        wrapCls.notEligibleForWish = true;
        wrapCls.eligibleForWish = false;
        wishStatus = 'Not Qualified';
    }
    
    //To get  vegitative Id
    public void vegitativeId() {
        wrapCls.vegetativeState = vId;
    }
    
    //Used to change the wish status
    public void wishStatus() {
        wrapCls.eligibleForWish = false;
        wrapCls.notEligibleForWish = false;
        wishStatus = '';
    }
    
    // Auto Complete the ICD Code values.
    @RemoteAction
    public static List<ICD_Codes__c> searchDiagnosis(String searchTerm) {
        List<ICD_Codes__c> icdCodes = Database.query('SELECT Id, Name,Condition_Description__c, Condition_Description__r.Name, Short_Description__c FROM ICD_Codes__c WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return icdCodes;
    } 
    
    // Auto Complete the Dianosis field value.
    @RemoteAction
    public static List<Condition_Description__c> searchCondition(String searchTerm) {
        List<Condition_Description__c> conditionDescriptions = Database.query('Select Id, Name, Code_To_Use__c from Condition_Description__c where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        if(!(conditionDescriptions.size() > 0))
        {
            conditionDescriptions =[Select Id, Name, Code_To_Use__c from Condition_Description__c WHERE Not_Listed__c = True];
        }
        return conditionDescriptions;
    }  
    
    //Auto populate form diagnosis
    @RemoteAction
    public static List<Condition_Description__c> searchDiagnosis1(String searchTerm) {
        List<Condition_Description__c> conditionDescriptions = Database.query('SELECT Id, Name, Code_To_Use__c FROM Condition_Description__c WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return conditionDescriptions;
    }
    
    //Used to save the info submitted through Diagnosis Verification Page and Redirect to docusign page
    public PageReference SaveMedicalInfo() {
        
        List<Diagnosis_Verification__c> diagnosisVerificationOldList = [SELECT Id FROM Diagnosis_Verification__c WHERE Lead__c  =: wrapCls.leadId];
        if(diagnosisVerificationOldList.size() > 0) {
            delete diagnosisVerificationOldList; 
        }
        
        List<Diagnosis_Verification__c> diagnosisVerificationList = new List<Diagnosis_Verification__c>();
        
        if(medicalPicklistOtherWrapper1.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper1);
        if(medicalPicklistOtherWrapper2.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper2);
        if(medicalPicklistOtherWrapper3.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper3);
        if(medicalPicklistOtherWrapper4.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper4);
        
        for(medicalwrapper saveRec : medicalPicklistValWrapper) {
            Diagnosis_Verification__c diagnosisVerification = new Diagnosis_Verification__c();
            diagnosisVerification.ICD_Code__c = saveRec.ICDCode;
            diagnosisVerification.Reason_for_Need__c = saveRec.reasonForNeed;
            diagnosisVerification.Lead__c = wrapCls.leadId;
            diagnosisVerification.Medical_Question__c = saveRec.medicalInfo.Id;
            diagnosisVerification.Medical_Question_Answer__c = saveRec.selectedPickVal;
            diagnosisVerification.Epilepsy_Value__c = saveRec.epilepsySelectedPickVal;
            diagnosisVerification.Order__c = saveRec.order;
            diagnosisVerification.Primary_Diagnosis__c = saveRec.diagnosis;
            diagnosisVerificationList.add(diagnosisVerification);
        }
        
        insert diagnosisVerificationList;
        
        updateLeadDetails();
        
        PageReference reference = new PageReference('/LeadPartA_ApprovalForm_VF_Output?Id='+currLead.id);
        reference.setRedirect(true);
        return reference;
    }
    //Used to save the info submitted through Diagnosis Verification Page
    public PageReference SaveMedicalInfo1() {        
        List<Diagnosis_Verification__c> diagnosisVerificationOldList = [SELECT Id FROM Diagnosis_Verification__c WHERE Lead__c  =: wrapCls.leadId];
        if(diagnosisVerificationOldList.size() > 0) {
            delete diagnosisVerificationOldList; 
        }
        
        List<Diagnosis_Verification__c> diagnosisVerificationList = new List<Diagnosis_Verification__c>();
        
        if(medicalPicklistOtherWrapper1.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper1);
        if(medicalPicklistOtherWrapper2.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper2);
        if(medicalPicklistOtherWrapper3.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper3);
        if(medicalPicklistOtherWrapper4.size() > 0)
            medicalPicklistValWrapper.addAll(medicalPicklistOtherWrapper4);
        
        for(medicalwrapper saveRec : medicalPicklistValWrapper) {
            Diagnosis_Verification__c diagnosisVerification = new Diagnosis_Verification__c();
            diagnosisVerification.ICD_Code__c = saveRec.ICDCode;
            diagnosisVerification.Reason_for_Need__c = saveRec.reasonForNeed;
            diagnosisVerification.Lead__c = wrapCls.leadId;
            diagnosisVerification.Medical_Question__c = saveRec.medicalInfo.Id;
            diagnosisVerification.Medical_Question_Answer__c = saveRec.selectedPickVal;
            diagnosisVerification.Epilepsy_Value__c = saveRec.epilepsySelectedPickVal;
            diagnosisVerification.Order__c = saveRec.order;
            diagnosisVerification.Primary_Diagnosis__c = saveRec.diagnosis;
            diagnosisVerificationList.add(diagnosisVerification);
        }
        
        insert diagnosisVerificationList;
        
        updateLeadDetails();
        
        PageReference reference = new PageReference('/verification_success');
        reference.setRedirect(true);
        return reference;
    }
    
    
    //Used to update lead information submitted from the diagnosis verification page from portal
    public void updateLeadDetails() {
        
        currLead.RFI_Form_Info_Hidden__c = wishStatus;
        currLead.Please_Explain_Deteriorate__c = explainDeteriorate;
        currLead.Child_will_ultimately_die_prematurely__c = false;
        currLead.Treatment_may_be_feasible_but_can_fail__c = false;
        currLead.Treatment_may_prolong_normal_activities__c = false;
        currLead.Debilitation_may_extend_over_many_years__c = false;
        currLead.Increased_probability_of_premature_death__c = false;
        currLead.Risk_of_complications_premature_death__c = false;
        currLead.Responds_to_treatment_with_normal_health__c = false;
        currLead.None_of_these_statements_describes_Child__c = false;
        Set<String> travelValuesSet = new Set<String>();
        Set<String> travelValuesLabel = new Set<String>();
        
        
        String jsonString = json.serialize(wrapCls);
        Map<String,Object> wrapClsMap = new Map<String,Object>();
        wrapClsMap= (Map<String,Object>)json.deserializeuntyped(jsonString);
        
        for(String currString : travelVal.keySet())
        {
            if(wrapClsMap.get(currString) == True)
            {
                travelValuesSet.add(travelVal.get(currString));
                travelValuesLabel.add(travelLabel.get(currString));
            }
        }
        
        
        currLead.Current_Condition_label__c = '';
        
        for(String s : travelValuesLabel)
        {
            currLead.Current_Condition_label__c+=s+';';
        }
        
        
        if(wrapCls.chronicHepatitisString != Null)
        {
            currLead.Chronic_Hepatitis__c = wrapCls.chronicHepatitisString;
            if(travelAlgorithmMap.containsKey(wrapCls.chronicHepatitisString)) {
                travelValuesSet.add(travelAlgorithmMap.get(wrapCls.chronicHepatitisString));
            }
        }
        if(wrapCls.pulmonaryHypertensionString != Null)
        {
            currLead.Pulmonary_Hypertension__c = wrapCls.pulmonaryHypertensionString;
            if(travelAlgorithmMap.containsKey(wrapCls.pulmonaryHypertensionString)) {
                travelValuesSet.add(travelAlgorithmMap.get(wrapCls.pulmonaryHypertensionString));
            }
        }
        if(wrapCls.strokesType != Null)
        {
            currLead.Strokes__c = wrapCls.strokesType ;
            if(travelAlgorithmMap.containsKey(wrapCls.strokesType)) {
                travelValuesSet.add(travelAlgorithmMap.get(wrapCls.strokesType));
            }
        }
        
        currLead.Convulsive_Disorders__c = '';
        if(wrapCls.convulsiveDisorders != Null)
        {
            for(String s : wrapCls.convulsiveDisorders)
            {
                currLead.Convulsive_Disorders__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
            }
        }
        currLead.Congenital_Heart_Disease__c = '';
        if(wrapCls.congenitalHeartDiseaseString != Null)
        {
            for(String s : wrapCls.congenitalHeartDiseaseString )
            {
                currLead.Congenital_Heart_Disease__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
                
            }
        }
        currLead.Chronic_Heart_Failure__c = '';
        if(wrapCls.chronicHeartFailureString != Null)
        {
            for(String s : wrapCls.chronicHeartFailureString)
            {
                currLead.Chronic_Heart_Failure__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
            }
        }
        currLead.Heart_Failure__c = '';
        if(wrapCls.heartFailureString!= Null)
        {
            for(String s : wrapCls.heartFailureString)
            {
                currLead.Heart_Failure__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
            }
        }
        currLead.Arrhythmia__c = '';
        if(wrapCls.ArrhythmiaString!= Null)
        {
            for(String s : wrapCls.ArrhythmiaString)
            {
                currLead.Arrhythmia__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
            }
        }
        currLead.Angina__c = '';
        if(wrapCls.anginaString!= Null)
        {
            for(String s : wrapCls.anginaString)
            {
                currLead.Angina__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
            }
        }
        currLead.Ventilator__c = wrapCls.ventilatorText;
        if(wrapCls.ventilatorText != null) {
            travelValuesSet.add(wrapCls.ventilatorText);
        }
        
        currLead.lung_disease__c='';
        if(wrapCls.lungDiseaseString!= Null)
        {
            for(String s : wrapCls.lungDiseaseString)
            {
                currLead.lung_disease__c+=s+';';
                if(travelAlgorithmMap.containsKey(s)) {
                    travelValuesSet.add(travelAlgorithmMap.get(s));
                }
            }
        } 
        
        currLead.Current_Condition__c = '';
        for(String s : travelValuesSet)
        {
            if(!String.isEmpty(s)) {
                currLead.Current_Condition__c+=s+';';
            }
            
        }
        
        if(wrapCls.describePatient == '1') {
            currLead.Child_will_ultimately_die_prematurely__c = true;
        } else if(wrapCls.describePatient == '2') {
            currLead.Treatment_may_be_feasible_but_can_fail__c = true;
        } else if(wrapCls.describePatient == '3') {
            currLead.Treatment_may_prolong_normal_activities__c = true;
        } else if(wrapCls.describePatient == '4') {
            currLead.Debilitation_may_extend_over_many_years__c = true;
        } else if(wrapCls.describePatient == '5') {
            currLead.Increased_probability_of_premature_death__c = true;
        } else if(wrapCls.describePatient == '6') {
            currLead.Risk_of_complications_premature_death__c = true;
        } else if(wrapCls.describePatient == '7') {
            currLead.Responds_to_treatment_with_normal_health__c = true;
        } else if(wrapCls.describePatient == '8') {
            currLead.None_of_these_statements_describes_Child__c = true;
        }
        newAttachment.OwnerId = UserInfo.getUserId();
        newAttachment.ParentId = wrapCls.leadId; // the record the file is attached to
        newAttachment.IsPrivate = true;
        if(newAttachment.Name != null && newAttachment.Body != null) {
            if(newAttachment.Name.contains(wishChildMedicalSummary)) {
            } else {
                newAttachment.Name = wishChildMedicalSummary + newAttachment.Name;
            }
            //newAttachment.Description = wishChildEligibilityNotes;
            insert newAttachment;
        } else if (newAttachment.Name == null && newAttachment.Body == null) {
            System.debug('????????????FileAttachment???????');
            List<Lead_File__c> medicalSummaryList = [SELECT Id, Parent__c, Description__c, File_Name__c FROM Lead_File__c WHERE Parent__c =: wrapCls.leadId AND File_Name__c LIKE : wishChildMedicalSummaryNameText order by CreatedDate desc LIMIT 1];
            
            if(medicalSummaryList.size() > 0 ) {
                //medicalSummaryList.get(0).Description__c = wishChildEligibilityNotes;
                update medicalSummaryList;
            }
        }
        currLead.Why_do_you_feel_would_be_eligible_Wish__c = wishChildEligibilityNotes;
        currLead.Treating_Medical_Professional_First_Name__c =  wrapCls.treatingFName;
        currLead.Treating_Medical_Professional_Last_Name__c = wrapCls.treatingLName;
        currLead.Treating_Medical_Professional_Phone__c = wrapCls.treatingPhone;
        currLead.Treating_Medical_Professional_Email__c = wrapCls.treatingEmail;
        currLead.Hospital_Treatment_Facility_Treating__c = wrapCls.treatingHospital;
        currLead.Is_We_Need_To_Expedite_The_Process__c = wrapCls.expediteTheProcess;
        currLead.Please_Explain__c =  wrapCls.plzExplain;
        currLead.Will_Child_s_Condition_Deteriorate__c = wrapCls.conditioDeteriorate;
        currLead.SD1_ICD_Code__c = wrapCls.diagnosisFilter1; 
        currLead.SD2_ICD_Code__c = wrapCls.diagnosisFilter2; 
        currLead.SD3_ICD_Code__c = wrapCls.diagnosisFilter3; 
        currLead.SD4_ICD_Code__c = wrapCls.diagnosisFilter4; 
        currLead.PD_ICD_Code__c = wrapCls.diagnosisFilter;
        currLead.SD1_Condition_Description__c = wrapCls.diagnosisFilterVal1; 
        currLead.SD2_Condition_Description__c = wrapCls.diagnosisFilterVal2; 
        currLead.SD3_Condition_Description__c = wrapCls.diagnosisFilterVal3; 
        currLead.SD4_Condition_Description__c = wrapCls.diagnosisFilterVal4; 
        currLead.PD_Condition_Description__c = wrapCls.selectedPrimaryDiagnosis; 
        currLead.I_am_Recognized_To_Practice_As_a__c = wrapCls.recognizationPickValSelected;
        currLead.I_m_Part_of_The_Treating_HealthCare_Team__c =  wrapCls.healthCareWork ;
        currLead.Is_in_a_Comatose_Vegetative_State__c =  wrapCls.vegetativeState ;
        currLead.Medical_Questions__c = getQuestioList;
        currLead.Travel_algorithm__c = wrapCls.algorithmCheckList;
        currLead.Month__c = wrapCls.monthPickList;
        currLead.TPN_Year__c = wrapCls.yearPickList;
        currLead.Reason_for_Need__c = wrapCls.reasonForNeed;
        currLead.Override_Dupe_Check__c = true;
        
        if(communicationList != Null)
        {
            String communications ='';
            for(String s : (communicationList))
            {
                communications+=s+';';
            }
            currLead.Communication__c  = communications.removeEnd(';');
        }
        update currLead;
    }
    
    //Used to redirect to docusig page
    public PageReference docusignRedirect() {
        PageReference reference=new PageReference('/LeadPartA_ApprovalForm_VF_Output?Id='+currLead.id);
        reference.setRedirect(true);
        return reference;
    }
    
    //Yes or No know Picklist Values
    public List<SelectOption> getPickListYesNo() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please Select'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }
    //Yes or No and I don't know Picklist Values
    public List<SelectOption> getPickListYesNoDontno() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please Select'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        options.add(new SelectOption('I don\'t know','I don\'t know'));
        return options;
    }
    
    //For Cardio Picklist
    public List<SelectOption> getCardioPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please Select'));
        options.add(new SelectOption('Yes','Hypertrophic'));
        options.add(new SelectOption('Yes','Restrictive'));
        options.add(new SelectOption('No','All Other'));
        return options;
    }
    //For Convulsion Picklist
    public List<SelectOption> getConvulsionsPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please Select'));
        options.add(new SelectOption('Yes','Intractable'));
        options.add(new SelectOption('No','Not intractable'));
        return options;
    }
    
    /*To display ContactAtWorks values for current logged in volunteer contact in community.*/
    public List<SelectOption> getHealthCareWorks(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.I_m_Part_of_The_Treating_HealthCare_Team__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Please Select')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }   
    //Communication Picklist
    public List<SelectOption> getCommunications(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.Communication__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Please Select',true));
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }   
    //Month Picklist
    public List<SelectOption> getMonth(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.Month__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Select Month--')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }  
    //Year Picklist
    public List<SelectOption> getYear(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.TPN_Year__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Select Year--')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }  
    
    
    //Wrapper class for lead and medical questions merge
    public class medicalWrapper {
        public List<SelectOption> pickVals {get;set;}
        public List<SelectOption> epilepsyPickVals {get;set;}
        public Medical_Questions__c medicalInfo{get;set;}
        public String selectedPickVal {get;set;}
        public String epilepsySelectedPickVal {get;set;}
        public String diagnosis {get;set;}
        public String ICDCode {get;set;}
        public Integer order {get;set;}
        public String reasonForNeed {get;set;}
        public medicalWrapper(Medical_Questions__c mq, String conditionDescriptionName, String ICDCodee, Integer order1) {
            if(!String.isEmpty(conditionDescriptionName)) {
                diagnosis = conditionDescriptionName.split('_')[0];
            } else {
                diagnosis = conditionDescriptionName;
            }
            order = order1;
            ICDCode = ICDCodee;
            
            medicalInfo = mq;
            //Creating picklist from medical questions field values
            if(medicalInfo.Picklist_values__c != null) {
                pickVals = new List<SelectOption>();
                pickVals.add(new SelectOption('','Please Select'));
                for(String currString: mq.Picklist_values__c.split(',')) {
                    pickVals.add(new SelectOption(currString,currString));
                }
            }
            //Creating picklist from medical questions field values
            if(medicalInfo.Epilepsy_picklist__c != null) {
                epilepsyPickVals = new List<SelectOption>();
                epilepsyPickVals.add(new SelectOption('','Please Select'));
                for(String currString: mq.Epilepsy_picklist__c.split(',')) {
                    epilepsyPickVals.add(new SelectOption(currString,currString));
                }
            }
        }
    }
    
    // Self Fieldset, it holds the mandatory fields of Self relationship.
    public List<Schema.FieldSetMember> getPartAFields() {
        return SObjectType.Lead.FieldSets.Diagnosis_Verfication_Fieldset.getFields();
    }
}