/******************************************************************************************
Author : MAWA
Created Date: 4/25/2019
Modification: 07/09/2019 - Samer - SIW-246
              Modified code for childDOB and childDOB2 to fix date calculation error.
*******************************************************************************************/
@IsTest
public class batch_LeadChildAgeTest {
    
    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountList;
        
        List<Condition_Description__c> conditionList = TestDataFactory.createConditionDescription(1);
        Condition_Description__c conditionMelanoma = conditionList.get(0);
        conditionMelanoma.Name = 'Malignant Melanoma';
        conditionMelanoma.Treatment_Subspecialty__c = 'Oncology';
        conditionMelanoma.Code_To_Use__c = 'C43.30';
        conditionMelanoma.PR_Diagnosis__c = 'Malignant Melanoma';
        conditionMelanoma.Group1__c = true;
        insert conditionList;
        
        List<ICD_Codes__c> icdCodeList = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdMelanoma = icdCodeList.get(0);
        icdMelanoma.Name = 'C43.30';
        icdMelanoma.Condition_Description__c = conditionMelanoma.Id;
        icdMelanoma.Group1__c = true;
        icdMelanoma.Short_Description__c = 'Malignant melanoma of unspecified part of face';
        icdMelanoma.Long_Description__c = 'Malignant melanoma of unspecified part of face';
        insert icdCodeList;
        
        List<Lead> leadListNew = TestDataFactory.createLead(20);
        for(Integer i = 0; i < leadListNew.size(); i++) {
            Lead lead = leadListNew.get(i);
            lead.FirstName = 'Charlie';
            lead.LastName = 'Young' + i;
            lead.Company = 'Make-A-Wish';
            lead.Status = 'Inquiry';
            lead.PD_ICD_Code__c = icdMelanoma.Id;
            lead.Diagnosis_Given_By_Referrer__c = 'Malignant Melanoma';
            lead.PostalCode = '85016';
            lead.Street = '100 Market Street';
            lead.City = 'Phoenix';
            lead.State = 'Arizona';
            lead.ChapterName__c = accountAzChapter.Id;
            lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
            lead.Child_Age__c = 'Under 2.5';
            lead.Gender__c = 'Male';
            lead.Age_Requirement_Met__c = false;
            lead.Treating_Medical_Professional_Email__c = 'medical.professional' + i + '@gmail.com';
            lead.is_Family_Aware_of_Referral__c = 'Yes';
            if(i < (leadListNew.size()/2)) {
                lead.DOB__c = Date.today().addYears(-1).addMonths(-6);
            } else {
                lead.DOB__c = Date.today().addYears(-2).addMonths(-6);
            }
        }
        insert leadListNew;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    static void testBatchLeadChildAgeWhenRunDateIsToday() {
        Test.startTest();
        //Verify none of the leads entering the batch have the Age requirement field marked as true
        Lead[] leadsBeforeUpdateList = [
            SELECT Id, Age_Requirement_Met__c
            FROM Lead
            WHERE Age_Requirement_Met__c = true
        ];
        System.assertEquals(0, leadsBeforeUpdateList.size());
        //Cron Expression setting at 13:00:00 every day
        String cronExpression = '0 0 13 * * ?';
        batch_LeadChildAgeSchedule reminder = new batch_LeadChildAgeSchedule();
        String jobId = System.schedule('Lead Child Age Req', cronExpression, reminder);
        reminder.execute(null);
        Test.stopTest();
        
        Lead[] leadsUpdatedList = [
            SELECT Id, Age_Requirement_Met__c
            FROM Lead
            WHERE Age_Requirement_Met__c = true
        ];
        //Assert that number of the leads that should have been updated have been updated
        System.assertEquals(true, leadsUpdatedList[0].Age_Requirement_Met__c);
        System.assertEquals(10, leadsUpdatedList.size());
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(cronExpression, ct.CronExpression);
    }
    
    @IsTest
    static void testBatchLeadChildAgeWhenRunDateLastDayOfMonth() {
        Test.startTest();
        //Verify none of the leads entering the batch have the Age requirement field marked as true
        Lead[] leadsBeforeUpdateList = [
            SELECT Id, Age_Requirement_Met__c
            FROM Lead
            WHERE Age_Requirement_Met__c = true
        ];
        System.assertEquals(0, leadsBeforeUpdateList.size());
        batch_leadChildAge reminder = new batch_leadChildAge();
        reminder.runDate = Date.parse('06/30/2019');
        Database.executeBatch(reminder);
        Test.stopTest();
        
        Lead[] leadsUpdatedList = [
            SELECT Id, Age_Requirement_Met__c
            FROM Lead
            WHERE Age_Requirement_Met__c = true
        ];
        //Assert that no leads should have been updated
        System.assertEquals(0, leadsUpdatedList.size());
    }
}