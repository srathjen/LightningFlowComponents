/**
 * @description Utility methods, standardizing and providing reuse
 *
 * @author Gustavo Mayer, Traction on Demand
 *
 * @date 7/15/2019
 */
public class Utils {

    public class UtilsException extends Exception {
    }

    public static final String DATE_FORMAT_MDDYYYY = 'M/dd/yyyy';
    public static final String AM = 'AM';
    public static final String PM = 'PM';

    private static final String EMAIL_REGEX = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';

    public static final Map<String, String> TIME_ZONE_MAP = new Map<String, String>{
            '(GMT-07:00) Mountain Standard Time (America/Phoenix)' => 'America/Phoenix',
            '(GMT-02:00) Brasilia Summer Time (America/Sao_Paulo)' => 'America/Sao_Paulo',
            '(GMT-03:00) Argentina Time (America/Argentina/Buenos_Aires)' => 'America/Argentina/Buenos_Aires',
            '(GMT-03:00) Chile Summer Time (America/Santiago)' => 'America/Santiago',
            '(GMT-03:30) Newfoundland Standard Time (America/St_Johns)' => 'America/St_Johns',
            '(GMT-04:00) Atlantic Standard Time (America/Halifax)' => 'America/Halifax',
            '(GMT-04:00) Atlantic Standard Time (America/Puerto_Rico)' => 'America/Puerto_Rico',
            '(GMT-04:30) Venezuela Time (America/Caracas)' => 'America/Caracas',
            '(GMT-05:00) Colombia Time (America/Bogota)' => 'America/Bogota',
            '(GMT-05:00) Eastern Standard Time (America/Indiana/Indianapolis)' => 'America/Indiana/Indianapolis',
            '(GMT-05:00) Peru Time (America/Lima)' => 'America/Lima',
            '(GMT-05:00) Eastern Standard Time (America/New_York)' => 'America/New_York',
            '(GMT-05:00) Eastern Standard Time (America/Panama)' => 'America/Panama',
            '(GMT-06:00) Central Standard Time (America/Chicago)' => 'America/Chicago',
            '(GMT-06:00) Central Standard Time (America/El_Salvador)' => 'America/El_Salvador',
            '(GMT-06:00) Central Standard Time (America/Mexico_City)' => 'America/Mexico_City',
            '(GMT-07:00) Mountain Standard Time (America/Denver)' => 'America/Denver',
            '(GMT-07:00) Mountain Standard Time (America/Phoenix)' => 'America/Phoenix',
            '(GMT-08:00) Pacific Standard Time (America/Los_Angeles)' => 'America/Los_Angeles',
            '(GMT-08:00) Pacific Standard Time (America/Tijuana)' => 'America/Tijuana',
            '(GMT-09:00) Alaska Standard Time (America/Anchorage)' => 'America/Anchorage'
    };

    /**
     * @description Retrieve information about the current user.
     *
     * @author Chris Shinnimin, Traction on Demand
     *
     * @date 2020-03-18
     */
    public static User currentUser {
        get {
            if (currentUser == null) {
                currentUser = [
                        SELECT Id, Name, Chapter_Name__c, UserRole.Name, ProfileId, Profile.Id, Profile.Name, ContactId,
                                Contact.Account.Volunteer_Manager__c, Contact.OwnerId, Hidden_Role_Name_Id__c, CreatedDate
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                        LIMIT 1
                ];
            }
            return currentUser;
        }
        set;
    }

