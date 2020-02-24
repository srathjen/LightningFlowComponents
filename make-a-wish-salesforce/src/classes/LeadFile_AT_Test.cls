/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for LeadFile object

Modification Log:
09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/
@isTest
public class LeadFile_AT_Test {

	static testmethod void createLeadFile() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		insert newLead;
		cg__Lead_File__c newFileRecord = OrientationandTrainingUtil.createLeadFileRecord(newLead.Id);
		insert newFileRecord;
	}

	static testmethod void updateLeadFile() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		insert newLead;
		cg__Lead_File__c newFileRecord = OrientationandTrainingUtil.createLeadFileRecord(newLead.Id);
		insert newFileRecord;
		newFileRecord.File_Path__c = 'https://salesforce.com';
		update newFileRecord;
	}
}