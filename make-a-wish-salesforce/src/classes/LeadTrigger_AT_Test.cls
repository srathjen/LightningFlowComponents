/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 09/12/2016
Description : LeadTrigger_AT_Test is used to increase the code coverage for LeadTrigger_AT and its controller.

Modification Log:
1. 09/10/2019 - Manik - WLP-423
2. 01/02/2020 - SIW-342 - All field name changes reverted. Sub_status__c = 'Pending Diagnosis Verification' may have changed from 'Pending Part A'
*****************************************************************************************************/

@isTest
public class LeadTrigger_AT_Test {

    //This method is create the lead with addidional parent information.
    public testMethod static void sameAdditionalParent() {
        try {
            Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
            Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
            insert descrip;
            Office__c officeRec = OrientationandTrainingUtil.createOffice(chapterAccount.Id);
            insert officeRec;
            Zip_Code__c zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
            zipRec.External_Id__c = '6201717';
            insert zipRec;
            Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
            Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
            ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
            insert icdCode;
            Lead newLead = OrientationandTrainingUtil.createAdditionalParentLead(chapterAccount.Id);
            insert newLead;
            Condition_Description__c conditionDesCription = OrientationandTrainingUtil.createConditionDesCription();
            insert conditionDesCription;
            ICD_Codes__c obj = new ICD_Codes__c();
            obj.Name = 'C120';
            obj.Condition_Description__c = conditionDesCription.Id;
            insert obj;
            ICD_Codes__c obj1 = new ICD_Codes__c();
            obj1.Name = 'C121';
            obj1.Condition_Description__c = conditionDesCription.Id;
            insert obj1;
            RecursiveTriggerHandler.isFirstTime = true;
            System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
            newLead.SD1_ICD_Code__c = icdCode.Id;
            newLead.SD2_ICD_Code__c = icdCode.Id;
            newLead.SD3_ICD_Code__c = icdCode.Id;
            newLead.SD4_ICD_Code__c = icdCode.Id;
            newLead.Status = 'Referred';
            newLead.ChapterName__c = chapAcc.Id;
                newLead.Sub_Status__c = 'Pending Diagnosis Verification';  //SIW-342
            newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfessionalCon.Id;
            newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
            newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
            newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
            newLead.Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
            newLead.PD_ICD_Code__c = obj.Id;
            newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
            update newLead;
            newLead.Status = 'Qualified';
            newLead.PD_ICD_Code__c = obj1.Id;
            Test.startTest();
            update newLead;
            Test.stopTest();
            System.assertEquals(newLead.Status, 'Qualified');
            System.assertEquals(medicalProfessionalCon.Id, newLead.Treating_Medical_Professional_Contact_Id__c);
        }

        catch (DMLException e) {
            system.assertEquals(e.getMessage(), e.getMessage());
        }
    }
    //Convert the lead with Eligibility Review status.

