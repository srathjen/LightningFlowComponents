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
    
    public static void UpdateWishRecordIdentifier(Set<Id> ParentIdsSet, Set<Id> chapterIds, Id recTypeId){
        Integer increment;
        boolean IsFYChanged =false;
        Datetime  FYDate = Datetime.now();
        String dateOutput = FYDate.format('yy');
        Integer FYYear=integer.valueof(dateOutput);
        Map<String,office__c> accountOfficeMap = new Map<String,office__c>();
        Set<Id> accountId = new Set<Id>();
        List<Period> financialPeriod = [SELECT StartDate, EndDate,IsForecastPeriod,Type FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY];
        if(financialPeriod.size()>0){
            if( (Date.today() >= financialPeriod[0].StartDate && Date.today() <= financialPeriod[0].EndDate) && (Date.today().addDays(-1)  >= financialPeriod[0].StartDate && Date.today().addDays(-1) <= financialPeriod[0].EndDate)){
                IsFYChanged = true;
            }
            FYDate  = datetime.newInstance(financialPeriod[0].EndDate.year(), financialPeriod[0].EndDate.month(),financialPeriod[0].EndDate.day()); 
            FYYear = integer.valueof(FYDate.format('yy'));
        }
        for(office__c currOffice : [SELECT Office_Id__c, Chapter__r.name,Chapter__c  FROM Office__c WHERE Chapter__c in : chapterIds]){
            accountOfficeMap.put(currOffice.Chapter__r.Name,currOffice );
        }
        List<Case> lstParentWishes=[SELECT Id, RecordTypeId, Unique_Wish_Record_Identifier__c,Fund_Id__c, ChapterName__c,ChapterName__r.Name  FROM Case WHERE Id In: ParentIdsSet and RecordTypeId =: recTypeId Order BY CreatedDate desc];
        List<Case> lstParentWisheRecordTypes = [SELECT Id, Unique_Wish_Record_Identifier__c, ChapterName__c,ChapterName__r.Name FROM Case WHERE RecordTypeId =: recTypeId and  Unique_Wish_Record_Identifier__c !=null and Is_Migrated_Record__c = false Order BY CreatedDate desc Limit 2];
        System.debug('Parent Wishes 1:' + lstParentWishes);
        System.debug('Parent Wishes 2:' + lstParentWisheRecordTypes );
        if(IsFYChanged){
            if(lstParentWisheRecordTypes.size()>0 && lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c != Null){
                String wishRecordIdentifier=lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c;
                wishRecordIdentifier = wishRecordIdentifier.Right(5);
                increment = Integer.valueOf(wishRecordIdentifier) +1;
            }
            else{
                increment = 10001;
            }
        }
        else
        {
            increment = 10001;
        }
        for(Case parentWishes: lstParentWishes){
            String temp = accountOfficeMap.containskey(parentWishes.ChapterName__r.Name) ? accountOfficeMap.get(parentWishes.ChapterName__r.Name).Office_Id__c : Null;
            if(temp!=Null)
            {
                if(parentWishes.Unique_Wish_Record_Identifier__c == null){
                    parentWishes.Unique_Wish_Record_Identifier__c = temp.left(3) + '-' + FYYear + '-' + increment ;
                }
                if(parentWishes.Fund_Id__c == null){
                    parentWishes.Fund_Id__c = temp.left(3) + '-' + FYYear  + '-' + increment ;
                }
            }
            increment=increment+1;
        }
        System.debug('Parent Wishes 3:' + lstParentWishes);
        if(lstParentWishes.size() > 0)
            update lstParentWishes;
    } 
    
    /* Used to create action track for different stages based on Chapter and used to pull Case team members to child wishes*/
    public static void createActionTracks(String caseType, Map<Id, Case> caseChapterIdsMap, Set<Id> parentWishIdsSet) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
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
                chaptersWishMap.put(addTeamMember.ParentId, addTeamMember);
                if(parentCaseMembersMap.containsKey(addTeamMember.ParentId)) {
                    for(CaseTeamMember createWishTeamMember : parentCaseMembersMap.get(addTeamMember.ParentId)){
                        CaseTeamMember addWishTeamMember = new CaseTeamMember(MemberId = createWishTeamMember.MemberId,TeamRoleId = createWishTeamMember.TeamRoleId,ParentId = addTeamMember.Id);
                        childWishTeamMembersList.add(addWishTeamMember);
                    }
                }
                if(addTeamMember.RecordTypeId != parentWishRecordTypeId) {
                    if(wishDeterminationCases.containsKey(addTeamMember.Id)) {
                        wishDeterminationCases.get(addTeamMember.Id).add(addTeamMember);
                    } else {
                        wishDeterminationCases.put(addTeamMember.Id, new List<Case>{addTeamMember});
                    }
                }
            }
            if(childWishTeamMembersList.size()>0) {
                insert childWishTeamMembersList;
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
    
   
    // When the case status is updated the corresponding lead status should be update.
    public static void UpdateLeadStatus(List<Case> caseList){
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<Lead> updateLeadList = new List<Lead>();
        for(Case processdbcaseList : caseList){
            if(processdbcaseList.Status == 'Open' || processdbcaseList.Status == 'Escalated')
                caseMap.Put(processdbcaseList.Lead__c,processdbcaseList);
            system.debug('@@@@@ caseMap @@@@@@@'+caseMap.Values());
        }
        
        if(caseMap.size() > 0){
            for(Lead dbLeads: [SELECT Id,Status,Sub_Status__c,IsConverted FROM Lead WHERE Id in: caseMap.KeySet() AND IsConverted = False]){
                if(caseMap.get(dbLeads.Id).Status == 'Open')
                {
                    dbLeads.Sub_Status__c = 'Local';
                }
                
                if(caseMap.get(dbLeads.Id).Status == 'Escalated')
                {
                    system.debug('@@@@@ caseMap @@@@@@@'+caseMap.get(dbLeads.Id).Status);
                    dbLeads.Sub_Status__c = 'National';
                }
                
                /* if(caseMap.get(dbLeads.Id).Status == 'Medical Eligible')
{
dbLeads.Status = 'Qualified';
}

if(caseMap.get(dbLeads.Id).Status == 'Denied')
{
dbLeads.Status = 'DNQ';
}*/
                
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
        List<Wish_Expense__c> wishExpenseList = [SELECT Id, Budget_Cash__c, Budget_In_Kind__c, Actual_Cash__c,Actual_In_Kind__c,FE_Posted_Cash__c, FE_Posted_In_Kind__c, Case__c FROM Wish_Expense__c WHERE Case__c In: budgetIds];
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
        decimal totalBudCash=0;
        decimal totalBudInKind=0;
        decimal totalActCash=0;
        decimal totalActInKind=0;
        decimal totalFECash=0;
        decimal totalFEInkind=0;
        system.debug('budget Info 3: ' + wishExpenseListbyId);
        for(Id IdStatus : wishExpenseListbyId.keySet()){
            for(Wish_Expense__c expenseSatus : wishExpenseListbyId.get(IdStatus)){
                if(expenseSatus.Budget_Cash__c!= null){
                    totalBudCash= totalBudCash+ expenseSatus.Budget_Cash__c;
                }
                if(expenseSatus.Budget_In_Kind__c!= null){
                    totalBudInKind= totalBudInKind+ expenseSatus.Budget_In_Kind__c;
                }
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
            if(totalBudCash + totalBudInKind > 0 ){
                if( (totalActCash + totalActInKind  == 0 || totalFECash + totalFEInkind ==0) || (totalActCash != totalFECash || totalActInKind !=totalFEInkind )){
                    ActualsMatch.add(IdStatus);
                }
            }
            totalBudCash =0;
            totalBudInKind =0;
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
        Map<Id,Case> updateCaseMap = new Map<Id,Case>();
        List<Case> casebudgetapprovals = new List<Case>();
        Set<Id> approvedCaseIds = new Set<Id>();
        String budgetStatus='';
        String projectedStatus='';
        String caseApproveStatus;
        for(Wish_Expense__c updateRecord : [SELECT Id, Wish_Expense_Approval_Status__c,Budget_Approval_Status__c, Projected_Approval_Status__c,  
                                            Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c, Actual_Cash__c,
                                            Actual_In_Kind__c,Case__c, Case__r.Budget_Approved_Date__c FROM Wish_Expense__c WHERE Case__c =: approvedBudgetStatus.keySet()]) {
                                                caseApproveStatus = approvedBudgetStatus.get(updateRecord.Case__c) ;
                                                
                                                if(caseApproveStatus == 'Approved'){
                                                    if(updateRecord.Budget_Approval_Status__c == 'Submitted'){
                                                        updateRecord.Budget_Approval_Status__c = 'Approved';
                                                        budgetStatus='Approved';
                                                        if(updateRecord.Projected_Cash__c == 0) {
                                                            updateRecord.Projected_Cash__c = updateRecord.Budget_Cash__c;
                                                        }
                                                        if(updateRecord.Projected_In_Kind__c == 0) {
                                                            updateRecord.Projected_In_Kind__c = updateRecord.Budget_In_Kind__c;
                                                        }
                                                    }
                                                    if(updateRecord.Case__r.Budget_Approved_Date__c == Null)
                                                    {
                                                        Case updateCase = new Case();
                                                        updateCase.id = updateRecord.Case__c;
                                                        updateCase.Budget_Approved_Date__c = Date.Today();
                                                        updateCaseMap.put(updateRecord.Case__c,updateCase);
                                                        
                                                    }
                                                    if(updateRecord.Projected_Approval_Status__c == 'Submitted'){
                                                        updateRecord.Projected_Approval_Status__c = 'Approved';
                                                        projectedStatus= 'Approved';
                                                    }
                                                }
                                                wishExpenseUpdateList.add(updateRecord);
                                                if(!approvedCaseIds.contains(updateRecord.Case__c)){
                                                    approvedCaseIds.add(updateRecord.Case__c);
                                                }
                                            }
        if(wishExpenseUpdateList.size() > 0) {
            Update wishExpenseUpdateList;
        }
        if(updateCaseMap.size() >0)
            update updateCaseMap.values();
        
        if(budgetStatus=='Approved' || projectedStatus== 'Approved'){
            for(Id tempId : approvedCaseIds ){
                Case approvedCase = new Case();
                approvedCase.Id= tempId;
                if(budgetStatus=='Approved')
                    approvedCase.Budget_Status__c=budgetStatus;
                if(projectedStatus== 'Approved')
                    approvedCase.Projected_Status__c=projectedStatus; 
                casebudgetapprovals.add(approvedCase);       
            }
            update casebudgetapprovals;
        }
    }
   
    
    //1.Used to create list of task for volunteers when the wish determination case is created.
    //2.Based on "Wish Planning" recordtype, we are pulling the list of task which are stored under Chapter Action Track" object.
    //3.Task are assigned to the volunteer user who got initially approved for the case with the "Wish Granter" role.
    public static void wishDeterminationSubCaseTaskCreation(List<Case> caseList, Set<Id> caseIds) {
        
        Constant_AC  constant = new Constant_Ac();    
        Id defaultRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
        Id determinationChapterActionRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> wishDeterminationTaskList = new List<Task>();
        
        //Used to get case and its case team members
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : caseIds AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate DESC]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        
        //Used get all chapter action track for wish determination case
        List<Chapter_Action_Track__c> subTaskList = [SELECT Id, Task_Name__c, Description__c, Due_Days__c, Sort_Order__c FROM Chapter_Action_Track__c WHERE RecordtypeId =: determinationChapterActionRT];
        if(subTaskList.size() > 0) {
            for(Case createTasks : caseList) {
                for(Chapter_Action_Track__c createSubTask : subTaskList) {
                    Task newSubTask = new Task();
                    newSubTask.Subject = createSubTask.Task_Name__c;
                    if(createSubTask.Due_Days__c != null) {
                        newSubTask.ActivityDate = Date.Today() + Integer.valueOf(createSubTask.Due_Days__c);
                    }
                    newSubTask.WhatId = createTasks.ParentId;
                    newSubTask.RecordTypeId = defaultRecordTypeId;
                    newSubTask.WhoId = createTasks.ContactId;
                    newSubTask.Description = createSubTask.Description__c;
                    if(caseTeamMemberMap.containsKey(createTasks.ParentId)) {
                        newSubTask.OwnerId = caseTeamMemberMap.get(createTasks.ParentId);
                    }
                    wishDeterminationTaskList.add(newSubTask);
                }
            }
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
        Constant_AC  constant = new Constant_Ac();    
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
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
            
            for(Task closeTask : [SELECT Id, Status,Subject,RecordTypeId, WhatId FROM Task WHERE WhatId IN : interViewCloseTaskIdsSet AND Status != 'Completed']) {
                if(closeTask.RecordTypeId == wishGrantTaskRT) {
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
                } else {
                    if(closeTask.Subject == 'Wish Presentation not set' && presentationIdsSet.contains(closeTask.WhatId)) {
                        closeTask.Status = 'Completed';
                        updateTasks.add(closeTask);
                    } 
                }
                
            }
        }
        if(interViewOpenTaskIdsSet.size() > 0 ) {
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
    
    
    //1.If interview date is changed then the "Wish Determination" Task due dates are updated with new interview date
    public static void updateDeterminationTaskDueDates(Map<Id,Date> dueDateMap) {
        List<Task> updateDueDates = new List<Task>();
        Set<Id> checkInDupRecord = new Set<Id>();
        for(Task closeTask : [SELECT Id, Status,Subject, WhatId FROM Task WHERE WhatId IN : dueDateMap.keySet() AND Status != 'Completed']) {
            
            if(closeTask.Status != 'Completed') {
                if(closeTask.Subject == 'Procure Icebreaker Gift' || closeTask.Subject == 'Conduct initial wish visit') {
                    if(dueDateMap.get(closeTask.WhatId) != null ) {
                        closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId);
                    } else {
                        closeTask.ActivityDate = null;
                    }
                }
                if(closeTask.Subject == 'Confirm wish visit with wish family') {
                    if(dueDateMap.get(closeTask.WhatId) != null ) {
                        closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId).addDays(-2);
                    } else {
                        closeTask.ActivityDate = null;
                    }
                }
                if(closeTask.Subject == 'Complete/upload wish family packet') {
                    if(dueDateMap.get(closeTask.WhatId) != null ) {
                        closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 5;
                    } else {
                        closeTask.ActivityDate = null;
                    }
                }
                if(closeTask.Subject == 'Submit wish family packet to chapter approval') {
                    if(dueDateMap.get(closeTask.WhatId) != null ) {
                        closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 2;
                    } else {
                        closeTask.ActivityDate = null;
                    }
                }
                if(closeTask.Subject == 'Check in with the family every 30 days') {
                    if(dueDateMap.get(closeTask.WhatId) != null ) {
                        closeTask.ActivityDate = dueDateMap.get(closeTask.WhatId) + 30;
                    }
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
                                if(currActionTrack.Task_Name__c == 'Create Wish Receipt') {
                                    newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addDays(dayCalc);
                                } else {
                                    newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addDays(-dayCalc);
                                }
                                
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
                                if(currActionTrack.Task_Name__c == 'Create Wish Receipt') {
                                    newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addDays(dayCalc);
                                } else {
                                    newTask.ActivityDate = currCase.Parent.Anticipated_Start_Date__c.addDays(-dayCalc);
                                }
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
                                if(updateTask.Subject == 'Create Wish Receipt') {
                                    toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addDays(dayCalc);
                                } else {
                                    toUpdate.ActivityDate = updateAniticipationTaskMap.get(updateTask.whatId).Anticipated_Start_Date__c.addDays(-dayCalc);
                                }
                                
                                
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
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
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
    
    //Sprint 12 ticket
    public static void wishGrantedSubCaseTaskCreation(List<Case> caseList, Set<Id> caseIds) {
        
        
        Constant_AC  constant = new Constant_Ac();    
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        
        Map<Id, Date> parentMap = new Map<Id, Date>();
        
        for(Case parentCaseDetail : [SELECT Id, Anticipated_Start_Date__c FROM Case WHERE Id IN : caseIds AND RecordTypeId =: parentWishRecordTypeId]) {
            parentMap.put(parentCaseDetail.Id, parentCaseDetail.Anticipated_Start_Date__c);
        }
        
        Map<Id, Id> caseTeamMemberMap = new Map<Id, Id>();
        List<Task> wishGrantedTaskList = new List<Task>();
        
        //Used to get case and its case team members
        for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name  FROM CaseTeamMember WHERE ParentId IN : caseIds AND TeamRole.Name = 'Wish Granter' ORDER BY CreatedDate DESC]) {
            if(!caseTeamMemberMap.containsKey(caseTeamMem.ParentId)) {
                caseTeamMemberMap.put(caseTeamMem.ParentId,caseTeamMem.MemberId);
            } 
        }
        
        List<WishGrantedSubCaseTaskList__c> subTaskList = WishGrantedSubCaseTaskList__c.getAll().values();
        
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
        for(Task closeTask : [SELECT Id FROM Task WHERE Subject = 'Wish concept approval' AND WhatId IN : conceptApprovalTaskParentIdSet]) {
            closeTask.Status = 'Completed';
            closeTaskList.add(closeTask);
        }
        if(closeTaskList.size() > 0) {
            update closeTaskList;
        }
    }
    
    public static void updateLeadStatus(set<string> updatedApprovedLeadInfoSet, set<string> updatedDnqLeadInfoSet){
        
        list<Lead> UpadtedLeadListInfo = new list<Lead>();
        for(Lead currentLead: [SELECT ID,Status,isConverted FROm Lead Where (ID IN:updatedApprovedLeadInfoSet OR ID IN:updatedDnqLeadInfoSet) and isConverted =: False]){
            
            if(updatedApprovedLeadInfoSet.contains(currentLead.Id)){
                currentLead.Status  = 'Qualified';
            }
            else if(updatedDnqLeadInfoSet.contains(currentLead.Id)){
                currentLead.Status  = 'DNQ';
                currentLead.DNQ_Date__c = Date.Today();
            }
            UpadtedLeadListInfo.add(currentLead);
            
        }
        if(UpadtedLeadListInfo.size()>0){
            
            Update UpadtedLeadListInfo;
        }
        
    }
    
    public Static void sendEmailToNationalMACTeam(List<Case> diagnosisCaseList) {
        Set<Id> leadIdSet = new Set<Id>();
        Map<Id, List<Attachment>> docusignAttachmentMap = new Map<Id, List<Attachment>>();
        Map<Id, Id> caseLeadMap = new map<Id, Id>();
        Set<Id> parentAttachmentIdSet = new Set<Id>();
        List<Case> diagnosisVerificationList = new List<Case>();
        for(Case diagnosisCase : diagnosisCaseList) {
            //SendEmailToMacTeam_AC.sendEmailToMac(diagnosisCase.Local_MCA_Team__c,diagnosisCase.Lead__c,diagnosisCase.Id,'National', diagnosisCase.MAC_Email__c);
            caseLeadMap.put(diagnosisCase.Id, diagnosisCase.Lead__c);
            leadIdSet.add(diagnosisCase.Lead__c);
            diagnosisVerificationList.add(diagnosisCase);
        }
        
        if(leadIdSet.Size() > 0) {
            
            for(dsfs__DocuSign_Status__c docusignStatusCheck : [SELECT Id, dsfs__Envelope_Status__c, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Completed' AND dsfs__Lead__c IN :  leadIdSet]) {
                parentAttachmentIdSet.add(docusignStatusCheck.Id);
            }
            
            if(parentAttachmentIdSet.Size() > 0) {
                for(Attachment attachmentInfo : [select Name, ParentId, Body, BodyLength from Attachment where ParentId IN : parentAttachmentIdSet]) {
                    if(docusignAttachmentMap.containsKey(attachmentInfo.ParentId)) {
                        docusignAttachmentMap.get(attachmentInfo.ParentId).add(attachmentInfo);
                    } else {
                        docusignAttachmentMap.put(attachmentInfo.ParentId, new list<Attachment>{attachmentInfo});
                    }
                }
            }
            
            if(diagnosisVerificationList.size() > 0) {
                for(Case diagnosisVerificationCase : diagnosisVerificationList) {
                    SendEmailToMacTeam_AC.sendEmail(docusignAttachmentMap, 'National', diagnosisVerificationCase.Local_MCA_Team__c, diagnosisVerificationCase.MAC_Email__c, diagnosisVerificationCase.Id);
                }
            }
            
        }
    }

    public static void updateChildCase(List<Case> parentCaseList){
        Map<Id,Case> parentCaseMap = new Map<Id,Case>();
        Map<Id,Case> updateChildCaseMap = new Map<Id,Case>();
        List<Case> insertchildCaseList = new List<Case>();
        Constant_AC  constant = new Constant_Ac();    
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
        
        for(Case processParentCase : parentCaseList){
            parentCaseMap.put(processParentCase.Id,processParentCase); 
        }
        
        for(Case dbParentCase : [SELECT Id,OwnerId,Status,ParentId,AccountId,RecordTypeId from Case WHERE ParentId =: parentCaseMap.keySet() AND RecordTypeId  =: wishDeterminationRecordTypeId AND isClosed = false]){
            if(parentCaseMap.containsKey(dbParentCase.ParentId)){
                dbParentCase.OwnerId = parentCaseMap.get(dbParentCase.ParentId).OwnerId;
                dbParentCase.Status = 'Closed';  
                updateChildCaseMap.put(dbParentCase.Id,dbParentCase);
            }
        }
        if(updateChildCaseMap.size() > 0)
            update updateChildCaseMap.values();
        
        for(Case ProcessChilldCaseId : updateChildCaseMap.values()){
            Case newPlanningWish = new Case(ChapterName__c = ProcessChilldCaseId.ChapterName__c,Wish_Type__c ='Standard', Subject = 'Wish Planning',ParentId = ProcessChilldCaseId.ParentId,AccountId=ProcessChilldCaseId.AccountId,ContactId = ProcessChilldCaseId.ContactId,Origin = 'Web',RecordTypeId = wishPlanningRecordTypeId,OwnerId = ProcessChilldCaseId.OwnerId);
            insertchildCaseList.add(newPlanningWish); 
            Case newGrantingWish = new Case(ChapterName__c = ProcessChilldCaseId.ChapterName__c, Wish_Type__c ='Standard', Subject = 'Wish Granting', ParentId = ProcessChilldCaseId.ParentId, AccountId=ProcessChilldCaseId.AccountId,ContactId = ProcessChilldCaseId.ContactId,Origin = 'Web',RecordTypeId = wishGrantRecordTypeId, OwnerId = ProcessChilldCaseId.OwnerId);
            insertchildCaseList.add(newGrantingWish); 
            Case newImpactWish = new Case(ChapterName__c = ProcessChilldCaseId.ChapterName__c, Wish_Type__c ='Standard', Subject = 'Wish Impact', ParentId = ProcessChilldCaseId.ParentId, AccountId=ProcessChilldCaseId.AccountId,ContactId = ProcessChilldCaseId.ContactId,Origin = 'Web',RecordTypeId = wishEffectRecordTypeId, OwnerId = ProcessChilldCaseId.OwnerId);
            insertchildCaseList.add(newImpactWish); 
        }
        
        if(insertchildCaseList.size() > 0)
            insert insertchildCaseList;
    }
    /***Change the Volunteer Opportunity Status as Completed when the wish wish status as completed or closed ********/
    public static void updateVolunteerOpportunityStatus(List<Id> caseId){
        Constant_AC  constant = new Constant_Ac(); 
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c >(); 
        Id wishVolunteerOpportunity = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        for(Volunteer_Opportunity__c currRec:[SELECT id,Status__c from Volunteer_Opportunity__c where Wish__c IN:caseId and RecordTypeId=:wishVolunteerOpportunity]){
            currRec.Status__c='Completed';
            volunteerOppList.add(currRec);
        }
        if(volunteerOppList.size() > 0 && volunteerOppList != Null){
            Update volunteerOppList;
        }
        
    }
    
    public static void grantedWishCount(set<Id> wishIdsSet){
        string key;
        set<string> parentWishIdsSet = new set<string>();
        Map<Id,Integer> volunteerWithCount = new Map<id,Integer>();
        list<Contact> updateGrantedWishCount = new list<Contact>();
        set<Id> volunteerNameSet = new set<Id>();
        for(Volunteer_Opportunity__c currentVolOpp : [SELECT ID,Wish__c,Wish__r.Status,Volunteer_Name__c,IsApproved__c FROM Volunteer_Opportunity__c WHERE IsApproved__c = True AND Wish__r.Status = 'Granted']){
            key = currentVolOpp.Wish__c + '_' + currentVolOpp.Volunteer_Name__c; 
            if(!parentWishIdsSet.contains(key)){
                parentWishIdsSet.add(key);
                if(volunteerNameSet.contains(currentVolOpp.Volunteer_Name__c)){
                    volunteerWithCount.put(currentVolOpp.Volunteer_Name__c,volunteerWithCount.get(currentVolOpp.Volunteer_Name__c)+1);
                }
                else{
                    volunteerWithCount.put(currentVolOpp.Volunteer_Name__c,1);
                    volunteerNameSet.add(currentVolOpp.Volunteer_Name__c);
                }
            }
        }
        for(Contact volunteerContact : [SELECT ID,Number_of_wishes_active__c,Number_of_wishes_granted__c From Contact WHERE ID IN: volunteerWithCount.keySet()]){
            if(volunteerWithCount.containsKey(volunteerContact.Id)){
                volunteerContact.Number_of_wishes_granted__c = volunteerWithCount.get(volunteerContact.Id);
                if(volunteerContact.Number_of_wishes_active__c > 0)
                    volunteerContact.Number_of_wishes_active__c -= volunteerWithCount.get(volunteerContact.Id);
                Integer count = Integer.valueOf( volunteerContact.Number_of_wishes_active__c);
                if(count < 0)
                    volunteerContact.Number_of_wishes_active__c = 0;
                updateGrantedWishCount.add(volunteerContact);
            }
        }
        if(updateGrantedWishCount.size() > 0){
            Update updateGrantedWishCount;
        }
    }
    
    public static void wishChildRegionValidation(Map<Id, Case> parentCaseMap, Set<Id> contactSet) {
        Constant_AC  constant = new Constant_AC();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        
        Set<Id> wishChildWithNoRegion = new Set<Id>();
        if(contactSet.size() > 0) {
            for(Contact wishChild : [SELECT Id, Region_Code__c FROM Contact WHERE RecordTypeId =: wichChildRecordTypeId AND Id IN : contactSet]) {
                if(wishChild.Region_Code__c == null) {
                    wishChildWithNoRegion.add(wishChild.Id);
                }
            }
            if(wishChildWithNoRegion.size() > 0) {
                for(Case parentCase : parentCaseMap.values()) {
                    if(wishChildWithNoRegion.contains(parentCase.ContactId)) {
                        parentCase.addError('Please enter region for wish child');
                    }
                }
            }
        }
    }
    
    public static void wishClearanceTask(Map<Id, Case> wishClearanceMap, Set<Id> newWishClearanceSet, Set<Id> newMedicalSummarySet, Set<Id> newMedicalWishClearanceSet) {
        
        List<Task> taskToUpdateList = new List<Task>();
        Set<Task> newTaskSet = new Set<Task>();
        Map<String, Task> taskToUpdateMap = new Map<String, Task>();
        for(Task checkClearanceTask : [SELECT Id, Subject, WhatId, OwnerId, ActivityDate FROM Task WHERE isClosed = false AND WhatId IN : wishClearanceMap.keySet() AND (Subject = 'New wish clearance needed' OR Subject = 'New medical summary needed'  OR Subject = 'New wish clearance needed')]) {
            taskToUpdateMap.put(checkClearanceTask.WhatId+'-'+checkClearanceTask.Subject, checkClearanceTask);
        }
        if(newWishClearanceSet.size() > 0) {
            for(Id newWishClearanceTask : newWishClearanceSet) {
                if(taskToUpdateMap.containsKey(newWishClearanceTask+'-'+'New wish clearance needed')) {
                    taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed').ActivityDate = Date.today()+3;
                    taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed'));
                } else {
                    Task newTask = new Task();
                    newTask.ActivityDate = Date.today() + 3;
                    newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
                    newTask.Subject = 'New wish clearance needed';
                    newTask.WhatId = newWishClearanceTask;
                    taskToUpdateList.add(newTask);
                }
            }
        }
        
        
        if(newMedicalSummarySet.size() > 0) {
            for(Id newWishClearanceTask : newMedicalSummarySet) {
                if(taskToUpdateMap.containsKey(newWishClearanceTask+'-'+'New medical summary needed')) {
                    taskToUpdateMap.get(newWishClearanceTask+'-'+'New medical summary needed').ActivityDate = Date.today()+3;
                    taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask+'-'+'New medical summary needed'));
                } else {
                    Task newTask = new Task();
                    newTask.ActivityDate = Date.today() + 3;
                    newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
                    newTask.Subject = 'New medical summary needed';
                    newTask.WhatId = newWishClearanceTask;
                    taskToUpdateList.add(newTask);
                }
            }
        }
        
        if(newMedicalWishClearanceSet.size() > 0) {
            for(Id newWishClearanceTask : newMedicalWishClearanceSet) {
                if(taskToUpdateMap.containsKey(newWishClearanceTask+'-'+'New wish clearance needed')) {
                    taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed').ActivityDate = Date.today()+3;
                    taskToUpdateList.add(taskToUpdateMap.get(newWishClearanceTask+'-'+'New wish clearance needed'));
                } else {
                    Task newTask = new Task();
                    newTask.ActivityDate = Date.today() + 3;
                    newTask.OwnerId = wishClearanceMap.get(newWishClearanceTask).OwnerId;
                    newTask.Subject = 'New wish clearance needed';
                    newTask.WhatId = newWishClearanceTask;
                    taskToUpdateList.add(newTask);
                }
            }
        }
        
        
        if(taskToUpdateList.size() > 0) {
            newTaskSet.addAll(taskToUpdateList);
            if(newTaskSet.size() > 0) {
                taskToUpdateList.clear();
                taskToUpdateList.addAll(newTaskSet);
                if(taskToUpdateList.size() > 0) {
                    upsert taskToUpdateList;
                }
            }
            
        }
    }
    
    public void createVolunteerOpportunity(Map<Id,Case> VolunteercaseMap){
     RecursiveTriggerHandler.isFirstTime = false;
     Id volunteerOppWishRecordTypeId = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
     Map<Id,Chapter_Role__c> chapterRoleMap = new Map<Id,Chapter_Role__c>();
     List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        for(Chapter_Role__c currentChapterRole :[SELECT ID,Chapter_Name__c,Chapter_Name__r.Name,Role_Name__r.Name FROM Chapter_Role__c WHERE Role_Name__r.Name =: 'Wish Granter' AND Chapter_Name__c IN: VolunteercaseMap.keySet()]){
                chapterRoleMap.put(currentChapterRole.Chapter_Name__c,currentChapterRole);
        }
        if(chapterRoleMap.size() > 0){
            for(Case currentCase : VolunteercaseMap.Values()){
                    for(Integer i=0 ;i<=1;i++){
                     if(chapterRoleMap.containsKey(currentCase.ChapterName__c)){
                        Volunteer_Opportunity__c volunteerOpp = new Volunteer_Opportunity__c();
                        volunteerOpp.Chapter_Role_Opportunity__c = chapterRoleMap.get(currentCase.ChapterName__c).Id;
                        volunteerOpp.Wish__c = currentCase.id;
                        volunteerOpp.RecordTypeId = volunteerOppWishRecordTypeId;
                        volunteerOpp.Is_Non_Viewable__c = True;
                        volunteerOpp.Chapter_Name__c = chapterRoleMap.get(currentCase.ChapterName__c).Chapter_Name__c;
                        volunteerOppList.add(volunteerOpp);
                    }
                }
           }
            if(volunteerOppList.size()>0){
                insert volunteerOppList;
            }
        }
    }
	
	//This method is used to create "Diagnosis Verification Review" Task for "Eligibility Review" Case Owner    
    public static void CreateDiagnosisVerificationReview(List<Case> eligibilityReviewCaseList) {
        List<Task> DiagnosisVerificationTaskList = new List<Task>();
        for(Case reviewCase : eligibilityReviewCaseList) {
            Task newDiagnosisVerificationTask = new Task();
            newDiagnosisVerificationTask.OwnerId = reviewCase.OwnerId;
            newDiagnosisVerificationTask.WhatId = reviewCase.Id;
            newDiagnosisVerificationTask.Subject = 'Diagnosis Verification Review';
            newDiagnosisVerificationTask.ActivityDate = Date.today().addDays(1);
            DiagnosisVerificationTaskList.add(newDiagnosisVerificationTask);
        }
        if(DiagnosisVerificationTaskList.size() > 0) {
            insert DiagnosisVerificationTaskList;
        }
    }
    
    public static void changeChildCasesOwner(Map<Id, Id> newCaseOwnerMap) {
        
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        
        List<Case> childCaseList = new List<Case>();
        for(Case childCase : [SELECT Id, OwnerId, ParentId FROM Case WHERE ParentId IN : newCaseOwnerMap.keySet() AND isClosed = false AND RecordTypeId !=: parentWishRecordTypeId]) {
            if(childCase.OwnerId != newCaseOwnerMap.get(childCase.ParentId)) {
                childCase.OwnerId = newCaseOwnerMap.get(childCase.ParentId);
                childCaseList.add(childCase);
            }
        }
        if(childCaseList.size() > 0) {
            update childCaseList;
        }
        
    }
    
    public static void chageAccessPermission(Map<Id, Id> caseContactMap) {
        Map<Id, String> caseTeamRoleFilteredMap = new Map<Id, String>();
        Map<String, Id> caseTeamRoleMap = new Map<String, Id>();
        for(CaseTeamRole caseTeamRoleInfo : [SELECT Id, Name FROM CaseTeamRole]) {
            if(caseTeamRoleInfo.Name.contains(' (Wish Closed)')) {
                caseTeamRoleFilteredMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name.remove(' (Wish Closed)'));
            } else {
                caseTeamRoleMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
            }
        }
        
        Map<Id, List<CaseTeamMember>> caseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
        for(CaseTeamMember caseTeamMemberInfo : [SELECT Id, MemberId, TeamRoleId, ParentId FROM CaseTeamMember WHERE ParentId IN : caseContactMap.keySet()]) {
            if(caseTeamMemberMap.containsKey(caseTeamMemberInfo.ParentId)) {
                caseTeamMemberMap.get(caseTeamMemberInfo.ParentId).add(caseTeamMemberInfo);
            } else {
                caseTeamMemberMap.put(caseTeamMemberInfo.ParentId, new List<CaseTeamMember> {caseTeamMemberInfo});
            }
        }
        
        if(caseTeamMemberMap.size() > 0) {
            List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
            List<ContactShare> contactToShareList = new List<ContactShare>();
            for(Id caseId : caseContactMap.keySet()) {
                if(caseTeamMemberMap.containsKey(caseId)) {
                    for(CaseTeamMember caseTeamRoleUpdate : caseTeamMemberMap.get(caseId)) {
                        if(caseTeamRoleFilteredMap.containsKey(caseTeamRoleUpdate.TeamRoleId)) {
                            if(caseTeamRoleMap.containsKey(caseTeamRoleFilteredMap.get(caseTeamRoleUpdate.TeamRoleId))) {
                                caseTeamRoleUpdate.TeamRoleId = caseTeamRoleMap.get(caseTeamRoleFilteredMap.get(caseTeamRoleUpdate.TeamRoleId));
                                updateRoleList.add(caseTeamRoleUpdate);
                                //Contact Share
                                ContactShare shareContact = new ContactShare();
                                shareContact.ContactAccessLevel = 'Read';
                                shareContact.ContactId = caseContactMap.get(caseId);
                                shareContact.UserOrGroupId = caseTeamRoleUpdate.MemberId;
                                contactToShareList.add(shareContact);
                            }
                        }
                    }
                }
            }
            if(updateRoleList.size() > 0) {
                update updateRoleList;
            }
            if(contactToShareList.size() > 0) {
                insert contactToShareList;
            }
        }
    }
}