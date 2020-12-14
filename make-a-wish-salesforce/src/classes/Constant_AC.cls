/**
 * @description Constants class
 * @author      Gustavo Mayer, Traction on Demand
 * @createdDate 6-19-2019
 // 04/28/2020 - Manoj - SIW-563 : Added label for 'Other'
 // 07/29/2020 - Manoj - SIW-378: Added labels for static text
 // 08/21/2020 - Manoj - SIW-669: Added label COMMENT_BOX_TEXT
 */
public class Constant_AC {
	public final static String CONTACT_WISH_CHILD_RT_LABEL = 'Wish Child';
	public final static Id CONTACT_WISH_CHILD_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Wish_Child').getRecordTypeId();
	public final static Id IN_KIND_ACCOUNT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('In_Kind_Donors').getRecordTypeId();
	public final static Id DETERMINATION_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Wish_Determination').getRecordTypeId();
	public final static Id PLANNING_ANTICIPATION_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Wish_Planning').getRecordTypeId();
	public final static Id WISH_ASSIST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Wish_Assist').getRecordTypeId();
	public final static Id GRANT_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Wish_Granting').getRecordTypeId();
	public final static Id WISH_FAMILY_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Wish_Family').getRecordTypeId();
	public final static String WISH_FAMILY_RT_LABEL = 'Wish Family';
	public final static Id WISH_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Wish').getRecordTypeId();
	public final static Id MEDICAL_PROFESSIONAL_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medical_Professional').getRecordTypeId();
	public final static String MEDICAL_PROFESSIONAL_RT_LABEL = 'Medical Professional';
	public final static String Other_RT_LABEL = 'Other';
	public final static Id ORGANIZATION_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
	public final static Id HOUSEHOLD_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();
	public final static Id CHAPTER_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Chapter').getRecordTypeId();
	public final static Id ORIENTATION_RT_ID = Schema.SObjectType.Orientation_Training__c.getRecordTypeInfosByDeveloperName().get('Orientation').getRecordTypeId();
	public final static Id TRAINING_RT_ID = Schema.SObjectType.Orientation_Training__c.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();
	public final static Id VOLUNTEER_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer_Contact').getRecordTypeId();
	public final static String VOLUNTEER_RT_LABEL = 'Volunteer Contact';
	public final static Id PROSPECTIVE_VOLUNTEER_RT_ID = Schema.SObjectType.Dynamic_Content__c.getRecordTypeInfosByDeveloperName().get('Chapter_Prospective').getRecordTypeId();
	public final static Id NATIONAL_RT_ID = Schema.SObjectType.Dynamic_Content__c.getRecordTypeInfosByDeveloperName().get('National').getRecordTypeId();
	public final static Id INTERVIEW_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Interview').getRecordTypeId();
	public final static Id TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
	public final static Id EVENTS_ID = Schema.SObjectType.Non_Wish_Events__c.getRecordTypeInfosByDeveloperName().get('Events').getRecordTypeId();
	public final static Id ACTIVE_VOL_RT_ID = Schema.SObjectType.Dynamic_Content__c.getRecordTypeInfosByDeveloperName().get('Chapter_Active').getRecordTypeId();
	public final static Id WISH_VOLUNTEER_OPPORTUNITY_ID = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Wish').getRecordTypeId();
	public final static Id BACKGROUND_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Background_Check').getRecordTypeId();
	public final static Id NON_WISH_EVENT_RT_ID = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Non_Wish_Event').getRecordTypeId();
	public final static Id NON_WISH_RT_ID = Schema.SObjectType.Non_Wish_Events__c.getRecordTypeInfosByDeveloperName().get('Non_Wish').getRecordTypeId();
	public final static Id CLASS_OFFERING_RECORD_TYPE_ID = Schema.SObjectType.Class_Offering__c.getRecordTypeInfosByDeveloperName().get('Virtual_Self_Paced').getRecordTypeId();
	public final static Id TRAVEL_ALGM_RT_ID = Schema.SObjectType.Medical_Questions__c.getRecordTypeInfosByDeveloperName().get('Travel_Algorithm').getRecordTypeId();
	public final static Id BUDGETING_RT_ID = Schema.SObjectType.Wish_Expense__c.getRecordTypeInfosByDeveloperName().get('Budgeting').getRecordTypeId();
	public final static String IN_KIND_DONATION_RT_LABEL = 'In-Kind Donation';
	public final static String IN_KIND_REIMBURSEMENT_RT_LABEL = 'Reimbursement';
	public final static Id IN_KIND_ID = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByDeveloperName().get('In_Kind_Donation').getRecordTypeId();
	public final static Id REIMBURSEMENT_ID = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByDeveloperName().get('Reimbursement').getRecordTypeId();
	public final static Id DIAGNOSIS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnosis_Verification_Review').getRecordTypeId();
	public final static String BOARD_MEMBER_RT_LABEL = 'Board Member';
	public final static Id BOARD_MEMBER_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Board_Member').getRecordTypeId();
	public final static Id HOSPITAL_TREATMENT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Hospital_Treatment_Facility').getRecordTypeId();
	public final static Id UPDATE_CONTACT_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Contact_Updates').getRecordTypeId();
	public final static Id REGISTERED_WISH_ID = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Volunteer_Registered_Wish').getRecordTypeId();
	public final static Id REGISTERED_NON_WISH_ID = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Volunteer_Registered_Non_Wish').getRecordTypeId();
	public final static Id VOLUNTEER_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
	public final static String VOLUNTEER_TASK_RT_LABEL = 'Volunteer';
	public final static Id STAFF_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
	public final static Id WISH_CLEARANCE_ATTACHMENT_ID = Schema.SObjectType.Minor_Participant__c.getRecordTypeInfosByDeveloperName().get('Wish_Clarence_Attachment').getRecordTypeId();
	public final static Id COMBO_RECORD_ID = Schema.SObjectType.Minor_Participant__c.getRecordTypeInfosByDeveloperName().get('Combo_Form_Attachment').getRecordTypeId();
	public final static Id WISH_EXPENSE_RT_FINANCE = Schema.SObjectType.Wish_Expense__c.getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
	public static final String TYPE_LIGHTNING = 'Lightning';
	public static final String TYPE_CLASSIC = 'Classic';
	public static final String THEME_4D = 'Theme4d';
	public static final String THEME_4U = 'Theme4u';

