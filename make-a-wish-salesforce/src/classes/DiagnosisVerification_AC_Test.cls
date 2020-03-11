/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : This DiagnosisVerification_AC_Test is used to cover the unit testing for DiagnosisVerification_AC.
Modification Log:
23/03/2018 - Sankar - WVC-1835
09/10/2019 - Manik - WLP-423
01/02/2020 - CSmith - SIW-342 field name changes reverted.
*******************************************************************************************************************/
@isTest
public class DiagnosisVerification_AC_Test {
    @testSetup
    //This method is used to update the wish child and wish family.
    public static void setUpData() {
        Condition_Description__c condistionDescription = OrientationandTrainingUtil.createConditionDesCription();
        condistionDescription.Not_Listed__c = condistionDescription.InActive__c = true;
        insert condistionDescription;

        ICD_Codes__c iCDCode = OrientationandTrainingUtil.createICDCode(condistionDescription.Id);
        insert iCDCode;

        List<Medical_Questions__c> medicalQuestion = OrientationandTrainingUtil.CreateMedicalQuestion(condistionDescription.Id);
        insert medicalQuestion;

        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAccount;

        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.PD_ICD_Code__c = iCDCode.Id;
        newLead.Communication__c = 'rec1;rec2';
        //newLead.Travel_Restriction__c = 'Test1;Test2;Test3;';
        newLead.Current_Condition_Label__c = 'Test1;Test2;Test3;';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        newLead.unique_wish_identifier__c = '059-17-12367';
        insert newLead;

        WishChildWrapper wc = new WishChildWrapper();
        wc.describePatient = 'Yes';
        wc.password = '123456';
        wc.getStateRecognizationPicklistValues();
        wc.getCommunications();
        wc.getHealthCareWorks();

        cg__Lead_File__c newFile = new cg__Lead_File__c();
        newFile.cg__Lead__c = newLead.Id;
        newFile.cg__Description__c = 'SampleDesc';
        newFile.File_Path__c = 'TestPath';
        newFile.cg__File_Name__c = 'File';
        insert newFile;

        DocuSignCredentialsSetting__c setting = new DocuSignCredentialsSetting__c();
        setting.Name = 'Test Setting';
        setting.account__c = 'TestAccount';
        insert setting;

        dsfs__DocuSign_Status__c newStatus = new dsfs__DocuSign_Status__c(dsfs__Lead__c = newLead.Id, dsfs__Subject__c = 'Diagnosis Verification Form');
        insert newStatus;
//        System.assertEquals(newLead.Id, newFile.Parent__c, 'Id dose nit match');
//        System.assert(newLead.Id == newFile.Parent__c, 'value does not match');
    }

