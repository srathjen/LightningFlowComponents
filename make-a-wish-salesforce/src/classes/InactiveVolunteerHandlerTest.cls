// Created By : MST
// This test class will be used to do unit testing and functionality verifiying
@isTest
public class InactiveVolunteerHandlerTest {
    
    @testSetup static void setup() {
        //OrientationandTrainingUtil.createrSystemAdminUser();
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User prospectiveUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.id);
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Case parentCase = OrientationandTrainingUtil.ParentCasetoAddCaseMember(wishChild.Id);
        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c();
        volOpp.Volunteer_Name__c = volunteerContact.Id;
        volOpp.Chapter_Name__c = chapterAccount.Id;
        volOpp.Chapter_Role_Opportunity__c = chapterRole.Id;
        volOpp.Wish__c = parentCase.id;
        insert volOpp;
        Background_check__c newBgCheck = new Background_check__c();
        newBgCheck.Volunteer__c = volunteerContact.Id;
        newBgCheck.HiddenBackgroundExpire__c = false;
        insert newBgCheck;
        Conflict_Of_Interest__c  coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
    }
    
    
    public testMethod static void inactiveUser() {
        
        List< User> volUser = [SELECT Id, isActive FROM User WHERE Firstname = 'Jonathanan' LIMIT 1];
        if(volUser.size() > 0) {
            volUser[0].isActive = false;
            update volUser[0];
        }
    }
}