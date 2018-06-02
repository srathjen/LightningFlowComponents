/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record insert then it will call the case_OnAfterInsertTriggerHandlerHelper class based 
on the collection size() > 0.
*******************************************************************************************************************/

Public class Case_OnAfterInsertTriggerHandler{
    
    Static Constant_AC  constant = new Constant_Ac();   
    Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();     
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();    
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    /***************************************************************************************************************    
This method is used to get the new case record values then it will added into the collections, then
It will call the corresponding methods in Case_OnAfterInsertTriggerHandlerHelper calss.
*****************************************************************************************************************/   
    public static void OnAfterInsert(List<Case> newCaseList){
        List<Case> eligibilityReviewCaseList = new List<Case>();
        Map<Id, Case> surveyEmailMap = new Map<Id, Case>();
        Set<Id> impactparentIdSet = new Set<Id>();
        Set<Id> parentIdsSet = new Set<Id>();
        Map<Id, Case> wishChapterIdsMap = new Map<Id,Case>();
        Set<String> wishTypeSet = new Set<String>();
        String wishType = '';
        Map<Id, Case> wishPlaningAnticipationSubCaseMap = new Map<Id, Case>();
        Map<Id, case> wishReceiptMap = new Map<Id, case>();
        Set<Id> wishGrantedSubCaseIdSet = new Set<Id>();
        List<Case> wishGrantedSubCaseList = new List<Case>();
        Map<Id, Case> parentCaseIntakeOwnerMap = new Map<Id, Case>();
        Set<Id> chapterNames = new Set<Id>();
        List<Case> newCaseFileList = new List<Case>();
        List<Case> potentialRushList = new List<Case>();
        for(Case newWish : newCaseList) {
            if(newWish.RecordTypeId == diagnosisVerificationRT ||newWish.RecordTypeId == wishEffectRecordTypeId || newWish.RecordTypeId == wishDeterminationRecordTypeId || newWish.RecordTypeId == wishPlanningRecordTypeId
               || newWish.RecordTypeId == wishAssistRecordTypeId || newWish.RecordTypeId == parentWishRecordTypeId || newWish.RecordTypeId == wishGrantRecordTypeId){
                   if(newWish.RecordTypeId == diagnosisVerificationRT && newWish.subject == 'Eligibility Review') {
                       eligibilityReviewCaseList.add(newWish);
                   }
                   // Below four lines are related to STT-11 for poplating Survey email to parent case when Wish Impact subcase has value for Survey Email field.
                   if((newWish.Survey_Email__c != NULL || newWish.Survey_Sent__c) && newWish.RecordTypeId == wishEffectRecordTypeId && newWish.ParentId != NULL) {
                       surveyEmailMap.put(newWish.Id, newWish);
                       impactparentIdSet.add(newWish.ParentId);
                   }
                   if(newWish.RecordTypeId == wishDeterminationRecordTypeId) 
                   {
                       if(newWish.isClosed != True && newWish.Status != 'Completed')
                       {
                           parentIdsSet.add(newWish.ParentId);
                           wishChapterIdsMap.put(newWish.Id, newWish);
                           wishType = constant.wishDeterminationRT;
                       }
                   } 
                   else if(newWish.RecordTypeId == wishPlanningRecordTypeId) {
                       if(newWish.isClosed != True && newWish.Status != 'Completed')
                       {
                           wishTypeSet.add(newWish.Wish_Type__c);
                           wishPlaningAnticipationSubCaseMap.put(newWish.Id, newWish);
                           parentIdsSet.add(newWish.ParentId);
                           wishChapterIdsMap.put(newWish.Id, newWish);
                           wishType = constant.wishPlanningAnticipationRT;
                       }
                   } 
                   else if(newWish.RecordTypeId == wishAssistRecordTypeId) {
                       if(newWish.isClosed != True && newWish.Status != 'Completed')
                       {
                           parentIdsSet.add(newWish.ParentId);
                           wishChapterIdsMap.put(newWish.Id, newWish);
                           wishType = constant.wishAssistRT;
                       }
                   } 
                   else if(newWish.RecordTypeId == wishGrantRecordTypeId) {
                       if(newWish.Wish_Receipt_Items__c != Null && newWish.ParentId != Null){
                           wishReceiptMap.put(newWish.ParentId,newWish);
                       }
                       
                       if(newWish.isClosed != True && newWish.Status != 'Completed')
                       {
                           parentIdsSet.add(newWish.ParentId);
                           wishChapterIdsMap.put(newWish.Id,newWish);
                           wishType = constant.wishGrantRT;
                           wishGrantedSubCaseList.add(newWish);
                           wishGrantedSubCaseIdSet.add(newWish.ParentId);
                       }
                   } 
                   else if(newWish.RecordTypeId == wishEffectRecordTypeId) {
                       if(newWish.isClosed != True && newWish.Status != 'Completed')
                       {
                           parentIdsSet.add(newWish.ParentId);
                           wishChapterIdsMap.put(newWish.Id, newWish);
                           wishType = constant.wishGrantRT;
                       }
                   } 
                   else if(newWish.RecordTypeId == parentWishRecordTypeId){
                       if(newWish.isClosed != True)
                       {   
                           parentCaseIntakeOwnerMap.put(newWish.Id, newWish);
                           parentIdsSet.add(newWish.Id);
                           chapterNames.add(newWish.ChapterName__c);
                       }
                       //IME-107
                       if(!newWish.Rush__c){
                           potentialRushList.add(newWish);
                       }
                   }
               }
            newCaseFileList.add(newWish);
        }
        
        if (parentIdsSet.size()>0 && chapterNames.size()>0){
            Case_OnAfterInsertTriggerHandlerHelper.UpdateWishRecordIdentifier(parentIdsSet,chapterNames,parentWishRecordTypeId);
        } 
        if(surveyEmailMap.size() > 0) {
            Case_OnAfterInsertTriggerHandlerHelper.updateSurveyField(surveyEmailMap, impactparentIdSet);
        }
        if(wishChapterIdsMap.size()>0 && parentIdsSet.size()>0) {
            Case_OnAfterInsertTriggerHandlerHelper.createActionTracks(wishType,wishChapterIdsMap,parentIdsSet);
        }
        if(parentCaseIntakeOwnerMap.size() > 0 ) {
            Case_OnAfterInsertTriggerHandlerHelper.CaseTeamInTakeManager(parentCaseIntakeOwnerMap);
        }
        /*if(wishReceiptMap.size() > 0){
            Case_OnAfterInsertTriggerHandlerHelper.wishReciptValues(wishReceiptMap,parentCaseIntakeOwnerMap);
        }*/
        if(newCaseFileList.size() > 0)
            Case_OnAfterInsertTriggerHandlerHelper.createCaseFile(newCaseFileList);
        
        //IME-107
        if(potentialRushList.size() > 0){
            Case_OnAfterInsertTriggerHandlerHelper.createPotentialRushTask(potentialRushList);
        }
    } 
}