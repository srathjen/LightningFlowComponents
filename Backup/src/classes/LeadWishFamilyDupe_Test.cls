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

}