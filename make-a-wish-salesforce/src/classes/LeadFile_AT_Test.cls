/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for LeadFile object
*******************************************************************************************************************/
@isTest
public class LeadFile_AT_Test {
    static testmethod void createLeadFile() {
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        Lead_File__c newFileRecord = OrientationandTrainingUtil.createLeadFileRecord(newLead.Id);
    }
}