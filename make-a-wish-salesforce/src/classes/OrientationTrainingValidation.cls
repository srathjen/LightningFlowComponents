/**
 * @description Orientation and Training Validation, centralizes validations of Orientation and Training.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class OrientationTrainingValidation {

	private final static String START_TIME = 'Start Time';
	private final static String END_TIME = 'End Time';

	/**
	 * Validate if Start and End Time values of Orientation and Training are valid
	 * @param orientationTrainings
	 */
	public static void validateStartEnd(List<Orientation_Training__c> orientationTrainings) {
		Map<String, Datetime> timeConversion = new Map<String, Datetime>();
		Map<String, String> orientationTrainingStartTimeFieldMap = Utils.getFieldMap('Orientation_Training__c', 'Start_Time__c');
		TimeRegexPattern regex = new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM);
		for (String fieldLabel : orientationTrainingStartTimeFieldMap.keySet()) {
			timeConversion.put(fieldLabel, Utils.parseAmPm(fieldLabel, regex));
		}
		for (Orientation_Training__c orientationTraining : orientationTrainings) {
			if (String.isEmpty(orientationTraining.Start_Time__c) || !timeConversion.containsKey(orientationTraining.Start_Time__c)) {
				orientationTraining.addError(String.format(Label.Enter_Valid, new List<String>{
						START_TIME
				}));
			} else if (String.isEmpty(orientationTraining.End_Time__c) || !timeConversion.containsKey(orientationTraining.End_Time__c)) {
				orientationTraining.addError(String.format(Label.Enter_Valid, new List<String>{
						END_TIME
				}));
			} else if ((timeConversion.get(orientationTraining.Start_Time__c) >= timeConversion.get(orientationTraining.End_Time__c))) {
				orientationTraining.addError(Label.Invalid_Start_and_End_Time);
			}
		}
	}
}