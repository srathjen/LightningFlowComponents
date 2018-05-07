/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for RecallApprovalRest Class
*************************************************************************************/

@istest
public class RecallApprovalRest_AC_Test {
    
    //Test class for recalling single volunteer opportunity from approval
    static testMethod void  singleVolOppRecallApproval(){
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        
        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c(Wish__c = parentCase.Id, Chapter_Role_Opportunity__c = chapterRole.Id);
        insert volOpp;
        
        volOpp.Volunteer_Name__c = VolunteerContact.Id;
        update volOpp;
        
        
        Test.startTest();
        RecallApprovalRest_AC reqst = new RecallApprovalRest_AC();
        String JsonMsg = JSON.serialize(reqst);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/recalApproval/'+volOpp.Id;  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        RecallApprovalRest_AC.getBackApproval();
        
        Test.stopTest();
        
    }
    
    //Test class for recalling multiple volunteer opportunity from approval
    static testMethod void  multipleVolOppRecall(){
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        
        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c(Wish__c = parentCase.Id, Chapter_Role_Opportunity__c = chapterRole.Id);
        insert volOpp;
        volOpp.Volunteer_Name__c = VolunteerContact.Id;
        update volOpp;
        
        Volunteer_Opportunity__c volOpp1 = new Volunteer_Opportunity__c(Wish__c = parentCase.Id, Chapter_Role_Opportunity__c = chapterRole.Id);
        insert volOpp1;
        volOpp1.Volunteer_Name__c = VolunteerContact.Id;
        update volOpp1;
        
        
        Test.startTest();
        RecallApprovalRest_AC reqst = new RecallApprovalRest_AC();
        String JsonMsg = JSON.serialize(reqst);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/recalApproval/'+volOpp.Id+','+volOpp1.Id;  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        RecallApprovalRest_AC.getBackApproval();
        
        Test.stopTest();
        
    }
    
}