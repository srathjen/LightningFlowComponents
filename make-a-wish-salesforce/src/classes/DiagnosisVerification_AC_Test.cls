/**
* Author      : MST Solutions
* Date        : 10/4/2016
* Description : This DiagnosisVerification_AC_Test is used to cover the unit testing for DiagnosisVerification_AC.
* Modification Log:
* 23/03/2018 - Sankar - WVC-1835
* 09/10/2019 - Manik - WLP-423
* 01/02/2020 - CSmith - SIW-342 field name changes reverted.
**/
@IsTest
public class DiagnosisVerification_AC_Test {
    
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    
    @TestSetup
    public static void setUpData() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Condition_Description__c> conditionList = TestDataFactory.createConditionDescription(1);
        Condition_Description__c conditionMelanoma = conditionList.get(0);
        conditionMelanoma.Name = 'Malignant Melanoma';
        conditionMelanoma.Treatment_Subspecialty__c = 'Oncology';
        conditionMelanoma.Code_To_Use__c = 'C43.30';
        conditionMelanoma.PR_Diagnosis__c = 'Malignant Melanoma';
        conditionMelanoma.Group1__c = true;
        conditionMelanoma.Not_Listed__c = true;
        conditionMelanoma.InActive__c = true;
        insert conditionList;
        
        List<ICD_Codes__c> icdCodeList = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdMelanoma = icdCodeList.get(0);
        icdMelanoma.Name = 'C43.30';
        icdMelanoma.Condition_Description__c = conditionMelanoma.Id;
        icdMelanoma.Group1__c = true;
        icdMelanoma.Short_Description__c = 'Malignant melanoma of unspecified part of face';
        icdMelanoma.Long_Description__c = 'Malignant melanoma of unspecified part of face';
        insert icdCodeList;
        
        List<Medical_Questions__c> medicalQuestionList = TestDataFactory.createMedicalQuestions(4);
        Medical_Questions__c questionOne = medicalQuestionList.get(0);
        questionOne.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
        questionOne.Picklist_values__c = 'Yes,No';
        questionOne.Data_Type__c = 'Picklist';
        questionOne.Wrapper_Variable__c = 'TestWrapperOne';
        questionOne.Current_Condition__c = 'TestConditionOne';
        questionOne.Recommendation_to_Chapter__c = 'None Apply';
        questionOne.Condition_Description__c = conditionMelanoma.Id;
        questionOne.Sort_Order__c = 1;
        Medical_Questions__c questionTwo = medicalQuestionList.get(1);
        questionTwo.Question__c = 'Is child currently receiving or within one year of completing chemotherapy infusions or radiation treatment for this condition?';
        questionTwo.Picklist_values__c = 'Yes,No';
        questionTwo.Data_Type__c = 'Picklist';
        questionTwo.Wrapper_Variable__c = 'TestWrapperTwo';
        questionTwo.Current_Condition__c = 'TestConditionTwo';
        questionTwo.Recommendation_to_Chapter__c = 'None Apply';
        questionTwo.Condition_Description__c = conditionMelanoma.Id;
        questionTwo.Sort_Order__c = 2;
        Medical_Questions__c questionThree = medicalQuestionList.get(2);
        questionThree.Question__c = 'Does child also have end organ damage?';
        questionThree.Picklist_values__c = 'Yes,No';
        questionThree.Data_Type__c = 'Picklist';
        questionThree.Wrapper_Variable__c = 'TestWrapperThree';
        questionThree.Current_Condition__c = 'TestConditionThree';
        questionThree.Recommendation_to_Chapter__c = 'None Apply';
        questionThree.Condition_Description__c = conditionMelanoma.Id;
        questionThree.Sort_Order__c = 3;
        Medical_Questions__c questionFour = medicalQuestionList.get(3);
        questionFour.Question__c = 'Does child suffer from epilepsy?';
        questionFour.Picklist_values__c = 'Yes,No';
        questionFour.Data_Type__c = 'Picklist';
        questionFour.Wrapper_Variable__c = 'TestWrapperFour';
        questionFour.Current_Condition__c = 'TestConditionFour';
        questionFour.Recommendation_to_Chapter__c = 'None Apply';
        questionFour.Epilepsy_picklist__c = 'Localization-related (focal) (partial) symptomatic epilepsy and epileptic syndromes with simple partial seizures,' + 
            ' Localization-related (focal) (partial) symptomatic epilepsy and epileptic syndromes with complex partial seizures,Generalized idiopathic epilepsy' +
            ' and epileptic syndromes,Lennox-Gastaut Syndrome,Epileptic Spasms,None of these describe child';
        questionFour.Condition_Description__c = conditionMelanoma.Id;
        questionFour.Sort_Order__c = 4;
        insert medicalQuestionList;
        
        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountMawa = accountList.get(0);
        accountMawa.Name = 'Make-A-Wish America';
        accountMawa.RecordTypeId = CHAPTER_RT_ID;
        insert accountList;
        
