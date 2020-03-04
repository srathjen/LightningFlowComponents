/**
 * @description     Helper class to separate out selector and other common functions related to DiagnosisVerification_AC
 *
 * @author          Chris Shinnimin, Traction on Demand
 * @date            2020-03-03
 */
public class DiagnosisVerification_AC_Helper {

    /*
     * @description     Function to translate condition related checkboxes on Lead to a status code.
     *                  This was moved out of loadData() to reduce the size of that function and improve readability.
     *
     * @param           Lead lead
     *
     * @return          String
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-02-28
     */
    public static String getDescribePatientCode(Lead lead) {
        if (lead.Child_will_ultimately_die_prematurely__c == true) {
            return '1';
        } else if (lead.Treatment_may_be_feasible_but_can_fail__c == true) {
            return '2';
        } else if (lead.Treatment_may_prolong_normal_activities__c == true) {
            return '3';
        } else if (lead.Debilitation_may_extend_over_many_years__c == true) {
            return '4';
        } else if (lead.Increased_probability_of_premature_death__c == true) {
            return '5';
        } else if (lead.Risk_of_complications_premature_death__c == true) {
            return '6';
        } else if (lead.Responds_to_treatment_with_normal_health__c == true) {
            return '7';
        } else if (lead.None_of_these_statements_describes_Child__c == true) {
            return '8';
        } else {
            return '8';
        }
    }

    /*
     * @description     Function to return a list of Medical Questions.
     *                  This was moved out of loadData() to reduce the size of that function and improve readability.
     *
     * @return          List<Medical_Questions__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-02-28
     */
    public static List<Medical_Questions__c> getMedicalQuestions(String whereClauseField, String whereClauseValue) {
        String query = 'SELECT ';

        final List<String> FIELDS_TO_SELECT = new List<String> {
            'Id',
            'RecordTypeId',
            'Condition_Description__c',
            'Condition_Description__r.Name',
            'Current_Condition__c',
            'Data_Type__c',
            'Epilepsy_picklist__c',
            'Picklist_values__c',
            'Question__c',
            'Recommendation_to_Chapter__c',
            'Sort_Order__c',
            'Wrapper_Variable__c'
        };

        for (String field : FIELDS_TO_SELECT) {
            query += field + ',';
        }

        query = query.removeEnd(',');
        query += ' FROM Medical_Questions__c ';
        if (!String.isBlank(whereClauseField)) {
            query += 'WHERE ' + whereClauseField + ' = :whereClauseValue';
        }
        query += ' ORDER BY Sort_Order__c ASC ';
        query += 'LIMIT 50000';

        return Database.query(query);
    }

    /*
     * @description     Function to return a list of Diagnosis Verifications for a given Lead.
     *                  This was moved out of loadData() to reduce the size of that function and improve readability.
     *
     * @param           Id leadId
     *
     * @return          List<Diagnosis_Verification__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-02-28
     */
    public static List<Diagnosis_Verification__c> getDiagnosisVerifications(Id leadId) {
        return [
            SELECT
                Id,
                Group1__c,
                ICD_Code__c,
                Lead__c,
                Primary_Diagnosis__c,
                PCD_ICD__c,
                Order__c,
                Short_Description__c,
                Condition_Description__c,
                Condition_Description__r.Name,
                IsEligible__c,
            (
                SELECT
                    Medical_Question__c,
                    Epilepsy_Value__c,
                    Medical_Question_Answer__c,
                    IsEligible__c,
                    Comment__c
                FROM DiagnosisMedicalQuestions__r
            )
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :leadId
            ORDER BY Order__c
            LIMIT 50000
        ];
    }

    /*
     * @description     Function to return a list of ICD Codes with a given ICD Code Name.
     *                  This was moved out of WishChildEligibilityCheck() to reduce the size of that function and improve readability.
     *                  Note that it is not clear why this function returns a List and not an individual ICD_Code__c.
     *                  The calling function only references element 0 of the returned array. Consider refactoring
     *                  this function to return a single ICD_Codes__c record.
     *
     * @param           String nameString
     *
     * @return          List<ICD_Codes__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-03-02
     */
    public static List<ICD_Codes__c> getIcdCodeInfo(String nameString) {
        return [
            SELECT
                Id,
                Name,
                Skip_Medical_Question__c,
                Condition_Description__c,
                Short_Description__c,
                Condition_Description__r.Name,
                Condition_Description__r.isEligible__c,
                Group1__c
            FROM ICD_Codes__c
            WHERE Name = :nameString
            LIMIT 50000
        ];
    }

    /*
     * @description     Function to return a list of Condition Descriptions with a given Name.
     *                  This was moved out of WishChildEligibilityCheck() to reduce the size of that function and improve readability.
     *
     *
     * @param           String whereClauseField
     * @param           String whereClauseValue
     *
     * @return          List<Condition_Description__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-03-02
     */
    public static List<Condition_Description__c> getConditionDescriptionInfo(String whereClauseField, String whereClauseValue, Boolean isLiteralValue) {
        String query = 'SELECT ';

        final List<String> FIELDS_TO_SELECT = new List<String> {
            'Id',
            'Name',
            'isEligible__c',
            'Group1__c',
            'Code_To_Use__c',
            'InActive__c'
        };

        for (String field : FIELDS_TO_SELECT) {
            query += field + ',';
        }

        query = query.removeEnd(',');
        query += ' FROM Condition_Description__c ';
        if (!String.isBlank(whereClauseField)) {
            query += 'WHERE ' + whereClauseField + ' = ';
            if (isLiteralValue) {
                query += whereClauseValue;
            } else {
                query += ':whereClauseValue';
            }
        }
        query += ' LIMIT 50000';

        System.debug(query);

        return Database.query(query);
    }
}