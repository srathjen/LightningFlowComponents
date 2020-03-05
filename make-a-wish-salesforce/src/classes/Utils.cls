/**
 * @description Utility methods, standardizing and providing reuse
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 7/15/2019
 */
public class Utils {

	public class UtilsException extends Exception {
	}

	public static final String DATE_FORMAT_MDDYYYY = 'M/dd/yyyy';
	/**
	 * Find Picklist Labels
	 * @param sObjectApiName
	 * @param fieldApiName
	 *
	 * @return
	 */
	public static List<String> getPicklistLabels(String sObjectApiName, String fieldApiName) {
		List<String> pickListLabels = new List<String>();
		try {
			Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
			Schema.DescribeFieldResult fieldResult = fieldsByName.get(fieldApiName).getDescribe();
			List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

			for (Schema.PicklistEntry pickListValue : picklistEntries) {
				pickListLabels.add(pickListValue.getLabel());
			}
		} catch (Exception e) {
			System.debug('Error in get picklist labels: line' + e.getLineNumber() + ', ' + e.getMessage());
		}
		return pickListLabels;
	}

	/**
	 * Find field labels
	 * @param sObjectApiName
	 *
	 * @return
	 */
	public static Map<String, String> getFieldLabels(String sObjectApiName) {
		Map<String, String> fieldLabelsMap = new Map<String, String>();
		try {
			Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
			for (String fieldName : fieldsByName.keySet()) {
				String fieldLabel = fieldsByName.get(fieldName).getDescribe().label;
				fieldLabelsMap.put(fieldName, fieldLabel);
			}
		} catch (Exception e) {
			System.debug('Error in get field labels: line' + e.getLineNumber() + ', ' + e.getMessage());
		}
		return fieldLabelsMap;
	}

	/**
	 * Format a Date field
	 *
	 * @param date
	 * @param format
	 * @return Formatted String Date
	 */
	public static String formatDate(Date d, String format) {
		try {
			Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
			return dt.format(format);
		} catch (Exception e) {
			throw new UtilsException('Unable to format Date: ' + e);
		}
	}

	/**
	 * Parse a String to a Date
	 *
	 * @param date
	 * @param currentFormat
	 * @return Date
	 */
	public static Date parseDate(String d, String currentFormat) {
		try {
			if (String.isEmpty(d) || String.isEmpty(currentFormat)) {
				return null;
			}
			if (DATE_FORMAT_MDDYYYY.equals(currentFormat)) {
				if (d.containsAny('/')) {
					String [] dateParts = d.split('/');
					Integer month = Integer.valueOf(dateParts[0]);
					Integer day = Integer.valueOf(dateParts[1]);
					Integer year = Integer.valueOf(dateParts[2]);
					return Date.newInstance(year, month, day);
				} else if (d.containsAny('-')) {
					String [] dateParts = d.split('-');
					Integer month = Integer.valueOf(dateParts[0]);
					Integer day = Integer.valueOf(dateParts[1]);
					Integer year = Integer.valueOf(dateParts[2]);
					return Date.newInstance(year, month, day);
				}
			}
		} catch (Exception e) {
			throw new UtilsException('Unable to parse Date: ', e);
		}
		throw new UtilsException('Unsupported format');
	}

	/**
	 * Generate random number
	 * @return
	 */
	public static String generateRandomNumber(Integer length) {
		if (length == null || length <= 0) {
			length = 6;
		}
		final String chars = '0123456789';
		String randStr = '';
		while (randStr.length() < length) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx + 1);
		}
		return randStr;
	}

	/*
     * Static function to convert a comma separated String to a List<SelectOption>
     *
     * @param String picklistString
     *
     * @return List<SelectOption>
     *
     * @author Chris Shinnimin, Traction on Demand
     * @date 2020-03-03
    */
	public static List<SelectOption> picklistStringToOptions(String picklistString) {
		List<SelectOption> selectOptions = new List<SelectOption>();

		if (String.isBlank(picklistString)) {
			return selectOptions;
		}

		selectOptions.add(new SelectOption('', 'Please Select'));
		for (String currString : picklistString.split(',')) {
			selectOptions.add(new SelectOption(currString, currString));
		}

		return selectOptions;
	}
}