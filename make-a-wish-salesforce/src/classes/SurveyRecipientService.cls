/**
 * @description Service class for updating survey recipients
 *
 * @author Mason Buhler, Traction on Demand
 *
 * @date 7-26-2019
 */
public with sharing class SurveyRecipientService {

    public static void updateSurveyRecipients(List<Wish_Affiliation__c> newWishAffiliationsList, Map<Id, Wish_Affiliation__c> oldWishAffiliationsMap) {
        List<Wish_Affiliation__c> wishAffiliationsToProcess = new List<Wish_Affiliation__c>();
        Set<Id> allCaseIds = new Set<Id>();
        Set<Id> caseIdsToClearSurveyRecipient = new Set<Id>();
        List<Wish_Affiliation__c> wishAffiliationsToUpdate = new List<Wish_Affiliation__c>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();

        for (Wish_Affiliation__c wa : newWishAffiliationsList) {
            Wish_Affiliation__c oldWA = oldWishAffiliationsMap != null ? oldWishAffiliationsMap.get(wa.Id) : null;
            // Narrow down the list of wish affiliations to ones that meet our criteria, and collect related case Ids
            if ((oldWA == null || wa.Survey_Recipient__c != oldWA.Survey_Recipient__c) && wa.Wish__c != null) {
                if (wa.Survey_Recipient__c) {
                    wishAffiliationsToProcess.add(wa);
                } else {
                    caseIdsToClearSurveyRecipient.add(wa.Wish__c);
                }
                allCaseIds.add(wa.Wish__c);
            }
        }

        if (allCaseIds.isEmpty()) {
            // Nothing to do
            return;
        }

        // Retrieve all related cases (wishes) and map them by case Id
        Map<Id, Case> allCasesById = new Map<Id, Case>([
                SELECT Id, Survey_Recipient__c
                FROM Case
                WHERE Id IN :allCaseIds
        ]);

        for (Id caseId : caseIdsToClearSurveyRecipient) {
            Case c = allCasesById.get(caseId);
            c.Survey_Recipient__c = null;
            casesToUpdate.put(c.Id, c);
        }

        if (!wishAffiliationsToProcess.isEmpty()) {
            // Retrieve all related wish affiliations and map them by case Id
            List<Wish_Affiliation__c> allRelatedWishAffiliations = [
                    SELECT Id, Survey_Recipient__c, Contact__c, Wish__c
                    FROM Wish_Affiliation__c
                    WHERE Survey_Recipient__c = TRUE AND Wish__c IN :allCaseIds
            ];

            Map<Id, List<Wish_Affiliation__c>> relatedWishAffiliationsByCaseId = new Map<Id, List<Wish_Affiliation__c>>();
            for (Wish_Affiliation__c wa : allRelatedWishAffiliations) {
                if (!relatedWishAffiliationsByCaseId.containsKey(wa.Wish__c)) {
                    relatedWishAffiliationsByCaseId.put(wa.Wish__c, new List<Wish_Affiliation__c>());
                }
                relatedWishAffiliationsByCaseId.get(wa.Wish__c).add(wa);
            }

            for (Wish_Affiliation__c wa : wishAffiliationsToProcess) {
                if (relatedWishAffiliationsByCaseId.containsKey(wa.Wish__c)) {
                    // Un-check the survey recipient checkbox for all related wish affiliations
                    for (Wish_Affiliation__c relatedWA : relatedWishAffiliationsByCaseId.get(wa.Wish__c)) {
                        relatedWA.Survey_Recipient__c = false;
                        wishAffiliationsToUpdate.add(relatedWA);
                    }
                }
                Case c = allCasesById.get(wa.Wish__c);
                // Stamp the new survey recipient's contact Id on the case
                c.Survey_Recipient__c = wa.Contact__c;
                casesToUpdate.put(c.Id, c);
            }
        }
        update wishAffiliationsToUpdate;
        update casesToUpdate.values();
    }
}