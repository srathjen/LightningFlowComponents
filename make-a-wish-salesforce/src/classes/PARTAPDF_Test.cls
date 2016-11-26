@isTest
public class PARTAPDF_Test {
    
    public testmethod static void SignDocument(){  
        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.PD_ICD_Code__c = 'C00';
        newLead.PD_Condition_Description__c = 'Malignant Melanoma';
        newLead.SD2_ICD_Code__c = '';
        newLead.SD2_Condition_Description__c = '';
        newLead.Medical_Questions__c = 'Sample<br> sdsdsds<br> sdsdsdsds<br>';
        newLead.Current_Condition__c = 'I am not sure;';
        insert newLead;
        
        Condition_Description__c conditionDesc = new Condition_Description__c();
        conditionDesc.Name = 'Intractable Epileptic Spasms with status epilepticus';
        insert conditionDesc;
        
        Medical_Questions__c mediQes = new Medical_Questions__c();
        mediQes.Question__c = 'Please choose the type of Epilepsy that most closely represents [Insert child\'s name]:';
        mediQes.Data_Type__c = 'Picklist';
        mediQes.Condition_Description__c = conditionDesc.Id;
        mediQes.Picklist_values__c = 'Localization-related (focal) (partial) symptomatic epilepsy and epileptic syndromes with simple partial seizures,Localization-related (focal) (partial) symptomatic epilepsy and epileptic syndromes with complex partial seizures,Generalized idiopathic epilepsy and epileptic syndromes,Lennox-Gastaut Syndrome,Epileptic Spasms,None of these describe child';
        mediQes.Epilepsy_picklist__c = 'Intractable with status epilepticus,Not Intractable';
        insert mediQes;
        
        Diagnosis_Verification__c diagVerRec = new Diagnosis_Verification__c();
        diagVerRec.ICD_Code__c = 'C00';
        diagVerRec.Primary_Diagnosis__c = 'Malignant Neoplasm';
        diagVerRec.Lead__c = newLead.Id;
        diagVerRec.Medical_Question__c = mediQes.Id;
        insert diagVerRec;
        
        DocuSignCredentialsSetting__c docCred = new DocuSignCredentialsSetting__c();
        docCred.Name = 'Test123';
        docCred.account__c = '121213';
        docCred.end_Point__c = 'jhjh';
        docCred.IntegratorKey__c = 'Test12121';
        docCred.Password__c = 'sdsdsd';
        insert docCred;
        
        PageReference pageRef = Page.LeadPartA_ApprovalForm_VF_Output;
        pageRef.getParameters().put('Id', newLead.id);
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        Test.StartTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(newLead);
        PARTAPDF testAccPlan = new PARTAPDF(sc);
        testAccPlan.SubmitSign();
        testAccPlan.cancel();
        Test.StopTest();
        
    }
}