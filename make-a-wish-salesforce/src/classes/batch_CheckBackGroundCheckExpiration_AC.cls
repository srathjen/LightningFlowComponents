/***************************************************************************
Author : MST Solutions
Created Date : 05/10/2017
Description : This class is used to update Volunteer Opportunity and Volunteer Role
to "Out of Compliance" when the Background Check is expired
****************************************************************************/
global class batch_CheckBackGroundCheckExpiration_AC implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        return Database.getQueryLocator([
            SELECT Id, Volunteer__c 
            FROM Background_check__c 
            WHERE Current__c = true
            AND Date__c < TODAY
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Background_check__c> backGroundCheckExpiredList)  {
        Set<Id> volContactIdSet = new Set<Id>();
        for(Background_check__c bcExpired : backGroundCheckExpiredList) {
            volContactIdSet.add(bcExpired.Volunteer__c);
        }
        if(!volContactIdSet.isEmpty()) {
            BackgroundCheckService.updateVolunteerRoleHiddenStatus(volContactIdSet, 'backgroundcheck', backGroundCheckExpiredList);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new batch_CheckBackGroundCheckExpiration_AC(), 200);
    }
}