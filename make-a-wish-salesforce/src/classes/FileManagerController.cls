/**
* @description File Manager Controller
* @author Gustavo Mayer, Traction on Demand
* @createdDate 17/Feb/2021
*/
public with sharing class FileManagerController {

	/**
	 * Finds files
	 * @param parentId SObject record id
	 * @return List of Files
	*/
	@AuraEnabled
	public static List<FileWrapper> findFiles(Id parentId) {
		List<FileWrapper> files = new List<FileWrapper>();
		Schema.SObjectType entityType = parentId.getSobjectType();
		if ('Lead'.equals(entityType.getDescribe().name)) {
			Id diagnosisVerificationMedicalProfessional = findDiagnosisVerificationMedicalProfessional(parentId);
			List<cg__Lead_File__c> leadFiles = [
					SELECT Id, cg__Lead__c, File_Path__c, cg__Description__c, cg__File_Name__c,
							cg__Lead__r.Hidden_DV_form_Medical_professional_Type__c, cg__Lead__r.Referring_MP__c,
							cg__Lead__r.Treating_MP__c, cg__Lead__r.Best_Contact__c, cg__Lead__r.Alt_1_MP__c, cg__Lead__r.Alt_2_MP__c
					FROM cg__Lead_File__c
					WHERE cg__Lead__c = :parentId
					AND cg__Description__c = :diagnosisVerificationMedicalProfessional
					ORDER BY cg__File_Name__c
			];
			for (cg__Lead_File__c leadFile : leadFiles) {
				FileWrapper file = new FileWrapper();
				file.fileId = leadFile.Id;
				file.parentId = leadFile.cg__Lead__c;
				file.fileName = leadFile.cg__File_Name__c;
				files.add(file);
			}
		}
		return files;
	}

	/**
	 * Upload File
	 * @param file File Wrapper
	 * @return True or False
	*/
	@AuraEnabled
	public static Boolean uploadFile(FileWrapper file) {
		Attachment attachment = new Attachment();
		try {
			Id diagnosisVerificationMedicalProfessional = findDiagnosisVerificationMedicalProfessional(file.parentId);
			String base64DataDecoded = EncodingUtil.urlDecode(file.base64Data, 'UTF-8');
			attachment.ParentId = file.parentId;
			attachment.Body = EncodingUtil.base64Decode(base64DataDecoded);
			attachment.Name = file.fileName;
			attachment.ContentType = 'image/png';
			attachment.Description = diagnosisVerificationMedicalProfessional;
			insert attachment;
			return true;
		} catch (Exception e) {
			System.debug('Error While Saving File: ' + e);
			return false;
		}
	}

	/**
	 * Delete File
	 * @param fileId file id
	 * @return True or False
	*/
	@AuraEnabled
	public static Boolean deleteFile(Id fileId) {
		Schema.SObjectType entityType = fileId.getSobjectType();
		if ('cg__Lead_File__c'.equals(entityType.getDescribe().name)) {
			Map<Id, Database.DeleteResult> resultMap = LeadFileService.deleteById(new List<Id>{
					fileId
			});
			Database.DeleteResult deleteResult = resultMap.get(fileId);
			return deleteResult.success;
		}
		return false;
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

	public class FileWrapper {
		@AuraEnabled
		public String fileId { get; set; }
		@AuraEnabled
		public String parentId { get; set; }
		@AuraEnabled
		public String fileName { get; set; }
		@AuraEnabled
		public String base64Data { get; set; }
		@AuraEnabled
		public String contentType { get; set; }
	}
}