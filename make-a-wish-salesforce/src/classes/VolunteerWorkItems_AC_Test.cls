@isTest
public class VolunteerWorkItems_AC_Test {
    
    @testSetup static void setup(){  
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Role__c currNonWishRole = OrientationandTrainingUtil.createNonWishRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.Id);
        Chapter_Role__c  currNonWishChapRole = OrientationandTrainingUtil.createChapter(acc.id,currNonWishRole.Id);
        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.Id);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case newParentWish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Volunteer_Opportunity__c wishVolunteerOpportunity = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id,currChapRole.Id,newParentWish.Id);
        Volunteer_Opportunity__c duplicateWishVolunteerOpportunity = OrientationandTrainingUtil.createDuplicateNewWishVolunteerOpportunity(acc.Id,currChapRole.Id,newParentWish.Id);
        Volunteer_Opportunity__c wishVolunteerOpportunity1 = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id,currChapRole.Id,newParentWish.Id);
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEvent(acc.Id);
        Volunteer_Opportunity__c nonWishVolunteerOpportunity= OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id,currChapRole.Id,nonWishEvent.Id);
        Volunteer_Opportunity__c duplicateNonWishVolunteerOpportunity = OrientationandTrainingUtil.CreateNonWishDuplicateVolunteerOpportunity(acc.Id,currChapRole.Id,nonWishEvent.Id);
        Volunteer_Opportunity__c nonWishVolunteerOpportunity1= OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id,currChapRole.Id,nonWishEvent.Id);
    }
    
    //Used to create and display wish events for volunteer users
    public static testMethod void volunteerWishEvents() {
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        System.RunAs(currUser) {
            PageReference pageref = Page.MyAssignment_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.getVolunteerAssignedWishEvents();
        }
    }
    
    //Used to create and display non wish events for volunteer users
    public static testMethod void volunteerNonWishEvents() {
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        System.RunAs(currUser) {
            PageReference pageref = Page.MyAssignment_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.getVolunteerAssignedNonWishEvents();
        }
    }
    
    //Used to create and display wish events that are assigned to volunteer users
    public static testMethod void volunteerAssignedWishEvents() {
        Constant_AC  constant = new Constant_Ac(); 
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        Volunteer_Opportunity__c wishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c, RecordTypeId FROM Volunteer_Opportunity__c WHERE RecordTypeId =: wishEvents LIMIT 1];
        wishVolunteerOpportunity.Volunteer_Name__c = volunteerContact.Id;
        update wishVolunteerOpportunity;
        System.RunAs(currUser) {
            PageReference pageref = Page.MyAssignment_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.getWishEvents();
        }
    }
    
    //Used to create and display wish events that are not assigned to volunteer users
    public static testMethod void volunteerUnAssignedWishEvents() {
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        System.RunAs(currUser) {
            PageReference pageref = Page.MyAssignment_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.getWishEvents();
        }
    }
    
    //Used to create and display non wish events that are not assigned to volunteer users
    public static testMethod void volunteerAssignedNonWishEvents() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        Volunteer_Opportunity__c nonWishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c FROM Volunteer_Opportunity__c WHERE RecordTypeId =: nonWishEvents LIMIT 1];
        nonWishVolunteerOpportunity.Volunteer_Name__c = volunteerContact.Id;
        update nonWishVolunteerOpportunity;
        System.RunAs(currUser) {
            PageReference pageref = Page.MyAssignment_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.getNonWishEvents();
        }
    }
    
    //Used to create and display non wish events that are un assigned to volunteer users
    public static testMethod void availableNonWishEvents() {
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }        
        System.RunAs(currUser) {
            PageReference pageref = Page.MyAssignment_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.getNonWishEvents();
        }
    }
    
    //Volunteer register for wish events when their role matches the event role
    public static testMethod void registerWishEvent() {
        Constant_AC  constant = new Constant_Ac(); 
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }        
        System.RunAs(currUser) {
            Volunteer_Opportunity__c wishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c, RecordTypeId FROM Volunteer_Opportunity__c WHERE RecordTypeId =: wishEvents LIMIT 1];
            PageReference pageref = Page.VolunteerAssignmentOpportunities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.volunteerOpportunityRecordId = wishVolunteerOpportunity.Id;
            volunteerWorkitems.RegisterWishEvents();
        }
    }
    
    //Volunteer register for wish events when their role does not matches the event role
    public static testMethod void volunteerUnMatchingWishRole() {
        Constant_AC  constant = new Constant_Ac(); 
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        List<Volunteer_Roles__c> getVolunteerRoleList = [SELECT Id FROM Volunteer_Roles__c];
        if(getVolunteerRoleList.size()>0) {
            delete getVolunteerRoleList;
        }
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }        
        System.RunAs(currUser) {
            Volunteer_Opportunity__c wishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c, RecordTypeId FROM Volunteer_Opportunity__c WHERE RecordTypeId =: wishEvents LIMIT 1];
            PageReference pageref = Page.VolunteerAssignmentOpportunities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.volunteerOpportunityRecordId = wishVolunteerOpportunity.Id;
            volunteerWorkitems.RegisterWishEvents();
        }
    }
    
    
    //User registration for simlar events
    public static testMethod void registerDuplicateWishEvent() {
        Constant_AC  constant = new Constant_Ac(); 
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }        
        System.RunAs(currUser) {
            Volunteer_Opportunity__c registerdWishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c, RecordTypeId FROM Volunteer_Opportunity__c WHERE RecordTypeId =: wishEvents AND Volunteer_Name__c = null LIMIT 1];
            registerdWishVolunteerOpportunity.Volunteer_Name__c = volunteerContact.Id;
            update registerdWishVolunteerOpportunity;
            
            Volunteer_Opportunity__c wishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c, RecordTypeId FROM Volunteer_Opportunity__c WHERE RecordTypeId =: wishEvents LIMIT 1];
            PageReference pageref = Page.VolunteerAssignmentOpportunities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.volunteerOpportunityRecordId = wishVolunteerOpportunity.Id;
            volunteerWorkitems.RegisterWishEvents();
        }
    }
    
    
    
    //Volunteer register for non wish events when their role matches the event role
    public static testMethod void nonWishEventsWishRoleVolunteeRegister() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        User currUser;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        System.RunAs(currUser) {
            Volunteer_Opportunity__c nonWishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c FROM Volunteer_Opportunity__c WHERE RecordTypeId =: nonWishEvents AND  Volunteer_Name__c = null LIMIT 1];
            PageReference pageref = Page.VolunteerAssignmentOpportunities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.volunteerOpportunityRecordId = nonWishVolunteerOpportunity.Id;
            volunteerWorkitems.RegisterNonWishEvents();
        }
    }
    
    //Volunteer register for non wish events when their role does not matches the event role
    public static testMethod void unmatchingRoleNonWishRegistration() {
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        User currUser;
        Chapter_Role__c nonWishChapterRole = [SELECT Id, Role_Name__c FROM Chapter_Role__c WHERE Role_Name__r.Name = 'Water Handler' LIMIT 1];
        Volunteer_Roles__c volunteerNonWishWishRole = [SELECT Id, Chapter_Role__c FROM Volunteer_Roles__c LIMIT 1];
        volunteerNonWishWishRole.Chapter_Role__c = nonWishChapterRole.Id;
        update volunteerNonWishWishRole;
        Contact volunteerContact = [SELECT Id FROM Contact  LIMIT 1];
        
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(volunteerContact.id);
        }
        System.RunAs(currUser) {
            Volunteer_Opportunity__c nonWishVolunteerOpportunity = [SELECT Id, Volunteer_Name__c FROM Volunteer_Opportunity__c WHERE RecordTypeId =: nonWishEvents AND  Volunteer_Name__c = null LIMIT 1];
            PageReference pageref = Page.VolunteerAssignmentOpportunities_VF;
            Test.setCurrentPageReference(pageref);
            VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
            volunteerWorkitems.volunteerOpportunityRecordId = nonWishVolunteerOpportunity.Id;
            volunteerWorkitems.RegisterNonWishEvents();
        }
    }
    
}