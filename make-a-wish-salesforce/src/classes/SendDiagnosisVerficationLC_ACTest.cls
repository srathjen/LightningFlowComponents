/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Vignesh SM
Date        : 13/03/2018
Description : Class contains test method for SendDiagnosisVerficationLC_AC.apxc component
*****************************************************************************************************/

@isTest
public class SendDiagnosisVerficationLC_ACTest {
    
    /********************************************************************************************
    Test method for getLeadInformation method    
    ***********************************************************************************************/
    @isTest
    static void getLeadInformation_test(){
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        
        insert newLead;
        Lead retreiveLead = SendDiagnosisVerficationLC_AC.getLeadInformation(newLead.Id);
        System.assertEquals(newLead.Id, retreiveLead.Id);       
    }
    
    /********************************************************************************************
    Test method for resetDVMedicalSummary, findLeadDupe, findFamilyContactDupe  method    
    ***********************************************************************************************/
    @isTest
    static void utilityMethods_test(){
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        
        insert newLead;
        SendDiagnosisVerficationLC_AC.resetDVMedicalSummary(newLead.Id);
        SendDiagnosisVerficationLC_AC.findLeadDupe(newLead.Id);
        SendDiagnosisVerficationLC_AC.findFamilyContactDupe(newLead.Id);
        System.assert(true);
    }
    
    /********************************************************************************************
    Test method for updateLead method    
    ***********************************************************************************************/
    @isTest
    static void updateLead_test(){
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
//SIW-342        newLead.Sub_Status__c = 'Pending Part A';
//insert to appease validation rule
        insert newLead;
        
        newLead.Sub_Status__c = 'Pending Diagnosis Verification';
        update newLead;
//End SIW-342
        
        String result = SendDiagnosisVerficationLC_AC.updateLead(newLead.Id, 'Treating Medical Professional', 0, newLead.Treating_Medical_Professional_Email__c,newLead.Sub_Status__c);
        System.assertEquals('UPDATED', result);
    }
   
}