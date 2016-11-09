@isTest
public class DiagnosisVerification_AC_Test{

  
     public static testMethod void testmethodone(){
       
         Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Condition_Description__c newdesc = OrientationandTrainingUtil.createConditionDesCription();
         insert newdesc;
         Medical_Questions__c mediQues = OrientationandTrainingUtil.CreateMedicalQuestion(newdesc.Id);
         insert mediQues;
        ICD_Codes__c  icdCode = OrientationandTrainingUtil.createICDCode(newdesc.Id);
        insert icdCode;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
         newLead.PD_ICD_Code__c = 'C00';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        insert newLead;
        Diagnosis_Verification__c  diagVerification = OrientationandTrainingUtil.createDiagnosis(newLead.Id, mediQues.Id);
        insert diagVerification;
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId',newLead.Id);
        DiagnosisVerification_AC diagosis = new DiagnosisVerification_AC();
        diagosis.epilepsyVal = 'test';
        //diagnosis.wrapCls.selectedPrimaryDiagnosis = 'Malignant Melanoma';
        diagosis.mulCon1 = 'test';
        diagosis.epilepsyPick = 'test';
        diagosis.epilepsyRadio = 'test';
        diagosis.wrapCls.describePatient = '1';
        diagosis.init();
        diagosis.submit();
         DiagnosisVerification_AC.medicalWrapper testIns = new DiagnosisVerification_AC.medicalWrapper(mediQues, 'Malignant Melanoma', 'C00', 1);
         
         diagosis.wrapCls.selectedPrimaryDiagnosis = 'Malignant Melanoma';
        diagosis.primaryDiagnosisEligibility();
         
        diagosis.changePatientValue();
        diagosis.notEligibleWish();
         diagosis.wrapCls.diagnosisFilterVal1 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition1();
         diagosis.wrapCls.diagnosisFilterVal2 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition2();
        diagosis.vegitativeId();
         diagosis.wrapCls.diagnosisFilterVal3 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition3(); 
         diagosis.wrapCls.diagnosisFilterVal4 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition4();
         diagosis.wrapCls.ansForQes = 'Yes';
        diagosis.groupQuestions();
         diagosis.wrapCls.ansForQes1 = 'Yes';
        diagosis.groupQuestions1();
         diagosis.wrapCls.ansForQes2 = 'Yes';
        diagosis.groupQuestions2();
         diagosis.wrapCls.ansForQes3 = 'Yes';
        diagosis.groupQuestions3();
         diagosis.wrapCls.ansForQes4 = 'Yes';
         diagosis.groupQuestions4();
        diagosis.getPickListYesNo();
        diagosis.getStateRecognizationPicklistValues();
        diagosis.getPickListYesNoDontno();
        diagosis.getCardioPicklist();
        diagosis.getConvulsionsPicklist();
        diagosis.getHealthCareWorks();
        diagosis.getCommunications();
        diagosis.getMonth();
        diagosis.getYear();
        diagosis.epilepsy();
        diagosis.groupQuestions4();
        diagosis.SaveMedicalInfo();
        diagosis.SaveMedicalInfo1();
        diagosis.updateLeadDetails();
        //diagosis.medicalWrapper.MediacalQuestions();
        diagosis.docusignRedirect();
         
        
     }
    
