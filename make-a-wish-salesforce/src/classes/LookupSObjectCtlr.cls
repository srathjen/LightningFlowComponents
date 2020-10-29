/**
 * @description LookupSObject Controller, exposes methods for the front end components.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 6/20/2019
 */
public with sharing class LookupSObjectCtlr {

	private final static Id medicalProfessionalRT = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id hospitalFacilityRT = Constant_AC.HOSPITAL_TREATMENT_ID;

	/**
	 * Find matching SObject record by keyword, SObject and return based on parameter
	 * @param searchString searchString
	 * @param sObjectAPIName sObjectAPIName
	 * @param fieldsToReturn fieldsToReturn
	 * @param formattedOutput formattedOutput
	 * @param filter filter
	 * @param isExternalLookup isExternalLookup
	 * @return String
	 */
	@AuraEnabled
	public static String lookup(
			String searchString,
			String sObjectAPIName,
			String fieldsToReturn,
			String formattedOutput,
			Map<String, String> filter,
			Boolean isExternalLookup) {

		// Sanitize the input
		String sanitizedSearchString = String.escapeSingleQuotes(searchString);
		String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
		String sanitizedFieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
		List<String> listFields = sanitizedFieldsToReturn.split(',');
		List<Result> results = new List<Result>();
		filter = filter == null ? new Map<String, String>() : filter;

		// Build our SOSL query
		String searchQuery = '';
		if (isExternalLookup && sObjectAPIName.equals('Contact')) {
			filter.put('RecordTypeId', 'RecordTypeId = ' + '\'' + medicalProfessionalRT + '\'');
			filter.put('Exclude_MP_from_Referral_Form_Searches__c', 'Exclude_MP_from_Referral_Form_Searches__c = FALSE');
			filter.put('npsp__Deceased__c', 'npsp__Deceased__c = FALSE');
			String whereClause = buildQueryFilters(filter);
			// Search only on a specific set of fields on Medical Professional Contact Lookup
			searchQuery = 'FIND \'' + sanitizedSearchString + '*\' ' +
					'IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName +
					'(' + sanitizedFieldsToReturn + whereClause + ')' +
					' LIMIT 50';
		} else if (isExternalLookup && sObjectAPIName.equals('Account')) {
			// Search only on a specific set of fields on Hospital/Facility Account Lookup
			filter.put('RecordTypeId', 'RecordTypeId = ' + '\'' + hospitalFacilityRT + '\'');
			filter.put('Exclude_HTF_from_Referral_Form_Searches__c', 'Exclude_HTF_from_Referral_Form_Searches__c = FALSE');
			String whereClause = buildQueryFilters(filter);
			searchQuery = 'FIND \'' + sanitizedSearchString + '*\' ' +
					'IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName +
					'(' + sanitizedFieldsToReturn + whereClause + ')' +
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
				String cleanFormattedOutput = cleanFormattedOutput(fieldValues, formattedOutput);
				r.Description = String.format(cleanFormattedOutput, fieldValues);
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
				String cleanFormattedOutput = cleanFormattedOutput(fieldValues, formattedOutput);
				result.Description = String.format(cleanFormattedOutput, fieldValues);
			}
		}
		return JSON.serialize(result);
	}

	private static String buildQueryFilters(Map<String, String> filterMap){
		String filter = '';
		for(String f : filterMap.keySet()){
			if(String.isEmpty(filterMap.get(f))) {
				continue;
			}
			if(String.isEmpty(filter)){
				filter = ' WHERE ' + filterMap.get(f);
			} else {
				filter = filter + ' AND ' + filterMap.get(f);
			}
		}
		return filter;
	}

	private static String cleanFormattedOutput(List<String> fieldValues, String formattedOutput){
		List<String> formattedOutputGroup = new List<String>();
		String token = '';
		List<String> tokens = formattedOutput.splitByCharacterType();
		for(Integer i=0; i<tokens.size(); i++){
			String s = tokens[i];
			if(s.equals('{') && token.contains('{') && token.contains('}')){
				formattedOutputGroup.add(token);
				token = '';
				token += s;
			} else if(tokens.size() == i+1){
				token += s;
				formattedOutputGroup.add(token);
			} else {
				token += s;
			}
		}
		List<String> formattedOutputList = new List<String>();
		for(Integer i=0; i<fieldValues.size(); i++){
			if(String.isNotEmpty(fieldValues[i])){
				formattedOutputList.add(formattedOutputGroup[i]);
			}
		}
		String cleanedFormattedOutput = String.join(formattedOutputList, '');
		Integer lastBracket = cleanedFormattedOutput.lastIndexOf('}');
		if(!String.valueOf(cleanedFormattedOutput.getChars()).equals(String.valueOf(lastBracket))){
			cleanedFormattedOutput = cleanedFormattedOutput.substring(0, lastBracket+1);
		}
		return cleanedFormattedOutput;
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