	/**
	* Test Related Constants
	*/
	public static final String TEST_EXCEPTION_ERROR = 'Test Class execution';

	/**
	* sObject Api Names and Labels
	*/
	public final static String WISH_AFFILIATION_API_NAME = Schema.SObjectType.Wish_Affiliation__c.getName();
	public final static String CONTACT_API_NAME = Schema.SObjectType.Contact.getName();
	public final static String RELATIONSHIP_API_NAME = Schema.SObjectType.npe4__Relationship__c.getName();

	/**
	 * Account Constants
	 */
	public static final String ACCOUNT_NAME_MAW_AMERICA = 'Make-A-Wish America';
	public static final String ACCOUNT_NAME_MAW_ALABAMA = 'Make-A-Wish Alabama';
	public static final String FAMILY_HOUSEHOLD_NAME_APPEND = ' ' + ' & ' + ' ' + 'Family Household';

	/**
	 * Affiliation Constants
	 */
	public final static String ORG_AFFILIATION_STATUS_ACTIVE = 'Active';
	public final static String ORG_AFFILIATION_STATUS_INACTIVE = 'Inactive';
	public final static String ORG_AFFILIATION_STATUS_PENDING = 'Pending';
	public final static String ORG_AFFILIATION_STATUS_CURRENT = 'Current';
	public final static String ORG_AFFILIATION_TREATING_FACILITY_CURRENT = 'Current';
	public final static String ORG_AFFILIATION_STATUS_NOT_APPROVED = 'Not Approved';
	public final static String ORG_AFFILIATION_STATUS_OUT_OF_COMPLIANCE = 'Out of Compliance';
	public final static String ORG_AFFILIATION_STATUS_PROSPECTIVE = 'Prospective';

	/**
	 * Lead Constants
	 */
	public static final Id LEAD_RT_WISH_CHILD = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Wish_Child').getRecordTypeId();
	public static final String LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL = 'Referring Medical Professional';
	public static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = 'Treating Medical Professional';
	public static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = 'Best contact for Physician';
	public static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = 'Alternate 1 Medical Professional';
	public static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = 'Alternate 2 Medical Professional';
	public static final String LEAD_STATUS_NEW = 'New';
	public static final String LEAD_STATUS_DNQ = 'DNQ';
	public static final String LEAD_STATUS_DUPLICATE = 'Duplicate';
	public static final String LEAD_STATUS_DECEASED = 'Deceased';
	public static final String LEAD_STATUS_QUALIFIED = 'Qualified';
	public static final String LEAD_STATUS_INQUIRY = 'Inquiry';
	public static final String LEAD_STATUS_REFERRED = 'Referred';
	public static final String LEAD_STATUS_ELIGIBILITY_REVIEW = 'Eligibility Review';
	public static final String LEAD_CHILD_AGE_UNDER_2_5 = 'Under 2.5';
	public static final String LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION = 'Pending Diagnosis Verification';
	public static final String LEAD_SUB_STATUS_PENDING_PART_A = 'Pending Part A';
	public static final String LEAD_SUB_STATUS_PENDING_PAPER_DV = 'Pending Paper DV';
	public static final String LEAD_SUB_STATUS_PENDING_CLARIFICATION_CHAPTER = 'Pending Clarification - Chapter';
	public static final String LEAD_SUB_STATUS_ADDITIONAL_INFORMATION_FOR_REVIEW = 'Additional Information for Review';
	public static final String LEAD_SUB_STATUS_MEDICAL_REVIEWED = 'Medical Reviewed';
	public static final String LEAD_DUP_CHECK_BLOCK_LEAD_DUP = 'Block Lead Dup';
	public static final String LEAD_DUP_CHECK_BLOCK_CONTACT_DUP = 'Block Contact Dup';
	public static final String LEAD_COUNTRY_UNITED_STATES = 'United States';
	public static final String LEAD_COMPANY_MAKE_A_WISH = 'Make-A-Wish';
	public static final String LEAD_SOURCE_ONLINE = 'Online';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_OTHER = 'Other';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_SELF = 'Self';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN = 'Parent/Guardian';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_MEDICAL_PROFESSIONAL = 'Medical Professional';
	public static final String LEAD_MEDICAL_PROVIDER_NURSE_PRACTITIONER = 'Nurse Practitioner';
	public static final String LEAD_MEDICAL_PROVIDER_PHYSICIAN_ASSISTANT = 'Physician Assistant';
	public static final String LEAD_MEDICAL_PROVIDER_PHYSICIAN = 'Physician';
	public static final String LEAD_NUMBER_OF_SIBLINGS_UNKNOWN = 'Unknown';
	public static final String LEAD_COMATOSE_VEGETATIVE_STATE_YES = 'Yes';
	public static final String LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES = 'Yes';
	public static final String LEAD_ERROR_WISH_CHILD = 'Wish Child';
	public static final String LEAD_ERROR_WISH_ADDITIONAL_PARENT_GUARDIAN = 'Additional Parent/Guardian';
	public static final String LEAD_ERROR_WISH_FAMILY = 'Wish Family';
	public static final String LEAD_RFI_FORM_INFO_QUALIFIED = 'Qualified';
	public static final String LEAD_RFI_FORM_INFO_NOT_QUALIFIED = 'Not Qualified';

