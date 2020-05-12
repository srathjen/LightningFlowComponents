/***************************************************************************************************
Author      : MST Solutions
Date        : 03/28/2018
Description : Class contains test method for QualifyingDiagnosisLC_AC.apxc component
*****************************************************************************************************/
@IsTest
public class QualifyingDiagnosisLC_AC_TEST {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id ALGORITHM_RECORD_TYPE_ID = Constant_AC.TRAVEL_ALGM_RT_ID;

	@TestSetup
	public static void setup() {
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
        lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		insert lead;

        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contact1 = contacts.get(0);
        contact1.FirstName = 'Test1';
        contact1.LastName = 'User2';
        contact1.AccountId = account1.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
        insert contacts;

        List<Case> cases = TestDataFactory.createCase(1);
        Case wish = cases.get(0);
        wish.Lead__c = lead.Id;
        wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        wish.ChapterName__c = accounts.get(0).Id;
        wish.Subject = 'Wish1';
        wish.Interview_date__c = System.today();
        wish.Wish_Type__c = 'Hawaii';
        wish.Start_Date__c = System.today();
        wish.End_Date__c = System.today();
        wish.ContactId = contact1.Id;
        wish.Status = 'New';
        wish.Rush__c = false;
        wish.Start_Date__c = System.today();
        wish.Budget_Submitted_Date__c = System.today();
        wish.Budget_Approved_Date__c = System.today();
        wish.Update_Wish_Child_Form_Info__c = true;
        insert cases;

        List<Condition_Description__c> conditionDescriptions = TestDataFactory.createConditionDescription(1);
        Condition_Description__c conditionDescription = conditionDescriptions.get(0);
        conditionDescription.Name = 'Malignant Melanoma';
        conditionDescription.Treatment_Subspecialty__c = 'Oncology';
        conditionDescription.Code_To_Use__c = 'C43.30';
        conditionDescription.PR_Diagnosis__c = 'Malignant Melanoma';
        conditionDescription.Group1__c = true;
        insert conditionDescriptions;

        List<Medical_Questions__c> medicalQuestions = TestDataFactory.createMedicalQuestions(3);
        Medical_Questions__c newQuestionsOne = medicalQuestions.get(0);
        newQuestionsOne.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
        newQuestionsOne.Picklist_values__c = 'Yes,No';
        newQuestionsOne.Data_Type__c = 'Picklist';
        newQuestionsOne.RecordTypeId = ALGORITHM_RECORD_TYPE_ID;
        newQuestionsOne.Wrapper_Variable__c = 'TestWrapperone';
        newQuestionsOne.Current_Condition__c = 'Testone';
        newQuestionsOne.Recommendation_to_Chapter__c = 'None Apply';
        newQuestionsOne.Condition_Description__c = conditionDescription.Id;
        newQuestionsOne.Sort_Order__c = 1;
        Medical_Questions__c newQuestionsTwo = medicalQuestions.get(1);
        newQuestionsTwo.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
        newQuestionsTwo.Picklist_values__c = 'Yes,No';
        newQuestionsTwo.Epilepsy_picklist__c = 'Yes,No';
        newQuestionsTwo.Data_Type__c = 'Picklist';
        newQuestionsTwo.RecordTypeId = ALGORITHM_RECORD_TYPE_ID;
        newQuestionsTwo.Wrapper_Variable__c = 'TestWrappertwo';
        newQuestionsTwo.Current_Condition__c = 'Testtwo';
        newQuestionsTwo.Recommendation_to_Chapter__c = 'None Apply';
        newQuestionsTwo.Condition_Description__c = conditionDescription.Id;
        newQuestionsTwo.Sort_Order__c = 2;
        Medical_Questions__c newQuestionsThree = medicalQuestions.get(2);
        newQuestionsThree.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
        newQuestionsThree.Picklist_values__c = 'Yes,No';
        newQuestionsThree.Data_Type__c = 'Comment box';
        newQuestionsThree.RecordTypeId = ALGORITHM_RECORD_TYPE_ID;
        newQuestionsThree.Wrapper_Variable__c = 'TestWrapperthree';
        newQuestionsThree.Current_Condition__c = 'Testthree';
        newQuestionsThree.Recommendation_to_Chapter__c = 'None Apply';
        newQuestionsThree.Condition_Description__c = conditionDescription.Id;
        newQuestionsThree.Sort_Order__c = 3;
        insert medicalQuestions;
	}

	@IsTest
	static void getMedicalInformation() {
		Lead lead = [
				SELECT Id, PD_ICD_Code__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		List<ICD_Codes__c> icdCodes = [
				SELECT Id, Name
				FROM ICD_Codes__c
				WHERE Name = 'Q917'
		];
        List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE Lead__c = :lead.Id
        ];
        List<Condition_Description__c> conditionDescriptions = [
            SELECT Id, Name, PR_Diagnosis__c
            FROM Condition_Description__c
            WHERE Name = 'Malignant Melanoma'
        ];

		System.assertEquals(lead.PD_ICD_Code__c, icdCodes[0].Id, 'ICD Code doesnot match');
		QualifyingDiagnosisLC_AC.getIcdCodeInfo(icdCodes[0].Name);
		QualifyingDiagnosisLC_AC.getConditionDescInfo('Malignant Melanoma');
        QualifyingDiagnosisLC_AC.getMedicalInformation(cases[0].Id);
        QualifyingDiagnosisLC_AC.updateQualifyingDiagnosis(conditionDescriptions[0].Name,
                icdCodes[0].Id, lead.Id, conditionDescriptions[0].PR_Diagnosis__c);
	}
}