/**
 * @description DocuSign Service, centralizes DocuSign business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class DocuSignService {

	/**
	 * Find DocuSign Status by Lead Ids and Envelope Status
	 * @param leadId
	 */
	public static List<dsfs__DocuSign_Status__c> findByLeadAndEnvelopeStatus(Set<Id> leadIds, String status) {
		return [
				SELECT Id, dsfs__Lead__c, dsfs__Envelope_Status__c, dsfs__Completed_Date_Time__c
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c IN:leadIds
				AND dsfs__Envelope_Status__c = :status
		];
	}

	/**
	 * Set Contacts on DocuSign Status by Converted Lead Ids
	 * @param leadId
	 */
	public static List<dsfs__DocuSign_Status__c> setContact(List<dsfs__DocuSign_Status__c> docuSignStatuses, Map<Id, Lead> leadMap) {
		List<dsfs__DocuSign_Status__c> updateDocusignStatuses = new List<dsfs__DocuSign_Status__c>();
		for (dsfs__DocuSign_Status__c docuSignStatus : docuSignStatuses) {
			if (leadMap.containsKey(docuSignStatus.dsfs__Lead__c)) {
				docuSignStatus.dsfs__Contact__c = leadMap.get(docuSignStatus.dsfs__Lead__c).ConvertedContactId;
				updateDocusignStatuses.add(docuSignStatus);
			}
		}
		return updateDocusignStatuses;
	}

	/**
	 * Delete DocuSign Status and Attachments found by Lead Id
	 * @param leadId
	 */
	public static void deleteByLeadIdAndDeleteRelatedAttachments(Id leadId) {
		Map<Id, dsfs__DocuSign_Status__c> docuSignMap = new Map<Id, dsfs__DocuSign_Status__c>();
		for (dsfs__DocuSign_Status__c docuSign : [
				SELECT Id, dsfs__Lead__c
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c = :leadId
		]) {
			docuSignMap.put(docuSign.Id, docuSign);
		}
		delete [
				SELECT Id
				FROM Attachment
				WHERE ParentId IN :docuSignMap.keySet()
		];
		delete docuSignMap.values();
	}

	/**
	 * Update the electronic signer in lead related docusign status record.
	 * @param leadContactMap
	 */
	public static void updateElectronicSigner(Map<Id, Id> leadContactMap, String subject) {
		List<dsfs__DocuSign_Status__c> docusignStatusList = new List<dsfs__DocuSign_Status__c>();
		try {
			for (dsfs__DocuSign_Status__c docusignStatus : [
					SELECT Id, dsfs__Lead__c, dsfs__Envelope_Status__c, dsfs__Contact__c
					FROM dsfs__DocuSign_Status__c
					WHERE dsfs__Lead__c IN :leadContactMap.keySet()
					AND dsfs__Subject__c = :subject
			]) {
				if (docusignStatus.dsfs__Contact__c == null) {
					docusignStatus.dsfs__Contact__c = leadContactMap.get(docusignStatus.dsfs__Lead__c);
					docusignStatusList.add(docusignStatus);
				}
			}
			if (!docusignStatusList.isEmpty()) {
				RecursiveTriggerHandler.blockBeforeUpdate = true;
				RecursiveTriggerHandler.blockAfterUpdate = true;
				update docusignStatusList;
			}
		} catch (Exception ex) {
			for (Lead currRec : [
					SELECT Id, LastName
					FROM Lead
					WHERE Id IN:leadContactMap.keySet()
			]) {
				ErrorMessage_AC.createdebugRec('DocuSignService',
						String.valueOf(currRec), String.valueOf(ex), 'updateElectronicSigner',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : [
						SELECT Id, LastName
						FROM Lead
						WHERE Id IN:leadContactMap.keySet()
				]) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}
}