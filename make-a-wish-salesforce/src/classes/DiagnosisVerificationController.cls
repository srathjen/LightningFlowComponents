/**
 * @description Diagnosis Verification Controller
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 08/Feb/2021
 */
public with sharing class DiagnosisVerificationController {

	private final static String STEP_STATUS_ACTIVE = 'active';
	private final static String NO = 'no';
	private final static String STEP_STATUS_INACTIVE = 'incomplete';

	@AuraEnabled(Cacheable=true)
	public static DiagnosisVerificationWrapper getDiagnosisVerificationByLeadId(
			String leadId
	) {
		Lead lead = [
				SELECT Id, I_m_Part_of_The_Treating_HealthCare_Team__c
				FROM Lead
				WHERE Id = :leadId
		];

		String step234Status = STEP_STATUS_ACTIVE;
		if (String.isBlank(lead.I_m_Part_of_The_Treating_HealthCare_Team__c)
				|| lead.I_m_Part_of_The_Treating_HealthCare_Team__c.toLowerCase().trim() == NO) {
			step234Status = STEP_STATUS_INACTIVE;
		}

		ProcessStepsWrapper step1 = new ProcessStepsWrapper();
		step1.id = 1;
		step1.label = 'Medical Professional Information';
		step1.status = STEP_STATUS_ACTIVE;

		ProcessStepsWrapper step2 = new ProcessStepsWrapper();
		step2.id = 2;
		step2.label = 'Diagnosis';
		step2.status = step234Status;

		ProcessStepsWrapper step3 = new ProcessStepsWrapper();
		step3.id = 3;
		step3.label = 'Additional Medical Questions';
		step3.status = step234Status;

		ProcessStepsWrapper step4 = new ProcessStepsWrapper();
		step4.id = 4;
		step4.label = 'Travel Questions';
		step4.status = step234Status;

		ProcessWrapper process = new ProcessWrapper();
		process.currentStepId = 1;
		process.steps = new List<ProcessStepsWrapper>{
				step1, step2, step3, step4
		};

		DiagnosisVerificationWrapper dvw = new DiagnosisVerificationWrapper();
		dvw.leadId = leadId;
		dvw.process = process;

		return dvw;
	}

	public class DiagnosisVerificationWrapper {
		@AuraEnabled
		public String leadId { get; set; }
		@AuraEnabled
		public ProcessWrapper process { get; set; }
	}

	public class ProcessWrapper {
		@AuraEnabled
		public Integer currentStepId { get; set; }
		@AuraEnabled
		public List<ProcessStepsWrapper> steps { get; set; }
	}

	public class ProcessStepsWrapper {
		@AuraEnabled
		public Integer id { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String status { get; set; }
	}
}