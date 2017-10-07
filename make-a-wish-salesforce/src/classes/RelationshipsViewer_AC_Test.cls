/************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 22/10/2016
Description : RelationshipsViewer_AC_Test is used to increase the code coverage for RelationshipsViewer_AC controller.
****************************************************************************************************************************/

@isTest
public class RelationshipsViewer_AC_Test{
    
    /*This EditContacts() is used to edit wish child and wish family contacts.*/
    public testmethod static void EditContacts(){
        /*Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        List<String> Option;
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
        rlationshipIns.ErrorMessage();
        rlationshipIns.DisplayErrorMessage();
        rlationshipIns.SameErrorMessage();
    }
    
    /*This UpdateWishChild() is used to update wish child  contact.*/
    public testmethod static void UpdateWishChild(){
        List<Contact> wishchildList = new List<Contact>();
      /*  Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
       
        Contact updateWishChild = new Contact();
        updateWishChild.Id = wishChild.Id;
        updateWishChild.Phone = '8056913402';
        updateWishChild.Email = 'test@gmail.com';
        updateWishChild.MailingStreet = 'North Street';
        updateWishChild.MailingCity = 'Chennai';
        updateWishChild.MailingState = 'Alabama';
        updateWishChild.MailingCountryCode = 'US';
        updateWishChild.MailingPostalCode = '621010';
        updateWishChild.MobilePhone = '8882288822';
        updateWishChild.OtherPhone = '9843680350';
        updateWishChild.HiddenOtherPhone__c = '7998689374';
        updateWishChild.MailingStreet = 'Test street';
        updateWishChild.Hidden_Street__c = 'Hidden street';
        updateWishChild.Hidden_Country__c = 'Alabama';
        updateWishChild.Hidden_State__c = 'test State';
        updateWishChild.City_Employer__c = 'test city';
        updateWishChild.Zip_Employer__c = '85003';
       // updateWishChild.Use_as_Household_Address__c = true;
        updatewishChild.Use_as_Household_Address__c = false;
        wishchildList.add(updateWishChild);
        update wishchildList;  
        Test.StartTest();
        rlationshipIns.wishChildContactList = wishchildList;
        rlationshipIns.SaveUpdatedContact();
        Test.StopTest();
    }
    
    
    /*This UpdateWishChild() is used to update wish child  contact Email.*/
    public testmethod static void UpdateWishChildEmail(){
        List<Contact> wishchildList = new List<Contact>();
       /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
       
        Contact updateWishChild = new Contact();
        updateWishChild.Id = wishChild.Id;
        updateWishChild.Hidden_Phone__c = '9999333444';
        updateWishChild.phone = null;
        updateWishChild.Use_as_Household_Address__c = true;
        updateWishChild.Same_as_Household_Address__c = true;
        wishchildList.add(updateWishChild);
        
        update wishchildList;  
        
        rlationshipIns.wishChildContactList = wishchildList;
        rlationshipIns.SaveUpdatedContact();
    }
    
    
    /*This UpdateFamily() is used to update wish family contacts.*/
    public testmethod static void UpdateFamily1(){
        
        List<Contact> wishFamilyList = new List<Contact>();
        List<Contact> wishFamilyList2 = new List<Contact>();
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
       /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        
        
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
        
        Contact updatewishFamily = new Contact();
        updatewishFamily.Id = wishFamily.Id;
        updatewishFamily.Phone = '8056913402';
        updatewishFamily.Email = 'test@gmail.com';
        updatewishFamily.MailingStreet = 'North Street';
        updatewishFamily.MailingCity = 'Chennai';
        updatewishFamily.MailingState = 'Alabama';
        updatewishFamily.MailingCountryCode = 'US';
        updatewishFamily.MailingPostalCode = '621010';
        updatewishFamily.HiddenMobilePhone__c = '9123456789';
        updatewishFamily.otherPhone = '9876543211';
        updatewishFamily.HiddenOtherPhone__c = '965432189';
        updatewishFamily.MobilePhone = '9894563654';
        updatewishFamily.Hidden_Email__c = 'test1@gmail.com';
        updatewishFamily.Hidden_Street__c = 'testStreet';
        updatewishFamily.Use_as_Household_Address__c = true;
        updatewishFamily.Hidden_Same_Address__c = true;
        updatewishFamily.Hidden_Country__c = 'USA';
        updatewishFamily.Hidden_State__c = 'testState';
        updatewishFamily.Hidden_Zip_Code__c = '35004';
        wishFamilyList .add(updatewishFamily);
        update wishFamilyList;
        rlationshipIns.clonedFamilyContactList = wishFamilyList;
        rlationshipIns.isMessage = false;
        Test.StartTest();
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
    }
    public testmethod static void UpdateWishChildCOntact1(){
        
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        rlationshipIns.sample = 'test sample';
        list <string> listoption = new list<string>();
        listoption.add(rlationshipIns.sample);
        rlationshipIns.options = listoption;
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
       
        Contact updateWishChild = new Contact();
        updateWishChild.Id = wishChild.Id;
        updateWishChild.Hidden_Phone__c = '9999333444';
        updateWishChild.MobilePhone = '9988775566';
        updateWishChild.phone = null;
        updateWishChild.Same_as_Household_Address__c = true;
        updateWishChild.Use_as_Household_Address__c = true;
        updateWishChild.Hidden_Country__c = 'USA';
        updateWishChild.HiddenMobilePhone__c = '9123456789';
        updateWishChild.otherPhone = '9876543211';
        updateWishChild.HiddenOtherPhone__c = '965432189';
        updateWishChild.Hidden_Email__c = 'test1@gmail.com';
        updateWishChild.Hidden_Street__c = 'testStreet';
        updateWishChild.Use_as_Household_Address__c = true;
        updateWishChild.Hidden_Same_Address__c = true;
        updateWishChild.Hidden_State__c = 'testState';
        updateWishChild.Hidden_Zip_Code__c = '35004';
        update updateWishChild;
        
    }
    
    
    public testmethod static void UpdateFamily2(){
    
        List<Contact> wishFamilyList2 = new List<Contact>();
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
       /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        
        
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
    
     Contact updatewishFam = new Contact();
        updatewishFam .Id = wishFamily.Id;
        updatewishFam .Phone = '8056913402';
        updatewishFam .Email = 'test@gmail.com';
        updatewishFam .MailingStreet = 'North Street';
        updatewishFam .MailingCity = 'Chennai';
        updatewishFam .MailingState = 'Alabama';
        updatewishFam .MailingCountryCode = 'US';
        updatewishFam .MailingPostalCode = '621010';
        updatewishFam .HiddenMobilePhone__c = '9123456789';
        updatewishFam .otherPhone = '9876543211';
        updatewishFam .HiddenOtherPhone__c = '965432189';
        updatewishFam .MobilePhone = '9894563654';
        updatewishFam .Hidden_Email__c = 'test1@gmail.com';
        updatewishFam .Hidden_Street__c = 'testStreet';
        updatewishFam .Use_as_Household_Address__c = false;
        updatewishFam .Hidden_Same_Address__c = false;
        updatewishFam .Hidden_Country__c = 'USA';
        updatewishFam .Hidden_State__c = 'testState';
        updatewishFam .Hidden_Zip_Code__c = '35004';
        wishFamilyList2 .add(updatewishFam );
        update wishFamilyList2;
        rlationshipIns.clonedFamilyContactList = wishFamilyList2;
        rlationshipIns.isMessage = false;
        Test.StartTest();
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
    }
    
}