@IsTest
public class ContactMergeController_Test {

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        Account accountAzChapter = TestDataFactory.createAccount(1)[0];
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountAzChapter;
        
        List<Contact> contactList = TestDataFactory.createContact(5);
        Contact volunteerPamela = contactList.get(0);
        volunteerPamela.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerPamela.AccountId = accountAzChapter.Id;
        volunteerPamela.FirstName = 'Pamela';
        volunteerPamela.LastName = 'Isley';
        volunteerPamela.Email = 'p.ivy@email.com';
        volunteerPamela.Phone = '5557779999';
        volunteerPamela.Birthdate = Date.today().addYears(-19);
        volunteerPamela.MailingPostalCode = '85641';
        volunteerPamela.MailingStreet = '1500 1st Avenue';
        volunteerPamela.MailingCountry = 'United States';
        volunteerPamela.MailingState = 'Arizona';
        volunteerPamela.MailingStateCode = 'AZ';
        volunteerPamela.MailingCity = 'Phoenix';

        Contact wishChildJacobi = contactList.get(1);
        wishChildJacobi.Region_Chapter__c = accountAzChapter.Id;
        wishChildJacobi.FirstName = 'Jacobi';
        wishChildJacobi.LastName = 'Smith';
        wishChildJacobi.Email = 'testmawa@gmail.com';
        wishChildJacobi.Phone = '9600467559';
        wishChildJacobi.OtherPhone = '8056913402';
        wishChildJacobi.MobilePhone = '9003910426';
        wishChildJacobi.MailingStreet = '100 East Street';
        wishChildJacobi.MailingCity = 'Trichy';
        wishChildJacobi.MailingState = 'Arizona';
        wishChildJacobi.MailingStateCode = 'AZ';
        wishChildJacobi.MailingPostalCode = '85251';
        wishChildJacobi.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishChildJacobi.MobilePhone = '9900220022';
        wishChildJacobi.Primary_Diagnosis_Condition_Description__c = 'Test Diagnosis';
        wishChildJacobi.Diagnosis__c = 'Test Diagnosis';

        Contact wishFamilySmith = contactList.get(2);
        wishFamilySmith.FirstName = 'Danielle';
        wishFamilySmith.LastName = 'Smith';
        wishFamilySmith.Email = 'testmawa@gmail.com';
        wishFamilySmith.Phone = '9600467559';
        wishFamilySmith.MailingStreet = '100 East Street';
        wishFamilySmith.MailingCity = 'Trichy';
        wishFamilySmith.MailingStateCode = 'AZ';
        wishFamilySmith.MailingPostalCode = '85251';
        wishFamilySmith.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        wishFamilySmith.IsParentGuardian__c = 'ParentGuardian';
        wishFamilySmith.Region_Chapter__c = accountAzChapter.Id;

        Contact medicalProfContact = contactList.get(3);
        medicalProfContact.FirstName = 'Rhonda';
        medicalProfContact.LastName = 'Oracle';
        medicalProfContact.Email = 'rhonda.oracle@gmail.com';
        medicalProfContact.Phone = '9600467554';
        medicalProfContact.MailingStreet = '1250 Phoenix Ave';
        medicalProfContact.MailingCity = 'Phoenx';
        medicalProfContact.MailingStateCode = 'AZ';
        medicalProfContact.MailingPostalCode = '85200';
        medicalProfContact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

        Contact volunteerPamelaDupe = contactList.get(4);
        volunteerPamelaDupe.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerPamelaDupe.AccountId = accountAzChapter.Id;
        volunteerPamelaDupe.FirstName = 'Pamela';
        volunteerPamelaDupe.LastName = 'Isley';
        volunteerPamelaDupe.Email = 'pam.isley@email.com';
        volunteerPamelaDupe.Phone = '5557779999';
        volunteerPamelaDupe.Birthdate = Date.today().addYears(-19);
        volunteerPamelaDupe.MailingPostalCode = '85265';
        volunteerPamelaDupe.MailingStreet = '1500 Shea Blvd';
        volunteerPamelaDupe.MailingCountry = 'United States';
        volunteerPamelaDupe.MailingState = 'Arizona';
        volunteerPamelaDupe.MailingCity = 'Scottsdale';
        insert contactList;

        User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
        volunteerUser.LastName = 'Smith0';
        volunteerUser.Email = 'js@email.com';
        System.runAs(TestDataFactory.adminUser) {
            insert volunteerUser;
        }
        
        List<Case> caseList = TestDataFactory.createCase(4);
        caseList[0].ContactId = volunteerPamela.Id;
        caseList[1].ContactId = wishChildJacobi.Id;
        caseList[2].ContactId = wishFamilySmith.Id;
        caseList[3].ContactId = medicalProfContact.Id;
        insert caseList;
        
