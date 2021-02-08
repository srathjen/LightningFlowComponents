/*****************************************************************************************************************
Created By : MST Solutions
Created Date : 11/27/2016
Description : This test class used to perform unit testing for the 'Docusign Page (LeadPartA Output PDF)'.

09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/

@isTest
public class PARTAPDF_Test {
  private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;

  @testSetup
  public static void setUpData() {
    trac_TriggerHandlerBase.blockTrigger = true;

    List<Condition_Description__c> conditionList = TestDataFactory.createConditionDescription(
      1
    );
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

    List<Medical_Questions__c> medicalQuestionList = TestDataFactory.createMedicalQuestions(
      1
    );
    Medical_Questions__c questionOne = medicalQuestionList.get(0);
    questionOne.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
    questionOne.Picklist_values__c = 'Yes,No';
    // questionOne.Data_Type__c = 'Picklist';
    questionOne.Wrapper_Variable__c = 'TestWrapper';
    questionOne.Current_Condition__c = 'TestCondition';
    questionOne.Recommendation_to_Chapter__c = 'None Apply';
    questionOne.Condition_Description__c = conditionMelanoma.Id;
    questionOne.Sort_Order__c = 1;
    insert medicalQuestionList;

    List<Account> accountList = TestDataFactory.createAccount(1);
    Account accountAzChapter = accountList.get(0);
    accountAzChapter.Name = 'Make-A-Wish Arizona';
    accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
    insert accountList;

    List<Lead> leadList = TestDataFactory.createLead(1);
    Lead leadDanielle = leadList.get(0);
    leadDanielle.ChapterName__c = accountAzChapter.Id;
    leadDanielle.FirstName = 'Danielle';
    leadDanielle.LastName = 'Dulsky';
    leadDanielle.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
    leadDanielle.PD_ICD_Code__c = icdMelanoma.Id;
    leadDanielle.Phone = '9600467559';
    leadDanielle.Email = 'testmawa@gmail.com';
    leadDanielle.Street = '100 Calle Street';
    leadDanielle.StateCode = 'AZ';
    leadDanielle.City = 'Scottsdale';
    leadDanielle.PostalCode = '85261';
    leadDanielle.CountryCode = 'US';
    leadDanielle.DOB__c = System.today() - 1435;
    leadDanielle.Company = 'MAW';
    leadDanielle.Status = 'Inquiry';
    leadDanielle.Gender__c = 'Female';
    leadDanielle.is_Family_Aware_of_Referral__c = 'Yes';
    leadDanielle.Referrer_FirstName__c = 'Bethany';
    leadDanielle.Referrer_Last_Name__c = 'Akers';
    leadDanielle.Referrer_Email__c = 'testmawa2d@gmail.com';
    leadDanielle.Referrer_Phone__c = '9600467578';
    leadDanielle.Referrer_City__c = 'Scottsdale';
    leadDanielle.Referrer_Zip__c = '85261';
    leadDanielle.Current_Condition_Label__c = 'Surgery in the past 3 months;I am not sure';
    leadDanielle.PD_Condition_Description__c = 'Malignant Melanoma';
    insert leadList;

    trac_TriggerHandlerBase.blockTrigger = false;
  }

  @isTest
  private static void validatePartAController() {
    Lead lead = [SELECT Id FROM Lead WHERE Name = 'Danielle Dulsky'];
    ApexPages.currentPage().getParameters().put('leadId', lead.Id);
    PARTAPDF controller = new PARTAPDF();
    controller.loadData();
    System.assert(
      controller.currentCondition.contains('Surgery in the past 3 months')
    );
  }
}
