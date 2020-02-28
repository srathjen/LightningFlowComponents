/*****************************************************************************************************************
Author      : MST Solutions
Date        : 01/19/2017
Description : This form is used as IFrame inside the  Diagnosis Verification form to upload medical summary attachment

Modification Log:
09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/
public class DVMedicalSummaryAttachment_AC {

	public Id attachmentId { get; set; }
	public Attachment newAttachment { get; set; }
	public Id recId;
	public Boolean isSaved { get; set; }
	public Boolean isDeleted { get; set; }

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
	}

	/**
	 * Display medical summary attachment to diagnosis verification form
	 * @return Lead Files
	 */
	public List<cg__Lead_File__c> getAttachments() {
		List<cg__Lead_File__c> attachmentList = [
                SELECT Id, cg__Lead__c, File_Path__c, cg__Description__c, cg__File_Name__c
				FROM cg__Lead_File__c
				WHERE cg__Lead__c = :recId
		];
		return attachmentList;
	}

	/**
	 * Save new attachment from diagnosis verification form
	 * @return Page Reference
	 */
	public PageReference save() {
		if (newAttachment.Body != null) {
			newAttachment.ParentId = recId;
			insert newAttachment;
			newAttachment = new Attachment();
		}
		PageReference redirect = new PageReference('/apex/DVMedicalSummaryAttachment_VF?id=' + recId + '&saved=true');
		redirect.setRedirect(true);
		return redirect;
	}

	/**
	 * Used to refresh the block
	 */
	public void Refresh() {
	}

	/**
	 * Delete Lead File
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
}