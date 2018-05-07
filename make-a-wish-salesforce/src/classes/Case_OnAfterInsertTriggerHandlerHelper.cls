/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record insert then it will called by the Case_OnAfterInsertTriggerHandler class.
*******************************************************************************************************************/

Public class Case_OnAfterInsertTriggerHandlerHelper{
    Static Constant_AC  constant = new Constant_Ac();   
    Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();     
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();    
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    /******************************************************************************************************
This method is used to uppdate the parent wish subject, Fund Id and Unique wish Identifier values. When 
a parent case is created.
******************************************************************************************************/
    public static void UpdateWishRecordIdentifier(Set<Id> ParentIdsSet, Set<Id> chapterIds, Id recTypeId){
        
        Integer increment;
        boolean IsFYChanged =false;
        Datetime  FYDate = Datetime.now();
        String dateOutput = FYDate.format('yy');
        Integer FYYear=integer.valueof(dateOutput);
        Map<String,office__c> accountOfficeMap = new Map<String,office__c>();
        Set<Id> accountId = new Set<Id>();
        List<Case> lstParentWishes;
        try{
        List<Period> financialPeriod = [SELECT StartDate, EndDate,IsForecastPeriod,Type FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY Limit 50000];
        if(financialPeriod.size()>0){
            if( (Date.today() >= financialPeriod[0].StartDate && Date.today() <= financialPeriod[0].EndDate) && (Date.today().addDays(-1)  >= financialPeriod[0].StartDate && Date.today().addDays(-1) <= financialPeriod[0].EndDate)){
                IsFYChanged = true;
            }
            FYDate  = datetime.newInstance(financialPeriod[0].EndDate.year(), financialPeriod[0].EndDate.month(),financialPeriod[0].EndDate.day()); 
            FYYear = integer.valueof(FYDate.format('yy'));
        }
        for(office__c currOffice : [SELECT Office_Id__c, Chapter__r.name,Chapter__c  FROM Office__c WHERE Chapter__c in : chapterIds Limit 50000]){
            accountOfficeMap.put(currOffice.Chapter__r.Name,currOffice );
        }
        lstParentWishes=[SELECT Id, RecordTypeId, Subject, Unique_Wish_Record_Identifier__c,Fund_Id__c, ChapterName__c,ChapterName__r.Name  FROM Case WHERE Id In: ParentIdsSet and RecordTypeId =: recTypeId Order BY CreatedDate desc Limit 50000];
        List<Case> lstParentWisheRecordTypes = [SELECT Id, Unique_Wish_Record_Identifier__c, ChapterName__c,ChapterName__r.Name FROM Case WHERE RecordTypeId =: recTypeId and  Unique_Wish_Record_Identifier__c !=null and CreatedBy.Name !='Integration User'  and Lead__r.unique_wish_identifier__c=null Order BY CreatedDate desc Limit 2];
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
                    parentWishes.UWISource__c = 'Case';
                }
                if(parentWishes.Fund_Id__c == null){
                    parentWishes.Fund_Id__c = temp.left(3) + '-' + FYYear  + '-' + increment ;
                }
            }
            increment=increment+1;
            parentWishes.Subject = parentWishes.Subject+' - '+parentWishes.Unique_Wish_Record_Identifier__c;
        }
        System.debug('Parent Wishes 3:' + lstParentWishes);
        if(lstParentWishes.size() > 0)
        {
            update lstParentWishes;
        }
       }
       catch(Exception ex){
           for(case currRec : lstParentWishes){
                ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdateWishRecordIdentifier',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(case currRec : lstParentWishes){
                currRec.addError(Label.Debug_log_error_message);
            }
       }
    } 
    
    /*************************************************************************************************
Related to STT-11 for populating survey email field on parent wish from the Wish Impact sub case.
***************************************************************************************************/
    public static void updateSurveyField(Map<Id, Case> surveyEmailMap, Set<Id> impactparentIdSet) {
        RecursiveTriggerHandler.allowToEditRecord = TRUE;
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        try{
        for(Case parentCase : [SELECT Id, Wish_Impact_Survey_Email__c,Survey_Sent__c FROM Case WHERE Id IN : impactparentIdSet Limit 50000]) {
            parentCaseMap.put(parentCase.Id, parentCase);
        }
        
        for(Case wishImpactCase : surveyEmailMap.Values()) {
            if(parentCaseMap.containsKey(wishImpactCase.ParentId)) {
                parentCaseMap.get(wishImpactCase.ParentId).Wish_Impact_Survey_Email__c = wishImpactCase.Survey_Email__c;
                parentCaseMap.get(wishImpactCase.ParentId).Survey_Sent__c = wishImpactCase.Survey_Sent__c ;
            }
        }
        if(parentCaseMap.size() > 0) {
            update parentCaseMap.values();
        }
        }
        catch(Exception ex){
            for(case currRec : surveyEmailMap.values()){
                ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateSurveyField',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(case currRec : surveyEmailMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
        
    }
    
    /***********************************************************************************************************************
Used to create action track for different stages based on Chapter and used to pull Case team members to child wishes.
***********************************************************************************************************************/
    public static void createActionTracks(String caseType, Map<Id, Case> caseChapterIdsMap, Set<Id> parentWishIdsSet) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Map<String, Case> chaptersWishMap = new Map<String, Case>();
        List<CaseTeamMember> childWishTeamMembersList = new List<CaseTeamMember>();
        Map<String, List<Case>> wishDeterminationCases = new Map<String, List<Case>>();
        Map<Id, List<CaseTeamMember>> parentCaseMembersMap = new Map<Id, List<CaseTeamMember>>();
        try{
        if(parentWishIdsSet.size()>0){
            //Used to get case and its case team members
            for(CaseTeamMember caseTeamMem : [SELECT Id,ParentId,Parent.RecordTypeId,MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : parentWishIdsSet AND Parent.RecordTypeId =:parentWishRecordTypeId Limit 50000]) {
                if(parentCaseMembersMap.containsKey(caseTeamMem.ParentId)) {
                    parentCaseMembersMap.get(caseTeamMem.ParentId).add(caseTeamMem);
                } else {
                    parentCaseMembersMap.put(caseTeamMem.ParentId, new list<CaseTeamMember>{caseTeamMem});
                }
            }
            
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
        catch(Exception ex){
            for(case currRec : caseChapterIdsMap.values()){
                ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'createActionTracks',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(case currRec : caseChapterIdsMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    } 
    
    /*********************************************************
Used to include Intake Manager into case team.
*********************************************************/
    public static void CaseTeamInTakeManager(Map<Id, Case> parentCaseIntakeOwnerMap) {
        Map<Id,String> teamRoleNameMap = new Map<Id, String>();
        Map<String,Id> teamRoleIdMap = new Map<String, Id>();
        Set<Id> chapterSet = new Set<Id>();
        List<Case> caseUpdateList = new List<Case>();
        Map<Id, Set<Id>> checkMemMap = new map<Id, Set<Id>>();
        try{
        for(Case caseInfo : parentCaseIntakeOwnerMap.values()) {
            chapterSet.add(caseInfo.chapterName__c);
        }
        for(CaseTeamRole caseTeamRoleInfo : [SELECT Id, Name FROM CaseTeamRole Limit 50000]) {
            teamRoleNameMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name);
            teamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
        }
        for(CaseTeamMember caseInfo : [SELECT Id, MemberId, ParentId FROM CaseTeamMember WHERE ParentId IN : parentCaseIntakeOwnerMap.keySet() Limit 50000]) {
            if(checkMemMap.containsKey(caseInfo.ParentId)) {
                checkMemMap.get(caseInfo.ParentId).add(caseInfo.MemberId);
            } else {
                checkMemMap.put(caseInfo.ParentId,new Set<Id>{caseInfo.MemberId});
            }
        }
        if(parentCaseIntakeOwnerMap.size() > 0) {
            List<CaseTeamMember> memberList = new List<CaseTeamMember>();
            for(Case caseteam : parentCaseIntakeOwnerMap.values()) {
                if(checkMemMap.containsKey(caseteam.Id) && !checkMemMap.get(caseteam.Id).contains(caseteam.OwnerId)) {
                    CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                    newCaseTeamMember.parentId = caseteam.Id;
                    newCaseTeamMember.MemberId = caseteam.OwnerId;
                    newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Intake Manager');
                    memberList.add(newCaseTeamMember);
                } else if(!checkMemMap.containsKey(caseteam.Id)) {
                    CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                    newCaseTeamMember.parentId = caseteam.Id;
                    newCaseTeamMember.MemberId = caseteam.OwnerId;
                    newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Intake Manager');
                    memberList.add(newCaseTeamMember);
                }
            }
            if(memberList.size() > 0) {
                insert memberList;
            }
        }
       }
       catch(Exception ex){
            for(case currRec : parentCaseIntakeOwnerMap.values()){
                ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'CaseTeamInTakeManager',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(case currRec : parentCaseIntakeOwnerMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    } 
    
    /*********************************************************************************
Used to create a case file records when a Parent case and sub cases is created.
**********************************************************************************/ 
    public static void createCaseFile(List<Case> caseList){
        List<cg__CaseFile__c> casefiles = new List<cg__CaseFile__c>();
        try{
        for(Case newCase : caseList){
            
            cg__CaseFile__c PicFolder =new cg__CaseFile__c();
            PicFolder.cg__Case__c = newCase .Id;
            PicFolder.cg__Content_Type__c = 'Folder';
            PicFolder.cg__File_Name__c = 'Photos';
            PicFolder.cg__WIP__c = false;
            PicFolder.cg__Private__c= false;
            casefiles.add(PicFolder);
            
            cg__CaseFile__c DocFolder =new cg__CaseFile__c();
            DocFolder.cg__Case__c = newCase.Id  ;
            DocFolder.cg__Content_Type__c = 'Folder';
            DocFolder.cg__File_Name__c = 'Documents';
            DocFolder.cg__WIP__c = false;
            DocFolder.cg__Private__c= false;
            casefiles.add(DocFolder);
            
            cg__CaseFile__c VedioFolder =new cg__CaseFile__c();
            VedioFolder.cg__Case__c = newCase.Id  ;
            VedioFolder.cg__Content_Type__c = 'Folder';
            VedioFolder.cg__File_Name__c = 'Videos';
            VedioFolder.cg__WIP__c = false;
            VedioFolder.cg__Private__c= false;
            casefiles.add(VedioFolder);
            
            cg__CaseFile__c StaffFolder =new cg__CaseFile__c();
            StaffFolder.cg__Case__c = newCase.Id  ;
            StaffFolder.cg__Content_Type__c = 'Folder';
            StaffFolder.cg__File_Name__c = 'Staff - Private';
            StaffFolder.cg__WIP__c = false;
            StaffFolder.cg__Private__c= true;
            casefiles.add(StaffFolder);
            
            cg__CaseFile__c FinanceFolder =new cg__CaseFile__c();
            FinanceFolder.cg__Case__c = newCase.Id  ;
            FinanceFolder.cg__Content_Type__c = 'Folder';
            FinanceFolder.cg__File_Name__c = 'Financials';
            FinanceFolder.cg__WIP__c = false;
            FinanceFolder.cg__Private__c= true;
            casefiles.add(FinanceFolder);
        }
        
        if(casefiles.size()>0){
            if(!Test.isRunningTest()) {
                insert casefiles;
            }
        }
       }
        catch(Exception ex){
            for(case currRec : caseList){
                ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'createCaseFile',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(case currRec : caseList){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /**********************************************************************************************************
This method is used to update the wish receipt items velues in parent case when a Granting case is created.
**********************************************************************************************************
    public static void wishReciptValues(Map<Id,Case> wishReciptMap,Map<Id,Case> ParentCase){
        list<Case> wishReceiptCaseList = new list<Case>();
        try{
        if(wishReciptMap.size() > 0){
            for(Case currentCase : ParentCase.values()){
                if(wishReciptMap.containsKey(currentCase.Id)){
                    currentCase.Wish_Receipt_Items__c = wishReciptMap.get(currentCase.id).Wish_Receipt_Items__c;
                    wishReceiptCaseList.add(currentCase);
                }
            }
        }
        if(wishReceiptCaseList.size() > 0){
            update wishReceiptCaseList;
        }
       }
       catch(Exception ex){
            for(case currRec : wishReciptMap.values()){
                ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'wishReciptValues',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(case currRec : wishReciptMap.values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    } */  

}