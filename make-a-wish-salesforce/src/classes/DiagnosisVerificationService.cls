/**
 * @description Diagnosis Verification Service, centralizes Diagnosis Verification business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class DiagnosisVerificationService {

	public static void deleteByLeadId(Id leadId){
		List<Diagnosis_Verification__c> diagnosisVerifications = [
				SELECT Id
				FROM Diagnosis_Verification__c
				WHERE Lead__c = :leadId
		];
		if(!diagnosisVerifications.isEmpty()){
			delete diagnosisVerifications;
		}
	}
}