/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Pavithra
Created Date : 08/11/2016
Description  : This class is used as handler to AffiliationReviewTrigger_AT for updating 
               Primary as True when affiliation record is creating for contact as a first record
               and used to add user to chatter group when the user becomes active for the chapter.
Modification Log
1. WVC-2205 - Kanagaraj A -08/08/2018 // Line 56 Previously the affilliation status was "Prospective".
                                         Now we have updated as "Pending".
*****************************************************************************************************/
Public Class Affiliation_OnBeforeInsertTriggerHandler{
   /********************************************************************************************** 
    This method will be called before record is inserted and it is fired Whenever first
      Affiliation record is fallon under contact, assigning that record as primary.
    ********************************************************************************************** */
       
    public static void OnBeforeInsert(List<npe5__Affiliation__c> beforeInsertList)
    {
        Set<Id> contactIds = new Set<Id>();
        Map<String,Integer> contactsMap = new Map<String,Integer>();
        Map<Id,String> contactMap = new Map<Id,String>();
        Map<Id,Contact> getContactRecType = new Map<Id,Contact>();
        Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        
        for(npe5__Affiliation__c currRec : beforeInsertList) 
        {
            contactIds.add(currRec.npe5__Contact__c);
        }
        
        if(contactIds.size() > 0)
        {
            getContactRecType.putAll([SELECT Id,RecordTypeId FROM Contact WHERE Id IN :contactIds]);
        }
        
        
        for(AggregateResult ar : [SELECT npe5__Contact__c, count(Id) cnt FROM npe5__Affiliation__c 
                                  WHERE npe5__Contact__c IN :contactIds 
                                  GROUP BY npe5__Contact__c])
        {
            contactsMap.put(String.valueOf(ar.get('npe5__Contact__c')), Integer.valueOf(ar.get('cnt')));
        }
        
        for(npe5__Affiliation__c currRec : beforeInsertList) 
        {
            if(!(contactsMap.containsKey(currRec.npe5__Contact__c))) 
            {
                currRec.npe5__Primary__c = True;
            }
            
            if(currRec.npe5__Contact__c != Null && getContactRecType.containsKey(currRec.npe5__Contact__c))
            {
                if(getContactRecType.get(currRec.npe5__Contact__c).RecordTypeId != volunteerRecordTypeId) {
                    currRec.npe5__Status__c = 'Active';
                } else {
                    currRec.npe5__Status__c = 'Pending';
                }
                    
            }
        }
    }
}