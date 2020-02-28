/**
 * @description DocuSign Service, centralizes DocuSign business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class DocuSignService {

	/**
	 * Delete DocuSign Status and Attachments found by Lead Id
	 * @param leadId
	 */
	public static void deleteByLeadIdAndDeleteRelatedAttachments(Id leadId){
		Map<Id, dsfs__DocuSign_Status__c> docuSignMap = new Map<Id, dsfs__DocuSign_Status__c>();
		for (dsfs__DocuSign_Status__c docuSign : [
				SELECT Id, dsfs__Lead__c
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c = :leadId
		]) {
			docuSignMap.put(docuSign.Id, docuSign);
		}
		List<Attachment> attachments = new List<Attachment>();
		for (Attachment attachment : [
				SELECT Id
				FROM Attachment
				WHERE ParentId IN :docuSignMap.keySet()
		]) {
			attachments.add(attachment);
		}
		if (!attachments.isEmpty()) {
			delete attachments;
		}
		if (!docuSignMap.values().isEmpty()) {
			delete docuSignMap.values();
		}
	}
}