	/**
	 * Case Constants
	 */
	public static final String CASE_STATUS_WISH_DETERMINED = 'Wish Determined';
	public static final String CASE_STATUS_WISH_DESIGN = 'Wish Design';
	public static final String CASE_STATUS_WISH_SCHEDULED = 'Wish Scheduled';
	public static final String CASE_STATUS_PENDING_APPROVAL = 'Pending Approval';
	public static final String CASE_STATUS_CLOSED = 'Closed';
	public static final String CASE_STATUS_COMPLETED = 'Completed';
	public static final String CASE_STATUS_GRANTED = 'Granted';
	public static final String CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW = 'Approved - National Medical Review';
	public static final String CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW = 'Approved - National MAC Review';
	public static final String CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW = 'DNQ - National Medical Review';
	public static final String CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW = 'DNQ - National MAC Review';
	public static final String CASE_STATUS_DNQ = 'DNQ';
	public static final String CASE_STATUS_DNQ_NATIONAL_STAFF = 'DNQ - National Staff';
	public static final String CASE_STATUS_DNQ_NATIONAL_MEDICAL_COUNCIL = 'DNQ - National Medical Council';
	public static final String CASE_STATUS_DNQ_CHAPTER_STAFF = 'DNQ - Chapter Staff';
	public static final String CASE_STATUS_DNQ_CHAPTER_MEDICAL_ADVISOR = 'DNQ - Chapter Medical Advisor';
	public static final String CASE_STATUS_INACTIVE = 'Inactive';
	public static final String CASE_STATUS_ESCALATED = 'Escalated';
	public static final String CASE_STATUS_QUALIFIED = 'Qualified';
	public static final String CASE_STATUS_READY_TO_ASSIGN = 'Ready to Assign';
	public static final String CASE_STATUS_READY_TO_INTERVIEW = 'Ready to Interview';
	public static final String CASE_STATUS_NEW = 'New';
	public static final String CASE_STATUS_PENDING_CLARIFICATION_MAC = 'Pending Clarification - MAC';
	public static final String CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ = 'Pending Clarification - MAC Consult Req';
	public static final String CASE_STATUS_PENDING_CLARIFICATION_CHAPTER = 'Pending Clarification - Chapter';
	public static final String CASE_STATUS_ON_APPEAL = 'Additional Information for Review';
	public static final String CASE_SUB_STATUS_PENDING = 'Pending';
	public static final String CASE_SUB_STATUS_ABANDONED = 'Abandoned';
	public static final String CASE_SUB_STATUS_NON_VIEWABLE = 'Non-Viewable';
	public static final String CASE_WISH_CLEARANCE_APPROPRIATE = 'Appropriate';
	public static final String CASE_WISH_CLEARANCE_NOT_APPROPRIATE = 'Not Appropriate';
	public static final String MEET_PWL_CRITERIA_YES = 'Yes';
	public static final String CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL = 'Cruise-Celebrity/Royal';
	public static final String CASE_WISH_TYPE_CRUISE_DISNEY = 'Cruise-Disney';
	public static final String CASE_WISH_TYPE_CRUISE_OTHER = 'Cruise-Other';
	public static final String CASE_WISH_TYPE_TRAILER_CAMPER = 'Trailer/Camper';
	public static final String CASE_WISH_TYPE_TRAVEL_OTHER = 'Travel-Other';
	public static final String CASE_WISH_TYPE_TRAVEL_INTERNATIONAL = 'Travel-International';
	public static final String CASE_WISH_TYPE_TRAVEL_HAWAII = 'Travel-Hawaii';
	public static final String CASE_RECORD_TYPE_DIAGNOSIS_VERIFICATION_REVIEW = 'Diagnosis Verification Review';
	public static final String CASE_ORIGIN_WEB = 'Web';
	public static final String CASE_ORIGIN_EMAIL = 'Email';
	public static final String CASE_RUSH_TIME_FRAME = 'Select timeframe';
	public static final String CASE_UWI_SOURCE_LEAD = 'Lead';

	/**
	 * Wish Affiliation Constants
	 */
	public static final String WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME = 'Wish_Affiliation_Type__c';
	public static final String WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME = 'Residing_with_Wish_child__c';

