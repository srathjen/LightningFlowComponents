/**
 * @description Constants class
 * @author		Gustavo Mayer, Traction on Demand
 * @createdDate	6-19-2019
 */
public class Constant_AC {
	public final static String CONTACT_WISH_CHILD_RT_LABEL = 'Wish Child';
	public final static Id CONTACT_WISH_CHILD_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Wish_Child').getRecordTypeId();
	public final static Id IN_KIND_ACCOUNT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('In_Kind_Donors').getRecordTypeId();
	public final static Id DETERMINATION_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Wish_Determination').getRecordTypeId();
	public final static Id DETERMINATION_CHAPTER_ACTION_RT_ID = Schema.SObjectType.Chapter_Action_Track__c.getRecordTypeInfosByDeveloperName().get('Wish_Determination').getRecordTypeId();
	public final static Id PLANNING_ANTICIPATION_CHAPTER_ACTION_RT_ID = Schema.SObjectType.Chapter_Action_Track__c.getRecordTypeInfosByDeveloperName().get('Wish_Planning').getRecordTypeId();
	public final static Id PLANNING_ANTICIPATION_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Wish_Planning').getRecordTypeId();
	public final static String WISH_ASSIST_RT_LABEL = 'Wish Assist';
	public final static Id WISH_ASSIST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Wish_Assist').getRecordTypeId();
	public final static Id GRANT_CHAPTER_ACTION_RT_ID = Schema.SObjectType.Chapter_Action_Track__c.getRecordTypeInfosByDeveloperName().get('Wish_Granting').getRecordTypeId();
	public final static Id GRANT_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Wish_Granting').getRecordTypeId();
	public final static Id WISH_FAMILY_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Wish_Family').getRecordTypeId();
	public final static String WISH_FAMILY_RT_LABEL = 'Wish Family';
	public final static Id WISH_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Wish').getRecordTypeId();
	public final static Id MEDICAL_PROFESSIONAL_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medical_Professional').getRecordTypeId();
	public final static String MEDICAL_PROFESSIONAL_RT_LABEL = 'Medical Professional';
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
	public final static Id WISH_FORM_CHILD_ID = Schema.SObjectType.Wish_Child_Form__c.getRecordTypeInfosByDeveloperName().get('Wish_Child').getRecordTypeId();
	public final static Id WISH_FORM_FAMILY_ID = Schema.SObjectType.Wish_Child_Form__c.getRecordTypeInfosByDeveloperName().get('Wish_Form_Family').getRecordTypeId();
	public final static Id WISH_FORM_DETERMINATION_ID = Schema.SObjectType.Wish_Child_Form__c.getRecordTypeInfosByDeveloperName().get('Wish_Form_Determination_Case').getRecordTypeId();
	public final static Id WISH_FORM_CHILD_EMERGENCY_ID = Schema.SObjectType.Wish_Child_Form__c.getRecordTypeInfosByDeveloperName().get('Wish_Form_Emergency_Contact').getRecordTypeId();
	public final static Id WISH_FORM_CHILD_DRIVER_ID = Schema.SObjectType.Wish_Child_Form__c.getRecordTypeInfosByDeveloperName().get('Wish_Form_Driver_Information').getRecordTypeId();
	public final static Id WISH_CLEARANCE_ATTACHMENT_ID = Schema.SObjectType.Minor_Participant__c.getRecordTypeInfosByDeveloperName().get('Wish_Clarence_Attachment').getRecordTypeId();
	public final static Id FORM_TRACKER_ATTACHMENT_ID = Schema.SObjectType.Minor_Participant__c.getRecordTypeInfosByDeveloperName().get('Form_Tracker_Attachment').getRecordTypeId();
	public final static Id COMBO_RECORD_ID = Schema.SObjectType.Minor_Participant__c.getRecordTypeInfosByDeveloperName().get('Combo_Form_Attachment').getRecordTypeId();
	public final static Id WISH_EXPENSE_RT_FINANCE = Schema.SObjectType.Wish_Expense__c.getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
	public static final String TYPE_LIGHTNING = 'Lightning';
	public static final String TYPE_CLASSIC = 'Classic';
	public static final String THEME_4D = 'Theme4d';
	public static final String THEME_4U = 'Theme4u';

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
	public static final String FAMILY_HOUSEHOLD_NAME_APPEND = ' ' + ' & ' + ' ' + 'Family Household';

	/**
	 * Affiliation Constants
	 */
	public final static String ORG_AFFILIATION_STATUS_ACTIVE = 'Active';
	public final static String ORG_AFFILIATION_TREATING_FACILITY_CURRENT = 'Current';

