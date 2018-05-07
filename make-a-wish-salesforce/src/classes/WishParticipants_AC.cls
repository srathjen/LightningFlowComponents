/*************************************************************************************************************************
Author      : MST Solutions
Description : This class is used to display the participant list in wish detail page.
**************************************************************************************************************************/
/*

*/
Public class WishParticipants_AC
{
   Case currCase = new Case();
   public Integer totalParticipants{get;set;}
   public WishParticipants_AC(Apexpages.standardController controller)
   {
     currCase = (Case)controller.getRecord();
     currCase = [SELECT id,ContactId FROM Case WHERE Id = :currCase.id limit 1];
     totalParticipants = 1; 
   }

   public list<npe4__Relationship__c> getParticipantsConList()
   {
       
        List<npe4__Relationship__c> relationshipList =  new List<npe4__Relationship__c>();
                 relationshipList = [SELECT id,npe4__RelatedContact__c,npe4__RelatedContact__r.Id, npe4__RelatedContact__r.FirstName,
                                                        npe4__RelatedContact__r.LastName,npe4__RelatedContact__r.Middle_Name__c,
                                                        npe4__RelatedContact__r.Birthdate,npe4__Type__c,npe4__RelatedContact__r.Current_Age__c,
                                                        npe4__RelatedContact__r.CurrentAge__c,Parent_Legal_Guardian__c,
                                                        Medical_Needs__c,Non_Comped__c FROM npe4__Relationship__c WHERE 
                                                        Wish_Participant__c = True AND npe4__Contact__c =: currCase.ContactId LIMIT 50000];                                            
        //Related to WVC-1892
        /* If(relationshipList != Null){
             npe4__Relationship__c rel = relationshipList.get(0);
             //relationshipList.add(rel);             
         } */
         for(npe4__Relationship__c currRel : relationshipList){
            If(!currRel.Non_Comped__c)
                totalParticipants += 1;
        }
         npe4__Relationship__c childRel = [SELECT id,npe4__RelatedContact__c,npe4__RelatedContact__r.Id, npe4__RelatedContact__r.FirstName,
                                                        npe4__RelatedContact__r.LastName,npe4__RelatedContact__r.Middle_Name__c,
                                                        npe4__RelatedContact__r.Birthdate,npe4__Type__c,npe4__RelatedContact__r.Current_Age__c,
                                                        npe4__RelatedContact__r.CurrentAge__c,Parent_Legal_Guardian__c,
                                                        Medical_Needs__c,Non_Comped__c FROM npe4__Relationship__c WHERE 
                                                        npe4__RelatedContact__c =: currCase.ContactId LIMIT 1];
         system.debug('Relatonship'+childRel);
         childRel.npe4__Type__c = 'Wish Child';
         childRel.Parent_Legal_Guardian__c = False;
         childRel.Medical_Needs__c = '';
         childRel.Non_Comped__c = False;
         If(relationshipList.Size()  > 0)
             relationshipList.add(0,childRel);  
         else
             relationshipList.add(childRel);                                           
        
        // related to WVC-1804 count the number of participants include the wish child.
         
        return relationshipList;
   
   }
}