	/**
	 * Contact Constants
	 */
	public static final String CONTACT_PHONE_HOME = 'Home';
	public static final String CONTACT_PHONE_MOBILE = 'Mobile';
	public static final String CONTACT_PHONE_OTHER = 'Other';
	public static final String CONTACT_PHONE_WORK = 'Work';
	public static final String CONTACT_PREFERRED_EMAIL_WORK = 'Work';
	public static final String CONTACT_PREFERRED_EMAIL_PERSONAL = 'Personal';
	public static final String CONTACT_PREFERRED_EMAIL_ALTERNATE = 'Alternate';
	public static final String CONTACT_PREFERRED_EMAIL_ALTERNATE1 = 'Alternate 1';
	public static final String CONTACT_PREFERRED_EMAIL_ALTERNATE2 = 'Alternate 2';
	public static final String CONTACT_FIRSTNAME_API_NAME = 'FirstName';
	public static final String CONTACT_LASTNAME_API_NAME = 'LastName';
	public static final String CONTACT_BIRTHDATE_API_NAME = 'Birthdate';
	public static final String CONTACT_MAILINGSTREET_API_NAME = 'MailingStreet';
	public static final String CONTACT_MAILINGCITY_API_NAME = 'MailingCity';
	public static final String CONTACT_MAILINGSTATE_API_NAME = 'MailingState';
	public static final String CONTACT_MAILINGPOSTALCODE_API_NAME = 'MailingPostalCode';
	public static final String CONTACT_MAILINGCOUNTRY_API_NAME = 'MailingCountry';
	public static final String CONTACT_NPE01_PREFERREDPHONE_API_NAME = 'npe01__PreferredPhone__c';
	public static final String CONTACT_PHONE_API_NAME = 'Phone';
	public static final String CONTACT_NPE01_HOMEEMAIL_API_NAME = 'npe01__HomeEmail__c';
	public static final String CONTACT_TYPE_SIBLING = 'Sibling';
	public static final String CONTACT_TYPE_PARENT_LEGAL_GUARDIAN = 'Parent/Guardian';
	public static final String CONTACT_TYPE_REFERRING = 'Referring';
	public static final String CONTACT_SALUTATION_MASTER = 'Master';
	public static final String CONTACT_SALUTATION_MR = 'Mr.';
	public static final String CONTACT_SALUTATION_MISS = 'Miss';
	public static final String CONTACT_SALUTATION_MS = 'Ms.';
	public static final String CONTACT_GENDER_MALE = 'Male';
	public static final String CONTACT_GENDER_FEMALE = 'Female';
	public static final String CONTACT_NAME_UNKNOWN = 'Unknown';
	public static final String CONTACT_STATUS_ROLE_SPECIFIC_TRAINING_AVAILABLE = 'Role Specific Training Available';
	public static final String CONTACT_ONBOARDING_STATUS_BACKGROUND_CHECK = 'Background Check';
	public static final String CONTACT_HIDDEN_VOLUNTEER_STATUS_TRAINING_REGISTERED = 'Training Registered';
	public static final String CONTACT_HIDDEN_VOLUNTEER_STATUS_ORIENTATION_COMPLETED = 'Orientation With Completed';
	public static final String CONTACT_HIDDEN_VOLUNTEER_STATUS_ORIENTATION_WITHOUT_COMPLETED = 'Orientation Without Completed';
	public static final String CONTACT_ONBOARDING_STATUS_ORIENTATION = 'Orientation';
	public static final String CONTACT_IS_APPLICATION_SUBMIT = 'Submit';
	public static final String CONTACT_IS_APPLICATION_APPROVED = 'Approved';

	/**
	 * Chapter Role File Constants
	 */
	public final static String CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER = 'Single Day Event Volunteer';
	public final static String CHAPTER_ROLE_WISH_GRANTER = 'Wish Granter';
	public final static String CHAPTER_ROLE_WISH_GRANTER_MENTOR = 'Wish Granter Mentor';

	/**
	 * In Kind Reimbursement File Constants
	 */
	public final static String INKIND_REIMBURSEMENT_FILE_DOCUMENTATION = 'Not Available';

	/**
	 * Relationship Constants
	 */
	public static final String RELATIONSHIP_NPE4_TYPE_API_NAME = 'npe4__Type__c';
	public static final String RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME = 'Parent_Legal_Guardian__c';
	public static final String RELATIONSHIP_STATUS_ACTIVE = 'Active';

	/**
	 * Volunteer Status Processor Background Check and Conflict Of Interest
	 */
	public final static String VOLUNTEER_TRAINING_NO_CHECK_OUT_OF_COMPLIANCE = 'TRAINING_NO_CHECK_OUT_OF_COMPLIANCE';
	public final static String VOLUNTEER_OUT_OF_COMPLIANCE_NO_CHECK_TRAINING = 'OUT_OF_COMPLIANCE_NO_CHECK_TRAINING';
	public final static String VOLUNTEER_NONE_OUTSTANDING = 'NONE_OUTSTANDING';
	public final static String VOLUNTEER_OUT_OF_COMPLIANCE_NONE_TRAINING = 'OUT_OF_COMPLIANCE_NONE_TRAINING';
	public final static String VOLUNTEER_TRAINING_NONE_OUT_OF_COMPLIANCE = 'TRAINING_NONE_OUT_OF_COMPLIANCE';

