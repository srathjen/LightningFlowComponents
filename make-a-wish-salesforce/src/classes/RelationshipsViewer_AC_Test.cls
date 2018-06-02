/************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 22/10/2016
Description : RelationshipsViewer_AC_Test is used to increase the code coverage for RelationshipsViewer_AC controller.
****************************************************************************************************************************/

@isTest
public class RelationshipsViewer_AC_Test{
    /*This EditContacts() is used to edit wish child and wish family contacts.*/
    public testmethod static void editContacts(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        rlationshipIns.isWishFamily = false;
        rlationshipIns.UpdateContactInfo();
        rlationshipIns.getStates();
        rlationshipIns.ErrorMessage();
        rlationshipIns.DisplayErrorMessage();
        rlationshipIns.SameErrorMessage();
        rlationshipIns.close();
        rlationshipIns.ReturnToWish();
        system.assertEquals(relationship.npe4__Contact__c,wishChild.Id);
    }
    
    /*This method is used to increase the code coverage for wish child contact record.*/
     public testmethod static void updateWishChildContact(){
        List<Contact> wishchildList = new List<Contact>();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        rlationshipIns.isWishFamily = false;
        rlationshipIns.UpdateContactInfo();
        Contact updateWishChild = new Contact();
        updateWishChild.Id = wishChild.id;
        updateWishChild.Email = 'test123@gmail.com';
        updateWishChild.Phone = '9962474790';
        updateWishChild.MobilePhone = '9962474791';
        updateWishChild.OtherPhone = '9962474792';
        updateWishChild.MailingStreet = 'North Street';
        updateWishChild.MailingCity = 'Chennai';
        updateWishChild.MailingState = 'Alabama';
        updateWishChild.MailingPostalCode = '621010';
        wishchildList.add(updateWishChild);
        Update wishchildList;
        Test.StartTest();
        rlationshipIns.getStates();
        rlationshipIns.wishChildContactList = wishchildList;
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishchildList[0].Email,'test123@gmail.com');
    }
    
    /*This method is used to increase for blank values for wish child contact record block*/
     public testmethod static void updateWishChildContactwithNull(){
        List<Contact> wishchildList = new List<Contact>();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        rlationshipIns.isWishFamily = false;
        rlationshipIns.UpdateContactInfo();
        Contact updateWishChild = new Contact();
        updateWishChild.Id = wishChild.id;
        updateWishChild.Email = null;
        updateWishChild.Phone = null;
        updateWishChild.MobilePhone = null;
        updateWishChild.OtherPhone = null;
        updateWishChild.MailingStreet = null;
        updateWishChild.MailingCity = null;
        updateWishChild.MailingState = null;
        updateWishChild.MailingPostalCode = null;
        wishchildList.add(updateWishChild);
        Update wishchildList;
        Test.StartTest();
        rlationshipIns.getStates();
        rlationshipIns.wishChildContactList = wishchildList;
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishchildList[0].Email,null);
    }
    
     /*This method is used to increase for blank values to updated values for wish child contact record block*/
     public testmethod static void updateWishChildContactHouseHoldAdd(){
        List<Contact> wishchildList = new List<Contact>();
        Map<Id,npe4__Relationship__c> preferredCon = new Map<Id,npe4__Relationship__c>();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildConwithNull(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        relationship.Hidden_Preferred_Contact__c = True;
        Update relationship;
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        rlationshipIns.isWishFamily = false;
        preferredCon.put(relationship.npe4__RelatedContact__c,relationship);
        rlationshipIns.UpdateContactInfo();
        Contact updateWishChild = new Contact();
        updateWishChild.Id = wishChild.id;
        updateWishChild.Email = 'test123@gmail.com';
        updateWishChild.Phone = '9962474790';
        updateWishChild.MobilePhone = '9962474791';
        updateWishChild.OtherPhone = '9962474792';         
        updateWishChild.MailingStreet = 'North Street';
        updateWishChild.MailingCity = 'Chennai';
        updateWishChild.MailingState = 'Alabama';
        updateWishChild.MailingPostalCode = '621010';
        updateWishChild.Hidden_Current_Pref_Con_Rel_Id__c = relationship.Id;
        wishchildList.add(updateWishChild);
        Update wishchildList;
        Test.StartTest();
        rlationshipIns.getStates();
        
        rlationshipIns .preferredConMapClone = preferredCon;
        //rlationshipIns.newPreferredCon = relationship.npe4__RelatedContact__c;
        rlationshipIns.wishChildContactList = wishchildList;
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishchildList[0].Email,'test123@gmail.com');
    }
    
    /*This updateFamilyAddress() is used to update wish family contacts.*/
    public testmethod static void updateFamilyAddress(){
        Map<Id,npe4__Relationship__c> preferredCon = new Map<Id,npe4__Relationship__c>();
        List<Contact> wishFamilyList = new List<Contact>();
        List<Contact> wishFamilyList2 = new List<Contact>();
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        relationship.Hidden_Preferred_Contact__c = True;
        Update relationship;
        ApexPages.currentPage().getParameters().put('recId', parentCase.Id);
        RelationshipsViewer_AC rlationshipIns = new RelationshipsViewer_AC();
        
        preferredCon.put(relationship.npe4__RelatedContact__c,relationship);
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
        updatewishFamily.otherPhone = '9876543211';
        updatewishFamily.HiddenOtherPhone__c = '965432189';
        updatewishFamily.MobilePhone = '9894563654';
        updatewishFamily.npe01__WorkPhone__c = '9962474793';
        updatewishFamily.npe01__PreferredPhone__c =  'other';
        updatewishFamily.Use_as_Household_Address__c = true;
        wishFamilyList .add(updatewishFamily);
        update wishFamilyList;
        rlationshipIns.clonedFamilyContactList = wishFamilyList;
        rlationshipIns.isMessage = false;
        Test.StartTest();
        rlationshipIns .preferredConMapClone = preferredCon;
       // rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishFamilyList[0].Email,'test@gmail.com');
    }
    
    
    /*This updateWishFamilyContactHouseHoldAdd() is used to update wish family contacts.*/
    public testmethod static void updateWishFamilyContactHouseHoldAdd(){
        Map<Id,npe4__Relationship__c> preferredCon = new Map<Id,npe4__Relationship__c>();
        List<Contact> wishFamilyList = new List<Contact>();
        List<Contact> wishFamilyList2 = new List<Contact>();
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon(); 
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamilywithNull();
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
         relationship.Hidden_Preferred_Contact__c = True;
        Update relationship;
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
        //updatewishFamily.otherPhone = '9876543211';
        updatewishFamily.npe01__PreferredPhone__c =  'other';
        updatewishFamily.MobilePhone = '9894563654';
        updatewishFamily.Use_as_Household_Address__c = true;
        wishFamilyList .add(updatewishFamily);
        update wishFamilyList;
        preferredCon.put(relationship.npe4__RelatedContact__c,relationship);
        rlationshipIns.clonedFamilyContactList = wishFamilyList;
        rlationshipIns.isMessage = false;
        Test.StartTest();
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishFamilyList[0].Email,'test@gmail.com');
    }
    
    /*This updateFamilywithNullValue() is used to update wish family contacts with null values.*/
    public testmethod static void updateFamilywithNullValue(){
        
        List<Contact> wishFamilyList = new List<Contact>();
        List<Contact> wishFamilyList2 = new List<Contact>();
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
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
        updatewishFamily.Phone = Null;
        updatewishFamily.Email = Null;
        updatewishFamily.MailingStreet = Null;
        updatewishFamily.MailingCity = Null;
        updatewishFamily.MailingState = Null;
        updatewishFamily.MailingCountryCode = Null;
        updatewishFamily.MailingPostalCode = Null;
        updatewishFamily.otherPhone = Null;
        updatewishFamily.MobilePhone = Null;
        updatewishFamily.npe01__WorkPhone__c = Null;
        updatewishFamily.npe01__PreferredPhone__c = Null;
        updatewishFamily.Use_as_Household_Address__c = true;
        wishFamilyList .add(updatewishFamily);
        update wishFamilyList;
        rlationshipIns.clonedFamilyContactList = wishFamilyList;
        rlationshipIns.isMessage = false;
        Test.StartTest();
       // rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishFamilyList[0].Email,Null);
    }
    
    /*This updateFamilywithSameHouseHouseHold() is used to update wish family contacts.*/
    public testmethod static void updateFamilywithSameHouseHouseHold(){
        
        List<Contact> wishFamilyList = new List<Contact>();
        List<Contact> wishFamilyList2 = new List<Contact>();
        PageReference pageRef = Page.RelationshipsViewer_VF; 
        Test.setCurrentPage(pageRef);
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
        updatewishFamily.Same_as_Household_Address__c = true;
        updatewishFamily.Hidden_Use_as_Household_Address__c = false;
        wishFamilyList .add(updatewishFamily);
        update wishFamilyList;
        rlationshipIns.clonedFamilyContactList = wishFamilyList;
        rlationshipIns.isMessage = false;
        Test.StartTest();
        rlationshipIns.SaveUpdatedContact();
        rlationshipIns.close();
        Test.StopTest();
        system.assertEquals(wishFamilyList[0].Same_as_Household_Address__c,true);
    }
    
}