        List<Lead> leadList = TestDataFactory.createLead(1);
        Lead leadFrieda = leadList.get(0);
        leadFrieda.ChapterName__c = accountMawa.Id;
        leadFrieda.FirstName = 'Frieda';
        leadFrieda.LastName = 'Crowley';
        leadFrieda.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        leadFrieda.PD_ICD_Code__c = icdMelanoma.Id;
        leadFrieda.Phone = '9600467559';
        leadFrieda.Email = 'testmawa@gmail.com';
        leadFrieda.Street = '100 Mesa Avenue';
        leadFrieda.StateCode = 'AZ';
        leadFrieda.City = 'Scottsdale';
        leadFrieda.PostalCode = '85261';
        leadFrieda.CountryCode = 'US';
        leadFrieda.DOB__c = System.today() - 1435;
        leadFrieda.Company = 'MAW';
        leadFrieda.Status = 'Inquiry';
        leadFrieda.Gender__c = 'Female';
        leadFrieda.is_Family_Aware_of_Referral__c = 'Yes';
        leadFrieda.Referrer_FirstName__c = 'Alan';
        leadFrieda.Referrer_Last_Name__c = 'Lady';
        leadFrieda.Referrer_Email__c = 'testmawa2d@gmail.com';
        leadFrieda.Referrer_Phone__c = '9600467578';
        leadFrieda.Referrer_City__c = 'Scottsdale';
        leadFrieda.Referrer_Zip__c = '85261';
        leadFrieda.Current_Condition_Label__c = 'Surgery in the past 3 months;I am not sure';
        leadFrieda.PD_Condition_Description__c = 'Malignant Melanoma';
        leadFrieda.Communication__c = 'rec1;rec2';
        leadFrieda.unique_wish_identifier__c = '059-17-12367';
        leadFrieda.Chronic_Hepatitis__c = 'N/A';
        leadFrieda.Strokes__c = 'N/A';
        leadFrieda.Convulsive_Disorders__c = 'Epilepsy;Unknown';
        leadFrieda.Congenital_Heart_Disease__c = 'Unknown;N/A';
        leadFrieda.Chronic_Heart_Failure__c = 'Unknown;N/A';
        leadFrieda.Heart_Failure__c = 'Unknown;N/A';
        leadFrieda.Arrhythmia__c = 'Unknown;N/A';
        leadFrieda.Ventilator__c = 'N/A';
        leadFrieda.Angina__c = 'Unknown;N/A';
        leadFrieda.Lung_Disease__c = 'Unknown;N/A';
        insert leadList;
        
        List<cg__Lead_File__c> leadFileList = TestDataFactory.createLeadFile(1);
        cg__Lead_File__c leadFileFrieda = leadFileList.get(0);
        leadFileFrieda.cg__Lead__c = leadFrieda.Id;
        leadFileFrieda.cg__Description__c = 'Medical Information for Frieda Crowley';
        leadFileFrieda.File_Path__c = 'TestPath';
        insert leadFileList;
        
        List<Diagnosis_Verification__c> diagnosisVerificationList = TestDataFactory.createDiagnosisVerification(1);
        Diagnosis_Verification__c verificationFrieda = diagnosisVerificationList.get(0);
        verificationFrieda.ICD_Code__c = icdMelanoma.Id;
        verificationFrieda.Lead__c = leadFrieda.Id;
        verificationFrieda.Order__c = 2;
        verificationFrieda.Condition_Description__c = conditionMelanoma.Id;
        insert diagnosisVerificationList;
        
        DocuSignCredentialsSetting__c setting = new DocuSignCredentialsSetting__c();
        setting.Name = 'Test Setting';
        setting.account__c = 'TestAccount';
        insert setting;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void checkDiagnosisVerificationFormForValidDiagnosisAtPrimaryDiagnosis() {
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.Treatment_may_be_feasible_but_can_fail__c = true;
        update newLead;
        
        Condition_Description__c conditionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
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
        currDiagnosisVerificationDupe.wishChildWrapperIns.medProfTypeHid = 'Alternate Medical Professional Other';
        currDiagnosisVerificationDupe.SubmitSign();
        DiagnosisWrapper dw = new DiagnosisWrapper();
        dw.conditionDescription = 'ss';
        //Setting the Primary Diagnosis
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].conditionDescription = conditionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode = conditionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'PCD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        conditionDescription.isEligible__c = true;
        update conditionDescription;
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        //Answer for the Question
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes'); //Used to hold the Medical Question response
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0'); // Used to hold the Diagnosis block number
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        Test.stopTest();
        