	/**
	 * Lead Constants
	 */
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
	public static final String LEAD_SUB_STATUS_MEDICAL_REVIEWED = 'Medical Reviewed'; //SIW-524 DNQ-Medical Lead Sub-Status Changes
	public static final String LEAD_DUP_CHECK_BLOCK_LEAD_DUP = 'Block Lead Dup';
	public static final String LEAD_DUP_CHECK_BLOCK_CONTACT_DUP = 'Block Contact Dup';
	public static final String LEAD_COUNTRY_UNITED_STATES = 'United States';
	public static final String LEAD_COMPANY_MAKE_A_WISH = 'Make-A-Wish';
	public static final String LEAD_SOURCE_ONLINE = 'Online';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_OTHER = 'Other';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_SELF = 'Self';
	public static final String LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN = 'Parent/Guardian';
	public static final String LEAD_MEDICAL_PROVIDER_NURSE_PRACTITIONER = 'Nurse Practitioner';
	public static final String LEAD_MEDICAL_PROVIDER_PHYSICIAN_ASSISTANT = 'Physician Assistant';
	public static final String LEAD_MEDICAL_PROVIDER_PHYSICIAN = 'Physician';
	public static final String LEAD_NUMBER_OF_SIBLINGS_UNKNOWN = 'Unknown';
	public static final String LEAD_COMATOSE_VEGETATIVE_STATE_YES = 'Yes';
	public static final String LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES = 'Yes';
	public static final String LEAD_ERROR_WISH_CHILD = 'Wish Child';
	public static final String LEAD_ERROR_WISH_ADDITIONAL_PARENT_GUARDIAN = 'Additional Parent/Guardian';
	public static final String LEAD_ERROR_WISH_FAMILY = 'Wish Family';
	public static final String LEAD_ERROR_BEST = 'Best Physician Contact';
	public static final String LEAD_ERROR_MEDICAL_PROFESSIONAL = 'Medical Professional';
	public static final String LEAD_ERROR_WISH_FAMILY_AND_MEDICAL_PROFESSIONAL = 'Wish Family and Medical Professional';

	/**
	 * Lead File Constants
	 */
	public static final String LEAD_FILE_CONTENT_TYPE_FOLDER = 'Folder';

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
	public static final String CASE_STATUS_OPEN = 'Open';
	public static final String CASE_STATUS_QUALIFIED = 'Qualified';
	public static final String CASE_STATUS_READY_TO_ASSIGN = 'Ready to Assign';
	public static final String CASE_STATUS_READY_TO_INTERVIEW = 'Ready to Interview';
	public static final String CASE_STATUS_NEW = 'New';
	public static final String CASE_STATUS_PENDING_CLARIFICATION_MAC = 'Pending Clarification - MAC';
	public static final String CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ = 'Pending Clarification - MAC Consult Req';
	public static final String CASE_STATUS_PENDING_CLARIFICATION_CHAPTER = 'Pending Clarification - Chapter';
	public static final String CASE_SUB_STATUS_PENDING = 'Pending';
	public static final String CASE_SUB_STATUS_ABANDONED = 'Abandoned';
	public static final String CASE_SUB_STATUS_DNQ_MEDICAL = 'DNQ - Medical';
	public static final String CASE_WISH_CLEARANCE_APPROPRIATE = 'Appropriate';
	public static final String CASE_WISH_CLEARANCE_NOT_APPROPRIATE = 'Not Appropriate';
	public static final String MEET_PWL_CRITERIA_YES = 'Yes';
	public static final String CASE_WISH_TYPE_CELEBRITY_DOMESTIC_TRAVEL = 'Celebrity-Domestic Travel';
	public static final String CASE_WISH_TYPE_CELEBRITY_LOCAL = 'Celebrity-Local';
	public static final String CASE_WISH_TYPE_CELEBRITY_INTERNATIONAL_TRAVEL = 'Celebrity-International Travel';
	public static final String CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL = 'Cruise-Celebrity/Royal';
	public static final String CASE_WISH_TYPE_CRUISE_DISNEY = 'Cruise-Disney';
	public static final String CASE_WISH_TYPE_CRUISE_OTHER = 'Cruise-Other';
	public static final String CASE_WISH_TYPE_TRAILER_CAMPER = 'Trailer/Camper';
	public static final String CASE_WISH_TYPE_TRAVEL_OTHER = 'Travel-Other';
	public static final String CASE_WISH_TYPE_TRAVEL_INTERNATIONAL = 'Travel-International';
	public static final String CASE_WISH_TYPE_TRAVEL_HAWAII = 'Travel-Hawaii';
	public static final String CASE_BUDGET_APPROVAL_STATUS_APPROVED = 'Approved';
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
	public static final String CONTACT_TYPE_REFERRER_AND_BEST = 'Referrer&Best';
	public static final String CONTACT_TYPE_REFERRER_AND_TREATING = 'Referrer&Treating';
	public static final String CONTACT_TYPE_BEST = 'BestContact';
	public static final String CONTACT_TYPE_TREATING = 'Treating';
	public static final String CONTACT_TYPE_REFERRING = 'Referring';
	public static final String CONTACT_SALUTATION_MASTER = 'Master';
	public static final String CONTACT_SALUTATION_MR = 'Mr.';
	public static final String CONTACT_SALUTATION_MISS = 'Miss';
	public static final String CONTACT_SALUTATION_MS = 'Ms.';
	public static final String CONTACT_GENDER_MALE = 'Male';
	public static final String CONTACT_GENDER_FEMALE = 'Female';
	public static final String CONTACT_NAME_UNKNOWN = 'Unknown';

