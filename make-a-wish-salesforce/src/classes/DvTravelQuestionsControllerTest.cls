/**
 * @description Test class for DvTravelQuestionsController Class and it's inner class
 * @author Christopher Smith, Make-A-Wish America
 * @createdDeate 2/24/2021
 */

@isTest
private class DvTravelQuestionsControllerTest {
  @TestSetup
  static void setup() {
    trac_TriggerHandlerBase.blockTrigger = true;

    ICD_Codes__c icd = new ICD_Codes__c(Name = 'D83.4');
    upsert icd;

    List<Lead> testLeads = TestDataFactory.createLead(1);
    Lead wk = testLeads.get(0);
    wk.firstName = 'Timmy';
    wk.LastName = 'Smith';

    wk.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
    wk.Status = Constant_AC.LEAD_STATUS_REFERRED;
    wk.Parent_First_Name__c = 'Mom';
    wk.Parent_Last_Name__c = 'Smith';
    wk.Company = 'Make-A-Wish America';
    wk.dob__c = Date.Today().AddYears(-7);
    wk.is_Family_Aware_of_Referral__c = 'Yes';
    wk.PD_Condition_Description__c = 'Neoplasm';
    wk.Phone = '123456789';
    wk.Email = 'test@email.com';
    wk.Street = '123 Street';
    wk.City = 'Phoenix';
    wk.State = 'Arizona';
    wk.StateCode = 'AZ';
    wk.PostalCode = '8042000';
    wk.CountryCode = 'US';
    wk.gender__c = 'Male';
    wk.Treating_Medical_Professional_First_Name__c = 'Dr';
    wk.Treating_Medical_Professional_Last_Name__c = 'John';
    wk.Hospital_Treatment_Facility_Treating__c = 'Mercy';
    wk.ICD_Given_By_Referrer__c = icd.id;

    upsert wk;
    //necessary to update before setting substatus
    wk.sub_status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
    update wk;

    List<Medical_Questions__c> travRecs = TestDataFactory.createMedicalQuestions(
      2
    );
    travRecs[0].recordTypeId = Constant_AC.TRAVEL_ALGM_RT_ID;
    travRecs[0].current_condition__c = 'testCondition';
    travRecs[0].recommendation_to_chapter__c = '';
    travRecs[1].recordTypeId = Constant_AC.TRAVEL_ALGM_RT_ID;
    travRecs[1].current_condition__c = 'testOption';
    travRecs[1].recommendation_to_chapter__c = 'travelRestriction';
    upsert travRecs;
    trac_TriggerHandlerBase.blockTrigger = false;
  }

  @isTest
  private static void shouldMakeWrapperWithFalseValues() {
    test.startTest();

    Lead wk = [
      SELECT
        id,
        Lung_Disease__c,
        Pulmonary_Hypertension__c,
        Ventilator__c,
        Angina__c,
        Arrhythmia__c,
        Heart_Failure__c,
        Chronic_Heart_Failure__c,
        Congenital_Heart_Disease__c,
        Chronic_Hepatitis__c,
        Hidden_Proto_Pulmonary_Hypertension__c,
        Strokes__c,
        Convulsive_Disorders__c,
        Travel_Restriction__c,
        Current_Condition_Label__c,
        Travel_Algorithm__c
      FROM Lead
      WHERE
        sub_status__c = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
    ];

    DvTravelQuestionsController.TravelQuestionsWrapper wrapper = DvTravelQuestionsController.getTravelWrapperByLead(
      String.valueOf(wk.id)
    );
    System.AssertEquals(false, wrapper.isLungDisease);

    test.stopTest();
  }

  @isTest
  private static void shouldFillValuesOnLead() {
    test.startTest();
    Lead wk = [
      SELECT
        id,
        Lung_Disease__c,
        Pulmonary_Hypertension__c,
        Ventilator__c,
        Angina__c,
        Arrhythmia__c,
        Heart_Failure__c,
        Chronic_Heart_Failure__c,
        Congenital_Heart_Disease__c,
        Chronic_Hepatitis__c,
        Hidden_Proto_Pulmonary_Hypertension__c,
        Strokes__c,
        Convulsive_Disorders__c,
        Travel_Restriction__c,
        Current_Condition_Label__c,
        Travel_Algorithm__c
      FROM Lead
      WHERE
        sub_status__c = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
    ];
    wk.lung_disease__c = 'testOption';
    wk.Pulmonary_Hypertension__c = 'testOption';
    wk.Ventilator__c = 'testOption';
    wk.Angina__c = 'testOption';
    wk.arrhythmia__c = 'testOption';
    wk.Heart_Failure__c = 'testOption';
    wk.Chronic_Heart_Failure__c = 'testOption';
    wk.Congenital_Heart_Disease__c = 'testOption';
    wk.Chronic_Hepatitis__c = 'testOption';
    wk.Hidden_Proto_Pulmonary_Hypertension__c = 'testOption';
    wk.Strokes__c = 'testOption';
    wk.Convulsive_Disorders__c = 'testOption';
    wk.Travel_Algorithm__c = 'testOption';
    update wk;

    DvTravelQuestionsController.TravelQuestionsWrapper wrapper = DvTravelQuestionsController.getTravelWrapperByLead(
      String.valueOf(wk.id)
    );
    System.AssertEquals(true, wrapper.isLungDisease);

    DVTravelQuestionsController.saveTravelQuestionData(wrapper);

    wk = [
      SELECT
        id,
        Lung_Disease__c,
        Pulmonary_Hypertension__c,
        Ventilator__c,
        Angina__c,
        Arrhythmia__c,
        Heart_Failure__c,
        Chronic_Heart_Failure__c,
        Congenital_Heart_Disease__c,
        Chronic_Hepatitis__c,
        Hidden_Proto_Pulmonary_Hypertension__c,
        Strokes__c,
        Convulsive_Disorders__c,
        Travel_Restriction__c,
        Current_Condition_Label__c,
        Travel_Algorithm__c
      FROM Lead
      WHERE
        sub_status__c = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
    ];
    System.AssertNotEquals(null, wk.Current_Condition_Label__c);
    System.AssertNotEquals(null, wk.Travel_Restriction__c);

    test.stopTest();
  }

