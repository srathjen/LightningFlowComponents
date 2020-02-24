/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for CaseFile object
*******************************************************************************************************************/
@IsTest
public class CaseFile_AT_Test {
	@TestSetup static void methodName() {
		Id wishClearenceRecordTypeId = Constant_AC.WISH_CLEARANCE_ATTACHMENT_ID;

		Contact wishChildCon = OrientationandTrainingUtil.CreateWishChild();
		insert wishChildCon;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChildCon.Id);
		insert parentCase;

		insert new Minor_Participant__c(Associated_Childeren__c = 'Test', AttachmentId__c = 'Test', RecordTypeId = wishClearenceRecordTypeId, Case__c = parentCase.Id);
	}

	static testmethod void createCaseFile() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert wishChild;

        Case parentCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		cg__CaseFile__c newFileRecord = OrientationandTrainingUtil.createCaseFileRecord(parentCase.Id);
		newFileRecord.File_Path__c = 'Path';
		newFileRecord.cg__Key__c = 'Test File';
		newFileRecord.cg__File_Name__c = 'Sample';
        insert newFileRecord;
        
		Minor_Participant__c updateCaseFile = new Minor_Participant__c();
		updateCaseFile.Id = [
				SELECT Id
				FROM Minor_Participant__c
				LIMIT 1
		].Id;
		updateCaseFile.Case__c = parentCase.Id;
		updateCaseFile.AttachmentId__c = newFileRecord.cg__File_Name__c;
		update updateCaseFile;
		update newFileRecord;

		//system.AssertEquals(newCase.contactId,wishChild.Id,'Contact Id does not match');
		//system.Assert(newCase.Id == newFileRecord.cg__Case__c,'Case Id does not match');
	}

	static testMethod void deleteCaseFile() {
		Test.startTest();
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert wishChild;

        Case parentCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Minor_Participant__c newMinorPart = new Minor_Participant__c();
		newMinorPart.Case__c = parentCase.id;
		newMinorPart.File_Path__c = 'Path';
		insert newMinorPart;
		cg__CaseFile__c newFileRecord = OrientationandTrainingUtil.createCaseFileRecord(parentCase.Id);
		newFileRecord.File_Path__c = 'Path';
		insert newFileRecord;
		cg__CaseFile__c newCaseFile = new cg__CaseFile__c(cg__Case__c = parentCase.Id, cg__Content_Type__c = 'Folder', cg__File_Name__c = 'Documents');
		insert newCaseFile;
		cg__CaseFile__c newCaseFile1 = new cg__CaseFile__c(cg__Case__c = parentCase.Id, cg__Content_Type__c = 'Folder', cg__File_Name__c = 'Documents', cg__Parent_Folder_Id__c = newCaseFile.Id);
		insert newCaseFile1;
		cg__CaseFile__c folderCon = new cg__CaseFile__c(cg__Case__c = parentCase.Id, cg__Content_Type__c = 'Folder1', cg__File_Name__c = 'Documents', cg__Parent_Folder_Id__c = newCaseFile.Id);
		insert folderCon;
		delete newFileRecord;
		Test.stopTest();
	}
}