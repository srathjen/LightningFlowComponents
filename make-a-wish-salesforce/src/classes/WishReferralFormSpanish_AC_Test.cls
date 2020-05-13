@isTest
public class WishReferralFormSpanish_AC_Test {

    static Condition_Description__c conditionDescription = new Condition_Description__c(name='Cancer', Code_to_Use__c = 'C00');
    static ICD_Codes__c icdCode = new ICD_Codes__c();
    static Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
    static Office__c office = OrientationandTrainingUtil.createOffice(chapterAccount.Id);
    static Zip_Code__c zipCode = new Zip_Code__c(name='85016',External_Id__c=randomIntegerString(7));
    static WishReferralFormSpanish_AC.siblingWrapper sibling = new WishReferralFormSpanish_AC.siblingWrapper();
    
    public static testMethod void prepdata()    {
        insert conditionDescription;

        icdCode.Name = 'C00';
        icdCode.Condition_Description__c = conditionDescription.id;
        insert icdCode;

        chapterAccount.Intake_Manager__c = UserInfo.getUserId();
        insert chapterAccount;
        
        insert office;

        zipCode.Office__c = office.Id;
        insert zipCode;
    }

    public static testMethod void relationshipNone() {
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

        String fname = sibling.fname;
        String lname = sibling.lname;
        String age = sibling.age;
    }

