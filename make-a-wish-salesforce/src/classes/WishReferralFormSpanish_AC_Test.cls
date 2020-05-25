@IsTest
public class WishReferralFormSpanish_AC_Test {

    @TestSetup
    static void setup() {
        Condition_Description__c conditionDescription = new Condition_Description__c(Name = 'Cancer', Code_To_Use__c = 'C00');
        insert conditionDescription;

        ICD_Codes__c icdCode = new ICD_Codes__c();
        icdCode.Name = 'C00';
        icdCode.Condition_Description__c = conditionDescription.Id;
        insert icdCode;

        List<Account> chapterAccounts = TestDataFactory.createAccount(1);
        chapterAccounts[0].Intake_Manager__c = UserInfo.getUserId();
        insert chapterAccounts;

        Office__c office = new Office__c(Name = Utils.generateRandomCharacterString(7));
        insert office;

        Zip_Code__c zipCode = new Zip_Code__c(Name = '85016', External_Id__c = Utils.generateRandomNumber(7));
        zipCode.Office__c = office.Id;
        insert zipCode;
    }

    @IsTest static void relationshipNone() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.warningMsg = Label.Wish_Form_Welcome_Message;
        controller.displayWarningPopup = true;
        controller.CreateLead();
        controller.currLead.Child_Age__c = Constant_AC.LEAD_CHILD_AGE_UNDER_2_5;

        controller.getlanguage();
        controller.getdiaYear();
        controller.getNoOfSiblings();
        controller.getSelfRequiredFields();
        controller.getNonMedicalReqFields();
        controller.getMedicalRequiredFields();

