/*****************************************************************************
Author : MST Solutions
CreateDate : 09/27/2017
Description : Entertainment_AC_Test is used to increase the code coverage for Entertainment_AC.
******************************************************************************/

@isTest
Public class Entertainment_AC_Test{
    
    //Relation ship record creation
    public static testMethod void createParentCase(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactWishParent =  OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishChild.id,contactWishParent.id);
        npe4__Relationship__c  newRelationShip = new npe4__Relationship__c();
        newRelationShip.Id = relationShip.Id;
        newRelationShip.npe4__Type__c = 'Father';
        Update newRelationShip;
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.Entertainment_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        Entertainment_AC absentIns = new Entertainment_AC(sc);
        Test.StartTest();
        System.assertEquals(relationShip.npe4__RelatedContact__c, caseId.ContactId);
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        absentIns.CallouttoDocusign();
        absentIns.cancel();
        absentIns.getRecpList();
        absentIns.DisplayMessage();
        Test.StopTest();
        
    }
    //Email update for relation ship
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
        PageReference pageRef = Page.Entertainment_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        Entertainment_AC absentIns = new Entertainment_AC(sc);
        Test.StartTest();
        relMap.put(relationShip.Id, relationShip);
        absentIns.relationShipMap = relMap;
        absentIns.recpName = relationShip.Id;
        System.assertEquals(relationShip.npe4__RelatedContact__c, caseId.ContactId);
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
    public static testMethod void createParentCaseWithWishFamily(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactWishParent =  OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishChild.id,contactWishParent.id);
        npe4__Relationship__c  newRelationShip = new npe4__Relationship__c();
        newRelationShip.Id = relationShip.Id;
        newRelationShip.npe4__Type__c = 'Legal Guardian';
        Update newRelationShip;
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.Entertainment_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        Entertainment_AC absentIns = new Entertainment_AC(sc);
        Test.StartTest();
        absentIns.ReturnToWish();
        absentIns.displayRelatedInfo();
        System.assertEquals(relationShip.npe4__RelatedContact__c, caseId.ContactId);
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        absentIns.CallouttoDocusign();
        absentIns.ReturnToWishClearanceForm();
        absentIns.cancel();
        Test.StopTest();
        
    }
    
}