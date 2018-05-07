/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record is created from Manually or lead convertion then this calss has been called by
theCase_OnBeforeInsertTriggerHandler and we are updating the Dev staff Email Id in this class.
*******************************************************************************************************************/
Public class Case_OnBeforeInsertTriggerHandlerHelper{
    /******************************************************************************************************************
updateGrantingCaseDevEmail() is used to Updating DEV Staff Email field for wishgarntingcase based on chatper account.
when a new case is created.
******************************************************************************************************************/
    public static void updateGrantingCaseDevEmail(map<id,Case> parenChildCasemap,String parentWishRecordTypeId){
        map<id,string> parenCaseMap = new map<id,string>();
        //try{
            if(parenChildCasemap.size() > 0){
                for(Case parentCase : [SELECT ID,ChapterName__c,ChapterName__r.DevStaffEmail__c,RecordTypeId FROM Case WHERE ID IN:parenChildCasemap.keySet() AND RecordTypeId =: parentWishRecordTypeId Limit 50000]){
                    parenCaseMap.put(parentCase.id, parentCase.ChapterName__r.DevStaffEmail__c);
                }
                
                for(Case currentGranting : parenChildCasemap.values()){
                    if(parenCaseMap.containsKey(currentGranting.ParentId)){
                        currentGranting.Dev_Staff_Email__c = parenCaseMap.get(currentGranting.ParentId);                        
                    }
                }
            }
       /* }
        catch(Exception e){
            for(case newCase : parenChildCasemap.values()){
                system.debug('@@ Exception @@@'+e);
                newCase.addError(e.getMessage()); 
            }
        }*/
    }
}