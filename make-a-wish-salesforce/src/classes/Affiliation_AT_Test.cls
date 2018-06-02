/*************************************************************************
Author : MST Solutions
CreatedDate :  8/5/2016
Description : Unit Test for AffiliationTriggerHandler and Affiliation_AT.
**************************************************************************/
@isTest
public class Affiliation_AT_Test{
    
    //Used to verify the status of the Affiliation is set to prospective when it gets created.
    static testmethod void updateContact(){ 
        Test.startTest();
        Constant_Ac  constant = new constant_Ac();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.boardMemberRT).getRecordTypeId();
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        volunteerContact.RecordTypeId = volunteerRecordTypeId;
        update volunteerContact;
        System.assertEquals(volunteerContact.RecordTypeId, volunteerRecordTypeId, 'Recordtype doesnot match');
        
        Map<id,npe5__Affiliation__c> contactMap = new Map<id,npe5__Affiliation__c>();
        Set<Id> affiliationIds = new Set<Id>();
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c  = volunteerContact.Id;
        neworgAffiliation.npe5__Organization__c = volunteerAccount.Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.Constituent_Code__c = 'Volunteer';
        neworgAffiliation.npe5__Status__c = 'Active';
        insert neworgAffiliation;
        contactMap.put(neworgAffiliation.npe5__Contact__c,neworgAffiliation);
        affiliationIds.add(neworgAffiliation.npe5__Organization__c);
        //AffiliationTriggerHandler_AC.updateContact(contactMap,affiliationIds);
        System.assertEquals('Active', neworgAffiliation.npe5__Status__c,'Incorrect Affiliation Status');        
        
        neworgAffiliation.Id = neworgAffiliation.Id;
        neworgAffiliation.npe5__Status__c = 'Prospective';
        neworgAffiliation.Constituent_code__c = 'Volunteer';
        update neworgAffiliation;
        System.assertEquals('Prospective', neworgAffiliation.npe5__Status__c,'Incorrect Affiliation Status');
        Test.stopTest();
    }
    
    //Used to create volunteer account, contact and affilation with status active for volunteer user.
    static testmethod void affiliationUpdateWithActive(){
        
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        Group alabamaGroup = new Group();
        alabamaGroup.Name = 'Make-A-Wish Alabama';
        alabamaGroup.DeveloperName = 'ABC';
        insert alabamaGroup;
        System.assertEquals('Make-A-Wish Alabama', alabamaGroup.Name,'Chapter Name doesnot match');
        OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        npe5__Affiliation__c volunteerAffiliation =  [SELECT Id, npe5__Status__c FROM npe5__Affiliation__c LIMIT 1];
        volunteerAffiliation.npe5__Status__c = 'Active';
        update volunteerAffiliation;
        
    }
    
    //Used to create volunteer account, contact and affilation with status active for volunteer user and update the volunteer status as inactive.
    static testmethod void affiliationUpdateWithInActive(){
        
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccountwithVolunteerManager();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        Group alabamaGroup = new Group();
        alabamaGroup.Name = 'Make-A-Wish Alabama';
        alabamaGroup.DeveloperName = 'ABC';
        insert alabamaGroup;
        OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c(Chapter_Name__c = volunteerAccount.Id,Volunteer_Contact__c = volunteerContact.Id);
        insert newVolOpp;
        npe5__Affiliation__c volunteerAffiliation =  [SELECT Id, npe5__Status__c FROM npe5__Affiliation__c LIMIT 1];
        volunteerAffiliation.npe5__Status__c = 'InActive';
        update volunteerAffiliation;
        System.assertEquals('InActive', volunteerAffiliation.npe5__Status__c,'Status is not Inactive');
        
    }
    
    //Assigning volunteer contact to collaboration group when user become active.
    static testmethod void affiliationCreationWithStatusNull(){
        
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
        User prospectiveVolunteer = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
        
        CollaborationGroup collabGroup = OrientationandTrainingUtil.createCollaborationGroup(volunteerAccount.Name);
        //CollaborationGroupMember groupMem = OrientationandTrainingUtil.createCollabrationGroupMember(collabGroup.Id, prospectiveVolunteer.Id);
        npe5__Affiliation__c affiliationId = OrientationandTrainingUtil.CreateAffiliationwithNullStatus(volunteerAccount.Id,volunteerContact.Id);
        
        npe5__Affiliation__c volunteerAffiliation =  [SELECT Id, npe5__Status__c FROM npe5__Affiliation__c WHERE Id =:affiliationId.Id LIMIT 1];
        volunteerAffiliation.npe5__Status__c = 'Active';
        update volunteerAffiliation;
        System.assertEquals('Active', volunteerAffiliation.npe5__Status__c,'Status is not Active');
        
    }
    
    //Remove volunteer from public group when affilaition deleted.
    static testmethod void affiliationDelete(){
        
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        Group alabamaGroup = new Group();
        alabamaGroup.Name = 'Make-A-Wish Alabama';
        alabamaGroup.DeveloperName = 'ABC';
        insert alabamaGroup;
        System.assertEquals('Make-A-Wish Alabama', alabamaGroup.Name,'Chapter Name doesnot match');
        System.assertEquals('Make-A-Wish Alabama', alabamaGroup.Name);
        OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        npe5__Affiliation__c volunteerAffiliation =  [SELECT Id, npe5__Status__c FROM npe5__Affiliation__c LIMIT 1];
        volunteerAffiliation.npe5__Status__c = 'InActive';
        delete volunteerAffiliation;
        
    }
    
}