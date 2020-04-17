/**
 * @description Utils Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 7/15/2019
 */
@IsTest
public class Utils_Test {

	@IsTest
	private static void getPicklistLabels() {
		List<String> opportunityStages = Utils.getPicklistLabels('Opportunity', 'StageName');

		System.assert(!opportunityStages.isEmpty(), 'Picklist Labels should be available');
	}

	@IsTest
	private static void getFieldMap() {
		Map<String, String> opportunityStages = Utils.getFieldMap('Opportunity', 'StageName');

		System.assert(!opportunityStages.isEmpty(), 'Picklist Map should be available');
	}

	@IsTest
	private static void getPicklistSelectOptions() {
		List<SelectOption> opportunityStages = Utils.getPicklistSelectOptions(
				'Opportunity', 'StageName', 'Please select a Stage Name');

		System.assert(!opportunityStages.isEmpty(), 'Picklist Select Options should be available');
	}

	@IsTest
	private static void getFieldLabels() {
		Map<String, String> opportunityStages = Utils.getFieldLabels('Opportunity');

		System.assert(!opportunityStages.isEmpty(), 'Picklist Labels should be available');
	}

	@IsTest
	private static void getFieldPaths() {
		List<String> relationshipMedicalRelationships = Utils.getFieldPaths('npe4__Relationship__c', 'MedicalRelationships');

		System.assert(!relationshipMedicalRelationships.isEmpty(), 'Picklist Labels should be available');
	}

	@IsTest
	private static void formatDateToString() {
		Integer year = 2019;
		Integer month = 2;
		Integer day = 5;
		Date d = Date.newInstance(year, month, day);

		String result = Utils.formatDate(d, Utils.DATE_FORMAT_MDDYYYY);

		System.assertEquals('2/05/2019', result);
	}

	@IsTest
	private static void parseStringToDate() {
		Integer year = 2019;
		Integer month = 2;
		Integer day = 5;
		String dateWithSlash = month + '/' + day + '/' + year;
		String dateWithHyphen = month + '-' + day + '-' + year;

		Date result1 = Utils.parseDate(dateWithSlash, Utils.DATE_FORMAT_MDDYYYY);
		Date result2 = Utils.parseDate(dateWithHyphen, Utils.DATE_FORMAT_MDDYYYY);

		System.assertEquals(year, result1.year());
		System.assertEquals(month, result1.month());
		System.assertEquals(day, result1.day());
		System.assertEquals(year, result2.year());
		System.assertEquals(month, result2.month());
		System.assertEquals(day, result2.day());
	}

	@IsTest
	private static void generateRandomNumber() {
		Integer numberLength = 3;

		String result = Utils.generateRandomNumber(numberLength);

		System.assertEquals(3, result.length());
	}

	@IsTest
	private static void generateRandomNumberWhenInvalidLength() {
		Integer numberLength = null;

		String result = Utils.generateRandomNumber(numberLength);

		System.assertEquals(6, result.length());
	}

	@IsTest
	private static void removeNonNumericCharacters() {
		String alpanumericString = '(555)555-5555';

		String result = Utils.removeFormatNumberField(alpanumericString);

		System.assertEquals('5555555555', result);
	}

	@IsTest
	private static void parseAmPm_WhenHourMinuteAmPm() {
		String value = '10:30 PM';

		Time result = Utils.parseAmPm(value, new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM));

		System.assertEquals(Time.newInstance(22, 30, 0, 0), result);
	}

	@IsTest
	private static void parseAmPm_WhenHourMinuteSecondAmPm() {
		String value = '9:30:46 AM';

		Time result = Utils.parseAmPm(value, new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_SECOND_AM_PM));

		System.assertEquals(Time.newInstance(9, 30, 46, 0), result);
	}

	@IsTest
	private static void parseAmPm_WhenInvalidPattern() {
		String value = '9:30:46 AM';
		try {
			Utils.parseAmPm(value, new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM));
		} catch (Utils.UtilsException e) {
			System.assertEquals('Pattern HOUR_MINUTE_AM_PM does not match the value 9:30:46 AM provided', e.getMessage());
		}
	}
}