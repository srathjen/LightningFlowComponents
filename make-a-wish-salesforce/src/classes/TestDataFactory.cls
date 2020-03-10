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
                        WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
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
        // Community users require associated contact
        List<User> users = createUser(num);
        List<Contact> contacts = createContact(num);
        insert contacts;

        // Must run as admin to create community user
        System.runAs (adminUser) {
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
                User u = users.get(i);
                u.UserRoleId = userRole.Id;
                u.ProfileId = profile.Id;
                u.ContactId = contacts.get(i).Id;
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
}