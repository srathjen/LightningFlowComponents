/**
 * @description Diagnosis Verification Login Controller
 * @author Pramod Nagar, Traction on Demand
 * @createdDate 11/Feb/2021
 */
public without sharing class DvLoginController {

	@AuraEnabled(Cacheable=true)
	public static DvLoginFieldsWrapper getLeadInfoByLeadId(String leadId) {
		DvLoginFieldsWrapper dvLoginFieldsWrapper = new DvLoginFieldsWrapper();
		if (String.isEmpty(leadId)) {
			return dvLoginFieldsWrapper;
		}
		try {
			Lead lead = [
					SELECT Id, Part_A_Form_Password__c, Status
					FROM Lead
					WHERE Id = :leadId
			];
			dvLoginFieldsWrapper.isLeadReviewed = false;
			if (!lead.Status.equals(Constant_AC.LEAD_STATUS_REFERRED)) {
				dvLoginFieldsWrapper.isLeadReviewed = true;
			}
			dvLoginFieldsWrapper.formPassword = lead.Part_A_Form_Password__c;
			//Get alert message info to show on login page from metadata
			trac_Diagnosis_Verification_Form_Alert__mdt alertMessageInfo = getAlertMessageInfo();
			if(alertMessageInfo != null) {
				dvLoginFieldsWrapper.isDisplayAlertMessage = alertMessageInfo.trac_Display_Alert__c;
				dvLoginFieldsWrapper.alertMessage = alertMessageInfo.trac_Alert_Message__c;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return dvLoginFieldsWrapper;
	}

	public class DvLoginFieldsWrapper {
		@AuraEnabled
		public String formPassword { get; set; }
		@AuraEnabled
		public Boolean isLeadReviewed { get; set; }
		@AuraEnabled
		public Boolean isDisplayAlertMessage { get; set; }
		@AuraEnabled
		public String alertMessage { get; set; }
	}

	private static trac_Diagnosis_Verification_Form_Alert__mdt getAlertMessageInfo() {
		trac_Diagnosis_Verification_Form_Alert__mdt[] alertMessageInfo = [
			SELECT MasterLabel, trac_Alert_Message__c, trac_Display_Alert__c 
			FROM trac_Diagnosis_Verification_Form_Alert__mdt
		];
		return alertMessageInfo[0];
	}
}