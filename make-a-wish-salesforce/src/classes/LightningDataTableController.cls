/**
* @Description Apex Controller to handle various functionalities of LightningDatatable component
* @author Mitali Nahar, Traction on Demand
* @createdDate 2019-06-16
 */
public with sharing class LightningDataTableController {

	/**
	 * Find records based on parameters
	 * @param strObjectName
	 * @param strFieldSetName
	 * @param strTypeOfSignature
	 * @param caseRecordId
	 * @param showVoid
	 * @return DataTableResponse
	 */
	@AuraEnabled
	public static DataTableResponse getRecords(String strObjectName, String strFieldSetName, String strTypeOfSignature, Id caseRecordId, String showVoid) {
		//Get the fields from FieldSet
		Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(strObjectName);
		Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
		Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
		//To hold the table hearders
		List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
		//Field to be queried - fetched from fieldset
		List<String> lstFieldsToQuery = new List<String>();
		//The final wrapper response to return to component
		DataTableResponse response = new DataTableResponse();
		for (Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields()) {
			String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
			//This way we can set the type of a column
			//We do not get the exact type from schema object which matches to lightning:datatable component structure
			if (dataType == 'datetime') {
				dataType = 'date';
			}
			//Create a wrapper instance and store label, fieldname and type.
			DataTableColumns datacolumns = new DataTableColumns(String.valueOf(eachFieldSetMember.getLabel()),
					String.valueOf(eachFieldSetMember.getFieldPath()),
					String.valueOf(eachFieldSetMember.getType()).toLowerCase());
			lstDataColumns.add(datacolumns);
			lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
		}
		//Need to check for other columns as per fieldset for going more than one Level up to get fields
		lstFieldsToQuery.add('Wish_Affiliation__r.Contact__r.Name');
		lstFieldsToQuery.add('Wish_Affiliation__r.Contact__r.Email');
		//Form an SOQL to fetch the data - Set the wrapper instance and return as response
		if (!lstDataColumns.isEmpty()) {
			response.lstDataTableColumns = lstDataColumns;
			String query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') ;
			if (!strTypeOfSignature.equals('Medical')) {
				query += ', (SELECT Id,Signing_on_Behalf_Of__r.Contact__r.Name FROM Guardian_Signatures__r) ';
			}
			query += ' FROM ' + strObjectName;
			String medical = 'Medical';
			if (strTypeOfSignature.equals('Medical')) {
				query += ' WHERE Type__c =: ' + String.escapeSingleQuotes(medical) + ' AND Wish_Case__c =: caseRecordId';
			} else {
				query += ' WHERE Type__c !=:' + String.escapeSingleQuotes(medical) + ' AND Wish_Case__c =: caseRecordId';
			}
			if (showVoid == 'false') {
				String voided = 'Voided';
				query += ' AND Status__c !=:' + String.escapeSingleQuotes(voided);
			}
			response.lstDataTableData = Database.query(query);
		}
		return response;
	}

	/**
	 * Delete Wish Required Signature
	 * @param wrsId
	 */
	@AuraEnabled
	public static void deleteWishRequiredSigns(Id wrsId) {
		try {
			if (wrsId != null) {
				delete new Wish_Required_Signature__c(Id = wrsId);
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Update Wish Required Signature with assigned Wish Required Form
	 * @param wrsId
	 * @param formId
	 */
	@AuraEnabled
	public static void updateFormOnWRS(Id wrsId, Id formId) {
		try {
			if (wrsId != null && formId != null) {
				Wish_Required_Signature__c wrs = new Wish_Required_Signature__c(Id = wrsId, Wish_Signature_Form__c = formId);
				update wrs;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Update Wish Required Signature with assigned Wish Affiliation
	 * @param wrsId
	 * @param conId
	 * @param caseId
	 */
	@AuraEnabled
	public static void updateSignerOnWRS(Id wrsId, Id conId, Id caseId) {
		try {
			Wish_Affiliation__c wishAff = [
					SELECT Id
					FROM Wish_Affiliation__c
					WHERE Contact__c = :conId AND Wish__c = :caseId
			];

			if (wrsId != null && wishAff != null) {
				Wish_Required_Signature__c wrs = new Wish_Required_Signature__c(Id = wrsId, Wish_Affiliation__c = wishAff.Id);
				update wrs;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Find Wish Affiliation of a Contact on Case
	 * @param conId
	 * @param caseId
	 * @return Wish Affiliation
	 */
	@AuraEnabled
	public static Wish_Affiliation__c getWishAffRecord(Id conId, Id caseId) {
		try {
			return [
					SELECT Id,Wish_Affiliation_Type__c,Relationship_Type__c,Relationship__r.npe4__Contact__r.FirstName,
							Relationship__r.npe4__Contact__r.LastName, Parent_Legal_Guardian__c,
							Send_Clearance_Forms_To__c,Best_Medical_Contact__c
					FROM Wish_Affiliation__c
					WHERE Contact__c = :conId AND Wish__c = :caseId
					LIMIT 1
			];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Find Case details from Case Id
	 * @param caseId
	 * @return Case
	 */
	@AuraEnabled
	public static Case getWish(Id caseId) {
		try {
			if (caseId != null) {
				return [
						SELECT Wish_Clearance_Needed__c
						FROM Case
						WHERE Id = :caseId
				];
			}
			return null;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}

	}

	/**
	 * Find Wish Signature Form details on a Wish Required Signature
	 * @param wishSignId
	 * @return Wish Signature Form
	 */
	@AuraEnabled
	public static Wish_Signature_Forms__c getDocGen(String wishSignId) {
		Wish_Signature_Forms__c wishForm = [
				SELECT Id, DocGen_Package_ID__c, Delivery_Option_ID_Print__c, Delivery_Option_ID_eSign__c
				FROM Wish_Signature_Forms__c
				WHERE Id IN (
						SELECT Wish_Signature_Form__c
						FROM Wish_Required_Signature__c
						WHERE Id = :wishSignId
				)
				LIMIT 1
		];
		if (wishForm == null || wishForm.DocGen_Package_ID__c == null || wishForm.Delivery_Option_ID_eSign__c == null || wishForm.Delivery_Option_ID_Print__c == null) {
			throw new AuraHandledException('No Package or Delivery Option Available!');
		}
		return wishForm;
	}

	/**
	 * Hold metadata to support UI
	 * @return Metadata Wrapper
	 */
	@AuraEnabled
	public static MetadataWrapper getMetadata() {
		MetadataWrapper metadataWrapper = new MetadataWrapper();
		metadataWrapper.medicalProfessionalId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		return metadataWrapper;
	}

	/**
	 * Update Docusign, building Docusign external request call
	 * @param action
	 * @param resendToEmail
	 * @param wrsId
	 * @param voidReason
	 * @param selectedCon
	 * @param reassignToEmail
	 * @param wishAffList
	 * @return DocusignResponse
	 */
	@AuraEnabled
	public static DocusignResponse updateEnvelopeDocusign(String action, String resendToEmail, Id wrsId, String voidReason, SObject selectedCon, String reassignToEmail, String wishAffList) {
		try {
			String endpoint = '';
			String json = '';
			String envelopeId = '';
			if (wrsId != null) {
				for (dsfs__DocuSign_Status__c docEnvelope : [
						SELECT Id, dsfs__DocuSign_Envelope_ID__c
						FROM dsfs__DocuSign_Status__c
						WHERE Wish_Required_Signature__c = :wrsId
						ORDER BY dsfs__Sent_Date_Time__c DESC
						LIMIT 1
				]) {
					if (docEnvelope.dsfs__DocuSign_Envelope_ID__c != null) {
						envelopeId = docEnvelope.dsfs__DocuSign_Envelope_ID__c;
					}
				}
			}
			//Build Endpoint and JSON Request Body for Callout to Docusign
			if (action.equals('Resend')) {
				endpoint = '/recipients?resend_envelope=true';
				json = '{' +
						' ' +
						' "signers":[' +
						' {' +
						' "recipientId": "1",' +
						' "email": "' + resendToEmail + '",' +
						'      }' +
						'    ]' +
						'  }';
			} else if (action.equals('Void')) {
				json = '{' +
						' ' +
						' "status": "voided",' +
						' "voidedReason":  "' + voidReason + '",' +
						'}';

			} else if (action.equals('Reassign')) {
				endpoint = '/recipients?resend_envelope=true';
				json = '{' +
						' ' +
						' "signers":[' +
						' {' +
						' "recipientId": "1",' +
						' "name":  "' + selectedCon.get('Name') + '",' +
						' "email": "' + reassignToEmail + '",' +
						'      }' +
						'    ]' +
						'  }';
				//updateWishSignatureForReassign(wrsId,'E-Signature',reassignToEmail);
			}
			return calloutToDocusign(json, endpoint, envelopeId, action, wrsId, 'E-Signature', reassignToEmail, wishAffList);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Asynchronously update Wish Required Signature
	 * @param wrsId
	 * @param format
	 * @param emailId
	 * @param wishAffList
	 */
	@Future
	public static void updateWishSignatureForReassign(Id wrsId, String format, String emailId, String wishAffList) {
		if (String.isNotBlank(wishAffList)) {
			List<Wish_Affiliation__c> listAff = (List<Wish_Affiliation__c>) JSON.deserialize(wishAffList, List<Wish_Affiliation__c>.class);
			if (listAff != null && !listAff.isEmpty()) {
				Wish_Required_Signature__c updateWRS = new Wish_Required_Signature__c(
						Id = wrsId, Status__c = 'Sent', Format__c = format, Sent_Date__c = System.today(),
						Sent_to_Email_Address__c = emailId, Wish_Affiliation__c = listAff[0].Id);
				update updateWRS;
			}
		}
	}

	/**
	 * Update Wish Required Signature
	 * @param wrsId
	 * @param format
	 * @param emailId
	 */
	@AuraEnabled
	public static void updateWishSignature(Id wrsId, String format, String emailId) {
		try {
			Wish_Required_Signature__c updateWRS = new Wish_Required_Signature__c(Id = wrsId);
			if (format == 'E-Signature') {
				updateWRS.Sent_to_Email_Address__c = emailId;
				updateWRS.Status__c = 'Not Sent - Pending';
			}
			if (format == 'Paper') {
				updateWRS.Status__c = 'Sent';
				updateWRS.Sent_Date__c = System.today();
				updateWRS.Format__c = format;
			}
			update updateWRS;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Send Docusign update request
	 * @param body
	 * @param endpoint
	 * @param docEnvelopeId
	 * @param action
	 * @param wrsId
	 * @param format
	 * @param emailId
	 * @param wishAffList
	 * @return DocusignResponse
	 */
	private static DocusignResponse calloutToDocusign(String body, String endpoint, String docEnvelopeId, String action, Id wrsId, String format, String emailId, String wishAffList) {
		DocusignResponse dsResponse = new DocusignResponse();
		Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
		String account;
		String IntegratorKey;
		String envelopeId;
		for (DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
			account = credentialIns.account__c;
			IntegratorKey = credentialIns.IntegratorKey__c;
		}
		envelopeId = docEnvelopeId;
		//Create Authorization Headers
		String authorizationHeader = '<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>' + IntegratorKey + '</IntegratorKey></DocuSignCredentials>';
		HttpRequest req = new HttpRequest();
		String setEndpoint = 'Callout:Docusign_Credential/accounts/' + account + '/envelopes/' + envelopeId + '';
		setEndpoint += String.isNotBlank(endpoint) ? endpoint : '' ;
		req.setEndpoint(setEndpoint);
		req.setMethod('PUT');
		req.setTimeout(120000);
		req.setHeader('X-DocuSign-Authentication', authorizationHeader);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Length', '162100');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Content-Disposition', 'form-data');
		req.setBody(body);
		Http http = new Http();
		HttpResponse res;
		try {
			res = http.send(req);
			JSONParser parser = JSON.createParser(res.getBody());
			System.JSONToken token;
			String text;
			while ((token = parser.nextToken()) != null) {
				// Parse the object
				if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) {
					text = parser.getText();
					if (token == JSONToken.FIELD_NAME && text == 'message') {
						token = parser.nextToken();
						dsResponse.errorMessage = parser.getText();
					}
				} else {
					token = parser.nextToken();
					if (token == JSONToken.END_ARRAY) {
						break;
					}
				}
			}
			//Prepare return message as per response received
			if (res.getStatusCode() == 200) {
				if (action.equals('Resend')) {
					dsResponse.successMessage = 'The Docusign Envelope was resent successfully' ;
				} else if (action.equals('Reassign')) {
					dsResponse.successMessage = 'The Docusign Envelope was reassigned successfully' ;
					updateWishSignatureForReassign(wrsId, 'E-Signature', emailId, wishAffList);
				} else if (action.equals('Void')) {
					dsResponse.successMessage = 'The Docusign Envelope was voided successfully' ;
				}
			} else {
				if (String.isBlank(dsResponse.errorMessage)) {
					dsResponse.errorMessage = 'There was a problem is updating the Docusign Envelope' ;
				}
			}
			return dsResponse;
		} catch (Exception e) {
			dsResponse.errorMessage = e.getMessage();
			return dsResponse;
		}
	}

	/**
	 * Find Wish Required Signature File Path
	 * @param wrsId
	 * @return Wish Required Signature File
	 */
	@AuraEnabled
	public static Wish_Required_Signature_File__c getWishFilePath(Id wrsId) {
		system.debug('wrsId-->' + wrsId);
		try {
			if (wrsId != null) {
				Wish_Required_Signature_File__c objFile = new Wish_Required_Signature_File__c();
				for (Wish_Required_Signature_File__c wishFile : [
						SELECT Id, File_Path__c
						FROM Wish_Required_Signature_File__c
						WHERE Wish_Required_Signature__c = :wrsId
						ORDER BY CreatedDate DESC
				]) {
					if (wishFile.File_Path__c != null) {
						objFile = wishFile;
						break;
					}
				}
				return objFile;
			}
			return null;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//Wrapper class to hold Success and Errors
	public class DocusignResponse {
		@AuraEnabled
		public String successMessage { get; set; }
		@AuraEnabled
		public String errorMessage { get; set; }

		public DocusignResponse() {
		}
	}

	//Wrapper class to hold Columns with headers
	public class DataTableColumns {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String fieldName { get; set; }
		@AuraEnabled
		public String type { get; set; }

		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableColumns(String label, String fieldName, String type) {
			this.label = label;
			this.fieldName = fieldName;
			this.type = type;
		}
	}

	//Wrapper class to hold response - This response is used in the lightning:datatable component
	public class DataTableResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns { get; set; }
		@AuraEnabled
		public List<sObject> lstDataTableData { get; set; }

		public DataTableResponse() {
			lstDataTableColumns = new List<DataTableColumns>();
			lstDataTableData = new List<sObject>();
		}
	}

	// Wrapper class for holding metadata
	public class MetadataWrapper {
		@AuraEnabled
		public String medicalProfessionalId { get; set; }
	}
}