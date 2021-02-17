/**
 * @description Diagnosis Verification Additional Medical Questions Controller
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 08/Feb/2021
 */
public with sharing class DvAdditionalMedicalQuestionsController {

	public static String YES = Constant_AC.YES_TEXT;
	public static String NO = Constant_AC.NO_TEXT;
	public static String MILD_FUNCTION = Constant_AC.MILD_FUNCTION;
	public static String MODERATE_FUNCTION = Constant_AC.MODERATE_FUNCTION;
	public static String SAME_AGE_PEERS = Constant_AC.SAME_AGE_PEERS;
	public static String CHILD_NON_VERBAL = Constant_AC.CHILD_NON_VERBAL;
	public static String FOLLOW_MEDICAL_TEAM = Constant_AC.FOLLOW_MEDICAL_TEAM;
	public static String CHILD_VERBAL_DELAYED = Constant_AC.CHILD_VERBAL_DELAYED;
	public static String CHILD_VERBAL_AGE = Constant_AC.CHILD_VERBAL_AGE;
	public static String RED = 'Red';

	@AuraEnabled(Cacheable=true)
	public static AdditionalMedicalQuestionsWrapper getAdditionalMedicalQuestionsByLeadId(
			String leadId
	) {
		AdditionalMedicalQuestionsWrapper amq = new AdditionalMedicalQuestionsWrapper();

		Lead lead = [
				SELECT Id, FirstName, Status, Provided_additional_information__c, Why_do_you_feel_would_be_eligible_Wish__c,
						Please_Explain_Deteriorate__c, Any_medical_reason_for_moving_quickly__c,
						Will_Child_s_Condition_Deteriorate__c, Please_Explain__c, Unplanned_hospital_admissions__c,
						Number_hospital_admissions__c, Admitting_diagnosis__c, ICU_Admissions__c, Expedite_timeframe__c,
						Other_expedite_timeframe_comments__c, Child_will_ultimately_die_prematurely__c,
						Treatment_may_be_feasible_but_can_fail__c, Treatment_may_prolong_normal_activities__c,
						Debilitation_may_extend_over_many_years__c, Increased_probability_of_premature_death__c,
						None_of_these_statements_describes_Child__c, Does_Child_Have_Cognitive_Delays__c, Non_Verbal__c,
						Does_Child_Have_Speech_or_Language_Delay__c, Non_Verbal_Additional_Information__c,
						Non_Verbal_Communication_Method__c
				FROM Lead
				WHERE Id = :leadId
		];
		amq.wishChildFirstName = lead.FirstName;
		amq.additionalInfoProvide = lead.Provided_additional_information__c;
		amq.additionalClinicalDetails = lead.Why_do_you_feel_would_be_eligible_Wish__c;
		amq.expectConditionDeteriorateExplain = lead.Please_Explain_Deteriorate__c;
		amq.medicalExpediteProcess = lead.Any_medical_reason_for_moving_quickly__c.stripHtmlTags();
		amq.expectConditionDeteriorate = lead.Will_Child_s_Condition_Deteriorate__c;
		amq.medicalExpediteProcessReason = lead.Please_Explain__c;
		amq.unplannedHospitalAdmissions = lead.Unplanned_hospital_admissions__c;
		amq.timesChildAdmitted = String.valueOf(lead.Number_hospital_admissions__c);
		amq.admittedDiagnosis = lead.Admitting_diagnosis__c;
		amq.hospitalizationAdmissionIcu = lead.ICU_Admissions__c;
		amq.provideTimeFrameWish = lead.Expedite_timeframe__c;
		amq.provideTimeFrameWishInformation = lead.Other_expedite_timeframe_comments__c;

		if (lead.Child_will_ultimately_die_prematurely__c) {
			amq.statementDescribePatient = 'TREATMENT_MAY_BE_FEASIBLE_BUT_CAN_FAIL';
		} else if (lead.Treatment_may_be_feasible_but_can_fail__c) {
			amq.statementDescribePatient = 'TREATMENT_MAY_PROLONG_NORMAL_ACTIVITIES';
		} else if (lead.Treatment_may_prolong_normal_activities__c) {
			amq.statementDescribePatient = 'DEBILITATION_MAY_EXTEND_OVER_MANY_YEARS';
		} else if (lead.Debilitation_may_extend_over_many_years__c) {
			amq.statementDescribePatient = 'INCREASED_PROBABILITY_OF_PREMATURE_DEATH';
		} else if (lead.Increased_probability_of_premature_death__c) {
			amq.statementDescribePatient = 'CHILD_WILL_ULTIMATELY_DIE_PREMATURELY';
		} else if (lead.None_of_these_statements_describes_Child__c) {
			amq.statementDescribePatient = 'NONE_OF_THESE_STATEMENTS_DESCRIBES_CHILD';
		}

		Set<String> levelSet = new Set<String>{
				MILD_FUNCTION,
				MODERATE_FUNCTION,
				SAME_AGE_PEERS
		};
		if (levelSet.contains(lead.Does_Child_Have_Cognitive_Delays__c)) {
			amq.levelOfDelay = lead.Does_Child_Have_Cognitive_Delays__c;
			amq.cognitiveDelay = YES;
			if (lead.Non_Verbal__c == YES &&
					lead.Does_Child_Have_Cognitive_Delays__c != SAME_AGE_PEERS
					) {
				amq.expressNeedsDesires = CHILD_NON_VERBAL;
			}
		} else if (lead.Does_Child_Have_Cognitive_Delays__c == NO
				|| lead.Does_Child_Have_Cognitive_Delays__c == FOLLOW_MEDICAL_TEAM) {
			amq.cognitiveDelay = lead.Does_Child_Have_Cognitive_Delays__c;
			if (lead.Non_Verbal__c == YES) {
				amq.expressNeedsDesires = CHILD_NON_VERBAL;
			}
		}
		amq.speechLanguageDelay = lead.Does_Child_Have_Speech_or_Language_Delay__c;
		amq.describeCommunicationNeedsInformation = lead.Non_Verbal_Additional_Information__c;
		if (lead.Non_Verbal__c == NO) {
			if (lead.Does_Child_Have_Speech_or_Language_Delay__c == YES) {
				amq.expressNeedsDesires = CHILD_VERBAL_DELAYED;
			} else {
				amq.speechLanguageDelay = CHILD_VERBAL_AGE;
			}
		}
		amq.describeCommunicationNeeds = new List<String>();
		if (!String.isEmpty(lead.Non_Verbal_Communication_Method__c)) {
			amq.describeCommunicationNeeds = lead.Non_Verbal_Communication_Method__c.split(
					';'
			);
		}

		// TODO: Temporary until we implement Sprint 2 Diagnosis Questions and Eligibility Service
		Boolean isLeadQualified = isLeadEligible(lead.Id);
		amq.isLeadQualifying = isLeadQualified;

		return amq;
	}

	@AuraEnabled
	public static SaveAdditionalMedicalQuestionsResultWrapper saveAdditionalMedicalQuestions(
			AdditionalMedicalQuestionsWrapper amq
	) {

		System.debug('WRAPPERZ ' + amq);

		Lead lead = [
				SELECT Id, FirstName, Status, Provided_additional_information__c, Why_do_you_feel_would_be_eligible_Wish__c,
						Please_Explain_Deteriorate__c, Any_medical_reason_for_moving_quickly__c,
						Will_Child_s_Condition_Deteriorate__c, Please_Explain__c, Unplanned_hospital_admissions__c,
						Number_hospital_admissions__c, Admitting_diagnosis__c, ICU_Admissions__c, Expedite_timeframe__c,
						Other_expedite_timeframe_comments__c, Child_will_ultimately_die_prematurely__c,
						Treatment_may_be_feasible_but_can_fail__c, Treatment_may_prolong_normal_activities__c,
						Debilitation_may_extend_over_many_years__c, Increased_probability_of_premature_death__c,
						None_of_these_statements_describes_Child__c, Does_Child_Have_Cognitive_Delays__c, Non_Verbal__c,
						Does_Child_Have_Speech_or_Language_Delay__c, Non_Verbal_Additional_Information__c,
						Non_Verbal_Communication_Method__c
				FROM Lead
				WHERE Id = :amq.leadId
		];

		try {
			lead.Any_medical_reason_for_moving_quickly__c = amq.medicalExpediteProcess;
			if (amq.medicalExpediteProcess.containsIgnoreCase(YES)) {
				lead.Any_medical_reason_for_moving_quickly__c = String.format(
						Label.Dynamic_Font_Tag_with_Color,
						new List<String>{
								RED, amq.medicalExpediteProcess
						}
				);
			}
			lead.Please_Explain_Deteriorate__c = amq.expectConditionDeteriorateExplain;
			lead.Please_Explain__c = amq.medicalExpediteProcessReason;
			lead.Will_Child_s_Condition_Deteriorate__c = amq.expectConditionDeteriorate;
			lead.Why_do_you_feel_would_be_eligible_Wish__c = amq.additionalClinicalDetails;
			lead.Provided_additional_information__c = amq.additionalInfoProvide;
			lead.Unplanned_hospital_admissions__c = amq.unplannedHospitalAdmissions;
			lead.Number_hospital_admissions__c = String.isBlank(amq.timesChildAdmitted) ? null : Integer.valueOf(
					amq.timesChildAdmitted
			);
			lead.Admitting_diagnosis__c = amq.admittedDiagnosis;
			lead.ICU_Admissions__c = amq.hospitalizationAdmissionIcu;
			lead.Expedite_timeframe__c = amq.provideTimeFrameWish;
			lead.Other_expedite_timeframe_comments__c = amq.provideTimeFrameWishInformation;
			lead.Child_will_ultimately_die_prematurely__c = amq.statementDescribePatient == 'TREATMENT_MAY_BE_FEASIBLE_BUT_CAN_FAIL' ? true : false;
			lead.Treatment_may_be_feasible_but_can_fail__c = amq.statementDescribePatient == 'TREATMENT_MAY_PROLONG_NORMAL_ACTIVITIES' ? true : false;
			lead.Treatment_may_prolong_normal_activities__c = amq.statementDescribePatient == 'DEBILITATION_MAY_EXTEND_OVER_MANY_YEARS' ? true : false;
			lead.Debilitation_may_extend_over_many_years__c = amq.statementDescribePatient == 'INCREASED_PROBABILITY_OF_PREMATURE_DEATH' ? true : false;
			lead.Increased_probability_of_premature_death__c = amq.statementDescribePatient == 'CHILD_WILL_ULTIMATELY_DIE_PREMATURELY' ? true : false;
			lead.None_of_these_statements_describes_Child__c = amq.statementDescribePatient == 'NONE_OF_THESE_STATEMENTS_DESCRIBES_CHILD' ? true : false;

			if (amq.cognitiveDelay == YES) {
				lead.Does_Child_Have_Cognitive_Delays__c = amq.levelOfDelay;
			} else {
				lead.Does_Child_Have_Cognitive_Delays__c = amq.cognitiveDelay;
			}

			lead.Does_Child_Have_Speech_or_Language_Delay__c = amq.speechLanguageDelay;
			lead.Non_Verbal__c = '';
			if (amq.speechLanguageDelay == CHILD_VERBAL_AGE || amq.expressNeedsDesires == CHILD_VERBAL_DELAYED) {
				lead.Non_Verbal__c = NO;
			}
			if (amq.expressNeedsDesires == CHILD_NON_VERBAL) {
				lead.Non_Verbal__c = YES;
			}
			if (amq.levelOfDelay == SAME_AGE_PEERS) {
				lead.Non_Verbal__c = YES;
				lead.Does_Child_Have_Speech_or_Language_Delay__c = YES;
			}
			if (amq.levelOfDelay == SAME_AGE_PEERS || amq.expressNeedsDesires == CHILD_NON_VERBAL) {
				lead.Non_Verbal_Communication_Method__c = String.join(amq.describeCommunicationNeeds, ';');
				lead.Non_Verbal_Additional_Information__c = amq.describeCommunicationNeedsInformation;
			}
			System.debug('SAVING');
			System.debug('LEADZ-' + lead);
			update lead;

			SaveAdditionalMedicalQuestionsResultWrapper sqr = new SaveAdditionalMedicalQuestionsResultWrapper();
			sqr.lead = lead;
			sqr.saved = true;
			sqr.errorMessage = '';
			return sqr;
		} catch (Exception ex) {
			SaveAdditionalMedicalQuestionsResultWrapper sqr = new SaveAdditionalMedicalQuestionsResultWrapper();
			sqr.lead = lead;
			sqr.saved = false;
			sqr.errorMessage = ex.getMessage();
			return sqr;
		}
	}

	public class AdditionalMedicalQuestionsWrapper {
		@AuraEnabled
		public String leadId { get; set; }
		@AuraEnabled
		public Boolean isLeadQualifying { get; set; }
		@AuraEnabled
		public String wishChildFirstName { get; set; }
		@AuraEnabled
		public String unplannedHospitalAdmissions { get; set; }
		@AuraEnabled
		public String timesChildAdmitted { get; set; }
		@AuraEnabled
		public String admittedDiagnosis { get; set; }
		@AuraEnabled
		public String hospitalizationAdmissionIcu { get; set; }
		@AuraEnabled
		public String additionalClinicalDetails { get; set; }
		@AuraEnabled
		public String statementDescribePatient { get; set; }
		@AuraEnabled
		public String expectConditionDeteriorate { get; set; }
		@AuraEnabled
		public String expectConditionDeteriorateExplain { get; set; }
		@AuraEnabled
		public String medicalExpediteProcess { get; set; }
		@AuraEnabled
		public String medicalExpediteProcessReason { get; set; }
		@AuraEnabled
		public String provideTimeFrameWish { get; set; }
		@AuraEnabled
		public String provideTimeFrameWishInformation { get; set; }
		@AuraEnabled
		public String medicalSummaryAttachment { get; set; }
		@AuraEnabled
		public String additionalInfoProvide { get; set; }
		@AuraEnabled
		public String cognitiveDelay { get; set; }
		@AuraEnabled
		public String levelOfDelay { get; set; }
		@AuraEnabled
		public String speechLanguageDelay { get; set; }
		@AuraEnabled
		public String expressNeedsDesires { get; set; }
		@AuraEnabled
		public List<String> describeCommunicationNeeds { get; set; }
		@AuraEnabled
		public String describeCommunicationNeedsInformation { get; set; }
	}

	public class SaveAdditionalMedicalQuestionsResultWrapper {
		@AuraEnabled
		public Lead lead { get; set; }
		@AuraEnabled
		public Boolean saved { get; set; }
		@AuraEnabled
		public String errorMessage { get; set; }
	}

	// TODO: Temporary until we implement Sprint 2 Diagnosis Questions and Eligibility Service
	public static Boolean isLeadEligible(Id leadId) {
		Boolean isLeadEligible = false;
		List<Diagnosis_Verification__c> diagnosisVerificationLst = DiagnosisVerification_AC_Helper.getDiagnosisVerifications(leadId);
		for (Diagnosis_Verification__c dvs : diagnosisVerificationLst) {
			isLeadEligible = dvs.isEligible__c;
		}
		return isLeadEligible;
	}
}