    public static testMethod void testmethodone2(){
       
         Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Condition_Description__c newdesc = OrientationandTrainingUtil.createConditionDesCription();
         insert newdesc;
         Medical_Questions__c mediQues = OrientationandTrainingUtil.CreateMedicalQuestion(newdesc.Id);
         insert mediQues;
        ICD_Codes__c  icdCode = OrientationandTrainingUtil.createICDCode(newdesc.Id);
        insert icdCode;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.PD_ICD_Code__c = 'C00';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
         newLead.SD2_ICD_Code__c = '';
        newLead.SD2_Condition_Description__c = '';
        insert newLead;
        Diagnosis_Verification__c  diagVerification = OrientationandTrainingUtil.createDiagnosis(newLead.Id, mediQues.Id);
        insert diagVerification;
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId',newLead.Id);
        DiagnosisVerification_AC diagosis = new DiagnosisVerification_AC();
        diagosis.epilepsyVal = 'test';
        //diagnosis.wrapCls.selectedPrimaryDiagnosis = 'Malignant Melanoma';
        diagosis.mulCon1 = 'test';
        diagosis.epilepsyPick = 'test';
        diagosis.epilepsyRadio = 'test';
        diagosis.wrapCls.describePatient = '1';
        diagosis.init();
        diagosis.submit();
         diagosis.wrapCls.selectedPrimaryDiagnosis = 'Malignant Melanoma';
        diagosis.primaryDiagnosisEligibility();
         
        diagosis.changePatientValue();
        diagosis.notEligibleWish();
         diagosis.wrapCls.diagnosisFilterVal1 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition1();
         diagosis.wrapCls.diagnosisFilterVal2 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition2();
        diagosis.vegitativeId();
         diagosis.wrapCls.diagnosisFilterVal3 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition3(); 
         diagosis.wrapCls.diagnosisFilterVal4 = 'Malignant Melanoma';
        diagosis.otherDiagnosisEligibilityCondition4();
        diagosis.wrapCls.ansForQes = 'No';
        diagosis.groupQuestions();
         diagosis.wrapCls.ansForQes1 = 'No';
        diagosis.groupQuestions1();
         diagosis.wrapCls.ansForQes2 = 'No';
        diagosis.groupQuestions2();
         diagosis.wrapCls.ansForQes3 = 'No';
        diagosis.groupQuestions3();
         diagosis.wrapCls.ansForQes4 = 'No';
         diagosis.groupQuestions4();
        diagosis.getPickListYesNo();
        diagosis.getStateRecognizationPicklistValues();
        diagosis.getPickListYesNoDontno();
        diagosis.getCardioPicklist();
        diagosis.getConvulsionsPicklist();
        diagosis.getHealthCareWorks();
        diagosis.getCommunications();
        diagosis.getMonth();
        diagosis.getYear();
        diagosis.epilepsy();
        diagosis.groupQuestions4();
        diagosis.SaveMedicalInfo();
        diagosis.SaveMedicalInfo1();
        diagosis.updateLeadDetails();
        //diagosis.medicalWrapper.MediacalQuestions();
        diagosis.docusignRedirect();
        diagosis.wishStatus();
        diagosis.epilepsyClass = 'epilepsyRadio';
        diagosis.epilepsyVal = 'Not Intractable';
        diagosis.wrapCls.describePatient = '3';
        diagosis.epilepsy();
        String searchTerm = 'C00';
        DiagnosisVerification_AC.searchDiagnosis(searchTerm);
        DiagnosisVerification_AC.searchDiagnosis1(searchTerm);
        DiagnosisVerification_AC.searchCondition(searchTerm);
        
     }
    
    public static testMethod void testmethodone1(){
       
         Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Condition_Description__c newdesc = OrientationandTrainingUtil.createConditionDesCription();
         insert newdesc;
         Medical_Questions__c mediQues = OrientationandTrainingUtil.CreateMedicalQuestion(newdesc.Id);
         //insert mediQues;
        ICD_Codes__c  icdCode = OrientationandTrainingUtil.createICDCode(newdesc.Id);
        insert icdCode;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.PD_ICD_Code__c = 'C00';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
         newLead.SD3_ICD_Code__c = '';
        newLead.SD3_Condition_Description__c = '';
        
        insert newLead;
        Diagnosis_Verification__c  diagVerification = OrientationandTrainingUtil.createDiagnosis( mediQues.Id);
        insert diagVerification;
        PageReference pageRef = Page.DiagnosisVerification_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId',newLead.Id);
        DiagnosisVerification_AC diagosis = new DiagnosisVerification_AC();
        diagosis.epilepsyVal = 'test';
        //diagnosis.wrapCls.selectedPrimaryDiagnosis = 'Malignant Melanoma';
        diagosis.mulCon1 = 'test';
        diagosis.epilepsyPick = 'test';
        diagosis.epilepsyRadio = 'test';
        diagosis.wrapCls.describePatient = '1';
        diagosis.init();
        diagosis.submit();
         diagosis.wrapCls.selectedPrimaryDiagnosis = 'Test';
        diagosis.primaryDiagnosisEligibility();
         
        diagosis.changePatientValue();
        diagosis.notEligibleWish();
         diagosis.wrapCls.diagnosisFilterVal1 = 'Test';
        diagosis.otherDiagnosisEligibilityCondition1();
         diagosis.wrapCls.diagnosisFilterVal2 = 'Test';
        diagosis.otherDiagnosisEligibilityCondition2();
        diagosis.vegitativeId();
         diagosis.wrapCls.diagnosisFilterVal3 = 'Test';
        diagosis.otherDiagnosisEligibilityCondition3(); 
         diagosis.wrapCls.diagnosisFilterVal4 = 'Test';
        diagosis.otherDiagnosisEligibilityCondition4();
        diagosis.groupQuestions();
        diagosis.groupQuestions1();
        diagosis.groupQuestions2();
        diagosis.groupQuestions3();
        diagosis.getPickListYesNo();
        diagosis.getStateRecognizationPicklistValues();
        diagosis.getPickListYesNoDontno();
        diagosis.getCardioPicklist();
        diagosis.getConvulsionsPicklist();
        diagosis.getHealthCareWorks();
        diagosis.getCommunications();
        diagosis.getMonth();
        diagosis.getYear();
        diagosis.epilepsy();
        diagosis.groupQuestions4();
        diagosis.SaveMedicalInfo();
        diagosis.SaveMedicalInfo1();
        diagosis.updateLeadDetails();
        //diagosis.medicalWrapper.MediacalQuestions();
        diagosis.docusignRedirect();
         
        
     }

}