	/**
	 * Volunteer Roles Constants
	 */
	public static final String VOLUNTEER_ROLE_STATUS_ACTIVE = 'Active';
	public static final String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = 'Out of Compliance';
	public static final String VOLUNTEER_ROLE_STATUS_FORMER = 'Former';
	public static final String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = 'Not Approved';
	public static final String VOLUNTEER_ROLE_STATUS_PENDING = 'Pending';
	public final static String VOLUNTEER_ROLE_STATUS_PENDING_TRAINING = 'Pending Training';
	public final static String VOLUNTEER_ROLE_STATUS_MISSING_REQUIREMENT = 'Missing Requirement';
	public final static String VOLUNTEER_ROLE_STATUS_CHAPTER_REVIEW = 'Chapter Review';
	public final static String VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW = 'Under Chapter Review';
	public final static String VOLUNTEER_ROLE_SUB_STATUS_CHAPTER = 'Chapter';
	public final static String VOLUNTEER_ROLE_SUB_STATUS_VOLUNTEER = 'Volunteer';
	public final static String VOLUNTEER_ROLE_ATTENDANCE_COMPLETED = 'Completed';

	/**
	 * Volunteer Orientation Training Constants
	 */
	public static final String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = 'Training';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION = 'Orientation';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_APPROVED = 'Approved';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED = 'Not Approved';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED = 'Follow-up Requested';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = 'Completed';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED = 'Registered';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = 'Volunteer Cancelled';

	/**
	 * Volunteer Opportunities Constants
	 */
	public static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER = 'Wish Granter';
	public static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR = 'Wish Granter Mentor';
	public static final String VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER = 'Temporary Wish Granter';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_CLOSED = 'Closed';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED = 'Completed';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE = 'Inactive';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE = 'Out of Compliance';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_APPROVED = 'Approved';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_HOLD = 'Hold';
	public static final String VOLUNTEER_OPPORTUNITY_STATUS_PENDING = 'Pending';
	public static final String VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED = 'Not Approved';
	public final static String VOLUNTEER_RT_LABEL_NON_WISH_EVENT = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Non_Wish_Event').getName();
	public final static String VOLUNTEER_RT_LABEL_NON_WISH_EVENT_VOLUNTEER_REGISTERED = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByDeveloperName().get('Volunteer_Registered_Non_Wish').getName();

	/**
	 * Contact Application Status
	 */
	public static final String CONTACT_APPLICATION_STATUS_APPROVED = 'Approved';
	public static final String CONTACT_APPLICATION_STATUS_COMPLETE = 'Complete';
	public static final String CONTACT_APPLICATION_STATUS_DOCUSIGN_PENDING = 'DocuSign Pending';
	public static final String CONTACT_APPLICATION_STATUS_SUBMIT = 'Submit';
	public static final String CONTACT_APPLICATION_STATUS_FULLY_SUBMIT = 'Fully Submit';
	public static final String CONTACT_APPLICATION_STATUS_PARTIAL_SUBMIT = 'Partial Submit';
	public static final String CONTACT_APPLICATION_STATUS_REJECTED = 'Rejected';
	public static final String CONTACT_ONBOARDING_STATUS_APPLICATION = 'Application';

	/**
	 * Docusign Status
	 */
	public static final String DOCUSIGN_ENVELOPE_STATUS_COMPLETED = 'Completed';
	public static final String DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM = 'Diagnosis Verification Form';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY = 'Signature Required - Wish Form & Liability And Publicity Release Form';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_FORM = 'Signature Required – Make-A-Wish Wish Clearance Form';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_RUSH_WISH_CLEARANCE_FORM = 'Signature Required – Make-A-Wish Rush Wish Clearance Form';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_NO_TRAVEL_FORM = 'Signature Required – Make-A-Wish Wish Clearance No Travel Form';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_RUSH_WISH_CLEARANCE_NO_TRAVEL_FORM = 'Signature Required – Make-A-Wish Rush Wish Clearance No Travel Form';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_CHILD_MEDICAL_FORM = 'Signature Required – Make-A-Wish Wish Clearance, Child\'s Medical Summary:';
	public static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_RUSH_WISH_CLEARANCE_CHILD_MEDICAL_FORM = 'Signature Required – Make-A-Wish Rush Wish Clearance, Child\'s Medical Summary:';
	public static final String DOCUSIGN_STATUS_ENVELOPE_STATUS_SENT = 'Sent';

	/**
	 * Docusign Recipient Constants
	 */
	public static final String DOCUSIGN_RECIPIENT_STATUS_COMPLETED = 'Completed';
	public static final String DOCUSIGN_RECIPIENT_STATUS_DELIVERED = 'Delivered';
	public static final String DOCUSIGN_RECIPIENT_STATUS_SENT = 'Sent';

	/**
	* Wish Affiliation Types
	*/
	public static final String WISH_AFFILIATION_TYPE_WISH_CHILD = 'Wish Child';
	public static final String WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT = 'Approved Participant';
	public static final String WISH_AFFILIATION_TYPE_REQUESTED_PARTICIPANT = 'Requested Participant';
	public static final String WISH_AFFILIATION_TYPE_MEDICAL_PROFESSIONAL = 'Medical Professional';
	public static final String WISH_AFFILIATION_TYPE_OTHER = 'Other';

