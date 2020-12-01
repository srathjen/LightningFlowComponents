// This class used to do the unit testing and code coverage
// It will create the lead record
@IsTest
private class DiagnosisVerificationReminder_ACTest {

    private static final Date TODAY = Date.today();
    private static final String CRON_EXP = '0 0 0 15 3 ? 2022';

    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Condition_Description__c descrip = TestDataFactory.createConditionDescription(1)[0];
        descrip.Name = 'Malignant Melanoma';
        descrip.Treatment_Subspecialty__c = 'Oncology';
        descrip.Code_To_Use__c = 'C43.30';
        descrip.PR_Diagnosis__c = 'Malignant Melanoma';
        descrip.Group1__c = true;
        insert descrip;

        ICD_Codes__c icdCode = TestDataFactory.createIcdCode(1)[0];
        icdCode.Name = 'C43.30';
        icdCode.Condition_Description__c = descrip.Id;
        icdCode.Group1__c = true;
        icdCode.Short_Description__c = icdCode.Long_Description__c = 'Malignant melanoma of unspecified part of face';
        insert icdCode;

        List<Lead> leadList = new List<Lead>(TestDataFactory.createLead(20));
        for (Integer i = 0; i < leadList.size(); i++) {
            leadList[i].Has_this_child_ever_received_prior_wish__c = 'Yes';
            leadList[i].Has_this_child_ever_received_prior_wish__c = 'Yes';
            leadList[i].Any_medical_reason_for_moving_quickly__c = 'Yes';
            leadList[i].Relationship_to_child__c = 'Self';
            leadList[i].Diagnosis_Given_By_Referrer__c = 'Malignant';
            leadList[i].Referrer_FirstName__c = 'Testing' + i;
            leadList[i].Referrer_Last_Name__c = 'Testing' + i;
            leadList[i].Referrer_Phone__c = '8220708920';
            leadList[i].Referrer_Email__c = 'testmawa@gmail.com';
            leadList[i].Referrer_City__c = 'karur';
            leadList[i].unique_wish_identifier__c = '059-17-1236' + i;
            leadList[i].Referrer_Zip__c = '35004';
            leadList[i].is_Family_Aware_of_Referral__c = 'Yes';
            leadList[i].FirstName = 'Testing' + i;
            leadList[i].Child_Middle_Initial__c = 'Testing' + i;
            leadList[i].LastName = 'Testing' + i;
            leadList[i].Gender__c = 'Male';
            leadList[i].Child_Age__c = '16';
            leadList[i].DOB__c = Date.valueOf('2000-09-11');
            leadList[i].Parent_First_Name__c = 'Testing' + i;
            leadList[i].Parent_Last_Name__c = 'Testing' + i;
            leadList[i].Street = 'Karur';
            leadList[i].City = 'Karur';
            leadList[i].State = 'Arizona';
            leadList[i].PostalCode = '35004';
            leadList[i].Email = 'testmawa2@gmail.com';
            leadList[i].Phone = '8220708920';
            leadList[i].What_is_the_family_s_primary_spoken_lang__c = 'English';
            leadList[i].Any_medical_reason_for_moving_quickly__c = 'yes';
            leadList[i].PD_Condition_Description__c = 'c00';
            leadList[i].PD_ICD_Code__c = icdCode.Id;
            leadList[i].RFI_Form_Info_Hidden__c = 'Referred';
            leadList[i].Company = 'MST';
            leadList[i].Status = 'Referred';
            leadList[i].Referred_Date__c = TODAY.addDays(-3);
            leadList[i].Treating_Medical_Professional_First_Name__c = 'Dr. Jack';
            leadList[i].Treating_Medical_Professional_Last_Name__c = 'Doe';
            leadList[i].Treating_Medical_Professional_Phone__c = '8220708921';
            leadList[i].Treating_Medical_Professional_Email__c = 'jdoe@email.com';
            leadList[i].Hospital_Treatment_Facility_Treating__c = 'Treating Facility';
        }
        insert leadList;
        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void testBatchReferredDateThreeDays() {
        List<Lead> leadsBeforeUpdate = getTestLeads();
        for (Lead lead : leadsBeforeUpdate) {
            setupLeadRecord(lead, TODAY, Constant_AC.LEAD_STATUS_REFERRED);
            lead.Inquiry_Date__c = TODAY.addDays(-4);
            lead.Referred_Date__c = TODAY.addDays(-3);
        }
        update leadsBeforeUpdate;

        Test.startTest();
        scheduleJob();
        Test.stopTest();
    }

    @IsTest
    static void testBatchPartAReminderSevenDays() {
        List<Lead> leadsBeforeUpdate = getTestLeads();
        System.assertEquals(null, leadsBeforeUpdate[0].Diagnosis_Pending_Days__c);
        for (Lead lead : leadsBeforeUpdate) {
            setupLeadRecord(lead, TODAY.addDays(-7), Constant_AC.LEAD_STATUS_REFERRED);
        }
        update leadsBeforeUpdate;

        Test.startTest();
        scheduleJob();
        Test.stopTest();
    }

    @IsTest
    static void testBatchPartAReminderFourteenDays() {
        List<Lead> leadsBeforeUpdate = getTestLeads();
        System.assertEquals(null, leadsBeforeUpdate[0].Diagnosis_Pending_Days__c);
        for (Lead lead : leadsBeforeUpdate) {
            setupLeadRecord(lead, TODAY.addDays(-14), Constant_AC.LEAD_STATUS_REFERRED);
        }
        update leadsBeforeUpdate;

        Test.startTest();
        scheduleJob();
        Test.stopTest();
    }

    @IsTest
    static void testBatchPartAReminderTwentyOneDays() {
        List<Lead> leadsBeforeUpdate = getTestLeads();
        System.assertEquals(null, leadsBeforeUpdate[0].Diagnosis_Pending_Days__c);
        for (Lead lead : leadsBeforeUpdate) {
            setupLeadRecord(lead, TODAY.addDays(-21), Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION);
        }
        update leadsBeforeUpdate;

        Test.startTest();
        scheduleJob();
        Test.stopTest();
    }

    private static List<Lead> getTestLeads() {
        return [
                SELECT Id, Diagnosis_Given_By_Referrer__c, Status, Part_A_Sent__c, Sub_Status__c,
                        Referred_Date__c, Dup_Check__c, Diagnosis_Pending_Days__c
                FROM Lead
        ];
    }

    private static void scheduleJob() {
        System.schedule('testJob1',
                CRON_EXP,
                new DiagnosisVerificationReminder_AC());
    }

    private static void setupLeadRecord(Lead lead, Date partASentDate, String status) {
        lead.Diagnosis_Given_By_Referrer__c = 'Malignant';
        lead.Status = status;
        lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
        lead.Referred_Date__c = TODAY;
        lead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
        lead.Part_A_Sent__c = partASentDate;
    }
}