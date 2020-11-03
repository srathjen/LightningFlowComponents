/**
 * @description This form is used as IFrame inside the  Diagnosis Verification form to upload medical summary attachment
 * Modification Log:
 * 09/10/2019 - Manik - WLP-423
 *
 * @author MST Solutions
 *
 * @date : 01/19/2017
 **/
public class DVMedicalSummaryAttachment_AC {

	public Id attachmentId { get; set; }
	public Attachment newAttachment { get; set; }
	public Id recId;
	public Boolean isSaved { get; set; }
	public Boolean isDeleted { get; set; }
	public Id diagnosisVerificationMedicalProfessional;

	public DVMedicalSummaryAttachment_AC() {
		newAttachment = new Attachment();
		recId = ApexPages.currentPage().getParameters().get('id');
		if (ApexPages.currentPage().getParameters().get('saved') != null
				&& ApexPages.currentPage().getParameters().get('saved') == 'true') {
			isSaved = true;
		}
		if (ApexPages.currentPage().getParameters().get('deleted') != null
				&& ApexPages.currentPage().getParameters().get('deleted') == 'true') {
			isDeleted = true;
		}
		diagnosisVerificationMedicalProfessional = findDiagnosisVerificationMedicalProfessional(recId);
	}

	/**
	 * @description Display medical summary attachment to diagnosis verification form
	 * @return Lead Files
	 */
	public List<cg__Lead_File__c> getAttachments() {
		return [
				SELECT Id, cg__Lead__c, File_Path__c, cg__Description__c, cg__File_Name__c,
						cg__Lead__r.Hidden_DV_form_Medical_professional_Type__c, cg__Lead__r.Referring_MP__c,
						cg__Lead__r.Treating_MP__c, cg__Lead__r.Best_Contact__c, cg__Lead__r.Alt_1_MP__c, cg__Lead__r.Alt_2_MP__c
				FROM cg__Lead_File__c
				WHERE cg__Lead__c = :recId
				AND cg__Description__c = :diagnosisVerificationMedicalProfessional
		];
	}

	/**
	 * @description Save new attachment from diagnosis verification form
	 * @return Page Reference
	 */
	public PageReference save() {
		if (newAttachment.Body != null) {
			newAttachment.ParentId = recId;
			newAttachment.Description = diagnosisVerificationMedicalProfessional;
			insert newAttachment;
			newAttachment = new Attachment();
		}
		PageReference redirect = new PageReference('/apex/DVMedicalSummaryAttachment_VF?id=' + recId + '&saved=true');
		redirect.setRedirect(true);
		return redirect;
	}

	/**
	 * @description Delete Lead File
	 * @return Page Reference
	 */
	public PageReference removeAttachment() {
		List<Id> leadFilesToDelete = new List<Id>();
		leadFilesToDelete.add(attachmentId);
		LeadFileService.deleteById(leadFilesToDelete);
		PageReference redirect = new PageReference('/apex/DVMedicalSummaryAttachment_VF?id=' + recId);
		redirect.setRedirect(true);
		return redirect;
	}

	/**
	 * Finds the current Medical Professional who the DV was sent to
	 * @return Contact Id
	*/
	private static Id findDiagnosisVerificationMedicalProfessional(Id leadId) {
		Id medicalProfessionalFileOwner = null;
		Lead lead = [
				SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c,
						Best_Contact__c, Alt_1_MP__c, Alt_2_MP__c
				FROM Lead
				WHERE Id = :leadId
		];
		if (lead.Hidden_DV_form_Medical_professional_Type__c.equals(Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL)
				&& lead.Referring_MP__c != null) {
			medicalProfessionalFileOwner = lead.Referring_MP__c;
		} else if (lead.Hidden_DV_form_Medical_professional_Type__c.equals(Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL)
				&& lead.Treating_MP__c != null) {
			medicalProfessionalFileOwner = lead.Treating_MP__c;
		} else if (lead.Hidden_DV_form_Medical_professional_Type__c.equals(Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT)
				&& lead.Best_Contact__c != null) {
			medicalProfessionalFileOwner = lead.Best_Contact__c;
		} else if (lead.Hidden_DV_form_Medical_professional_Type__c.equals(Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL)
				&& lead.Alt_1_MP__c != null) {
			medicalProfessionalFileOwner = lead.Alt_1_MP__c;
		} else if (lead.Hidden_DV_form_Medical_professional_Type__c.equals(Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL)
				&& lead.Alt_2_MP__c != null) {
			medicalProfessionalFileOwner = lead.Alt_2_MP__c;
		}
		return medicalProfessionalFileOwner;
	}
}