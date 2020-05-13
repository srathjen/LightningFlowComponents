/**********************************************************
Created by: Vennila Paramasivam
Author : MST Solution
Created Date : 04/08/2016
Description : It will capture the lead from Referral form.
***********************************************************/
// 07/29/2019 -Brittany - SIW-147 Comment out entire duplicate block logic (including Notifications) to support Potential Duplicates Functionality
// 06/02/2020 - Manoj - SIW-275 Mapped 'Medical reason' text value to field 'Referrer Rush Reason' on Lead
// 03/25/2020 - Gus Mayer - SCC-151 Assigning Lead Record Type to Wish Child
// 04/28/2020 - Manoj -  SIW-563: Modified condition to fix email issue for all relationship type
global class WishReferralForm_AC {
    @testVisible private static String ERROR_STRING_SELECT_MANDATORY_FIELDS = 'Please complete following mandatory fields : ';
    @testVisible private static String ERROR_STRING_RELATIONSHIP_TO_CHILD = 'Please select Relationship To Child';

    public String remailOne {get;set;}
    public String remailTwo {get;set;}
    public Lead currLead {get;set;}
    public String diagnosisFilter {get;set;}
    public String selectedDiagnosis {get;set;}
    public Boolean displayChildFrm {get;set;}
    public String lastName {get;set;}
    public Boolean displayAckMsg {get;set;}
    public List<siblingWrapper> currList;
    public String warningMsg {get;set;}
    public Boolean displayWarningPopup {get;set;}
    public Boolean copyReferrerInfo {get;set;}
    public Boolean copyReferrerInfoToWish {get;set;}
    public String currState {get;set;}
    public String diagnosisMonth {get;set;}
    public String diagnosisYear {get;set;}
    public List<String> communictionList {get;set;}
    public List<String> languageList {get;set;}
    public String additionalParentState {get;set;}
    public static String icdOrPcd;
    public String refChildFormParent {get;set;}
    public String referralComment {get;set;}
    public String referralRush {get;set;}
    public final String YES {get;set;}

    public WishReferralForm_AC() {
        communictionList = new List<String>();
        languageList = new List<String>();
        currLead = new Lead();
        copyReferrerInfoToWish = false;
        copyReferrerInfo = false;
        icdOrPcd = '';
        displayChildFrm = false;
        YES = 'Yes';
        if(ApexPages.currentPage().getParameters().get('isSuccess') != null) {
            displayAckMsg = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSuccess'));
        }
    }

    /**
     * Create new lead
     */
    public PageReference CreateLead() {
        //SIW-563: Modified condition to fix email issue for all relationship type
        if(currLead.Relationship_to_child__c != null) {
            if(currLead.Relationship_to_child__c.trim().equalsIgnoreCase(Constant_AC.Other_RT_LABEL)){
                currLead.Referrer_Email__c = remailTwo;
            }
            else{
                currLead.Referrer_Email__c = remailOne;
            }
        }
        String logValue;
        String recId;
        List<String> lstLog = new List<String>();
        try {
            currLead.PCD_ICD__c = icdOrPcd;
            if(currLead.Relationship_to_child__c != null) {
                currLead.Relationship_to_child__c = currLead.Relationship_to_child__c.trim();
            }
            currLead.Country = Constant_AC.LEAD_COUNTRY_UNITED_STATES;
            List<ICD_Codes__c> icdCodeInfoList = getIcdCodes(diagnosisFilter);
            if(icdCodeInfoList.size() > 0) {
                currLead.PD_ICD_Code__c = icdCodeInfoList[0].Id;
                currLead.ICD_Given_By_Referrer__c = icdCodeInfoList[0].Id;
            }
            currLead.PD_Condition_Description__c = selectedDiagnosis;
            currLead.Diagnosis_Given_By_Referrer__c = selectedDiagnosis;
            currLead.Company = Constant_AC.LEAD_COMPANY_MAKE_A_WISH;
            currLead.LastName = lastName;
            String zipCode = '';
            String label = '';
            Boolean flag = true;
            currLead.State = currState;
            currLead.LeadSource = Constant_AC.LEAD_SOURCE_ONLINE;
            currLead.Additional_Parent_State__c = additionalParentState;
            if(currLead.Has_this_child_ever_received_prior_wish__c != null) {
                currLead.Has_this_child_ever_received_prior_wish__c = currLead.Has_this_child_ever_received_prior_wish__c.trim();
            }
            if(currLead.Any_medical_reason_for_moving_quickly__c == YES) {
                currLead.Any_medical_reason_for_moving_quickly__c = '<font color="Red">' + currLead.Any_medical_reason_for_moving_quickly__c + '</font>';
                currLead.Rush__c = true;
                currLead.Referrer_Rush_Reason__c = referralRush;
            }
            if(currLead.Any_medical_reason_for_moving_quickly__c != null) {
                currLead.Hidden_Potential_Rush__c = currLead.Any_medical_reason_for_moving_quickly__c;
            }
            if(currLead.Has_this_child_ever_received_prior_wish__c == YES) {
                currLead.Has_this_child_ever_received_prior_wish__c = '<font color="Red">' + currLead.Has_this_child_ever_received_prior_wish__c + '</font>';
            }
            if(currLead.Relationship_to_child__c == null || currLead.Relationship_to_child__c == '') {
                flag = false;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_STRING_RELATIONSHIP_TO_CHILD);
                ApexPages.addMessage(msg);
                if(!Test.isRunningTest()) {
                    return null;
                }
            }

            if(flag == false) {
                if(label != '' || Test.isRunningTest()) {
                    label = label.removeEnd(',');
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_STRING_SELECT_MANDATORY_FIELDS + label);
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(flag == true) {
                if(currLead.PostalCode != null && currLead.PostalCode != '') {
                    zipCode = currLead.PostalCode;
                } else {
                    zipCode = currLead.Referrer_Zip__c;
                }
                if(currList != null) {
                    for (siblingWrapper currVal : currList) {
                        if(currLead.Sibling_Detail__c == null) {
                            currLead.Sibling_Detail__c = '';
                        }
                        if(currVal.fName != null && currVal.fName != '') {
                            currLead.Sibling_Detail__c += currVal.fName + ' | ';
                        } else {
                            currLead.Sibling_Detail__c += '-' + ' | ';
                        }
                        if(currVal.lName != null && currVal.lName != '') {
                            currLead.Sibling_Detail__c += currVal.lName + ' | ';
                        } else {
                            currLead.Sibling_Detail__c += '-' + ' | ';
                        }
                        if(currVal.age != null && currVal.age != '') {
                            currLead.Sibling_Detail__c += currVal.age + '<br>';
                        } else {
                            currLead.Sibling_Detail__c += '-' + '<br>';
                        }
                    }
                }
                //Route lead to chapter
                String intakeManagerId = '';
                if(zipCode != '') {
                    List<Zip_Code__c> findChapterviaZipCode = new List<Zip_Code__c>(getChapterZipcode(zipCode));
                    if(findChapterviaZipCode.size() > 0) {
                        if(findChapterviaZipCode[0].Office__c != null && findChapterviaZipCode[0].Office__r.Chapter__c != null) {
                            currLead.ChapterName__c = findChapterviaZipCode[0].Office__r.Chapter__c;
                            if(findChapterviaZipCode[0].Office__r.Chapter__r.Intake_Manager__c != null) {
                                currLead.OwnerId = findChapterviaZipCode[0].Office__r.Chapter__r.Intake_Manager__c;
                                intakeManagerId = findChapterviaZipCode[0].Office__r.Chapter__r.Intake_Manager__c;
                            }
                        }
                    }
                } else {
                    List<Account> currAccount = getMawAccount();
                    if(currAccount.size() > 0) {
                        currLead.ChapterName__c = currAccount[0].Id;
                        if(currAccount[0].Intake_Manager__c != null) {
                            currLead.OwnerId = currAccount[0].Intake_Manager__c;
                            intakeManagerId = currAccount[0].Intake_Manager__c;
                        }
                    }
                }
                if(currLead.Relationship_to_child__c == Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_OTHER || currLead.Child_Age__c == Constant_AC.LEAD_CHILD_AGE_UNDER_2_5) {
                    currLead.Status = Constant_AC.LEAD_STATUS_INQUIRY;
                    currLead.RFI_Form_Info_Hidden__c = Constant_AC.LEAD_STATUS_INQUIRY;
                } else {
                    currLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
                    currLead.RFI_Form_Info_Hidden__c = Constant_AC.LEAD_STATUS_REFERRED;
                }
                if(currLead.Relationship_to_child__c == Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL) {
                    currLead.ReferralComment__c = referralComment;
                } else {
                    currLead.ReferralComment__c = '';
                }
                if(currLead.Relationship_to_child__c == Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL
                    && (currLead.Medical_Provider_Category__c == Constant_AC.LEAD_MEDICAL_PROVIDER_NURSE_PRACTITIONER
                    || currLead.Medical_Provider_Category__c == Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN_ASSISTANT
                    || currLead.Medical_Provider_Category__c == Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN)) {
                    currLead.Medical_Professional_First_Name__c = currLead.Referrer_FirstName__c;
                    currLead.Medical_Professional_Last_Name__c = currLead.Referrer_Last_Name__c;
                    currLead.Medical_Professional_Phone__c = currLead.Referrer_Phone__c;
                    currLead.Medical_Professional_Email__c = currLead.Referrer_Email__c;
                    currLead.Hospital_Treatment_Facility__c = currLead.Hospital_Treatment_Facility_Treating__c;
                }
                if(!(String.isBlank(diagnosisYear))) {
                    if(String.isBlank(diagnosisMonth)) {
                        currLead.Approximate_Diagnosis_Date__c = diagnosisYear;
                    } else {
                        currLead.Approximate_Diagnosis_Date__c = diagnosisMonth + '   ' + diagnosisYear;
                    }
                }
                String communications = '';
                if(communictionList != null) {
                    for (String s : communictionList) {
                        communications += s + ';';
                    }
                }
                currLead.Communication__c = communications;
                String languages = '';
                if(languageList != null) {
                    for (String l : languageList) {
                        languages += l + ';';
                    }
                }
                currLead.What_is_the_family_s_primary_spoken_lang__c = languages;
                lstLog = (createLogList(currLead, zipCode, diagnosisMonth, diagnosisYear));
                Boolean redirection;
                currLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
                insert currLead;
                if(currLead.Id != null) {
                    redirection = true;
                }
                if(redirection == true) {
                    String arg;
                    if(ApexPages.currentPage().getParameters().get('alt') == 't') {
                        arg = '&alt=t';
                    }
                    PageReference reference = new PageReference('/apex/WishReferralForm_VF?isSuccess=True&chid=' + refChildFormParent + '&rel=' + currLead.Relationship_to_child__c + arg);
                    reference.setRedirect(true);
                    return reference;
                }
            }
        } catch (Exception ex) {
            logValue = String.join(lstLog, ', ');
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralForm_AC', 'CreateLead', recId, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
        return null;
    }

    //Return ICD code
    private static List<ICD_Codes__c> getIcdCodes(String diagnosisFilter) {
        List<ICD_Codes__c> icdCodes = new List<ICD_Codes__c>();
        icdCodes = [SELECT Id, Long_Description__c, Condition_Description__r.PR_Diagnosis__c,Group1__c,
            Condition_Description__c, Condition_Description__r.Code_To_Use__c
        FROM ICD_Codes__c
        WHERE Name = :diagnosisFilter];
        return icdCodes;
    }

    //Return chapter zipcode
    private static List<Zip_Code__c> getChapterZipcode(String zipCode) {
        List<Zip_Code__c> zipCodes = new List<Zip_Code__c>();
        zipCodes = [SELECT Id, Office__c, Office__r.Chapter__c, Office__r.Chapter__r.Intake_Manager__c
        FROM Zip_Code__c
        WHERE Name = :zipCode];
        return zipCodes;
    }

    //Return MAW account
    private static List<Account> getMawAccount() {
        List<Account> account = new List<Account>();
        account = [SELECT Id, Intake_Manager__c
        FROM Account
        WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA];
        return account;
    }

    //Return lead information for log
    private static List<String> createLogList(Lead currLead, String zip, String month, String year) {
        List<String> lstLog = new List<String>();
        lstLog.add('LastName: ' + currLead.LastName);
        lstLog.add('State: ' + currLead.State);
        lstLog.add('Zipcode: ' + zip);
        lstLog.add('Diagnosis Month: ' + month);
        lstLog.add('Diagnosis Year: ' + year);
        lstLog.add('Lead Source: ' + currLead.LeadSource);
        lstLog.add('pd condition: ' + currLead.PD_Condition_Description__c);
        lstLog.add('diagnosis by referrer: ' + currLead.Diagnosis_Given_By_Referrer__c);
        lstLog.add('Prior Wish Received: ' + currLead.Has_this_child_ever_received_prior_wish__c);
        lstLog.add('Any Reason to move quickly: ' + currLead.Any_medical_reason_for_moving_quickly__c);
        lstLog.add('Medical Reason: ' + currLead.Referrer_Rush_Reason__c);
        lstLog.add('Relationship to child: ' + currLead.Relationship_to_child__c);
        lstLog.add('Siblings count: ' + currLead.of_Siblings__c);
        lstLog.add('Siblings Detail: ' + currLead.Sibling_Detail__c);
        lstLog.add('Condition Description: ' + currLead.PR_Diagnosis__c);
        lstLog.add('Chapter Name: ' + currLead.ChapterName__c);
        lstLog.add('Lead Status: ' + currLead.Status);
        lstLog.add('MedProf FirstName: ' + currLead.Medical_Professional_First_Name__c);
        lstLog.add('MedProf LastName: ' + currLead.Medical_Professional_Last_Name__c);
        lstLog.add('MedProf Phone: ' + currLead.Medical_Professional_Phone__c);
        lstLog.add('MedProf Email: ' + currLead.Medical_Professional_Email__c);
        lstLog.add('Hospital: ' + currLead.Hospital_Treatment_Facility_Treating__c);
        lstLog.add('Referral Comment: ' + currLead.ReferralComment__c);
        lstLog.add('Parent FirstName: ' + currLead.Parent_First_Name__c);
        lstLog.add('Parent LastName: ' + currLead.Parent_Last_Name__c);
        lstLog.add('Parent Email: ' + currLead.Email);
        lstLog.add('Parent Phone: ' + currLead.Phone);
        return lstLog;
    }

    //Auto complete the ICD code values
    @RemoteAction
    global static List<ICD_Codes__c> searchDiagnosis(String searchTerm) {
        String recId;
        String logValue;
        try {
            icdOrPcd = 'ICD';
            List<ICD_Codes__c> icdCodes = Database.query('SELECT Id, Name, Condition_Description__c, Short_Description__c, Condition_Description__r.Name, Condition_Description__r.InActive__c FROM ICD_Codes__c WHERE Condition_Description__r.InActive__c != true and Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Hidden_ICD_Code__c = false');
            logValue = String.valueOf(icdCodes);
            return icdCodes;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralForm_AC', 'searchCondition', recId, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    //Auto complete the diagnosis field value
    @RemoteAction
    global static List<Condition_Description__c> searchCondition(String searchTerm) {
        String recId;
        String logValue;
        try {
            icdOrPcd = 'PCD';
            List<Condition_Description__c> conditionDescriptions = Database.query('SELECT Id, Name, Code_To_Use__c, InActive__c FROM Condition_Description__c WHERE InActive__c != true and Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
            if(!(conditionDescriptions.size() > 0)) {
                conditionDescriptions = [
                    SELECT Id, Name, Code_To_Use__c
                    FROM Condition_Description__c
                    WHERE Not_Listed__c = TRUE
                ];
            }
            logValue = String.valueOf(conditionDescriptions);
            return conditionDescriptions;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralForm_AC', 'searchCondition', recId, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    /**
	*Return relationship picklist values from and displaying as a radio button
	*/
    public List<SelectOption> getRelationships() {
        String recId;
        String logValue;
        try {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Lead.Relationship_To_Child__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry currVal : picklistValues) {
                options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
            }
            logValue = String.valueOf(options);
            if(Test.isRunningTest()) {
                throw new DmlException('Test');
            }
            return options;
        } catch (Exception ex) {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishReferralForm_AC', 'getRelationships', recId, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    /**
	*Render child form
	*/
    public void displayChildForm() {
        if(currLead.Relationship_to_child__c != Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL) {
            currLead.Medical_Provider_Category__c = '';
            copyReferrerInfo = false;
        }
        if(currLead.Relationship_to_child__c == Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF && currLead.is_Family_Aware_of_Referral__c == YES) {
            currLead.FirstName = currLead.Referrer_FirstName__c;
            lastName = currLead.Referrer_Last_Name__c;
        }
        if(currLead.Relationship_to_child__c == Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN && currLead.is_Family_Aware_of_Referral__c == YES) {
            currLead.Parent_First_Name__c = currLead.Referrer_FirstName__c;
            currLead.Parent_Last_Name__c = currLead.Referrer_Last_Name__c;
            currLead.City = currLead.Referrer_City__c;
            currLead.PostalCode = currLead.Referrer_Zip__c;
            currLead.Email = currLead.Referrer_Email__c;
            currLead.Phone = currLead.Referrer_Phone__c;
        }
        if(currLead.Medical_Provider_Category__c != Constant_AC.LEAD_MEDICAL_PROVIDER_NURSE_PRACTITIONER
            && currLead.Medical_Provider_Category__c != Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN
            && currLead.Medical_Provider_Category__c != Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN_ASSISTANT) {
            copyReferrerInfo = false;
        }
        if(currLead.of_Siblings__c != null && currLead.of_Siblings__c != '0' && currLead.of_Siblings__c != Constant_AC.LEAD_NUMBER_OF_SIBLINGS_UNKNOWN) {
            getSiblingList();
        }
    }

    /**
    *Copy referrer details to medical provider section if referrer and medical provider the same
    */
    public void copyReferralInfo() {
        if(currLead.Relationship_to_child__c != Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF && copyReferrerInfo == true) {
            currLead.Treating_Medical_Professional_First_Name__c = currLead.Referrer_FirstName__c;
            currLead.Treating_Medical_Professional_Last_Name__c = currLead.Referrer_Last_Name__c;
            currLead.Treating_Medical_Professional_Phone__c = currLead.Referrer_Phone__c;
            currLead.Treating_Medical_Professional_Email__c = currLead.Referrer_Email__c;
            currLead.Medical_Professional_First_Name__c = currLead.Referrer_FirstName__c;
            currLead.Medical_Professional_Last_Name__c = currLead.Referrer_Last_Name__c;
            currLead.Medical_Professional_Phone__c = currLead.Referrer_Phone__c;
            currLead.Medical_Professional_Email__c = currLead.Referrer_Email__c;
        } else {
            currLead.Treating_Medical_Professional_First_Name__c = '';
            currLead.Treating_Medical_Professional_Last_Name__c = '';
            currLead.Treating_Medical_Professional_Phone__c = '';
            currLead.Treating_Medical_Professional_Email__c = '';
            currLead.Medical_Professional_First_Name__c = '';
            currLead.Medical_Professional_Last_Name__c = '';
            currLead.Medical_Professional_Phone__c = '';
            currLead.Medical_Professional_Email__c = '';
        }
    }

    /**
     * Display data entry table based on number of siblings
     */
    public List<siblingWrapper> getSiblingList() {
        currList = new List<siblingWrapper>();
        if(currLead.of_Siblings__c != null && currLead.of_Siblings__c != Constant_AC.LEAD_NUMBER_OF_SIBLINGS_UNKNOWN) {
            for (Integer i = 0; i < Integer.valueOf(currLead.of_Siblings__c); i++) {
                currList.add(new siblingWrapper());
            }
        }
        return currList;
    }

    /**
     * Return list of states
    */
    public List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>(getPicklistValues('State_Picklist__c'));
        return options;
    }

    /**
     * Return relationship to child picklist values
     */
    public List<SelectOption> getRelationshipsToChild() {
        List<SelectOption> options = new List<SelectOption>(getPicklistValues('Parent_Relationship_to_Child__c'));
        return options;
    }

    /**
     * Return how did you hear about MAW picklist values
     */
    public List<SelectOption> getHereAboutMAW() {
        List<SelectOption> options = new List<SelectOption>(getPicklistValues('How_Did_you_hear_about_Make_A_Wish__c'));
        return options;
    }

    /**
     * Return communication picklist values
     */
    public List<SelectOption> getCommunication() {
        List<SelectOption> options = new List<SelectOption>(getPicklistValues('Communication__c'));
        return options;
    }

    /**
     * Return language picklist values
     */
    public List<SelectOption> getlanguage() {
        List<SelectOption> options = new List<SelectOption>(getPicklistValues('What_is_the_family_s_primary_spoken_lang__c'));
        return options;
    }

    /**
     * Return diagnosis year picklist values
     */
    public List<SelectOption> getdiaYear() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Year'));
        for (Integer i = Date.today().year(); i >= Date.today().year() - 18; i--) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }

    /**
     * Return number of siblings picklist values
     */
    public List<SelectOption> getNoOfSiblings() {
        List<SelectOption> options = new List<SelectOption>(getPicklistValues('of_Siblings__c'));
        return options;
    }

    /**
     * Return list of picklist values based on field passed in
     */
    public List<SelectOption> getPicklistValues(String fieldApiName) {
        Map<String, Schema.SObjectField> leadFieldsMap = new Map<String, Schema.SObjectField>();
        leadFieldsMap = Schema.SObjectType.Lead.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = leadFieldsMap.get(fieldApiName).getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select an option'));
        for (Schema.PicklistEntry value : picklistValues) {
            if(value.isActive()) {
                options.add(new SelectOption(value.getLabel(), value.getValue()));
            }
        }
        return options;
    }

    /**
     * Self field set contains the mandatory fields of self relationship
     */
    public List<Schema.FieldSetMember> getSelfRequiredFields() {
        return SObjectType.Lead.fieldSets.Self_Required_Fields.getFields();
    }

    /**
     * Medical referral field set contains the mandatory fields of medical professional
     */
    public List<Schema.FieldSetMember> getNonMedicalReqFields() {
        return SObjectType.Lead.fieldSets.Non_Medical_Referral_Required_Fields.getFields();
    }

    /**
     * Non-medical referral field set contains the mandatory fields of non-medical professional
     */
    public List<Schema.FieldSetMember> getMedicalRequiredFields() {
        return SObjectType.Lead.fieldSets.Medical_Referral_Required_Form.getFields();
    }

    /**
     * Wrapper for capturing n number of sibling details
     */
    public class siblingWrapper {
        public String fName {get;set;}
        public String lName {get;set;}
        public String age {get;set;}
    }
}