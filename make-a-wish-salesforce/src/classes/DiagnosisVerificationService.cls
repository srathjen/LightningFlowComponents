/**
 * @description Diagnosis Verification Service, centralizes Diagnosis Verification business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class DiagnosisVerificationService {

	/**
	 * Find Diagnosis Verifications by Lead Id
	 * @param leadId
	 */
	public static List<Diagnosis_Verification__c> findByLeadId(Id leadId) {
		return [
				SELECT Id, ICD_Code__c, Condition_Description__c, Group1__c, isEligible__c
				FROM Diagnosis_Verification__c
				WHERE Lead__c = :leadId
				AND isEligible__c = TRUE
				LIMIT 1
		];
	}

	/**
	 * Delete Diagnosis Verifications found by Lead Id
	 * @param leadId
	 */
	public static void deleteByLeadId(Id leadId) {
		delete [
				SELECT Id
				FROM Diagnosis_Verification__c
				WHERE Lead__c = :leadId
		];
	}

	/**
	 * Update Contact on Diagnosis Verifications found by Lead Id
	 * @param leadMap
	 */
	public static void updateContact(Map<Id, Lead> leadMap) {
		List<Diagnosis_Verification__c> diagnosisList = new List<Diagnosis_Verification__c>();
		for (Diagnosis_Verification__c diagnosisInfo : [
				SELECT Id, Contact__c, Lead__c
				FROM Diagnosis_Verification__c
				WHERE Lead__c IN :leadMap.keySet()
		]) {
			diagnosisInfo.Contact__c = leadMap.get(diagnosisInfo.Lead__c).ConvertedContactId;
			diagnosisList.add(diagnosisInfo);
		}
		update diagnosisList;
	}
}