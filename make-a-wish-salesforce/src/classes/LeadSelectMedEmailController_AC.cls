/**************************************************************************************
Author :            MST Solutions
Description :       This class referred in the LeadSelectMedEmail_VF.Intake form contains 
                    both treating medical professional and best contact for physicians 
                    Then the user must select who have received DV form. 
Modification logs:
                    1. 12/4/2018 Yuvraj IME-77 Line No: 40,117
                    2. 10/5/2018 Vignesh IME 122 
                    3. 10/05/2018 Yuvraj IME-126 Line No: 113
                    4. 08/07/2019 - Samer - SIW-274: Update Lead Diagnosis Verification Received with 
                     the date DV was signed
                    5. 09/10/2019 - Manik - WLP-423
                    6. 1/2/2020 - CSmith - SIW-342 - field name changes reverted
****************************************************************************************/
public class LeadSelectMedEmailController_AC {

	public Boolean success { get; set; }
	public Lead currLead { get; set; }
	public String URLToRedirect { get; set; }
	public String Logvalue;
	public String recId;

	public LeadSelectMedEmailController_AC() {
		currLead = [
				SELECT Id,Part_A_Form_Password__c,Using_Paper_Process_For_DV__c, Part_A_Sent__c,
						Best_Contact_for_Physician_Last_Name__c, HiddenMedicalProfessionalEmail__c,
						Best_Contact_for_Physician_First_Name__c,Best_contact_for_Physician_Email__c,
						Treating_Medical_Professional_First_Name__c,Of_Times_Email_Sent__c,
						Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Email__c,
						Alternate1MedProfessionalFirstName__c,Alternate1MedProfessionalLastName__c,
						Alternate1MedProfessionalPhone__c, Alternate1MedicalProfessionalEmail__c,
						Alternate2MedProfessionalFirstName__c, Alternate2MedProfessionalLastName__c,
						Alternate2MedProfessionalPhone__c, Alternate2MedProfessionalEmail__c,Part_A_Received__c
				FROM Lead
				WHERE Id = :ApexPages.currentPage().getParameters().get('id')
		];
	}

	//Update the Lead medical professional type.
	public void updateLead() {
		try {
			URLToRedirect = Label.Instance_Url + '/' + currLead.Id;
			currLead.Hidden_DV_form_Medical_professional_Type__c = ApexPages.currentPage().getParameters().get('type');
			currLead.HiddenMedicalProfessionalEmail__c = ApexPages.currentPage().getParameters().get('email');
			currLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
			if (currLead.Of_Times_Email_Sent__c == null) {
				currLead.Of_Times_Email_Sent__c = 0;
			}
			currLead.Pending_Diagnosis_Date__c = Date.today();
			if (ApexPages.currentPage().getParameters().get('sendOrRest') == 'Reset') {
				currLead.Part_A_Form_Password__c = Lead_OnBeforeInsertTriggerHandler.getRandom();
				resetDVValues();
				currLead.Part_A_Received__c = null;
			}
			currLead.Of_Times_Email_Sent__c = currLead.Of_Times_Email_Sent__c + 1;
			update currLead;
			success = true;
		} catch (Exception ex) {
			success = false;
			Logvalue = String.valueOf(currLead);
			recId = currLead.Id;
			new ApexDebugLog().createLog(new ApexDebugLog.Error(
					'LeadSelectMedEmailController_AC', 'updateLead', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	 public void resetDVValues() {
		try {
			LeadService.resetLead(currLead.Id);
			DiagnosisVerificationService.deleteByLeadId(currLead.Id);
			CaseService.deleteByLeadIdAndRecordTypeNames(currLead.Id,
					new List<String>{Constant_AC.CASE_RECORD_TYPE_DIAGNOSIS_VERIFICATION_REVIEW});
			DocuSignService.deleteByLeadIdAndDeleteRelatedAttachments(currLead.Id);
			LeadFileService.deleteNonFolderByLeadId(currLead.Id);
		} catch (Exception ex) {
			success = false;
			Logvalue = String.valueOf(currLead);
			recId = currLead.Id;
			new ApexDebugLog().createLog(new ApexDebugLog.Error(
					'LeadSelectMedEmailController_AC', 'resetDVValues', recId, ex, Logvalue));
			ApexPages.Message myMsg = new ApexPages.Message(
					ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	//Go to the lead detail page.
	public PageReference GoToLeadViewPage() {
		PageReference page = new PageReference('/' + currLead.Id);
		return page;
	}
}