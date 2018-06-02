/*****************************************************************************
Author : MST Solutions
CreateDate : 03/25/2016
Description : AbsentForm_AC_Test is used to increase the code coverage for AbsentForm_AC.
******************************************************************************/
//
//Created the method named createParentCase - Knagaraj
//Created the method named createParentCaseWithWishChild - Kanagaraj
//
//Created the method named createParentCaseWithWishFamily - Kanagaraj
//The class AbsentForm_AC_Test is used to do the unit testing for functionality
//This class have the 3 methods
//Last updated by kanagarj on 3/14/2018


@isTest
Public class AbsentParentSingleParentForm_AC_Test{
    
    //This method will create relationshiprecord
    //This method will associate the contact with the relationship
    //This methos used to updated the relationship record
    public static testMethod void createParentCase(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactWishParent =  OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishParent.id,contactWishChild.id);
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        npe4__Relationship__c  newRelationShip = new npe4__Relationship__c();
        newRelationShip.Id = relationShip.Id;
        newRelationShip.npe4__Type__c = 'Father';
        newRelationShip.Parent_Legal_Guardian__c = true;
        newRelationShip.Under_18__c = true;
        newRelationShip.Wish_Participant__c = true;
        Update newRelationShip;
        
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.AbsentForm_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        pageRef.getParameters().put('option','Absent_Vf');
        Test.setCurrentPage(pageRef);
        AbsentParentSingleParentForm_AC absentIns = new AbsentParentSingleParentForm_AC(sc);
        absentIns.getRecpList();
        absentIns.getParticipantList();
        List<String> participantNameList = new List<String>();
        absentIns.pageName = 'Absent_Vf';
        absentIns.getRecpList();
        absentIns.getParticipantList();
        absentIns.participantName = 'Test';
        
        /*absentIns.participantNameList.add('kanagaraj');
        absentIns.participantNameList.add('kanagaraj');
        absentIns.participantNameList.add('kanagaraj');*/
        Test.StartTest();
        System.assert(relationShip.npe4__Contact__c .equals(caseId.ContactId),'Check RelatedContact equals to Contact in Case');
        Contact familyContact = [SELECT Id,Name,Email FROM Contact WHERE Id =: contactWishParent.Id];
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        absentIns.recpName = relationShip.Id;
        absentIns.recpEmail = familyContact.Email;
        absentIns.recpRelType = '';
        absentIns.individualName = '';
        absentIns.individualEmail = '';
       
        absentIns.CallouttoDocusign();
        //absentIns.cancel();
        absentIns.updateRelatedContact();
       // absentIns.updateParticipantName();
        absentIns.checkEmail('kana@gmail');
        absentIns.DisplayMessage();
        Test.StopTest();
        
    }
    //Email update for relation ship
    //This method will create the parentcase record and associated with wishchild contact
    //This method will update the relationship record
    public static testMethod void createParentCaseWithWishChild(){
        Map<Id, npe4__Relationship__c> relMap = new Map<Id, npe4__Relationship__c>();
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactWishParent =  OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishChild.id,contactWishParent.id);
        npe4__Relationship__c  newRelationShip = new npe4__Relationship__c();
        newRelationShip.Id = relationShip.Id;
        newRelationShip.npe4__Type__c = 'Mother';
        Update newRelationShip;
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.AbsentForm_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        AbsentParentSingleParentForm_AC absentIns = new AbsentParentSingleParentForm_AC(sc);
        Test.StartTest();
        relMap.put(relationShip.Id, relationShip);
        absentIns.relationShipMap = relMap;
        absentIns.recpName = relationShip.Id;
        System.assert(relationShip.npe4__RelatedContact__c.equals(caseId.ContactId),'Check RelatedContact equals to Contact in Case');
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        absentIns.getRecpList();
        absentIns.displayReturnToWish = true;
        //absentIns.updateRelatedContact();
        absentIns.recpName = relationShip.Id;
        absentIns.recpEmail = contactWishParent.Email;
        absentIns.CallouttoDocusign();
        absentIns.ReturnToWish();
        absentIns.cancel();
        Test.StopTest();
        
    }
    
    //Docusign callout
    //This method will create the parent case wiah the wish family conatct
    //The relationship record will gets updated
    public static testMethod void createParentCaseWithWishFamily(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactWishParent =  OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishChild.id,contactWishParent.id);
        npe4__Relationship__c  newRelationShip = new npe4__Relationship__c();
        newRelationShip.Id = relationShip.Id;
        newRelationShip.npe4__Type__c = 'Legal Guardian';
        newRelationShip.Parent_Legal_Guardian__c = true;
        newRelationShip.Under_18__c = true;
        newRelationShip.Wish_Participant__c = true;
        Update newRelationShip;
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.AbsentForm_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        AbsentParentSingleParentForm_AC absentIns = new AbsentParentSingleParentForm_AC(sc);
        Test.StartTest();
        
        absentIns.ReturnToWish();
        absentIns.displayRelatedInfo();
        System.assert(relationShip.npe4__RelatedContact__c.equals(caseId.ContactId),'Check RelatedContact equals to Contact in Case');
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        absentIns.CallouttoDocusign();
        absentIns.pageName = 'Single_Vf';
        absentIns.ReturnToWishClearanceForm();
        absentIns.cancel();
        Test.StopTest();
    }
    
}