    public static testMethod void relationshipSelf() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        controller.currLead.Child_Age__c = String.valueOf(5);
        controller.CreateLead();
        controller.copyReferralInfo();
    }

    public static testMethod void relationshipSelf1() {
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
        prepdata();
        controller.diagnosisFilter = icdCode.Name;
        controller.selectedDiagnosis = icdCode.Name;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = randomCharacterString(7);
        controller.currList = new List<WishReferralFormSpanish_AC.SiblingWrapper>{
                new WishReferralFormSpanish_AC.SiblingWrapper()
        };
        controller.currList[0].fName = randomCharacterString(3);
        controller.currList[0].lName = randomCharacterString(7);
        controller.currList[0].age = randomCharacterString(1);
        
        controller.CreateLead();
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        controller.CreateLead();
        controller.copyReferralInfo();
    }

    public static testMethod void relationshipSelf2() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        Contact con = WishReferralFormSpanish_AC_Test.createContact();
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Medical_Provider_Category__c = Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN;
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        fillReferralContacts(controller.currLead);
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        controller.currLead.Child_Age__c = String.valueOf(16);
        controller.currLead.DOB__c = Date.valueOf(Date.Today().addYears(-16));
        controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';
        controller.diagnosisFilter = conditionDescription.Code_to_Use__c;
        controller.selectedDiagnosis = conditionDescription.Name;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = randomCharacterString(13);
        controller.currLead.Treating_Medical_Professional_First_Name__c = controller.currLead.Referrer_FirstName__c;
        controller.currLead.Treating_Medical_Professional_Last_Name__c = controller.currLead.Referrer_Last_Name__c;
        controller.currLead.Treating_Medical_Professional_Phone__c = controller.currLead.Referrer_Phone__c;
        controller.currLead.Treating_Medical_Professional_Email__c = controller.currLead.Referrer_Email__c;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.diagnosisYear = String.valueOf(Date.Today().Year()-4);
        controller.diagnosisMonth = String.valueOf(Date.Today().Month());
        controller.CreateLead();
        controller.copyReferralInfo();
    }

    public static testMethod void relationshipSelf3() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        Contact con = WishReferralFormSpanish_AC_Test.createContact();
        List<SelectOption> statesList = controller.getStates();

        Lead dupeLead = new Lead();
        dupeLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        dupeLead.PD_ICD_Code__c = icdCode.Id;
        dupeLead.PD_Condition_Description__c = conditionDescription.name;
        dupeLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
        dupeLead.Diagnosis_Given_By_Referrer__c = conditionDescription.name;
        dupeLead.Hospital_Treatment_Facility__c = randomCharacterString(10)+ ' ' + randomCharacterString(8);
        dupeLead.Hospital_Treatment_Facility_Treating__c = dupeLead.Hospital_Treatment_Facility__c;
        dupeLead.Treating_Medical_Professional_Last_Name__c = randomCharacterString(9);
        dupeLead.Gender__c = Constant_AC.CONTACT_GENDER_MALE;
        dupeLead.Company = randomCharacterString(7) + ', Inc.';
        
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        fillReferralContacts(controller.currLead);
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        
        controller.currLead.Child_Age__c = '16';
        controller.currLead.DOB__c = dupeLead.DOB__c = Date.valueOf(Date.Today().addYears(-16));
        controller.currLead.State = statesList[Math.mod(Math.abs(Crypto.getRandomInteger()),statesList.size()-1)].getValue();
        dupeLead.firstName = controller.currLead.firstName;
        dupeLead.lastName = controller.currLead.lastName;
        dupeLead.Street = controller.currLead.Street;
        dupeLead.City = controller.currLead.City;
        dupeLead.State = controller.currLead.State;
        dupeLead.PostalCode = controller.currLead.PostalCode;
        dupeLead.Email = controller.currLead.Email;
        dupeLead.Phone = controller.currLead.Phone;
        controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';
        controller.diagnosisFilter = icdCode.Name;
        controller.selectedDiagnosis = conditionDescription.Name;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = randomCharacterString(12);
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.PD_Condition_Description__c = conditionDescription.name;
        Lead dupeLead2 = dupeLead.clone();
        dupeLead2.Status = Constant_AC.LEAD_sTATUS_INQUIRY;
        Lead dupeLead3 = dupeLead.clone();
        dupeLead3.Status = 'Other';

        insert new List<Lead>{
                dupeLead, dupeLead2, dupeLead3
        }; 
        controller.CreateLead();
        controller.copyReferralInfo();
    }

    public static testMethod void relationshipOther() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_OTHER;
        controller.CreateLead();
    }

    public static testMethod void relationshipMedicalProfessional() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        controller.currLead.Medical_Provider_Category__c = Constant_AC.LEAD_MEDICAL_PROVIDER_NURSE_PRACTITIONER;
        prepdata();
        controller.CreateLead();
    }

    public static testMethod void medicalFirstNameblank() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        controller.currLead.LastName = RandomCharacterString(8);
        controller.diagnosisYear = String.ValueOf(Date.Today().addYears(-2));
        controller.diagnosisMonth = String.ValueOf(Date.Today().Month());
        controller.CreateLead();
    }

    public static testMethod void relationshipFamily() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
        controller.currLead.LastName = randomCharacterString(4);
        controller.currLead.DOB__c = Date.Today().addYears(-16);
        controller.currlead.Child_Age__c = '16';
        controller.CreateLead();
    }

    public static testMethod void relationshipSibling() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
        controller.currLead.LastName = randomCharacterString(10);
        controller.currLead.DOB__c = Date.Today().addDays(-1050);
        controller.currlead.Of_Siblings__c = '2';
        controller.getSiblingList();
        controller.CreateLead();
        controller.getStates();
        controller.copyReferrerInfo = True;
        controller.copyReferralInfo();     
        controller.getNoOfSiblings();
        prepdata();        
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        controller.disPlayChildForm();
    }

    public static testMethod void relationshipSibling2() {
        PageReference pageRef = Page.WishReferralForm_Spanish_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralFormSpanish_AC controller = new WishReferralFormSpanish_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = Label.Wish_Form_Yes;
        controller.currLead.Any_medical_reason_for_moving_quickly__c = Label.Wish_Form_Yes;
        controller.currLead.Relationship_To_Child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_SELF;
        controller.currLead.LastName = randomCharacterString(10);
        controller.currLead.DOB__c = Date.Today().addDays(-1050);
        controller.currlead.Of_Siblings__c = '2';
        controller.getSiblingList();
        controller.CreateLead();
        controller.getStates();
        controller.copyReferrerInfo = True;
        controller.copyReferralInfo();       
        controller.getNoOfSiblings();        
        controller.currLead.is_Family_Aware_of_Referral__c = Label.Wish_Form_Yes;
        controller.disPlayChildForm();
    }

    public static testmethod void callmethods() {
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

    static contact createContact() {
        Contact currCon = new Contact();
        currcon.FirstName = randomCharacterString(7);
        currcon.lastName = randomCharacterString(11);
        currCon.Birthdate = Date.Today().addYears(-17);
        currCon.Phone = randomIntegerString(10);
        currCon.Email = randomEmailAddress();
        currCon.Diagnosis__c = conditionDescription.Name;
        insert currCon;
        return currCon;
    }

    private static void fillReferralContacts(Lead leadToFill)  {
        leadToFill.Referrer_FirstName__c = randomCharacterString(5);
        leadToFill.Referrer_Last_Name__c = randomCharacterString(5);
        leadToFill.Referrer_Phone__c = randomIntegerString(10);
        leadToFill.Referrer_Email__c = randomEmailAddress();
        leadToFill.Referrer_City__c = randomCharacterString(8);
        leadToFill.Referrer_Zip__c = zipCode.Name;
        leadToFill.Medical_Provider_Category__c = Constant_AC.LEAD_MEDICAL_PROVIDER_PHYSICIAN;
        
        leadToFill.FirstName = randomCharacterString(5);
        leadToFill.Child_Middle_Initial__c = randomCharacterString(1);
        leadToFill.lastName = randomCharacterString(7);
        leadToFill.Gender__c = Constant_AC.CONTACT_GENDER_MALE;
        
        leadToFill.Parent_First_Name__c = randomCharacterString(8);
        leadToFill.Parent_Last_Name__c = randomCharacterString(8);
        leadToFill.Street = randomIntegerString(3) + ' ' + randomCharacterString(7);
        leadToFill.State = randomCharacterString(20);
        leadToFill.City = randomCharacterString(8);
        leadToFill.PostalCode = zipCode.Name;
        leadToFill.Email = randomEmailAddress();
        leadToFill.Phone = randomIntegerString(10);
        leadToFill.Treating_Medical_Professional_First_Name__c = randomCharacterString(8);
        leadToFill.Treating_Medical_Professional_Last_Name__c = randomCharacterString(7);
        leadToFill.Treating_Medical_Professional_Phone__c = randomIntegerString(10);
        leadToFill.Treating_Medical_Professional_Email__c = randomEmailAddress();
    }

    private static String randomCharacterString(Integer numCharacters)  {
        String characters = 'abcdefghijklmnopqrstuvwxyz';
        String returnString = '';
        for (Integer i=0; i<numCharacters; i++) {
            returnString += Math.mod(Math.abs(Crypto.getRandomInteger()), characters.length()-1);
        }
        return returnString;
    }

    private static String randomIntegerString(Integer numDigits)   {
        String digits = '0123456789';   
        String returnString = '';
        for (Integer i=0; i<numDigits; i++) {
            returnString += Math.mod(Math.abs(Crypto.getRandomInteger()), digits.length()-1);
        }
        return returnString;
    }

    private static String randomEmailAddress()  {
        return randomCharacterString(5) + '@' + randomCharacterString(5) + '.' + randomCharacterString(3);
    }
}