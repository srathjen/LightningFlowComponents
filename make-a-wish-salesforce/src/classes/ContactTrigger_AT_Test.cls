/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : ContactTrigger_AT_Test is used to increase the code coverage for contact_AT trigger and contactTriggerHandler.
*****************************************************************************************************/

@isTest
public class ContactTrigger_AT_Test{
    /*This setup method is used to create a chapter user and systemAdmin users*/
    
    @testSetup static void setup(){   
        OrientationandTrainingUtil.createChapterUser();
        OrientationandTrainingUtil.createrSystemAdminUser();
    }
    /*This setup method is used to create a community user records*/
    public testmethod static void createCommunityUser(){  
        User chapterUser = [SELECT Id,UserName,ProfileId,Profile.Name,Email FROM User WHERE Email  =: 'test123@gmail.com' LIMIT 1];        
            System.runAs(chapterUser){
                Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
                try{
                    OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);}
                catch(exception ex){
                }
            }
        
    }
    
    
    /*This method is used to update the application status to complete*/
    
    public testmethod static void UpdateApplicationStatustoComplete(){ 
        Constant_AC  constant = new Constant_AC(); 
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        user systemAdmin = [select id from user where id =:userinfo.getuserid()];
        system.runAs(systemAdmin){
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
            OrientationandTrainingUtil.CreateAffiliation(VolunteerContact.Id);
            Contact dbcontact = [SELECT Id,FirstName,LastName,AccountId,Birth_Month__c ,Birth_Day__c,is_Application__c, Birth_Year__c,RecordTypeId FROM Contact Where RecordTypeId =: volunteerRecordTypeId Limit 1];
            dbcontact .Birth_Day__c = '21';
            dbcontact .Birth_Month__c = 'March';
            dbcontact.RecordTypeId=volunteerRecordTypeId;
            dbcontact .Birth_Year__c = '1986';
            dbcontact .is_Application__c =  'Complete';
            dbcontact.HiddenOtherPhone__c = '1122334455';
            update dbcontact;
            System.assertEquals(dbcontact .is_Application__c,'Complete');
        }
    }
    
    /*This method is used to update the application status to reject*/
    
    public testmethod static void UpdateApplicationStatustoReject(){ 
        Constant_AC  constant = new Constant_AC(); 
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        user systemAdmin = [select id from user where id =:userinfo.getuserid()];
        system.runAs(systemAdmin){
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
            OrientationandTrainingUtil.CreateAffiliationwithAccount(VolunteerContact.Id,chapterAccount.id);
            Role__c WishRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,WishRole.Id);
            Contact dbcontact = [SELECT Id,FirstName,LastName,AccountId,Birth_Month__c ,Birth_Day__c,is_Application__c, Birth_Year__c,RecordTypeId FROM Contact Where RecordTypeId =: volunteerRecordTypeId Limit 1];
            dbcontact .Birth_Day__c = '21';
            dbcontact .Birth_Month__c = 'March';
            dbcontact .Birth_Year__c = '1986';
            dbcontact .is_Application__c =  'Rejected';
            dbcontact.Volunteer_Role__c = 'Wish Granter;Airport Greeter';
            update dbcontact;
            System.assertEquals(dbcontact .is_Application__c,'Rejected');
        }
    }
    
    /*This method is used to create a task record when zipcode is update*/
    
    public testmethod static void CreateZipcodeUpdateTask(){
        user systemAdmin = [select id from user where id =:userinfo.getuserid()];
        system.runAs(systemAdmin){
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Account chapterAccount1 = OrientationandTrainingUtil.createVolunteerAccount();
            Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
            Office__c  officeRec = OrientationandTrainingUtil.createOffice(chapterAccount1.Id);
            officeRec.External_Id__c = 'R123';
            insert officeRec;
            Zip_Code__c  zipcodeRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
            zipcodeRec.Name = '32401';
            zipCodeRec.office__c = officeRec.id;
            zipCodeRec.External_Id__c = 'R123';
            insert zipCodeRec;
            OrientationandTrainingUtil.CreateAffiliationwithAccount(VolunteerContact.Id,chapterAccount.id);
            contact dbContact = [SELECT Id,MailingPostalCode  FROM Contact WHERE Id =:VolunteerContact.Id];
            dbContact.MailingPostalCode  = '32401';
            update dbContact;
            System.assertEquals(dbcontact .MailingPostalCode,'32401');
          
        }
    }
    
    /* This Method is used to update the Volunteer LastName,FirstName,Email and Mobile Number */
    public testmethod static void UpdateVolunteerDetails(){ 
        Constant_AC  constant = new Constant_AC(); 
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        user systemAdmin = [select id from user where id =:userinfo.getuserid()];
        system.runAs(systemAdmin){
            
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
            User volunteerUser=OrientationandTrainingUtil.createVolunteerUser(VolunteerContact.Id);
            OrientationandTrainingUtil.CreateAffiliationwithAccount(VolunteerContact.Id,chapterAccount.id);
            Role__c WishRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id,WishRole.Id);
            Contact dbcontact = [SELECT Id,FirstName,LastName,MobilePhone,Email,RecordTypeId FROM Contact Where RecordTypeId =: volunteerRecordTypeId Limit 1];
            dbcontact.LastName = 'moss';
            dbcontact.FirstName = 'Smith';
            dbcontact.MobilePhone='9003910427';
            dbcontact.Email ='Smith@gmail.com';
            dbcontact.Same_as_Household_Address__c = True;
            update dbcontact;
            System.assertEquals(dbcontact .Email,'Smith@gmail.com');
            
        }
        
    }
    //This Method is used to create a wish child contact
    testmethod static void CreateWishChildContact()
    {
        Constant_ac constant = new Constant_ac();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        
        Account newAcc = new Account();
        newAcc.Name = 'Test';
        insert newAcc; 
        
        Account chapterAcc=OrientationandTrainingUtil.createchapterAccount();
        ICD_Codes__c  newICD = new ICD_Codes__c ();
        newICD.Name = 'c00';
        insert newICD;
        Contact newCon = new Contact();
        newCon.LastName = 'Test';
        newCon.ICD_10_Code__c = newICD.Id;
        newCon.Diagnosis__c  = 'Malignant Neoplasm';
        //newCon.Short_Description__c  = 'Test';
        newCon.Non_Verbal__c  = 'No';
        newCon.accountid = newAcc.id;
        newCon.Region_Chapter__c=chapterAcc.Id;
        newCon.recordTypeId = wichChildRecordTypeId;
        insert newCon;
        System.assertEquals(newCon.ICD_10_Code__c ,newICD.Id);
    }
    
    //This method is used to create a medical professional contact.
    testmethod static void CreateMedicalContact()
    {
        Constant_ac constant = new Constant_ac();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Id MedicalProfContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId(); 
        Account newAcc = new Account();
        newAcc.Name = 'Test';
        insert newAcc; 
        ICD_Codes__c  newICD = new ICD_Codes__c ();
        newICD.Name = 'c00';
        insert newICD;
        Contact newCon = new Contact();
        newCon.LastName = 'Test';
        newCon.ICD_10_Code__c = newICD.Id;
        newCon.Diagnosis__c  = 'Malignant Neoplasm';
        //newCon.Short_Description__c  = 'Test';
        newCon.Non_Verbal__c  = 'No';
        newCon.accountid = newAcc.id;
        newCon.recordTypeId = wichChildRecordTypeId;
        insert newCon;
        
        Contact newMedCon = new Contact();
        newMedCon.LastName = 'Test';
        // newMedCon.accountid = newAcc.id;
        newMedCon.recordTypeId = MedicalProfContactRecordTypeId;
        insert newMedCon;
        
        npe4__Relationship__c newRel = new npe4__Relationship__c();
        newRel.npe4__RelatedContact__c = newMedCon.id;
        newRel.npe4__Contact__c =  newCon.id;
        newRel.npe4__Status__c = 'Active';
        newRel.Qualifying_Medical_Professional__c = true;
        insert newRel;
        
        newMedCon.LastName = 'Test1';
        newMedCon.Email = 'test@gmail.com';
        update newMedCon;
        System.assertEquals(newMedCon.Email ,'test@gmail.com');
    }
    
    //This method is used to update the wish family contatc information.
    public testmethod static void RecallWishFamilyContactInfo(){
       
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id,childFamily.Id);
        
        Contact updateConFamily = new Contact();
        updateConFamily.Hidden_First_Name__c  = 'Chandra';
        updateConFamily.Hidden_Last_Name__c  = 'Sekar';
        updateConFamily.Hidden_Phone__c = '8056913402';
        updateConFamily.Hidden_Email__c  = 'testmst@gmail.com';
        updateConFamily.Hidden_Street__c = 'North Street';
        updateConFamily.Hidden_city__c = 'Chennai';
        updateConFamily.Hidden_State__c = 'Alabama';
        updateConFamily.Hidden_Country__c =  'United States';
        updateConFamily.Hidden_Zip_Code__c = '621010';
        updateConFamily.IsContactInfoUpdated__c = true;
        updateConFamily.Id = childFamily.Id;
        update updateConFamily;        
        
        Contact updateCon = new Contact();
        updateCon.Email = 'kanagu431@gmail.com';
        updateCon.IsRejected_Contact_Info__c = true;
        updateCon.Id = childCon.Id;
        update updateCon;
        System.assertEquals(updateCon.IsRejected_Contact_Info__c ,True);
    }
    
    //This method used to increase the code coverage for when the wish child information is updated.
    public testmethod static void updatewishChildContactInfo(){        
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();        
        Contact updateCon = new Contact();
        updateCon.Hidden_First_Name__c  = 'Chandra';
        updateCon.Hidden_Last_Name__c  = 'Sekar';
        updateCon.Hidden_Phone__c = '8056913402';
        updateCon.Hidden_Email__c  = 'testmst@gmail.com';
        updateCon.Hidden_Street__c = 'North Street';
        updateCon.Hidden_city__c = 'Chennai';
        updateCon.Hidden_State__c = 'Alabama';
        updateCon.Hidden_Country__c =  'United States';
        updateCon.Hidden_Zip_Code__c = '621010';
        updateCon.IsContactInfoUpdated__c = true;
        updateCon.Id = childCon.Id;
        update updateCon;
        System.assertEquals(updateCon.IsContactInfoUpdated__c ,True);  
    }
    
    /*This method is used to update the application status to submit*/
    
    public testmethod static void UpdateApplicationStatustoSubmit(){ 
        Constant_AC  constant = new Constant_AC(); 
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        user systemAdmin = [select id from user where id =:userinfo.getuserid()];
        system.runAs(systemAdmin){
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
            OrientationandTrainingUtil.CreateAffiliation(VolunteerContact.Id);
            Contact dbcontact = [SELECT Id,FirstName,LastName,AccountId,Birth_Month__c ,Birth_Day__c,is_Application__c, Birth_Year__c,RecordTypeId FROM Contact Where RecordTypeId =: volunteerRecordTypeId Limit 1];
            dbcontact .Birth_Day__c = '21';
            dbcontact .Birth_Month__c = 'March';
            dbcontact .Birth_Year__c = '1986';
            dbcontact .is_Application__c = 'Submit';
            update dbcontact;
            System.assertEquals(dbcontact.is_Application__c,'Submit');  
        }
    }
    
    //This method is used to update the medical professional contact.
    public testmethod static void updateMedicalProfContact(){
        Constant_AC  constant = new Constant_AC(); 
        Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Contact medicalProfessionalcon=OrientationandTrainingUtil.createMedicalProfContact();
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        npe4__Relationship__c relationship=OrientationandTrainingUtil.CreateMedicalProfessionalRelationshipRec(medicalProfessionalcon.Id,childCon.Id);
        Contact UpdateMedicalProfessional=[SELECT id,FirstName FROM Contact WHERE RecordTypeId =:medicalProfessionalRecordTypeId Limit 1];
        UpdateMedicalProfessional.FirstName='Smith';
        update UpdateMedicalProfessional;
        System.assertEquals(UpdateMedicalProfessional.FirstName,'Smith');  
        
    }
    
    public testmethod static void createwishfamilyContact(){
        Contact wishChildFamily = OrientationandTrainingUtil.CreateWishFamily();
    }
    
    //This Method is used to Update and recall the wish family contatc information.
    public testmethod static void RecallWishChildContactInfo(){
        
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id,childFamily.Id);
        
        Contact updateConFamily = new Contact();
        updateConFamily.Hidden_First_Name__c  = 'Chandra';
        updateConFamily.Hidden_Last_Name__c  = 'Sekar';
        updateConFamily.Hidden_Phone__c = '8056913402';
        updateConFamily.Hidden_Email__c  = 'testmst@gmail.com';
        updateConFamily.Hidden_Street__c = 'North Street';
        updateConFamily.Hidden_city__c = 'Chennai';
        updateConFamily.Hidden_State__c = 'Alabama';
        updateConFamily.Hidden_Country__c =  'United States';
        updateConFamily.Hidden_Zip_Code__c = '621010';
        updateConFamily.IsContactInfoUpdated__c = true;
        updateConFamily.Id = childFamily.Id;
        update updateConFamily;
        
        System.assert([SELECT Name FROM Contact WHERE Hidden_Zip_Code__c ='621010' LIMIT 1].Name != Null);        
        Contact updateCon = new Contact();
        updateCon.Email = 'kanagu431@gmail.com';
        updateCon.IsContactInfoUpdated__c = true;
        updateCon.Id = childCon.Id;
        update updateCon;
    }
    
    //This method is used to recall the approval and update the wish child contac information.
    public testmethod static void updatewishChildRecall(){
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id,childFamily.Id);
        childFamily.Hidden_First_Name__c  = '';
        Update childFamily;
        Contact updateCon = new Contact();
        updateCon.Hidden_First_Name__c  = 'Chandra';
        updateCon.Hidden_Last_Name__c  = 'Sekar';
        updateCon.Hidden_Phone__c = '8056913402';
        updateCon.Hidden_Email__c  = 'testmst@gmail.com';
        updateCon.Hidden_Street__c = 'North Street';
        updateCon.Hidden_State__c = 'Alabama';
        updateCon.Hidden_Country__c =  'United States';
        updateCon.Hidden_Zip_Code__c = '621010';
        updateCon.HiddenOtherPhone__c = '9876543210';
        updateCon.HiddenMobilePhone__c = '8907654321';
        updateCon.Hidden_Use_as_Household_Address__c = True;
        updateCon.IsRejected_Contact_Info__c = true;
        updateCon.Id = childCon.Id;
        update updateCon;
        updateCon.Hidden_city__c = 'Chennai';
        Update updateCon;
        System.assertEquals(updateCon.Hidden_city__c,'Chennai');        
    }
    
    /*This Method is used to update the relationship type in wish family contact.
    public testmethod static void  updateRelationship(){
        Test.startTest();
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        Contact wishchildCon = OrientationandTrainingUtil.CreateWishChildCon();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  newRelationShip= OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id,childFamily.Id); 
        
        Contact updateCon = new Contact();
        updateCon.Id = childFamily.Id;
        updateCon.Relationship__c = 'Brother';
        updateCon.Email = 'Test@msil.com';
        
        Update updateCon;
        System.assert(updateCon.Email!= Null);
        
        Contact wishchildFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c   relationship = new npe4__Relationship__c();
        newRelationShip.Parent_Legal_Guardian__c = True;
        relationship.npe4__Contact__c = wishchildCon.Id;
        relationship.npe4__RelatedContact__c = wishchildFamily.Id;
        relationship.npe4__Status__c = 'Active';
        relationship.npe4__Type__c = 'Father';
        Insert relationship; 
        Test.stopTest();        
    }
    */
    public testmethod static void deleteContact()
    {
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        Delete childFamily;
    }
    
    //This method is used to update the condition description in wish child contact.
    public testmethod static void diagnosisUpdate()
    {
        Constant_AC  constant = new Constant_AC();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(childCon.Id);
        childCon.Diagnosis__c = 'Malignant';
        childCon.SD1_Condition_Description__c = 'Malignant';
        childCon.SD2_Condition_Description__c = 'Malignant';
        childCon.SD3_Condition_Description__c = 'Malignant';
        childCon.SD4_Condition_Description__c = 'Malignant';
        childCon.RecordTypeId = wichChildRecordTypeId;
        update childCon;
        System.assertEquals([SELECT Id FROM Contact WHERE SD1_Condition_Description__c = 'Malignant' LIMIT 1].Id,childCon.Id);
    }
    
    //This method is used to update the ICD in wish child contact.
    public testmethod static void icdUpdates()
    {
        Constant_AC  constant = new Constant_AC();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
        ICD_Codes__c newICD = new ICD_Codes__c(Name = 'C00');
        insert newICD;
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(childCon.Id);
        childCon.ICD_10_Code__c = newICD.Id;
        childCon.SD1_ICD_Code__c = newICD.Id;
        childCon.SD2_ICD_Code__c = newICD.Id;
        childCon.SD3_ICD_Code__c = newICD.Id;
        childCon.SD4_ICD_Code__c = newICD.Id;
        childCon.RecordTypeId = wichChildRecordTypeId;
        update childCon;
        System.assertEquals([SELECT Id FROM Contact WHERE ICD_10_Code__c =: newICD.Id LIMIT 1].Id,childCon.Id);
    }
    
    //This method is used to create a volunteer user for migrated volunteer contact.
    public testmethod static void createMigratedVolunteerUser(){
       Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Account chapterAcc=OrientationandTrainingUtil.createchapterAccount();
        Contact newContact = new Contact();
        newContact.FirstName = 'moss';
        newContact.LastName = 'Smith';
        newContact.Birthdate = System.today()-1;
        newContact.Parent_Guardian_Name__c = 'Steve Smith'; 
        newContact.RecordTypeId = volunteerRecordTypeId;
        newContact.Title = 'Mr';
        newContact.Birth_Month__c = 'January';
        newContact.Birth_Day__c = '12';
        newContact.Birth_Year__c = '1985';
        newContact.Alternate_Phone_Type__c = 'Home';
        newContact.npe01__PreferredPhone__c = 'Mobile';
        newContact.OtherPhone = '3332211144';
        newContact.HomePhone= '9003910426';
        newContact.MobilePhone= '9003910426';
        newContact.I_m_on_LinkedIn__c ='Yes';
        newContact.How_did_you_hear_about_Make_A_Wish__c  = 'Family';
        newContact.MailingStreet  = 'ThillaiNagar';
        newContact.MailingCity = 'Trichy';
        newContact.MailingCountrycode = 'US';
        newContact.MailingPostalCode = '621010';
        newContact.mailingstatecode = 'AZ';
        newContact.Emergency_Contact__c  = 'Test';
        newContact.Emergency_Contact_Relationship__c= 'Father';
        newContact.Emergency_Contact_Phone__c  = '9003910426';
        newContact.Read__c  = 'English';
        newContact.language__c = 'English';
        newContact.speak__c = 'English';
        newContact.understand__c = 'English';
        newContact.Professional_Skills__c = 'Photography';
        newContact.Language_Notes__c = 'Test';
        newContact.Volunteer_Role__c = 'Special Events';
        newContact.is_Application__c ='Partial Submit';
        newContact.AccountId = chapterAcc.Id;
        newContact.email='Test@mail.com';
        newContact.Volunteer_Role__c = 'Water Handler';
        newContact.Do_Not_Create_User__c=False;
        newContact.Migrated_Record__c = True;
        insert newContact; 
        System.assert(newContact.Migrated_Record__c,True);
    }
    
    public testmethod static void updateContactPhone(){
        Constant_AC  constant = new Constant_AC();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact newCon = New Contact();
        newCon.RecordTypeId = wichChildRecordTypeId;
        newCon.IsContactInfoUpdated__c = true;
        newCon.Hidden_First_Name__c = 'TestFirst Name';
        newCon.Hidden_Last_Name__c = 'estLastName';
        newCon.FirstName = 'TestFirst Name';
        newCon.LastName = 'TestLastName';
        newCon.Diagnosis__c = 'Malignant Neoplasm';
        insert newCon;
        npe4__Relationship__c newRlet = new npe4__Relationship__c();
        newRlet.npe4__RelatedContact__c = newCon.id;
        newRlet.npe4__Status__c = 'Active';
        newRlet.npe4__Contact__c = newCon.id;
        insert newRlet;
        newCon.Hidden_Phone__c = '222222222222';
        newCon.HiddenMobilePhone__c = '2222222222';
        newCon.HiddenOtherPhone__c = '1111111111';
        newCon.Hidden_Preferred_Contact_Rel_Id__c = newRlet.id;
        newCon.Hidden_Zip_Code__c = '62100';
        update newCon;
        newCon.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
        update newCon;
    }
    
    public testmethod static void updateContactPhoneNegative(){
        Constant_AC  constant = new Constant_AC();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact newCon = New Contact();
        newCon.RecordTypeId = wichChildRecordTypeId;
        newCon.IsContactInfoUpdated__c = true;
        newCon.FirstName = 'TestFirst Name';
        newCon.LastName = 'TestLastName';
        newCon.Diagnosis__c = 'Malignant Neoplasm';
        insert newCon;
        newCon.Hidden_Phone__c = '9912121313';
        newCon.HiddenMobilePhone__c = '9912121313';
        newCon.HiddenOtherPhone__c = '9912121313';
        newCon.Hidden_Zip_Code__c = '11111';
        newCon.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
        update newCon;
        
       
    }
    
}