/*************************************************************************
Author : MST Solutions
CreatedDate :  8/5/2016
Description : Unit Test for AffiliationTriggerHandler and Affiliation_AT.
**************************************************************************/
@isTest
public class Affiliation_AT_Test{
    
    //Used to create volunteer account, contact and affilation with status active for volunteer user.
    static testmethod void affiliationUpdateWithActive(){
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        
        CollaborationGroup collGroup = new CollaborationGroup();
        collGroup.Name = 'Make-A-Wish Alabama';
        collGroup.CollaborationType = 'Private';
        insert collGroup;
        
        Group alabamaGroup = new Group();
        alabamaGroup.Name = 'Make-A-Wish Alabama';
        alabamaGroup.DeveloperName = 'ABC';
        insert alabamaGroup;
        OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        npe5__Affiliation__c volunteerAffiliation =  [SELECT Id, npe5__Status__c FROM npe5__Affiliation__c LIMIT 1];
        volunteerAffiliation.npe5__Status__c = 'Active';
        update volunteerAffiliation;
        
    }
    
    //Assigning volunteer contact to collaboration group when user become active.
    static testmethod void affiliationCreationWithStatusNull(){
       
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
        User prospectiveVolunteer = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
        
        CollaborationGroup collabGroup = OrientationandTrainingUtil.createCollaborationGroup(volunteerAccount.Name);
        collabGroup.Name = 'Alabama - Chapter';
        update collabGroup;
        //CollaborationGroupMember groupMem = OrientationandTrainingUtil.createCollabrationGroupMember(collabGroup.Id, prospectiveVolunteer.Id);
        npe5__Affiliation__c affiliationId = OrientationandTrainingUtil.CreateAffiliationwithNullStatus(volunteerAccount.Id,volunteerContact.Id);
      
        npe5__Affiliation__c volunteerAffiliation =  [SELECT Id, npe5__Status__c FROM npe5__Affiliation__c WHERE Id =:affiliationId.Id];
        volunteerAffiliation.npe5__Status__c = 'Active';
        update volunteerAffiliation;
      
    }
    
    static testmethod void affiliationCreation() {
        Constant_AC  constant = new Constant_Ac();
        Id chapterRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
        
        Account newAccount = new Account();
        newAccount.Name = 'Alabama - Chapter';
        newAccount.RecordTypeId = chapterRecordTypeId;
        insert newAccount;
        
        npe5__Affiliation__c newAffiliation = new npe5__Affiliation__c();
        newAffiliation.npe5__Organization__c = newAccount.Id;
    }
    
    
}