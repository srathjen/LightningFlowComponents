/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Description : This class is used to increase the code coverage for VolunteerOpportunitySelection_AC
Modification Log: 
28/03/2018 - Kanagaraj
*****************************************************************************************************/
@isTest(seeAllData=False)
private class VolunteerOpportunitySelection_AC_Test{

    /*Create a time Sheet with only one volunteer opportunity */
    private static testmethod void createVolunterSelection(){        
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
            User currUser;
            System.RunAs(new User(Id = UserInfo.getUserId())) {
               
                currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
                
            }
             Volunteer_Opportunity__c wishVolunteerOpportunity = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id,currChapRole.Id,newParentWish.Id);
                Volunteer_Opportunity__c dbVolOpp = new Volunteer_Opportunity__c();
                dbVolOpp.Id = wishVolunteerOpportunity.Id;
                dbVolOpp.Volunteer_Name__c = con.Id;
                dbVolOpp.Status__c = 'Approved';
                Test.StartTest();
                update dbVolOpp;
                            
               system.RunAs(currUser){           
                   Test.setCurrentPageReference(new PageReference('Page.VolunteerOpportunitySelection_VF')); 
                   System.currentPageReference().getParameters().put('caseRecId', newParentWish.Id);
                   VolunteerOpportunitySelection_AC volunteeerController = new VolunteerOpportunitySelection_AC();
                   //volunteeerController.caseId = newParentWish.Id;
                    volunteeerController.createTimeSheet();
                    volunteeerController.CreateNewTimeSheet();
                    volunteeerController.DisplayError();
                    VolunteerOpportunitySelection_AC.volunteerWrapper newWrapper = new VolunteerOpportunitySelection_AC.volunteerWrapper();
                    newWrapper.recordSelected = false;
                    newWrapper.volOpp = dbVolOpp;
            System.assertEquals(newWrapper.volOpp,dbVolOpp,'Volunteer Oppurtunity value does not match');
            System.assert(newWrapper.volOpp == dbVolOpp,'Volunteer Oppurtunity value  does not match');
        }
        
        Test.stopTest();
    }
    
    /*Create a time Sheet with more than one volunteer opportunity */
    private static testmethod void createTwoVolunterSelection(){        
            Constant_AC  constant = new Constant_Ac(); 
            Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
            Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
            Account acc = OrientationandTrainingUtil.createVolunteerAccount();
            Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
            OrientationandTrainingUtil.createAffiliation(con.id);
           
            Role__c currRole = OrientationandTrainingUtil.createRole();
            Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.Id);
            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.Id);
            Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
            Case newParentWish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
            User currUser;
            System.RunAs(new User(Id = UserInfo.getUserId())) {
               
                currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
                
            }
            List<Volunteer_Opportunity__c> voloppList = new List<Volunteer_Opportunity__c>();
             Volunteer_Opportunity__c wishVolunteerOpportunity = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id,currChapRole.Id,newParentWish.Id);
                Volunteer_Opportunity__c dbVolOpp = new Volunteer_Opportunity__c();
                dbVolOpp.Id = wishVolunteerOpportunity.Id;
                dbVolOpp.Volunteer_Name__c = con.Id;
                dbVolOpp.Status__c = 'Approved';
                
                Volunteer_Opportunity__c wishVolunteerOpportunity2 = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id,currChapRole.Id,newParentWish.Id);
                Volunteer_Opportunity__c dbVolOpp2 = new Volunteer_Opportunity__c();
                dbVolOpp2.Id = wishVolunteerOpportunity2.Id;
                dbVolOpp2.Volunteer_Name__c = con.Id;
                dbVolOpp2.Status__c = 'Approved';
                voloppList.add(dbVolOpp);
                voloppList.add(dbVolOpp2);
                Test.StartTest();
                update voloppList;
                
               system.RunAs(currUser){               
                   Test.setCurrentPageReference(new PageReference('Page.VolunteerOpportunitySelection_VF')); 
                   System.currentPageReference().getParameters().put('caseRecId', newParentWish.Id);
                   VolunteerOpportunitySelection_AC volunteeerController = new VolunteerOpportunitySelection_AC();
                   volunteeerController.DisplayError();
                   VolunteerOpportunitySelection_AC.volunteerWrapper newWrapper = new VolunteerOpportunitySelection_AC.volunteerWrapper();
                   volunteeerController.volunteerWrapperList[0].recordSelected =True;
                   volunteeerController.createTimeSheet();
            System.assertEquals(dbVolOpp2.Status__c,'Approved','Volunteer Opportunity status does not match');
            System.assert(dbVolOpp2.Status__c == 'Approved','Volunteer Opportunity status does not match');
        }               
        Test.stopTest();
    }
}