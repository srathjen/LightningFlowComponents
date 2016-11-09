/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan, Chandrasekar Nallusamy
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
    List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
    Set<Id> contactIds = new Set<Id>();
    Map<Id,contact> contactMap = new Map<Id,Contact>();
    
    // Mapping Birthdate from Contact to Wish.
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) { 
        Set<Id> PartAwishContactSet = new Set<Id>();
        Map<Id,Contact> PartAwishContactMap = new Map<Id,Contact>();
        String nationalRec;
        String email;
        
        if((Trigger.isUpdate) && Trigger.isBefore){
        id usc = UserSetting__c.getinstance(userinfo.getUserId()).id;
            Map<String,Case> caseMap = New Map<String,Case>();
            Map<String,User> managerUserMap = new Map<String,User>();
         //   Map<String,Case> updateWishChildInfo = new Map<String,Case>();
            
            for(Case currentCase : Trigger.new)
            {
                if((currentCase.Status == 'Ready to Assign') && (currentCase.Volunteer_Manager_Email__c != Null) &&
                   (currentCase.Volunteer_Manager_Name__c != Null) && trigger.oldmap.get(currentCase.id).Status !=  'Ready to Assign' && currentCase.RecordTypeId == parentWishRecordTypeId){
                       caseMap.Put(currentCase.Volunteer_Manager_Email__c,currentCase);
                   }
                
                if(currentCase.Sub_Status__c == 'Abandoned'){
                    currentCase.IsLocked__c = true;
                }
                
                if( currentCase.IsLocked__c == true && trigger.oldMap.get(currentCase.Id).IsLocked__c == true && usc == Null){
                    currentCase.addError('You have not Permission to edit this record.');
                }
                
           /*     if(currentCase.Update_Wish_Child_Form_Info__c == True && Trigger.oldMap.get(currentCase.id).Update_Wish_Child_Form_Info__c != True)
                {
                   updateWishChildInfo.put(currentCase.id,currentCase);
                }*/
                
            }
            for(User currentUser : [SELECT ID,Email FROM User Where Email IN: caseMap.keyset() ] ){
                
                managerUserMap.put(currentUser.Email,currentUser);
            }
            
            for(Case currentCase : Trigger.new){
                if(managerUserMap.containsKey(currentCase.Volunteer_Manager_Email__c)){
                    currentCase.OwnerId = managerUserMap.get(currentCase.Volunteer_Manager_Email__c).Id;
                }
            }
            
            
         /*   if(updateWishChildInfo.size() > 0)
            {
               WishChildFormValUpdate_AC.updateWishdetails(updateWishChildInfo);
            }*/
            
            
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
        Map<Id, Case> wishChapterIdsMap = new Map<Id,Case>();
        String wishType = '';
        List<cg__CaseFile__c> casefiles=new List<cg__CaseFile__c>();
        for(Case newWish : Trigger.New) {
            if(newWish.RecordTypeId == wishDeterminationRecordTypeId) {
                parentIdsSet.add(newWish.ParentId);
                wishChapterIdsMap.put(newWish.AccountId, newWish);
                wishType = constant.wishDeterminationRT;
            } else if(newWish.RecordTypeId == wishPlanningRecordTypeId) {
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
           if(!Test.isRunningTest())
            insert casefiles;
        }
        if(wishChapterIdsMap.size()>0 && parentIdsSet.size()>0 && wishType != null) {
            CaseTriggerHandler.createActionTracks(wishType,wishChapterIdsMap,parentIdsSet);
        }
        
    }
    //Used to create child wish for Parent wish
    //Used to submit parent wish for approval once the required volunteer assigend to Wis
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
        
        for(Case caseMemberCheck : Trigger.New) {
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
            
        /*    if(caseMemberCheck.Update_Wish_Child_Form_Info__c == True && Trigger.oldMap.get(caseMemberCheck.id).Update_Wish_Child_Form_Info__c != True)
            {
               updateWishChildInfo.put(caseMemberCheck.id,caseMemberCheck);
            } */
            
            if(caseMemberCheck.Status != trigger.oldMap.get(caseMemberCheck.Id).Status && caseMemberCheck.RecordTypeId == partARecordTypeId && caseMemberCheck.Lead__c != Null){
                PartAWishList.add(caseMemberCheck);
                system.debug('@@@@@ PartAWishList @@@@@@@'+PartAWishList);
            }
            
            
           /* if(caseMemberCheck.Sub_Status__c == 'Abandoned')
            {
                Approval.ProcessSubmitRequest approvalreq = new Approval.ProcessSubmitRequest();
                approvalreq.setComments('Submitting request for approval.');
                approvalreq.setObjectId(caseMemberCheck.id);
                approvalreq.setProcessDefinitionNameOrId('Case_Submit_for_Abandoned_Case_Approval');
                approvalreq.setSkipEntryCriteria(true);
                approvalReqList.add(approvalreq);
            }*/
        }
        
        if(childCreationWishList.size()>0) {
            CaseTriggerHandler.createChildWish(childCreationWishList, wishType);
        }
        if(wishListForApprovalList.size()>0) {
            CaseTriggerHandler.submitForApproval(wishListForApprovalList);
        }
        
        if(PartAWishList.size() > 0){
            CaseTriggerHandler.UpdateLeadStatus(PartAWishList);
        }
        
        if(wishIds.size() > 0)
        {
            CaseTriggerHandler.UpdateVolunteerWishGranted(wishIds);
        }
        
        if(updateWishChildInfo.size() > 0)
        {
         //  WishChildFormValUpdate_AC.UpdateWishChildandWishFamily(updateWishChildInfo);
        }
        
        /*-----------------------------------  Volunteer Opportunity creation under the parent case when status is changed as Ready To Assign ------------------ */
        for(Case currentCase :Trigger.new){
            
            if((currentCase.Status == 'Ready to Assign') && trigger.oldMap.get(currentCase.id).Status != 'Ready to Assign' && currentCase.Chapter_Name__c !=Null ){
                caseMap.put(currentCase.Chapter_Name__c,currentCase);
                System.debug('11111111111111Chapter roleMap' +  caseMap.keySet()); 
            }
        }
        
        for(Chapter_Role__c currentChapterRole :[SELECT ID,Chapter_Name__r.Name,Role_Name__r.Name FROM Chapter_Role__c WHERE Role_Name__r.Name =: 'Wish Granter' AND Chapter_Name__r.Name IN: caseMap.keySet()]){
            chapterRoleMap.put(currentChapterRole.Chapter_Name__r.Name,currentChapterRole);
            System.debug('************Chapter roleMap' +  chapterRoleMap); 
        }
        
        
        for(Case currentCase : Trigger.new){
            if(chapterRoleMap.containsKey(currentCase.Chapter_Name__c)){
                system.debug('########chapterRoleMap' + chapterRoleMap);
                for(Integer i=0 ;i<=1;i++){
                    Volunteer_Opportunity__c volunteerOpp = new Volunteer_Opportunity__c();
                    volunteerOpp.Chapter_Role_Opportunity__c = chapterRoleMap.get(currentCase.Chapter_Name__c).Id;
                    volunteerOpp.Wish__c = currentCase.id;
                    volunteerOpp.RecordTypeId = volunteerOppWishRecordTypeId;
                    volunteerOpp.Is_Non_Viewable__c = True;
                    volunteerOpp.Chapter_Name__c = chapterRoleMap.get(currentCase.Chapter_Name__c).Chapter_Name__c;
                    volunteerOppList.add(volunteerOpp);
                    system.debug('!!!!!!!!!!!VolunteerOpp' + volunteerOppList);
                }
                
            }
        }
        
        if(volunteerOppList.size()>0){
            INSERT volunteerOppList;
        }
        
        //if(approvalReqList.size() > 0)
           // List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);
        
    }
}