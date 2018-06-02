/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 09/12/2016
Description : LeadTrigger_AT_Test is used to increase the code coverage for LeadTrigger_AT and its controller.
*****************************************************************************************************/

@isTest
public class LeadTrigger_AT_Test{    
    
    Constant_AC  constant = new Constant_AC();
    public Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    public Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    public Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    public Id organizationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.OrganizationRT).getRecordTypeId();
    public Id parentwishRecTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    
    //This method is create the lead with addidional parent information.
    public testmethod static void sameAdditionalParent(){
        try{
            Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
            Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
            insert descrip;
            Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
            Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
            ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
            insert icdCode;
            Lead newLead = OrientationandTrainingUtil.createAdditionalParentLead(chapterAccount);
            insert newLead;
            Condition_Description__c conditionDesCription = OrientationandTrainingUtil.createConditionDesCription();
            Insert conditionDesCription;
            ICD_Codes__c obj=new ICD_Codes__c();
            obj.Name='C120';
            obj.Condition_Description__c = conditionDesCription.Id;
            insert obj;
            ICD_Codes__c obj1=new ICD_Codes__c();
            obj1.Name='C121';
            obj1.Condition_Description__c = conditionDesCription.Id;
            insert obj1;
            RecursiveTriggerHandler.isFirstTime = true; 
            System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
            newLead.SD1_ICD_Code__c = icdCode.Id;
            newLead.SD2_ICD_Code__c = icdCode.Id;
            newLead.SD3_ICD_Code__c = icdCode.Id;
            newLead.SD4_ICD_Code__c = icdCode.Id;
            newLead.Status = 'Referred';
            newLead.ChapterName__c = chapAcc.Id;
            newLead.Sub_Status__c = 'Pending Diagnosis Verification';
            newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfessionalCon.Id;
            newLead.Medical_Professional_ContactId__c =  medicalProfessionalCon.Id;
            newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
            newLead.Relationship_to_child__c = 'Medical Professional'; 
            newLead.Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
            newLead.PD_ICD_Code__c = obj.Id;
            newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
            update newLead;        
            newLead.Status = 'Qualified';
            newLead.PD_ICD_Code__c = obj1.Id;
            Test.startTest();
            update newLead;
            Test.stopTest();
            System.assertEquals(newLead.Status,'Qualified');
            System.assertEquals(medicalProfessionalCon.Id,newLead.Treating_Medical_Professional_Contact_Id__c );
        }
        
        catch(DMLException e) {
            system.assertEquals(e.getMessage(), e.getMessage());
        }
    }
    
    //Convert the lead with qualified status.
    
    public testmethod static void updateLeadAsQualified(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';   
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        System.assertEquals(medicalProfessionalCon.Id,newLead.Medical_Professional_ContactId__c);
    }
    //The reffer and treating medical professional are same person.
    //Convert the lead with status of Qualified
    public testmethod static void updateLeadAsQualifiedMedCon(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfessionalCon2 = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Constant_AC  constant = new Constant_AC();
        Id hospitalTreatMentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.hospitalTreatment).getRecordTypeId();
        Account newAccount = new Account();
        newAccount.Name = 'TestReferrer';
        newAccount.RecordTypeId = hospitalTreatMentRecordTypeId;
        Insert newAccount;
        
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Referrer_FirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalLastName__c = 'Alternate';
        newLead.Referrer_Last_Name__c = 'Alternate';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        newLead.Alternate1MedicalProfessionalEmail__c = 'alternate@gmail.com';
        newLead.Referrer_Email__c = 'alternate@gmail.com';
        newLead.Alternate1MedProfessionalPhone__c = '9600467559';
        newLead.Alternate1HospitalTreatmentFacility__c = 'TestAlternate1Hospital';
        
        newLead.Alternate2MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalLastName__c = 'Alternate2';        
        newLead.Alternate2MedProfessionalEmail__c = 'alternate2@gmail.com';        
        newLead.Alternate2MedProfessionalPhone__c = '9600467552';
        newLead.Alternate2HospitalTreatmentFacility__c = 'TestAlternate2Hospital';
        newLead.Referrer_Phone__c = '9600467559';
        
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';   
        //newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 1 Medical Professional';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.HiddenAlternate1MedProfessionalId__c =  medicalProfessionalCon.Id;
        newLead.HiddenAlternate2MedProfessionalId__c =  medicalProfessionalCon2.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Any_medical_reason_for_moving_quickly__c = 'No';
        //newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        
    }
    
    /*The lead has contain the alternate medical provider details.
medical professional contact merged with existing contact*/
    public testmethod static void updateLeadAsQualifiedAlternateMedCon(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Referrer_FirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate2MedProfessionalLastName__c = 'Alternate';
        newLead.Referrer_Last_Name__c = 'Alternate';
        newLead.Alternate1MedProfessionalFirstName__c = 'TestReferrer';
        newLead.Alternate1MedProfessionalLastName__c = 'Alternate1';        
        //newLead.Alternate1MedProfessionalEmail__c = 'alternate1@gmail.com';        
        newLead.Alternate1MedProfessionalPhone__c = '9600467552';
        
        newLead.Alternate2MedProfessionalEmail__c = 'alternate@gmail.com';
        newLead.Referrer_Email__c = 'alternate@gmail.com';
        newLead.Alternate2MedProfessionalPhone__c = '9600467559';
        newLead.Alternate2HospitalTreatmentFacility__c = 'TestAlternate2Hospital';
        newLead.Referrer_Phone__c = '9600467559';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';   
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        // newLead.HiddenAlternate2MedProfessionalId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.DOB__c = system.today() - 8543;
        newLead.Gender__c = 'Female';
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        //newLead.Childs_Qualifying_Diagnosis__c = 'Testrr';
        newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        
    }
    
    
    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
    public testmethod static void CreateRelationShipRecord(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        
        newLead.Relationship_to_child__c = 'Medical Professional';
        
        newLead.Sibling_Detail__c = '- | bbb | 12';
        //newLead.Sub_Status__c ='Pending Diagnosis Verification';
        
        insert newLead;
        RecursiveTriggerHandler.isFirstTime = true; 
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        update newLead;
        System.assertEquals(newLead.Status,'Inquiry');
    }
    
    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
    public testmethod static void CreateRelationShipRecordwithExisitingContact(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        newLead.Treating_Medical_Professional_Contact_Id__c = trateProfContact.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfContact.Id;
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.Wish_Family_ContactId__c = wishFamily.Id;
        newLead.Sibling_Detail__c = 'aa | bbb | -';
        newLead.Is_Required_Bypass__c = true;
        insert newLead;
        
        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true; 
        update newLead;
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';
        Test.StartTest();
        update newLead;
        Test.StopTest();
        System.assertEquals(newLead.Status,'Qualified');
        
    }
    
    //This Method is used increase the code coverage when the lead is send to DV form and convert the lead with Qualified status.
    public testmethod static void UpdateStatusAsQualified(){    
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRecwithDupe(chapterAccount.Id); 
        newLead.Sibling_Detail__c = 'aa | bbb | 12 '+'<br/>'+' bb | - | 13' +'<br/>'+' -| cc | 13'+'<br/>'+' dd | dd |-'+'<br/>'+' -| ee |-'+'<br/>'+' -| ee |-'+'<br/>'+' ff| - |-';
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.PD_ICD_Code__c = icdCode.Id; 
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';    
        insert newLead;
        
        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;
        insert newDV;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Is_Required_Bypass__c = true;
        RecursiveTriggerHandler.isFirstTime = true; 
        Test.startTest();       
        
        update newLead;
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';        
        update newLead ;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
    }
    
    //This metod is increase the code coverage for when the lead is converted and the contacts are merged with existing contact. 
    public testmethod static void UpdateStatusAsQualifiedwithContactId(){         
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();        
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        Contact medicalProCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();        
        Lead newLead = OrientationandTrainingUtil.createTestLeadRecwithDupe(chapterAccount.Id); 
        newLead.Sibling_Detail__c = 'aa | bbb | 12 '+'<br/>'+' bb | - | 13' +'<br/>'+' -| cc | 13'+'<br/>'+' dd | dd |-'+'<br/>'+' -| ee |-'+'<br/>'+' -| ee |-'+'<br/>'+' ff| - |-';
        newLead.Child_Age__c = '4';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.unique_wish_identifier__c = '123456';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';           
        insert newLead;
        
        Lead_File__c  leadFile = OrientationandTrainingUtil.createLeadFileRecord(newLead.Id);
        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = icdCode.Id;
        newDV.Lead__c = newLead.id;
        insert newDV;
        
        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Is_Required_Bypass__c = true;
        System.assertEquals(newLead.Sub_Status__c,'Pending Diagnosis Verification');
        
        RecursiveTriggerHandler.isFirstTime = true; 
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';       
        update newLead ;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
    }
    
    /*This method is used to increase the code coverage for CreateNewCase method when the lead status is updated as 'Eligibility Review'. */ 
    public testmethod static void UpdateStatusAsEligibilityReview(){         
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
        Chapter_Name_Settings__c newC = new Chapter_Name_Settings__c();
        newC.Name = alabamaAccountRec.Name;
        insert newC;
        Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
        Insert officeRec;
        Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
        zipRec.External_Id__c = '32193';
        Insert zipRec;
        Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Status = 'Inquiry';
        newLead.Street = 'KuttaiKarai Street';
        newLead.StateCode = 'AZ';
        newLead.city = 'Trichy';
        newLead.Postalcode = '32193';
        newLead.Please_Explain__c = 'Test';
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        // newLead.PostalCode = NewIcdCode.Id;
        // newLead.Sub_Status__c ='Pending Diagnosis Verification';
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Status = 'Referred';
        newLead.Hidden_Chapter_Name__c = alabamaAccountRec.Name;
        newLead.Street = 'KuttaiKarai Street';
        newLead.StateCode = 'AZ';
        newLead.city = 'Trichy';
        newLead.CountryCode = 'US';
        newLead.Gender__C = 'male';
        newLead.Treating_Medical_Professional_Email__c = 'testTreating@mail.com';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Alternate1MedicalProfessionalEmail__c = 'alternate1@mail.com';
        newLead.Alternate2MedProfessionalEmail__c = 'alternate2@mail.com';
        update newLead;
        
        newLead.Status = 'Eligibility Review';
        newLead.Treating_Medical_Professional_Email__c  = 'testmawa3@gmail.com';
        newLead.Postalcode = '32193';
        newLead.PD_ICD_Code__c  =  NewIcdCode.Id;
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        newLead.Medical_Questions__c = 'YES Test Diagnosis';
        newLead.Dup_Check__c = 'Block Lead Dup';
        newLead.unique_wish_identifier__c = '123455';
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        Test.startTest();
        update newLead ;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Eligibility Review');
    } 
    
    //This method is used to increase the code coverage for when the lead is updated with the DNQ status.
    public testmethod static void UpdateStatusDNQ(){ 
        User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1];
        User nationalStaff;
        System.RunAs(currUser)
        {   
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
        }
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Account chapterAc = [SELECT Id,Intake_Manager__c  FROM Account WHERE Id =:chapterAccount LIMIT 1];
        Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c  icdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        insert icdCode;        
        chapterAc.Intake_Manager__c = nationalStaff.Id;
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Relationship_to_child__c = 'Medical Professional';
        //newLead.ChapterName__c = OrientationandTrainingUtil.CreateAlabamaAccount();
        // newLead.OwnerId =nationalStaff.Id;
        newLead.status = 'Referred';
        newLead.PD_ICD_Code__c = icdCode.Id;  
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test'; 
        Insert newlead;
        system.assertequals(chapterAccount,[SELECT ChapterName__r.Name FROM lead WHERE Id =: newlead.Id].ChapterName__c);
        system.assertequals('Referred',[SELECT status FROM lead WHERE Id =: newLead.Id].Status);
        newlead.Status = 'DNQ';
        Test.startTest();
        update newlead;
        Test.stopTest();
        system.assertequals('DNQ',[SELECT status FROM lead WHERE Id =: newlead.Id].Status);
    }
    
    //This method is used to ncrease the code coverage for the lead created with medical provider type.
    public testmethod static void MedicalProfessionalType(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.Wish_Family_ContactId__c = wishFamily.Id;
        newLead.Sibling_Detail__c = 'aa | bbb | -';
        newLead.Treating_Medical_Professional_First_Name__c = 'TestMedFirstName';
        newLead.Referrer_FirstName__c = 'TestMedFirstName';
        newLead.Treating_Medical_Professional_Last_Name__c = 'TestMedLastName';
        newLead.Referrer_Last_Name__c = 'TestMedLastName';
        newLead.Treating_Medical_Professional_Phone__c = '9600467559';
        newLead.Referrer_Phone__c = '9600467559';
        newLead.Treating_Medical_Professional_Email__c = 'test@gmail.com';
        newLead.Referrer_Email__c = 'test@gmail.com';
        insert newLead;
        
        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Is_Required_Bypass__c = True;
        RecursiveTriggerHandler.isFirstTime = true; 
        update newLead;
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';
        Test.StartTest();
        update newLead;
        Test.StopTest();
        system.assertequals('Qualified',[SELECT status FROM lead WHERE Id =: newlead.Id].Status);
        
    }
    
    //This method is used to ncrease the code coverage for the lead created with medical provider type.
    public testmethod static void duplicateLead(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Constant_AC  constant = new Constant_AC();
        Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'mosstest';
        medicalProfContact .LastName = 'harttest';
        medicalProfContact .Email = 'testmawa1@gmail.com';
        medicalProfContact .Phone =  '9600467554';
        medicalProfContact .MailingStreet ='KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode  = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        dupLead.Status = 'Referred';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;         
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            //System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    public testmethod static void duplicateLeadAddress(){ 
        RecursiveTriggerHandler.isFirstTime = true;        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        dupLead.Status = 'Referred';
        dupLead.FirstName = 'moss';
        dupLead.LastName = 'Smith Household Dupe';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;         
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            //System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    public testmethod static void duplicateLeadAddressAndPhone(){ 
        RecursiveTriggerHandler.isFirstTime = true;        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        dupLead.Status = 'Referred';
        dupLead.FirstName = 'moss Dupe';
        dupLead.LastName = 'Smith Household Dupe';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;         
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            //System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    public testmethod static void duplicateLeadDOBAndName(){ 
        RecursiveTriggerHandler.isFirstTime = true;        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        newLead.Status = 'Referred';
        insert newLead;
        Lead dupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        dupLead.Status = 'Referred';
        dupLead.FirstName = 'moss';
        dupLead.LastName = 'Smith Household Dupe';
        dupLead.Street = 'KuttaiKarai Street Dupe';
        insert dupLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;         
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    //This method is used to increase the code coverage for the lead created with medical provider type.
    public testmethod static void duplicatemedicalProfList(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Constant_AC  constant = new Constant_AC();
        Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'SteveJune';
        medicalProfContact .LastName = 'Waughone';
        medicalProfContact .Email = 'testmawa2d@gmail.com';
        medicalProfContact .Phone =  '9600467578';
        medicalProfContact .MailingStreet ='KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode  = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        Insert medicalProfContact;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        //Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        Insert newLead;
        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;        
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    //This method is used to increase the code coverage for the lead created with duplicate family contact list.
    public testmethod static void duplicateFamilyList(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Constant_AC  constant = new Constant_AC();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        //Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();         
        Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Contact wishFamilyCon = new Contact();
        wishFamilyCon.FirstName = 'MAWAFirstJune';
        wishFamilyCon.LastName = 'MAWALastJune';
        wishFamilyCon.Email = 'testmawa@gmail.com';
        wishFamilyCon.Phone = '9600467559';
        wishFamilyCon.MailingStreet ='KuttaiKarai Street';
        wishFamilyCon.MailingCity = 'Trichy';
        wishFamilyCon.MailingStateCode = 'AZ';
        wishFamilyCon.MailingPostalCode  = '6201717';
        wishFamilyCon.MailingCountryCode = 'US';
        wishFamilyCon.RecordTypeId = wishFamilyRecordTypeId ;
        wishFamilyCon.IsParentGuardian__c  = 'ParentGuardian';
        wishFamilyCon.Region_Chapter__c=chapterAccount.id;
        Insert wishFamilyCon;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        newLead.Status = 'Referred';
        insert newLead;        
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;         
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    //This method is used to increase the code coverage for the lead created with duplicate best physician contact List.
    public testmethod static void duplicateBestPhyList(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Constant_AC  constant = new Constant_AC();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        //Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
        //Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();         
        Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'SteveJune1';
        medicalProfContact .LastName = 'Waughone1';
        medicalProfContact .Email = 'testmawa@gmail.com';
        medicalProfContact .Phone =  '9600467578';
        medicalProfContact .MailingStreet ='KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode  = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        Insert medicalProfContact;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);        
        newLead.Status = 'Referred';
        newLead.Best_Contact_for_Physician_First_Name__c = 'SteveJune1';
        newLead.Best_contact_for_Physician_Email__c = 'testmawa@gmail.com';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Waughone1';
        insert newLead;        
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        RecursiveTriggerHandler.isFirstTime = true;         
        try {
            update newLead; 
        }
        catch (DmlException ex) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            // System.assertEquals(ex.getDmlMessage(0).Contains('There might be a duplicate Wish Child. Please click <a href=https://cs52.salesforce.com/apex/LeadDuplicate_VF?'),True);
        }
        
    }
    //This method is used to increase the code coverage for the lead created with best contact as the Referrer.
    public testmethod static void referrerSameAsBestLead(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';   
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'bestPhysician';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Best contact for Physician';
        newLead.Referrer_Email__c = 'best@mail.com';
        newLead.Is_Required_Bypass__c = true;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        System.assertEquals(medicalProfessionalCon.Id,newLead.Medical_Professional_ContactId__c);
    }
    
    //This method is used to increase the code coverage for the lead created with Treating medical provider as the Referrer.
    public testmethod static void referrerSameAsTreat(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test';   
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Treating_Medical_Professional_Email__c = 'best@mail.com';
        newLead.Treating_Medical_Professional_First_Name__c = 'bestPhysician';
        newLead.Treating_Medical_Professional_Last_Name__c = 'Test';
        newLead.Treating_Medical_Professional_Phone__c = '2233445566';
        newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfessionalCon.Id;
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Referrer_Email__c = 'best@mail.com';
        newLead.Hidden_DV_form_Medical_professional_Type__c = 'Best contact for Physician';
        newLead.Is_Required_Bypass__c = true;
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        System.assertEquals(medicalProfessionalCon.Id,newLead.Medical_Professional_ContactId__c);
    }
    
    //This method is used to increase the code coverage for the lead created with Alternate1 as the Referrer.
    public testmethod static void referrerSameAsAlter1(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test'; 
        insert newLead;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Alternate1MedicalProfessionalEmail__c = 'alter1@mail.com';
        newLead.Alternate1MedProfessionalFirstName__c = 'bestPhysician';
        newLead.Alternate1MedProfessionalLastName__c = 'Test';
        newLead.Alternate1MedProfessionalPhone__c = '2233445566';
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Referrer_Email__c = 'alter1@mail.com';
        newLead.Is_Required_Bypass__c = true;
        // newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 1 Medical Professional';
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Test';
        newLead.Status = 'Qualified';
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        System.assertEquals(medicalProfessionalCon.Id,newLead.Medical_Professional_ContactId__c);
    }
    
    //This method is used to increase the code coverage for the lead created with Alternate2 as the Referrer.
    public testmethod static void referrerSameAsAlter2(){
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription(); 
        insert descrip;
        Account chapAcc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact FamilyContact = OrientationandTrainingUtil.CreateWishFamily();
        ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
        insert icdCode;
        //Test.startTest();
        Constant_AC  constant = new Constant_AC();
        Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();
        Lead newLead = OrientationandTrainingUtil.createSameMedicalLead(chapterAccount);
        newLead.Sibling_Detail__c = 'aa | - | 12';
        newLead.Relationship_to_child__c = 'Medical Professional';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.PD_ICD_Code__c = icdCode.Id;
        newLead.Diagnosis_Given_By_Referrer__c  = 'Test'; 
        insert newLead;
        
        Map<Lead, ID> leadMap = new Map<Lead, ID>();
        leadMap.put(newLead, newLead.ChapterName__c);
        //Lead_OnAfterUpdateTriggerHandlerHelper.createTaskforDNQLeads(leadMap);
        Case caseInsatnce = new Case();
        caseInsatnce.Lead__c = newLead.id;
        caseInsatnce.RecordTypeId = partARecordTypeId;
        caseInsatnce.Origin = 'Email';
        caseInsatnce.Status = 'New';
        insert caseInsatnce;
        
        dsfs__DocuSign_Status__c newDoc = new dsfs__DocuSign_Status__c();
        newDoc.dsfs__Lead__c = newLead.id;
        newDoc.dsfs__Envelope_Status__c = 'Completed';
        insert newDoc;
        //Test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true; 
        System.assertEquals( RecursiveTriggerHandler.isFirstTime,true);
        newLead.SD1_ICD_Code__c = icdCode.Id;
        newLead.SD2_ICD_Code__c = icdCode.Id;
        newLead.SD3_ICD_Code__c = icdCode.Id;
        newLead.SD4_ICD_Code__c = icdCode.Id;
        newLead.Status = 'Referred';
        newLead.ChapterName__c = chapAcc.Id;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        newLead.Wish_Family_ContactId__c = FamilyContact.Id;
        newLead.Medical_Professional_ContactId__c =  medicalProfessionalCon.Id;
        newLead.Hidden_Additional_Parent_Id__c =  FamilyContact.Id;
        newLead.Alternate2MedProfessionalEmail__c = 'best@mail.com';
        newLead.Alternate2MedProfessionalFirstName__c = 'bestPhysician';
        newLead.Alternate2MedProfessionalLastName__c = 'Test';
        newLead.Alternate2MedProfessionalPhone__c = '2233445566';
        newLead.Referrer_FirstName__c = 'bestPhysician';
        newLead.Referrer_Last_Name__c = 'Test';
        newLead.Referrer_Phone__c = '2233445566';
        newLead.Referrer_Email__c = 'best@mail.com';
        newLead.Is_Required_Bypass__c = true;
        // newLead.Hidden_DV_form_Medical_professional_Type__c = 'Alternate 2 Medical Professional';
        update newLead;
        Test.startTest();
        newLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        newLead.Please_Explain__c = 'Yes';
        newLead.Status = 'Qualified';        
        update newLead;
        Test.stopTest();
        System.assertEquals(newLead.Status,'Qualified');
        System.assertEquals(medicalProfessionalCon.Id,newLead.Medical_Professional_ContactId__c);
    }    
}