  @isTest
  private static void shouldFillValuesOnWrapper() {
    test.startTest();
    Lead wk = [
      SELECT
        id,
        Lung_Disease__c,
        Pulmonary_Hypertension__c,
        Ventilator__c,
        Angina__c,
        Arrhythmia__c,
        Heart_Failure__c,
        Chronic_Heart_Failure__c,
        Congenital_Heart_Disease__c,
        Chronic_Hepatitis__c,
        Hidden_Proto_Pulmonary_Hypertension__c,
        Strokes__c,
        Convulsive_Disorders__c,
        Travel_Restriction__c,
        Current_Condition_Label__c,
        Travel_Algorithm__c
      FROM Lead
      WHERE
        sub_status__c = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
    ];
    wk.Travel_Algorithm__c =
      Constant_AC.INFECTIOUS_TUBERCULOSIS +
      ';' +
      Constant_AC.AIRBORNE_VIRAL_INFECTIONS_OF_HIGH_MORTALITY +
      ';' +
      Constant_AC.PNEUMOTHORAX +
      ';' +
      Constant_AC.PLEURAL_EFFUSION +
      ';' +
      Constant_AC.OXYGEN_DEPENDENCE_AT_SEA_LEVEL +
      ';' +
      Constant_AC.OXYGEN_REQUIREMENT_4L_MIN_AT_SEA_LEVEL +
      ';' +
      Constant_AC.LONG_TERM_OXYGEN_WITHIN_LAST_6_MONTHS +
      ';' +
      Constant_AC.HOSPITALIZATION_FOR_ACUTE_RESPIRATORY +
      ';' +
      Constant_AC.SEVERE_UNCONTROLLED_HYPERTENSION +
      ';' +
      Constant_AC.PORTAL_HYPERTENSION +
      ';' +
      Constant_AC.HEPTOPULMONARY_SYNDROME +
      ';' +
      Constant_AC.CHRONIC_LIVER_DISEASE +
      ';' +
      Constant_AC.END_STAGE_LIVER_DISEASE +
      ';' +
      Constant_AC.ESOPHAGEAL_VARICES_OR_HISTORY_OF +
      ';' +
      Constant_AC.INCREASED_INTRACRANIAL_PRESSURE +
      ';' +
      Constant_AC.PANIC_DISORDER +
      ';' +
      Constant_AC.MAJOR_BLEEDING +
      ';' +
      Constant_AC.SYMPTOMATIC_ANEMIA +
      ';' +
      Constant_AC.SICKLE_CELL_ANEMIA +
      ';' +
      Constant_AC.SURGERY_IN_THE_PAST_2_MONTHS +
      ';' +
      Constant_AC.MEDICALLY_FRAGILE_MEDICALLY_COMPLEX +
      ';' +
      Constant_AC.I_AM_NOT_SURE;

    update wk;

    DvTravelQuestionsController.TravelQuestionsWrapper wrapper = DvTravelQuestionsController.getTravelWrapperByLead(
      String.valueOf(wk.id)
    );
    wrapper.pulmonaryHypertensionSelection = 'abc';
    wrapper.chestPainSelections = new List<String>{ 'def' };
    wrapper.arrhythmiaSelections = new List<String>{ 'ghi' };
    wrapper.acuteHeartFailureSelections = new List<String>{ 'jkl' };
    wrapper.chronicHeartFailureSelections = new List<String>{ 'mno' };
    wrapper.cyanoticHeartDiseaseSelections = new List<String>{ 'pqr' };
    wrapper.convulsiveDisorderSelections = new List<String>{ 'stu' };

    DvTravelQuestionsController.saveTravelQuestionData(wrapper);

    wk = [
      SELECT id, Current_Condition_Label__c
      FROM Lead
      WHERE
        sub_status__c = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
    ];

    System.AssertNotEquals(null, wk.Current_Condition_Label__c);

    test.stopTest();
  }
}