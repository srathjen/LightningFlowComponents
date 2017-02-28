/*****************************************************************************
Author : MST Solutions
CreateDate : 14/11/2016
Description : WishLiabilityForm_AC_Test is used to increase the code coverage for WishLiabilityForm_AC.
******************************************************************************/
 @isTest
public class WishLiabilityForm_AC_Test {

    /*This method is used to cover the code coverage of Constructor method*/
    static testMethod void CalltheConstructorMethod(){ 
      Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
     /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
      Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
      Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
      List<Contact> WishFamilyContactList = OrientationandTrainingUtil.CreateWishFamilyList(3);
      insert WishFamilyContactList;
      List<npe4__Relationship__c> npe4RelationShipList = OrientationandTrainingUtil.relationshipChildList(WishFamilyContactList,wishChild.Id,3);
      insert npe4RelationShipList;
      case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
      wish.Hidden_Email_List__c = 'MAWAFirstName MAWALastName1,MAWAFirstName MAWALastName2';
      wish.Hidden_Name_List__c = 'kesavkumar@mstsolutions.com,kanagaraj@mstsolutions.com';
      update wish;
      Wish_Child_Form__c childForm  = OrientationandTrainingUtil.createWishChildForm(wish.Id);
      insert childForm; 
      OrientationandTrainingUtil.insertDocusignSetting();
      ApexPages.StandardController sc = new ApexPages.StandardController(wish);
      PageReference pageRef = Page.WishLiabilityForm_VF;
      pageRef.getParameters().put('id',String.valueOf(wish.Id));
      Test.setCurrentPage(pageRef);
      WishLiabilityForm_AC wishLiabilityIns = new WishLiabilityForm_AC(sc);
      system.AssertEquals(wishChild.Id,wish.ContactId);
      
   }
   
   
    /*This method is used to cover the code coverage of Constructor else condition method*/
    static testMethod void CalltheConstructorMethodError(){ 
      Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
      /*Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
      Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
      Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
      Contact WishFamilyContact = OrientationandTrainingUtil.CreateWishFamily();
     
      npe4__Relationship__c npe4RelationShip = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,WishFamilyContact.Id);
      
      case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
      wish.Hidden_Email_List__c = 'MAWAFirstName MAWALastName1,MAWAFirstName MAWALastName2';
      wish.Hidden_Name_List__c = 'kesavkumar@mstsolutions.com,kanagaraj@mstsolutions.com';
      update wish;
      Wish_Child_Form__c childForm  = OrientationandTrainingUtil.createWishChildForm(wish.Id);
      insert childForm; 
      OrientationandTrainingUtil.insertDocusignSetting();
      ApexPages.StandardController sc = new ApexPages.StandardController(wish);
      PageReference pageRef = Page.WishLiabilityForm_VF;
      pageRef.getParameters().put('id',String.valueOf(wish.Id));
      Test.setCurrentPage(pageRef);
      WishLiabilityForm_AC wishLiabilityIns = new WishLiabilityForm_AC(sc);
      system.AssertEquals(wishChild.Id,wish.ContactId);
   }
   
   /*This method is used to cover the code coverage of multiEmail() and CallOuttoDocusign() method.*/
    static testMethod void SendDocusigntoEmail(){ 
      Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
     /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
      Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
      Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
      List<Contact> WishFamilyContactList = OrientationandTrainingUtil.CreateWishFamilyList(3);
      insert WishFamilyContactList;
      List<npe4__Relationship__c> npe4RelationShipList = OrientationandTrainingUtil.relationshipChildList(WishFamilyContactList,wishChild.Id,3);
      insert npe4RelationShipList;
      case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
      wish.Hidden_Email_List__c = 'MAWAFirstName MAWALastName1,MAWAFirstName MAWALastName2';
      wish.Hidden_Name_List__c = 'kesavkumar@mstsolutions.com,kanagaraj@mstsolutions.com';
      update wish;
      Wish_Child_Form__c childForm  = OrientationandTrainingUtil.createWishChildForm(wish.Id);
      insert childForm; 
      OrientationandTrainingUtil.insertDocusignSetting();
      ApexPages.StandardController sc = new ApexPages.StandardController(wish);
      PageReference pageRef = Page.WishLiabilityForm_VF;
      pageRef.getParameters().put('id',String.valueOf(wish.Id));
      Test.setCurrentPage(pageRef);
      WishLiabilityForm_AC wishLiabilityIns = new WishLiabilityForm_AC(sc);
      wishLiabilityIns.isFirstParentSendEmail = false;
      wishLiabilityIns.isFirstParent = false;
      wishLiabilityIns.multiEmail();
      List<String>  emailList = new List<String>{'MAWAFirstName MAWALastName0','MAWAFirstName MAWALastName1','MAWAFirstName MAWALastName2'};
      wishLiabilityIns.emailList = emailList;
      wishLiabilityIns.sendpdftoEmail();
      
      Map<String,String> sendEmailMap = new Map<String,String>();
          sendEmailMap.put('MAWAFirstName MAWALastName0', 'vennila@mstsolutions.com');
          sendEmailMap.put('MAWAFirstName MAWALastName1', 'kesavkumar@mstsolutions.com');
          sendEmailMap.put('MAWAFirstName MAWALastName2', 'kanagaraj@mstsolutions.com');
      
          Test.StartTest();
          Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
          WishLiabilityForm_AC.CallOuttoDocusign(sendEmailMap,wish.Id);
          wishLiabilityIns.redirect();
          Test.StopTest();
    system.AssertEquals(wishChild.Id,wish.ContactId);
    }
    
     /*This method is used to cover the code coverage of multiEmail() else condition.*/
     static testMethod void SendDocusigntoEmailError(){ 
      Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
     /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
      Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
      Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
      List<Contact> WishFamilyContactList = OrientationandTrainingUtil.CreateWishFamilyList(3);
      insert WishFamilyContactList;
      List<npe4__Relationship__c> npe4RelationShipList = OrientationandTrainingUtil.relationshipChildList(WishFamilyContactList,wishChild.Id,3);
      insert npe4RelationShipList;
      case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
      wish.Hidden_Email_List__c = 'MAWAFirstName MAWALastName1,MAWAFirstName MAWALastName2';
      wish.Hidden_Name_List__c = 'kesavkumar@mstsolutions.com,kanagaraj@mstsolutions.com';
      update wish;
      Wish_Child_Form__c childForm  = OrientationandTrainingUtil.createWishChildForm(wish.Id);
      insert childForm; 
      OrientationandTrainingUtil.insertDocusignSetting();
      ApexPages.StandardController sc = new ApexPages.StandardController(wish);
      PageReference pageRef = Page.WishLiabilityForm_VF;
      pageRef.getParameters().put('id',String.valueOf(wish.Id));
      Test.setCurrentPage(pageRef);
      WishLiabilityForm_AC wishLiabilityIns = new WishLiabilityForm_AC(sc);
      wishLiabilityIns.multiEmail();
      
      Map<String,String> sendEmailMap = new Map<String,String>();
          sendEmailMap.put('MAWAFirstName MAWALastName0', 'vennila@mstsolutions.com');
          sendEmailMap.put('MAWAFirstName MAWALastName1', 'kesavkumar@mstsolutions.com');
          sendEmailMap.put('MAWAFirstName MAWALastName2', 'kanagaraj@mstsolutions.com');
      
          Test.StartTest();
          Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
          WishLiabilityForm_AC.CallOuttoDocusign(sendEmailMap,wish.Id);
          wishLiabilityIns.redirect();
          Test.StopTest();
    system.AssertEquals(wishChild.Id,wish.ContactId);
    }
    
    
    /*This method is used to cover the code coverage of SignNowmultiEmail() and SubmitAndSign() method.*/
    static testMethod void SignDocusignNow(){
        
      Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
     /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
      Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/
      Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
      List<Contact> WishFamilyContactList = OrientationandTrainingUtil.CreateWishFamilyList(3);
      insert WishFamilyContactList;
      List<npe4__Relationship__c> npe4RelationShipList = OrientationandTrainingUtil.relationshipChildList(WishFamilyContactList,wishChild.Id,3);
      insert npe4RelationShipList;
      case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
      wish.Hidden_Email_List__c = 'MAWAFirstName MAWALastName1,MAWAFirstName MAWALastName2';
      wish.Hidden_Name_List__c = 'kesavkumar@mstsolutions.com,kanagaraj@mstsolutions.com';
      update wish;
      OrientationandTrainingUtil.insertDocusignSetting();
      Wish_Child_Form__c childForm  = OrientationandTrainingUtil.createWishChildForm(wish.Id);
      insert childForm;  
      
      ApexPages.StandardController sc = new ApexPages.StandardController(wish);
      PageReference pageRef = Page.WishLiabilityForm_VF;
      pageRef.getParameters().put('id',String.valueOf(wish.Id));
      Test.setCurrentPage(pageRef);
      WishLiabilityForm_AC wishLiabilityIns = new WishLiabilityForm_AC(sc);
      wishLiabilityIns.multiEmail();
      Map<String,String> sendEmailMap = new Map<String,String>();
          sendEmailMap.put('MAWAFirstName MAWALastName0', 'vennila@mstsolutions.com');
          sendEmailMap.put('MAWAFirstName MAWALastName1', 'kesavkumar@mstsolutions.com');
          sendEmailMap.put('MAWAFirstName MAWALastName2', 'kanagaraj@mstsolutions.com');
          Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
          wishLiabilityIns.SignNowmultiEmail();
          Test.StartTest();
          wishLiabilityIns .SubmitAndSign();
          Test.StopTest();
          
       system.AssertEquals(wishChild.Id,wish.ContactId);
    }
  }