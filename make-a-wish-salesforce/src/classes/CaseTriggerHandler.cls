/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description :
1.'CreateActionTracks' method is used to carry CaseTeamMembers from Parent Wish to Child Wishes and Used to create
Tasks based on Chapters and Wish type from 'Chapter Action Track' custom object.
2.'CreateChildWish' method is used to create Child Wishes for Parent Wish.
3.'SubmitForApproval' method used to automatically submit Parent Wish for approval when required number of
Volunteers added to Parent Wish.
*******************************************************************************************************************/

public class CaseTriggerHandler {
    
    public static void UpdateWishRecordIdentifier(Set<Id> ParentIdsSet, Set<String> chapterNames, Id recTypeId){
        Integer increment;
        date FYDate = Date.today();
        Integer FYYear=Date.Today().year();
        System.debug('Parent Wishes 1.a:'+ ParentIdsSet);
        System.debug('Parent Wishes 1.b:'+ chapterNames);
        System.debug('Parent Wishes 1.c:'+ recTypeId);
        Map<String,office__c> accountOfficeMap = new Map<String,office__c>();
        Set<Id> accountId = new Set<Id>();
        List<Period> financialPeriod = [SELECT StartDate, EndDate,IsForecastPeriod,Type FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY];
        boolean IsFYChanged =false;
        if(financialPeriod.size()>0){
            if( (FYDate >= financialPeriod[0].StartDate && FYDate <= financialPeriod[0].EndDate) && (FYDate.addDays(-1)  >= financialPeriod[0].StartDate && FYDate.addDays(-1) <= financialPeriod[0].EndDate)){
                IsFYChanged = true;
            }
            FYYear = financialPeriod[0].EndDate.year();
        }
        
        for(Account currAccount : [SELECT ID FROM Account WHERE Name in : chapterNames]){
            accountId.add(currAccount.id);     
        }
        System.debug('Parent Wishes 1.1:'+ accountId);
        for(office__c currOffice : [SELECT Office_Id__c, Chapter__r.name,Chapter__c  FROM Office__c WHERE Chapter__c in : accountId ]){
            accountOfficeMap.put(currOffice.Chapter__r.Name,currOffice );
        }
        System.debug('Parent Wishes 1.2:'+ accountOfficeMap);
        List<Case> lstParentWishes=[SELECT Id, RecordTypeId, Unique_Wish_Record_Identifier__c,Fund_Id__c, ChapterName__c,ChapterName__r.Name  FROM Case WHERE Id In: ParentIdsSet and RecordTypeId =: recTypeId Order BY CreatedDate desc];
        List<Case> lstParentWisheRecordTypes = [SELECT Id, Unique_Wish_Record_Identifier__c, ChapterName__c,ChapterName__r.Name FROM Case WHERE RecordTypeId =: recTypeId and  Unique_Wish_Record_Identifier__c !=null Order BY CreatedDate desc Limit 2];
        
        System.debug('Parent Wishes 1.3:' + lstParentWishes);
        System.debug('Parent Wishes 1.4:' + lstParentWisheRecordTypes );
        // System.debug('Parent Wishes 1.4.1:' + lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c);
        if(IsFYChanged){
            if(lstParentWisheRecordTypes.size()>0 && lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c != Null){
                System.debug('Parent Wishes 1.4.2:');
                String wishRecordIdentifier=lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c;
                wishRecordIdentifier = wishRecordIdentifier.Right(5);
                System.debug('Parent Wishes 1.4.3:' + wishRecordIdentifier );
                increment = Integer.valueOf(wishRecordIdentifier) +1;
                System.debug('Parent Wishes 1.4.4:' + increment );
                //lstparentCases[0].Unique_Wish_Record_Identifier__c = i;
            }
            else{
                increment = 1;
            }
        }
        else
        {
            increment = 1;
        }
        
        String s = increment.format();
        System.debug('Parent Wishes 1.5:' + s);
        
        for(Case parentWishes: lstParentWishes){
            if(s.length()==4){
                s='0' + s;
            } else if(s.length()==3){
                s='00' + s;
            } else if(s.length()==2){
                s='000' + s;
            } else if(s.length()==1){
                s='0000' + s;
            }
            
            String temp = accountOfficeMap.containskey(parentWishes.ChapterName__r.Name) ? accountOfficeMap.get(parentWishes.ChapterName__r.Name).Office_Id__c : Null;
            System.debug('Parent Wishes 1.7:' + temp );
            if(temp!=Null)
            {
                parentWishes.Unique_Wish_Record_Identifier__c = temp.left(3) + '-' + FYYear + '-' + s;
                if(parentWishes.Fund_Id__c ==null){
                    parentWishes.Fund_Id__c = temp.left(3) + '-' + FYYear  + '-' + s;
                }
                
            }
            increment=increment+1;
            s= increment.format();
        } 
        
        //String officeId= lstChapterOfficeIds[0].Office_Id__c;
        // lstParentWishes[0].Unique_Wish_Record_Identifier__c= officeId.left(3) + '-' + FYYear.year() + '-' + increment;
        System.debug('Parent Wishes 1.8:' + lstParentWishes);
        update lstParentWishes;
        
    }
    
