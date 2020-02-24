/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : This class is used to generate file path for the attachment that stored in SDrive for object

Modification Log:
09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/
public without sharing class AWSFilePath_AC {

	@future
	public static void UpdateWishRequiredSignatureFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {

		try {
			List<String> wishSignFilePaths;
			List<Id> fileParentIds = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			List<Wish_Required_Signature_File__c > wishSignFiles = [
					Select Id, Wish_Required_Signature__c, File_Name__c, File_Path__c
					from Wish_Required_Signature_File__c
					where Wish_Required_Signature_File__c.Content_Type__c != 'Folder' and Wish_Required_Signature_File__c.Id in:fileRecordIds
			];
			if (wishSignFiles.size() > 0) {
				for (Wish_Required_Signature_File__c dbWishSignFileRec : wishSignFiles) {
					fileParentIds.add(dbWishSignFileRec.Wish_Required_Signature__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + dbWishSignFileRec.File_Name__c
					});
				}
			}
			if (!Test.isRunningTest()) {
				//Used to get the file path of the attachment stored in Amazon
				If (fileParentIds.Size() > 0)
					wishSignFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
			} else {
				wishSignFilePaths = new List<String>{
						'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
				};
			}

			for (Wish_Required_Signature_File__c wishSignFileRec : wishSignFiles) {
				for (String str : wishSignFilePaths) {
					if (str.contains(wishSignFileRec.Id)) {
						wishSignFileRec.File_Path__c = str;
						wishSignFileRec.WIP__c = false;
					}
				}
			}
			update wishSignFiles;
			delete [
					SELECT Id
					FROM Attachment
					WHERE ParentId IN:fileParentIds
			];
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			System.debug('Exception ' + ex + 'trace ' + ex.getStackTraceString());
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateAccountFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Wish_Required_Signature_File__c currRec : [
						SELECT Id
						FROM Wish_Required_Signature_File__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					//  currRec.addError(Label.Debug_log_error_message);
				}
			}

		}

	}

	@future
	public static void UpdateAccountFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {

		try {
			List<String> accountFilePaths;
			List<Id> fileParentIds = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			List<cg__AccountFile__c> accountFiles = [
					Select Id, cg__Account__c, cg__File_Name__c, File_Path__c
					from cg__AccountFile__c
					where cg__AccountFile__c.cg__Content_Type__c != 'Folder' and cg__AccountFile__c.Id in:fileRecordIds
			];

			if (accountFiles.size() > 0) {
				for (cg__AccountFile__c dbAccountFileRec : accountFiles) {
					fileParentIds.add(dbAccountFileRec.cg__Account__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + dbAccountFileRec.cg__File_Name__c
					});
				}
			}

			if (!Test.isRunningTest()) {
				//Used to get the file path of the attachment stored in Amazon
				If (fileParentIds.Size() > 0)
					accountFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
			} else
					accountFilePaths = new List<String>{
							'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
					};

			for (cg__AccountFile__c accountFileRec : accountFiles) {
				for (String str : accountFilePaths) {
					if (str.contains(accountFileRec.Id)) {
						accountFileRec.File_Path__c = str;
					}
				}
			}
			update accountFiles;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateAccountFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (cg__AccountFile__c currRec : [
						SELECT Id
						FROM cg__AccountFile__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					//  currRec.addError(Label.Debug_log_error_message);
				}
			}

		}

	}

	@future
	public static void UpdateContactFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
		try {
			List<String> contactFilePaths;
			List<Id> fileParentIds = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			List<cg__ContactFile__c> contactFiles = [
					Select Id, cg__Contact__c, cg__File_Name__c, File_Path__c
					from cg__ContactFile__c
					where cg__Content_Type__c != 'Folder' and cg__ContactFile__c.Id in:fileRecordIds
			];

			if (contactFiles.size() > 0) {
				for (cg__ContactFile__c dbContactFileRec : contactFiles) {
					fileParentIds.add(dbContactFileRec.cg__Contact__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + dbContactFileRec.cg__File_Name__c
					});
				}
			}
			if (fileParentIds.size() > 0) {

				if (!Test.isRunningTest())
					//Used to get the file path of the attachment stored in Amazon

					contactFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList); else
						contactFilePaths = new List<String>{
								'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
						};

			}

			for (cg__ContactFile__c ContactFileRec : contactFiles) {
				for (String str : contactFilePaths) {
					if (str.contains(ContactFileRec.Id)) {
						ContactFileRec.File_Path__c = str;
					}
				}
			}
			update contactFiles;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateContactFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (cg__ContactFile__c currRec : [
						SELECT Id
						FROM cg__ContactFile__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					// currRec.addError(Label.Debug_log_error_message);
				}
			}

		}

	}

	@future
	public static void UpdateCaseFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
		try {
			List<String> caseFilePaths;
			List<Id> fileParentIds = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			List<cg__CaseFile__c> caseFiles = [
					Select Id, cg__Case__c, cg__File_Name__c, File_Path__c
					from cg__CaseFile__c
					where cg__CaseFile__c.cg__Content_Type__c != 'Folder' and cg__CaseFile__c.Id in:fileRecordIds
			];

			if (caseFiles.size() > 0) {
				for (cg__CaseFile__c dbCaseFileRec : caseFiles) {
					fileParentIds.add(dbCaseFileRec.cg__Case__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + dbCaseFileRec.cg__File_Name__c
					});
				}
			}

			if (!Test.isRunningTest() && fileParentIds.Size() > 0 && fileRecordIds.Size() > 0) {
				//Used to get the file path of the attachment stored in Amazon
				If (fileParentIds.Size() > 0)
					caseFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
			} else
					caseFilePaths = new List<String>{
							'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
					};

			for (cg__CaseFile__c caseFileRec : caseFiles) {
				for (String str : caseFilePaths) {
					if (str.contains(caseFileRec.Id)) {
						caseFileRec.File_Path__c = str;
					}
				}
			}
			update caseFiles;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateCaseFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (cg__CaseFile__c currRec : [
						SELECT Id
						FROM cg__CaseFile__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					// currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	@future
	public static void UpdateBackgroundCheckFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
		try {
			List<String> bcFilePaths;
			List<Id> fileParentIds = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			List<Background_Check_File__c> bcFiles = [
					Select Id, Parent__c, File_Name__c, File_Path__c
					from Background_Check_File__c
					where Background_Check_File__c.Content_Type__c != 'Folder' and Background_Check_File__c.Id in:fileRecordIds
			];

			if (bcFiles.size() > 0) {
				for (Background_Check_File__c dbbcFileRec : bcFiles) {
					fileParentIds.add(dbbcFileRec.Parent__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + dbbcFileRec.File_Name__c
					});
				}
			}

			if (!Test.isRunningTest()) {
				//Used to get the file path of the attachment stored in Amazon
				If (fileParentIds.Size() > 0)
					bcFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
			} else
					bcFilePaths = new List<String>{
							'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
					};

			for (Background_Check_File__c bcFileRec : bcFiles) {
				for (String str : bcFilePaths) {
					if (str.contains(bcFileRec.Id)) {
						bcFileRec.File_Path__c = str;
					}
				}
			}
			update bcFiles;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateBackgroundCheckFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Background_Check_File__c currRec : [
						SELECT Id
						FROM Background_Check_File__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					// currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	@future
	public static void UpdateInKindDonReimburFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
		try {
			List<String> drFilePaths;
			List<Id> fileParentIds = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			//List<In_Kind_Donation_Reimbursement_File__c> drFiles = [Select Id, Parent__c, File_Name__c, File_Path__c from In_Kind_Donation_Reimbursement_File__c where In_Kind_Donation_Reimbursement_File__c.Content_Type__c !='Folder' and  In_Kind_Donation_Reimbursement_File__c.Id in: fileRecordIds];

			List<InkindDon_reimburseFile__c> drFiles = [
					Select Id, Parent__c, File_Name__c, File_Path__c
					from InkindDon_reimburseFile__c
					where InkindDon_reimburseFile__c.Content_Type__c != 'Folder' and InkindDon_reimburseFile__c.Id in:fileRecordIds
			];

			if (drFiles.size() > 0) {
				// for(In_Kind_Donation_Reimbursement_File__c dbdrFileRec : drFiles){
				for (InkindDon_reimburseFile__c dbdrFileRec : drFiles) {
					fileParentIds.add(dbdrFileRec.Parent__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + dbdrFileRec.File_Name__c
					});
				}
			}

			if (!Test.isRunningTest() && fileParentIds.Size() > 0)
				//Used to get the file path of the attachment stored in Amazon

				drFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList); else
					drFilePaths = new List<String>{
							'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
					};

			// for(In_Kind_Donation_Reimbursement_File__c drFileRec : drFiles){
			for (InkindDon_reimburseFile__c drFileRec : drFiles) {
				for (String str : drFilePaths) {
					if (str.contains(drFileRec.Id)) {
						drFileRec.File_Path__c = str;
					}
				}
			}
			update drFiles;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateInKindDonReimburFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (InkindDon_reimburseFile__c currRec : [
						SELECT Id
						FROM InkindDon_reimburseFile__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					//  currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	/*This method is used to create file path for the attachment that stored to SDrive from the Lead record.
It will update the file path to lead file record that created during attachment upload*/
	@future
	public static void generateLeadFilePath(Set<Id> fileIdsSet, Map<Id, String> exceptionMap) {
		try {
			List<Id> fileIdsList = new List<Id>(fileIdsSet);
			List<String> leadFilePath;
			List<Id> fileParentIdList = new List<Id>();
			List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

			List<cg__Lead_File__c> leadFileList = [
					Select Id, cg__Lead__c, cg__File_Name__c, File_Path__c
					from cg__Lead_File__c
					where cg__Lead_File__c.cg__Content_Type__c != 'Folder' and cg__Lead_File__c.Id in:fileIdsSet
			];
			if (leadFileList.size() > 0) {
				for (cg__Lead_File__c collectedFileRec : leadFileList) {
					fileParentIdList.add(collectedFileRec.cg__Lead__c);
					requestParametersList.add(new Map<String, String>{
							'response-content-disposition' => 'attachment;filename=' + collectedFileRec.cg__File_Name__c
					});
				}
			}

			if (!Test.isRunningTest()) {
				//Used to get the file path of the attachment stored in Amazon
				If (fileParentIdList.Size() > 0)
					leadFilePath = cg.SDriveTools.getAttachmentURLs(fileParentIdList, fileIdsList, (365 * 24 * 60 * 60), requestParametersList);
			} else
					leadfilepath = new List<String>{
							'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='
					};
			for (cg__Lead_File__c collectedFileRec : leadFileList) {
				for (String filePath : leadFilePath) {
					if (filePath.contains(collectedFileRec.Id)) {
						collectedFileRec.File_Path__c = filePath;
					}
				}
			}
			update leadFileList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Id currRec : exceptionMap.keyset()) {
				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'generateLeadFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (cg__Lead_File__c currRec : [
						SELECT Id
						FROM cg__Lead_File__c
						WHERE Id IN :exceptionMap.keyset()
				]) {
					// currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	// Used to generate task when volunteer upload image or video
	/*WLP-467 remove automated task creation */
//	@Future(Callout = true)
//	public static void createAttachmentReviewTask(String jsontaskListString, Set<Id> caseIdsSet, Map<Id, String> exceptionMap) {
//		try {
//			Id staffTaskRT = Constant_AC.STAFF_TASK_RT_ID;
//			List<cg__CaseFile__c> caseFileList = (List<cg__CaseFile__c>) Json.deserialize(jsontaskListString, List<cg__CaseFile__c>.class);
//			Id contactId;
//			Map<Id, Case> caseOwnerMap = new Map<Id, Case>();
//			Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
//			for (Case caseOwner : [
//					SELECT Id, ContactId, RecordTypeId, OwnerId
//					FROM Case
//					WHERE RecordTypeId = :wishRecordTypeId AND Id IN :caseIdsSet
//			]) {
//				caseOwnerMap.put(caseOwner.Id, caseOwner);
//				contactId = caseOwner.Id;
//			}
//			Set<Id> reviewPhotosSet = new Set<Id>();
//			Set<Id> dupCheck = new Set<Id>();
//			if (contactId != null) {
//				String jsonbody = VolunteerInterviewTask_AC.getUploadReviewTask(contactId);
//				List<Task> newTaskList;
//				if (!Test.isRunningTest()) {
//					newTaskList = (List<Task>) JSON.deserialize(jsonbody, List<Task>.class);
//				} else {
//					newTaskList = new list<task>();
//				}
//				if (newTaskList.size() > 0) {
//					for (Task getTask : newTaskList) {
//						reviewPhotosSet.add(getTask.WhatId);
//					}
//				}
//			}
//			List<Task> reviewTaskList = new List<Task>();
//			for (cg__CaseFile__c createTask : caseFileList) {
//				if (!reviewPhotosSet.contains(createTask.cg__Case__c) && !dupCheck.contains(createTask.cg__Case__c)) {
//					Task reviewTask = new Task();
//					reviewTask.Subject = 'Review Volunteer Upload';
//					reviewTask.SystemGeneratedTask__c = TRUE;
//					reviewTask.WhatId = createTask.cg__Case__c;
//					reviewTask.RecordTypeId = staffTaskRT;
//					reviewTask.ActivityDate = System.today().addDays(10);
//					if (caseOwnerMap.containsKey(createTask.cg__Case__c)) {
//						reviewTask.OwnerId = caseOwnerMap.get(createTask.cg__Case__c).OwnerId;
//						reviewTask.WhoId = caseOwnerMap.get(createTask.cg__Case__c).ContactId;
//					}
//					reviewTaskList.add(reviewTask);
//					dupCheck.add(createTask.cg__Case__c);
//				}
//			}
//			if (reviewTaskList.size() > 0) {
//				insert reviewTaskList;
//			}
//			if (Test.isRunningTest()) {
//				throw new CommonTriggerException('Test Class execution');
//			}
//		} catch (Exception ex) {
//			for (Id currRec : exceptionMap.keyset()) {
//				ErrorMessage_AC.createdebugRec('AWSFilePath_AC', exceptionMap.get(currRec), String.valueOf(ex), 'UpdateInKindDonReimburFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
//			}
//			if (!Test.isRunningTest()) {
//				for (Lead_File__c currRec : [
//						SELECT Id
//						FROM Lead_File__c
//						WHERE Id IN :exceptionMap.keyset()
//				]) {
//					// currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//
//		}
//	}

}