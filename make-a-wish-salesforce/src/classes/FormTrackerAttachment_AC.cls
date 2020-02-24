public class FormTrackerAttachment_AC {

	/**
	 * [attachmentLists description]
	 * @param  currentPageId [description]
	 * @return               [description]
	 */

	@AuraEnabled
	public static List<Minor_Participant__c> attachmentLists(Id currentPageId) {
		Id formTrackerAttachMentRecordTypeId = Constant_AC.FORM_TRACKER_ATTACHMENT_ID;
		List<Minor_Participant__c > attachmentList = new List<Minor_Participant__c >();
		for (Minor_Participant__c dbMinorParticipant : [
				select Id,File_Path__c,AttachmentId__c,Case__c,RecordTypeId
				from Minor_Participant__c
				where RecordTypeId = :formTrackerAttachMentRecordTypeId AND
				Case__c = :currentPageId
				ORDER BY CreatedDate DESC
				LIMIT 1
		]) {

			attachmentList.add(dbMinorParticipant);
		}

		return attachmentList;
	}

	@AuraEnabled
	public static String syncFileAttachment(Id currentPageId) {
		Id formTrackerAttachMentRecordTypeId = Constant_AC.FORM_TRACKER_ATTACHMENT_ID;
		String result = '';
		List<cg__CaseFile__c> attachmentList = new List<cg__CaseFile__c>();
		Minor_Participant__c minorPartipant = [
				select AttachmentId__c,Case__c,Id,RecordTypeId
				from Minor_Participant__c
				where RecordTypeId = :formTrackerAttachMentRecordTypeId
				AND Case__c = :currentPageId
				ORDER BY CreatedDate DESC
				LIMIT 1
		];

		attachmentList = [
				select Id, File_Path__c, cg__File_Name__c
				from cg__CaseFile__c
				where cg__Case__c = :currentPageId AND cg__File_Name__c = :minorPartipant.AttachmentId__c AND cg__Parent_Folder_Id__c != Null
				ORDER BY CreatedDate DESC
				LIMIT 1
		];

		if (attachmentList.size() > 0) {
			Minor_Participant__c minor_p = new Minor_Participant__c(Id = minorPartipant.Id, Case__c = currentPageId, RecordTypeId = formTrackerAttachMentRecordTypeId,
					AttachmentId__c = attachmentList[0].cg__File_Name__c);
			minor_p.File_Path__c = attachmentList[0].File_Path__c;
			update minor_p;
			result = (minor_p.File_Path__c != '') ? 'success' : 'error';
		}
		return result;
	}

	/**
	 * [saveFileAttachment description]
	 * @param  config [description]
	 * @return        [description]
	 */

	@AuraEnabled
	public static Id saveFileAttachment(String config) {
		Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(config);
		Id formTrackerAttachMentRecordTypeId = Constant_AC.FORM_TRACKER_ATTACHMENT_ID;
		Id currentPageId = (Id) meta.get('recordId');
		String pageName = (String) meta.get('currentpageName');
		String participantName = (String) meta.get('MinorparticipantName');
		String participantEmail = (String) meta.get('MinorparticipantEmail');
		String FormName = (String) meta.get('FormName');
		String associatedParticipant = (String) meta.get('associated');
		String documentTitle = (String) meta.get('documentTitle');
		String format = (String) meta.get('selectedFormat');
		String fileId = (String) meta.get('fileId');
		Id parentId = (Id) meta.get('recordId');
		String fileName = (String) meta.get('fileName');
		String base64Data = (String) meta.get('base64Data');
		String contentType = (String) meta.get('contentType');

		String pageSrc = (String) meta.get('pageSrc');
		Id minorparticipantrecId;

		if (pageSrc == 'upload') {
			minorparticipantrecId = (Id) meta.get('minorparticipantrecId');
		}

		if (fileId == '') {
			fileId = saveTheFile(parentId, fileName, base64Data, contentType);
			if (pageName != Null && participantName != Null && participantEmail != Null && formName != Null && associatedParticipant != Null) {
				Minor_Participant__c newMinorRec = new Minor_Participant__c();
				if (pageSrc == 'upload') {
					newMinorRec.Id = minorparticipantrecId;
				}
				newMinorRec.SignedDate__c = System.today();
				newMinorRec.Name__c = participantName;
				newMinorRec.Associated_Childeren__c = associatedParticipant;
				newMinorRec.Case__c = currentPageId;
				newMinorRec.Email__c = participantEmail;
				newMinorRec.Case__c = currentPageId;
				newMinorRec.Form_Name__c = formName;
				newMinorRec.RecordTypeId = formTrackerAttachMentRecordTypeId;
				newMinorRec.AttachmentId__c = fileName;
				newMinorRec.SelectedFormat__c = format;
				newMinorRec.Attachment_Title__c = documentTitle;

				upsert newMinorRec;
			}

		} else {
			// appendToFile(fileId, base64Data);
		}

		return Id.valueOf(fileId);
	}

	/**
	 * [saveTheFile description]
	 * @param  parentId    [description]
	 * @param  fileName    [description]
	 * @param  base64Data  [description]
	 * @param  contentType [description]
	 * @return             [description]
	 */

	public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
		base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

		Attachment oAttachment = new Attachment();
		oAttachment.parentId = parentId;

		oAttachment.Body = EncodingUtil.base64Decode(base64Data);
		oAttachment.Name = fileName;
		oAttachment.ContentType = contentType;

		insert oAttachment;

		return oAttachment.Id;
	}

	/**
	 * [removeAttachment Used to delete the attachment from wish child form]
	 * @param  attachmentId  [description]
	 * @param  currentPageId [description]
	 * @return               [description]
	 */

	@AuraEnabled
	public static String removeAttachment(Id attachmentId, Id currentPageId) {
		Id formTrackerAttachMentRecordTypeId = Constant_AC.FORM_TRACKER_ATTACHMENT_ID;
		List<Minor_Participant__c> minorParticipantList = new List<Minor_Participant__c>();
		String result = '';
		string fileName;
		for (Minor_Participant__c attachmentToBeDeleted : [
				SELECT Id,AttachmentId__c,Case__c,SignedDate__c,RecordTypeId
				FROM Minor_Participant__c
				WHERE Id = :attachmentId AND Case__c = :currentPageId AND
				RecordTypeId = :formTrackerAttachMentRecordTypeId
		]) {
			fileName = attachmentToBeDeleted.AttachmentId__c;
			attachmentToBeDeleted.AttachmentId__c = null;
			attachmentToBeDeleted.SignedDate__c = null;
			attachmentToBeDeleted.File_Path__c = null;
			minorParticipantList.add(attachmentToBeDeleted);
		}

		List<cg__CaseFile__c> dbcaseFile = [
				SELECT Id,cg__File_Name__c,cg__Case__c
				FROM cg__CaseFile__c
				WHERE cg__File_Name__c = :fileName AND cg__Case__c = :currentPageId
		];
		if (minorParticipantList.size() > 0 && dbcaseFile.size() > 0) {
			try {
				update minorParticipantList;
				delete dbcaseFile;
				result = 'success';
			} Catch (Exception e) {
				String Logvalue = String.valueof(minorParticipantList[0]);
				new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC', 'removeAttachment', currentPageId, e, Logvalue));
				result = 'false';
			}
		}
		return result;
	}

}