/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/25/2020
 */
public with sharing class DocusignStatusService {
    public static Map<Id, Conflict_Of_Interest__c> findExistingCoiBySignedDate(List<dsfs__DocuSign_Status__c> docuSignStatuses, Date signedDate) {
        Map<Id, Conflict_Of_Interest__c> coiMap = new Map<Id, Conflict_Of_Interest__c>();
        Set<Id> contactIds = new Set<Id>();
        for (dsfs__DocuSign_Status__c docuSignStatus : docuSignStatuses) {
            contactIds.add(docuSignStatus.Docusign_Hidden_Contact__c);
        }
        for (Conflict_Of_Interest__c coi : [
                SELECT Volunteer_Contact__c, Signed_Date__c, Expiration_Date__c
                FROM Conflict_Of_Interest__c
                WHERE Volunteer_Contact__c IN :contactIds
                AND Signed_Date__c = :signedDate
        ]) {
            coiMap.put(coi.Volunteer_Contact__c, coi);
        }
        return coiMap;
    }
}