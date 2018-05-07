/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for CaseFile object
*******************************************************************************************************************/
@isTest
public class CaseFile_AT_Test {
    static testmethod void createCaseFile() {
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case newCase = OrientationandTrainingUtil.createParentCase(wishChild.Id);
        cg__CaseFile__c newFileRecord = OrientationandTrainingUtil.createCaseFileRecord(newCase.Id);
        system.AssertEquals(newCase.contactId,wishChild.Id,'Contact Id does not match');
        system.Assert(newCase.Id == newFileRecord.cg__Case__c,'Case Id does not match');
    }
}