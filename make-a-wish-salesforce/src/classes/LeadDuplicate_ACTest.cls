@isTest
Public class LeadDuplicate_ACTest
{
   
  // Creating duplicate lead and duplicate wish Family record.
  static testmethod void createDuplicateFamily()
  {
     Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
     Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
     Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
     newLead.Child_Age__c = '4';
     newLead.unique_wish_identifier__c = '1234567';
     newLead.Additional_Parent_Relationship_to_Child__c = '';
     newLead.Additional_Parent_First_Name__c = 'Parent2';
     newLead.Additional_Parent_Last_Name__c = 'Lead';
     newLead.Additional_Parent_Phone__c = '9876543210';
     newLead.Additional_Parent_Email__c = 'parent2@mail.com';
     newLead.Additional_Parent_Postal_Code__c = '35004';
     newLead.Additional_Parent_City__c = 'Test st';
     newLead.Additional_Parent_State__c = 'Alabama';     
     insert newLead;
      
     Lead newdupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
     newdupLead.Override_Dupe_Check__c = True;
     newdupLead.Child_Age__c = '4';
     newdupLead.unique_wish_identifier__c = '123456';
     insert newdupLead;
      
     ApexPages.currentPage().getParameters().put('wishFamily','True');
     ApexPages.currentPage().getParameters().put('Id',newLead.id);
     List<Lead> currLead = new List<Lead>();
     currLead.add(newLead);
     currLead.add(newdupLead);
     ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
     LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
     controller.getdupLeadList();
     controller.getdupContactList();
     controller.getAdditionalParentContactList();
     controller.getdupMedicalContactList();
     controller.getdupTreatingContactList();
     controller.getdupParentContactList();
     controller.nextStep();
  
  }
  // Selecting No duplicate Option on Lead Merge page.
  static testmethod void selectNoDuplicate()
  {
     Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
     Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
     Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
     newLead.Child_Age__c = '4';
     newLead.unique_wish_identifier__c = '1234567';
     insert newLead;
      
     Lead newdupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
     newdupLead.Override_Dupe_Check__c = True;
     newdupLead.Child_Age__c = '4';
     newdupLead.unique_wish_identifier__c = '1234568';
     insert newdupLead;
      
     ApexPages.currentPage().getParameters().put('wishFamily','True');
     ApexPages.currentPage().getParameters().put('Id',newLead.id);
     List<Lead> currLead = new List<Lead>();
     currLead.add(newLead);
     currLead.add(newdupLead);
     ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
     LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
     controller.NoDuplicate = True; 
    
     controller.nextStep();
     controller.ContinuePartAForm();
     controller.CompleteDupeCheck();
  
  }
  
  // Creating duplicate medical professional contacts.
  static testmethod void duplicateMedicalProfessional()
  {
     Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
     Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
     Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
     
     
     newLead.Treating_Medical_Professional_First_Name__c = 'moss';
     newLead.Treating_Medical_Professional_Last_Name__c  = 'hart';
     newLead.Treating_Medical_Professional_Phone__c  = '9600467558';
     newLead.Treating_Medical_Professional_Email__c = 'testmawa1@gmail.com';
     newLead.Hospital_Treatment_Facility__c = 'Moss Hart AC';
     newLead.Child_Age__c = '4';
     newLead.unique_wish_identifier__c = '1234567';
      newLead.Alternate1HospitalTreatmentFacility__c = 'Alternate1Hos';
     newLead.Alternate1MedicalProfessionalEmail__c = 'alternate1@mail.com';
     newLead.Alternate1MedProfessionalFirstName__c = 'Test';
     newLead.Alternate1MedProfessionalLastName__c = 'Alternate1';
     newLead.Alternate1MedProfessionalPhone__c = '9876543210';
     newLead.Alternate2HospitalTreatmentFacility__c = 'Alternate2Hos';
     newLead.Alternate2MedProfessionalEmail__c = 'alternate2@mail.com';
     newLead.Alternate2MedProfessionalFirstName__c = 'Test';
     newLead.Alternate2MedProfessionalLastName__c = 'Alternate2';
     newLead.Alternate2MedProfessionalPhone__c = '9876543201'; 
     newLead.Best_contact_for_Physician_Email__c = 'best@mail.com';
     newLead.Best_Contact_for_Physician_First_Name__c = 'best';
     newLead.Best_Contact_for_Physician_Last_Name__c = 'Last';
      insert newLead;
     Lead newdupLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
     newdupLead.Override_Dupe_Check__c = True;
     newdupLead.Child_Age__c = '4';
     newdupLead.unique_wish_identifier__c = '1234568';
     insert newduplead;
     Lead newdupLead2 = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
     newdupLead2.Override_Dupe_Check__c = True;
     newdupLead2.Child_Age__c = '4';
     newdupLead2.unique_wish_identifier__c = '1234568';
     //insert newduplead2;
     
     ApexPages.currentPage().getParameters().put('wishFamily','True');
     ApexPages.currentPage().getParameters().put('Id',newLead.id);
     List<Lead> currLead = new List<Lead>();
     currLead.add(newLead);
     currLead.add(newdupLead);
     ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
     LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
    controller.currLead.Hospital_Treatment_Facility_Treating__c = 'test';
     controller.getdupContactList();
     controller.getdupMedicalContactList();
     controller.getdupTreatingContactList();
      controller.getdupAlternate1MedicalContactList();
      controller.getdupAlternate2MedicalContactList();
      controller.getbestPhysicianContactList();
     controller.getdupParentContactList();
       for(Lead currDup : currLead)
         {
           LeadDuplicate_AC.leadWrapper newWrapper = new LeadDuplicate_AC.LeadWrapper(currDup);
           newWrapper.selected = True;
           controller.wrapperList.add(newWrapper);
         }
     controller.getdupLeadList();
     controller.nextStep();
     Apexpages.currentPage().getParameters().put('recordId',currLead[0].id);
     controller.selectDefaultRecord();
     controller.mergeContacts();
     controller.isNo();
     controller.isYes();
     controller.GoToLeadViewPage();
  
  }
   //No duplicate creation.
   static testmethod void blankLead()
  {
     List<Lead> currLead = new List<Lead>();
     ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
     LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
  }

}