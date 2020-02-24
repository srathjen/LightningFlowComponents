/*****************************************************************************************
Created by: Kanagaraj
Author : MST Solutions
CreateDate : 07/09/2018
Description : This class is used to increase the code coverage for FormTrackerAttachment_AC
*******************************************************************************************/

@isTest
Public class FormTrackerAttachment_AC_Test{
    
    static testMethod void calltheConstructorMethod(){ 
        
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact parentGurdianContact =  OrientationandTrainingUtil.CreateWishFamily();
        Contact participantContact =  OrientationandTrainingUtil.CreateWishFamilyparticipant();
        insert chapterAcc;
        insert wishChild;
        insert parentGurdianContact;
        insert participantContact;
        Test.startTest();

        npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id,parentGurdianContact.Id);
        npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id,participantContact.Id);
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
        Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
        RecursiveTriggerHandler.blockBeforeUpdate = true;
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert wish;

        Minor_Participant__c minorParticipantIns = OrientationandTrainingUtil.createMinorParticipanRec(wish.Id);
        insert minorParticipantIns;
        
        Test.StopTest();
        List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildFormRec(wish.id,wishChild,parentGurdianContact,participantContact);
        Insert  wishChildFormIns;
        
        FormTrackerAttachment_AC wishDashBoard = new FormTrackerAttachment_AC();
        List<Minor_Participant__c> participantList = FormTrackerAttachment_AC.attachmentLists(wish.Id);
        string result = FormTrackerAttachment_AC.syncFileAttachment(wish.Id);
        //Id saveAttachmentIds = FormTrackerAttachment_AC.saveTheFile(wish.Id,'test Form','test','test');
        string comboconfigValue = '{"recordId":"'+wish.Id+'","currentpageName":"WishGranting_VF","MinorparticipantName":"Mother Name","MinorparticipantEmail":"kanagaraj@mstsolutions.com","FormName":"Liability Form","associated":"self","documentTitle" :"mr","selectedFormat":"Paper","pageSrc":"upload","fileId":"","recordId":"'+wish.Id+'","fileName":"test","base64Data" :"test","contentType":"test"}';
        Id attachmentId = FormTrackerAttachment_AC.saveFileAttachment(comboconfigValue);
        string removeattachmentRec = FormTrackerAttachment_AC.removeAttachment(minorParticipantIns.Id,wish.Id);
    }
    
    static testMethod void removeAttachmentRec(){ 
        
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact parentGurdianContact =  OrientationandTrainingUtil.CreateWishFamily();
        Contact participantContact =  OrientationandTrainingUtil.CreateWishFamilyparticipant();
        Test.startTest();
        npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id,parentGurdianContact.Id);
        npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id,participantContact.Id);
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
        Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
        RecursiveTriggerHandler.blockBeforeUpdate = true;
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Minor_Participant__c minorParticipantIns = OrientationandTrainingUtil.createMinorParticipanRec(wish.Id);
        insert minorParticipantIns;
        cg__CaseFile__c cgcaseFile = OrientationandTrainingUtil.wishFormCaseFileRecord(wish.Id);
        Test.StopTest();
        List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildFormRec(wish.id,wishChild,parentGurdianContact,participantContact);
        Insert  wishChildFormIns;
        
        FormTrackerAttachment_AC wishDashBoard = new FormTrackerAttachment_AC();
        List<Minor_Participant__c> participantList = FormTrackerAttachment_AC.attachmentLists(wish.Id);
        string result = FormTrackerAttachment_AC.syncFileAttachment(wish.Id);
        string removeattachmentRec = FormTrackerAttachment_AC.removeAttachment(minorParticipantIns.Id,wish.Id);
    }
}