// This class used to do the unit testing and code coverage
// It will create the lead record
@isTest
private class DiagnosisVerficationRemainder_ACTest {
    private static Date todayDate = Date.today();

    @testSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account makeAWish = OrientationandTrainingUtil.CreateAmericaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        List<Lead> leadList = new List<Lead>(TestDataFactory.createLead(20));
        for(Integer i = 0; i < leadList.size(); i++) {
            leadList[i].Has_this_child_ever_received_prior_wish__c = 'Yes';
            leadList[i].Has_this_child_ever_received_prior_wish__c = 'Yes';
            leadList[i].Any_medical_reason_for_moving_quickly__c  = 'Yes';
            leadList[i].Relationship_To_Child__c = 'Self';
            leadList[i].Diagnosis_Given_By_Referrer__c = 'Malignant';
            leadList[i].Referrer_FirstName__c = 'Testing' + i;
            leadList[i].Referrer_Last_Name__c = 'Testing' + i;
            leadList[i].Referrer_Phone__c = '8220708920';
            leadList[i].Referrer_Email__c = 'testmawa@gmail.com';
            leadList[i].Referrer_City__c = 'karur';
            leadList[i].unique_wish_identifier__c ='059-17-1236' + i;
            leadList[i].Referrer_Zip__c = '35004';
            leadList[i].is_Family_Aware_of_Referral__c = 'Yes';
            leadList[i].FirstName = 'Testing' + i;
            leadList[i].Child_Middle_Initial__c = 'Testing' + i;
            leadList[i].lastName = 'Testing' + i;
            leadList[i].Gender__c = 'Male';
            leadList[i].Child_Age__c = '16';
            leadList[i].DOB__c = Date.valueOf('2000-09-11');
            leadList[i].Parent_First_Name__c = 'Testing' + i;
            leadList[i].Parent_Last_Name__c = 'Testing' + i;
            leadList[i].Street = 'Karur';
            leadList[i].City = 'Karur';
            leadList[i].state = 'Arizona';
            leadList[i].PostalCode= '35004';
            leadList[i].Email= 'testmawa2@gmail.com';
            leadList[i].Phone= '8220708920';
            leadList[i].What_is_the_family_s_primary_spoken_lang__c= 'English';
            leadList[i].Hospital_Treatment_Facility_Treating__c= 'Malignant Neoplasm';
            leadList[i].Treating_Medical_Professional_First_Name__c = 'Treating' + i;
            leadList[i].Treating_Medical_Professional_Last_Name__c= 'Treating' + i;
            leadList[i].Treating_Medical_Professional_Phone__c = '8220708921';
            leadList[i].Treating_Medical_Professional_Email__c= 'testmawa3@gmail.com';
            leadList[i].Any_medical_reason_for_moving_quickly__c= 'yes';
            leadList[i].PD_Condition_Description__c  = 'c00';
            leadList[i].PD_ICD_Code__c = icdCode.Id;
            leadList[i].RFI_Form_Info_Hidden__c = 'Referred';
            leadList[i].Company = 'MST';
            leadList[i].Status = 'Referred';
            leadList[i].Referred_Date__c = todayDate.addDays(-3);
        }
        insert leadList;
        trac_TriggerHandlerBase.blockTrigger = false;
    }
       
    @isTest
    static void testBatchPartAReminderSevenDays() {
        Test.startTest();
        List<Lead> leadsBeforeUpdate = new List<Lead>();
        leadsBeforeUpdate = [SELECT Id, Diagnosis_Given_By_Referrer__c, Status, Part_A_Sent__c, Sub_Status__c, 
                            Referred_Date__c, Dup_Check__c, Diagnosis_Pending_Days__c 
                            FROM Lead];
        System.assertEquals(NULL, leadsBeforeUpdate[0].Diagnosis_Pending_Days__c);
        for(Lead lead : leadsBeforeUpdate) {
            lead.Diagnosis_Given_By_Referrer__c = 'Malignant';
            lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
            lead.Part_A_Sent__c = todayDate.addDays(-7);
            lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
            lead.Referred_Date__c = todayDate;
            lead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
        }
        update leadsBeforeUpdate;
        DiagnosisVerficationRemainder_AC batchAffiliation = new DiagnosisVerficationRemainder_AC();
        Database.executeBatch(batchAffiliation, 200);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchPartAReminderFourteenDays() {
        Test.startTest();
        List<Lead> leadsBeforeUpdate = new List<Lead>();
        leadsBeforeUpdate = [SELECT Id, Diagnosis_Given_By_Referrer__c, Status, Part_A_Sent__c, Sub_Status__c, 
                            Referred_Date__c, Dup_Check__c, Diagnosis_Pending_Days__c 
                            FROM Lead];
        System.assertEquals(NULL, leadsBeforeUpdate[0].Diagnosis_Pending_Days__c);
        for(Lead lead : leadsBeforeUpdate) {
            lead.Diagnosis_Given_By_Referrer__c = 'Malignant';
            lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
            lead.Part_A_Sent__c = todayDate.addDays(-14);
            lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
            lead.Referred_Date__c = todayDate;
            lead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
        }
        update leadsBeforeUpdate;
        DiagnosisVerficationRemainder_AC batchAffiliation = new DiagnosisVerficationRemainder_AC();
        Database.executeBatch(batchAffiliation, 200);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchPartAReminderTwentyOneDays() {
        Test.startTest();
        List<Lead> leadsBeforeUpdate = new List<Lead>();
        leadsBeforeUpdate = [SELECT Id, Diagnosis_Given_By_Referrer__c, Status, Part_A_Sent__c, Sub_Status__c, 
                            Referred_Date__c, Dup_Check__c, Diagnosis_Pending_Days__c 
                            FROM Lead];
        System.assertEquals(NULL, leadsBeforeUpdate[0].Diagnosis_Pending_Days__c);
        for(Lead lead : leadsBeforeUpdate) {
            lead.Diagnosis_Given_By_Referrer__c = 'Malignant';
            lead.Status = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
            lead.Part_A_Sent__c = todayDate.addDays(-21);
            lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
            lead.Referred_Date__c = todayDate;
            lead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
        }
        update leadsBeforeUpdate;
        DiagnosisVerficationRemainder_AC batchAffiliation = new DiagnosisVerficationRemainder_AC();
        Database.executeBatch(batchAffiliation, 200);
        Test.stopTest(); 
    }
    
    @isTest
    static void testBatchReferredDateThreeDays() {
        Test.startTest();
        List<Lead> leadsBeforeUpdate = new List<Lead>();
        leadsBeforeUpdate = [SELECT Id, Diagnosis_Given_By_Referrer__c, Status, Part_A_Sent__c, Sub_Status__c, 
                            Referred_Date__c, Dup_Check__c, Diagnosis_Pending_Days__c 
                            FROM Lead];
        for(Lead lead : leadsBeforeUpdate) {
            lead.Diagnosis_Given_By_Referrer__c = 'Malignant';
            lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
            lead.Part_A_Sent__c = todayDate;
            lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
            lead.Inquiry_Date__c = todayDate.addDays(-4);
            lead.Referred_Date__c = todayDate.addDays(-3);
            lead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
        }
        update leadsBeforeUpdate;
        DiagnosisVerficationRemainder_AC batchAffiliation = new DiagnosisVerficationRemainder_AC();
        Database.executeBatch(batchAffiliation, 200);
        Test.stopTest();
    }

    @isTest
    static void testScheduler() {
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        //Schedule the test job
        String jobId = System.schedule('testJob1',
                                       CRON_EXP, 
                                       new DiagnosisVerficationRemainder_AC());
        //Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression,'Does not match');
        //Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered,'Does not match');
        //Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', 
                            String.valueOf(ct.NextFireTime),'Does not match');
        Test.stopTest();
    }
}