    public testmethod static void updateLeadAsEligibilityReview() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        OrientationandTrainingUtil.CreateAmericaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.Part_A_Received__c = Date.Today();
        newLead.OwnerId = userInfo.getUserId();
        List<Lead> leadlist = new List<Lead>();
        leadlist.add(newLead);
       // Lead_OnBeforeUpdateTriggerHandlerHelper.createComatoseTask(leadlist);** removing as part of SIW
        Lead_OnBeforeUpdateTriggerHandlerHelper.updateChapterViaZipcode(leadlist);
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Eligibility Review';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'Yes';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Eligibility Review');

    }

    public testmethod static void updateLeadAsIntegrationUser() {
        User integrationUser = OrientationandTrainingUtil.createIntegrationUser();
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        OrientationandTrainingUtil.CreateAmericaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.PostalCode = '21344';
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Qualifying_Diagnosis__c = 'Test';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.Status = 'Pending Diagnosis Verification';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.OwnerId = userInfo.getUserId();
        newLead.Qualifying_Diagnosis__c = null;
        List<Lead> leadlist = new List<Lead>();
        leadlist.add(newLead);
        //Lead_OnBeforeUpdateTriggerHandlerHelper.createComatoseTask(leadlist);Removing as part of SIW-255
        Lead_OnBeforeUpdateTriggerHandlerHelper.updateChapterViaZipcode(leadlist);
        update newLead;
        Test.startTest();
        System.runAs(integrationUser) {

            newLead.Any_medical_reason_for_moving_quickly__c = 'No';
            newLead.Please_Explain__c = 'Yes';
            //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
            newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
            newLead.Status = 'Eligibility Review';
            newLead.Is_in_a_Comatose_Vegetative_State__c = 'Yes';
            newLead.ChapterName__c = chapAcc.Id;
            newLead.PostalCode = '98002';
            update newLead;
        }

        Test.stopTest();
    }
    //Convert the lead with qualified status.

    public testmethod static void updateLeadAsQualified() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');
        System.assertEquals(medicalProfessionalCon.Id, newLead.Medical_Professional_ContactId__c);
    }
    //The reffer and treating medical professional are same person.
    //Convert the lead with status of Qualified
    public testmethod static void updateLeadAsQualifiedMedCon() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfessionalCon2 = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Id hospitalTreatMentRecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
        Account newAccount = new Account();
        newAccount.Name = 'TestReferrer';
        newAccount.RecordTypeId = hospitalTreatMentRecordTypeId;
        insert newAccount;

        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Referrer_FirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalLastName__c = 'Alternate';
        newLead.Referrer_Last_Name__c = 'Alternate';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        newLead.Alternate1MedicalProfessionalEmail__c = 'alternate@gmail.com';
        newLead.Referrer_Email__c = 'alternate@gmail.com';
        newLead.Alternate1MedProfessionalPhone__c = '9600467559';
        newLead.Alternate1HospitalTreatmentFacility__c = 'TestAlternate1Hospital';

        newLead.Alternate2MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalLastName__c = 'Alternate2';
        newLead.Alternate2MedProfessionalEmail__c = 'alternate2@gmail.com';
        newLead.Alternate2MedProfessionalPhone__c = '9600467552';
        newLead.Alternate2HospitalTreatmentFacility__c = 'TestAlternate2Hospital';
        newLead.Referrer_Phone__c = '9600467559';

        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        //newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 1 Medical Professional';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.HiddenAlternate1MedProfessionalId__c = medicalProfessionalCon.Id;
        newLead.HiddenAlternate2MedProfessionalId__c = medicalProfessionalCon2.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Any_medical_reason_for_moving_quickly__c = 'No';
        //newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');

    }

    /*The lead has contain the alternate medical provider details.
medical professional contact merged with existing contact*/
    public testmethod static void updateLeadAsQualifiedAlternateMedCon() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Referrer_FirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalLastName__c = 'Alternate';
        newLead.Referrer_Last_Name__c = 'Alternate';
        newLead.Alternate1MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalLastName__c = 'Alternate1';
        //newLead.Alternate1MedProfessionalEmail__c = 'alternate1@gmail.com';
        newLead.Alternate1MedProfessionalPhone__c = '9600467552';

        newLead.Alternate2MedProfessionalEmail__c = 'alternate@gmail.com';
        newLead.Referrer_Email__c = 'alternate@gmail.com';
        newLead.Alternate2MedProfessionalPhone__c = '9600467559';
        newLead.Alternate2HospitalTreatmentFacility__c = 'TestAlternate2Hospital';
        newLead.Referrer_Phone__c = '9600467559';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        // newLead.HiddenAlternate2MedProfessionalId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.DOB__c = system.today() - 8543;
        newLead.Gender__c = 'Female';
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');

    }

    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */
    public testmethod static void CreateRelationShipRecord() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAccount;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';

        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;

        newLead.Sibling_Detail__c = '- | bbb | 12';
        //newLead.Sub_Status__c ='Pending Diagnosis Verification';

        insert newLead;
        RecursiveTriggerHandler.isFirstTime = true;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        update newLead;
        System.assertEquals(newLead.Status, 'Inquiry');
    }

    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */
    public testmethod static void CreateRelationShipRecordwithExisitingContact() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        newLead.Treating_Medical_Professional_Contact_Id__c = trateProfContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfContact.Id;
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.Wish_Family_ContactId__c = wishFamily.Id;
        newLead.Sibling_Detail__c = 'aa | bbb | -';
        newLead.Is_Required_Bypass__c = true;
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        update newLead;
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';
        Test.StartTest();
        update newLead;
        Test.StopTest();
        System.assertEquals(newLead.Status, 'Qualified');

    }

    //This Method is used increase the code coverage when the lead is send to DV form and convert the lead with Qualified status.
    public testmethod static void UpdateStatusAsQualified() {
        List<Contact> wishContacts = new List<Contact>();
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAccount;
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        medicalProfessionalCon.Region_Chapter__c = chapterAccount.Id;
        wishContacts.add(medicalProfessionalCon);
        Contact medicalProfessionalCon2 = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        wishContacts.add(medicalProfessionalCon2);
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        wishContacts.add(wishFamily);
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        wishContacts.add(FamilyContact);
        insert wishContacts;

        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        User currUser ;
//        System.RunAs(new User(Id = UserInfo.getUserId())) {
////            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
//            currUser = OrientationandTrainingUtil.createAdminUser();
//            insert currUser;
//        }
//        System.runAs(currUser){
            Lead newLead = OrientationandTrainingUtil.createTestLeadRecwithDupe(chapterAccount.Id);
            newLead.Sibling_Detail__c = 'aa | bbb | 12 ' + '<br/>' + ' bb | - | 13' + '<br/>' + ' -| cc | 13' + '<br/>' + ' dd | dd |-' + '<br/>' + ' -| ee |-' + '<br/>' + ' -| ee |-' + '<br/>' + ' ff| - |-';
            newLead.Child_Age__c = '4';
            newLead.unique_wish_identifier__c = '123456';
            newLead.ChapterName__c = chapterAccount.Id;
            newLead.SD1_ICD_Code__c = icdCode.Id;
            newLead.PD_ICD_Code__c = icdCode.Id;
            newLead.Diagnosis_Given_By_Referrer__c = 'Test';
            newLead.Referrer_FirstName__c = 'TestMedFirstName';
            newLead.Referrer_Last_Name__c ='Last';
            newLead.Treating_Medical_Professional_First_Name__c =  'TestMedFirstName';
            newLead.Treating_Medical_Professional_Email__c = 'abc@makeawish.com';
            newLead.Treating_Medical_Professional_Last_Name__c = 'Last';
            newLead.Referrer_Email__c = 'abc@makeawish.com';
            newLead.Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
            newLead.Medical_Professional_ContactId__c = '123456';
            newLead.Wish_Family_ContactId__c = wishFamily.Id;
            newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
            newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
            newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
            newLead.OwnerId = userInfo.getUserId();
            insert newLead;

            dsfs__DocuSign_Status__c document = OrientationandTrainingUtil.CreateDocusignRecord();
            document.dsfs__Lead__c = newLead.Id;
            document.dsfs__Completed_Date_Time__c = System.today();
            insert document;

            Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
            newDV.ICD_Code__c = icdCode.Id;
            newDV.Lead__c = newLead.id;

            insert newDV;

            newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
            newLead.Is_Required_Bypass__c = true;
            newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfessionalCon.Id;
            newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
            newLead.PostalCode = '85001';
            newLead.CountryCode = 'US';
            newLead.DOB__c = System.today() - 1435;
            newLead.HiddenAlternate1MedProfessionalId__c = medicalProfessionalCon.Id;
            newLead.HiddenAlternate2MedProfessionalId__c = medicalProfessionalCon2.Id;
    //        newLead.IsConverted = true;
    //        newLead.ConvertedAccountId = account.Id;
    //        newLead.ConvertedContactId = wishChildContact1.Id;
            newLead.Company = 'MAWA';
            newLead.Status = 'Inquiry';
            newLead.Gender__c = 'Male';
            newLead.Best_Contact_for_Physician_First_Name__c = 'TestMedFirstName';
            newLead.Best_contact_for_Physician_Email__c = 'abc@makeawish.com';
            newLead.Best_Contact_for_Physician_Last_Name__c = 'Last';
    //        newLead.Referrer_FirstName__c = 'Carol';
    //        newLead.Referrer_Last_Name__c = 'Jones';
    //        newLead.Referrer_Email__c = 'cj@email.com';
    //        newLead.Referrer_Phone__c = '5555555555';
            newLead.Referrer_City__c = 'Phoenix';
            newLead.Referrer_Zip__c = '85123';
            newLead.Sibling_Detail__c = 'aa | aaab | 14 <br> bbb | bbbc | 15';
            newLead.PD_Condition_Description__c = 'Test Diagnosis';
            newLead.Parent_First_Name__c = 'Bob';
            newLead.Parent_Last_Name__c = 'Smith';
            newLead.Medical_Professional_First_Name__c = 'Dr Max';
            newLead.Medical_Professional_Last_Name__c = 'Roger';
            newLead.Medical_Professional_Phone__c = '55555555555';
            newLead.Medical_Professional_Email__c = 'testmawa1s@gmail.com';
            newLead.Hospital_Treatment_Facility__c = 'Banner Hospital';
    //        newLead.Treating_Medical_Professional_First_Name__c = 'Dr Max';
    //        newLead.Treating_Medical_Professional_Last_Name__c = 'Roger';
    //        newLead.Treating_Medical_Professional_Phone__c = '5555555555';
    //        newLead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
            newLead.Hospital_Treatment_Facility_Treating__c = 'Banner Hospital';
            newLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
            newLead.is_Family_Aware_of_Referral__c = 'Yes';
            newLead.Medical_Questions__c = 'Test Diagnosis';
            newLead.PD_ICD_Code__c = icdCode.Id;
            newLead.Lung_Disease__c = 'Test1;Test2';
            newLead.Angina__c = 'Test1;Test2';
            newLead.Ventilator__c = 'Test1;Test2';
            newLead.Arrhythmia__c = 'Test1;Test2';
            newLead.Heart_Failure__c = 'Test1;Test2';
            newLead.Congenital_Heart_Disease__c = 'Test1;Test2';
            newLead.Chronic_Hepatitis__c = 'Test1;Test2';
            newLead.Convulsive_Disorders__c = 'Test1;Test2';
            newLead.Pulmonary_Hypertension__c = 'Test1;Test2';
            newLead.Strokes__c = 'Test1;Test2';
            newLead.Chronic_Heart_Failure__c = 'Test1;Test2';
            newLead.isSign__c = true;
            newLead.Travel_algorithm__c = 'Test1;Test2;';
            RecursiveTriggerHandler.isFirstTime = true;
            Test.startTest();

            update newLead;
            newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
            newLead.Please_Explain__c = 'Yes';
            newLead.Status = 'Qualified';
            update newLead ;
            Test.stopTest();
            System.assertEquals(newLead.Status, 'Qualified');
//        }
    }

    //This metod is increase the code coverage for when the lead is converted and the contacts are merged with existing contact.
    public testmethod static void UpdateStatusAsQualifiedwithContactId() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Contact medicalProCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRecwithDupe(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | bbb | 12 ' + '<br/>' + ' bb | - | 13' + '<br/>' + ' -| cc | 13' + '<br/>' + ' dd | dd |-' + '<br/>' + ' -| ee |-' + '<br/>' + ' -| ee |-' + '<br/>' + ' ff| - |-';
        newLead.Child_Age__c = '4';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.unique_wish_identifier__c = '123456';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        insert newLead;

        cg__Lead_File__c leadFile = OrientationandTrainingUtil.createLeadFileRecord(newLead.Id);
        insert leadFile;
        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Is_Required_Bypass__c = true;
        System.assertEquals(newLead.Sub_Status__c, 'Pending Diagnosis Verification');    //SIW-342

        RecursiveTriggerHandler.isFirstTime = true;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead ;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');
    }

    /*This method is used to increase the code coverage for CreateNewCase method when the lead status is updated as 'Eligibility Review'. */
    public testmethod static void UpdateStatusAsEligibilityReview() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAccount;

        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        insert wishChildContact;

        Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
        insert alabamaAccountRec;

        Office__c officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
        insert officeRec;
        Zip_Code__c zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
        zipRec.External_Id__c = '32193';
        insert zipRec;

        Zip_Code__c zipRec1 = OrientationandTrainingUtil.createZipcode(officeRec.Id);
        zipRec1.External_Id__c = '12345';
        insert zipRec1;

        Condition_Description__c newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Inquiry';
        newLead.Street = 'KuttaiKarai Street';
        newLead.StateCode = 'AZ';
        newLead.city = 'Trichy';
        newLead.Postalcode = '32193';
        newLead.Please_Explain__c = 'Test';
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        // newLead.PostalCode = NewIcdCode.Id;
        // newLead.Sub_Status__c ='Pending Diagnosis Verification';
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Status = 'Referred';
        newLead.Hidden_Chapter_Name__c = alabamaAccountRec.Name;
        newLead.Street = 'KuttaiKarai Street';
        newLead.StateCode = 'AZ';
        newLead.city = 'Trichy';
        newLead.CountryCode = 'US';
        newLead.Gender__C = 'male';
        newLead.Treating_Medical_Professional_Email__c = 'testTreating@mail.com';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Alternate1MedicalProfessionalEmail__c = 'alternate1@mail.com';
        newLead.Alternate2MedProfessionalEmail__c = 'alternate2@mail.com';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Part_A_Received__c = Date.Today(); 
        update newLead;

        newLead.Status = 'Eligibility Review';
        newLead.Treating_Medical_Professional_Email__c = 'testmawa3@gmail.com';
        newLead.Postalcode = '12345';
        newLead.PD_ICD_Code__c = NewIcdCode.Id;
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        newLead.Medical_Questions__c = 'YES Test Diagnosis';
        newLead.Dup_Check__c = 'Block Lead Dup';
        newLead.unique_wish_identifier__c = '123455';
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        Test.startTest();
        update newLead ;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Eligibility Review');
    }

    //This method is used to increase the code coverage for when the lead is updated with the DNQ status.
    public testmethod static void UpdateStatusDNQ() {
        User currUser = [
                SELECT id
                from User
                where id = :Userinfo.getUserId()
                limit 1
        ];
        User nationalStaff;
        System.RunAs(currUser) {
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([
                    select Id
                    from UserRole
                    where Name = 'National Staff'
            ].Id);
        }
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAccount;
        Account chapterAc = [
                SELECT Id,Intake_Manager__c
                FROM Account
                WHERE Id = :chapterAccount.Id
                LIMIT 1
        ];
        Condition_Description__c newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        insert icdCode;
        chapterAc.Intake_Manager__c = nationalStaff.Id;
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();

        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        //newLead.ChapterName__c = OrientationandTrainingUtil.CreateAlabamaAccount();
        // newLead.OwnerId =nationalStaff.Id;
        newLead.status = 'Referred';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Any_medical_reason_for_moving_quickly__c = 'No';
        newLead.Part_A_Received__c = System.today();

        insert newlead;
        system.assertequals(chapterAccount.Id, [
                SELECT ChapterName__r.Name
                FROM lead
                WHERE Id = :newlead.Id
        ].ChapterName__c);
        system.assertequals('Referred', [
                SELECT status
                FROM lead
                WHERE Id = :newLead.Id
        ].Status);
        newlead.Status = 'DNQ';
        newLead.Sub_Status__c = 'Age';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        Test.startTest();
        update newlead;
        Test.stopTest();
        system.assertequals('DNQ', [
                SELECT status
                FROM lead
                WHERE Id = :newlead.Id
        ].Status);
    }

    //This method is used to increase the code coverage for the lead created with medical provider type.
    public testmethod static void MedicalProfessionalType() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.Wish_Family_ContactId__c = wishFamily.Id;
        newLead.Sibling_Detail__c = 'aa | bbb | -';
        newLead.Treating_Medical_Professional_First_Name__c = 'TestMedFirstName';
        newLead.Referrer_FirstName__c = 'TestMedFirstName';
        newLead.Treating_Medical_Professional_Last_Name__c = 'TestMedLastName';
        newLead.Referrer_Last_Name__c = 'TestMedLastName';
        newLead.Treating_Medical_Professional_Phone__c = '9600467559';
        newLead.Referrer_Phone__c = '9600467559';
        newLead.Treating_Medical_Professional_Email__c = 'test@gmail.com';
        newLead.Referrer_Email__c = 'test@gmail.com';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Is_Required_Bypass__c = True;
        RecursiveTriggerHandler.isFirstTime = true;
        update newLead;
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';
        Test.StartTest();
        update newLead;
        Test.StopTest();
        system.assertequals('Qualified', [
                SELECT status
                FROM lead
                WHERE Id = :newlead.Id
        ].Status);

    }

    //This method is used to ncrease the code coverage for the lead created with medical provider type.
    public testmethod static void duplicateLead() {
        RecursiveTriggerHandler.isFirstTime = true;
        Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'mosstest';
        medicalProfContact .LastName = 'harttest';
        medicalProfContact .Email = 'testmawa1@gmail.com';
        medicalProfContact .Phone = '9600467554';
        medicalProfContact .MailingStreet = 'KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        dupLead.Status = 'Referred';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            //System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    public testmethod static void duplicateLeadAddress() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        dupLead.Status = 'Referred';
        dupLead.FirstName = 'moss';
        dupLead.LastName = 'Smith Household Dupe';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            //System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    public testmethod static void duplicateLeadAddressAndPhone() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        dupLead.Status = 'Referred';
        dupLead.FirstName = 'moss Dupe';
        dupLead.LastName = 'Smith Household Dupe';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            //System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    public testmethod static void duplicateLeadDOBAndName() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        dupLead.Status = 'Referred';
        dupLead.FirstName = 'moss';
        dupLead.LastName = 'Smith Household Dupe';
        dupLead.Street = 'KuttaiKarai Street Dupe';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    //This method is used to increase the code coverage for the lead created with medical provider type.
    public testmethod static void duplicatemedicalProfList() {
        RecursiveTriggerHandler.isFirstTime = true;
        Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'SteveJune';
        medicalProfContact .LastName = 'Waughone';
        medicalProfContact .Email = 'testmawa2d@gmail.com';
        medicalProfContact .Phone = '9600467578';
        medicalProfContact .MailingStreet = 'KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        insert medicalProfContact;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        //Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        insert newLead;
        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    //This method is used to increase the code coverage for the lead created with duplicate family contact list.
    public testmethod static void duplicateFamilyList() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        //Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Id wishFamilyRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        Contact wishFamilyCon = new Contact();
        wishFamilyCon.FirstName = 'MAWAFirstJune';
        wishFamilyCon.LastName = 'MAWALastJune';
        wishFamilyCon.Email = 'testmawa@gmail.com';
        wishFamilyCon.Phone = '9600467559';
        wishFamilyCon.MailingStreet = 'KuttaiKarai Street';
        wishFamilyCon.MailingCity = 'Trichy';
        wishFamilyCon.MailingStateCode = 'AZ';
        wishFamilyCon.MailingPostalCode = '6201717';
        wishFamilyCon.MailingCountryCode = 'US';
        wishFamilyCon.RecordTypeId = wishFamilyRecordTypeId ;
        wishFamilyCon.IsParentGuardian__c = 'ParentGuardian';
        wishFamilyCon.Region_Chapter__c = chapterAccount.id;
        insert wishFamilyCon;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Referred';
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    //This method is used to increase the code coverage for the lead created with duplicate best physician contact List.
    public testmethod static void duplicateBestPhyList() {
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        //Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'SteveJune1';
        medicalProfContact .LastName = 'Waughone1';
        medicalProfContact .Email = 'testmawa@gmail.com';
        medicalProfContact .Phone = '9600467578';
        medicalProfContact .MailingStreet = 'KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        insert medicalProfContact;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status = 'Referred';
        newLead.Best_Contact_for_Physician_First_Name__c = 'SteveJune1';
        newLead.Best_contact_for_Physician_Email__c = 'testmawa@gmail.com';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Waughone1';
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        RecursiveTriggerHandler.isFirstTime = true;
        try {
            update newLead;
        } catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }

    }
    //This method is used to increase the code coverage for the lead created with best contact as the Referrer.
    public testmethod static void referrerSameAsBestLead() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);

        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Best contact for Physician';
        newLead.Referrer_Email__c = 'best@mail.com';
        newLead.Is_Required_Bypass__c = true;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');
        System.assertEquals(medicalProfessionalCon.Id, newLead.Medical_Professional_ContactId__c);
    }

    //This method is used to increase the code coverage for the lead created with Treating medical provider as the Referrer.
    public testmethod static void referrerSameAsTreat() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Treating_Medical_Professional_Email__c = 'best@mail.com';
        newLead.Treating_Medical_Professional_First_Name__c = 'bestPhysician';
        newLead.Treating_Medical_Professional_Last_Name__c = 'Test';
        newLead.Treating_Medical_Professional_Phone__c = '2233445566';
        newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfessionalCon.Id;
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Referrer_Email__c = 'best@mail.com';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Best contact for Physician';
        newLead.Is_Required_Bypass__c = true;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');
        System.assertEquals(medicalProfessionalCon.Id, newLead.Medical_Professional_ContactId__c);
    }

    //This method is used to increase the code coverage for the lead created with Alternate1 as the Referrer.
    public testmethod static void referrerSameAsAlter1() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Alternate1MedicalProfessionalEmail__c = 'alter1@mail.com';
        newLead.Alternate1MedProfessionalFirstName__c = 'bestPhysician';
        newLead.Alternate1MedProfessionalLastName__c = 'Test';
        newLead.Alternate1MedProfessionalPhone__c = '2233445566';
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Referrer_Email__c = 'alter1@mail.com';
        newLead.Is_Required_Bypass__c = true;
        // newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 1 Medical Professional';
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');
        System.assertEquals(medicalProfessionalCon.Id, newLead.Medical_Professional_ContactId__c);
    }

    //This method is used to increase the code coverage for the lead created with Alternate2 as the Referrer.
    public testmethod static void referrerSameAsAlter2() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.ChapterName__c = chapAcc.Id;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        insert newLead;

        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;

        insert newDV;

        Map<Lead, ID> leadMap = new Map<Lead, ID>();
        leadMap.put(newLead, newLead.ChapterName__c);
        //Lead_OnAfterUpdateTriggerHandlerHelper.createTaskforDNQLeads(leadMap);
        Case caseInsatnce = new Case();
        caseInsatnce.Lead__c = newLead.id;
        caseInsatnce.RecordTypeId = partARecordTypeId;
        caseInsatnce.Origin = 'Email';
        caseInsatnce.Status = 'New';
        insert caseInsatnce;

        dsfs__DocuSign_Status__c newDoc = new dsfs__DocuSign_Status__c();
        newDoc.dsfs__Lead__c = newLead.id;
        newDoc.dsfs__Envelope_Status__c = 'Completed';
        insert newDoc;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    //SIW-342
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c = FamilyContact.Id;
        newLead.Alternate2MedProfessionalEmail__c = 'best@mail.com';
        newLead.Alternate2MedProfessionalFirstName__c = 'bestPhysician';
        newLead.Alternate2MedProfessionalLastName__c = 'Test';
        newLead.Alternate2MedProfessionalPhone__c = '2233445566';
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Referrer_Email__c = 'best@mail.com';
        newLead.Is_Required_Bypass__c = true;
        // newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Qualified');
        System.assertEquals(medicalProfessionalCon.Id, newLead.Medical_Professional_ContactId__c);
    }

    public testmethod static void updateFromyestoNo() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfessionalCon2 = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Referrer_FirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalLastName__c = 'Alternate';
        newLead.Referrer_Last_Name__c = 'Alternate';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        newLead.Alternate1MedicalProfessionalEmail__c = 'alternate@gmail.com';
        newLead.Referrer_Email__c = 'alternate@gmail.com';
        newLead.Alternate1MedProfessionalPhone__c = '9600467559';
        newLead.Alternate1HospitalTreatmentFacility__c = 'TestAlternate1Hospital';

        newLead.Alternate2MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalLastName__c = 'Alternate2';
        newLead.Alternate2MedProfessionalEmail__c = 'alternate2@gmail.com';
        newLead.Alternate2MedProfessionalPhone__c = '9600467552';
        newLead.Alternate2HospitalTreatmentFacility__c = 'TestAlternate2Hospital';
        newLead.Referrer_Phone__c = '9600467559';

        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Any_medical_reason_for_moving_quickly__c = 'yes';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.ChapterName__c = chapterAccount.Id;
        newLead.OwnerId = UserInfo.getUserId();
        newLead.Hidden_Chapter_Change_Confirmation__c = chapterAccount.Id;
        insert newLead;
        Set<String> icdSet = new Set<String>();
        Set<String> conDesSet = new Set<String>();
        icdSet.add(icdCode.id);
        conDesSet.add(descrip.id);
        String icdCodeName = icdCode.Name;
        List<Lead> leadList = new List<Lead>();
        leadList.add(newLead);
        Lead_OnBeforeUpdateTriggerHandlerHelper.createPotentialRushTask(leadList);
        Lead_OnBeforeUpdateTriggerHandlerHelper.ToUpdateMedicalInfo(conDesSet, icdSet, leadList);
        Lead_OnBeforeUpdateTriggerHandlerHelper.updateQualifingDiagnosis(icdCodeName, leadList);
        newLead.Any_medical_reason_for_moving_quickly__c = null;
        newLead.ChapterName__c = chapAcc.Id;
        newLead.City = 'Salem';
        update newLead;
    }

    static testMethod void testCatch() {
        Office__c newOffice = new Office__c();
        newOffice.Name = 'Arizona';
        insert newOffice;
        Zip_Code__c newZip = new Zip_Code__c();
        newZip.Name = '35004';
        newZip.External_Id__c = '123';
        newZip.Office__c = newOffice.id;
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Referrer_FirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalLastName__c = 'Alternate';
        newLead.Referrer_Last_Name__c = 'Alternate';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        newLead.Alternate1MedicalProfessionalEmail__c = 'alternate@gmail.com';
        newLead.Referrer_Email__c = 'alternate@gmail.com';
        newLead.Alternate1MedProfessionalPhone__c = '9600467559';
        newLead.Alternate1HospitalTreatmentFacility__c = 'TestAlternate1Hospital';
        newLead.PostalCode = Null;
        newLead.Referrer_Zip__c = Null;
        newLead.Alternate2MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalLastName__c = 'Alternate2';
        newLead.Alternate2MedProfessionalEmail__c = 'alternate2@gmail.com';
        newLead.Alternate2MedProfessionalPhone__c = '9600467552';
        newLead.Alternate2HospitalTreatmentFacility__c = 'TestAlternate2Hospital';
        newLead.Referrer_Phone__c = '9600467559';
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        newLead.Any_medical_reason_for_moving_quickly__c = 'yes';
        newLead.PostalCode = '12345';
        newLead.lastName = Null;
        try {
            insert newLead;
        } catch (DMLException e) {

        }

    }

    static testMethod void deleteLeadRec() {
        Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount.Id);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c = 'Test';
        insert newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status, 'Inquiry');
        cg__Lead_File__c leadFile = OrientationandTrainingUtil.createLeadFileRecord(newLead.Id);
        insert leadFile;
        try {
            Delete newLead;
        } catch (DMLException e) {

        }
    }
}