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
    
   /*This method is used to increase the code coverage for findDuplicateRecords method */ 
   public testmethod static void FindWishChildDupe(){ 
         
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Child_Age__c = '4';
         insert newLead;
         try{
         Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         insert dupeLead;  
         }
         catch(Exception ex){
         }
   }
   /*This method is used to increase the code coverage for findDuplicateRecords method when the lead status is updated as 'referred'. */ 
    public testmethod static void UpdateStatusAsReferred(){ 
        
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Child_Age__c = '4';
         insert newLead;
         try{
         newLead.Status = 'Referred';
         update newLead ;
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
         newLead.Child_Age__c = '4';
         insert newLead;
         newLead.LastName = 'Dravid';
         newLead.ICD_10_Code__C = '';
         newLead.Primary_Diagnosis__c = '';
         newLead.Medical_Questions__c = 'Yes';
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
         insert newLead;
         newLead.Status = 'Eligibility Review';
         newLead.Treating_Medical_Professional_Email__c  = 'testmawa3@gmail.com';
         newLead.Postalcode = '32193';
         newLead.ICD_10_Code__c =  'C43.30';
         newLead.Primary_Diagnosis__c = 'Malignant Melanoma';
         newLead.Medical_Questions__c = 'YES Test Diagnosis';
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
         insert newLead;
         newLead.Status = 'Part A Pending';
         newLead.Treating_Medical_Professional_Email__c  = 'testmawa3@gmail.com';
         newLead.Postalcode = '32193';
         newLead.ICD_10_Code__c =  'C43.30';
         newLead.Primary_Diagnosis__c = 'Malignant Melanoma';
         newLead.Medical_Questions__c = 'YES Test Diagnosis';
         update newLead ;
         
     }
     
     /*This method is used to increase the code coverage for onAfterUpdate method when the lead status is updated as 'Qualified'. */ 
     
     public testmethod static void UpdateStatusAsQualified(){ 
        
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
         Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
         Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
         Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
         ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Child_Age__c = '4';
         insert newLead;
          newLead.Status = 'Qualified';
          Test.StartTest();
          update newLead ;
          Test.StopTest();
      
     }
      
    /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
   public testmethod static void CreateNewContactRecord(){ 
        
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
         Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
         Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
         Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
         ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Sibling_Detail__c = 'aa | bbb | 12 '+'<br/>'+' bb | ccc | 13';
         newLead.Child_Age__c = '4';
         insert newLead;
         dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id); 
         Case partAWish = OrientationandTrainingUtil.CreatePartAWish(newLead.Id);
         newLead.Status = 'Qualified';
         Test.StartTest();
         update newLead ;
         Test.StopTest();
      
     }
     
     /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
     public testmethod static void CreateNewSameContactRecord(){ 
        
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Account alabamaAccountRec = OrientationandTrainingUtil.AlabamaAccount();
         Office__c  officeRec = OrientationandTrainingUtil.createOffice(alabamaAccountRec .Id);
         Zip_Code__c  zipRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
         Condition_Description__c  newDesCription = OrientationandTrainingUtil.createConditionDesCription();
         ICD_Codes__c  NewIcdCode = OrientationandTrainingUtil.createICDCode(newDesCription.Id);
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Sibling_Detail__c = 'aa | bbb | 12 '+'<br/>'+' bb | ccc | 13';
         newLead.Medical_Professional_First_Name__c = 'Steve';
         newLead.Medical_Professional_Last_Name__c = 'Waugh';
         newLead.Medical_Professional_Phone__c =  '9600467557';
         newLead.Medical_Professional_Email__c = 'testmawa2@gmail.com';
         newLead.Hospital_Treatment_Facility__c =  'Steve Smith AC';
         newLead.Child_Age__c = '4';
         insert newLead;
         dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id); 
         Case partAWish = OrientationandTrainingUtil.CreatePartAWish(newLead.Id);
         newLead.Status = 'Qualified';
         Test.StartTest();
         update newLead ;
         Test.StopTest();
      
     }
     
     /*This method is used to increase the code coverage for dupecheckonContact method when the lead status is updated as 'Qualified'. */ 
     public testmethod static void CreateRelationShipRecord(){ 
        
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Contact trateProfContact = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
         Contact medicalProfContact = OrientationandTrainingUtil.CreateMedicalProfContact();
         Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Child_Age__c = '4';
         newLead.Treating_Medical_Professional_Contact_Id__c = trateProfContact.Id;
         newLead.Medical_Professional_ContactId__c = medicalProfContact.Id;
         newLead.Wish_Family_ContactId__c = wishFamily.Id;
         newLead.Sibling_Detail__c = 'aa | bbb | 12';
         insert newLead;
         dsfs__DocuSign_Status__c dsfs = OrientationandTrainingUtil.createDocusignStatus(newLead.Id); 
         Case partAWish = OrientationandTrainingUtil.CreatePartAWish(newLead.Id);
         newLead.Status = 'Qualified';
         Test.StartTest();
         update newLead ;
         Test.StopTest();
      
     }
      
}