    /**
     * @description Find Picklist Field Label / Values Map
     *
     * @param sObjectApiName
     * @param fieldApiName
     *
     * @return List of Picklist Options
     */
    public static Map<String, String> getFieldMap(String sObjectApiName, String fieldApiName) {
        Map<String, String> fieldMap = new Map<String, String>();
        try {
            Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
            Schema.DescribeFieldResult fieldResult = fieldsByName.get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListValue : picklistEntries) {
                fieldMap.put(pickListValue.getLabel(), pickListValue.getValue());
            }
        } catch (Exception e) {
            System.debug('Error in get picklist labels and values map: line' + e.getLineNumber() + ', ' + e.getMessage());
        }
        return fieldMap;
    }

    /**
     * @description Find Picklist Labels
     *
     * @param sObjectApiName
     * @param fieldApiName
     *
     * @return List of Picklist Options
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
     * @description Find Picklist Select Options
     *
     * @param sObjectApiName
     * @param fieldApiName
     * @param optionalPlaceholderOption
     *
     * @return List of Picklist Options
     */
    public static List<SelectOption> getPicklistSelectOptions(String sObjectApiName, String fieldApiName, String optionalPlaceholderOption) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        try {
            Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
            List<Schema.PicklistEntry> picklistEntries = fieldsByName.get(fieldApiName).getDescribe().getPicklistValues();
            if (optionalPlaceholderOption != null) {
                selectOptions.add(new SelectOption('', optionalPlaceholderOption));
            }
            for (Schema.PicklistEntry pickListValue : picklistEntries) {
                selectOptions.add(new SelectOption(pickListValue.getLabel(), pickListValue.getValue()));
            }
        } catch (Exception e) {
            System.debug('Error in get picklist select options: line' + e.getLineNumber() + ', ' + e.getMessage());
        }
        return selectOptions;
    }

    /**
     * @description Find Field Paths
     *
     * @param sObjectApiName
     * @param fieldApiName
     *
     * @return List of Field Paths
     */
    public static List<String> getFieldPaths(String sObjectApiName, String fieldApiName) {
        List<String> fieldPaths = new List<String>();
        try {
            Map<String, FieldSet> fieldSetMap = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fieldSets.getMap();
            List<FieldSetMember> fieldSetMembers = fieldSetMap.get(fieldApiName).getFields();

            for (Schema.FieldSetMember fieldPath : fieldSetMembers) {
                fieldPaths.add(fieldPath.getFieldPath());
            }
        } catch (Exception e) {
            System.debug('Error in get field set labels: line' + e.getLineNumber() + ', ' + e.getMessage());
        }
        return fieldPaths;
    }

    /**
     * @description Find field labels
     *
     * @param sObjectApiName
     *
     * @return Map of Picklist Options
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
     * @description Format a Date field
     *
     * @param d
     * @param format
     *
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
     * @description Parse a String to a Date
     *
     * @param d
     * @param currentFormat
     *
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
     * @description Generate random number
     *
     * @param length
     *
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

    /**
     * @description Generates a string of lowercase letters of specified length;
     *
     * @param numCharacters
     *
     * @return String
     */
    public static String generateRandomCharacterString(Integer numCharacters) {
        if (numCharacters == null || numCharacters <= 0) {
            numCharacters = 6;
        }
        final String characters = 'abcdefghijklmnopqrstuvwxyz';
        String returnString = '';
        for (Integer i = 0; i < numCharacters; i++) {
            returnString += Math.mod(Math.abs(Crypto.getRandomInteger()), characters.length() - 1);
        }
        return returnString;
    }

    /**
     * @description Generates a random email address.
     *
     * @return
     */
    public static String generateRandomEmailAddress() {
        return generateRandomCharacterString(5) + '@' + generateRandomCharacterString(5) + '.' + generateRandomCharacterString(3);
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
    public static List<SelectOption> picklistStringToOptions(String picklistString, String optionalPlaceholderOption) {
        List<SelectOption> selectOptions = new List<SelectOption>();

        if (String.isBlank(picklistString)) {
            return selectOptions;
        }

        if (optionalPlaceholderOption != null) {
            selectOptions.add(new SelectOption('', optionalPlaceholderOption));
        }

        for (String currString : picklistString.split(',')) {
            selectOptions.add(new SelectOption(currString, currString));
        }

        return selectOptions;
    }

    /**
     * @description Phone fields are currently String type fields and are being used in comparision,
     * but when compared they are coming formatted and some are not causing the if statetment to fail
     * e.g: (555)555-5555 is not equal to 5555555555
     * Creating a method to remove special characters and alphabet
     *
     * @param field
     *
     * @return String
     */
    public static String removeFormatNumberField(String field) {
        if (String.isNotEmpty(field)) {
            return field.replaceAll('[^0-9]', '');
        }
        return field;
    }

    /*
     * @description		"Self Fieldset, it holds the mandatory fields of Self relationship."
     * 					This function was noticed duplicated in multiple classes, so pulled out
     * 					during code cleanup (Chris Shinnimin, Traction on Demand).
     *
     * @return			List<Schema.FieldSetMember>
     *
     * @date			unknown
     * @author			MST Solutions
     */
    public static List<Schema.FieldSetMember> getPartAFields() {
        return SObjectType.Lead.fieldSets.Diagnosis_Verfication_Fieldset.getFields();
    }

    /*
     * @description 		Create a Map of sObject labels by Schema.SObjectFields.
     *
     * @param               Schema.DescribeSObjectResult describe: the sObject type
     *
     * @return              Map<Schema.SObjectField,String>
     *
     * @author				Chris Shinnimin, Traction on Demand
     * @date				2020-03-30
    */
    public static Map<Schema.SObjectField, String> mapOfSObjectLabelsByFields(Schema.DescribeSObjectResult describe) {
        Map<Schema.SObjectField, String> mapOfSObjectLabelsByFields = new Map<Schema.SObjectField, String>();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(describe.Name);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        List<Schema.SObjectField> allFields = (describe.fields.getMap()).values();

        for (Schema.SObjectField field : allFields) {
            mapOfSObjectLabelsByFields.put(field, fieldMap.get(String.valueOf(field)).getDescribe().getLabel());
        }

        return mapOfSObjectLabelsByFields;
    }

    public static Datetime parseAmPm(String value, TimeRegexPattern regex) {
        Pattern p = Pattern.compile(regex.getPattern());
        Matcher m = p.matcher(value);
        if (!m.matches()) {
            throw new UtilsException('Pattern ' + regex.getPatternKey() + ' does not match the value ' + value + ' provided');
        } else if (TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM.equals(regex.getPatternKey())) {
            Integer hour = Integer.valueOf(m.group(1));
            Integer minute = Integer.valueOf(m.group(2));
            Integer shift = m.group(3).toUpperCase().equals(PM) ? 12 : 0;
            if (hour == 12 && m.group(3).toUpperCase().equals(AM)) {
                return Datetime.newInstanceGmt(Date.today().addDays(1), Time.newInstance(hour + 12, minute, 0, 0));
            } else if ((hour + shift) == 24) {
                return Datetime.newInstanceGmt(Date.today(), Time.newInstance(hour, minute, 0, 0));
            }
            return Datetime.newInstanceGmt(Date.today(), Time.newInstance(hour + shift, minute, 0, 0));
        } else if (TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_SECOND_AM_PM.equals(regex.getPatternKey())) {
            Integer hour = Integer.valueOf(m.group(1));
            Integer minute = Integer.valueOf(m.group(2));
            Integer second = Integer.valueOf(m.group(3));
            Integer shift = m.group(4).toUpperCase().equals(PM) ? 12 : 0;
            if (hour == 12 && m.group(4).toUpperCase().equals(AM)) {
                return Datetime.newInstanceGmt(Date.today().addDays(1), Time.newInstance(hour + 12, minute, second, 0));
            } else if ((hour + shift) == 24) {
                return Datetime.newInstanceGmt(Date.today(), Time.newInstance(hour, minute, second, 0));
            }
            return Datetime.newInstanceGmt(Date.today(), Time.newInstance(hour + shift, minute, second, 0));
        } else {
            throw new UtilsException('Error while trying to parse value');
        }
    }

    /**
     * @description Get a Map of UserRole.Name by User Id.
     *
     * @param userIds
     *
     * @return Map<Id,String>
     *
     * @author MST Solutions
     *
     * @date unknown
     */
    public static Map<Id, String> getUserRoleMap(Set<Id> userIds) {
        Map<Id, String> userRoleMap = new Map<Id, String>();

        for (User currUser : [
                SELECT Id, UserRole.Name
                FROM User
                WHERE Id IN :userIds
        ]) {
            userRoleMap.put(currUser.Id, currUser.UserRole.Name);
        }

        return userRoleMap;
    }

    /**
     * @description Validate whether a String contains an email address.
     *
     * @param email
     *
     * @return Boolean
     *
     * @author unknown
     *
     * @date unknown
     */
    public static Boolean isEmail(String email) {
        Pattern MyPattern = Pattern.compile(EMAIL_REGEX);
        Matcher MyMatcher = MyPattern.matcher(email);

        return MyMatcher.matches();
    }
}