    /* Used to create action track for different stages based on Chapter and used to pull Case team members to child wishes*/
    public static void createActionTracks(String caseType, Map<Id, Case> caseChapterIdsMap, Set<Id> parentWishIdsSet) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Map<String, Case> chaptersWishMap = new Map<String, Case>();
        if(parentWishIdsSet.size()>0){
            Map<Id, List<CaseTeamMember>> parentCaseMembersMap = new Map<Id, List<CaseTeamMember>>();
            
            //Used to get case and its case team members
            for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : parentWishIdsSet]) {
                if(parentCaseMembersMap.containsKey(caseTeamMem.ParentId)) {
                    parentCaseMembersMap.get(caseTeamMem.ParentId).add(caseTeamMem);
                } else {
                    parentCaseMembersMap.put(caseTeamMem.ParentId, new list<CaseTeamMember>{caseTeamMem});
                }
            }
            List<CaseTeamMember> childWishTeamMembersList = new List<CaseTeamMember>();
            Map<String, List<Case>> wishDeterminationCases = new Map<String, List<Case>>();
            
            //Used to include the parent wish case team members to child wish case team
            for(Case addTeamMember : caseChapterIdsMap.values()) {
                chaptersWishMap.put(addTeamMember.ChapterName__r.Name, addTeamMember);
                if(parentCaseMembersMap.containsKey(addTeamMember.ParentId)) {
                    for(CaseTeamMember createWishTeamMember : parentCaseMembersMap.get(addTeamMember.ParentId)){
                        CaseTeamMember addWishTeamMember = new CaseTeamMember(MemberId = createWishTeamMember.MemberId,TeamRoleId = createWishTeamMember.TeamRoleId,ParentId = addTeamMember.Id);
                        childWishTeamMembersList.add(addWishTeamMember);
                    }
                }
                if(addTeamMember.RecordTypeId == wishDeterminationRecordTypeId) {
                    if(wishDeterminationCases.containsKey(addTeamMember.ChapterName__r.Name)) {
                        wishDeterminationCases.get(addTeamMember.ChapterName__r.Name).add(addTeamMember);
                    } else {
                        wishDeterminationCases.put(addTeamMember.ChapterName__r.Name, new List<Case>{addTeamMember});
                    }
                }
            }
            if(childWishTeamMembersList.size()>0) {
                insert childWishTeamMembersList;
            }
        }
        if(caseChapterIdsMap.size()>0) {
            List<Task> newTaskList = new List<Task>();
            Map<String,List<Chapter_Action_Track__c>> chapterActionTracksMap = new Map<string, List<Chapter_Action_Track__c>>();
            
            //Used to get chapter action details based on wish chapter
            for(Chapter_Action_Track__c chapterActions : [SELECT Id, Wish_Type__c, Assigned_To__c ,Due_Date__c,Recurring__c, Recurring_Frequency__c, Name, Chapter_Name__r.Name, Case_Type_Stage__c,Sort_Order__c,Task_Name__c FROM Chapter_Action_Track__c WHERE Chapter_Name__r.Name IN : chaptersWishMap.keySet() ORDER BY Sort_Order__c ASC]) {
                if(chapterActionTracksMap.containsKey(chapterActions.Wish_type__c)) {
                    chapterActionTracksMap.get(chapterActions.Wish_type__c).add(chapterActions);
                } else {
                    chapterActionTracksMap.put(chapterActions.Wish_type__c, new List<Chapter_Action_Track__c>{chapterActions});
                }
                
            }
            
            List<Task> taskList = new List<Task>();
            //Used to create new task for wish by looking into chapter action track object based on wish chapter, wish type and wish stage
            for(Case createTasks : caseChapterIdsMap.values()) {
                if(chapterActionTracksMap.containsKey(createTasks.Wish_type__c)) {
                    for(Chapter_Action_Track__c actionTrack : chapterActionTracksMap.get(createTasks.Wish_type__c)) {
                        if(createTasks.Wish_type__c == actionTrack.Wish_type__c && createTasks.Subject == actionTrack.Case_Type_Stage__c && createTasks.ChapterName__r.Name== actionTrack.Chapter_Name__r.Name && actionTrack.Sort_Order__c == 1) {
                            Task newTask = new Task();
                            newTask.WhatId = createTasks.Id;
                            newTask.WhoId = createTasks.ContactId;
                            newTask.Subject = actionTrack.Task_Name__c;
                            newTask.ActivityDate = System.today() + Integer.valueOf(actionTrack.Due_Date__c);
                            newTask.Sort_Order__c = actionTrack.Sort_Order__c;
                            newTask.TaskVolunteerRole__c = actionTrack.Assigned_To__c;
                            taskList.add(newTask);
                        }
                    } 
                }
            }
            if(taskList.size()>0) {
                //insert taskList;
            }
        }
    }    
    
    //Used to create child wish for Parent wish
    public static void createChildWish (List<Case> childCreationWishList, String wishType) {
        Constant_AC  constant = new Constant_Ac(); 
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        
        List<Case> newWishList = new List<Case>();
        for(Case wishDetails : childCreationWishList) {
            if(wishDetails.RecordTypeId == parentWishRecordTypeId) {
                Case newWish = new Case(ChapterName__c = wishDetails.ChapterName__c, Wish_Type__c ='Standard', Subject = wishType.split('-')[0], ParentId = wishDetails.Id, AccountId=wishDetails.AccountId,ContactId=wishDetails.ContactId,Origin = 'Web',RecordTypeId=wishType.split('-')[1], OwnerId = wishDetails.OwnerId);
                newWishList.add(newWish);
            } else{
                Case newWish = new Case(ChapterName__c = wishDetails.ChapterName__c, Wish_Type__c = wishDetails.Wish_type__c ,Subject = wishType.split('-')[0], ParentId = wishDetails.ParentId, AccountId=wishDetails.AccountId,ContactId=wishDetails.ContactId,Origin = 'Web',RecordTypeId=wishType.split('-')[1], OwnerId = wishDetails.OwnerId);
                newWishList.add(newWish);
            }
        }
        if(newWishList.size()>0) {
            insert newWishList;
        }
    }
    
    //Used to submit parent wish for approval once the required volunteer assigend to Wish
    public static void submitForApproval(List<Case> wishListForApproval) {
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        for(Case wishForApproval : wishListForApproval) {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Parent Wish Approval');
            approvalRequest.setObjectId(wishForApproval.id);
            approvalRequest.setProcessDefinitionNameOrId('Wish_Approval');
            approvalRequest.setSkipEntryCriteria(true);
            approvalRequestList.add(approvalRequest);
        }
        if(approvalRequestList.size()>0) {
            List<Approval.ProcessResult> resultList = Approval.process(approvalRequestList);
        }
    }
    // When the case status is updated the corresponding lead status should be update.
    public static void UpdateLeadStatus(List<Case> caseList){
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<Lead> updateLeadList = new List<Lead>();
        for(Case processdbcaseList : caseList){
            caseMap.Put(processdbcaseList.Lead__c,processdbcaseList);
            system.debug('@@@@@ caseMap @@@@@@@'+caseMap.Values());
        }
        
        if(caseMap.size() > 0){
            for(Lead dbLeads: [SELECT Id,Status,Sub_Status__c  FROM Lead WHERE Id in: caseMap.KeySet()]){
                if(caseMap.get(dbLeads.Id).Status == 'In progress')
                {
                    dbLeads.Sub_Status__c = 'Local';
                }
                
                if(caseMap.get(dbLeads.Id).Status == 'Escalated')
                {
                    system.debug('@@@@@ caseMap @@@@@@@'+caseMap.get(dbLeads.Id).Status);
                    dbLeads.Sub_Status__c = 'National';
                }
                
                if(caseMap.get(dbLeads.Id).Status == 'Medical Eligible')
                {
                    dbLeads.Status = 'Qualified';
                }
                
                if(caseMap.get(dbLeads.Id).Status == 'Denied')
                {
                    dbLeads.Status = 'DNQ';
                }
                
                updateLeadList.add(dbLeads);
                system.debug('@@@@@ updateLeadList @@@@@@@'+updateLeadList);
            }
            
        }
        
        if(updateLeadList.size() > 0)
            update updateLeadList;
    }
    
    public static void CheckBudgetActuals(List<Case> budgetCases) {
        Set<Id> ActualsMatch = new Set<Id>();
        Set<Id> budgetIds=new Set<Id>();
        Map<Id, List<String>> pandaCase =new Map<Id, List<String>>();
        Constant_AC  constant = new Constant_Ac();
        for(Case caseTemp : budgetCases){
            budgetIds.add(caseTemp.Id);
        }
        
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        system.debug('P&A Case data 1.1 :'+ budgetIds);
        system.debug('P&A Case data 1.2 :'+ wishPlanningRecordTypeId );
        system.debug('P&A Case data 1.3 :'+ budgetCases);
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        List<case> PandACaseList= [SELECT Id,ParentId, Absent_Parent_Form__c,Child_s_Medical_Summary_Form__c,Communication_Profile__c,Date_Liability_Release_Authorization__c,
                 Date_Received_for_Absent_Parent_Form__c,Date_Received_for_Child_s_Medical_Summar__c,Date_Received_for_Communication_Profile__c,
                 Date_Received_for_Entertainment_Sports__c,Date_Received_for_Guardianship_Document__c,Date_Received_for_Passports__c,
                 Date_Received_for_Single_Parent_Form__c,Date_Received_for_Visas__c,Date_Received_for_Wish_Safety_Authorizat__c,Date_Wish_Child_Form__c,
                 Date_Wish_Family_Form__c,Date_Wish_Information_Form__c,Entertainment_Sports_Wish_LOU__c,Guardianship_Document__c,
                 Liability_Release_and_Authorization__c,Passports__c,Single_Parent_Form__c,Visas__c,Wish_Child_Form__c,Wish_Family_Form__c,
                 Wish_Information_Form__c,Wish_Safety_Authorization_Part_B_Form__c 
                 FROM Case WHERE ParentId IN : budgetIds and RecordTypeId =: wishPlanningRecordTypeId];
        system.debug('P&A Case data 1 :'+ PandACaseList);
        for(Case panda : PandACaseList){
            if(panda.Absent_Parent_Form__c == true && panda.Date_Received_for_Absent_Parent_Form__c == null){
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Absent Parent Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Absent Parent Form when wish status is Completed.'); 
                } 
            }
            if(panda.Child_s_Medical_Summary_Form__c == true && panda.Date_Received_for_Child_s_Medical_Summar__c == null){
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Child’s Medical Summary Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Child’s Medical Summary Form when wish status is Completed.'); 
                } 
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Child’s Medical Summary Form when wish status is Completed.');
            }
            if(panda.Communication_Profile__c == true && panda.Date_Received_for_Communication_Profile__c == null){
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Communication Profile when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Communication Profile when wish status is Completed.'); 
                } 
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Communication Profile when wish status is Completed.');
            }
            if(panda.Entertainment_Sports_Wish_LOU__c == true && panda.Date_Received_for_Entertainment_Sports__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Entertainment & Sports when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Entertainment & Sports when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Entertainment & Sports when wish status is Completed.'); 
                } 
            }
            if(panda.Guardianship_Document__c == true && panda.Date_Received_for_Guardianship_Document__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Guardianship Document when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Guardianship Document when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Guardianship Document when wish status is Completed.'); 
                } 
            }
            if(panda.Liability_Release_and_Authorization__c == true && panda.Date_Liability_Release_Authorization__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Liability Release and Authorization when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Liability Release and Authorization when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Liability Release and Authorization when wish status is Completed.'); 
                } 
            }
            if(panda.Passports__c== true && panda.Date_Received_for_Passports__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Passports when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Passports when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Passports when wish status is Completed.'); 
                } 
            }
            if(panda.Single_Parent_Form__c == true && panda.Date_Received_for_Single_Parent_Form__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Single Parent Form when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Single Parent Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Single Parent Form when wish status is Completed.'); 
                } 
            }
            if(panda.Visas__c == true && panda.Date_Received_for_Visas__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Visas when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Visas when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Visas when wish status is Completed.'); 
                } 
            }
            if(panda.Wish_Child_Form__c == true && panda.Date_Wish_Child_Form__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Wish Child Form when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Wish Child Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Wish Child Form when wish status is Completed.'); 
                } 
            }
            if(panda.Wish_Family_Form__c == true && panda.Date_Wish_Family_Form__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Wish Family Form when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Wish Family Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Wish Family Form when wish status is Completed.'); 
                } 
            }
            if(panda.Wish_Information_Form__c == true && panda.Date_Wish_Information_Form__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Wish Information Form when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Wish Information Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Wish Information Form when wish status is Completed.'); 
                } 
            }
            if(panda.Wish_Safety_Authorization_Part_B_Form__c == true && panda.Date_Received_for_Wish_Safety_Authorizat__c == null){
                //pandaCase.put(panda.ParentId, 'There should be value on Date - Wish Safety Authorization Part B Form when wish status is Completed.');
                if(!pandaCase.containsKey(panda.ParentId)){
                    pandaCase.put(panda.ParentId, new List<String>{'There should be value on Date - Wish Safety Authorization Part B Form when wish status is Completed.'});    
                }else{
                    pandaCase.get(panda.ParentId).add('There should be value on Date - Wish Safety Authorization Part B Form when wish status is Completed.'); 
                } 
            }
            
        }
        system.debug('budget Info 1: ' + budgetIds);
        Map<Id, List<Wish_Expense__c>> wishExpenseListbyId= new Map<Id, List<Wish_Expense__c>>();
        List<Wish_Expense__c> wishExpenseList = [SELECT Id, Actual_Cash__c,Actual_In_Kind__c,FE_Posted_Cash__c, FE_Posted_In_Kind__c, Case__c FROM Wish_Expense__c WHERE Case__c In: budgetIds];
        system.debug('budget Info 2: ' + wishExpenseList );
        for(Id caseId : budgetIds){
           for(Wish_Expense__c wishExpense : wishExpenseList ){
               if( caseId == wishExpense.Case__c){
                   if(!wishExpenseListbyId.containsKey(caseId)){
                        wishExpenseListbyId.put(caseId, new List<Wish_Expense__c>{wishExpense });    
                   }else{
                        wishExpenseListbyId.get(caseId).add(wishExpense ); 
                   } 
               }
           } 
        }
        decimal totalActCash=0;
        decimal totalActInKind=0;
        decimal totalFECash=0;
        decimal totalFEInkind=0;
        system.debug('budget Info 3: ' + wishExpenseListbyId);
        for(Id IdStatus : wishExpenseListbyId.keySet()){
            for(Wish_Expense__c expenseSatus : wishExpenseListbyId.get(IdStatus)){
                if(expenseSatus.Actual_Cash__c != null){
                    totalActCash = totalActCash + expenseSatus.Actual_Cash__c;
                }
                if(expenseSatus.Actual_In_Kind__c!= null){
                    totalActInKind = totalActInKind + expenseSatus.Actual_In_Kind__c;
                }
                if(expenseSatus.FE_Posted_Cash__c!= null){
                    totalFECash = totalFECash  + expenseSatus.FE_Posted_Cash__c;
                }
                if(expenseSatus.FE_Posted_In_Kind__c!= null){
                    totalFEInkind = totalFEInkind + expenseSatus.FE_Posted_In_Kind__c;
                }
            }
            if( totalActCash != totalFECash || totalActInKind !=totalFEInkind ){
                ActualsMatch.add(IdStatus);
            }
            totalActCash =0;
            totalActInKind =0;
            totalFECash =0;
            totalFEInkind =0;
            
        }
        
        system.debug('budget Info 5: ' + ActualsMatch);
        system.debug('P&A Case data 2 :'+ pandaCase);
        for(Case caseTemp : budgetCases){
            if(ActualsMatch.contains(caseTemp.Id)){
                caseTemp.addError('The Wish Budget Actuals and FE posted values should be match');
            }
            for(Id pandaItem : pandaCase.keySet()){
                if(caseTemp.Id == pandaItem){
                    for(string str : pandaCase.get(pandaItem)) 
                        caseTemp.addError(str);
                }
            }
        }         
    }
    
    public static void matchBudgetData(Set<Id> approvedBudgetIdsSet, Map<Id, String> approvedBudgetStatus) {
        List<Wish_Expense__c> wishExpenseUpdateList = new List<Wish_Expense__c>();
        String caseApproveStatus;
        for(Wish_Expense__c updateRecord : [SELECT Id, Wish_Expense_Approval_Status__c,Budget_Approval_Status__c, Projected_Approval_Status__c,  Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c, Actual_Cash__c,Actual_In_Kind__c,Case__c FROM Wish_Expense__c WHERE Case__c =: approvedBudgetStatus.keySet()]) {
            caseApproveStatus = approvedBudgetStatus.get(updateRecord.Case__c) ;
            if(caseApproveStatus == 'Approved'){
                if(updateRecord.Budget_Approval_Status__c == 'Submitted'){
                    updateRecord.Budget_Approval_Status__c = 'Approved';
                    if(updateRecord.Projected_Cash__c == 0) {
                        updateRecord.Projected_Cash__c = updateRecord.Budget_Cash__c;
                    }
                    if(updateRecord.Projected_In_Kind__c == 0) {
                        updateRecord.Projected_In_Kind__c = updateRecord.Budget_In_Kind__c;
                    }
                }
                if(updateRecord.Projected_Approval_Status__c == 'Submitted'){
                    updateRecord.Projected_Approval_Status__c = 'Approved';
                }
            }
            wishExpenseUpdateList.add(updateRecord);
        }
        
        if(wishExpenseUpdateList.size() > 0) {
            Update wishExpenseUpdateList;
        }
    }
    
    public static void UpdateVolunteerWishGranted(Set<Id> wishIds)
    {
        
        List<Contact> updateContactList = new List<Contact>();
        for(Volunteer_Opportunity__c currVolOpp : [SELECT id,Volunteer_Name__c, Volunteer_Name__r.Number_of_wishes_active__c,
                                                   Volunteer_Name__r.Number_of_wishes_granted__c FROM Volunteer_Opportunity__c WHERE Wish__c IN :wishIds AND Volunteer_Name__c != Null])
        {
            
            if(currVolOpp.Volunteer_Name__c != Null)
            {
                
                Contact updateContact = new Contact();
                updateContact.id = currVolOpp.Volunteer_Name__c;
                if(currVolOpp.Volunteer_Name__r.Number_of_wishes_active__c > 0)
                    updateContact.Number_of_wishes_active__c = currVolOpp.Volunteer_Name__r.Number_of_wishes_active__c - 1;
                if(currVolOpp.Volunteer_Name__r.Number_of_wishes_granted__c > 0)
                    updateContact.Number_of_wishes_granted__c = currVolOpp.Volunteer_Name__r.Number_of_wishes_granted__c + 1;
                else
                   updateContact.Number_of_wishes_granted__c = 1;
                updateContactList.add(updateContact);
            }
            
        }
        if(updateContactList.size() > 0)
            Update updateContactList;
        
    }
    
    public static void wishDeterminationSubCaseTaskCreation(List<Case> caseList, Set<Id> caseIds) {
        
        Constant_AC  constant = new Constant_Ac();    
        Id defaultRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
        
        System.debug('>>>>>>>>>>wishDeterminationSubCaseTaskCreation>>>>>>');
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> wishDeterminationTaskList = new List<Task>();
        
        //Used to get case and its case team members
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : caseIds AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate DESC]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        
        List<WishDeterminationSubCaseTaskList__c> subTaskList = WishDeterminationSubCaseTaskList__c.getAll().values();
        System.debug('>>>>>>>>subTaskList>>>>>>>>>'+subTaskList);
        
        if(subTaskList.size() > 0) {
            for(Case createTasks : caseList) {
                for(WishDeterminationSubCaseTaskList__c createSubTask : subTaskList) {
                    Task newSubTask = new Task();
                    newSubTask.Subject = createSubTask.Task_Subject__c;
                    newSubTask.ActivityDate = System.Today() + Integer.valueOf(createSubTask.Due_Date__c);
                    newSubTask.WhatId = createTasks.ParentId;
                    newSubTask.RecordTypeId = defaultRecordTypeId;
                    newSubTask.WhoId = createTasks.ContactId;
                    if(caseTeamMemberMap.containsKey(createTasks.ParentId)) {
                        newSubTask.OwnerId = caseTeamMemberMap.get(createTasks.ParentId);
                    }
                    wishDeterminationTaskList.add(newSubTask);
                }
            }
            
            System.debug('>>>>>>>>>>>>>wishDeterminationTaskList>>>>>>>>>>>>>'+wishDeterminationTaskList);
            if(wishDeterminationTaskList.size() > 0) {
                insert wishDeterminationTaskList;
            }
        }
        
    }
    
    // Used to create interview task
    public static void inTerviewTask(Set<Id> interViewCloseTaskIdsSet, Set<Id> interViewOpenTaskIdsSet, Map<Id, Case> interviewTaskParentIdMap) {
        Constant_AC  constant = new Constant_Ac();    
        Id defaultRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        //Used to get case and its case team members
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : interviewTaskParentIdMap.keySet() AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate DESC]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        List<Task> updateTasks = new List<Task>();
        if(interViewCloseTaskIdsSet.size() > 0 ) {
            for(Task closeTask : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : interViewCloseTaskIdsSet AND Status != 'Completed']) {
                if(closeTask.Subject == 'Enter interview date') {
                    closeTask.Status = 'Completed';
                    updateTasks.add(closeTask);
                }
            }
        }
        if(interViewOpenTaskIdsSet.size() > 0 ) {
            for(Id parentId : interViewOpenTaskIdsSet) {
                Task newSubTask = new Task();
                newSubTask.Subject = 'Enter interview date';
                newSubTask.ActivityDate = System.Today() + 7;
                newSubTask.WhatId = parentId;
                newSubTask.RecordTypeId = defaultRecordTypeId;
                if(interviewTaskParentIdMap.containsKey(parentId))  {
                    newSubTask.WhoId = interviewTaskParentIdMap.get(parentId).contactId;
                }
                if(caseTeamMemberMap.containsKey(parentId)) {
                    newSubTask.OwnerId = caseTeamMemberMap.get(parentId);
                }
                updateTasks.add(newSubTask);
            }
        }
        if(updateTasks.size() > 0) {
            upsert updateTasks;
        }
        
    }
    
    // WishGranted Task
    public static void wishGrantedPresentationTask(Set<Id> interViewCloseTaskIdsSet, Set<Id> interViewOpenTaskIdsSet, Map<Id, Case> interviewTaskParentIdMap, Set<Id> presentationIdsSet, Set<Id> endDateIdSet) {
        System.debug('>>>interViewCloseTaskIdsSet'+interViewCloseTaskIdsSet+'interViewOpenTaskIdsSet>>>'+interViewOpenTaskIdsSet);
        Constant_AC  constant = new Constant_Ac();    
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantTaskRT).getRecordTypeId();
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        //Used to get case and its case team members
        Map<String,WishGrantedSubCaseTaskList__c> wishGrantedTaskDetailsMap = new Map<String,WishGrantedSubCaseTaskList__c>();
        
        for(WishGrantedSubCaseTaskList__c createSubTask : WishGrantedSubCaseTaskList__c.getAll().values()) {
            wishGrantedTaskDetailsMap.put(createSubTask.Task_Subject__c, createSubTask);
        }
       
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : interviewTaskParentIdMap.keySet() AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate DESC]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        List<Task> updateTasks = new List<Task>();
        if(interViewCloseTaskIdsSet.size() > 0 ) {
            System.debug('Not Null>>>>>>>Date111111');
            for(Task closeTask : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : interViewCloseTaskIdsSet AND Status != 'Completed' AND RecordTypeId =: wishGrantTaskRT]) {
                if(closeTask.Subject == 'Schedule Wish Presentation (add date, time, location name and address)' && presentationIdsSet.contains(closeTask.WhatId)) {
                    closeTask.Status = 'Completed';
                    updateTasks.add(closeTask);
                } 
                if(closeTask.Subject != 'Schedule Wish Presentation (add date, time, location name and address)' && closeTask.Subject != 'Secure in-kind donations for wish presentation') {
                    if(wishGrantedTaskDetailsMap.containsKey(closeTask.Subject)) {
                        Integer dueDateCalc = Integer.valueOf(wishGrantedTaskDetailsMap.get(closeTask.Subject).Due_Date__c);
                        if(presentationIdsSet.contains(closeTask.WhatId) && closeTask.Subject == 'Obtain itinerary and/or wish packet') {
                            closeTask.ActivityDate = interviewTaskParentIdMap.get(closeTask.WhatId).Presentation_Date__c.addDays(-dueDateCalc);
                        }
                        if(endDateIdSet.contains(closeTask.WhatId) && closeTask.Subject != 'Obtain itinerary and/or wish packet') {
                            closeTask.ActivityDate = interviewTaskParentIdMap.get(closeTask.WhatId).End_Date__c.addDays(-dueDateCalc);
                        }
                        updateTasks.add(closeTask);
                    }
                }
            }
        }
        if(interViewOpenTaskIdsSet.size() > 0 ) {
            System.debug('Null>>>>>>>Date1111');
            for(Id parentId : interViewOpenTaskIdsSet) {
                Task newSubTask = new Task();
                newSubTask.Subject = 'Schedule Wish Presentation (add date, time, location name and address)';
                if(interviewTaskParentIdMap.containsKey(parentId) && interviewTaskParentIdMap.get(parentId).Anticipated_Start_Date__c != null) {
                    newSubTask.ActivityDate = interviewTaskParentIdMap.get(parentId).Anticipated_Start_Date__c - 30;
                }
                
                newSubTask.WhatId = parentId;
                newSubTask.RecordTypeId = wishGrantTaskRT;
                if(interviewTaskParentIdMap.containsKey(parentId))  {
                    newSubTask.WhoId = interviewTaskParentIdMap.get(parentId).contactId;
                }
                if(caseTeamMemberMap.containsKey(parentId)) {
                    newSubTask.OwnerId = caseTeamMemberMap.get(parentId);
                }
                updateTasks.add(newSubTask);
            }
            
            for(Task changeTaskDueDate : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : interViewOpenTaskIdsSet AND Status != 'Completed' AND RecordTypeId =: wishGrantTaskRT AND Subject = 'Obtain itinerary and/or wish packet']) {
                changeTaskDueDate.ActivityDate = null;
                updateTasks.add(changeTaskDueDate);
            }
        }
        if(updateTasks.size() > 0) {
            upsert updateTasks;
        }
        
    }
    
    
    //Used to update wish determination Open activities due dates
    public static void updateDeterminationTaskDueDates(Map<Id,Date> dueDateMap) {
        List<Task> updateDueDates = new List<Task>();
        Set<Id> checkInDupRecord = new Set<Id>();
        for(Task closeTask : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : dueDateMap.keySet() AND Status != 'Completed']) {
            
            if(closeTask.Status != 'Completed') {
                if(closeTask.Subject == 'Procure Icebreaker Gift' || closeTask.Subject == 'Conduct Interview') {
                    closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId);
                }
                if(closeTask.Subject == 'Complete/upload wish family packet' || closeTask.Subject == 'Submit wish family packet to chapter approval') {
                    closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 5;
                }
                if(closeTask.Subject == 'Check in with the family every 30 days') {
                    closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 30;
                }
            } else if(closeTask.Status == 'Completed' && closeTask.Subject == 'Check in with the family every 30 days') {
                checkInDupRecord.add(closeTask.Id);
            }
            updateDueDates.add(closeTask);
        }
        if(updateDueDates.size() > 0) {
            for(Integer i=0; i< updateDueDates.size(); i++) {
                if(checkInDupRecord.contains(updateDueDates[i].Id)) {
                    updateDueDates.remove(i);
                }
            }
            update updateDueDates;
        }
        
    }
    
    //Used to create Activities for WishPlanning & Anticipation Wish
    public static void wishPlaningAnticipationTaskCreation(Map<Id, Case> wishPlaningAnticipationSubCaseMap) 
    {
        Constant_AC  constant = new Constant_Ac();    
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Date todayDate;
        List<Task> planingAnticipationTaskList = new List<Task>();
        Integer monthCount = 0;
        Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
        
        for(Chapter_Action_Track__c getTask : [SELECT Id, Task_Name__c, Chapter_Name__c, Weeks__c, Months__c ,Wish_type__c, Sort_Order__c 
                                               FROM Chapter_Action_Track__c 
                                               ORDER BY Sort_Order__c ASC]) 
        {
            if(chapterActionMap.containskey(getTask.Wish_type__c)) {
                chapterActionMap.get(getTask.Wish_type__c).add(getTask);
            } else {
                chapterActionMap.put(getTask.Wish_type__c, new List<Chapter_Action_Track__c>{getTask});
            }
        }
        
        for(Case currCase : [SELECT  id, Parent.Wish_type__c, Parent.ChapterName__c, Parent.OwnerId,  OwnerId, ParentId, Parent.Anticipated_Start_Date__c FROM Case
                             WHERE Id IN :wishPlaningAnticipationSubCaseMap.keySet() AND ParentId != Null
                             AND Parent.isClosed !=  True AND Parent.RecordTypeId = :parentWishRecordTypeId
                             AND Parent.Wish_type__c != Null]) 
        {
            
            if(chapterActionMap.containsKey(currCase.Parent.Wish_type__c))
            {
                for(Chapter_Action_Track__c currActionTrack : chapterActionMap.get(currCase.Parent.Wish_type__c))
                { 
                    if(currActionTrack.Chapter_Name__c == currCase.Parent.ChapterName__c) {
                        Task newTask = new Task();
                        newTask.WhatId = currCase.ParentId;
                        newTask.Subject = currActionTrack.Task_Name__c;
                        //newTask.OwnerId = currCase.OwnerId;
                        newTask.OwnerId = currCase.Parent.OwnerId;
                        newTask.RecordTypeId = taskPlanningRecordTypeId;
                        Integer months = Integer.valueOf(currActionTrack.Months__c);
                        Integer Weeks = Integer.valueOf(currActionTrack.Weeks__c);
                        Integer dayCalc;
                        if(months == Null) {
                            months = 0;
                        }
                        if(Weeks == Null) {
                            Weeks = 0;
                            dayCalc = 0;
                        } else {
                            dayCalc = Weeks * 7;
                        }
                        
                        if(currActionTrack.Months__c != null && currActionTrack.Months__c != 0 && currCase.Parent.Anticipated_Start_Date__c != null) {
                            if(dayCalc != null) {
                                todayDate = System.today().addDays(dayCalc);
                            } else {
                              todayDate = System.today();  
                            }
                            if(currCase.Parent.Anticipated_Start_Date__c > todayDate.addmonths(months))
                            {
                                newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addMonths(-months).addDays(dayCalc);
                            }
                            else
                            {
                                newTask.ActivityDate = Date.Today();
                            }
                        } else if((currActionTrack.Months__c == null || currActionTrack.Months__c == 0) && (currCase.Parent.Anticipated_Start_Date__c != null)) {
                            if(dayCalc != null) {
                                todayDate = System.today().addDays(dayCalc);
                            }
                            if(currCase.Parent.Anticipated_Start_Date__c > todayDate) {
                                newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addDays(-dayCalc);
                            } else {
                                newTask.ActivityDate = Date.Today();
                            }
                        } else {
                            
                        }
                        //}
                        planingAnticipationTaskList.add(newTask);
                    } 
                }
            } else if(chapterActionMap.containsKey('Other')) {
                for(Chapter_Action_Track__c currActionTrack : chapterActionMap.get('Other'))
                { 
                    if(currActionTrack.Chapter_Name__c == currCase.Parent.ChapterName__c) {
                        Task newTask = new Task();
                        newTask.WhatId = currCase.ParentId;
                        newTask.Subject = currActionTrack.Task_Name__c;
                        //newTask.OwnerId = currCase.OwnerId;
                        newTask.OwnerId = currCase.Parent.OwnerId;
                        newTask.RecordTypeId = taskPlanningRecordTypeId;
                        Integer months = Integer.valueOf(currActionTrack.Months__c);
                        Integer Weeks = Integer.valueOf(currActionTrack.Weeks__c);
                        Integer dayCalc;
                        if(months == Null) {
                            months = 0;
                        }
                        if(Weeks == Null) {
                            Weeks = 0;
                            dayCalc = 0;
                        } else {
                            dayCalc = Weeks * 7;
                        }
                       
                        if(currActionTrack.Months__c != null && currActionTrack.Months__c != 0 && currCase.Parent.Anticipated_Start_Date__c != null) {
                            if(dayCalc != null) {
                                todayDate = System.today().addDays(dayCalc);
                            } else {
                              todayDate = System.today();  
                            }
                            if(currCase.Parent.Anticipated_Start_Date__c > todayDate.addmonths(months))
                            {
                                newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addMonths(-months).addDays(dayCalc);
                            }
                            else
                            {
                                newTask.ActivityDate = Date.Today();
                            }
                        } else if((currActionTrack.Months__c == null || currActionTrack.Months__c == 0) && (currCase.Parent.Anticipated_Start_Date__c != null)) {
                            if(dayCalc != null) {
                                todayDate = System.today().addDays(dayCalc);
                            }
                            if(currCase.Parent.Anticipated_Start_Date__c > todayDate) {
                                newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addDays(-dayCalc);
                            } else {
                                newTask.ActivityDate = Date.Today();
                            }
                        } else {
                            
                        }
                        planingAnticipationTaskList.add(newTask);
                    } 
                }
            }
        }
        
        if(planingAnticipationTaskList.size() > 0) {
            insert planingAnticipationTaskList;
        }
    }
    
    //Used to update WishPlanning & Anticipation Open activities due dates if the anticipated date is updated
    public static void updateAnticipationTasks(Map<Id,Case> updateAniticipationTaskMap, Map<Id,Case> removeAniticipationTaskMap,set<string> wishTypes)
    {
        Constant_Ac constant = new Constant_Ac();
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id wishGrantRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        List<Task> taskListToUpdate = new List<Task>();
        
        integer months;
        Integer weeks;
        Integer dayCalc;
        Date todayDate;        
        if(removeAniticipationTaskMap.size() > 0)
        {
            for(Task updateTask : [SELECT id,ActivityDate FROM Task WHERE RecordTypeId = :taskPlanningRecordTypeId 
                                   AND whatId IN :removeAniticipationTaskMap.keySet() AND isClosed != True])
            {
                Task toUpdate = new Task();
                toUpdate.id = updateTask.id;
                toUpdate.ActivityDate = Null;
                taskListToUpdate.add(toUpdate);
            }
        } 
        
        if(updateAniticipationTaskMap.size() > 0)
        {
            
            Map<String,Chapter_Action_Track__c> chapterMap = new Map<String,Chapter_Action_Track__c>();
            
            for(Chapter_Action_Track__c getTask : [SELECT Id, Task_Name__c, Chapter_Name__c, Weeks__c, Months__c ,Wish_type__c, Sort_Order__c 
                                                   FROM Chapter_Action_Track__c 
                                                   ORDER BY Sort_Order__c ASC]) 
            {
                chapterMap.put(getTask.Task_Name__c+'-'+getTask.Chapter_Name__c, getTask);
            }
            
            for(Task updateTask : [SELECT id,ActivityDate,WhatId,Subject FROM Task WHERE RecordTypeId = :taskPlanningRecordTypeId 
                                   AND whatId IN :updateAniticipationTaskMap.keySet() AND isClosed != True])
            {
                if(updateAniticipationTaskMap.containsKey(updateTask.whatId) && chapterMap.containsKey(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c))
                { 
                    Task toUpdate = new Task();
                    toUpdate.id = updateTask.id;
                    if(chapterMap.containsKey(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c))
                    {
                        months = integer.valueOf(chapterMap.get(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c).months__c);
                        weeks = integer.valueOf(chapterMap.get(updateTask.Subject+'-'+updateAniticipationTaskMap.get(updateTask.WhatId).ChapterName__c).Weeks__c);
                        
                        if(months == Null) {
                            months = 0;
                        }
                        if(Weeks == Null) {
                            Weeks = 0;
                            dayCalc = 0;
                        } else {
                            dayCalc = Weeks * 7;
                        }
                        if(months != null && months != 0) {
                            if(dayCalc != null) {
                                todayDate = System.today().addDays(dayCalc);
                            } else {
                                todayDate = System.today();  
                            }
                            
                            if(updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c > todayDate.addmonths(months))
                            {
                                toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addMonths(-months).addDays(dayCalc);
                            }
                            else
                            {
                                toUpdate.ActivityDate = Date.Today();
                            }
                        } else if(months == null || months == 0) {
                            if(dayCalc != null) {
                                todayDate = System.today().addDays(dayCalc);
                            }
                            if(updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c > todayDate) {
                                toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addDays(-dayCalc);
                            } else {
                                toUpdate.ActivityDate = Date.Today();
                            }
                        }
                    }
                    
                    taskListToUpdate.add(toUpdate);
                }
            }
            
            
        }
        for(Task getGrantTask : [SELECT Id, WhatId, RecordTypeId, Subject FROM Task WHERE WhatId IN : updateAniticipationTaskMap.keySet() AND (Subject = 'Schedule Wish Presentation (add date, time, location name and address)' OR Subject = 'Secure in-kind donations for wish presentation') AND RecordTypeId =: wishGrantRT]) {
            getGrantTask.ActivityDate = updateAniticipationTaskMap.get(getGrantTask.whatId).Anticipated_Start_Date__c - 30;
            taskListToUpdate.add(getGrantTask);
        }
        if(taskListToUpdate.size() > 0) {
            update taskListToUpdate;
        }
    }
    
    public static void UpdateTasksAsAbondoned(Map<Id,Case> UpdateAllOpenTasks)
    {
        List<Task> updateTasksList = new List<Task>();
        for(Task currTask : [SELECT id,WhatId FROM TASK WHERE WhatId IN :UpdateAllOpenTasks.keyset() AND isClosed=false])
        {
            Task updateTask = new Task();
            updateTask.id = currTask.id;
            updateTask.Status = 'Abandoned';
            updateTasksList.add(updateTask);
        }
        if(updateTasksList.size() > 0)
            update updateTasksList;
    }
    
    //Used to update the role for Volunteer user to Wish, when the parent wish is completed.
    public static void revokeWishPermissionForVolunteers(Set<Id> parentWishIds, Set<Id> revokingContactIdSet) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantTaskRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Map<String,Id> caseTeamRoleMap = new Map<String, Id>();
        
        Set<Id> userIdSet = new Set<Id>();
        List<ContactShare> removeContactShareList = new List<ContactShare>();
        //List<CaseTeamRole> restrictivePermissionRole = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'Wish Granter (Wish Closed)'];
        
        for(CaseTeamRole caseRole : [SELECT Id, Name FROM CaseTeamRole]) {
            if(caseRole.Name.contains('Wish Closed')) {
                caseTeamRoleMap.put(caseRole.Name, caseRole.Id);
            }
        }
        
        List<CaseTeamMember> updateTeamRole = new List<CaseTeamMember>();
        Set<Id> childWishIdsSet = new Set<Id>();
        for(Case childCase : [SELECT Id FROM Case WHERE ParentId IN : parentWishIds]) {
            childWishIdsSet.add(childCase.Id);
        }
        Set<Id> memberIdSet = new Set<Id>();
        Set<Id> volunteerUsersSet = new Set<Id>();
        List<CaseTeamMember> caseTeamMemberList = [SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId FROM CaseTeamMember WHERE (ParentId IN : parentWishIds OR ParentId IN : childWishIdsSet)];
        
        if(caseTeamMemberList.size() > 0) {
            for(CaseTeamMember getCaseTeamMember : caseTeamMemberList) {
                memberIdSet.add(getCaseTeamMember.MemberId);
            }
            if(memberIdSet.size() > 0) {
                for(User getVolunteerUser : [SELECT Id, ContactId FROM User WHERE ContactId != null AND Id IN : memberIdSet]) {
                    volunteerUsersSet.add(getVolunteerUser.Id);
                }
            }
            
            for(CaseTeamMember getCaseTeamMember : [SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId FROM CaseTeamMember WHERE (ParentId IN : parentWishIds OR ParentId IN : childWishIdsSet)]) {
                String roleName = getCaseTeamMember.TeamRole.Name + ' (Wish Closed)';
                if(caseTeamRoleMap.size() > 0 && caseTeamRoleMap.containsKey(roleName) && volunteerUsersSet.contains(getCaseTeamMember.MemberId)) {
                    getCaseTeamMember.TeamRoleId = caseTeamRoleMap.get(roleName);
                }
                userIdSet.add(getCaseTeamMember.MemberId);
                updateTeamRole.add(getCaseTeamMember);
            }
            if(updateTeamRole.size() > 0) {
                update updateTeamRole;
            }
            
        }
        
        for(ContactShare conShare : [SELECT Id, UserOrGroupId, ContactId FROM ContactShare WHERE ContactId IN : revokingContactIdSet]) {
            System.debug('>>>>>>>>>>>ContactId>>'+conShare.ContactId);
            if(userIdSet.Contains(conShare.UserOrGroupId) && volunteerUsersSet.contains(conShare.UserOrGroupId)) {
                removeContactShareList.add(conShare);
            }
        }
        if(removeContactShareList.size() > 0) {
            delete removeContactShareList;
        }
        
    }
    
    //Used to delete Wishplanning & Anticipation open activities if wish type is changed
    public static void deleteAnticipationTask(Map<Id, Case> caseIdsMap, Set<String> newWishTypeSet) {
        Constant_Ac constant = new Constant_Ac();
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        
        List<Task> deleteOpenAnticipationTask = new List<Task>();
        for(Task oldAnticipationTask : [SELECT Id FROM Task WHERE WhatId IN : caseIdsMap.keySet() AND RecordTypeId =: taskPlanningRecordTypeId AND isClosed = false]) {
            deleteOpenAnticipationTask.add(oldAnticipationTask);
        }
        if(deleteOpenAnticipationTask.size() > 0) {
            delete deleteOpenAnticipationTask;
        }
        Map<Id, Case> planningCaseMap = new Map<Id, Case>();
        for(Case getAnticipationCase : [SELECT Id, ParentId, RecordTypeId FROM Case WHERE RecordTypeId =: wishPlanningRecordTypeId AND isClosed = false AND ParentId IN : caseIdsMap.keySet()]) {
            planningCaseMap.put(getAnticipationCase.Id, getAnticipationCase);
        }
        if(planningCaseMap.size() > 0) {
            wishPlaningAnticipationTaskCreation(planningCaseMap);
        }
    }
    
    public static void wishGrantedSubCaseTaskCreation(List<Case> caseList, Set<Id> caseIds) {
        
        
        Constant_AC  constant = new Constant_Ac();    
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantTaskRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        
        Map<Id, Date> parentMap = new Map<Id, Date>();
        
        for(Case parentCaseDetail : [SELECT Id, Anticipated_Start_Date__c FROM Case WHERE Id IN : caseIds AND RecordTypeId =: parentWishRecordTypeId]) {
            parentMap.put(parentCaseDetail.Id, parentCaseDetail.Anticipated_Start_Date__c);
        }
        
        System.debug('>>>>>>>>>>wishDeterminationSubCaseTaskCreation>>>>>>');
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> wishGrantedTaskList = new List<Task>();
        
        //Used to get case and its case team members
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name  FROM CaseTeamMember WHERE ParentId IN : caseIds AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate DESC]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        
        List<WishGrantedSubCaseTaskList__c> subTaskList = WishGrantedSubCaseTaskList__c.getAll().values();
        System.debug('>>>>>>>>subTaskList>>>>>>>>>'+subTaskList);
        
        if(subTaskList.size() > 0) {
            for(Case createTasks : caseList) {
                for(WishGrantedSubCaseTaskList__c createSubTask : subTaskList) {
                    Task newSubTask = new Task();
                    newSubTask.Subject = createSubTask.Task_Subject__c;
                    if(parentMap.containsKey(createTasks.ParentId) && parentMap.get(createTasks.ParentId) != null) {
                        if(createSubTask.Name == 'Task1' || createSubTask.Name == 'Task2') {
                            newSubTask.ActivityDate = parentMap.get(createTasks.ParentId) + Integer.valueOf(createSubTask.Due_Date__c);
                        } else {
                            
                        }
                    }
                    newSubTask.Description = createSubTask.Description__c;
                    newSubTask.WhatId = createTasks.ParentId;
                    newSubTask.RecordTypeId = wishGrantTaskRT;
                    newSubTask.WhoId = createTasks.ContactId;
                    if(caseTeamMemberMap.containsKey(createTasks.ParentId)) {
                        newSubTask.OwnerId = caseTeamMemberMap.get(createTasks.ParentId);
                    }
                    wishGrantedTaskList.add(newSubTask);
                }
            }
            
            if(wishGrantedTaskList.size() > 0) {
                insert wishGrantedTaskList;
            }
        }
        
    }
    
    //Close task automatically based on Criteria
    public static void autoCloseTask(Set<Id> conceptApprovalTaskParentIdSet) {
        
        List<Task> closeTaskList = new List<Task>();
        for(Task closeTask : [SELECT Id FROM Task WHERE Subject = 'Wish concept approval1' AND WhatId IN : conceptApprovalTaskParentIdSet]) {
            closeTask.Status = 'Completed';
            closeTaskList.add(closeTask);
        }
        if(closeTaskList.size() > 0) {
            update closeTaskList;
        }
    }
    
}