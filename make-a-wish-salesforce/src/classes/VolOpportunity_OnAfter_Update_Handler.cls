/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new volunteer Opportunity record get update then it will call the VolOpportunity_OnAfter_Update_Helper class based 
on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
public class VolOpportunity_OnAfter_Update_Handler{
     
    static Constant_AC  constant = new Constant_AC();
    static Id registeredWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.registeredWish).getRecordTypeId();
    static Id registeredNonWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.registeredNonWish).getRecordTypeId();
    static Id wishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
    static Id nonWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
    static Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    // This method is used to call the corresponding methods based on the condition that current record met.
    public static void onAfterUpdate(map<Id,Volunteer_Opportunity__c> newMap,map<Id,Volunteer_Opportunity__c> oldMap){
        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> VolunteerwishIdSet = new Set<Id>();
        set<Id> volunteerIdsSet = new set<Id>();
        List<Volunteer_Opportunity__c> recordsForApprovalProcess = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams = new List<Volunteer_Opportunity__c>();
        Map<Id,Volunteer_Opportunity__c> volunteerforApexSharing = new Map<Id,Volunteer_Opportunity__c>();
        Map<String,Set<String>> volunteerCaseMap = new Map<String, set<String>>();
        Map<String, List<Volunteer_Opportunity__c >> volunteerOppMap = new Map<String, List<Volunteer_Opportunity__c>>();
        List<Volunteer_Opportunity__c> nonWishList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> nonWishListtoupdatecount = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> updateWishGrantedList = new List<Volunteer_Opportunity__c>();
        Set<Id> updateUserSet = new Set<Id>();
        Set<Id> volconId= new Set<Id>();
        List<Volunteer_Opportunity__c> rejectedVolunteerOpportunitiesList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> volOpportunitySharingList = new List<Volunteer_Opportunity__c>();
        Set<Id> wishIds = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        set<Id> voluOppIdSet = new Set<Id>();
        boolean isdelete;
        Set<Id> volunteerOppIdSet = new Set<Id>();
        Set<Id> recallApprovalIdSet = new Set<Id>();
        Set<ID> volunteerOppName=new Set<ID>();
        for(Volunteer_Opportunity__c currRec : newMap.values()){ 
            
            if(currRec.Status__c != oldMap.get(currRec.Id).Status__c && oldMap.get(currRec.Id).Status__c == 'Pending' && (currRec.Status__c == 'Inactive' || currRec.Status__c == 'Out of Compliance')){
                recallApprovalIdSet.add(currRec.Id);
            }
            
            if(currRec.Status__c != 'Approved' &&  (currRec.Volunteer_Name__c!= Null && oldMap.get(currRec.id).Volunteer_Name__c== Null)&& (currRec.Wish__c != Null && currRec.Reason_Inactive__c == Null)){
                recordsForApprovalProcess.add(currRec); 
                chapterIdsSet.add(currRec.Chapter_Name__c);
            } 
            
            if((currRec.Status__c == 'Approved' && currRec.Volunteer_Name__c!= Null && oldMap.get(currRec.id).Reason_Inactive__c == Null  && currRec.Reason_Inactive__c != Null)||
               (currRec.Reason_Inactive__c == 'Not Approved' && currRec.Reason_Inactive__c != oldMap.get(currRec.Id).Reason_Inactive__c) || (currRec.Inactive__c == true && currRec.Inactive__c != oldMap.get(currRec.Id).Inactive__c)){
                   if(RecursiveTriggerHandler.isFirstTime == true || Test.isRunningTest()){
                       volunteerOpportunityList.add(currRec);
                       volunteerOppIdSet.add(currRec.Id);
                   }
            }
            else if(currRec.Status__c != 'Approved' &&  (currRec.Volunteer_Name__c!= Null && oldMap.get(currRec.id).Volunteer_Name__c== Null)&& (currRec.Wish__c == Null) && (currRec.Non_Wish_Event__c != Null && currRec.Reason_Inactive__c == Null)){
                recordsForApprovalProcess.add(currRec); 
                chapterIdsSet.add(currRec.Chapter_Name__c);
            }
            if((currRec.Status__c == 'Approved' && oldMap.get(currRec.id).Status__c == 'Pending')  &&  currRec.Volunteer_Name__c != NULL && (currRec.Wish__c != NULL || currRec.Non_Wish_Event__c != NULL) && currRec.Reason_Inactive__c == NULL){
                volOpportunitySharingList.add(currRec); 
                if(currRec.Wish__c != Null){
                    recordsForCreatingCaseTeams.add(currRec);
                }
             }
            if((currRec.Volunteer_Name__c != Null) &&(currRec.Wish__c != Null)){
                volunteerforApexSharing.put(currRec.Id,currRec);
                if(volunteerCaseMap.containsKey(currRec.Volunteer_Name__c))
                {
                    volunteerCaseMap.get(currRec.wish__c).add(currRec.Volunteer_Name__c);
                }
                else
                {
                    volunteerCaseMap.put(currRec.wish__c,new Set<String>{currRec.Volunteer_Name__c});
                }
            }
            if(currRec.Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && currRec.Status__c != 'Approved' && currRec.Status__c == 'Pending' && currRec.Reason_Inactive__c == Null ){
                if(RecursiveTriggerHandler.isFirstTime == true){ 
                    nonWishListtoupdatecount.add(currRec);
                    voluOppIdSet.add(currRec.Id); 
                    isdelete = false;
                }
            }
            if(currRec.Volunteer_Name__c == Null && oldMap.get(currRec.Id).Volunteer_Name__c  != Null){
                updateUserSet.add(currRec.Id);
                volconId.add(oldMap.get(currRec.Id).Volunteer_Name__c);
            }
            if((currRec.Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && currRec.Status__c == 'Approved' && currRec.Reason_Inactive__c != Null ) || (currRec.Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && currRec.Status__c != 'Approved' && currRec.Reason_Inactive__c != Null)){
                if(RecursiveTriggerHandler.isFirstTime == true){ 
                    nonWishListtoupdatecount.add(currRec);
                    voluOppIdSet.add(currRec.Id); 
                    isdelete = false;
                }
            }
            if(currRec.Volunteer_Name__c != Null && currRec.Wish__c != Null && currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c  != 'Approved' ){
                volunteerIdsSet.add(currRec.Volunteer_Name__c);
            }
            
            //Related to STT-62
            /*if(currRec.Volunteer_Name__c != NULL && currRec.Wish__c != NULL && currRec.inActive__c == TRUE && Trigger.oldMap.get(currRec.Id).inActive__c == FALSE){
                caseIdSet.add(currRec.Wish__c);
                voluOppIdSet.add(currRec.Volunteer_Name__c );
            }*/
            if(currRec.Volunteer_Name__c != Null && currRec.Wish__c != Null && (currRec.Status__c == 'Approved' || currRec.Status__c != 'Approved') && currRec.Reason_Inactive__c != Null && currRec.inActive__c == true){
                caseIdSet.add(currRec.Wish__c);
                voluOppIdSet.add(currRec.Volunteer_Name__c );
            }
            
            if(currRec.Status__c == 'Approved' && oldMap.get(currRec.id).Status__c != 'Approved'){
                volunteerOppName.add(currRec.Volunteer_Name__c);
            }
         }
         
         for(Volunteer_Opportunity__c  currRec :[SELECT id, ownerId, owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c, 
                                                Chapter_Name__r.Name FROM Volunteer_Opportunity__c WHERE Id IN :Trigger.newMap.keySet()]){
            
            if(currRec.OwnerId != oldMap.get(currRec.Id).OwnerId && currRec.Chapter_Name__c != Null && currRec.Owner.userRole.Name == 'National Staff'){
                if(volunteerOppMap.containsKey(currRec.Chapter_Name__r.Name))
                    volunteerOppMap.get(currRec.Chapter_Name__r.Name).add(currRec);
                else
                    volunteerOppMap.put(currRec.Chapter_Name__r.Name, new List<Volunteer_Opportunity__c>{currRec});
            }
        } 
        
        if(recallApprovalIdSet.size() > 0) {
            Case_OnAfterUpdateTriggerHandlerHelper.recallVolOppApproval(recallApprovalIdSet);
        }
        if(caseIdSet.size() > 0 && voluOppIdSet.size() > 0 ){
            if(RecursiveTriggerHandler.isFirstTime == true){
                VolOpportunity_OnAfter_Update_Helper.updateCase(caseIdSet,voluOppIdSet);
            }
        }
        if(volunteerOpportunityList.size() > 0){
            VolOpportunity_OnAfter_Update_Helper.CreateNewVolunteerOpportunity(volunteerOpportunityList,volunteerOppIdSet);
         }
        
        if(volunteerIdsSet.size() > 0){
            VolOpportunity_OnAfter_Update_Helper.ActiveWishCount(volunteerIdsSet);
        }
        if(updateUserSet.size() > 0){
            VolOpportunity_OnAfter_Update_Helper.updateUserRoleId(updateUserSet,volconId);
        }
        
        //Used to create approval process for volunteer opportunity record
        if(recordsForApprovalProcess.size() > 0 && chapterIdsSet.size()>0) {
            VolOpportunity_OnAfter_Update_Helper.SubmitforApprovalProcess(recordsForApprovalProcess, chapterIdsSet);
        }
        //Adding to volunteer to case team member once it is approved
        if(recordsForCreatingCaseTeams.size() > 0){
            VolOpportunity_OnAfter_Update_Helper.CreateCaseTeamMembers(recordsForCreatingCaseTeams);
        }
        if(nonWishListtoupdatecount.Size() > 0 ){
          VolOpportunity_OnAfter_Update_Helper.UpdateVolunteerRegisterdCount(nonWishListtoupdatecount,voluOppIdSet,isdelete);
        }
        if(volOpportunitySharingList.size() > 0){
            VolOpportunity_OnAfter_Update_Helper.sharevolunteerOpportunityRecord(volOpportunitySharingList);
        }
        if(volunteerOppName.size() > 0){
            VolOpportunity_OnAfter_Insert_Helper.Updatecontacts(volunteerOppName);
        }
        if(volunteerOppMap.size() > 0){
            ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOppMap);
        }
     }
}