        WishReferralFormSpanish_AC.siblingWrapper sibling = new WishReferralFormSpanish_AC.siblingWrapper();
        String fName = sibling.fName;
        String lName = sibling.lName;
        String age = sibling.age;
        String refChildFormParent = controller.refChildFormParent;
        String referralComment = controller.referralComment;
    }

    @IsTest
    static void relationshipSelf() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        controller.currLead.Child_Age__c = String.valueOf(5);
        controller.CreateLead();
        controller.CopyReferralInfo();
    }

    @IsTest
    static void relationshipSelf1() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();

        fillReferralContacts(controller.currLead);

        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Child_Age__c = String.valueOf(15);
        controller.currLead.DOB__c = Date.today().addYears(-15);
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;

        controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';

        ICD_Codes__c icdCode = [
                SELECT Id, Name
                FROM ICD_Codes__c
                WHERE Name = 'C00'
                LIMIT 1
        ];
        controller.diagnosisFilter = icdCode.Name;
        controller.selectedDiagnosis = icdCode.Name;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = Utils.generateRandomCharacterString(7);
        controller.currList = new List<WishReferralFormSpanish_AC.siblingWrapper>{
                new WishReferralFormSpanish_AC.siblingWrapper()
        };
        controller.currList[0].fName = Utils.generateRandomCharacterString(3);
        controller.currList[0].lName = Utils.generateRandomCharacterString(7);
        controller.currList[0].age = Utils.generateRandomCharacterString(1);

        controller.CreateLead();
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        controller.CreateLead();
        controller.CopyReferralInfo();
    }

    @IsTest static void relationshipSelf2() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC_Test.createContact();
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Medical_Provider_Category__c = Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN;
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        fillReferralContacts(controller.currLead);
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        controller.currLead.Child_Age__c = String.valueOf(16);
        controller.currLead.DOB__c = Date.valueOf(Date.today().addYears(-16));
        controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';

        Condition_Description__c conditionDescription = [
                SELECT Id, Name, Code_To_Use__c
                FROM Condition_Description__c
                WHERE Code_To_Use__c = 'C00'
        ];
        controller.diagnosisFilter = conditionDescription.Code_To_Use__c;
        controller.selectedDiagnosis = conditionDescription.Name;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = Utils.generateRandomCharacterString(13);
        controller.currLead.Treating_Medical_Professional_First_Name__c = controller.currLead.Referrer_FirstName__c;
        controller.currLead.Treating_Medical_Professional_Last_Name__c = controller.currLead.Referrer_Last_Name__c;
        controller.currLead.Treating_Medical_Professional_Phone__c = controller.currLead.Referrer_Phone__c;
        controller.currLead.Treating_Medical_Professional_Email__c = controller.currLead.Referrer_Email__c;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.diagnosisYear = String.valueOf(Date.today().year() - 4);
        controller.diagnosisMonth = String.valueOf(Date.today().month());
        controller.CreateLead();
        controller.CopyReferralInfo();
    }

    @IsTest
    public static void relationshipSelf3() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC_Test.createContact();
        List<SelectOption> statesList = controller.getStates();

        Condition_Description__c conditionDescription = [
                SELECT Id, Name, Code_To_Use__c
                FROM Condition_Description__c
                WHERE Code_To_Use__c = 'C00'
        ];
        ICD_Codes__c icdCode = [
                SELECT Id, Name
                FROM ICD_Codes__c
                WHERE Name = 'C00'
                LIMIT 1
        ];

        Lead dupeLead = new Lead();
        dupeLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        dupeLead.PD_ICD_Code__c = icdCode.Id;
        dupeLead.PD_Condition_Description__c = conditionDescription.Name;
        dupeLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
        dupeLead.Diagnosis_Given_By_Referrer__c = conditionDescription.Name;
        dupeLead.Hospital_Treatment_Facility__c = Utils.generateRandomCharacterString(10) + ' ' + Utils.generateRandomCharacterString(8);
        dupeLead.Hospital_Treatment_Facility_Treating__c = dupeLead.Hospital_Treatment_Facility__c;
        dupeLead.Treating_Medical_Professional_Last_Name__c = Utils.generateRandomCharacterString(9);
        dupeLead.Gender__c = Constant_AC.CONTACT_GENDER_MALE;
        dupeLead.Company = Utils.generateRandomCharacterString(7) + ', Inc.';

        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        fillReferralContacts(controller.currLead);
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;

        controller.currLead.Child_Age__c = '16';
        controller.currLead.DOB__c = dupeLead.DOB__c = Date.valueOf(Date.today().addYears(-16));
        controller.currLead.State = statesList[Math.mod(Math.abs(Crypto.getRandomInteger()), statesList.size() - 1)].getValue();
        dupeLead.FirstName = controller.currLead.FirstName;
        dupeLead.LastName = controller.currLead.LastName;
        dupeLead.Street = controller.currLead.Street;
        dupeLead.City = controller.currLead.City;
        dupeLead.State = controller.currLead.State;
        dupeLead.PostalCode = controller.currLead.PostalCode;
        dupeLead.Email = controller.currLead.Email;
        dupeLead.Phone = controller.currLead.Phone;
        controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';
        controller.diagnosisFilter = icdCode.Name;
        controller.selectedDiagnosis = conditionDescription.Name;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = Utils.generateRandomCharacterString(12);
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.PD_Condition_Description__c = conditionDescription.Name;
        Lead dupeLead2 = dupeLead.clone();
        dupeLead2.Status = Constant_AC.LEAD_STATUS_INQUIRY;
        Lead dupeLead3 = dupeLead.clone();
        dupeLead3.Status = 'Other';

        insert new List<Lead>{
                dupeLead, dupeLead2, dupeLead3
        };
        controller.CreateLead();
        controller.CopyReferralInfo();
    }

    @IsTest
    public static void relationshipOther() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_OTHER;
        controller.CreateLead();
    }

    @IsTest
    public static void relationshipMedicalProfessional() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        controller.currLead.Medical_Provider_Category__c = Constant_AC.LEAD_MEDICAL_PROVIDER_NURSE_PRACTITIONER;

        controller.CreateLead();
    }

    @IsTest
    public static void medicalFirstNameblank() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        controller.currLead.LastName = Utils.generateRandomCharacterString(8);
        controller.diagnosisYear = String.valueOf(Date.today().addYears(-2));
        controller.diagnosisMonth = String.valueOf(Date.today().month());
        controller.CreateLead();
    }

    @IsTest
    public static void relationshipFamily() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
        controller.currLead.LastName = Utils.generateRandomCharacterString(4);
        controller.currLead.DOB__c = Date.today().addYears(-16);
        controller.currLead.Child_Age__c = '16';
        controller.CreateLead();
    }

    @IsTest
    public static void relationshipSibling() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
        controller.currLead.LastName = Utils.generateRandomCharacterString(10);
        controller.currLead.DOB__c = Date.today().addDays(-1050);
        controller.currLead.of_Siblings__c = '2';
        controller.getSiblingList();
        controller.CreateLead();
        controller.getStates();
        controller.copyReferrerInfo = true;
        controller.CopyReferralInfo();
        controller.getNoOfSiblings();
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        controller.disPlayChildForm();
    }

    @IsTest
    public static void relationshipSibling2() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        controller.currLead.LastName = Utils.generateRandomCharacterString(10);
        controller.currLead.DOB__c = Date.today().addDays(-1050);
        controller.currLead.of_Siblings__c = '2';
        controller.getSiblingList();
        controller.CreateLead();
        controller.getStates();
        controller.copyReferrerInfo = true;
        controller.CopyReferralInfo();
        controller.getNoOfSiblings();
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        controller.disPlayChildForm();
    }

    @IsTest
    public static void callmethods() {
        WishReferralFormSpanish_AC obj = new WishReferralFormSpanish_AC();
        obj.getNonMedicalReqFields();
        obj.getMedicalRequiredFields();
        obj.getSelfRequiredFields();
        obj.getRelationshipsToChild();
        obj.getHearWish();
        obj.getChildagesp();
        obj.getHereAboutMAW();
        obj.getdiaYear();
        obj.getCommunication();
    }

    static Contact createContact() {
        Contact currCon = new Contact();
        currCon.FirstName = Utils.generateRandomCharacterString(7);
        currCon.LastName = Utils.generateRandomCharacterString(11);
        currCon.Birthdate = Date.today().addYears(-17);
        currCon.Phone = Utils.generateRandomNumber(10);
        currCon.Email = Utils.generateRandomEmailAddress();

        Condition_Description__c conditionDescription = [
                SELECT Id, Name
                FROM Condition_Description__c
                WHERE Code_To_Use__c = 'C00'
                LIMIT 1
        ];

        currCon.Diagnosis__c = conditionDescription.Name;
        insert currCon;
        return currCon;
    }

    private static void fillReferralContacts(Lead leadToFill) {
        Zip_Code__c zipCode = [
                SELECT Id, Name
                FROM Zip_Code__c
                WHERE Name = '85016'
                LIMIT 1
        ];

        leadToFill.Referrer_FirstName__c = Utils.generateRandomCharacterString(5);
        leadToFill.Referrer_Last_Name__c = Utils.generateRandomCharacterString(5);
        leadToFill.Referrer_Phone__c = Utils.generateRandomNumber(10);
        leadToFill.Referrer_Email__c = Utils.generateRandomEmailAddress();
        leadToFill.Referrer_City__c = Utils.generateRandomCharacterString(8);
        leadToFill.Referrer_Zip__c = zipCode.Name;
        leadToFill.Medical_Provider_Category__c = Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN;

        leadToFill.FirstName = Utils.generateRandomCharacterString(5);
        leadToFill.Child_Middle_Initial__c = Utils.generateRandomCharacterString(1);
        leadToFill.LastName = Utils.generateRandomCharacterString(7);
        leadToFill.Gender__c = Constant_AC.CONTACT_GENDER_MALE;

        leadToFill.Parent_First_Name__c = Utils.generateRandomCharacterString(8);
        leadToFill.Parent_Last_Name__c = Utils.generateRandomCharacterString(8);
        leadToFill.Street = Utils.generateRandomNumber(3) + ' ' + Utils.generateRandomCharacterString(7);
        leadToFill.State = Utils.generateRandomCharacterString(20);
        leadToFill.City = Utils.generateRandomCharacterString(8);
        leadToFill.PostalCode = zipCode.Name;
        leadToFill.Email = Utils.generateRandomEmailAddress();
        leadToFill.Phone = Utils.generateRandomNumber(10);
        leadToFill.Treating_Medical_Professional_First_Name__c = Utils.generateRandomCharacterString(8);
        leadToFill.Treating_Medical_Professional_Last_Name__c = Utils.generateRandomCharacterString(7);
        leadToFill.Treating_Medical_Professional_Phone__c = Utils.generateRandomNumber(10);
        leadToFill.Treating_Medical_Professional_Email__c = Utils.generateRandomEmailAddress();
    }

}