        Conflict_Of_Interest__c volunteerCoi = TestDataFactory.createConflictOfInterest(1)[0];
        volunteerCoi.Volunteer_Contact__c = volunteerPamela.Id;
        volunteerCoi.Expiration_Date__c = Date.today().addDays(60);
        insert volunteerCoi;
        
        Background_check__c volunteerBackgroundCheck = TestDataFactory.createBackgroundCheck(1)[0];
        volunteerBackgroundCheck.Date__c = System.today() + 60;
        volunteerBackgroundCheck.Volunteer__c = volunteerPamela.Id;
        volunteerBackgroundCheck.Status__c = 'Approved';
        volunteerBackgroundCheck.Current__c = true;
        volunteerBackgroundCheck.Date_Completed__c = System.today();
        insert volunteerBackgroundCheck;
        
        Role__c wishRole = TestDataFactory.createRole(1, true)[0];
        wishRole.Name = 'Wish Granter';
        insert wishRole;
        
        Orientation_Training__c volunteerOrientationTraining = TestDataFactory.createOrientationTraining(1)[0];
        volunteerOrientationTraining.Name = 'Volunteer Orientation';
        volunteerOrientationTraining.Chapter_Name__c = accountAzChapter.Id;
        volunteerOrientationTraining.RecordTypeId = Constant_AC.TRAINING_RT_ID;
        volunteerOrientationTraining.Start_Time__c = '7:00 AM';
        volunteerOrientationTraining.End_Time__c = '7:00 PM';
        insert volunteerOrientationTraining;
        
        Chapter_Role__c chapterRoleWishGranter = TestDataFactory.createChapterRole(1)[0];
        chapterRoleWishGranter.Chapter_Name__c = accountAzChapter.Id;
        chapterRoleWishGranter.Role_Name__c = wishRole.Id;
        insert chapterRoleWishGranter;
        
        Chapter_Role_O_T__c azChapterOrientationTraining = TestDataFactory.createChapterRoleOrientationAndTraining(1)[0];
        azChapterOrientationTraining.Chapter_Role__c = chapterRoleWishGranter.Id;
        azChapterOrientationTraining.Orientation_Training__c = volunteerOrientationTraining.Id;
        azChapterOrientationTraining.Required__c = true;
        insert azChapterOrientationTraining;
        
        Class_Offering__c classOffering = TestDataFactory.createClassOffering(1)[0];
        classOffering.Chapter_Role_O_T__c = azChapterOrientationTraining.Id;
        classOffering.Date__c = System.today() + 10;
        classOffering.Start_Time__c = '10:00 AM';
        classOffering.End_Time__c = '11:00 AM';
        classOffering.max_capacity__c = 100;
        classOffering.Location__c = 'Online';
        classOffering.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        insert classOffering;
        
        npe4__Relationship__c smithFamilyRelationship = TestDataFactory.createRelationship(1)[0];
        smithFamilyRelationship.npe4__Contact__c = wishChildJacobi.Id;
        smithFamilyRelationship.npe4__RelatedContact__c = wishFamilySmith.Id;
        smithFamilyRelationship.Parent_Legal_Guardian__c = true;
        insert smithFamilyRelationship;
        
        npe5__Affiliation__c neworgAffiliation = TestDataFactory.createAffiliation(1)[0];
        neworgAffiliation.npe5__Contact__c = medicalProfContact.Id;
        neworgAffiliation.npe5__Organization__c = accountAzChapter.Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Pending';
        neworgAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert neworgAffiliation;
        
        Volunteer_Roles__c volunteerRole = TestDataFactory.createVolunteerRole(1)[0];
        volunteerRole.Chapter_Role__c = chapterRoleWishGranter.Id;
        volunteerRole.Volunteer_Name__c = volunteerPamela.Id;
        volunteerRole.Status__c = 'Pending';
        volunteerRole.Sub_status__c = 'Missing Requirement';
        insert volunteerRole;
        
        Volunteer_Orientation_Training__c volunteerOrientation = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        volunteerOrientation.Class_Offering__c = classOffering.Id;
        volunteerOrientation.Hidden_O_T_Id__c = volunteerOrientationTraining.Id;
        volunteerOrientation.Registered_Date__c = Date.today();
        volunteerOrientation.Volunteer__c = volunteerPamela.Id;
        volunteerOrientation.Volunteer_Attendance__c = 'Registered';
        volunteerOrientation.Type__c = 'Orientation';
        insert volunteerOrientation;
        
