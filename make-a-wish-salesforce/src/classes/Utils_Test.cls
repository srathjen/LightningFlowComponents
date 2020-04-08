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
	private static void parseStringToDate(){
		Integer year = 2019;
		Integer month = 2;
		Integer day = 5;
		String dateWithSlash = month +'/'+day+'/'+year;
		String dateWithHyphen = month +'-'+day+'-'+year;

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
	private static void generateRandomNumber(){
		Integer numberLength = 3;

		String result = Utils.generateRandomNumber(numberLength);

		System.assertEquals(3, result.length());
	}

	@IsTest
	private static void generateRandomNumberWhenInvalidLength(){
		Integer numberLength = null;

		String result = Utils.generateRandomNumber(numberLength);

		System.assertEquals(6, result.length());
	}

	@IsTest
	private static void removeNonNumericCharacters(){
		String alpanumericString = '(555)555-5555';

		String result = Utils.removeFormatNumberField(alpanumericString);

		System.assertEquals('5555555555', result);
	}
}