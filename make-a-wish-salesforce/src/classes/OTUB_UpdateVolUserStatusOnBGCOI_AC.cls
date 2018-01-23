/*****************************************************************************************
Created By  : MST
Author : MST Solutions
Description : Used to update COI and BG Volunteer Status Active Hidden field based on Org Affiliation status
**********************************************************************************************/
global class OTUB_UpdateVolUserStatusOnBGCOI_AC implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator([SELECT Id, npe5__Contact__c FROM npe5__Affiliation__c WHERE (npe5__Status__c = 'Active' OR npe5__Status__c = 'Inactive' ) AND npe5__Primary__c = TRUE]);
    }
    
    global void Execute(Database.BatchableContext BC, List<npe5__Affiliation__c> scope)  {
        Set<Id> contactIdsSet = new Set<Id>();
        
        Map<Id, Background_check__c> backGroundContactMap = new Map<Id, Background_check__c>();
        Map<Id, Conflict_Of_Interest__c> coiContactMap = new Map<Id, Conflict_Of_Interest__c>();
        
        
        List<Background_check__c> bgList = new List<Background_check__c>();
        List<Conflict_Of_Interest__c> coiList = new List<Conflict_Of_Interest__c>();
        
        for(npe5__Affiliation__c currResult : scope) {
            contactIdsSet.add(currResult.npe5__Contact__c);
        }
        
        
        for(Background_check__c dbbackgroundCheckRec : [SELECT Id,current__c,Date__c,Volunteer__c, Volunteer_is_Inactive__c FROM Background_check__c  WHERE Volunteer__c IN: contactIdsSet AND Current__c = TRUE ]) {
            backGroundContactMap.put(dbbackgroundCheckRec.Volunteer__c, dbbackgroundCheckRec);
        }
        
        for(Conflict_Of_Interest__c dbconflictInterestRec : [SELECT Id,Expiration_Date__c,Volunteer_Contact__c, Volunteer_is_Inactive__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c IN: contactIdsSet AND Current__c = TRUE]){
            coiContactMap.put(dbconflictInterestRec.Volunteer_Contact__c, dbconflictInterestRec);
        } 
        
        
        Set<Id> volConSet = new Set<Id>();
        Set<Id> activeSet = new Set<Id>();
        Set<Id> inActiveSet = new Set<Id>();
        for(npe5__Affiliation__c af : [SELECT Id, npe5__Contact__c, npe5__Status__c FROM npe5__Affiliation__c WHERE npe5__Primary__c = TRUE AND (npe5__Status__c = 'Active' OR npe5__Status__c = 'Inactive' ) AND npe5__Contact__c IN :  contactIdsSet]) {
            if(af.npe5__Status__c == 'Active') {
                if(backGroundContactMap.containsKey(af.npe5__Contact__c)) {
                    if(backGroundContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c == True) {
                        backGroundContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c = false;
                        bgList.add(backGroundContactMap.get(af.npe5__Contact__c));
                    }
                }
                if(coiContactMap.containsKey(af.npe5__Contact__c)) {
                    if(coiContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c == True) {
                        coiContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c = false;
                        coiList.add(coiContactMap.get(af.npe5__Contact__c));
                    }
                }
            } else {
                if(backGroundContactMap.containsKey(af.npe5__Contact__c)) {
                    if(backGroundContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c == false) {
                        backGroundContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c = true;
                        bgList.add(backGroundContactMap.get(af.npe5__Contact__c));
                    }
                }
                if(coiContactMap.containsKey(af.npe5__Contact__c)) {
                    if(coiContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c == false) {
                        coiContactMap.get(af.npe5__Contact__c).Volunteer_is_Inactive__c = true;
                        coiList.add(coiContactMap.get(af.npe5__Contact__c));
                    }
                }
            }
        }
        
        if(coiList.size() > 0) {
            update coiList;
        }
        if(bgList.size() > 0) {
            update bgList;
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}