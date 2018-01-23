/*****************************************************************************
Author : MST Solutions
CreateDate : 09/26/2017
Description : LiabilityForms_AC_Test is used to increase the code coverage for LiabilityForms_AC.
******************************************************************************/
@isTest
public class LiabilityForms_AC_Test {
    
    /*This method is used to cover the code coverage of Constructor method*/
    public static testMethod void CalltheConstructorMethod(){ 
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
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
        PageReference pageRef = Page.LiabilityForms_VF;
        pageRef.getParameters().put('id',String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        LiabilityForms_AC wishLiabilityIns = new LiabilityForms_AC(sc);
        system.AssertEquals(wishChild.Id,wish.ContactId);
        
    }
   }