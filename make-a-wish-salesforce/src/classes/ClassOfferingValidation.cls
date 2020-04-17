/**
 * @description Class Offering Validation, centralizes validations of Class Offering.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class ClassOfferingValidation {

	private final static String START_TIME = 'Start Time';
	private final static String END_TIME = 'End Time';

	/**
	 * Validate if Start and End Time values of Class Offering are valid
	 * @param classOfferings
	 */
	public static void validateStartEnd(List<Class_Offering__c> classOfferings) {
		Map<String, Time> timeConversion = new Map<String, Time>();
		Map<String, String> classOfferingStartTimeFieldMap = Utils.getFieldMap('Class_Offering__c', 'Start_Time__c');
		TimeRegexPattern regex = new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM);
		for (String fieldLabel : classOfferingStartTimeFieldMap.keySet()) {
			timeConversion.put(fieldLabel, Utils.parseAmPm(fieldLabel, regex));
		}
		for (Class_Offering__c classOffering : classOfferings) {
			if (String.isEmpty(classOffering.Start_Time__c) && !timeConversion.containsKey(classOffering.Start_Time__c)) {
				classOffering.addError(String.format(Label.Enter_Valid, new List<String>{START_TIME}));
			}
			if (String.isEmpty(classOffering.End_Time__c) && !timeConversion.containsKey(classOffering.End_Time__c)) {
				classOffering.addError(String.format(Label.Enter_Valid, new List<String>{END_TIME}));
			}
			if ((timeConversion.get(classOffering.Start_Time__c) >= timeConversion.get(classOffering.End_Time__c))) {
				classOffering.addError(Label.Invalid_Start_and_End_Time);
			}
		}
	}
}