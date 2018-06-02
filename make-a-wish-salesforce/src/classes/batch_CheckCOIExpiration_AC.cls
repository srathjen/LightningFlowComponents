/***************************************************************************
Author : MST Solutions
Created Date : 05/10/2017
Description : This class is used to update Volunteer Opportunity and Volunteer Role
to "Out of Compliance" when the Conflict of Interest is expired
****************************************************************************/
global class batch_CheckCOIExpiration_AC implements Database.Batchable<sObject>  {
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        return Database.getQueryLocator([SELECT id, Expiration_Date__c, Current__c, Volunteer_Contact__c FROM Conflict_Of_Interest__c WHERE Current__c = True AND Expiration_Date__c <= TODAY ]);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Conflict_Of_Interest__c> coiExpiredList)  {
        
        Set<Id> volContactIdSet = new Set<Id>();
        for(Conflict_Of_Interest__c coiExpired : coiExpiredList) {
            volContactIdSet.add(coiExpired.Volunteer_Contact__c);
        }
        
        if(volContactIdSet.size() > 0) {
            BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(volContactIdSet, 'COI',coiExpiredList);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}