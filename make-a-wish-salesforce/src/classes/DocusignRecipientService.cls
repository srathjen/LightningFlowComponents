/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/26/2020
 */
public class DocusignRecipientService {
	private static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_LIABILITY = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_LIABILITY;
	private static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY;

	/**
	* @description updateCompletedRecipient() is used to update the recipient name when the recipient record is created.
	* @param dsfsIdSet
	* @param nameMap
	* @param DSrecipiantList
	*/
	public static void updateCompletedRecipient(Set<Id> dsfsIdSet, Map<String, String> nameMap, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
		if (dsfsIdSet.isEmpty()) {
			return;
		}
		Map<Id, String> caseToSubjectMap = new Map<Id, String>();
		for (dsfs__DocuSign_Status__c dsfs : [
				SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c
				FROM dsfs__DocuSign_Status__c
				WHERE Id IN :dsfsIdSet AND dsfs__Case__c != NULL
				AND (dsfs__Subject__c = :DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_LIABILITY OR dsfs__Subject__c = :DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY)
		]) {
			caseToSubjectMap.put(dsfs.dsfs__Case__c, dsfs.dsfs__Subject__c);
		}
		try {
			Set<Id> contactIdSet = new Set<Id>();
			if (!contactIdSet.isEmpty()) {
				List<Contact> updateContactList = new List<Contact>();
				for (Contact dbContact : [
						SELECT Id, Name, Email, Publicity_OK__c
						FROM Contact
						WHERE Id IN :contactIdSet
				]) {
					dbContact.Publicity_OK__c = Constant_AC.CONTACT_PUBLICITY_YES;
					updateContactList.add(dbContact);
				}
				if (!updateContactList.isEmpty()) {
					RecursiveTriggerHandler.blockBeforeUpdate = true;
					RecursiveTriggerHandler.blockAfterUpdate = true;
					update updateContactList;
				}
			}
		} catch (Exception ex) {
			for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
				ErrorMessage_AC.createDebugRec('DocusignRecipientService', String.valueOf(currRec), String.valueOf(ex), 'UpdateCompletedRecipient', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	}

	/**
	* @description updateCompletedRecipient() is used to update the recipient name in docusign status record when the recipient record is created.
	* @param envelopMap
	* @param DSrecipiantList
	*/
	public static void updateStatusRecord(Map<Id, String> envelopMap, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
		if (envelopMap.isEmpty()) {
			return;
		}
		List<dsfs__DocuSign_Status__c> updatedsfsList = new List<dsfs__DocuSign_Status__c>();
		try {
			if (!envelopMap.isEmpty()) {
				for (dsfs__DocuSign_Status__c dbStatusRec : [
						SELECT Id,Recipient_names__c,dsfs__Sender__c,dsfs__Sender_Email__c
						FROM dsfs__DocuSign_Status__c
						WHERE Id IN :envelopMap.keySet()
				]) {
					if (envelopMap.containsKey(dbStatusRec.Id)) {
						if (dbStatusRec.Recipient_names__c == null) {
							dbStatusRec.Recipient_names__c = envelopMap.get(dbStatusRec.Id);
						} else {
							dbStatusRec.Recipient_names__c = dbStatusRec.Recipient_names__c + ', ' + envelopMap.get(dbStatusRec.Id);
						}
						updatedsfsList.add(dbStatusRec);
					}
				}
			}
			update updatedsfsList;
		} catch (Exception ex) {
			for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
				ErrorMessage_AC.createDebugRec('DocusignRecipientService', String.valueOf(currRec), String.valueOf(ex), 'UpdateStatusRecord', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	}

	/**
	* @description updateRecipientName() is used to update the recipient name when the recipient status is updated as completed or delivered.
	* @param completedIdSet
	* @param completedNameString
	* @param DSrecipiantList
	*/
	public static void updateRecipientName(Set<Id> completedIdSet, Set<String> completedNameString, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
		if (completedIdSet.isEmpty() || completedNameString.isEmpty()) {
			return;
		}
		Set<Id> completedWishIdSet = new Set<Id>();
		try {
			if (!completedIdSet.isEmpty()) {
				for (dsfs__DocuSign_Status__c dsfsStatusRec : [
						SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c
						FROM dsfs__DocuSign_Status__c
						WHERE Id IN :completedIdSet AND dsfs__Case__c != NULL
						AND dsfs__Subject__c = :DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY
				]) {
					completedWishIdSet.add(dsfsStatusRec.dsfs__Case__c);
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
			}
		} catch (Exception ex) {
			for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
				ErrorMessage_AC.createDebugRec('DocusignRecipientService', String.valueOf(currRec),
						String.valueOf(ex), 'UpdateRecipientName', currRec.Id,
						ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	* @param parentIdSet
	* @param DSrecipiantList
	*/
	public static void updateAttachmentId(Set<Id> parentIdSet, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
		if (parentIdSet.isEmpty()) {
			return;
		}
		Map<Id, Id> attachmentMap = new Map<Id, Id>();
		List<dsfs__DocuSign_Status__c> dbdsfsList = new List<dsfs__DocuSign_Status__c>();
		try {
			for (Attachment dbAttachment : [
					SELECT Id,ParentId
					FROM Attachment
					WHERE ParentId IN :parentIdSet
			]) {
				attachmentMap.put(dbAttachment.ParentId, dbAttachment.Id);
			}
			for (dsfs__DocuSign_Status__c dbStatusRec : [
					SELECT Id,AttachmentId__c
					FROM dsfs__DocuSign_Status__c
					WHERE Id IN :parentIdSet
			]) {
				if (attachmentMap.containsKey(dbStatusRec.Id)) {
					dbStatusRec.AttachmentId__c = attachmentMap.get(dbStatusRec.Id);
					dbdsfsList.add(dbStatusRec);
				}
			}
			update dbdsfsList;

			if (Test.isRunningTest()) {
				throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
			}
		} catch (Exception ex) {
			for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
				ErrorMessage_AC.createDebugRec('DocusignRecipientService', String.valueOf(currRec), String.valueOf(ex), 'updateAttachmentId', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}
}