        System.assert(conditionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode);
    }
    
    @IsTest
    public static void checkDiagnosisVerificationFormWithSecondaryDiagnosis() {
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.Debilitation_may_extend_over_many_years__c = true;
        update newLead;
        
        Condition_Description__c condistionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
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
        //Answer for the Question
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList = new List<DiagnosisWrapper.MedicalWrapper>();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'No';
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].isEligible = true;
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.changeWishStatus();
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.addDiagnosisVerification();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'ICD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList = new List<DiagnosisWrapper.MedicalWrapper>();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList.add(new DiagnosisWrapper.MedicalWrapper());
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].medicalWrapperList[0].selectedPickVal = 'Yes';
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('medicalResponse', null);
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '6');
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
        Test.stopTest();
        
        System.assert(currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode == 'A00');
    }
    
    @IsTest
    public static void checkDiagnosisVerificationFormRemoveDiagnosisFunction() {
        Integer countBeforeRemove;
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.Increased_probability_of_premature_death__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
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
        //Answer for the Question
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.addDiagnosisVerification();
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].conditionDescription = condistionDescription.Name;
        currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode = condistionDescription.Code_To_Use__c;
        ApexPages.currentPage().getParameters().put('icdOrPcd', 'ICD');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        currDiagnosisVerificationDupe.WishChildEligibilityCheck();
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        countBeforeRemove = currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.size();
        currDiagnosisVerificationDupe.RemoveDiagnosisBlock();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        Test.stopTest();
        
        System.assert(currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst.size() != countBeforeRemove);
    }
    
    @IsTest
    public static void checkDiagnosisVerificationFormWithDiagnosisVerficationData() {
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.Risk_of_complications_premature_death__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
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
        //Answer for the Question
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
        ApexPages.currentPage().getParameters().put('medicalResponse', 'Yes');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        
        PageReference pageRefUpdate = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRefUpdate);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupeUpdated = new DiagnosisVerification_AC();
        List<Condition_Description__c> conditionDescriptionLst = DiagnosisVerification_AC.searchCondition('Mali');
        List<ICD_Codes__c> iCDCodeLst = DiagnosisVerification_AC.searchDiagnosis('C43.30');
        List<ICD_Codes__c> iCDCodeLst1 = DiagnosisVerification_AC.searchDiagnosis(NULL);
        Test.stopTest();
        
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[1].iCDCode);
    }
    
    @IsTest
    public static void checkDiagnosisVerificationLeadFileDelete() {
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.Responds_to_treatment_with_normal_health__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
        ];
        
        cg__Lead_File__c leadFile = [
            SELECT Id 
            FROM cg__Lead_File__c 
            WHERE cg__Lead__c = :newLead.Id
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
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '1');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('attachmentId', leadFile.Id);
        currDiagnosisVerificationDupe.deleteLeadFile();
        PageReference pageRefUpdate = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRefUpdate);
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);
        DiagnosisVerification_AC currDiagnosisVerificationDupeUpdated = new DiagnosisVerification_AC();
        Test.stopTest();
        
        String errorMsg;
        try {
            cg__Lead_File__c leadFileUpdate = [
                SELECT Id 
                FROM cg__Lead_File__c 
                WHERE cg__Lead__c = :newLead.Id
            ];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }
        System.assert(errorMsg == 'List has no rows for assignment to SObject');
    }
    
    @IsTest
    public static void checkDiagnosisVerificationFormWithDiagnosisVerficationDataWithoutMedicalQuestion() {
        List<Medical_Questions__c> medicalQuestion = [
            SELECT Id
            FROM Medical_Questions__c
        ];
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.None_of_these_statements_describes_Child__c = true;
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT Id,Name,Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
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
        //Answer for the Question
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '1');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('collectedConditionValue', 'test1;test2');
        ApexPages.currentPage().getParameters().put('uniqueCurrentConditionSet', 'test3');
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
        
        System.assert(currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode == null, 'value does not match');
    }
    
    @IsTest
    public static void checkDiagnosisVerificationFormWithDiagnosisVerficationDataandWithoutMedicalQuestions() {
        List<Medical_Questions__c> medicalQuestion = [
            SELECT Id
            FROM Medical_Questions__c
        ];
        medicalQuestion.clear();
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        Condition_Description__c condistionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
        ];
        
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
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '1');
        currDiagnosisVerificationDupe.MedicalResponse();
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        currDiagnosisVerificationDupe.deleteLeadFile();
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '1');
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
        
        System.assert(currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].isEligible == false);
    }
    
    @IsTest
    public static void checkDiagnosisVerificationForm() {
        Lead newLead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Frieda Crowley'
        ];
        newLead.Child_will_ultimately_die_prematurely__c = true;
        newLead.Travel_algorithm__c = 'Some Condition';
        newLead.Hidden_Proto_Pulmonary_Hypertension__c = 'Tension';
        update newLead;
        Condition_Description__c condistionDescription = [
            SELECT Id, Name, Code_To_Use__c
            FROM Condition_Description__c
            LIMIT 1
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
        ApexPages.currentPage().getParameters().put('medicalResponse', 'No');
        ApexPages.currentPage().getParameters().put('diagnosisBlockNum', '0');
        ApexPages.currentPage().getParameters().put('questionNumber', '0');
        currDiagnosisVerificationDupe.MedicalResponse();
        ApexPages.currentPage().getParameters().put('collectedConditionValue', 'test1;test2');
        ApexPages.currentPage().getParameters().put('uniqueCurrentConditionSet', 'test3');
        currDiagnosisVerificationDupe.SaveMedicalInformation();
        Test.stopTest();
        System.assertEquals(condistionDescription.Code_To_Use__c, currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode, 'Id does not match');
        System.assert(condistionDescription.Code_To_Use__c == currDiagnosisVerificationDupe.diagnosisVerificationWrapperLst[0].iCDCode);
    }
}