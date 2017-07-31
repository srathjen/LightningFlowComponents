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
    
    /*This method is used to increase the code coverage for onAfterUpdate method when the lead status is updated as 'Qualified'. */ 
    
    public testmethod static void UpdateStatusAsQualified(){ 
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Sibling_Detail__c = 'aa | bbb | 12 '+'<br/>'+' bb | - | 13' +'<br/>'+' -| cc | 13'+'<br/>'+' dd | dd |-'+'<br/>'+' -| ee |-'+'<br/>'+' -| ee |-'+'<br/>'+' ff| - |-';
        newLead.Child_Age__c = '4';
        //  newLead.Sub_Status__c ='Pending Diagnosis Verification';
        newLead.unique_wish_identifier__c = '123456';
        
        insert newLead;
        
        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = 'c00';
        newDV.Lead__c = newLead.id;
        insert newDV;
        
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        update newLead;
        newLead.Status = 'Qualified';
        
        update newLead ;
        
        
    }
    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
    public testmethod static void CreateNewSameContactRecord(){ 
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Sibling_Detail__c = 'aa | bbb | 12 ';
        newLead.Medical_Professional_First_Name__c = 'Steve';
        newLead.Medical_Professional_Last_Name__c = 'Waugh';
        newLead.Medical_Professional_Phone__c =  '9600467557';
        newLead.Medical_Professional_Email__c = 'testmawa2@gmail.com';
        newLead.Hospital_Treatment_Facility__c =  'Steve Smith AC';
        // newLead.Sub_Status__c ='Pending Diagnosis Verification';
        
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        
        insert newLead;
        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = 'c00';
        newDV.Lead__c = newLead.id;
        insert newDV;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        update newLead;
        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id); 
        Case partAWish = OrientationandTrainingUtil.CreatePartAWish(newLead.Id);
        newLead.Status = 'Qualified';
        newLead.unique_wish_identifier__c = '1234567';
        Test.startTest();
        
        update newLead ;
        Test.stopTest();
        
        
    }
    
    /*This method is used to increase the code coverage for findDuplicateRecords method */ 
    public testmethod static void FindWishChildDupe(){ 
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        //Contact medicalProfConatc = OrientationandTrainingUtil.CreateMedicalProfContact();
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        // newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfConatc.id;
        insert newLead;
        try{
            Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
            newLead.unique_wish_identifier__c = '1234567';
            insert dupeLead;  
        }
        catch(Exception ex){
        }
    }
    
    public testmethod static void UpdateLeadLastName(){ 
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
        Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
        Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
        Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        Contact medicalProfConatc = OrientationandTrainingUtil.CreateMedicalProfContact();
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        newLead.Status = 'Eligibility Review';
        newLead.Sub_Status__c = '';
        insert newLead;
        newLead.LastName = 'Dravid';
        newLead.PD_ICD_Code__c  = '';
        newLead.PD_Condition_Description__c = '';
        newLead.Medical_Questions__c = 'Yes';
        newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfConatc.id; 
        // newLead.Status = 'Qualified';
        update newLead;
        
    }
    
    /*This method is used to increase the code coverage for CreateNewCase method when the lead status is updated as 'Eligibility Review'. */ 
    public testmethod static void UpdateStatusAsEligibilityReview(){ 
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
        Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
        Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
        Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '123456';
        // newLead.Sub_Status__c ='Pending Diagnosis Verification';
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        update newLead;
        
        newLead.Status = 'Eligibility Review';
        newLead.Treating_Medical_Professional_Email__c  = 'testmawa3@gmail.com';
        newLead.Postalcode = '32193';
        newLead.PD_ICD_Code__c  =  'C43.30';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        newLead.Medical_Questions__c = 'YES Test Diagnosis';
        newLead.Dup_Check__c = 'Block Lead Dup';
        newLead.unique_wish_identifier__c = '123455';
        update newLead ;
        
    }
    
    /*This method is used to increase the code coverage for updateStatus method when the lead status is updated as 'Part A Pending'. */ 
    public testmethod static void UpdateStatusAsPartAPending(){ 
        
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
        Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
        Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
        Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
        ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Status = 'Referred';
        newLead.unique_wish_identifier__c = '123456';
        // newLead.Sub_Status__c ='Pending Diagnosis Verification';
        insert newLead;
        newLead.Sub_Status__c ='Pending Diagnosis Verification';
        newLead.Treating_Medical_Professional_Email__c  = 'testmawa3@gmail.com';
        newLead.Postalcode = '32193';
        newLead.PD_ICD_Code__c  =  'C43.30';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        newLead.Medical_Questions__c = 'YES Test Diagnosis';
        newLead.Dup_Check__c = 'Block Lead Dup';
        newLead.unique_wish_identifier__c = '123455';
        update newLead ;
        
    }
    
    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
    public testmethod static void CreateRelationShipRecord(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        // Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        //       Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
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
        newLead.Sibling_Detail__c = 'aa | bbb | 12';
        //newLead.Sub_Status__c ='Pending Diagnosis Verification';
        Test.startTest();
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        update newLead;
        
        dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id); 
        Case partAWish = OrientationandTrainingUtil.CreatePartAWish(newLead.Id);
        
        newLead.Status = 'Qualified';
        Test.stopTest();
        update newLead ;
        
        
    }
    
    static testmethod void CheckDuplicate()
    {
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Lead newLead1 = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead1.unique_wish_identifier__c = '1234568';
        insert newLead1;
        Lead newLead2 = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead2.Status='Referred'; 
        newLead2.unique_wish_identifier__c = '123456';
        insert newLead2;
        newLead2.Sub_Status__c = 'Pending Diagnosis Verification';
        Database.SaveResult result = Database.update(newLead2, false);
        String instanceUrl = label.Instance_Url;
        String errorMessage = 'There might be a duplicate Wish Child. Please click <a href='+instanceUrl+'/apex/LeadDuplicate_VF?id='+newLead2.id+'>here </a> to review the duplicates.';
        System.assertEquals(errorMessage,result.getErrors()[0].getMessage());
    }
    
    static testmethod void createLeadforNationalStaffAsOwner(){
        User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1];
        User nationalStaff;
        System.RunAs(currUser)
        {   
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
        }
        
        System.runAs(nationalStaff) {
            Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
            // Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
            //         Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();
            Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
            Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
            Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
            Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
            Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
            newLead.Child_Age__c = '4';
            newLead.unique_wish_identifier__c = '123456';
            newLead.Treating_Medical_Professional_Contact_Id__c = trateProfContact.Id;
            newLead.Medical_Professional_ContactId__c = medicalProfContact.Id;
            newLead.Wish_Family_ContactId__c = wishFamily.Id;
            newLead.Sibling_Detail__c = 'aa | bbb | 12';
            //newLead.Sub_Status__c ='Pending Diagnosis Verification';
            insert newLead;
            
        }
        
        
    }
    
    public testmethod static void UpdateStatusAsQualifiedWithAllConValues(){ 
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        
        newLead.Referrer_FirstName__c = 'Steve';
        newLead.Referrer_Last_Name__c = 'Waugh';
        newLead.Referrer_Email__c = 'testmawa2@gmail.com';
        newLead.Referrer_Phone__c = '9600467557';
        newLead.Additional_Parent_City__c = 'Test City';
        newLead.Additional_Parent_Email__c = 'Test@mail.com';
        newLead.Additional_Parent_First_Name__c = 'Test Parent2';
        newLead.Additional_Parent_Last_Name__c = 'Last Name';
        newLead.Additional_Parent_Phone__c = '9876543210';
        newLead.Additional_Parent_Postal_Code__c = '35004';
        newLead.Additional_Parent_Relationship_to_Child__c = 'Father';
        newLead.Additional_Parent_State__c = 'Alabama';
        newLead.Additional_Parent_Street__c = 'Test Str';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Best_Contact_for_Physician_First_Name__c = 'best contact';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Last name';
        newLead.Relationship_to_child__c = 'Medical Professional';
        
        
        insert newLead;
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    
        newLead.Contact_Dup_Check__c = 'Block Contact Dup';
        newLead.Dup_Check__c = 'Block Lead Dup';
        newLead.Treating_Medical_Professional_Contact_Id__c = medicalProfessionalCon.Id;
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
        newLead.Wish_Family_ContactId__c = wishFamily.Id;
        newLead.Hidden_Additional_Parent_Id__c = wishFamily.Id;
        newLead.Hidden_Best_Contact_Person_Id__c = medicalProfessionalCon.Id;
        update newLead;
        
        newLead.Status = 'Qualified';
        update newLead ;
        String medCon = medicalProfessionalCon.Id;
        Test.stopTest();
        system.assertEquals(medCon,[SELECT Medical_Professional_ContactId__c FROM Lead WHERE Id =:newLead.Id].Medical_Professional_ContactId__c);
        
    }
    
    public testmethod static void UpdateStatusDNQ(){ 
        User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1];
        User nationalStaff;
        System.RunAs(currUser)
        {   
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
        }
        Id chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount);
        newLead.ChapterName__c = chapterAccount;
        newLead.OwnerId =nationalStaff.Id;
        newLead.status = 'Inquiry';
        Insert newlead;
        system.assertequals(chapterAccount,[SELECT ChapterName__r.Name FROM lead WHERE Id =: newlead.Id].ChapterName__c);
        system.assertequals('Referred',[SELECT status FROM lead WHERE Id =: newLead.Id].Status);
        Lead updateLeadStatus = new Lead();
        updateLeadStatus.Status= 'DNQ';
        updateLeadStatus.Id = newlead.Id;
        Update updateLeadStatus;
        system.assertequals('DNQ',[SELECT status FROM lead WHERE Id =: updateLeadStatus.Id].Status);
        
        
    }
    
    public testmethod static void UpdateStatusAsQualifiedWithAllConValueswithnull(){ 
        RecursiveTriggerHandler.isFirstTime = true;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Additional_Parent_City__c = 'Test City';
        newLead.Additional_Parent_Email__c = 'Test@mail.com';
        newLead.Additional_Parent_First_Name__c = 'Test Parent2';
        newLead.Additional_Parent_Last_Name__c = 'Last Name';
        newLead.Additional_Parent_Phone__c = '9876543210';
        newLead.Additional_Parent_Postal_Code__c = '35004';
        newLead.Additional_Parent_Relationship_to_Child__c = 'Father';
        newLead.Additional_Parent_State__c = 'Alabama';
        newLead.Additional_Parent_Street__c = 'Test Str';
        newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
        newLead.Best_Contact_for_Physician_First_Name__c = 'best contact';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Last name';
        newLead.Relationship_to_child__c = 'Medical Professional';
        
        Test.StartTest();
        insert newLead;
        newLead.Status = 'Referred';
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';    
        newLead.Contact_Dup_Check__c = 'Block Contact Dup';
        newLead.Dup_Check__c = 'Block Lead Dup';
        update newLead;
        
        newLead.Status = 'Qualified';
        update newLead ;
        Test.StopTest();
        String medCon = medicalProfessionalCon.Id;
        //system.assertEquals(medCon,[SELECT Medical_Professional_ContactId__c FROM Lead WHERE Id =:newLead.Id].Medical_Professional_ContactId__c);
        
    }
    
    public testmethod static void UpdateLeadAsQualified(){
       
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact treatingMedProf = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        Contact wishFamilyConntact = OrientationandTrainingUtil.CreateWishFamily();
         Contact bestContact = OrientationandTrainingUtil.CreateWishFamily();
        Lead newLead =  new Lead();
        newLead.FirstName = 'Test';
        newLead.LastName = 'Lead';
        newLead.Medical_Professional_ContactId__c = medicalProfessionalCon.Id;
       // newLead.Wish_Family_ContactId__c = wishFamilyConntact.id;
       // newLead.Treating_Medical_Professional_Contact_Id__c = treatingMedProf.Id;
       // newLead.Hidden_Best_Contact_Person_Id__c = bestContact.id;
        newLead.Gender__c = 'Female';
        newLead.Child_Age__c = '11';
        newLead.Status = 'Eligibility Review';
        newLead.ChapterName__c = chapterAccount.id;
        newLead.is_Family_Aware_of_Referral__c = 'yes';
        newLead.Treating_Medical_Professional_Email__c = 'Test@gmail.com';
        newLead.Treating_Medical_Professional_First_Name__c = 'Test Fname';
        newLead.Treating_Medical_Professional_Last_Name__c = 'Test Lname';
        newLead.Treating_Medical_Professional_Phone__c = '9942556677';
        newLead.Referrer_FirstName__c = 'Test Fname';
        newLead.Referrer_Last_Name__c = 'Test Lname';
        newLead.Referrer_Phone__c = '994255667788';
        newLead.Referrer_Email__c = 'test@gmail.com';
        newLead.Country = 'United States';
        newLead.Street = '4850 Lake Otis Pkwy';
        newLead.City = 'Anchorage';
        newLead.State_Picklist__c = 'Alaska';
        newLead.PostalCode = '99507-1419';
        newLead.Company = 'Test Company';
        newLead.PD_ICD_Code__c = 'c00';
        newLead.Additional_Parent_Relationship_to_Child__c = 'Father';
        newLead.Hidden_Additional_Parent_Id__c = wishFamilyConntact.id;
        newLead.Best_Contact_for_Physician_First_Name__c = 'Test Fname';
        newLead.Best_Contact_for_Physician_Last_Name__c = 'Test Lname';
        newLead.Best_contact_for_Physician_Email__c = 'test@gmail.com';
        insert newLead;
        test.startTest();
        Office__c newOffice =  new Office__c();
        newOffice.Chapter__c = chapterAccount.id;
        newOffice.Zip_Code__c = '35216';
        insert newOffice;
        
        Zip_Code__c newZip = new Zip_Code__c();
        newZip.Name = '35216';
        newZip.Office__c = newOffice.id;
        newZip.External_Id__c = '35216';
        insert newZip;
            
        Lead_File__c newLeadFile = new Lead_File__c();
        newLeadFile.Parent__c = newLead.id;
        newLeadFile.File_Name__c = 'test FIle Name';
        insert newLeadFile;
        
        dsfs__DocuSign_Status__c newDocuSign = new dsfs__DocuSign_Status__c();
        newDocuSign.dsfs__Lead__c = newLead.id;
        newDocuSign.dsfs__Envelope_Status__c = 'Completed';
        insert newDocuSign;
        
        Diagnosis_Verification__c newDV = new Diagnosis_Verification__c();
        newDV.ICD_Code__c = 'c00';
        newDV.Lead__c = newLead.id;
        insert newDV;
        
        list<Lead> leadList = new list<Lead>();
        newLead.Status = 'Qualified';
        leadList.add(newLead);
        if(leadList.size() > 0 )
        update leadList;
        set<String> postalCode = new Set<String>();
        postalCode.add('35216');
        LeadTriggerHandler leadHandler = new LeadTriggerHandler();
        leadHandler.onAfterUpdate(leadList);
        
        test.stopTest();
    }
    
}