	/**
	* Wish Change Request Status
	*/
	public static final String WISH_CHANGE_REQUEST_STATUS_PROPOSED = 'Proposed';
	public static final String WISH_CHANGE_REQUEST_STATUS_APPROVED = 'Approved';

	/**
	 * Wish Required Signature
	 */
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED = 'Expired';
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_SIGNED = 'Signed';
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_VOIDED = 'Voided';
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_SENT = 'Sent';
	public static final String WISH_REQUIRED_SIGNATURE_FORMAT_ESIGNATURE = 'E-Signature';

	/**
	 * Task Constants
	 */
	public static final String TASK_PRIORITY_NORMAL = 'Normal';
	public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
	public static final String TASK_STATUS_COMPLETED = 'Completed';
	public static final String TASK_STATUS_IN_PROGRESS = 'In Progress';
	public static final String TASK_STATUS_SCHEDULED = 'Scheduled';
	public static final String TASK_STATUS_APPROVED = 'Approved';
	public static final String TASK_DESCRIPTION_RUSH_QUALIFIED = 'New RUSH referral qualified';
	public static final String TASK_SUBJECT_SEND_DIAGNOSIS_VERIFICATION = 'Send Diagnosis Verification';
	public static final String TASK_SUBJECT_REMINDER_FOR_DIAGNOSIS_VERIFICATION = 'days reminder for Diagnosis Verification';
	public static final String TASK_SUBJECT_NEW_INQUIRY_SUBMITTED = 'New Inquiry Submitted';
	public static final String TASK_SUBJECT_NEW_REFERRAL_SUBMITTED = 'New Referral Submitted';
	public static final String TASK_SUBJECT_SEND_WELCOME_LETTER = 'Send Welcome Letter/Make Welcome Call';
	public static final String TASK_SUBJECT_RUSH_QUALIFIED = 'Lead ET : New Rush Qualified';
	public static final String TASK_SUBJECT_RUSH_MODIFIED_NO = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary';
	public static final String TASK_SUBJECT_REVIEW_BACKGROUND_CHECK = 'Review Background Check';
	public static final String TASK_SUBJECT_BACKGROUND_CHECK = 'Background Check';
	public static final String TASK_SUBJECT_CHECK_IN_WITH_FAMILY = 'Check in with the family every 30 days';
	public static final String TASK_SUBJECT_WISH_PRESENTATION_NOT_SET = 'Wish Presentation Not Set';
	public static final String TASK_SUBJECT_BUDGET_IS_APPROVED_ACKNOWLEDGE = 'Budget is approved: Acknowledge Receipt of Approval';
	public static final String TASK_SUBJECT_SEND_DNQ = 'Send DNQ Notification to Qualifying Medical Professional';
	public static final String TASK_SUBJECT_INTERVIEW_TASK = 'Interview Task';
	public static final String TASK_SUBJECT_INTERVIEW_COMPLETED = 'Interview Completed';
	public static final String TASK_SUBJECT_PARENT_ORIENTATION = 'Parent/Guardian Orientation';
	public static final String TASK_SUBJECT_BACKGROUND_CHECK_EXPIRING = 'BC ET : Background Check Expiring';
	public static final String TASK_SUBJECT_COI_EXPIRING = 'COI ET : COI Expiring';
	public static final String TASK_SUBJECT_BUDGET_IS_APPROVED = 'Budget is approved';
	public static final String TASK_SUBJECT_BUDGET_APPROVAL_REQUEST = 'Case ET : Budget Approval Request';
	public static final String TASK_SUBJECT_BUDGET_NEEDS_REVISED = 'Budget needs to be revised';
	public static final String TASK_SUBJECT_FOLLOWUP_ON_CLEARANCE = 'Follow-up on wish clearance';
	public static final String TASK_SUBJECT_INTERVIEW_DATE_NOT_SET = 'Interview date not set';
	public static final String TASK_SUBJECT_BIRTHDAY_REMINDER = 'Wish Child Birthday Reminder';
	public static final String TASK_SUBJECT_FAMILY_PACKET_NOT_SUBMITTED = 'Wish Family Packet not submitted';
	public static final String TASK_SUBJECT_RUSH_REFERRAL = 'Lead ET : New Rush Referral';
	public static final String TASK_SUBJECT_RUSH_CHANGED = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary';
	public static final String TASK_SUBJECT_WISH_CONCEPT_APPROVAL = 'Wish concept approval';
	public static final String TASK_SUBJECT_WISH_NOT_CLOSED = 'Wish not closed';
	public static final String TASK_SUBJECT_FLIGHTS_BOOKED = 'Flights booked';
	public static final String TASK_SUBJECT_BUDGET = 'Budget';
	public static final String TASK_SUBJECT_REQUEST_PASSPORTS = 'Request Passports from family';
	public static final String TASK_SUBJECT_PASSPORTS_REQUESTED = 'Passports Requested from family';
	public static final String TASK_SUBJECT_SNEAK_PEEK_LETTER = 'Sneak Peek Letter';
	public static final String TASK_SUBJECT_CRUISE_REQUEST_FORM = 'Cruise request form';
	public static final String TASK_SUBJECT_REFERRAL_DNQ = 'Referral DNQ';
	public static final String TASK_SUBJECT_REVIEW_VOLUNTEER_UPLOAD = 'Review Volunteer Upload';
	public static final String TASK_TYPE_EMAIL = 'Email';
	public static final String TASK_AVAILABLE_TIME_OTHER = 'Other';
	public final static String TASK_RT_STAFF_LABEL = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Staff').getName();

