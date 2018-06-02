/***************************************************************************************************
Author      : MST Solutions
Date        : 03/28/2018
Description : Class contains test method for QualifyingDiagnosisLC_AC.apxc component
*****************************************************************************************************/
@isTest
public class QualifyingDiagnosisLC_AC_TEST {
    
    /********************************************************************************************
    Test method for getLeadInformation method    
    ***********************************************************************************************/
    
    testmethod static void getMedicalInformation(){
        Condition_Description__c condistionDescription = OrientationandTrainingUtil.createConditionDesCription();
        insert condistionDescription;
        ICD_Codes__c iCDCode = OrientationandTrainingUtil.createICDCode(condistionDescription.Id);
        insert iCDCode;
        List<Medical_Questions__c> medicalQuestion = OrientationandTrainingUtil.CreateMedicalQuestion(condistionDescription.Id);        
        insert medicalQuestion;  
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.PD_ICD_Code__c = iCDCode.Id;
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';  
        insert newLead;
        Case DVCase = new Case(Lead__c = newLead.Id, Subject = 'Eligibility Review', Status = 'New');
        insert DVCase;
        System.assertEquals(newLead.PD_ICD_Code__c, iCDCode.Id, 'ICD Code doesnot match');
        QualifyingDiagnosisLC_AC.getMedicalInformation(DVCase.Id);
        QualifyingDiagnosisLC_AC.updateQualifyingDiagnosis(condistionDescription.Name, iCDCode.Id, newLead.Id,condistionDescription.PR_Diagnosis__c);
    }
    
}