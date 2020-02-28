/**
 * @description Diagnosis Verification Service, centralizes Diagnosis Verification business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class DiagnosisVerificationService {

	/**
	 * Delete Diagnosis Verifications found by Lead Id
	 * @param leadId
	 */
	public static void deleteByLeadId(Id leadId){
		delete [
				SELECT Id
				FROM Diagnosis_Verification__c
				WHERE Lead__c = :leadId
		];
	}
}