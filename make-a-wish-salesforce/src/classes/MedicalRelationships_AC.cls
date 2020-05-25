/**
 * @description This form displays the medical professional details in the case page layout.
 *
 * @author MST Solutions
 *
 * @date 02/15/2018
 */
public class MedicalRelationships_AC {

    private static final Id MEDICAL_PROFESSIONAL_RT = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

    @TestVisible private Case currCase = new Case();

    public static Id caseId { get; set; }

    public MedicalRelationships_AC(ApexPages.StandardController controller) {
        currCase = (Case) controller.getRecord();
        currCase = [
                SELECT Id, ContactId
                FROM Case
                WHERE Id = :currCase.Id
                LIMIT 1
        ];
        caseId = currCase.Id;
    }

    /**
     * @description Get the medical profession contact from the wish child contact.
     *
     * @return List of Relationships
     */
    public List<npe4__Relationship__c> getMedicalRelationshipsConList() {
        String queryString = '';
        try {
            Set<Id> caseIdSet = new Set<Id>();
            caseIdSet.add(currCase.ContactId);
            List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
            queryString = 'SELECT '
                    + String.join(Utils.getFieldPaths('npe4__Relationship__c', 'MedicalRelationships'), ', ')
                    + ' FROM npe4__Relationship__c WHERE npe4__Contact__c =\''
                    + currCase.ContactId
                    + '\' AND npe4__RelatedContact__r.RecordTypeId =\''
                    + MEDICAL_PROFESSIONAL_RT + '\'';
            for (npe4__Relationship__c currRec : Database.query(queryString)) {
                relationships.add(currRec);
            }
            return relationships;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('MedicalRelationships_AC', 'getmedicalRelationshipsConList', null, ex, queryString));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}