	/*
	 * User Constants
	 */
	public static final String INTEGRATION_USER = 'Integration User';
	public static final String USER_VOLUNTEER_ORIENTATION_STATUS_REGISTERED = 'Registered';
	public static final String USER_VOLUNTEER_ORIENTATION_STATUS_CANCELLED = 'Cancelled';

	/**
	 * Profile Constants
	 */
	public static final String PROFILE_INTEGRATION = 'Integration';
	public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';

	/**
	 * Role Constants
	 */
	public static final String ROLE_NATIONAL_STAFF = 'National Staff';

	/*
	 * Wish Role Constants
	 */
	public static final String WISH_ROLE_ALL_ROLES = 'All Roles';

	/**
	 * File Constants
	 */
	public static final String FILE_CONTENT_TYPE_FOLDER = 'Folder';
	public static final String FILE_NAME_DOCUMENTS = 'Documents';
	public static final String FILE_NAME_STAFF_PRIVATE = 'Staff - Private';
	public static final String FILE_NAME_FINANCIALS = 'Financials';
	public static final String FILE_NAME_PHOTOS = 'Photos';
	public static final String FILE_NAME_VIDEOS = 'Videos';

	/**
	 * Record Share Constants
	 */
	public static final String RECORD_SHARE_READ = 'Read';
	public static final String RECORD_SHARE_EDIT = 'Edit';
	public static final String RECORD_SHARE_NONE = 'None';

	/**
	 * Background Check Constants
	 */
	public static final String BACKGROUND_CHECK_STATUS_APPROVED = 'Approved';
	public static final String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = 'Approved w/ Conditions';
	public static final String BACKGROUND_CHECK_STATUS_REJECTED = 'Rejected';
	public static final String BACKGROUND_CHECK_STATUS_FIRST_ADVANTAGE = 'Received from First Advantage';
	public static final String BACKGROUND_CHECK_STATUS_MANUAL = 'Manual';
	public static final String BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_YES = 'Yes';
	public static final String BACKGROUND_CHECK_RESIDED_IN_US_FOR_PAST_7_YEARS_NO = 'No';

	/**
	 * Wish Expense Constants
	 */
	public static final String WISH_EXPENSE_BUDGET_APPROVAL_STATUS_SUBMITTED = 'Submitted';
	public static final String WISH_EXPENSE_BUDGET_APPROVAL_STATUS_APPROVED = 'Approved';

	/**
	 * Wish Budget Constants
	 */
	public static final String WISH_BUDGET_BUDGET_APPROVAL_STATUS_SUBMITTED = 'Submitted';
	public static final String WISH_BUDGET_BUDGET_APPROVAL_STATUS_APPROVED = 'Approved';

	/**
	 * Group Constants
	 */
	public static final String GROUP_TYPE_REGULAR = 'Regular';

	/**
	 * Case Team Member Role Constants
	 */
	public static final String CASE_TEAM_ROLE_INTAKE_MANAGER = 'Intake Manager';
	public static final String CASE_TEAM_ROLE_National_Staff_MANAGER = 'Full Access National Staff';
	public static final String CASE_TEAM_ROLE_VOLUNTEER_MANAGER = 'Volunteer Manager';
	public static final String CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE = 'Volunteer Manager (Inactive)';
	public static final String CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE = 'Wish Coordinator (Inactive)';
	public static final String CASE_TEAM_ROLE_WISH_COORDINATOR = 'Wish Coordinator';
	public static final String CASE_TEAM_ROLE_WISH_GRANTER = 'Wish Granter';
	public static final String CASE_TEAM_ROLE_WISH_GRANTER_MENTOR = 'Wish Granter Mentor';

	/**
	 * Process Instance Constants
	 */
	public static final String PROCESS_INSTANCE_STATUS_PENDING = 'Pending';

	/**
	 * Access Token Lists (Custom Metadata) Constants
	 */
	public static final String ACCESS_TOKEN_LISTS_FIRST_ADVANTAGE = 'First Advantage';

	/**
	 * User Role Constants
	 */
	public static final String USER_ROLE_CUSTOMER_PORTAL = 'CustomerPortal';

	/**
	 * Role (Role__c) Constants
	 */
	public final static String ROLE_WISH_GRANTER = 'Wish Granter';

