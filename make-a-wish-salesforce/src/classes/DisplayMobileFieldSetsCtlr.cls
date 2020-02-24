/**
  * @description Apex controller for the DisplayMobileFieldSets lightning component
  * @author      Mason Buhler, Traction on Demand
  * @date        2019-07-25
  */
public with sharing class DisplayMobileFieldSetsCtlr {

	/**
	 * @description         Get all relevant field set names with included field names
	 *
	 * @param sObjectName   Name of the sObject to pull field sets from
	 *
	 * @return              List of relevant field sets with field names for each
	 */
	@AuraEnabled
	public static List<FieldSetInfo> getFieldSets(String sObjectName) {
		if (String.isEmpty(sObjectName)) {
			throw new AuraHandledException('sObject Name can\'t be blank.');
		}

		// Find all metadata entries for the appropriate sObject
		List<Mobile_Field_Sets__mdt> mobileFieldSetList = [
				SELECT Field_Set_API_Name__c, Object_API_Name__c
				FROM Mobile_Field_Sets__mdt
				WHERE Object_API_Name__c = :sObjectName
		];
		List<String> fieldSetNamesList = new List<String>();
		// Out of all available field sets, we only care about the ones listed in the custom metadata
		for (Mobile_Field_Sets__mdt mobileFieldSet : mobileFieldSetList) {
			fieldSetNamesList.add(mobileFieldSet.Field_Set_API_Name__c);
		}

		Map<String, Schema.FieldSet> fieldSetsByName;
		try {
			// Retrieve all field sets for the given sObject
			fieldSetsByName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fieldSets.getMap();
		} catch (Exception e) {
			throw new AuraHandledException('\'' + sObjectName + '\' is not a valid sObject name.');
		}

		List<FieldSetInfo> returnValue = new List<FieldSetInfo>();
		for (Schema.FieldSet fs : fieldSetsByName.values()) {
			List<String> currentFieldNames = new List<String>();
			// Filter out the field sets not specified in the metadata, or ones without any fields in them
			if (fieldSetNamesList.contains(fs.getName()) && !fs.getFields().isEmpty()) {
				FieldSetInfo fsi = new FieldSetInfo();
				fsi.fieldSetName = fs.getLabel();
				for (Schema.FieldSetMember fsm : fs.getFields()) {
					currentFieldNames.add(fsm.getFieldPath());
				}
				if (!currentFieldNames.isEmpty()) {
					fsi.fieldNames = currentFieldNames;
					returnValue.add(fsi);
				}
			}
		}
		// Return a list of all requested field sets for the given sObject, along with a list of fields for each
		return returnValue;
	}

	/**
	  * @description Wrapper class for returning data to the DisplayMobileFieldSets lightning component
	  * @author      Mason Buhler, Traction on Demand
	  * @date        2019-07-25
	  */
	public class FieldSetInfo {
		@AuraEnabled public String fieldSetName;
		@AuraEnabled public List<String> fieldNames;
	}

}