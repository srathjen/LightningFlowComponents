/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for Contact object
*******************************************************************************************************************/
@isTest
public class ContactFile_AT_Test {
	static testmethod void createContactFile() {
		trac_TriggerHandlerBase.blockTrigger = true;

		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert wishChild;

		cg__ContactFile__c newFileRecord = OrientationandTrainingUtil.createContactFileRecord(wishChild.Id);
		cg__ContactFile__c newFileRecord1 = OrientationandTrainingUtil.createContactFileRecord(wishChild.Id);
		insert new List<cg__ContactFile__c>{
				newFileRecord, newFileRecord1
		};

		trac_TriggerHandlerBase.blockTrigger = false;
	}
}