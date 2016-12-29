@isTest
public class PARTAPDF_Test {
    
 public testmethod static void SignDocument(){  
     Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
     OrientationandTrainingUtil.insertDocusignSetting();
     Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
     newLead.PD_ICD_Code__c = 'C00';
     newLead.PD_Condition_Description__c = 'Malignant Melanoma';
     newLead.SD2_ICD_Code__c = '';
     newLead.SD2_Condition_Description__c = '';
     insert newLead;
       
       PageReference pageRef = Page.LeadPartA_ApprovalForm_VF_Output;
       pageRef.getParameters().put('Id', newLead.id);
       Test.setCurrentPage(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(newLead);
       PARTAPDF testAccPlan = new PARTAPDF(sc);
      
      Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
     Test.StartTest();
     testAccPlan.SubmitSign();
     testAccPlan.cancel();
     Test.StopTest();
           
   
    }
}