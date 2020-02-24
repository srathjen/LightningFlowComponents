/*	CREATED: 		08-03-2019 
  	CREATED BY: 	SHANNON PADERES
	DESCRIPTION: 	AC for Wish Form Attachment component for use in the Wish Design Forms Flow Screen. Can be resused in ltngOut as well.  */
public with sharing class wishFormFileUpload_AC {

	@AuraEnabled
	public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, String description) {
		//  Check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
		//  which is save the check data and return the attachemnt Id after insert,
		//  next time (in else) we are call the appentTOFile() method
		//  for update the attachment with reamins chunks
		if (String.isEmpty(fileId)) {
			Attachment attachment = saveTheFile(parentId, fileName, base64Data, contentType, description);
			return attachment.Id;
		} else {
			Attachment attachment = appendToFile(fileId, base64Data);
			return attachment.Id;
		}
	}

	public static Attachment saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String description) {
		Attachment attachment = new Attachment();
		try {
			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
			attachment.ParentId = parentId;
			attachment.Body = EncodingUtil.base64Decode(base64Data);
			attachment.Name = fileName;
			attachment.ContentType = contentType;
			attachment.Description = description;
			insert attachment;
		} catch (Exception e) {
			System.debug('Error While Saving File: ' + e);
		}
		return attachment;
	}

	private static Attachment appendToFile(Id fileId, String base64Data) {
		Attachment attachment = new Attachment();
		try {
			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
			attachment = [
					SELECT Id, Body
					FROM Attachment
					WHERE Id = :fileId
			];
			String existingBody = EncodingUtil.base64Encode(attachment.Body);
			attachment.Body = EncodingUtil.base64Decode(existingBody + base64Data);
			update attachment;
		} catch (Exception e) {
			System.debug('Error While Updating File: ' + e);
		}
		return attachment;
	}
}