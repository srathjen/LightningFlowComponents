@isTest
Public class LeadWishFamilyDupe_Test
{

   static testmethod void createRecords()
   {
     Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
     Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
     Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
     newLead.Child_Age__c = '4';
     insert newLead;
     LeadWishFamilyDupe.FindFamilyContactDupe(newLead.id);
   
   }
   
    /*This method is used to increase the code coverage for findDuplicateRecords method */ 
   public testmethod static void FindWishChildDupe(){ 
         
         Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
         Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
         Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         newLead.Child_Age__c = '4';
         insert newLead;
         Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
         dupeLead.Override_Dupe_Check__c = true;
         insert dupeLead;  
         LeadWishFamilyDupe.FindLeadDupe(dupeLead.id);
        
        
   }

}