    //This method is used to check the validate primary diagnosis in DV form.
    public static testmethod void checkDiadnosisVerificationFormForValidDiagnosisAtPrimaryDiagnosis() {
        Lead newLead = [
            SELECT ID
            FROM Lead
            LIMIT 50000
        ];
        newLead.Treatment_may_be_feasible_but_can_fail__c = true;
        update newLead;

        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator());
        currDiagnosisVerificationDupe.wishChildWrapperIns.medProfTypeHid = 'Treating Medical Professional';
        currDiagnosisVerificationDupe.SubmitSign();
        currDiagnosisVerificationDupe.wishChildWrapperIns.medProfTypeHid = 'Best contact for Physician';
        currDiagnosisVerificationDupe.SubmitSign();
        currDiagnosisVerificationDupe.wishChildWrapperIns.medProfTypeHid = 'Alternate 1 Medical Professional';
        currDiagnosisVerificationDupe.SubmitSign();
        currDiagnosisVerificationDupe.wishChildWrapperIns.medProfTypeHid = 'Alternate 2 Medical Professional';
        currDiagnosisVerificationDupe.SubmitSign();
        DiagnosisWrapper dw = new DiagnosisWrapper();
        dw.conditionDescription = 'ss';
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        condistionDescription.isEligible__c = true;
        update condistionDescription;
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
//      currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'Yes';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        Test.stopTest();
    }

    //This method is used to check the invalidate primary diagnosis in DV form.
    public static testmethod void checkDiadnosisVerificationFormForInValidDiagnosisAtPrimaryDiagnosis() {
        Lead newLead = [
            SELECT ID
            FROM Lead
            LIMIT 50000
        ];
        newLead.Treatment_may_prolong_normal_activities__c = true;
        update newLead;

        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '5'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('collectedConditionValue', 'test1;test2');
        ApexPages.currentPage().getParameters().put('uniqueCurrentConditionSet', 'test3');
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        Test.stopTest();
        System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'Id dose nit match');
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode);
    }
    //This method is used to check the validate secondary diagnosis in DV form.
    public static testmethod void checkDiadnosisVerificationFormWithSecondaryDiagnosis() {
        Lead newLead = [
            SELECT ID
            FROM Lead
            LIMIT 50000
        ];
        newLead.Debilitation_may_extend_over_many_years__c = true;
        update newLead;

        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].isEligible = true;
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.changeWishStatus();
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.addDiagnosisVerification();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'ICD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'Yes';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('medicalResponse', null); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '6'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[2].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[3].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[4].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[5].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[6].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = 'A00';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = 'A00';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[2].iCDCode = 'A00';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[3].iCDCode = 'A00';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[4].iCDCode = 'A00';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[5].iCDCode = 'A00';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[6].medicalWrapperList[0].isEligible = true;
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        Test.stopTest();
//      System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode, 'Id dose nit match');
//      System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode, 'value does not match');
    }
    //This method is used to check the remove diagnosis in DV form.
    public static testmethod void checkDiadnosisVerificationFormRemoveDiagnosisFunction() {
        Lead newLead = [
            SELECT ID
            FROM Lead
            LIMIT 50000
        ];
        newLead.Increased_probability_of_premature_death__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.addDiagnosisVerification();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'ICD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'Yes';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        currDiagnosisVerificationDupe.RemoveDiagnosisBlock();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        Test.stopTest();
        System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'Value does not match');
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'value does not match');
    }
    //This method is used to check the diagnosis verification in DV form.
    public static testmethod void checkDiadnosisVerificationFormWithDiagnosisVerficationData() {
        Lead newLead = [
            SELECT ID
            FROM Lead
        ];
        newLead.Risk_of_complications_premature_death__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.addDiagnosisVerification();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'ICD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'Yes';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        PageReference pageRefUpdate = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRefUpdate);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupeUpdated = new DiagnosisVerification_AC();
        List<Condition_Description__c> conditionDescriptionLst = DiagnosisVerification_AC.searchCondition('Mali');
        List<ICD_Codes__c> iCDCodeLst = DiagnosisVerification_AC.searchDiagnosis('C43.30');
        List<ICD_Codes__c> iCDCodeLst1 = DiagnosisVerification_AC.searchDiagnosis(NULL);
        Test.stopTest();
        System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode, 'Value does not match');
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode, 'value does not match');
    }
    //This method is used to check the diagnosis verification with medical question in DV form.
    public static testmethod void checkDiadnosisVerificationFormWithDiagnosisVerficationDataandMedicalQuestion() {
        Lead newLead = [
            SELECT ID
            FROM Lead
        ];
        newLead.Responds_to_treatment_with_normal_health__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[1].epilepsySelectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '1');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        currDiagnosisVerificationDupe.deleteLeadFile();
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        PageReference pageRefUpdate = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRefUpdate);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupeUpdated = new DiagnosisVerification_AC();
        Test.stopTest();
        System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'Value does not match');
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'value does not match');
    }
    //This method is used to check the diagnosis verification without medical question in DV form.
    public static testmethod void checkDiadnosisVerificationFormWithDiagnosisVerficationDataandWithoutMedicalQuestion() {
        List<Medical_Questions__c> medicalQuestion = [
            SELECT Id
            FROM Medical_Questions__c
            LIMIT 50000
        ];
        //medicalQuestion.clear();
        Lead newLead = [
            SELECT ID
            FROM Lead
        ];
        newLead.None_of_these_statements_describes_Child__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        condistionDescription.Name = 'Arteriovenus Malformation (AVM)';
        update condistionDescription;
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[1].epilepsySelectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '1');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        currDiagnosisVerificationDupe.deleteLeadFile();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = Null;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = Null;
        currDiagnosisVerificationDupe.ResetDiagnosis();
        currDiagnosisVerificationDupe.changePatientValue();
        currDiagnosisVerificationDupe.submit();
        currDiagnosisVerificationDupe.MedicalQuestions(null, null, false, null, 0, medicalQuestion, false);
        currDiagnosisVerificationDupe.MedicalQuestions(null, null, true, null, 0, medicalQuestion, false);
        currDiagnosisVerificationDupe.MedicalQuestions(null, null, true, null, 0, medicalQuestion, true);
        currDiagnosisVerificationDupe.MedicalQuestions(null, null, false, null, 0, medicalQuestion, true);
        currDiagnosisVerificationDupe.MedicalQuestions(null, condistionDescription.Id, false, null, 0, medicalQuestion, false);
        currDiagnosisVerificationDupe.MedicalQuestions(null, condistionDescription.Id, true, null, 0, medicalQuestion, false);
        currDiagnosisVerificationDupe.MedicalQuestions(null, condistionDescription.Id, true, null, 0, medicalQuestion, true);
        currDiagnosisVerificationDupe.MedicalQuestions(null, condistionDescription.Id, false, null, 0, medicalQuestion, true);
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        PageReference pageRefUpdate = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRefUpdate);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupeUpdated = new DiagnosisVerification_AC();
        TravelAlgorithmWrapper pw = new TravelAlgorithmWrapper();
        pw.getchronicHeartFailureList();
        pw.getcongenitalHeartDiseaseList();
        pw.getconvulsiveDisorderList();
        pw.getStrokeValues();
        pw.getPulmonaryHypertensionValues();
        pw.getHepatitisValues();
        pw.getheartFailureList();
        pw.getArrhythmiaList();
        pw.getanginaList();
        pw.getventilatorList();
        pw.getLungDiseaseList();
        Test.stopTest();
        System.assertEquals(Null, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'Value does not match');
        System.assert(currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode == Null, 'value does not match');
    }

    //This method is used to check the diagnosis verification without medical question in DV form.
    public static testmethod void checkDiadnosisVerificationFormWithDiagnosisVerficationDataandWithoutMedicalQuestions() {
        List<Medical_Questions__c> medicalQuestion = [
            SELECT Id
            FROM Medical_Questions__c
            LIMIT 50000
        ];
        medicalQuestion.clear();
        Lead newLead = [
            SELECT ID
            FROM Lead
        ];
        //newLead.Increased_probability_of_premature_death__c = true;
        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 50000
        ];
        Diagnosis_Verification__c dia = OrientationandTrainingUtil.createDiagnosis(newLead.Id);
        insert dia;

        Medical_Questions__c medQues = new Medical_Questions__c();
        medQues.Question__c = 'Is [child\'s name] currently receiving or within one year of completing chemotherapy infusions or radiation treatment for this condition?';
        medQues.Data_Type__c = 'Picklist';
        medQues.Picklist_values__c = 'Yes,No';
        insert medQues;

        DiagnosisMedicalQuestions__c newMedicalQues = new DiagnosisMedicalQuestions__c();
        newMedicalQues.Diagnosis_Verification__c = dia.Id;
        newMedicalQues.Medical_Question__c = medQues.Id;
        insert newMedicalQues;

        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[1].epilepsySelectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '1');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        currDiagnosisVerificationDupe.deleteLeadFile();
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1'); // Used to hold the Diagnosis block number
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = Null;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = Null;
        currDiagnosisVerificationDupe.ResetDiagnosis();
        currDiagnosisVerificationDupe.changePatientValue();
        currDiagnosisVerificationDupe.currLead = new Lead(Part_A_Form_Password__c = 'Test');
        currDiagnosisVerificationDupe.wishChildWrapperIns.password = 'Test';
        currDiagnosisVerificationDupe.submit();
        currDiagnosisVerificationDupe.currLead = new Lead(Part_A_Form_Password__c = 'Test2');
        currDiagnosisVerificationDupe.submit();
        currDiagnosisVerificationDupe.MedicalQuestions(null, null, false, null, 0, null, false);
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        PageReference pageRefUpdate = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRefUpdate);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupeUpdated = new DiagnosisVerification_AC();
        TravelAlgorithmWrapper pw = new TravelAlgorithmWrapper();
        pw.getchronicHeartFailureList();
        pw.getcongenitalHeartDiseaseList();
        pw.getconvulsiveDisorderList();
        pw.getStrokeValues();
        pw.getPulmonaryHypertensionValues();
        pw.getHepatitisValues();
        pw.getheartFailureList();
        pw.getArrhythmiaList();
        pw.getanginaList();
        pw.getventilatorList();
        pw.getLungDiseaseList();
        Test.stopTest();
        // System.assertEquals(Null, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode,'Value does not match');
        // System.assert(currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode == Null,'value does not match');
    }

    public static testmethod void checkDiadnosisVerificationForm() {
        Lead newLead = [
            SELECT ID
            FROM Lead
            LIMIT 50000
        ];
        newLead.Child_will_ultimately_die_prematurely__c = true;
        newLead.Travel_algorithm__c = 'Some Condition';
        newLead.Hidden_Proto_Pulmonary_Hypertension__c = 'Tension';
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT ID,Name,Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 1
        ];
        Diagnosis_Verification__c dv = OrientationandTrainingUtil.createDiagnosisRec(newLead.Id, condistionDescription.Id);
        dv.PCD_ICD__c = 'ICD';
        insert dv;
        Medical_Questions__c mQuestion = [
            SELECT Id, Condition_Description__c,Question__c,Current_Condition__c,Recommendation_to_Chapter__c
            FROM Medical_Questions__c
            LIMIT 1
        ];
        mQuestion.Question__c = null;
        mQuestion.Current_Condition__c = 'Some Condition';
        mQuestion.Recommendation_to_Chapter__c = 'Some Recommendation';
        mQuestion.Data_Type__c = 'Comment box';
        update mQuestion;
        DiagnosisMedicalQuestions__c dvQuestion = new DiagnosisMedicalQuestions__c();
        dvQuestion.Medical_Question__c = mQuestion.Id;
        dvQuestion.Epilepsy_Value__c = 'Some epilepsy Value';
        dvQuestion.Medical_Question_Answer__c = '';
        dvQuestion.isEligible__c = true;
        dvQuestion.Comment__c = '';
        dvQuestion.Diagnosis_Verification__c = dv.Id;
        insert dvQuestion;
        Test.startTest();
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupe = new DiagnosisVerification_AC();
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('collectedConditionValue', 'test1;test2');
        ApexPages.currentPage().getParameters().put('uniqueCurrentConditionSet', 'test3');
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        List<Diagnosis_Verification__c> diagnosisVerificationLst = [
            SELECT ID,isEligible__c, (
                SELECT isEligible__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :newLead.Id
            LIMIT 50000
        ];
        Test.stopTest();
        System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'Id dose nit match');
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode);
    }
}