        Volunteer_Opportunity__c volunteerOppPamela = TestDataFactory.createVolunteerOpportunity(1)[0];
        volunteerOppPamela.Chapter_Name__c = accountAzChapter.Id;
        volunteerOppPamela.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
        volunteerOppPamela.Volunteer_Name__c = volunteerPamela.Id;
        insert volunteerOppPamela;
        
        Awards_Recognition__c volunteerAward = TestDataFactory.createAwardsRecognitions(1)[0];
        volunteerAward.Chapter_Name__c = accountAzChapter.Id;
        volunteerAward.Volunteer_Contact__c = volunteerPamela.Id;
        volunteerAward.Award_Type__c = 'Chapter Recognition';
        insert volunteerAward;
        
        In_Kind_Donation_Reimbursement__c reimbursement = TestDataFactory.createInKindDonationReimbursement(1)[0];
        reimbursement.Wish__c = caseList[1].Id;
        reimbursement.Volunteer_Name__c = volunteerPamela.Id;
        insert reimbursement;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void contactMergeTest() {
        Contact volunteerPam = [
            SELECT Id, Name, FirstName, LastName, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, RecordTypeId 
            FROM Contact 
            WHERE Name = 'Pamela Isley' 
            AND Email = 'p.ivy@email.com'
        ];
        Contact volunteerPamDupe = [
            SELECT Id, Name, FirstName, LastName, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, RecordTypeId
            FROM Contact 
            WHERE Name = 'Pamela Isley' 
            AND Email = 'pam.isley@email.com'
        ];
        Volunteer_Opportunity__c volOppPam = [
            SELECT Id 
            FROM Volunteer_Opportunity__c 
            WHERE Volunteer_Name__c = :volunteerPam.Id
        ];
        Volunteer_Roles__c volRolePam = [
            SELECT Id 
            FROM Volunteer_Roles__c 
            WHERE Volunteer_Name__c = :volunteerPam.Id
        ];
        Volunteer_Orientation_Training__c volOrientationPam = [
            SELECT Id 
            FROM Volunteer_Orientation_Training__c 
            WHERE Volunteer__c = :volunteerPam.Id
        ];
        npe5__Affiliation__c affiliation = [
            SELECT Id 
            FROM npe5__Affiliation__c
            LIMIT 1
        ];
        npe4__Relationship__c relationship = [
            SELECT Id 
            FROM npe4__Relationship__c 
            LIMIT 1
        ];
        Background_check__c backgroundCheckPam = [
            SELECT Id 
            FROM Background_check__c 
            WHERE Volunteer__c = :volunteerPam.Id
        ];
        Awards_Recognition__c awardPam = [
            SELECT Id 
            FROM Awards_Recognition__c 
            WHERE Volunteer_Contact__c = :volunteerPam.Id
        ];
        Conflict_Of_Interest__c coiPam = [
            SELECT Id 
            FROM Conflict_Of_Interest__c 
            WHERE Volunteer_Contact__c = :volunteerPam.Id
        ];
        In_Kind_Donation_Reimbursement__c inKindReimbursement = [
            SELECT Id 
            FROM In_Kind_Donation_Reimbursement__c
        ];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(volunteerPam);
        ContactMergeController_AC testobj = new ContactMergeController_AC(sc);
        testobj.con = volunteerPam;
        testobj.getStates();
        ContactMergeController_AC.ContactWrapper contactwrapper1 = new ContactMergeController_AC.ContactWrapper(volunteerPam);
        ContactMergeController_AC.ContactWrapper contactwrapper2 = new ContactMergeController_AC.ContactWrapper(volunteerPamDupe);
        ContactMergeController_AC.Cell testcellwrap = new ContactMergeController_AC.Cell(volunteerPam.Id, volunteerPam.Name);
        ContactMergeController_AC.VolunteerOpportunityWrapper volopwrap = new ContactMergeController_AC.VolunteerOpportunityWrapper(volOppPam);
        ContactMergeController_AC.VolunteerRoleWrapper volrolwrap = new ContactMergeController_AC.VolunteerRoleWrapper(volRolePam);
        ContactMergeController_AC.VolunteerOTWrapper volotwrap = new ContactMergeController_AC.VolunteerOTWrapper(volOrientationPam);
        ContactMergeController_AC.VolunteerOTWrapper volotwrap2 = new ContactMergeController_AC.VolunteerOTWrapper(volOrientationPam);
        ContactMergeController_AC.AffiliationWrapper affwrap = new ContactMergeController_AC.AffiliationWrapper(affiliation);
        ContactMergeController_AC.AffiliationWrapper affwrap2 = new ContactMergeController_AC.AffiliationWrapper(affiliation);
        ContactMergeController_AC.RelationshipWrapper relwrap = new ContactMergeController_AC.RelationshipWrapper(relationship);
        ContactMergeController_AC.RelationshipWrapper relwrap2 = new ContactMergeController_AC.RelationshipWrapper(relationship);
        ContactMergeController_AC.BackgroundCheckWrapper backgdwrap = new ContactMergeController_AC.BackgroundCheckWrapper(backgroundCheckPam);
        ContactMergeController_AC.AwardsRecognitionWrapper awdwrap = new ContactMergeController_AC.AwardsRecognitionWrapper(awardPam);
        ContactMergeController_AC.ConflictOfInterestWrapper coiwrap = new ContactMergeController_AC.ConflictOfInterestWrapper(coiPam);
        ContactMergeController_AC.InkindDonationWrapper inkindwrap = new ContactMergeController_AC.InkindDonationWrapper(inKindReimbursement);
        ContactMergeController_AC.InkindDonationWrapper inkindwrap2 = new ContactMergeController_AC.InkindDonationWrapper(inKindReimbursement);
        ContactMergeController_AC.FieldRow fieldrow = new ContactMergeController_AC.FieldRow('$MASTER$', 'Master Record', true, 'teststyleclass');
        ContactMergeController_AC.FieldRow fieldrow2 = new ContactMergeController_AC.FieldRow('FirstName', 'Master Record', true, 'teststyleclass');
        contactwrapper1.selected = true;
        testobj.searchResults.add(contactwrapper1);
        contactwrapper2.selected = true;
        testobj.searchResults.add(contactwrapper2);
        testobj.mapHoldingSelectedRecords.put(contactwrapper1.con.Id, contactwrapper1);
        testobj.mapHoldingSelectedRecords.put(contactwrapper2.con.Id, contactwrapper2);
        testobj.selectedRecords.put(volunteerPam.Id, volunteerPam);
        testobj.setPageSize();
        testobj.nextStep();
        testobj.first();
        testobj.next();
        testobj.previous();
        testobj.last();
        Boolean haspre = testobj.hasPrevious;
        Boolean hasnext = testobj.hasNext;
        Integer pageNo = testobj.pageNumber;
        Integer totalPage = testobj.getTotalPages();
        testobj.searchRecords();
        volopwrap.checkbox = true;
        volrolwrap.checkbox = true;
        volotwrap.checkbox = true;
        volotwrap2.checkbox = false;
        testobj.volunteerRoleList.add(volrolwrap);
        relwrap.checkbox = true;
        relwrap2.checkbox = false;
        affwrap.checkbox = true;
        affwrap2.checkbox = false;
        backgdwrap.checkbox = true;
        inkindwrap.checkbox = true;
        inkindwrap2.checkbox = false;
        awdwrap.checkbox = true;
        coiwrap.checkbox = true;
        testobj.volunteerOppList.add(volopwrap);
        testobj.volunteerRoleList.add(volrolwrap);
        testobj.volunteerOTList.add(volotwrap);
        testobj.volunteerOTList.add(volotwrap2);
        testobj.relationshipList.add(relwrap);
        testobj.relationshipList.add(relwrap2);
        testobj.affiliationsList.add(affwrap);
        testobj.affiliationsList.add(affwrap2);
        testobj.backgroundcheckList.add(backgdwrap);
        testobj.awardsRecognitionList.add(awdwrap);
        testobj.inkindDonationList.add(inkindwrap);
        testobj.inkindDonationList.add(inkindwrap2);
        testobj.conflictofInterestList.add(coiwrap);
        testobj.fieldRows.add(fieldrow);
        testobj.fieldRows.add(fieldrow2);

        List<Contact> conlist = new List<Contact>();
        conlist.add(volunteerPam);
        testobj.wrapSOSLResults(conlist);
        Test.setCurrentPage(Page.MergeContact_VF);
        ApexPages.currentPage().getParameters().put('recordId', volunteerPam.Id);
        testobj.selectedRecords.put(volunteerPam.Id, volunteerPam);
        testobj.selectedRecords.put(volunteerPamDupe.Id, volunteerPamDupe);
        testobj.selectDefaultRecord();
        testobj.mergeContacts();
        testobj.volunteerOppList.clear();
        testobj.volunteerOTList.clear();
        testobj.volunteerRoleList.clear();
        testobj.relationshipList.clear();
        testobj.affiliationsList.clear();
        testobj.backgroundcheckList.clear();
        testobj.awardsRecognitionList.clear();
        testobj.inkindDonationList.clear();
        testobj.conflictofInterestList.clear();
        testobj.mergeContacts();
        Test.stopTest();
        
        List<Contact> contactListPostMerge = [
            SELECT Id 
            FROM Contact 
            WHERE Name = 'Pamela Isley'
        ];
        System.assert(contactListPostMerge.size() == 1);
    }
}