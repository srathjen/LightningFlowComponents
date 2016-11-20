/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : 
1.This trigger is used to create child wish for parent wish .
2.Create tasks for child wishes.
3.Submits parent wish for approval once the required number of volunteers added to the parent wish team.
4.Add parent wish team members to child wish team.
*******************************************************************************************************************/

trigger CaseTrigger_AT on Case (after insert, after update,before update, after delete,before insert) {
    
    Constant_AC  constant = new Constant_Ac();    
    public static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    public static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    public static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    public static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    public static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    public static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    public Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();
    public Id volunteerOppWishRecordTypeId = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
    public static Id diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
    Set<Id> contactIds = new Set<Id>();
    Map<Id,contact> contactMap = new Map<Id,Contact>();
    
    // Mapping Birthdate from Contact to Wish.
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) { 
        Set<Id> PartAwishContactSet = new Set<Id>();
        Map<Id,Contact> PartAwishContactMap = new Map<Id,Contact>();
        Set<Id> wishOwnerIdSet = new Set<Id>();
        Map<Id,User> wishOwnerMap = new Map<Id,User>();
        String nationalRec;
        String email;
        if(Trigger.isInsert){
            //  WishesTriggerHelperClass.updateDateReceived(null,trigger.new);
            for(Case newCase : trigger.new){
                wishOwnerIdSet.add(newCase.OwnerId);
            }
            
            if(wishOwnerIdSet.size() > 0){
                for(User wishOwner : [SELECT Id,ManagerId,Manager.Name,Manager.Email From User WHERE Id IN: wishOwnerIdSet AND ManagerId != Null ]){
                    wishOwnerMap.put(wishOwner.id,wishOwner);
                }
            }
            for(Case newCase : trigger.new){
                if(wishOwnerMap.containsKey(newCase.OwnerId)){
                    newCase.Hidden_Wish_Owner_Manager__c  = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
                    newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
                }
            }
            
        }
        if(Trigger.isUpdate)
        {
            UserSetting__c usc = UserSetting__c.getValues(userinfo.getUserId());
            Map<String,Case> caseMap = New Map<String,Case>();
            Map<String,String> managerUserMap = new Map<String,String>();
            Map<String,Case> wishChildInfoMap = new Map<String,case>();
            // WishesTriggerHelperClass.updateDateReceived(trigger.oldMap,trigger.newMap.values());
            Set<Id> parentWishIdsSet = new Set<Id>();
            for(Case currentCase : Trigger.new)
            {
                if((currentCase.Status == 'Ready to Assign') && trigger.oldmap.get(currentCase.id).Status !=  'Ready to Assign' && currentCase.RecordTypeId == parentWishRecordTypeId){
                    caseMap.Put(currentCase.ChapterName__c,currentCase);
                    currentCase.Ready_to_Assign_Date__c = Date.Today();
                }
                
                if(currentCase.Status == 'DNQ - Chapter Staff' || currentCase.Status == 'DNQ - Chapter Medical Advisor' || 
                    currentCase.Status == 'DNQ - National Staff' || currentCase.Status == 'DNQ - National Medical Council')
                {
                
                    currentCase.DNQ_Date__c = Date.Today();
                }
                
                if((currentCase.Status == 'Wish Determined') && (trigger.oldmap.get(currentCase.id).Status != 'Wish Determined')){
                    currentCase.Meet_PWL_Criteria__c = 'Yes';
                    currentCase.Sub_Status__c = 'Within Policy';
                    currentCase.Concept_Approval_Date__c = Date.Today();
                }
                
                if((currentCase.Status == 'Completed') && (trigger.oldmap.get(currentCase.id).Status != 'Completed') && currentCase.RecordTypeId == parentWishRecordTypeId){
                    system.debug('Parent Case Id 1 :'+currentCase.Id);
                    parentWishIdsSet.add(currentCase.Id);
                }
                
                if(currentCase.Sub_Status__c == 'Abandoned' || currentCase.isClosed == True){
                    
                    currentCase.IsLocked__c = true;
                }
                
                if( currentCase.IsLocked__c == true && trigger.oldMap.get(currentCase.Id).IsLocked__c == true && usc != Null){
                    if(usc.All_Closed_Cases_except_Abandoned__c == false && currentCase.Sub_Status__c != 'Abandoned' && currentCase.isClosed == True)
                        currentCase.addError('You have not Permission to edit this record.');
                    if(usc.Edit_Abandoned_Cases__c== false && currentCase.Sub_Status__c == 'Abandoned' && currentCase.isClosed == True)
                        currentCase.addError('You have not Permission to edit this record.');
                }
                else if( currentCase.IsLocked__c == true && trigger.oldMap.get(currentCase.Id).IsLocked__c == true && usc == Null){
                    currentCase.addError('You have not Permission to edit this record.');
                }
                
                if(currentCase.Sub_Status__c == 'Abandoned' && Trigger.oldMap.get(currentCase.id).Status == 'Granted' && usc == Null)
                {
                    currentCase.addError('You have not Permission to update the granted case as abandoned');
                }
                else if(currentCase.Sub_Status__c == 'Abandoned' && Trigger.oldMap.get(currentCase.id).Status == 'Granted' && usc != Null)
                {
                    if(usc.Abandon_the_Granted_case__c== false)
                        
                        currentCase.addError('You have not Permission to update the granted case as abandoned');
                }
                
                if(currentCase.Status == 'On Hold' && Trigger.oldMap.get(currentCase.id).Status != 'On Hold')
                {
                    currentCase.Hold_Date__c = Date.Today();
                }
                else if(currentCase.Status == 'Inactive' && Trigger.oldMap.get(currentCase.id).Status != 'Inactive')
                {
                    currentCase.Inactive_Date__c= Date.Today();
                }
                else if((currentCase.Status == 'Closed' || currentCase.Status == 'Completed') && Trigger.oldMap.get(currentCase.id).Status == 'Granted')
                {
                    currentCase.Completed_date__c= Date.Today();
                }
                
                if(currentCase.Sub_Status__c == 'Abandoned' && currentCase.Sub_Status__c != 'Abandoned')
                   currentCase.Closed_Date__c = Date.Today();
                   
                if(currentCase.Update_Wish_Child_Form_Info__c == True && Trigger.oldMap.get(currentCase.id).Update_Wish_Child_Form_Info__c != True)
                {
                    wishChildInfoMap.put(currentCase.id,currentCase);
                } 
                if(currentCase.Interview_date__c < System.today()) {
                    currentCase.Interview_date__c.addError('Interview Date should be in future');
                }
            }
            
            for(Case newCase : trigger.new){
                wishOwnerIdSet.add(newCase.OwnerId);
            }
            
            if(wishOwnerIdSet.size() > 0){
                for(User wishOwner : [SELECT Id,ManagerId,Manager.Name,Manager.Email From User WHERE Id IN: wishOwnerIdSet AND ManagerId != Null ]){
                    wishOwnerMap.put(wishOwner.id,wishOwner);
                }
            }
            for(Case newCase : trigger.new){
                if(wishOwnerMap.containsKey(newCase.OwnerId)){
                    newCase.Hidden_Wish_Owner_Manager__c  = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
                    newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
                }
            }
            
            for(Account currentAccount : [SELECT ID,Volunteer_Manager__c FROM Account Where ID IN: caseMap.keyset()] ){
                
                managerUserMap.put(currentAccount.Id,currentAccount.Volunteer_Manager__c);
            }
            
            for(Case currentCase : Trigger.new){
                if(managerUserMap.containsKey(currentCase.ChapterName__c)){
                    currentCase.OwnerId = managerUserMap.get(currentCase.ChapterName__c);
                }
            }
            
            if(parentWishIdsSet.size() >0){
                system.debug('Parent Case Id 2 :'+Trigger.new);
                CaseTriggerHandler.CheckBudgetActuals(Trigger.new);
            }
            
            if(wishChildInfoMap.size() > 0)
            {
                WishChildFormValUpdate_AC.updateWishType(wishChildInfoMap);
                
            }
        }
        
        for(Case currWish : Trigger.new) {
            if(currWish.contactId != Null && currWish.birthdate__c == Null) {
                contactIds.add(currWish.contactId); 
            }
            
            if(currWish.Local_MCA_Team__c != Null && currWish.RecordTypeId == partARecordTypeId){
                PartAwishContactSet.add(currWish.Local_MCA_Team__c );
                system.debug('@@@@@@@@@@@ PartAwishContactSet @@@@@@@@@@'+PartAwishContactSet);
            }
            if(currWish.Status == 'Escalated' && currWish.RecordTypeId == partARecordTypeId){
                nationalRec = 'Make-A-Wish America';
                currWish.isNational__c = True;
            }
            
            if(currWish.isEmail__c == true && trigger.oldMap.get(currWish.Id).isEmail__c  == false && currWish.RecordTypeId == partARecordTypeId){
                currWish.Status= 'In progress';
                
            }
            
            
        }
        if(nationalRec == 'Make-A-Wish America'){
            List<Account> dbAccountList = [SELECT Id,MAC_Email_del__c,Name FROM Account WHERE Name =: nationalRec Limit 1];
            email = dbAccountList[0].MAC_Email_del__c;
        }
        
        if(PartAwishContactSet.size() > 0){
            for(Contact dbContact : [SELECT Id,Email,First_Last_Initial__c,RecordTypeId,RecordType.Name from Contact WHERE Id IN:PartAwishContactSet]){
                PartAwishContactMap.put(dbContact.Id,dbContact);
                system.debug('@@@@@@@ dbcontactMedical @@@@ '+dbContact);
            }
        }
        if(contactIds.size() > 0) {
            contactMap.putAll([SELECT id,birthdate FROM Contact WHERE Id IN :contactIds]);
        }
        
        for(Case currWish : Trigger.new) {
            if((PartAwishContactMap.containsKey(currWish.Local_MCA_Team__c)) && (currWish.RecordTypeId == partARecordTypeId)){
                system.debug('@@@@@@@ Enter INTO MAP @@@@ '+currWish );
                currWish.MAC_Email__c = PartAwishContactMap.get(currWish.Local_MCA_Team__c).Email ;
                
            }
            if(currWish.Status == 'Escalated' && currWish.RecordTypeId == partARecordTypeId){
                currWish.MAC_Email__c = email;
            }
            
            if(contactMap.containsKey(currWish.contactId)) {
                if(contactMap.get(currWish.contactId).birthdate != Null)
                    currWish.birthdate__c = contactMap.get(currWish.contactId).birthdate;
            } 
        }
    }
    
    /* Used to create action track for different stages based on Chapter and used to pull Case team members to child wishes*/ 
    if(Trigger.isInsert && Trigger.isAfter) {
        Set<Id> newCaseIdsSet = new Set<Id>();
        Set<Id> parentIdsSet = new Set<Id>();
        Set<Id> chapterNames = new Set<Id>();
        List<Case> wishDeterminationSubCaseList = new List<Case>();
        List<Case> wishGrantedSubCaseList = new List<Case>();
        Map<Id, Case> wishPlaningAnticipationSubCaseMap = new Map<Id, Case>();
        Set<String> wishTypeSet = new Set<String>();
        Set<Id> wishDeterminationSubCaseIds = new Set<Id>();
        Set<Id> wishGrantedSubCaseIdSet = new Set<Id>();
        Map<Id, Case> wishChapterIdsMap = new Map<Id,Case>();
        String wishType = '';
        List<cg__CaseFile__c> casefiles=new List<cg__CaseFile__c>();
        for(Case newWish : Trigger.New) {
            if(newWish.RecordTypeId == wishDeterminationRecordTypeId) {
                parentIdsSet.add(newWish.ParentId);
                wishChapterIdsMap.put(newWish.AccountId, newWish);
                wishType = constant.wishDeterminationRT;
                wishDeterminationSubCaseList.add(newWish);
                wishDeterminationSubCaseIds.add(newWish.ParentId);
            } else if(newWish.RecordTypeId == wishPlanningRecordTypeId) {
                wishTypeSet.add(newWish.Wish_Type__c);
                wishPlaningAnticipationSubCaseMap.put(newWish.Id, newWish);
                parentIdsSet.add(newWish.ParentId);
                wishChapterIdsMap.put(newWish.AccountId, newWish);
                wishType = constant.wishPlanningAnticipationRT;
            } else if(newWish.RecordTypeId == wishAssistRecordTypeId) {
                parentIdsSet.add(newWish.ParentId);
                wishChapterIdsMap.put(newWish.AccountId, newWish);
                wishType = constant.wishAssistRT;
            } else if(newWish.RecordTypeId == wishGrantRecordTypeId) {
                parentIdsSet.add(newWish.ParentId);
                wishChapterIdsMap.put(newWish.AccountId, newWish);
                wishType = constant.wishGrantRT;
                wishGrantedSubCaseList.add(newWish);
                wishGrantedSubCaseIdSet.add(newWish.ParentId);
            } else if(newWish.RecordTypeId == parentWishRecordTypeId ){
                parentIdsSet.add(newWish.Id);
                chapterNames.add(newWish.ChapterName__c);
            }
            
            cg__CaseFile__c PicFolder =new cg__CaseFile__c();
            PicFolder.cg__Case__c = newWish.Id;
            PicFolder.cg__Content_Type__c = 'Folder';
            PicFolder.cg__File_Name__c = 'Photos';
            PicFolder.cg__WIP__c = false;
            casefiles.add(PicFolder);
            
            cg__CaseFile__c DocFolder =new cg__CaseFile__c();
            DocFolder.cg__Case__c = newWish.Id  ;
            DocFolder.cg__Content_Type__c = 'Folder';
            DocFolder.cg__File_Name__c = 'Documents';
            DocFolder.cg__WIP__c = false;
            casefiles.add(DocFolder);
            
            cg__CaseFile__c VedioFolder =new cg__CaseFile__c();
            VedioFolder.cg__Case__c = newWish.Id  ;
            VedioFolder.cg__Content_Type__c = 'Folder';
            VedioFolder.cg__File_Name__c = 'Videos';
            VedioFolder.cg__WIP__c = false;
            casefiles.add(VedioFolder);
        }
        
        if (casefiles.size()>0){
            if(!Test.isRunningTest()) {
                insert casefiles;
            }
        }
        System.debug('Parent Wishes 01:' + parentIdsSet);
        System.debug('Parent Wishes 02:' + chapterNames);
        //Commented
        if (parentIdsSet.size()>0 && chapterNames.size()>0){
            CaseTriggerHandler.UpdateWishRecordIdentifier(parentIdsSet,chapterNames,parentWishRecordTypeId);
        } 
        if(wishChapterIdsMap.size()>0 && parentIdsSet.size()>0 && wishType != null) {
            CaseTriggerHandler.createActionTracks(wishType,wishChapterIdsMap,parentIdsSet);
        }
        
        if(wishDeterminationSubCaseList.size() > 0 && wishDeterminationSubCaseIds.size() > 0) {
            System.debug('>>>>>>>>>>Record Val>>>>>>');
            CaseTriggerHandler.wishDeterminationSubCaseTaskCreation(wishDeterminationSubCaseList, wishDeterminationSubCaseIds);
        }
        
        if(wishPlaningAnticipationSubCaseMap.size() > 0 && wishTypeSet.size() > 0) {
            System.debug('WishPlanningInitiated>>>>>>');
            CaseTriggerHandler.wishPlaningAnticipationTaskCreation(wishPlaningAnticipationSubCaseMap);
        }
        
        if(wishGrantedSubCaseList.size() > 0 &&  wishGrantedSubCaseIdSet.size() > 0) {
            CaseTriggerHandler.wishGrantedSubCaseTaskCreation(wishGrantedSubCaseList, wishGrantedSubCaseIdSet);
        }
        
    }
    //Used to create child wish for Parent wish
    //Used to submit parent wish for approval once the required volunteer assigend to Wish
    if(Trigger.isUpdate && Trigger.isAfter) {
        
        Set<Id> newCaseIdsSet = new Set<Id>();
        Set<Id> wishIdsSet = new Set<Id>();
        List<Case> PartAWishList = new List<Case>();
        List<Case> childCreationWishList = new List<Case>();
        List<Case> wishListForApprovalList = new List<Case>();
        String wishType = '';
        list<Volunteer_Opportunity__c> volunteerOppList = new list<Volunteer_Opportunity__c>();
        Map<string,Case> caseMap = new Map<string,Case>();
        Map<string,Chapter_Role__c> chapterRoleMap = new Map<string,Chapter_Role__c>();
        Set<Id> wishIds = new Set<Id>();
        Map<Id,Case> updateWishChildInfo = new Map<Id,Case>();
        Map<Id,String> approvedBudgetStatus = new Map<Id,String>();
        Set<Id> approvedBudgetIdsSet = new Set<Id>();
        Map<Id, case> interviewTaskParentIdMap = new Map<Id, Case>();
        Map<Id, case> presentationOpenTaskParentIdMap = new Map<Id, Case>();
        Map<Id, case> presentationCloseTaskParentIdMap = new Map<Id, Case>();
        Set<Id> interViewCloseTaskIdsSet = new Set<Id>();
        Set<Id> interViewOpenTaskIdsSet = new Set<Id>();
        Set<Id> presentationCloseTaskIdsSet = new Set<Id>();
        Set<Id> presentationOpenTaskIdsSet = new Set<Id>();
        Set<Id> ParentIdSet = new Set<Id>();
        
        Map<Id, Date> dueDateMap = new Map<Id, Date>();
        Map<Id, Case> updateAniticipationTaskMap = new Map<Id,Case>();
        Map<Id, Case> removeAniticipationTaskMap = new Map<Id,Case>();
        Map<Id,Case> UpdateAllOpenTasks = new Map<Id,Case>();
        Set<String> wishTypes = new Set<String>();
        Map<Id,Case> caseIdsMap = new Map<Id, Case>();
        Set<String> newWishTypeSet = new Set<String>();
        Set<Id> wishChildIdSet = new Set<Id>();
        Set<Id> caseTeamMemberParentIdSet = new Set<Id>();
        Set<Id> revokingContactIdSet = new Set<Id>();
        Set<Id> presentationIdsSet = new Set<Id>();
        Set<Id> endDateIdSet = new Set<Id>();
        List<Contact> updateWishchildList = new List<Contact>();
        Set<Id> conceptApprovalParentIdSet = new Set<Id>(); //Parent Id for closing Concept Approval task
        Set<string> updatedApprovedLeadInfoSet = new Set<string>();
        Set<string> updatedDnqLeadInfoSet = new Set<string>();
        String DiagnosisVerificationReviewRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Diagnosis Verification Review').getRecordTypeId();
        List<Case> diagnosisVerificationCaseList = new List<Case>();
        for(Case caseMemberCheck : Trigger.New) {
            
            if(Trigger.oldMap.get(caseMemberCheck.Id).Wish_Type__c != caseMemberCheck.Wish_Type__c  && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                System.debug('>>>>>>DelAnticipationRecInitiated>>>>>');
                caseIdsMap.put(caseMemberCheck.Id, caseMemberCheck);
                newWishTypeSet.add(caseMemberCheck.Wish_Type__c);
            }
           /* Used to close the wish determine case and open the new planning and Granting and Impact sub cases will open. */
          if(caseMemberCheck.status == 'Wish Determined' && caseMemberCheck.Sub_Status__c == 'Within Policy' && caseMemberCheck.Wish_Type__c != Null && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId){
                   ParentIdSet.add(caseMemberCheck.Id);
           }
           
            if(caseMemberCheck.Status == 'Escalated' && caseMemberCheck.RecordTypeId == diagnosisVerificationRT && caseMemberCheck.Status != Trigger.oldMap.get(caseMemberCheck.Id).Status) {
                diagnosisVerificationCaseList.add(caseMemberCheck);
            }
            
            if((caseMemberCheck.Status == 'Approved - Chapter Staff' && trigger.oldMap.get(caseMemberCheck.Id).Status != 'Approved - Chapter Staff') || (caseMemberCheck.Status == 'Approved - Chapter Medical Advisor' && trigger.oldMap.get(caseMemberCheck.Id).Status != 'Approved - Chapter Medical Advisor') || 
               (caseMemberCheck.Status == 'Approved - National Staff' && trigger.oldMap.get(caseMemberCheck.Id).Status != 'Approved - National Staff')||(caseMemberCheck.Status == 'Approved - National Medical Council' && trigger.oldMap.get(caseMemberCheck.Id).Status != 'Approved - National Medical Council') && 
               CaseMemberCheck.RecordTypeid == DiagnosisVerificationReviewRecordTypeId ){
                   updatedApprovedLeadInfoSet.add(caseMemberCheck.Lead__c);
                   
               }
            else if((caseMemberCheck.Status == 'DNQ - Chapter Staff' || caseMemberCheck.Status == 'DNQ - Chapter Medical Advisor' || caseMemberCheck.Status == 'DNQ - National Staff'||
                     caseMemberCheck.Status == 'DNQ - National Medical Council')&& CaseMemberCheck.RecordTypeid == DiagnosisVerificationReviewRecordTypeId && trigger.oldMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status){
                         updatedDnqLeadInfoSet.add(caseMemberCheck.Lead__c);
                         
                     }
            
            if(updatedApprovedLeadInfoSet.size()>0 || updatedDnqLeadInfoSet.size()>0 ){
                
                CaseTriggerHandler.updateLeadStatus(updatedApprovedLeadInfoSet,updatedDnqLeadInfoSet);
                
            }
            
            
            if(caseMemberCheck.Sub_Status__c == 'Abandoned' && Trigger.Oldmap.get(caseMemberCheck.id).Sub_Status__c!= 'Abandoned' 
               && CaseMemberCheck.isClosed == True)
            {
                UpdateAllOpenTasks.put(caseMemberCheck.id,CaseMemberCheck);
            }
            
            if(CaseMemberCheck.Interview_date__c != null && Trigger.oldMap.get(CaseMemberCheck.id).Interview_date__c != CaseMemberCheck.Interview_date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                System.debug('>>>>>>>>>>UpdateInterviewDate1');
                dueDateMap.put(CaseMemberCheck.Id,CaseMemberCheck.Interview_date__c);
            }
            
            //Used to remove the access for Volunteer user to Wish, when the parent wish is completed.
            if((CaseMemberCheck.Status == 'Completed' || CaseMemberCheck.Status == 'Granted' || CaseMemberCheck.Status == 'Closed')  && Trigger.oldMap.get(CaseMemberCheck.Id).Status != CaseMemberCheck.Status) {
                caseTeamMemberParentIdSet.add(CaseMemberCheck.Id);
                revokingContactIdSet.add(CaseMemberCheck.ContactId);
            }
            
            if(CaseMemberCheck.Interview_date__c != null && Trigger.oldMap.get(CaseMemberCheck.id).Interview_date__c == null && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId)
            {
                
                interViewCloseTaskIdsSet.add(caseMemberCheck.Id);
                interviewTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
            }
            
            if(CaseMemberCheck.Interview_date__c == null && Trigger.oldMap.get(CaseMemberCheck.id).Interview_date__c != null && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                System.debug('>>>>>>>>>>UpdateInterviewDate3');
                interViewOpenTaskIdsSet.add(caseMemberCheck.Id);
                interviewTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
            }
            
            // Wish Granted task
            
            if(CaseMemberCheck.Presentation_Date__c != null && Trigger.oldMap.get(CaseMemberCheck.id).Presentation_Date__c != CaseMemberCheck.Presentation_Date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId)
            {
                System.debug('Not Null>>>>>>>Date');
                presentationIdsSet.add(caseMemberCheck.Id);
                presentationCloseTaskIdsSet.add(caseMemberCheck.Id);
                presentationCloseTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
            } if(CaseMemberCheck.Presentation_Date__c == null && Trigger.oldMap.get(CaseMemberCheck.id).Presentation_Date__c != CaseMemberCheck.Presentation_Date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                System.debug('Null>>>>>>>Date');
                presentationIdsSet.add(caseMemberCheck.Id);
                presentationOpenTaskIdsSet.add(caseMemberCheck.Id);
                presentationCloseTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
            }
            
            // Wish Granted task
            if(CaseMemberCheck.End_Date__c != null && Trigger.oldMap.get(CaseMemberCheck.id).End_Date__c != CaseMemberCheck.End_Date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId)
            {
                endDateIdSet.add(caseMemberCheck.Id);
                System.debug('Not Null>>>>>>>Date');
                presentationCloseTaskIdsSet.add(caseMemberCheck.Id);
                presentationCloseTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
            }
            
            if(CaseMemberCheck.End_Date__c == null && Trigger.oldMap.get(CaseMemberCheck.id).End_Date__c != CaseMemberCheck.End_Date__c && CaseMemberCheck.RecordTypeid == parentWishRecordTypeId) {
                System.debug('Null>>>>>>>Date');
                endDateIdSet.add(caseMemberCheck.Id);
                presentationOpenTaskIdsSet.add(caseMemberCheck.Id);
                presentationCloseTaskParentIdMap.put(caseMemberCheck.Id,caseMemberCheck);
            }
            //For closing concept approval task when wish status set to Wish Determined within policy
            if((CaseMemberCheck.Status == 'Wish Determined' && CaseMemberCheck.Sub_Status__c == 'Within Policy') && (CaseMemberCheck.Status != Trigger.oldMap.get(CaseMemberCheck.Id).Status || CaseMemberCheck.Sub_Status__c != Trigger.oldMap.get(CaseMemberCheck.Id).Sub_Status__c)) {
                conceptApprovalParentIdSet.add(CaseMemberCheck.Id);
            }
            
            
            System.debug('>>>>>>>>>???????????>>>>>>>>>>>>>>>1');
            if(caseMemberCheck.Budget_Approval_Status__c == 'Approved'  && caseMemberCheck.Budget_Approval_Status__c != Trigger.oldMap.get(caseMemberCheck.Id).Budget_Approval_Status__c && caseMemberCheck.RecordTypeId == wishPlanningRecordTypeId) {
                System.debug('>>>>>>>>>???????????>>>>>>>>>>>>>>>1');
                approvedBudgetIdsSet.add(caseMemberCheck.ParentId);
                approvedBudgetStatus.put(caseMemberCheck.ParentId, caseMemberCheck.Budget_Approval_Status__c);
            }
            if(caseMemberCheck.Case_Member_Count__c == 2 && caseMemberCheck.Case_Member_Count__c != Trigger.oldMap.get(caseMemberCheck.Id).Case_Member_Count__c && caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                wishListForApprovalList.add(caseMemberCheck);
            }
            
            if(CaseMemberCheck.Status == 'Granted' && Trigger.oldMap.get(CaseMemberCheck.id).Status != 'Granted' && parentWishRecordTypeId == CaseMemberCheck.RecordTypeid)
            {
                wishIds.add(CaseMemberCheck.id);
            }
            
            if(caseMemberCheck.isApprove__c == true && caseMemberCheck.isApprove__c != Trigger.oldMap.get(caseMemberCheck.Id).isApprove__c) {
                if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId) {
                    childCreationWishList.add(caseMemberCheck);
                    wishType = 'Wish Determination'+'-'+wishDeterminationRecordTypeId;
                }else if(caseMemberCheck.RecordTypeId == wishDeterminationRecordTypeId) {
                    childCreationWishList.add(caseMemberCheck);
                    wishType = 'Wish Planning & Anticipation'+'-'+wishPlanningRecordTypeId;
                }else if(caseMemberCheck.RecordTypeId == wishPlanningRecordTypeId) {
                    childCreationWishList.add(caseMemberCheck);
                    wishType = 'Wish Assist'+'-'+wishAssistRecordTypeId;
                }else if(caseMemberCheck.RecordTypeId == wishAssistRecordTypeId) {
                    childCreationWishList.add(caseMemberCheck);
                    wishType = 'Wish Grant'+'-'+wishGrantRecordTypeId;
                }else if(caseMemberCheck.RecordTypeId == wishGrantRecordTypeId) {
                    childCreationWishList.add(caseMemberCheck);
                    wishType = 'Wish Effect'+'-'+wishGrantRecordTypeId;
                }
            }
            
            if(caseMemberCheck.Update_Wish_Child_Form_Info__c == True && Trigger.oldMap.get(caseMemberCheck.id).Update_Wish_Child_Form_Info__c != True)
            {
                updateWishChildInfo.put(caseMemberCheck.id,caseMemberCheck);
            } 
            
            if(caseMemberCheck.Status != trigger.oldMap.get(caseMemberCheck.Id).Status && caseMemberCheck.RecordTypeId == partARecordTypeId && caseMemberCheck.Lead__c != Null){
                PartAWishList.add(caseMemberCheck);
            }
            
            if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Anticipated_Start_Date__c == Null &&
               Trigger.oldMap.get(caseMemberCheck.id).Anticipated_Start_Date__c != Null)
            {
                removeAniticipationTaskMap.put(caseMemberCheck.id,caseMemberCheck);
            } else if(caseMemberCheck.RecordTypeId == parentWishRecordTypeId && caseMemberCheck.Anticipated_Start_Date__c != Null
                      && caseMemberCheck.Anticipated_Start_Date__c != Trigger.oldMap.get(caseMemberCheck.id).Anticipated_Start_Date__c)
            {
                updateAniticipationTaskMap.put(caseMemberCheck.id,caseMemberCheck);
                wishTypes.add(caseMemberCheck.wish_type__c);
            }
            
            
            if((caseMemberCheck.Status == 'Ready to Assign') && trigger.oldMap.get(caseMemberCheck.id).Status != 'Ready to Assign' && caseMemberCheck.ChapterName__c !=Null ){
                caseMap.put(caseMemberCheck.ChapterName__c,caseMemberCheck);
                System.debug('11111111111111Chapter roleMap' +  caseMap.keySet()); 
            }
            
        }
        
        
        
        
        /*-----------------------------------  Volunteer Opportunity creation under the parent case when status is changed as Ready To Assign ------------------ */
        if(caseMap.size()>0){
            for(Chapter_Role__c currentChapterRole :[SELECT ID,Chapter_Name__c,Chapter_Name__r.Name,Role_Name__r.Name FROM Chapter_Role__c WHERE Role_Name__r.Name =: 'Wish Granter' AND Chapter_Name__c IN: caseMap.keySet()]){
                chapterRoleMap.put(currentChapterRole.Chapter_Name__c,currentChapterRole);
                System.debug('************Chapter roleMap' +  chapterRoleMap); 
            }
        }
        
        for(Case currentCase : Trigger.new){
            if(chapterRoleMap.containsKey(currentCase.ChapterName__c)){
                system.debug('########chapterRoleMap' + chapterRoleMap);
                for(Integer i=0 ;i<=1;i++){
                    Volunteer_Opportunity__c volunteerOpp = new Volunteer_Opportunity__c();
                    volunteerOpp.Chapter_Role_Opportunity__c = chapterRoleMap.get(currentCase.ChapterName__c).Id;
                    volunteerOpp.Wish__c = currentCase.id;
                    volunteerOpp.RecordTypeId = volunteerOppWishRecordTypeId;
                    volunteerOpp.Is_Non_Viewable__c = True;
                    volunteerOpp.Chapter_Name__c = chapterRoleMap.get(currentCase.ChapterName__c).Chapter_Name__c;
                    volunteerOppList.add(volunteerOpp);
                    system.debug('!!!!!!!!!!!VolunteerOpp' + volunteerOppList);
                }
                
            }
        }
        
        if(volunteerOppList.size()>0){
            INSERT volunteerOppList;
        }
        
        if(wishChildIdSet.size() >0){
            
            for(Contact dbWishchildCon : [SELECT Id,Name,Publicity_OK__c FROM Contact WHERE Id IN: wishChildIdSet]){
                
                Contact newCon = new Contact();
                newCon.Id = dbWishchildCon.Id;
                newCon.Publicity_OK__c = 'YES';
                updateWishchildList.add(newCon);
            }
        }
        if(updateWishchildList.size() > 0){
            update updateWishchildList;
        }
        if(caseIdsMap.size() > 0) {
            System.debug('>>>>>>DelAnticipationRec>>>>>');
            CaseTriggerHandler.deleteAnticipationTask(caseIdsMap,newWishTypeSet);
        }
        if(updateAniticipationTaskMap.size() > 0 || removeAniticipationTaskMap.size() >0)
        {
            CaseTriggerHandler.updateAnticipationTasks(updateAniticipationTaskMap,removeAniticipationTaskMap,wishTypes);
        }
        if(ParentIdSet.size() > 0)
            //CaseTriggerHandler.CreateSubCases(ParentIdSet);
        
        if(UpdateAllOpenTasks.size() > 0)
        {
            CaseTriggerHandler.UpdateTasksAsAbondoned(UpdateAllOpenTasks);
        }
        
        if(diagnosisVerificationCaseList.size() > 0) {
            CaseTriggerHandler.sendEmailToNationalMACTeam(diagnosisVerificationCaseList);
        }
        
        //Used to update caseTeam Member Role
        if(caseTeamMemberParentIdSet.size() > 0 && revokingContactIdSet.size() > 0) {
            CaseTriggerHandler.revokeWishPermissionForVolunteers(caseTeamMemberParentIdSet, revokingContactIdSet);
        }
        
        if(approvedBudgetIdsSet.size() > 0 && approvedBudgetStatus.size() > 0) {
            CaseTriggerHandler.matchBudgetData(approvedBudgetIdsSet, approvedBudgetStatus);
        }
        if(childCreationWishList.size()>0) {
            CaseTriggerHandler.createChildWish(childCreationWishList, wishType);
        }
        if(wishListForApprovalList.size()>0) {
            CaseTriggerHandler.submitForApproval(wishListForApprovalList);
        }
        
        if(PartAWishList.size() > 0){
            //  CaseTriggerHandler.UpdateLeadStatus(PartAWishList);
        }
        
        if(wishIds.size() > 0)
        {
            CaseTriggerHandler.UpdateVolunteerWishGranted(wishIds);
        }
        
        if(updateWishChildInfo.size() > 0)
        {
            WishChildFormValUpdate_AC.UpdateWishChildandWishFamily(updateWishChildInfo);
            //casehandler.casecreate(updateWishChildInfo);
        }
        
        if(dueDateMap.size() > 0 ) {
            CaseTriggerHandler.updateDeterminationTaskDueDates(dueDateMap);
        }
        if((interViewCloseTaskIdsSet.size() > 0 || interViewOpenTaskIdsSet.size() > 0) && interviewTaskParentIdMap.size() > 0) {
            CaseTriggerHandler.inTerviewTask(interViewCloseTaskIdsSet, interViewOpenTaskIdsSet, interviewTaskParentIdMap);
        }
        
        //Wish Granted Task
        if((presentationCloseTaskIdsSet.size() > 0 || presentationOpenTaskIdsSet.size() > 0) && presentationCloseTaskParentIdMap.size() > 0) {
            CaseTriggerHandler.wishGrantedPresentationTask(presentationCloseTaskIdsSet, presentationOpenTaskIdsSet, presentationCloseTaskParentIdMap,presentationIdsSet,endDateIdSet);
        }
        
        //Concept Approval Task auto close
        if(conceptApprovalParentIdSet.size() > 0) {
            CaseTriggerHandler.autoCloseTask(conceptApprovalParentIdSet);
        }

        //if(approvalReqList.size() > 0)
        // List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);
        
    }
}