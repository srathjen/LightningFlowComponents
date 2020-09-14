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

	/**
	 * @description Update Contact on Diagnosis Verifications found by Lead Id
	 * @param lead lead
	 * @param targetEmail Email To Address
	 */
	public static void processSendDiagnosisVerification(Lead lead, String targetEmail) {
		// Build Tasks
		Task task = new Task();
		task.Description = 'Diagnosis Verification sent to ' + lead.Hidden_DV_Form_Name__c + '.';
		task.OwnerId = Label.Salesforce_Support_User_Id;
		task.Priority = Constant_AC.TASK_PRIORITY_NORMAL;
		task.Status = Constant_AC.TASK_STATUS_COMPLETED;
		task.Subject = 'Lead ET : Your patient has been referred for a wish!';
		task.WhoId = lead.Id;
		// Build E-Mail to be sent
		EmailService.EmailMessageWrapper emailMessageWrapper = new EmailService.EmailMessageWrapper(
				lead.Id, Label.DV_Form_Email_Template_API, new List<String>{
						targetEmail
				});
		List<Messaging.SingleEmailMessage> emailMessages = EmailService.buildEmail(
				new List<EmailService.EmailMessageWrapper>{
						emailMessageWrapper
				}
		);
		insert task;
		EmailService.sendEmail(emailMessages);
	}
}