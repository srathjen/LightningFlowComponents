/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record updated then it will update the values to corresponding fields and also
it update the field values to related objects like Account, contact, VolunteerOpportunity.
Modification Log: 
23/03/2018 - Sankar - WVC-1835
*******************************************************************************************************************/
Public class Case_OnBeforeUpdateTriggerHandler{
    
    Static  Constant_AC  constant = new Constant_Ac();   
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Static String chapterecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    
    /********************************************************************************************************************** 
    This method is used to get the case records new values and old values and those values are added into collections
    then it will passed to the coressponding controller method.
    *******************************************************************************************************************/
    public static void OnBeforeUpdate(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap){
        UserSetting__c usc = UserSetting__c.getValues(userinfo.getUserId());
        List<Case> budgetCaseList = new List<Case>();
        List<Case> receiveDateCaseList = new List<Case>();
        Set<Id> wishOwnerIdSet = new Set<Id>();
        Map<String,Case> wishChildInfoMap = new Map<String,case>();
        Map<Id,Case> caseMap = New Map<Id,Case>();
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        Set<Id> contactSet = new Set<Id>();
        Set<Id> parentWishIdsSet = new Set<Id>();
        List<Case>updateChildCaseList = new List<Case>();
        Set<Id> parentGrantedIdSet = new Set<Id>();
        Set<Id> parentIdSet = new Set<Id>();
        Map<Id,User> wishOwnerMap = new Map<Id,User>();
        Set<Id> compltedParentIdSet = new Set<Id>();
        Map<Id,Account> managerUserMap = new Map<Id,Account>();
        Map<Id,contact> contactMap = new Map<Id,Contact>();
        Set<Id> contactIds = new Set<Id>(); 
        Map<Id,Case> changedNationaltypeCaseMap = new Map<Id,Case>();
        Profile dbprofile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];        
        List<Account> dbAccountList = [SELECT Id,MAC_Email_del__c,Name,RecordTypeId FROM Account WHERE Name =: 'Make-A-Wish America' AND RecordTypeId =: chapterecordTypeId Limit 1];
        
        User currUser = [SELECT Id,UserRole.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        system.debug('currUser.UserRole.Name'+currUser.UserRole.Name);
        List<Chapter_Vs_Role__c> currUserChapter = [SELECT Chapter_Name__c FROM Chapter_Vs_Role__c WHERE Role_Name__c =: currUser.UserRole.Name LIMIT 1];
        //system.debug('currUserChapter[0].Chapter_Name__c'+currUserChapter[0].Chapter_Name__c);
        
        for(Case currentCase : newCaseMap.values())
        {
            if(currentCase.RecordTypeId == parentWishRecordTypeId || currentCase.RecordTypeId == wishDeterminationRecordTypeId  || currentCase.RecordTypeId == wishPlanningRecordTypeId || currentCase.RecordTypeId == wishAssistRecordTypeId || 
               currentCase.RecordTypeId == wishGrantRecordTypeId || currentCase.RecordTypeId == diagnosisVerificationRT )
                if(currentCase.RecordTypeId == parentWishRecordTypeId){
                  if(currentCase.OwnerId != Null && currentCase.OwnerId != oldCaseMap.get(currentCase.Id).OwnerId){
                        wishOwnerIdSet.add(currentCase.OwnerId);
                    }
                    if(currentCase.Comment_1__c != Null && oldCaseMap.get(currentCase.id).Comment_1__c != currentCase.Comment_1__c){
                        system.debug('@@ currentCase.Comment_1 @@'+currentCase.Comment_1__c);
                        currentCase.Comment__c = currentCase.Comment_1__c;
                    }
                    else if(currentCase.Comment_2__c != Null && oldCaseMap.get(currentCase.id).Comment_2__c != currentCase.Comment_2__c){
                        currentCase.Comment__c = currentCase.Comment_2__c;
                        system.debug('@@ currentCase.Comment_2 @@'+currentCase.Comment_2__c );
                    }
                    else if(currentCase.Comments__c != Null && oldCaseMap.get(currentCase.id).Comments__c != currentCase.Comments__c){
                        currentCase.Comment__c = currentCase.Comments__c;
                        system.debug('@@ currentCase.Comment_s @@'+currentCase.Comments__c );
                    }
                }
            if((currentCase.Status == 'Ready to Assign') && oldCaseMap.get(currentCase.id).Status !=  'Ready to Assign' && currentCase.RecordTypeId == parentWishRecordTypeId){
                caseMap.Put(currentCase.ChapterName__c,currentCase);
                currentCase.Ready_to_Assign_Date__c = Date.Today();
                parentCaseMap.put(currentCase.Id, currentCase);
                contactSet.add(currentCase.ContactId);
            }
            if((!currentCase.Rush__c) && oldCaseMap.get(currentCase.Id).Rush__c==True && currentCase.RecordTypeId == parentWishRecordTypeId){
                currentCase.Rush_Timeframe__c=Null;
                currentCase.Rush_Explanation__c=Null;
            }
            if(currentCase.status == 'Hold' && currentCase.status != oldCaseMap.get(currentCase.Id).Status && currentCase.RecordTypeId == parentWishRecordTypeId && (oldCaseMap.get(currentCase.Id).Status != 'Hold' || 
                                                                                                                                                                     oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved' || oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')){
                                                                                                                                                                         currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
                                                                                                                                                                     }
            if(currentCase.status == 'Inactive' &&  currentCase.status != oldCaseMap.get(currentCase.Id).Status && currentCase.RecordTypeId == parentWishRecordTypeId && (oldCaseMap.get(currentCase.Id).Status != 'Inactive' || 
                                                                                                                                                                          oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved' || oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')){
                                                                                                                                                                              currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
                                                                                                                                                                          }
            if(currentCase.status == 'Closed' && currentCase.status != oldCaseMap.get(currentCase.Id).Status && currentCase.RecordTypeId == parentWishRecordTypeId && (oldCaseMap.get(currentCase.Id).Status != 'Closed' || 
                                                                                                                                                                       oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved' || oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')){
                                                                                                                                                                           currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
                                                                                                                                                                       }
            if(currentCase.status == 'DNQ' && currentCase.status != oldCaseMap.get(currentCase.Id).Status && currentCase.RecordTypeId == parentWishRecordTypeId && (oldCaseMap.get(currentCase.Id).Status != 'DNQ' || 
                                                                                                                                                                    oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved' || oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')){
                                                                                                                                                                        currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
                                                                                                                                                                    }
            if(currentCase.status == 'Ready to Interview' && oldCaseMap.get(currentCase.Id).Status == 'Ready to Assign' && currentCase.RecordTypeId == parentWishRecordTypeId){
                currentCase.Sub_Status__c = 'Pending';
            }
            if(currentCase.RecordTypeId == diagnosisVerificationRT && currentCase.Local_MCA_Team__c != oldCaseMap.get(currentCase.Id).Local_MCA_Team__c) {
                currentCase.Chapter_MACEmail__c = currentCase.Medical_Advisor_Email__c;
            }

            if(currentCase.RecordTypeId == diagnosisVerificationRT && currentCase.status == 'Escalated' && oldCaseMap.get(currentCase.Id).Status ==  'Escalated' && currentCase.Case_Comment__c != oldCaseMap.get(currentCase.Id).Case_Comment__c){
                currentCase.isNationalReply__c = true;
            }
            if(currentCase.Comments__c != oldCaseMap.get(currentCase.Id).Comments__c && currentCase.RecordTypeId == parentWishRecordTypeId)
                currentCase.Air_Travel_Details__c = 'This wish does not involve air travel';
            if(currentCase.Comment_1__c != oldCaseMap.get(currentCase.Id).Comment_1__c && currentCase.RecordTypeId == parentWishRecordTypeId)  
                currentCase.Air_Travel_Details__c = 'I am fully aware of the medical research regarding air travel and feel it is appropriate for this child. I will make any necessary adjustments to the medical treatment plan prior to their travel dates';
            if(currentCase.Comment_2__c != oldCaseMap.get(currentCase.Id).Comment_2__c && currentCase.RecordTypeId == parentWishRecordTypeId)  
                currentCase.Air_Travel_Details__c = 'I do not support air travel for this child';
            if(currentCase.Appropriate_Comments__c != oldCaseMap.get(currentCase.Id).Appropriate_Comments__c && currentCase.RecordTypeId == parentWishRecordTypeId)
                currentCase.Wish_Clearance__c = 'Appropriate';
            if(currentCase.Please_Explain__c != oldCaseMap.get(currentCase.Id).Please_Explain__c && currentCase.RecordTypeId == parentWishRecordTypeId)
                currentCase.Wish_Clearance__c = 'Not Appropriate';
            if(currentCase.RecordTypeId == parentWishRecordTypeId && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && currentCase.Status == 'Wish Determined' && currentCase.Sub_Status__c == 'Within Policy' && currentCase.Wish_Type__c == Null)
                currentCase.Wish_Type__c.addError('Please Enter the value for Wish Type'); 
            if(currentCase.RecordTypeId == parentWishRecordTypeId && currentCase.Status == 'Wish Determined' && currentCase.Sub_Status__c == 'Within Policy' && currentCase.Wish_Type__c != Null){
                caseMap.Put(currentCase.ChapterName__c,currentCase);
            }
            //Update the wish clearance needed when teh wish national type is changed.
            if(currentCase.RecordTypeId == parentWishRecordTypeId && currentCase.Wish_Type__c != Null  && currentCase.Wish_Type__c  != oldCaseMap.get(currentCase.Id).Wish_Type__C){
                changedNationaltypeCaseMap.put(currentCase.Id,currentCase);
            }
            /* Used to close the wish determine case and open the new planning and Granting and Impact sub cases will open. */
            if(currentCase.status == 'Wish Determined' && currentCase.Sub_Status__c != oldCaseMap.get(currentCase.id).Sub_Status__c && currentCase.Sub_Status__c == 'Within Policy' && currentCase.Wish_Type__c != Null && currentCase.RecordTypeid == parentWishRecordTypeId){
                currentCase.Meet_PWL_Criteria__c = 'Yes';
                currentCase.Concept_Approval_Date__c = Date.Today();
                updateChildCaseList.add(currentCase);
            }
            if(currentCase.status == 'Wish Determined' && oldCaseMap.get(currentCase.id).status != 'Wish Determined' && currentCase.RecordTypeid == parentWishRecordTypeId){
                currentCase.Wish_Determined_Date__c = system.Today();
            }
            if(currentCase.RecordTypeId == parentWishRecordTypeId && (currentCase.Status == 'Budget Approval - Submitted' && oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted') || (currentCase.Status == 'Budget Approval - Approved' && oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved')){
                currentCase.Sub_Status__c = Null;
            }

            if(currentCase.Status == 'Escalated' && currentCase.RecordTypeId == diagnosisVerificationRT && oldCaseMap.get(currentCase.id).Status != 'Escalated'){
                currentCase.isNational__c = True;
                currentCase.MAC_Email__c = dbAccountList[0].MAC_Email_del__c;
            }                                      
            if((currentCase.Status == 'DNQ - National Staff' || currentCase.Status == 'DNQ - National Medical Council' || currentCase.Status == 'DNQ - Chapter Staff' || currentCase.Status == 'DNQ - Chapter Medical Advisor') && currentCase.RecordTypeId == diagnosisVerificationRT)
            {
                currentCase.DNQ_Date__c = Date.Today();
            }
            if((currentCase.Status == 'Completed') && (oldCaseMap.get(currentCase.id).Status != 'Completed') && currentCase.RecordTypeId == parentWishRecordTypeId ){
                budgetCaseList.add(currentCase);
            }
            if(currentCase.RecordTypeId == parentWishRecordTypeId && currentCase.Status != oldCaseMap.get(currentCase.Id).Status && (((currentCase.Status == 'Granted') && (oldCaseMap.get(currentCase.id).Status == 'Wish Scheduled')) || ((currentCase.Status == 'Completed') && (oldCaseMap.get(currentCase.id).Status != 'Completed')) /* ||
                                                                                                                                     ( currentCase.Status == 'DNQ'  || currentCase.Status == 'Closed' ) */)){
                                                                                                                                         receiveDateCaseList.add(currentCase);
                                                                                                                                     }
            if((currentCase.Status == 'DNQ' || currentCase.Status == 'Completed' || currentCase.Status == 'Closed') && currentCase.RecordTypeId == parentWishRecordTypeId ){
                currentCase.IsLocked__c = true;
            }
            if((currentCase.Status != 'DNQ' && oldCaseMap.get(currentCase.Id).Status == 'DNQ') || (currentCase.Status != 'Completed' && oldCaseMap.get(currentCase.Id).Status == 'Completed') || (currentCase.Status != 'Closed' && oldCaseMap.get(currentCase.Id).Status == 'Closed') ||  (currentCase.isClosed == false && oldCaseMap.get(currentCase.Id).isClosed == true) && 
               currentCase.RecordTypeId == parentWishRecordTypeId){
                   currentCase.IsLocked__c = false;
               }
          if((currentCase.RecordTypeId == wishDeterminationRecordTypeId || currentCase.RecordTypeId == wishPlanningRecordTypeId || currentCase.RecordTypeId == wishAssistRecordTypeId || currentCase.RecordTypeId == wishGrantRecordTypeId || currentCase.ParentId != Null) &&(
               dbprofile.Name != 'System Administrator' && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && RecursiveTriggerHandler.allowToEditRecord == FALSE)) {
                   parentIdSet.add(currentCase.parentId);
               }
            if( currentCase.IsLocked__c == true && oldCaseMap.get(currentCase.Id).IsLocked__c == true && usc != Null){
                if(usc.All_Closed_Cases_except_Abandoned__c == false && currentCase.Sub_Status__c != 'Abandoned' && currentCase.isClosed == True &&
                   dbprofile.Name != 'System Administrator' && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && currentCase.RecordTypeId == parentWishRecordTypeId && 
                   (!(currentCase.Status == 'Completed' && (currentCase.Adoptable__c != oldCaseMap.get(currentCase.Id).Adoptable__c || currentCase.Adopted__c != oldCaseMap.get(currentCase.Id).Adopted__c ||
                                                            currentCase.Adopted_By__c != oldCaseMap.get(currentCase.Id).Adopted_By__c ))) && RecursiveTriggerHandler.allowToEditRecord == FALSE) {
                                                                currentCase.addError('You have not Permission to edit this record.');
                                                            }
                
                if(usc.Edit_Abandoned_Cases__c== false && currentCase.Sub_Status__c == 'Abandoned' && currentCase.isClosed == True &&
                   dbprofile.Name != 'System Administrator' && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null &&  currentCase.RecordTypeId == parentWishRecordTypeId && RecursiveTriggerHandler.allowToEditRecord == FALSE) {
                       currentCase.addError('You have not Permission to edit this record.');
                   }
            }
            else if( currentCase.IsLocked__c == true && oldCaseMap.get(currentCase.Id).IsLocked__c == true && usc == Null &&
                    dbprofile.Name != 'System Administrator' && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && currentCase.RecordTypeId == parentWishRecordTypeId &&
                    (!(currentCase.Status == 'Completed' && (currentCase.Adoptable__c != oldCaseMap.get(currentCase.Id).Adoptable__c || currentCase.Adopted__c != oldCaseMap.get(currentCase.Id).Adopted__c ||
                                                             currentCase.Adopted_By__c != oldCaseMap.get(currentCase.Id).Adopted_By__c ))) && RecursiveTriggerHandler.allowToEditRecord == FALSE) {
                                                                 currentCase.addError('You have not Permission to edit this record.');
                                                             }
            if(currentCase.Sub_Status__c == 'Abandoned' && oldCaseMap.get(currentCase.id).Status == 'Granted' && usc == Null && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && currentCase.RecordTypeId == parentWishRecordTypeId){
                currentCase.addError('You have not Permission to update the granted case as abandoned');
            }
            else if(currentCase.Sub_Status__c == 'Abandoned' && oldCaseMap.get(currentCase.id).Status == 'Granted' && usc != Null && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && currentCase.RecordTypeId == parentWishRecordTypeId){
                if(usc.Abandon_the_Granted_case__c== false)
                    currentCase.addError('You have not Permission to update the granted case as abandoned');
            }
            if(currentCase.Status == 'Hold' && oldCaseMap.get(currentCase.id).Status != 'Hold' && currentCase.RecordTypeId == parentWishRecordTypeId){
                currentCase.Hold_Date__c = Date.Today();
            }
            else if(currentCase.Status == 'Inactive' && oldCaseMap.get(currentCase.id).Status != 'Inactive' && currentCase.RecordTypeId == parentWishRecordTypeId)
            {
                currentCase.Inactive_Date__c= Date.Today();
            }
            else if((currentCase.Status == 'Closed' || currentCase.Status == 'Completed') && oldCaseMap.get(currentCase.id).Status == 'Granted' && currentCase.RecordTypeId == parentWishRecordTypeId)
            {
                currentCase.Completed_date__c= Date.Today();
            }
            if(currentCase.Sub_Status__c == 'Abandoned' && currentCase.Sub_Status__c != 'Abandoned' && currentCase.RecordTypeId == parentWishRecordTypeId)
                currentCase.Closed_Date__c = Date.Today();
            
            if(currentCase.Update_Wish_Child_Form_Info__c == True && oldCaseMap.get(currentCase.id).Update_Wish_Child_Form_Info__c != True && currentCase.RecordTypeId == parentWishRecordTypeId){
              //   If(currUserChapter[0].Chapter_Name__c != currentCase.Hidden_Chapter_Name__c){
                         //  currentCase.addError('You don\'t have access to approve this record.Please contact your Administrator');
              // }
              // else
                    wishChildInfoMap.put(currentCase.id,currentCase);
            }
            if(currentCase.contactId != Null && currentCase.birthdate__c == Null && currentCase.RecordTypeId == parentWishRecordTypeId){
                contactIds.add(currentCase.contactId); 
            } 
        }
        
        if(contactIds.size() > 0) {
            contactMap.putAll([SELECT id,birthdate FROM Contact WHERE Id IN :contactIds LIMIT 50000]);
        }
        
        if(wishOwnerIdSet.size() > 0){
            for(User wishOwner : [SELECT Id,ManagerId,Manager.Name,Manager.Email,Email From User WHERE Id IN: wishOwnerIdSet AND ManagerId != Null LIMIT 50000]){
                wishOwnerMap.put(wishOwner.id,wishOwner);
            }
        }
        if(parentIdSet.Size() > 0){
            for(Case parentCase : [SELECT Id,Status FROM Case WHERE Status = 'Completed' AND  Id IN : parentIdSet AND RecordTypeId =: parentWishRecordTypeId LIMIT 50000]){
                compltedParentIdSet.Add(parentCase.Id);
            }
        }
        
        for(Case newCase : newCaseMap.values()){
            if(wishOwnerMap.containsKey(newCase.OwnerId)){
                if(wishOwnerMap.get(newCase.OwnerId).ManagerId != Null && newCase.RecordTypeId == parentWishRecordTypeId )
                {
                    newCase.Hidden_Wish_Owner_Manager__c  = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
                    newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
                }
            }
            if(contactMap.containsKey(newCase.contactId) && newCase.RecordTypeId == parentWishRecordTypeId) {
                if(contactMap.get(newCase.contactId).birthdate != Null)
                    newCase.birthdate__c = contactMap.get(newCase.contactId).birthdate;
            } 
            if(compltedParentIdSet.Contains(newCase.ParentId)){
                newCase.addError('You have not Permission to edit this record.');
            }
        }
        
        //Case Owner Old Logic
        if(caseMap.size() > 0 ){
            for(Account currentAccount : [SELECT ID,Volunteer_Manager__c,Wish_Co_ordinator__c FROM Account Where ID IN: caseMap.keyset() LIMIT 50000] ){
                managerUserMap.put(currentAccount.Id,currentAccount);
            }
        }
        
        if(managerUserMap.size() > 0){
            for(Case currentCase : newCaseMap.values()){
                if(managerUserMap.containsKey(currentCase.ChapterName__c) && currentCase.Status == 'Ready to Assign' && currentCase.Status != oldCaseMap.get(currentCase.Id).Status && currentCase.RecordTypeId == parentWishRecordTypeId){
                    if(managerUserMap.get(currentCase.ChapterName__c).Volunteer_Manager__c != Null) {
                        currentCase.OwnerId = managerUserMap.get(currentCase.ChapterName__c).Volunteer_Manager__c;
                    }
                }
                if(managerUserMap.containsKey(currentCase.ChapterName__c) && currentCase.RecordTypeId == parentWishRecordTypeId && currentCase.Status == 'Wish Determined' && currentCase.Sub_Status__c == 'Within Policy' && (oldCaseMap.get(currentCase.Id).Status != currentCase.Status || oldCaseMap.get(currentCase.Id).Sub_Status__c != currentCase.Sub_Status__c)) {
                    if(managerUserMap.get(currentCase.ChapterName__c).Wish_Co_ordinator__c != Null)
                        currentCase.OwnerId = managerUserMap.get(currentCase.ChapterName__c).Wish_Co_ordinator__c ;
                }
            }
        }
        //This is used to update the wish clearance needed based on the wish national type.
        //WVC-1804
        If(changedNationaltypeCaseMap.Size() > 0){
            Case_OnBeforeUpdateTriggerHandlerHelper.updateWishClearanceNeeded(changedNationaltypeCaseMap);
        }
        if(parentCaseMap.size() > 0) {
            Case_OnBeforeUpdateTriggerHandlerHelper.wishChildRegionValidation(parentCaseMap,contactSet);
        }
        if(budgetCaseList.size() >0){
            Case_OnBeforeUpdateTriggerHandlerHelper.checkBudgetActuals(budgetCaseList);
        }
        if(receiveDateCaseList.size() > 0){
            Case_OnBeforeUpdateTriggerHandlerHelper.checkreceivedDates(receiveDateCaseList);
        }
        if(wishChildInfoMap.size() > 0){
            WishChildFormValUpdate_AC.updateWishType(wishChildInfoMap);
        }
    }       
}