/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Volunteer Opportunity record updated then it will update the values to corresponding fields.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

Public class VolOpportunity_OnBefore_Update_Handler{
    
    static Constant_AC  constant = new Constant_AC();
    static Id registeredWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.registeredWish).getRecordTypeId();
    static Id registeredNonWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.registeredNonWish).getRecordTypeId();
    static Id wishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
    static Id nonWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
    static Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    // This method is used to update the record type and vounteer Opportunity status and wish start date values. 
    public static void onBeforeUpdate(Map<Id,Volunteer_Opportunity__c> newMap,Map<Id,Volunteer_Opportunity__c> oldMap){
        Map<Id,Volunteer_Opportunity__c> approvedVolunteerOppMap = new Map<Id,Volunteer_Opportunity__c>();
        Map<Id,String> volunteerContactMap = new Map<Id,String>();
        Set<Id> volunteerContactIdSet = new set<Id>();
        Set<Id> dbWishSet = new Set<Id>();
        set<Id> dbCaseSet = new Set<Id>();
        for(Volunteer_Opportunity__c currRec : newMap.Values()){
            if(currRec.Inactive__c == true && oldMap.get(currRec.Id).Inactive__c == False && currRec.Reason_Inactive__c != null) {
                currRec.Status__c = 'Inactive';
                currRec.Inactivated_or_Rejected_Date__c = Date.today();
            }
            if(currRec.Inactive__c == true && currRec.Status__c == 'Inactive' && currRec.Wish__c != Null){
                currRec.Wish_End_Date__c = Date.today();
            }
            if(currRec.Status__c == 'Pending' && currRec.Status__c != oldMap.get(currRec.Id).Status__c) {
                currRec.Inactivated_or_Rejected_Date__c = Date.today();
            }
            if(currRec.Volunteer_Name__c != Null && currRec.Volunteer_Name__c != oldMap.get(currRec.Id).Volunteer_Name__c){
                volunteerContactIdSet.add(currRec.Volunteer_Name__c);
            }
            if(currRec.Reason_Inactive__c != Null){
                currRec.Inactive__c = True;
            }
            if(currRec.RecordTypeId == wishRecordTypeId  && currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c != currRec.Status__c && currRec.Wish__c != Null){
                currRec.RecordTypeId = registeredWishRecordTypeId;
                dbWishSet.add(currRec.Wish__c);
            }
            if(currRec.RecordTypeId == nonWishRecordTypeId && currRec.Status__c == 'Approved'){
                currRec.RecordTypeId = registeredNonWishRecordTypeId;
                
            }
            if(currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c == 'Pending') {
                currRec.Inactivated_or_Rejected_Date__c = null;
            }
        }
        
        if(volunteerContactIdSet.size() > 0){
            for(Contact volunteerContact : [SELECT Id,Email From Contact WHERE Id IN:volunteerContactIdSet]){
                volunteerContactMap.put(volunteerContact.Id,volunteerContact.Email);
            }
        }
        if(dbWishSet.size() > 0){
            for(Case dbCase : [SELECT Id,Status,RecordTypeId,isclosed From Case WHERE status != 'Granted' AND RecordTypeId =: parentWishRecordTypeId AND Id IN: dbWishSet]){
                if(dbCase.isclosed == false){
                    dbCaseSet.add(dbCase.Id);
                }
            }
        }
        if(volunteerContactMap.size() > 0 || dbCaseSet.size() > 0){
            for(Volunteer_Opportunity__c currRec : newMap.Values()){
                if(currRec.Volunteer_Name__c!= Null && volunteerContactMap.containsKey(currRec.Volunteer_Name__c)){
                    currRec.Hidden_Volunteer_Contact_Email__c = volunteerContactMap.get(currRec.Volunteer_Name__c);
                }
                if(dbCaseSet.contains(currRec .Wish__c)){
                    currRec.Wish_Start_Date__c = system.today();
                }
            }
        }
    }
}