/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : DocusignStatusTrigger_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@IsTest
public class DocusignStatusTrigger_AT_Test {
    @TestSetup static void methodName() {
        Account makeAWish = OrientationandTrainingUtil.CreateAmericaAccount();
        insert makeAWish;
    }

    /*This method is used to update the isConflict status as true when the envelop status is completed.*/
    @IsTest
    public static void updateisConfilicttoTrue() {
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        insert chapterAccount;

        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert VolunteerContact;

        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatuswithCon(VolunteerContact.Id);
        insert dsfs;

        Conflict_Of_Interest__c coi = new Conflict_Of_Interest__c();
        coi.current__c = true;
        coi.Volunteer_Contact__c = VolunteerContact.Id;
        insert coi;

        Conflict_Of_Interest__c conOfInt = new Conflict_Of_Interest__c();
        conOfInt.current__c = true;
        conOfInt.Volunteer_Contact__c = VolunteerContact.Id;
        insert conOfInt;

        dsfs__DocuSign_Status__c dbdsfs = new dsfs__DocuSign_Status__c ();
        dbdsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        dbdsfs.Id = dsfs.Id;
        dbdsfs.Docusign_Hidden_Contact__c = VolunteerContact.Id;
        dbdsfs.isConflict__c = true;
        update dbdsfs;
    }

    /*This method is used to update the isConfilict status as false when the envelop status is completed.*/
    @IsTest
    public static void updateisConfilicttoFalse() {
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        chapterAccount.Volunteer_Manager__c = UserInfo.getUserId();
        insert chapterAccount;

        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert VolunteerContact;

        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatuswithCon(VolunteerContact.Id);
        dsfs.dsfs__Contact__c = VolunteerContact.Id;
        dsfs.Docusign_Hidden_Contact__c = volunteerContact.Id;
        dsfs.dsfs__Subject__c = Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM;
        upsert dsfs;

        dsfs__DocuSign_Status__c dbdsfs = new dsfs__DocuSign_Status__c ();
        dbdsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        dbdsfs.Id = dsfs.Id;
        //dbdsfs.Docusign_Hidden_Contact__c  = volunteerContact.Id;
        dbdsfs.isConflict__c = false;
        update dbdsfs;

        Conflict_Of_Interest__c coi = new Conflict_Of_Interest__c();
        coi.current__c = true;
        coi.Volunteer_Contact__c = VolunteerContact.Id;
        insert coi;
    }

    /*This method is used to convert the lead when the docusign status is completed.*/
    @IsTest
    public static void convertlead() {
        //Below two lines are related to Part B
        //Constant_AC  constant = new Constant_AC();
        //Id diManualProcessRT = Schema.SObjectType.Diagnosis_Verification__c.getRecordTypeInfosByName().get(constant.diAutomatedProcess).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;

        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.unique_wish_identifier__c = '123456';
        insert newLead;

        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id);
        insert dsfs;
        //Condition_Description__c newCD = new Condition_Description__c(Name = 'Malignant');
        //Insert newCD;
        //ICD_Codes__c newICDCode = new ICD_Codes__c(Name = 'C00', Condition_Description__c = newCD.Id);
        //insert newICDCode;
        Lead updateLead = new Lead();
        updateLead.Status = 'Referred';
        updateLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        updateLead.RFI_Form_Info_Hidden__c = 'Qualified';
        updateLead.Sub_Status__c = 'Pending Diagnosis Verification';
        updateLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse Practitioner';
        updateLead.Please_Explain__c = 'Test';
        updateLead.Id = newLead.Id;
        Test.startTest();
        update updateLead;
        //Diagnosis_Verification__c newDiagnosisInformation = new Diagnosis_Verification__c(Lead__c = updateLead.Id ,ICD_Code__c = newICDCode.Id, Active__c = TRUE, RecordTypeId = diManualProcessRT, Type__c = 'Qualifying Diagnosis');
        //insert newDiagnosisInformation;
        dsfs__DocuSign_Status__c dbdsfs = new dsfs__DocuSign_Status__c ();
        dbdsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        dbdsfs.Id = dsfs.Id;
        dsfs.dsfs__Subject__c = Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM;
        dbdsfs.dsfs__Lead__c = newLead.Id;
        update dbdsfs;
        Test.stopTest();

    }

    @IsTest
    public static void convertleadStatusNotQualified() {
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;

        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.unique_wish_identifier__c = '123456';
        insert newLead;

        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id);
        insert dsfs;

        Lead updateLead = new Lead();
        updateLead.Status = 'Referred';
        updateLead.I_am_Recognized_To_Practice_As_a__c = 'Social Worker';
        updateLead.Is_in_a_Comatose_Vegetative_State__c = 'Yes';
        updateLead.Any_medical_reason_for_moving_quickly__c = 'No';
        updateLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        updateLead.Why_do_you_feel_would_be_eligible_Wish__c = 'Test';
        updateLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'Yes';
        updateLead.RFI_Form_Info_Hidden__c = 'Not Qualified';
        updateLead.Sub_Status__c = 'Pending Diagnosis Verification';
        updateLead.Part_A_Received__c = Date.Today();
        Test.startTest();
        updateLead.Id = newLead.Id;
        update updateLead;
        Test.stopTest();

        dsfs__DocuSign_Status__c dbdsfs = new dsfs__DocuSign_Status__c ();
        dbdsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        dbdsfs.Id = dsfs.Id;
        dbdsfs.dsfs__Lead__c = newLead.Id;
        //update dbdsfs;
    }

    @IsTest
    public static void updateDocusignStatus() {
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        insert chapterAccount;

        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChild();
        insert wishChildContact;

        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.CreateDocusignRecord();
        insert dsfs;

        Attachment attch = OrientationandTrainingUtil.CreateAttachmentRecordWishChild(dsfs.Id);
        dsfs.dsfs__Subject__c = Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM;
        dsfs.dsfs__Contact__c = wishChildContact.Id;
        update dsfs;
    }

    @IsTest
    public static void sendChildMedicalSummary() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        String subject = 'Signature Required – Make-A-Wish Rush Child' + '\'s' + ' ' + 'Medical Summary Form: ' + wishChild.FirstName;
        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.CreateDocusignRecord();
        dsfs.dsfs__Subject__c = subject;
        dsfs.dsfs__Case__c = parentCase.Id;
        insert dsfs;
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        update dsfs;
    }

    @IsTest
    public static void sendAbsentparentform() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        String subject = 'Signature Required – Make-A-Wish Wish Clearance Form';
        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatuswithCase(parentCase.Id);
        insert dsfs;
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        update dsfs;
    }

    @IsTest
    public static void sendWishClearance() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        String subject = 'Signature Required – Make-A-Wish Wish Clearance Form';
        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatuswithCase(parentCase.Id);
        dsfs.dsfs__Subject__c = subject;
        insert dsfs;
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        update dsfs;
    }
}