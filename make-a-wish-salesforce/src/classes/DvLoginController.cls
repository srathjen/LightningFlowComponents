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
	}
}