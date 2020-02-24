@isTest
public class LeadTriggerHandler_Test{
    public testmethod static void UpdateStatusDNQ(){
    User currUser = [SELECT Id FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        User nationalStaff;
        RecursiveTriggerHandler.isFirstTime = True;
        System.RunAs(currUser) {
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
            insert nationalStaff;
        }

        Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAccount;

        Contact medicalProfessionalCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        insert medicalProfessionalCon;

        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        insert wishFamily;

        chapterAccount.Intake_Manager__c = nationalStaff.Id;
        update chapterAccount;

        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.ChapterName__c = chapterAccount.Id;
        // newLead.OwnerId =nationalStaff.Id;
        newLead.status = 'Inquiry';
        insert newLead;

        System.assertequals(chapterAccount.Id,[SELECT ChapterName__r.Name FROM Lead WHERE Id =: newlead.Id].ChapterName__c);
        System.assertequals('Referred',[SELECT Status FROM lead WHERE Id =: newLead.Id].Status);

        RecursiveTriggerHandler.isFirstTime = true;
        newlead.Qualifying_Diagnosis__c  = 'Test';
        newLead.Will_Child_s_Condition_Deteriorate__c = 'No';
        newLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
        newLead.Is_in_a_Comatose_Vegetative_State__c = 'No';

		newLead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
		newLead.Any_medical_reason_for_moving_quickly__c = 'No';
        newLead.Part_A_Received__c = System.today();
        newLead.Sub_Status__c = 'Age';
        newlead.Status= 'DNQ';
        //updateLeadStatus.Id = newlead.Id;
        update newlead;

        System.assertequals('DNQ',[SELECT status FROM lead WHERE Id =: newlead.Id].Status);
    }
}