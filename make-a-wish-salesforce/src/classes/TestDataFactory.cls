/* 
* @Description DataFactory class to create test data
* @author Mitali Nahar, Traction on Demand
* @Date 2019-07-02
*/
@IsTest
public class TestDataFactory {

    public static User adminUser {
        get {
            if (adminUser == null) {
                adminUser = [
                        SELECT Id
                        FROM User
                        WHERE Profile.Name = 'System Administrator' AND UserRole.Name != NULL AND UserRole.Name != 'CustomerPortal'
                        AND IsActive = TRUE AND Id != :UserInfo.getUserId()
                        LIMIT 1
                ];
            }
            return adminUser;
        }
        set;
    }

    public static List<ICD_Codes__c> createIcdCode(Integer num) {
        List<ICD_Codes__c> icdCodes = new List<ICD_Codes__c>();
        for (Integer i = 0; i < num; i++) {
            ICD_Codes__c icd = new ICD_Codes__c();
            icd.Name = 'Q917';
            icdCodes.add(icd);
        }
        return icdCodes;
    }

    public static List<Account> createAccount(Integer num) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < num; i++) {
            Account a = new Account();
            a.Name = 'Chapter' + i;
            accounts.add(a);
        }
        return accounts;
    }

    public static List<Role__c> createRole(Integer num, Boolean isWishRole) {
        List<Role__c> roles = new List<Role__c>();
        for (Integer i = 0; i < num; i++) {
            Role__c role = new Role__c();
            role.isWishRole__c = isWishRole;
            roles.add(role);
        }
        return roles;
    }

    public static List<Chapter_Role__c> createChapterRole(Integer num) {
        List<Chapter_Role__c> chapterRoles = new List<Chapter_Role__c>();
        for (Integer i = 0; i < num; i++) {
            Chapter_Role__c role = new Chapter_Role__c();
            chapterRoles.add(role);
        }
        return chapterRoles;
    }

    public static List<Orientation_Training__c> createOrientationTraining(Integer num) {
        List<Orientation_Training__c> orientationTrainings = new List<Orientation_Training__c>();
        for (Integer i = 0; i < num; i++) {
            Orientation_Training__c orientationTraining = new Orientation_Training__c();
            orientationTraining.Name = 'Orientation ' + num;
            orientationTrainings.add(orientationTraining);
        }
        return orientationTrainings;
    }

    public static List<Chapter_Role_O_T__c> createChapterRoleOrientationAndTraining(Integer num) {
        List<Chapter_Role_O_T__c> chapterRoleOTS = new List<Chapter_Role_O_T__c>();
        for (Integer i = 0; i < num; i++) {
            Chapter_Role_O_T__c chapterRoleOT = new Chapter_Role_O_T__c();
            chapterRoleOTS.add(chapterRoleOT);
        }
        return chapterRoleOTS;
    }

    public static List<Contact> createContact(Integer num) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < num; i++) {
            Contact c = new Contact();
            c.FirstName = 'John' + i;
            c.LastName = 'Smith' + i;
            contacts.add(c);
        }
        return contacts;
    }

    public static List<Case> createCase(Integer num) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < num; i++) {
            Case c = new Case();
            cases.add(c);
        }
        return cases;
    }

    public static List<npe4__Relationship__c> createRelationship(Integer num) {
        List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
        for (Integer i = 0; i < num; i++) {
            npe4__Relationship__c r = new npe4__Relationship__c();
            relationships.add(r);
        }
        return relationships;
    }

    public static List<Wish_Affiliation__c> createWishAffiliation(Integer num) {
        List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Affiliation__c w = new Wish_Affiliation__c();
            wishAffiliations.add(w);
        }
        return wishAffiliations;
    }

    public static List<Wish_Signature_Forms__c> createWishSignatureForm(Integer num) {
        List<Wish_Signature_Forms__c> wishForms = new List<Wish_Signature_Forms__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Signature_Forms__c wishSignForm = new Wish_Signature_Forms__c();
            wishSignForm.Name = 'Medical Test';
            wishSignForm.Active__c = True;
            wishForms.add(wishSignForm);
        }
        return wishForms;
    }

    public static List<Wish_Required_Signature__c> createWishRequiredSignature(Integer num) {
        List<Wish_Required_Signature__c> wishSignatures = new List<Wish_Required_Signature__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Required_Signature__c wrs = new Wish_Required_Signature__c();
            wishSignatures.add(wrs);
        }
        return wishSignatures;
    }

    public static List<Wish_Signature_Chapter_Form__c> createWishSignatureChapterForm(Integer num) {
        List<Wish_Signature_Chapter_Form__c> wishSignChapForms = new List<Wish_Signature_Chapter_Form__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Signature_Chapter_Form__c wishSignChapForm = new Wish_Signature_Chapter_Form__c();
            wishSignChapForms.add(wishSignChapForm);
        }
        return wishSignChapForms;
    }

    public static Wish_Required_Signature_File__c createWRSFileRecord(Id wrsId) {
        Wish_Required_Signature_File__c newWRSFile = new Wish_Required_Signature_File__c();
        newWRSFile.File_Name__c = 'MedicalSummary.txt';
        newWRSFile.Wish_Required_Signature__c = wrsId;
        newWRSFile.Content_Type__c = 'text/plain';
        return newWRSFile;
    }

    public static npe4__Relationship__c createRelationship(Id contactId, Id relatedContactId) {
        npe4__Relationship__c relationhsip = new npe4__Relationship__c();
        relationhsip.npe4__Contact__c = contactId;
        relationhsip.npe4__RelatedContact__c = relatedContactId;
        return relationhsip;
    }

    public static List<dsfs__DocuSign_Status__c> createDocusignStatus(Integer num) {
        List<dsfs__DocuSign_Status__c> docusignStatus = new List<dsfs__DocuSign_Status__c>();
        for (Integer i = 0; i < num; i++) {
            dsfs__DocuSign_Status__c dsfs = new dsfs__DocuSign_Status__c();
            dsfs.dsfs__DocuSign_Envelope_ID__c = '0F31B5A9-DB3A-4D31-8D69-9DE86F2010A' + i;
            dsfs.dsfs__Envelope_Status__c = 'Sent';
            docusignStatus.add(dsfs);
        }
        return docusignStatus;
    }

    public static List<User> createUser(Integer num) {
        List<User> users = new List<User>();
        for (Integer i = 0; i < num; i++) {
            User user = new User();
            user.Alias = 'Test-' + i;
            user.Email = 'testuser' + i + '@testorg.com';
            user.EmailEncodingKey = 'UTF-8';
            user.LastName = 'Test' + i;
            user.LanguageLocaleKey = 'en_US';
            user.LocaleSidKey = 'en_US';
            user.TimeZoneSidKey = 'America/Los_Angeles';
            user.Username = 'testuser' + i + '@testorg.com';
            users.add(user);
        }
        return users;
    }

    public static List<User> createCommunityUser(Integer num) {
        // Must run as admin to create community user
        List<User> users = createUser(num);
        System.runAs (adminUser) {
            // Community users require associated contact/account
            List<Account> accounts = createAccount(num);
            insert accounts;

            List<Contact> contacts = createContact(num);
            for (Integer i = 0; i < num; i++) {
                contacts[i].AccountId = accounts[i].Id;
            }
            insert contacts;

            // Create customer portal user
            UserRole userRole = [
                    SELECT PortalType, PortalAccountId
                    FROM UserRole
                    WHERE PortalType = 'CustomerPortal'
                    LIMIT 1
            ];
            Profile profile = [
                    SELECT Id,Name
                    FROM Profile
                    WHERE Name = 'Active Volunteer (Member)'
                    LIMIT 1
            ];
            for (Integer i = 0; i < num; i++) {
                User u = users[i];
                u.ProfileId = profile.Id;
                u.ContactId = contacts[i].Id;
                u.PortalRole = 'Manager';
            }
        }
        return users;
    }

    public static List<Wish_Budget__c> createWishBudget(Integer num, Id caseId) {
        List<Wish_Budget__c> wishBudgets = new List<Wish_Budget__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Budget__c wishBudget = new Wish_Budget__c();
            wishBudget.Wish_Case__c = caseId;
            wishBudgets.add(wishBudget);
        }
        return wishBudgets;
    }

    public static List<Attachment> createAttachments(Integer num, Id parentId) {
        List<Attachment> attachments = new List<Attachment>();
        for (Integer i = 0; i < num; i++) {
            Attachment a = new Attachment();
            a.ParentId = parentId;
            a.Name = 'Attachment' + num + '.txt';
            a.Body = EncodingUtil.base64Decode('Test');
            attachments.add(a);
        }
        return attachments;
    }

    public static List<Wish_Expense__c> createWishExpense(Integer num, Id budgetId) {
        List<Wish_Expense__c> wishExpenses = new List<Wish_Expense__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Expense__c wishExpense = new Wish_Expense__c();
            wishExpense.Wish_Budget__c = budgetId;
            wishExpenses.add(wishExpense);
        }
        return wishExpenses;
    }

    public static List<Wish_Expense_Type__c> createWishExpenseTypes(Integer num, String typeName) {
        List<Wish_Expense_Type__c> wishExpenseTypes = new List<Wish_Expense_Type__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Expense_Type__c wishExpenseType = new Wish_Expense_Type__c();
            wishExpenseType.Name = typeName;
            wishExpenseTypes.add(wishExpenseType);
        }
        return wishExpenseTypes;
    }

    public static List<Wish_Expense_Transaction_Code__c> createWishTransCodes(Integer num, String typeName) {
        List<Wish_Expense_Transaction_Code__c> wishTransCodes = new List<Wish_Expense_Transaction_Code__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Expense_Transaction_Code__c wishExpenseType = new Wish_Expense_Transaction_Code__c();
            wishExpenseType.Name = typeName;
            wishTransCodes.add(wishExpenseType);
        }
        return wishTransCodes;
    }

    public static List<Wish_Change_Request__c> createWishChangeRequests(Integer num, Id wishCaseRecordId,
            Id wishAffiliationId) {
        List<Wish_Change_Request__c> wishChangeRequests = new List<Wish_Change_Request__c>();
        for (Integer i = 0; i < num; i++) {
            Wish_Change_Request__c wishChangeRequest = new Wish_Change_Request__c();
            wishChangeRequest.Wish_Case_Id__c = wishCaseRecordId;
            wishChangeRequest.Wish_Affiliation__c = wishAffiliationId;
            wishChangeRequests.add(wishChangeRequest);
        }
        return wishChangeRequests;
    }

    public static List<Lead> createLead(Integer num) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < num; i++) {
            Lead lead = new Lead();
            leads.add(lead);
        }
        return leads;
    }

    public static List<Volunteer_Roles__c> createVolunteerRole(Integer num) {
        List<Volunteer_Roles__c> volunteerRoles = new List<Volunteer_Roles__c>();
        for (Integer i = 0; i < num; i++) {
            Volunteer_Roles__c volunteerRole = new Volunteer_Roles__c();
            volunteerRoles.add(volunteerRole);
        }
        return volunteerRoles;
    }

    public static List<Conflict_Of_Interest__c> createConflictOfInterest(Integer num) {
        List<Conflict_Of_Interest__c> conflictOfInterests = new List<Conflict_Of_Interest__c>();
        for (Integer i = 0; i < num; i++) {
            Conflict_Of_Interest__c conflictOfInterest = new Conflict_Of_Interest__c();
            conflictOfInterests.add(conflictOfInterest);
        }
        return conflictOfInterests;
    }

    public static List<Background_check__c> createBackgroundCheck(Integer num) {
        List<Background_check__c> backgroundChecks = new List<Background_check__c>();
        for (Integer i = 0; i < num; i++) {
            Background_check__c backgroundCheck = new Background_check__c();
            backgroundChecks.add(backgroundCheck);
        }
        return backgroundChecks;
    }

    public static List<Class_Offering__c> createClassOffering(Integer num) {
        List<Class_Offering__c> classOfferings = new List<Class_Offering__c>();
        for (Integer i = 0; i < num; i++) {
            Class_Offering__c classOffering = new Class_Offering__c();
            classOfferings.add(classOffering);
        }
        return classOfferings;
    }

    public static List<Volunteer_Orientation_Training__c> createVolunteerOrientationAndTraining(Integer num) {
        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = new List<Volunteer_Orientation_Training__c>();
        for (Integer i = 0; i < num; i++) {
            Volunteer_Orientation_Training__c volunteerOrientationTraining = new Volunteer_Orientation_Training__c();
            volunteerOrientationTrainings.add(volunteerOrientationTraining);
        }
        return volunteerOrientationTrainings;
    }

    public static List<Diagnosis_Verification__c> createDiagnosisVerification(Integer num) {
        List<Diagnosis_Verification__c> diagnosisVerifications = new List<Diagnosis_Verification__c>();
        for (Integer i = 0; i < num; i++) {
            Diagnosis_Verification__c diagnosisVerification = new Diagnosis_Verification__c();
            diagnosisVerifications.add(diagnosisVerification);
        }
        return diagnosisVerifications;
    }

    public static List<cg__Lead_File__c> createLeadFile(Integer num) {
        List<cg__Lead_File__c> leadFiles = new List<cg__Lead_File__c>();
        for (Integer i = 0; i < num; i++) {
            cg__Lead_File__c leadFile = new cg__Lead_File__c();
            leadFile.cg__File_Name__c = 'MedicalSummary.txt';
            leadFile.cg__Content_Type__c = 'text/plain';
            leadFiles.add(leadFile);
        }
        return leadFiles;
    }

    public static List<Volunteer_Opportunity__c> createVolunteerOpportunity(Integer num) {
        List<Volunteer_Opportunity__c> volunteerOpportunities = new List<Volunteer_Opportunity__c>();
        for (Integer i = 0; i < num; i++) {
            Volunteer_Opportunity__c volunteerOpportunity = new Volunteer_Opportunity__c();
            volunteerOpportunities.add(volunteerOpportunity);
        }
        return volunteerOpportunities;
    }

    public static List<Task> createTask(Integer num) {
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < num; i++) {
            Task t = new Task();
            tasks.add(t);
        }
        return tasks;
    }
    
    public static List<Group> createGroup(Integer num) {
        List<Group> groups = new List<Group>();
        for(Integer i = 0; i < num; i++) {
            Group g = new Group();
            g.Name = 'Group ' + i;
            groups.add(g);
        }
        return groups;
    }

    public static List<cg__AccountFile__c> createAccountFile(Integer num) {
        List<cg__AccountFile__c> accountFiles = new List<cg__AccountFile__c>();
        for (Integer i = 0; i < num; i++) {
			cg__AccountFile__c accountFile = new cg__AccountFile__c();
            accountFile.cg__File_Name__c = 'MedicalSummary.txt';
            accountFile.cg__Content_Type__c = 'text/plain';
            accountFiles.add(accountFile);
        }
        return accountFiles;
    }

    public static List<Condition_Description__c> createConditionDescription(Integer num) {
        List<Condition_Description__c> conditionDescriptions = new List<Condition_Description__c>();
        for (Integer i = 0; i < num; i++) {
			Condition_Description__c conditionDescription = new Condition_Description__c();
            conditionDescriptions.add(conditionDescription);
        }
        return conditionDescriptions;
    }

    public static List<Medical_Questions__c> createMedicalQuestions(Integer num) {
        List<Medical_Questions__c> medicalQuestions = new List<Medical_Questions__c>();
        for (Integer i = 0; i < num; i++) {
			Medical_Questions__c medicalQuestion = new Medical_Questions__c();
			medicalQuestions.add(medicalQuestion);
        }
        return medicalQuestions;
    }

	public static List<npe5__Affiliation__c> createAffiliation(Integer num) {
		List<npe5__Affiliation__c> affiliations = new List<npe5__Affiliation__c>();
		for (Integer i = 0; i < num; i++) {
			npe5__Affiliation__c a = new npe5__Affiliation__c();
			affiliations.add(a);
		}
		return affiliations;
	}
    
    public static List<Non_Wish_Events__c> createNonwishEvent(Integer num) {
        List<Non_Wish_Events__c> nonWishEvents = new List<Non_Wish_Events__c>();
        for(Integer i = 0; i < num; i++) {
            Non_Wish_Events__c nonWishEvent = new Non_Wish_Events__c();
            nonWishEvents.add(nonWishEvent);
        }
        return nonWishEvents;
    }
    
    public static List<Time_sheet__c> createTimesheet(Integer num) {
        List<Time_sheet__c> timesheets = new List<Time_sheet__c>();
        for(Integer i = 0; i < num; i++) {
            Time_sheet__c timesheet = new Time_sheet__c();
            timesheets.add(timesheet);
        }
        return timesheets;
    }
    
    public static List<Chapter_Vs_Role__c> createChapterVsRole(Integer num) {
        List<Chapter_Vs_Role__c> chapterRoleList = new List<Chapter_Vs_Role__c>();
        for(Integer i = 0; i < num; i++) {
            Chapter_Vs_Role__c chapterRole = new Chapter_Vs_Role__c();
            chapterRoleList.add(chapterRole);
        }
        return chapterRoleList;
    }
    
    public static List<Awards_Recognition__c> createAwardsRecognitions(Integer num) {
        List<Awards_Recognition__c> awards = new List<Awards_Recognition__c>();
        for(Integer i = 0; i < num; i++) {
            Awards_Recognition__c award = new Awards_Recognition__c();
            awards.add(award);
        }
        return awards;
    }
    
    public static List<Dynamic_Content__c> createDynamicContent(Integer num) {
        List<Dynamic_Content__c> contentList = new List<Dynamic_Content__c>();
        for(Integer i = 0; i < num; i++) {
            Dynamic_Content__c content = new Dynamic_Content__c();
            contentList.add(content);
        }
        return contentList;
    }

	public static Lead createQualifiedLead(Id accountId, Id icdCodeId){
		Lead lead = new Lead();
		lead.Additional_Parent_City__c = 'Phoenix';
		lead.Additional_Parent_Email__c = 'additionalParent@email.com';
		lead.Additional_Parent_First_Name__c = 'Mother';
		lead.Additional_Parent_Last_Name__c = 'Smith';
		lead.Additional_Parent_Phone__c = '5555555555';
		lead.Additional_Parent_Postal_Code__c = '85020';
		lead.Additional_Parent_Relationship_to_Child__c = 'Mother';
		lead.Additional_Parent_State__c = 'Arizona';
		lead.Additional_Parent_Street__c = '123 St';
		lead.AddressVerified__c = false;
		lead.Age_Requirement_Met__c = false;
		lead.Alternate_1_Medical_Professional_Type__c = 'Physician';
		lead.Alternate_2_Medical_Professional_Type__c = 'Physician';
		lead.Alternate1HospitalTreatmentFacility__c = 'Banner Hospital';
		lead.Alternate1MedicalProfessionalEmail__c = 'alt1MedicalProfessional@email.com';
		lead.Alternate1MedProfessionalFirstName__c = 'Alt1MedicalProfessional';
		lead.Alternate1MedProfessionalLastName__c = 'Johnson';
		lead.Alternate1MedProfessionalPhone__c = '5555555555';
		lead.Alternate2HospitalTreatmentFacility__c = 'Banner Hospital';
		lead.Alternate2MedProfessionalEmail__c = 'alt2MedicalProfessional@email.com';
		lead.Alternate2MedProfessionalFirstName__c = 'Alt2MedicalProfessional';
		lead.Alternate2MedProfessionalLastName__c = 'Johnson';
		lead.Alternate2MedProfessionalPhone__c = '5555555555';
		lead.Any_medical_reason_for_moving_quickly__c = 'No';
		lead.Auto_Qualified__c = true;
		lead.Best_contact_for_Physician_Email__c = 'bestMedicalProfessional@email.com';
		lead.Best_Contact_for_Physician_First_Name__c = 'Best';
		lead.Best_Contact_for_Physician_Last_Name__c = 'Johnson';
		lead.ChapterName__c = accountId;
		lead.Child_Age__c = '6';
		lead.Child_will_ultimately_die_prematurely__c = false;
		lead.City = 'Phoenix';
		lead.Communication__c = 'This child is developmentally on target for chronological age';
		lead.Company = 'Make-A-Wish';
		lead.Country = 'United States';
		lead.CountryCode = 'US';
		lead.CreatedDate = Date.today();
		lead.Current_Condition_Label__c = '1.I am not sure;';
		lead.Debilitation_may_extend_over_many_years__c = false;
		lead.Diagnosis_Given_By_Referrer__c = 'Neoplasm';
		lead.DOB__c = Date.today() - 1435;
		lead.DOB_Text__c = '2013-05-05';
		lead.DoNotCall = false;
		lead.Dup_Check__c = 'Block Lead Dup';
		lead.DV_Present__c = true;
		lead.Email = 'parentLegalGuardian@email.com';
		lead.FirstName = 'Mark';
		lead.From_Mulesoft__c = false;
		lead.Gender__c = 'Male';
		lead.Has_this_child_ever_received_prior_wish__c = 'No';
		lead.HasOptedOutOfEmail = false;
		lead.HasOptedOutOfFax = false;
		lead.Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
		lead.Hidden_Field__c = false;
		lead.Hidden_Potential_Rush__c = 'No';
		lead.Hidden_Trigger_Referral_Email__c = false;
		lead.HiddenMedicalProfessionalEmail__c = 'treatingMedicalProfessional@email.com';
		lead.Hospital_Treatment_Facility__c = 'Banner Hospital';
		lead.Hospital_Treatment_Facility_Treating__c = 'Banner Hospital';
		lead.How_Did_you_hear_about_Make_A_Wish__c = 'Physician';
		lead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		lead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'Yes';
		lead.ICD_Given_By_Referrer__c = icdCodeId;
		lead.Increased_probability_of_premature_death__c = false;
		lead.Inquiry_Date__c = Date.today();
		lead.Is_Chapter_Active__c = false;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Is_in_a_Comatose_Vegetative_State__c = 'No';
		lead.Is_Required_Bypass__c = true;
		lead.isApprove__c = false;
		lead.IsConverted = false;
		lead.isSign__c = true;
		lead.IsUnreadByOwner = true;
		lead.LastModifiedDate = Date.today();
		lead.LastName = 'Smith';
		lead.Lead_Owner_Dupe_Alert__c = false;
		lead.LeadSource = 'Online';
		lead.Medical_Professional_Email__c = 'referringMedicalProfessional@email.com';
		lead.Medical_Professional_Last_Name__c = 'Johnson';
		lead.Medical_Professional_Phone__c = '5555555555';
		lead.Medical_Provider_Category__c = 'Physician';
		lead.Migrated_Record__c = false;
		lead.None_of_these_statements_describes_Child__c = false;
		lead.Number_hospital_admissions__c = 0;
		lead.of_Siblings__c = '2';
		lead.Of_Times_Email_Sent__c = 1;
		lead.Office_Referral_Email__c = 'test.referrals@arizona.wish.org';
		lead.Out_of_Territory__c = false;
		lead.Override_Dupe_Check__c = true;
		lead.Parent_First_Name__c = 'Father';
		lead.Parent_Last_Name__c = 'Smith';
		lead.Parent_Relationship_to_Child__c = 'Father';
		lead.Part_A_DV_Recipient__c = 'TreatingMedicalProfessional Johnson';
		lead.Part_A_Form_Password__c = '383639';
		lead.Part_A_Received__c = Date.today();
		lead.Part_A_Sent__c = Date.today();
		lead.PD_Condition_Description__c = 'Neoplasm';
		lead.PD_ICD_Code__c = icdCodeId;
		lead.Pending_Diagnosis_Date__c = Date.today();
		lead.Phone = '5555555555';
		lead.PostalCode = '85001';
		lead.Provided_additional_information__c = 'Abcdefg';
		lead.Provider_Signature__c = 'TreatingMedicalProfessional Johnson';
		lead.Qualified_Date__c = Date.today();
		lead.Qualifying_Diagnosis__c = 'Neoplasm';
		lead.Qualifying_ICD__c = icdCodeId;
		lead.ReferralComment__c = 'Abcdefg';
		lead.Referred_Date__c = Date.today();
		lead.Referrer_City__c = 'Phoenix';
		lead.Referrer_Email__c = 'referer@email.com';
		lead.Referrer_FirstName__c = 'Referrer';
		lead.Referrer_Last_Name__c = 'Johnson';
		lead.Referrer_Phone__c = '5555555555';
		lead.Referrer_Zip__c = '85001';
		lead.Relationship_to_child__c = 'Medical Professional';
		lead.Responds_to_treatment_with_normal_health__c = false;
		lead.RFI_Form_Info_Hidden__c = 'Qualified';
		lead.Risk_of_complications_premature_death__c = false;
		lead.Rush__c = false;
		lead.Sibling_Detail__c = 'Sib1 | Smith | 2<br>Sib2 | Smith | 4<br>';
		lead.State = 'Arizona';
		lead.StateCode = 'AZ';
		lead.Status = 'Qualified';
		lead.Street = '123 St';
		lead.Test_Record__c = false;
		lead.Travel_algorithm__c = 'I am not sure;';
		lead.Travel_Restriction__c = '1. I am not sure';
		lead.Treating_Medical_Professional_Email__c = 'treatingMedicalProfessional@email.com';
		lead.Treating_Medical_Professional_First_Name__c = 'TreatingMedicalProfessional';
		lead.Treating_Medical_Professional_Last_Name__c = 'Johnson';
		lead.Treating_Medical_Professional_Phone__c = '5555555555';
		lead.Treatment_may_be_feasible_but_can_fail__c = false;
		lead.Treatment_may_prolong_normal_activities__c = true;
		lead.Unplanned_hospital_admissions__c = 'No';
		lead.Using_Paper_Process_For_DV__c = false;
		lead.VisualAntidote__Fast_Forms_Auto_Assign__c = false;
		lead.VisualAntidote__Fast_Forms_Autoresponse__c = false;
		lead.Will_Child_s_Condition_Deteriorate__c = 'Not Sure';
		return lead;
	}
}