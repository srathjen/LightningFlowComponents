/**************************************************************************************
Author : MST Solutions
Description : This class referred in the LeadSelectMedEmail_VF.Intake form contains both treating medical professional and 
best contact for physicians Then the user must select who have received DV form. 

Modification logs:
1. 12/4/2018 Yuvraj IME-77 Line No: 40,117
2. 10/5/2018 Vignesh IME 122 
3. 10/05/2018 Yuvraj IME-126 Line No: 113
****************************************************************************************/
public class LeadSelectMedEmailController_AC{
    public boolean success {get;set;}
    public Lead currLead {get;set;}
    public string URLToRedirect {get;set;}
    Public string Logvalue; 
    Public string recId; 
    public LeadSelectMedEmailController_AC(){
       // try{
        currLead = [SELECT id, Part_A_Form_Password__c,Using_Paper_Process_For_DV__c, Part_A_Sent__c,Best_Contact_for_Physician_Last_Name__c , HiddenMedicalProfessionalEmail__c, Best_Contact_for_Physician_First_Name__C,Best_contact_for_Physician_Email__c,
                    Treating_Medical_Professional_First_Name__c,Of_Times_Email_Sent__c,Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Email__c, Alternate1MedProfessionalFirstName__c,Alternate1MedProfessionalLastName__c, Alternate1MedProfessionalPhone__c, Alternate1MedicalProfessionalEmail__c, Alternate2MedProfessionalFirstName__c, Alternate2MedProfessionalLastName__c, Alternate2MedProfessionalPhone__c, Alternate2MedProfessionalEmail__c, Part_A_Received__c FROM Lead WHERE id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
      //  }
        
      /* catch(Exception ex){
         Logvalue = string.valueof(currLead);
         recId = currLead.Id;
         new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadSelectMedEmailController_AC','LeadSelectMedEmailController_AC',recId,ex,Logvalue));
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
         ApexPages.addMessage(myMsg);  
        }*/
    }
    //Update the Lead medical professional type.
    public void updateLead(){
       try{
        URLToRedirect = Label.Instance_Url+'/'+currLead.Id;
        currLead.Hidden_DV_form_Medical_professional_Type__c = Apexpages.currentPage().getParameters().get('type');
        currLead.HiddenMedicalProfessionalEmail__c = Apexpages.currentPage().getParameters().get('email');
        //currLead.Hidden_Send_DV_Email__c = email;
        currLead.Sub_Status__c='Pending Diagnosis Verification'; 
        if( currLead.Of_Times_Email_Sent__c == Null ) {
            currLead.Of_Times_Email_Sent__c =  0;
        }
        currLead.Pending_Diagnosis_Date__c = Date.today();//IME-77
        if(Apexpages.currentPage().getParameters().get('sendOrRest') == 'Reset') {
            currLead.Part_A_Form_Password__c = Lead_OnBeforeInsertTriggerHandler.getRandom();
            resetDVValues();
            currLead.Part_A_Received__c = null;
        }
        currLead.Of_Times_Email_Sent__c= currLead.Of_Times_Email_Sent__c + 1; 
        Update currLead;
        success = True;
        }
        
         catch(Exception ex){
         success = false;
         Logvalue = string.valueof(currLead);
         recId = currLead.Id;
         new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadSelectMedEmailController_AC','updateLead',recId,ex,Logvalue));
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
         ApexPages.addMessage(myMsg);  
        }
    }
    
    public void resetDVValues() {
        try{
        List<Lead> leadRec = [SELECT Id,Hidden_Potential_Rush__c, Part_A_Received__c,Part_A_Sent__c, Status, Part_A_Form_Password__c, Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c, PD_Condition_Description__c, PD_ICD_Code__c FROM Lead WHERE Id =: currLead.Id LIMIT 1];
        leadRec[0].PR_Diagnosis__c = '';
        leadRec[0].PD_ICD_Code__c = leadRec[0].ICD_Given_By_Referrer__c;
        leadRec[0].PD_Condition_Description__c = leadRec[0].Diagnosis_Given_By_Referrer__c;
        
        leadRec[0].I_am_Recognized_To_Practice_As_a__c = '';
        leadRec[0].I_m_Part_of_The_Treating_HealthCare_Team__c = '';
        leadRec[0].Is_in_a_Comatose_Vegetative_State__c = '';
        //leadRec[0].Communication__c = '';
        leadRec[0].Part_A_Received__c = Date.today();
        leadRec[0].Part_A_Sent__c = Date.today();
        leadRec[0].Why_do_you_feel_would_be_eligible_Wish__c = '';
        //leadRec[0].Is_We_Need_To_Expedite_The_Process__c = '';//commented out for IME-107
        leadRec[0].Any_medical_reason_for_moving_quickly__c = leadRec[0].Hidden_Potential_Rush__c;//IME-107
        leadRec[0].Rush__c = false;
        leadRec[0].Please_Explain__c = '';
        leadRec[0].Will_Child_s_Condition_Deteriorate__c = '';
        leadRec[0].Please_Explain_Deteriorate__c = '';
        leadRec[0].Provider_Signature__c = '';
        leadRec[0].Current_Condition_Label__c = '';
        //leadRec[0].Treatment_Subspecialty__c = '';
        leadRec[0].Provided_additional_information__c = '';
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
        leadRec[0].Travel_Restriction__c = ''; 
        leadRec[0].Travel_algorithm__c = '';
        leadRec[0].Current_Condition_Label__c = '';
        leadRec[0].isSign__c = false;
        leadRec[0].Sub_Status__c='Pending Diagnosis Verification';
        leadRec[0].Pending_Diagnosis_Date__c = Date.today();//IME-77
        leadRec[0].Status = 'Referred';
        leadRec[0].RFI_Form_Info_Hidden__c = leadRec[0].Status;
        update leadRec;
        DELETE[SELECT Id FROM Diagnosis_Verification__c WHERE Lead__c =: currLead.Id];
        Map<Id, dsfs__DocuSign_Status__c> docusignDeleteList = new Map<Id, dsfs__DocuSign_Status__c>();
        for(dsfs__DocuSign_Status__c docusignRec : [SELECT Id, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Lead__c =: currLead.Id]) {
            docusignDeleteList.put(docusignRec.Id, docusignRec);
        }
        List<Attachment> attachmentList = new List<Attachment>();
        for(Attachment attachment : [SELECT Id FROM Attachment WHERE ParentId IN : docusignDeleteList.keySet()]) {
            attachmentList.add(attachment);
        }
        List<Case> caseDVList = [SELECT Id, Lead__c FROM Case WHERE Lead__c =: currLead.Id AND RecordType.Name = 'Diagnosis Verification Review'];
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
        for(Lead_File__c leadF : [SELECT Id FROM Lead_File__c WHERE Parent__c =: currLead.Id AND Content_Type__c != 'Folder']) {
            leadFileList.add(leadF);
        }
        if(leadFileList.size() > 0) {
            Delete leadFileList; 
        }
        }
         catch(Exception ex){
         success = false;
         Logvalue = string.valueof(currLead);
         recId = currLead.Id;
         new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadSelectMedEmailController_AC','resetDVValues',recId,ex,Logvalue));
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Debug_log_error_message);
         ApexPages.addMessage(myMsg);  
        }
    }
    
    //Go to the lead detail page.
    
    public pageReference GoToLeadViewPage(){
        pageReference page = new pageReference('/'+currLead.Id);
        return page;
    }
    //Method created for redirect action in LEX - IME
    /*@remoteAction
    public static boolean redirectToLeadPage(Lead currLead){
        return true;
    }*/
    
}