/**
 * @description LookupSObject Controller, exposes methods for the front end components.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 6/20/2019
 */
public with sharing class LookupSObjectCtlr {

	/**
	 * Find matching SObject record by keyword, SObject and return based on parameter
	 * @param searchString
	 * @param sObjectAPIName
	 * @param fieldsToReturn
	 * @param formattedOutput
	 * @param filter
	 * @return String
	 */
	@AuraEnabled
	public static String lookup(
			String searchString,
			String sObjectAPIName,
			String fieldsToReturn,
			String formattedOutput,
			Map<String, Object> filter,
			Boolean isExternalLookup) {

		// Sanitize the input
		String sanitizedSearchString = String.escapeSingleQuotes(searchString);
		String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
		String sanitizedFieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
		List<String> listFields = sanitizedFieldsToReturn.split(',');
		List<Result> results = new List<Result>();

		// Build our SOSL query
		String searchQuery = '';
		if (isExternalLookup && sObjectAPIName.equals('Contact')) {
			// Search only on a specific set of fields on Contact Lookup
			searchQuery = 'FIND \'' + sanitizedSearchString + '*\' ' +
					'IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName + '(' + sanitizedFieldsToReturn +
					' WHERE Exclude_MP_from_Referral_Form_Searches__c = FALSE AND npsp__Deceased__c = FALSE)' +
					' LIMIT 50';
		} else if (isExternalLookup && sObjectAPIName.equals('Account')) {
			searchQuery = 'FIND \'' + sanitizedSearchString + '*\' ' +
					'IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName + '(' + sanitizedFieldsToReturn +
					' WHERE Exclude_HTF_from_Referral_Form_Searches__c = FALSE)' +
					' LIMIT 50';
		} else {
			// Standard behaviour
			searchQuery = 'FIND \'' + sanitizedSearchString + '*\' ' +
					'IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(' + sanitizedFieldsToReturn + ') ' +
					'LIMIT 50';
		}

		// Execute the Query
		List<List<SObject>> searchList = Search.query(searchQuery);

		// Create a list of matches to return
		if (!searchList[0].isEmpty()) {
			String blank = '';
			for (SObject so : searchList[0]) {
				Result r = new Result();
				r.Id = so.Id;
				List<String> fieldValues = new List<String>();
				for (String f : listFields) {
					if (String.isEmpty(String.valueOf(so.get(f.trim())))) {
						fieldValues.add(blank);
					} else {
						fieldValues.add(String.valueOf(so.get(f.trim())));
					}
				}
				r.Description = String.format(formattedOutput, fieldValues);
				results.add(r);
			}
		}
		return JSON.serialize(results);
	}

	@AuraEnabled
	public static String loadObjectDescription(
			Id recordId,
			String sObjectAPIName,
			String fieldsToReturn,
			String formattedOutput) {
		// Sanitize the input
		String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
		String sanitizedFieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
		List<String> listFields = sanitizedFieldsToReturn.split(',');
		Result result = new Result();
		// Build our SOQL query
		String soqlQuery = 'SELECT ' + sanitizedFieldsToReturn +
				'  FROM ' + sanitizedSObjectAPIName +
				' WHERE Id = :recordId';
		List<SObject> objects = Database.query(soqlQuery);
		if (objects.size() > 0) {
			List<String> fieldValues = new List<String>();
			result.Id = (Id) objects[0].get('Id');
			for (String f : listFields) {
				fieldValues.add(String.valueOf(objects[0].get(f.trim())));
				result.Description = String.format(formattedOutput, fieldValues);
			}
		}
		return JSON.serialize(result);
	}

	// Wrapper class
	@TestVisible
	private class Result {
		@TestVisible
		String Id;
		@TestVisible
		String Description;
	}
}