	/**
	* SIW-378: labels for static text
	*/
	public final static String SAME_AGE_PEERS = 'Severe: Functions nothing like same-age peers, extremely cognitively delayed.';
	public final static String CHILD_VERBAL_AGE = 'No, child is verbal at an age-appropriate level.';
	public final static String CHILD_VERBAL_DELAYED = 'Yes, child is verbal but delayed and able to be understood by others';
	public final static String CHILD_NON_VERBAL = 'No, child is non-verbal';
	public final static String CARE_GIVER = 'Crying without the capacity to indicate needs or wants to a caregiver well known to the child';
	public final static String POINT_DESIRED = 'Pointing at desired objects, reaching out for something or someone they want,  taking your hand to what they want';
	public final static String CHILD_DESIRE = 'Repeating something they just heard in a manner suggesting the child is desiring (as opposed to just echoing words)';
	public final static String SIGN_LANG = 'Sign language (either standard or specific to the child)';
	public final static String ASSISTIVE_COMM = 'Assistive communication tool, tablet, or computer';
	public final static String FOLLOW_MEDICAL_TEAM = 'I do not have access to that information. I recommend the chapter follow up with the medical team';
	public final static String HELP_TEXT_COGNITIVE = '(This question does not affect eligibility criteria. If the child’s condition is eligible, this information helps our volunteers and staff to plan an appropriate wish.)';
	public final static String MILD_FUNCTION = 'Mild: Functions close to peers';
	public final static String MODERATE_FUNCTION = 'Moderate: Functions below peers';
	public final static String PLEASE_SELECT_ALL = '(Please select all that apply)';
	public final static String PLACEHOLDER_ADD_INFO = 'Please add any additional information about the child’s ability to communicate.';
	public final static String PLEASE_SELECT_TEXT = 'Please Select';
	public final static String SELECTED_TEXT = 'selected';
	public final static String YES_TEXT = 'Yes';
	public final static String NO_TEXT = 'No';
	public final static String INFECTIOUS_TUBERCULOSIS = 'Infectious Tuberculosis';
	public final static String AIRBORNE_VIRAL_INFECTIONS_OF_HIGH_MORTALITY = 'Airborne Viral Infections of High Mortality';
	public final static String PNEUMOTHORAX = 'Pneumothorax';
	public final static String PLEURAL_EFFUSION = 'Pleural Effusion';
	public final static String SEVERE_RESTRICTIVE_LUNG_DISEASE = 'Severe Restrictive Lung Disease';
	public final static String OXYGEN_DEPENDENCE_AT_SEA_LEVEL = 'Oxygen dependence at sea level';
	public final static String OXYGEN_REQUIREMENT_4L_MIN_AT_SEA_LEVEL = 'Oxygen requirement >4L/min at sea level';
	public final static String LONG_TERM_OXYGEN_WITHIN_LAST_6_MONTHS = 'Long-term oxygen within last 6 months';
	public final static String HOSPITALIZATION_FOR_ACUTE_RESPIRATORY = 'Hospitalization for acute respiratory illness in the past 6 weeks';
	public final static String PULMONARY_HYPERTENSION = 'Pulmonary hypertension';
	public final static String VENTILATOR_DEPENDENCE = 'Ventilator Dependence';
	public final static String CHEST_PAIN_ANGINA = 'Chest Pain/Angina';
	public final static String ARRHYTHMIA = 'Arrhythmia';
	public final static String ACUTE_HEART_FAILURE = 'Acute Heart Failure';
	public final static String CHRONIC_HEART_FAILURE = 'Chronic Heart Failure';
	public final static String CYANOTIC_CONGENITAL_HEART_DISEASE = 'Cyanotic Congenital Heart Disease';
	public final static String SEVERE_UNCONTROLLED_HYPERTENSION = 'Severe Uncontrolled Hypertension';
	public final static String ACUTE_OR_CHRONIC_HEPATITIS = 'Acute or Chronic Hepatitis';
	public final static String PORTAL_HYPERTENSION = 'Portal Hypertension';
	public final static String HEPTOPULMONARY_SYNDROME = 'Heptopulmonary Syndrome';
	public final static String CHRONIC_LIVER_DISEASE = 'Chronic liver disease';
	public final static String END_STAGE_LIVER_DISEASE = 'End Stage Liver Disease';
	public final static String ESOPHAGEAL_VARICES_OR_HISTORY_OF = 'Esophageal varices or history of';
	public final static String PORTOPULMONARY_HYPERTENSION = 'Portopulmonary Hypertension';
	public final static String INCREASED_INTRACRANIAL_PRESSURE = 'Increased Intracranial Pressure';
	public final static String TRANSIENT_ISCHEMIC_ATTACKS_OR_STROKES = 'Transient Ischemic Attacks or Strokes';
	public final static String UNSTABLE_OR_UNCONTROLLED_EPILEPSY = 'Unstable or uncontrolled epilepsy, seizure disorder, convulsive disorder';
	public final static String PANIC_DISORDER = 'Panic Disorder';
	public final static String MAJOR_BLEEDING = 'Major bleeding';
	public final static String SYMPTOMATIC_ANEMIA = 'Symptomatic Anemia';
	public final static String SICKLE_CELL_ANEMIA = 'Sickle Cell Anemia';
	public final static String SURGERY_IN_THE_PAST_2_MONTHS = 'Surgery in the past 2 months';
	public final static String MEDICALLY_FRAGILE_MEDICALLY_COMPLEX = 'Medically fragile/medically complex';
	public final static String I_AM_NOT_SURE = 'I am not sure';
	public final static String NONE_APPLY = 'None Apply';

	public final static String COMMENT_BOX_TEXT = 'Comment box';

}