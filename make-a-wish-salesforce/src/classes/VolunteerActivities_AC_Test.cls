/************************************************************************************
Author : Mst Solutions
Created date: 11/21/2016
Description : This class is used to increase the code coverage for VolunteerActivities_AC
*************************************************************************************/
@isTest
public class VolunteerActivities_AC_Test {
    
    @testSetup static void setup(){  
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        User VolcurrUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
    }
    
    //Wish open activities
    static testMethod void openWishActivities() {
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(parentCase.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Not Started';
        update newTask;
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getOpenActivities();
        }
    }
    
    //Non Wish open activities
    static testMethod void openNonActivities() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Volunteer_Opportunity__c newWishOpportunity =  new Volunteer_Opportunity__c();
        newWishOpportunity.RecordTypeId = nonWishEvents;
        newWishOpportunity.Wish__c = parentCase.Id;
        insert newWishOpportunity;
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(newWishOpportunity.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Not Started';
        update newTask;
        
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getOpenActivities();
        }
    }
    
    //Non Wish open activities
    static testMethod void openNonWishActivities() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Non_Wish_Events__c newWishOpportunity =  new Non_Wish_Events__c();
        newWishOpportunity.Event_Name__c = 'Test';
        insert newWishOpportunity;
        Volunteer_Opportunity__c volOpp =  new Volunteer_Opportunity__c();
        volOpp.RecordTypeId = nonWishEvents;
        volOpp.Non_Wish_Event__c = newWishOpportunity.Id;
        insert volOpp;
        
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(volOpp.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Not Started';
        update newTask;
        
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getOpenActivities();
        }
    }
    
    //Non Wish Event Activities
    static testMethod void openNonWishEventActivities() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Non_Wish_Events__c newWishOpportunity =  new Non_Wish_Events__c();
        newWishOpportunity.Event_Name__c = 'Test';
        insert newWishOpportunity;
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(newWishOpportunity.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Not Started';
        update newTask;
        
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getOpenActivities();
        }
    }
    
    
    
    /* Completed Block */
    static testMethod void openWishActivities1() {
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Presentation_Date__c = System.today();
        update parentCase;
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(parentCase.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Completed';
        update newTask;
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getCloseActivities();
        }
    }
    
    //Non Wish open activities
    static testMethod void openNonActivities1() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Volunteer_Opportunity__c newWishOpportunity =  new Volunteer_Opportunity__c();
        newWishOpportunity.RecordTypeId = nonWishEvents;
        newWishOpportunity.Wish__c = parentCase.Id;
        insert newWishOpportunity;
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(newWishOpportunity.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Completed';
        update newTask;
        
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getCloseActivities();
        }
    }
    
    //Non Wish open activities
    static testMethod void openNonWishActivities1() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Non_Wish_Events__c newWishOpportunity =  new Non_Wish_Events__c();
        newWishOpportunity.Event_Name__c = 'Test';
        insert newWishOpportunity;
        Volunteer_Opportunity__c volOpp =  new Volunteer_Opportunity__c();
        volOpp.RecordTypeId = nonWishEvents;
        volOpp.Non_Wish_Event__c = newWishOpportunity.Id;
        insert volOpp;
        
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(volOpp.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Completed';
        update newTask;
        
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getCloseActivities();
        }
    }
    
    //Non Wish Event Activities
    static testMethod void openNonWishEventActivities1() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        User volUser = [SELECT Id, ContactId FROM User WHERE ContactId != null LIMIT 1];
        Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Non_Wish_Events__c newWishOpportunity =  new Non_Wish_Events__c();
        newWishOpportunity.Event_Name__c = 'Test';
        insert newWishOpportunity;
        Task newTask = OrientationandTrainingUtil.wishPresentationNotSet(newWishOpportunity.Id);
        newTask.OwnerId = volUser.Id;
        newTask.Status = 'Completed';
        update newTask;
        
        System.RunAs(volUser) {
            PageReference pageref = Page.VolunteerActivities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
            volunteerWorkitems.getCloseActivities();
        }
    }
    
    
        
}