	/**
	 * Contact File Constants
	 */
	public final static String CONTACT_CONTENT_FILE_TYPE_FOLDER = 'Folder';
	public final static String CONTACT_FILE_NAME_DOCUMENTS = 'Documents';
	public static final String CONTACT_FILE_NAME_PHOTOS = 'Photos';
	public static final String CONTACT_FILE_NAME_VIDEOS = 'Videos';

	/**
	 * Chapter Role File Constants
	 */
	public final static String CHAPTER_ROLE_SINGLE_DAY_EVENT_VOLUNTEER = 'Single Day Event Volunteer';
	public final static String CHAPTER_ROLE_WISH_GRANTER = 'Wish Granter';
	public final static String CHAPTER_ROLE_WISH_GRANTER_MENTOR = 'Wish Granter Mentor';

	/**
	 * Relationship Constants
	 */
	public static final String RELATIONSHIP_NPE4_TYPE_API_NAME = 'npe4__Type__c';
	public static final String RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME = 'Parent_Legal_Guardian__c';
	public static final String RELATIONSHIP_STATUS_ACTIVE = 'Active';

	/**
	 * Volunteer Roles Constants
	 */
	public static final String VOLUNTEER_ROLE_STATUS_ACTIVE = 'Active';
	public static final String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = 'Out of Compliance';
	public static final String VOLUNTEER_ROLE_STATUS_FORMER = 'Former';
	public static final String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = 'Not Approved';

	/**
	 * Volunteer Orientation Training Constants
	 */
	public static final String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = 'Training';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = 'Completed';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED = 'Not Approved';
	public static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED = 'Follow-up Requested';

	/**
	 * Volunteer Opportunities Constants
	 */
	public static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER = 'Wish Granter';
	public static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR = 'Wish Granter Mentor';
	public static final String VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER = 'Temporary Wish Granter';

	/**
	 * Contact Application Status
	 */
	public static final String CONTACT_APPLICATION_STATUS_APPROVED = 'Approved';

	/**
	 * Docusign  Status
	 */
	public static final String DOCUSIGN_ENVELOPE_STATUS_COMPLETED = 'Completed';
	public static final String DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM = 'Diagnosis Verification Form';

	/**
	* Wish Affiliation Types
	*/
	public static final String WISH_AFFILIATION_TYPE_WISH_CHILD = 'Wish Child';
	public static final String WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT = 'Approved Participant';
	public static final String WISH_AFFILIATION_TYPE_REQUESTED_PARTICIPANT = 'Requested Participant';
	public static final String WISH_AFFILIATION_TYPE_DECLINED_PARTICIPANT = 'Declined Participant';
	public static final String WISH_AFFILIATION_TYPE_MEDICAL_PROFESSIONAL = 'Medical Professional';
	public static final String WISH_AFFILIATION_TYPE_GUARDIAN_OF_MINOR_PARTICIPANT = 'Guardian of Minor Participant';

	public static final String WISH_AFFILIATION_TYPE_OTHER = 'Other';
	/**
	* Wish Change Request Status
	*/
	public static final String WISH_CHANGE_REQUEST_STATUS_PROPOSED = 'Proposed';
	public static final String WISH_CHANGE_REQUEST_STATUS_APPROVED = 'Approved';
	public static final String WISH_CHANGE_REQUEST_STATUS_REJECTED = 'Rejected';

	/**
	 * Wish Required Signature
	 */
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED = 'Expired';
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_SIGNED = 'Signed';
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_VOIDED = 'Voided';
	public static final String WISH_REQUIRED_SIGNATURE_STATUS_SENT = 'Sent';

	/**
	 * Task Constants
	 */
	public static final String TASK_PRIORITY_NORMAL = 'Normal';
	public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
	public static final String TASK_STATUS_COMPLETED = 'Completed';
	public static final String TASK_STATUS_IN_PROGRESS = 'In Progress';
	public static final String TASK_DESCRIPTION_RUSH_QUALIFIED = 'New RUSH referral qualified';
	public static final String TASK_SUBJECT_SEND_DIAGNOSIS_VERIFICATION = 'Send Diagnosis Verification';
	public static final String TASK_SUBJECT_REMINDER_FOR_DIAGNOSIS_VERIFICATION = 'days reminder for Diagnosis Verification';
	public static final String TASK_SUBJECT_NEW_INQUIRY_SUBMITTED = 'New Inquiry Submitted';
	public static final String TASK_SUBJECT_NEW_REFERRAL_SUBMITTED = 'New Referral Submitted';
	public static final String TASK_SUBJECT_SEND_WELCOME_LETTER = 'Send Welcome Letter/Make Welcome Call';
	public static final String TASK_SUBJECT_RUSH_QUALIFIED = 'Lead ET : New Rush Qualified';
	public static final String TASK_SUBJECT_RUSH_MODIFIED_NO = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary';

	/**
	 * Profile Constants
	 */
	public static final String PROFILE_INTEGRATION = 'Integration';

	/**
	 * Role Constants
	 */
	public static final String ROLE_NATIONAL_STAFF = 'National Staff';
    
    /**
     * File Constants
	 */
    public static final String FILE_CONTENT_TYPE_FOLDER = 'Folder';
}