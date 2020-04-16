/* 
* @description 		Apex Controller to handle various functionalities of FileUpload component
* @author 			Mitali Nahar, Traction on Demand
* @date 			2019-06-26
*/
public with sharing class FileUploadController {

	/**
     * @description     Update Wish Sign record and save a file.
     *
     * @param           Id parentId
     * @param           String fileName
     * @param           String base64Data
     * @param           String contentType
     * @param           SObject wishSignRecord
     *
     * @return          Id
     *
     * @author          Mitali Nahar, Traction on Demand
     * @createdDate     2019-06-26
     */
	@AuraEnabled
	public static Id updateWRSAndSaveFile(Id parentId, String fileName, String base64Data, String contentType, SObject wishSignRecord) {
		try {
			if (wishSignRecord != null) {
				update wishSignRecord;

				parentId = wishSignRecord.Id;
				base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
				Attachment attach = new Attachment();
				attach.ParentId = parentId;
				attach.Body = EncodingUtil.base64Decode(base64Data);
				attach.Name = fileName;
				attach.ContentType = contentType;

				insert attach;

				return attach.Id;
			}

			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

			ContentVersion contentVersion = new ContentVersion();
			contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
			contentVersion.PathOnClient = fileName;
			contentVersion.Title = fileName;
			contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);

			insert contentVersion;

			List<ContentVersion> documents = [
				SELECT Id, ContentDocumentId
				FROM ContentVersion
				WHERE Id = :contentVersion.Id
				LIMIT 1
			];

			ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
			contentDocumentLink.ContentDocumentId = documents[0].ContentDocumentId;
			contentDocumentLink.LinkedEntityId = parentId;
			contentDocumentLink.ShareType = 'V'; // Viewer permission
			contentDocumentLink.Visibility = 'AllUsers';

			insert contentDocumentLink;

			return documents[0].ContentDocumentId;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}