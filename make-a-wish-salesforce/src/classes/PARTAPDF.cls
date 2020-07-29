/*****************************************************************************************************************
Author      : MST Solutions
Date        : 9/30/2016
Description : This class is used to display the Medical Information in Docusign page
1. 09/04/2020 - Manoj      - SIW-355 : Added 2 new field to get queried on page load
2. 29 Jul 2020 - Manoj      - SIW-378 : Added  fields in query for new questions
*******************************************************************************************************************/
public class PARTAPDF {
    public Id leadId { get; set; }
    public Lead currLead { get; set; }
    public String currentCondition { get; set; }
    public List<Diagnosis_Verification__c> diagnosisVerificationList { get; set; }
    public Map<Id, String> medicalQuestionMap { get; set; }
    public List<String> currentConditionList { get; set; }    

    public PARTAPDF() {
        currentConditionList = new List<String>();       
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        diagnosisVerificationList = new List<Diagnosis_Verification__c>();
        medicalQuestionMap = new Map<Id, String>();

        loadData();
    }

    /*
     * @description     Used to load the medical information data into the DocuSign page
     *
     * @date            unknown
     * @author          MST Solutions
     */
    public void loadData() {
        List<String> recValueList = new List<String>();

        final List<String> FIELDS_TO_SELECT = new List<String>{
            'Id',
            'IsConverted',
            'FirstName',
            'LastName',
            'Email',
            'Phone',
            'Name',
            'Provided_Additional_Information__c',
            'Diagnosis_Given_By_Referrer__c',
            'RFI_Form_Info_Hidden__c',
            'Override_Dupe_Check__c',
            'Please_Explain_Deteriorate__c',
            'ICD_Given_By_Referrer__r.Name',
            'Expedite_timeframe__c',
            'Other_expedite_timeframe_comments__c',
            'Does_Child_Have_Cognitive_Delays__c',
            'Does_Child_Have_Speech_or_Language_Delay__c',
            'Non_Verbal_Communication_Method__c',
            'Non_Verbal_Additional_Information__c',
            'Non_Verbal__c'
        };

        try {
            String query = 'SELECT ';

            for (String field : FIELDS_TO_SELECT) {
                query += field + ',';
            }

            for (Schema.FieldSetMember currField : Utils.getPartAFields()) {
                query += currField.getFieldPath() + ',';
            }

            query = query.removeEnd(',');

            query += ' FROM Lead ';
            query += ' WHERE Id = :leadId';

            currLead = Database.query(query);

            recValueList.add(String.valueOf(currLead));

            if (currLead.Current_Condition_Label__c != null) {
                for (String splitCondition : currLead.Current_Condition_Label__c.split('\n')) {
                    currentConditionList.add(splitCondition);
                }
            }

            diagnosisVerificationList = getDiagnosisVerificationList();
            recValueList.add(String.valueOf(diagnosisVerificationList));

            if ((!String.isEmpty(currLead.Current_Condition_Label__c)) && currLead.Current_Condition_Label__c.contains(';')) {
                Integer i = 0;
                currentCondition = '';

                for (String currentSplitString : currLead.Current_Condition_Label__c.split(';')) {
                    if (!String.isEmpty(currentSplitString)) {
                        currentCondition += i + 1 + '. ' + currentSplitString + '\n';
                        i++;
                    }
                }
            }

            for (Medical_Questions__c medicalQuestions : getMedicalQuestions()) {
                if (medicalQuestions.Question__c != null) {
                    medicalQuestions.Question__c = medicalQuestions.Question__c.replace('[child\'s name]', ' ' + currLead.FirstName + ' ' + currLead.LastName).replace(' (child\'s name) ', currLead.FirstName + ' ' + currLead.LastName).replace('[Insert child\'s name]', currLead.FirstName + ' ' + currLead.LastName);
                    medicalQuestions.Question__c = medicalQuestions.Question__c.replace('been on TPN?', 'been on TPN (years, months)?');
                    medicalQuestionMap.put(medicalQuestions.Id, medicalQuestions.Question__c);
                }

                recValueList.add(String.valueOf(medicalQuestions));
            }

        } catch (Exception ex) {
            // fail gracefully, consider user feedback mechanism
        }
    }

    /*
     * @description     Private function to retrieve a List<Diagnosis_Verification__c>
     *                  Pulled out of loadData() during code cleanup to improve readability.
     *
     * @return          List<Diagnosis_Verification__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @date            2020-03-11
     */
    private List<Diagnosis_Verification__c> getDiagnosisVerificationList() {
        return [
            SELECT
                Id,
                ICD_Code__c,
                Lead__c,
                Primary_Diagnosis__c,
                PCD_ICD__c,
                Order__c,
                Short_Description__c,
                Condition_Description__r.Name,
                isEligible__c, (
                SELECT
                    Medical_Question__c,
                    Epilepsy_Value__c,
                    Medical_Question_Answer__c,
                    isEligible__c,
                    Comment__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :leadId
            ORDER BY Order__c
        ];
    }

    /*
     * @description     Private function to retrieve a List<Medical_Questions__c>
     *                  Pulled out of loadData() during code cleanup to improve readability.
     *                  NOTE: Very similar selector exists in DiagnosisVerification_AC_Helper,
     *                        (candidate for extracting to a utility class)
     *
     * @return          List<Diagnosis_Verification__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @date            2020-03-11
    */
    private List<Medical_Questions__c> getMedicalQuestions() {
        return [
            SELECT
                Id,
                Condition_Description__c,
                Condition_Description__r.Name,
                Current_Condition__c,
                Data_Type__c,
                Epilepsy_picklist__c,
                Picklist_values__c,
                Question__c,
                Recommendation_to_Chapter__c,
                Sort_Order__c,
                Wrapper_Variable__c
            FROM Medical_Questions__c
            ORDER BY Sort_Order__c
        ];
    }
}