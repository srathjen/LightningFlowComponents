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

	/**
	 * Create Envelope
	 * @param document
	 * @param email
	 * @param fistName
	 * @param lastName
	 * @return
	 */
	public static HttpResponse createEnvelope(String document, String email, String fistName, String lastName) {
		String account;
		String IntegratorKey;
		Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
		for (DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
			account = credentialIns.account__c;
			IntegratorKey = credentialIns.IntegratorKey__c;
		}
		String authorizationHeader =
				'<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>'
				+ IntegratorKey + '</IntegratorKey></DocuSignCredentials>';
		String boundary = 'AAA';
		String body = '{' +
				'  "status":"sent",' +
				'  "enableWetSign": "false",' +
				'  "emailBlurb":"Volunteer Application Form",' +
				'  "emailSubject": "Volunteer Application Form",' +
				'  "enforceSignerVisibility":"True",' +
				'  "documents": [{' +
				'      "name": "document.pdf",' +
				'      "documentId":"1",' +
				'      "order":"1",' +
				'      "documentBase64":"' + document + '"' +
				'  }],' +
				'"recipients": {' +
				'    "signers" : [{' +
				'      "email": "' + email + '",' +
				'      "name": "' + fistName + ' ' + lastName + '",' +
				'      "recipientId":"1",' +
				'      "clientUserId":"1",' +
				'      "tabs": {' +
				'                "signHereTabs": [{' +
				'                    "anchorString": "~s1",' +
				'                    "anchorXOffset": "0.1",' +
				'                    "anchorYOffset": "0.1",' +
				'                    "anchorIgnoreIfNotPresent": "false",' +
				'                    "anchorUnits": "inches"' +
				'                }],' +
				'                "dateSignedTabs": [{' +
				'                      "anchorString": "~date",' +
				'                       "anchorXOffset": "0",' +
				'                       "fontSize":      "Size14",' +
				'                       "fontColor":     "Black",' +
				'                       "fonttype":     "Helvetica",' +
				'                        "anchorYOffset": "0",' +
				'                        "anchorIgnoreIfNotPresent": "false",' +
				'                        "xPosition": "100",' +
				'                        "yPosition": "72",' +
				'                        "anchorUnits": "inches"' +
				'                    }]' +
				'            }' +
				'    }]' +
				'  }' +
				'}';

		String header = '--' + boundary + '\nContent-Type: application/json\nContent-Disposition: form-data';
		String jsonBody = header + '\n\n' + body + '\n\n--' + boundary + '--';
		// Callout to Docusign.
		HttpRequest req = new HttpRequest();
		req.setHeader('X-DocuSign-Authentication', authorizationHeader);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Host', 'demo.docusign.net');
		req.setHeader('Content-Length', '162100');
		req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
		req.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes');
		req.setMethod('POST');
		req.setBody(jsonBody);
		Http http = new Http();
		HttpResponse res;
		res = http.send(req);
		return res;
	}

	/**
	 * DocuSign Create Recipient View
	 * @param envelopeId
	 * @param email
	 * @param fistName
	 * @param lastName
	 * @param returnUrl
	 * @return HttpResponse
	 */
	public static HttpResponse createRecipient(String envelopeId, String email, String fistName, String lastName, String returnUrl) {
		String account;
		String IntegratorKey;
		Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
		for (DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
			account = credentialIns.account__c;
			IntegratorKey = credentialIns.IntegratorKey__c;
		}
		String authorizationHeader = '<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>'
				+ IntegratorKey + '</IntegratorKey></DocuSignCredentials>';
		HttpRequest request = new HttpRequest();
		request.setHeader('X-DocuSign-Authentication', authorizationHeader);
		request.setHeader('Accept', 'application/json');
		request.setHeader('Host', 'demo.docusign.net');
		request.setHeader('Content-Length', '162100');
		request.setHeader('Content-Type', 'application/json');
		request.setMethod('POST');
		Http httprequest = new Http();
		HttpResponse response;
		request.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes/' + envelopeId + '/views/recipient');
		String jsonPayload;
		jsonPayload = '{' +
				'    "userName": "' + fistName + ' ' + lastName + '",' +
				'    "email": "' + email + '",' +
				'    "recipientId": "1",' +
				'    "clientUserId": "1",' +
				'    "authenticationMethod": "None",' +
				'    "returnUrl": "' + returnUrl + '"' +
				'}';
		request.setBody(jsonPayload);
		response = httprequest.send(request);
		return response;
	}
}
