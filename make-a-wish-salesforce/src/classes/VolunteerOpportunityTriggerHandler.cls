/*************************************************************************************************
Author   : MST Solutions
CreatedDate : 05/27/2016
Description : 1. This VolunteerOpportunityTriggerHandler is used to invoke the apporval process when the volunteer contact name is entered into the volunteer contact field.
2. And also it is used to update count of the no.of volunteer opportunities that are registered for the corresponding NonWish & Event. 
3. And it is used to update count of the number of volunteer opportunities that are created for the corresponding NonWish & Event.
4. And also it is used when the chapter staff is approved then the volunteer contact is added in to the coressponding case team.
*************************************************************************************************/

Public class VolunteerOpportunityTriggerHandler 
{
    
    Static Integer count = 0;
    Static Map<Id,Case> caseMap = new Map<Id,Case>();
    Static List<CaseTeamMember> CaseTeamMemberList = new List<CaseTeamMember>();
    Static Set<Id> ParentCaseSet = new Set<Id>();
    
    /* This SubmitforApprovalProcess() invoke the approval process when the volunteer contact name is entered into the volunteer contact field.*/
    Public Static Void SubmitforApprovalProcess(List<Volunteer_Opportunity__c> recordsForApprovalProcess, Set<Id> chapterIdsSet)
    {
        List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
        
        Map<Id,Id> volunteerManagerIdsMap = new Map<Id,Id>();
        
        for(Account getAccountName : [SELECT Id, Name, volunteer_manager__c FROM Account WHERE Id IN : chapterIdsSet]) {
            volunteerManagerIdsMap.put(getAccountName.id,getAccountName.volunteer_manager__c);
            
        }
        
        //Default user not give by client so we assign it to active user
        // User userns = [SELECT Id,username, profile.Name FROM User WHERE profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        for(Volunteer_Opportunity__c newVolunteerRole : recordsForApprovalProcess)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req1.setSubmitterId(user1.Id);
            req.setComments('Submitting request for approval.');
            req.setObjectId(newVolunteerRole.id);
            if(volunteerManagerIdsMap.containsKey(newVolunteerRole.Chapter_Name__c)) {
                if(volunteerManagerIdsMap.get(newVolunteerRole.Chapter_Name__c) != Null)
                    req.setNextApproverIds(new Id[] {volunteerManagerIdsMap.get(newVolunteerRole.Chapter_Name__c)});
                else
                    req.setNextApproverIds(new Id[] {userInfo.getUserId()});
            } else {
                req.setNextApproverIds(new Id[] {userInfo.getUserId()});
            }
            req.setProcessDefinitionNameOrId('Volunteer_Role_Approval_Process');
            req.setSkipEntryCriteria(true);
            approvalReqList.add(req);
        }
        if(approvalReqList.size() > 0)
        {
            List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);
            
            for(Approval.ProcessResult result: resultList )
            {        
                System.debug('Submitted for approval successfully: '+result.isSuccess());      
            }
            
        }
    }
    /*CreateCaseTeamMembers() is used to add the volunteers to case team member when the approver approve the 
volunteer opportunity record.*/ 
    Public Static Void CreateCaseTeamMembers(List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams)
    {
        List<Volunteer_Opportunity__c> VolunteerRoleList = new List<Volunteer_Opportunity__c>();
        Set<String> roleName = new Set<String>();
        Set<Id> dbVolunteerSet = new Set<Id>();
        Map<Id,Set<CaseTeamMember>> updateCaseMemberCount = new Map<Id,Set<CaseTeamMember>>();
        Map<String,CaseTeamRole > teamMemberRoleMap = new Map<String,CaseTeamRole>();
        Map<Id,User> volunteerContactMap = new Map<Id,User>();
        Set<Id> volunteerSet = new Set<Id>();
        Set<Id> VoluteerNameSet = new Set<Id>();
        Set<Id> wishAssignedSet = new Set<Id>();
        CaseTeamRole caseRoleID = [SELECT id,Name from CaseTeamRole WHERE Name =: 'Wish Granter' Limit 1];
        Set<Id> wishIds = new Set<Id>();
        Map<Id,Set<String>> wishMembersMap = new Map<Id,Set<String>>();
        Map<Id,Id> volunteerUserMap = new Map<Id, Id>();
        Map<Id,Set<Id>> wishUserMap = new Map<Id,Set<Id>>(); //Used to hold wish related contact and user for contact access to volunteers
        Map<Id,Id> wishRelatedContactMap = new Map<Id,Id>();
        Constant_AC  constant = new Constant_AC();
        List<Contact> updateContactList = new List<Contact>();
        
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        for(Volunteer_Opportunity__c newVolunteerRole : recordsForCreatingCaseTeams)
        {
            roleName.add(newVolunteerRole.Role__c);
            VoluteerNameSet.add(newVolunteerRole.Volunteer_Name__c);
            wishIds.add(newVolunteerRole.wish__c);
            if(wishUserMap.containsKey(newVolunteerRole.wish__c)) {
                wishUserMap.get(newVolunteerRole.wish__c).add(newVolunteerRole.Volunteer_Name__c);
            } else {
                wishUserMap.put(newVolunteerRole.wish__c, new Set<Id>{newVolunteerRole.Volunteer_Name__c});
            }
            
            Contact updateContact = new Contact();
            updateContact.id = newVolunteerRole.Volunteer_Name__c;
            updateContact.Date_of_last_engagement__c  = Date.Today();
            updateContactList.add(updateContact);
            
        }
        
        for(Case getRelatedContact : [SELECT Id, ContactId FROM Case WHERE Id IN : wishUserMap.keySet()]) {
            wishRelatedContactMap.put(getRelatedContact.Id, getRelatedContact.ContactId);
        }
        for(User contactUser : [SELECT Id, ContactId FROM User WHERE ContactId IN : VoluteerNameSet]) {
            volunteerUserMap.put(contactUser.ContactId, contactUser.Id);
        }
        
        for(CaseTeamRole  caseTem : [SELECT id,Name from CaseTeamRole]){
            teamMemberRoleMap.put(caseTem.Name,caseTem);
        }
        system.debug('>>>>>>> roleName' + roleName);
        system.debug('>>>>>>> teamMemberRoleMap Key set' +teamMemberRoleMap.keySet());
        
        for(CaseTeamMember dbcaseTeamMember : [SELECT id,MemberId, ParentId  FROM CaseTeamMember WHERE ParentId IN :wishIds]){
            
            if(wishMembersMap.containsKey(dbcaseTeamMember.parentId))
                wishMembersMap.get(dbcaseTeamMember.parentId).add(dbcaseTeamMember.MemberId);
            else
                wishMembersMap.put(dbcaseTeamMember.parentId,new Set<String>{dbcaseTeamMember.MemberId});
        }
        
        for(Volunteer_Opportunity__c newVolunteerRole : recordsForCreatingCaseTeams)
        {
            if(newVolunteerRole.Volunteer_Name__c != null && newVolunteerRole.wish__c != null){
                
                if(!wishMembersMap.containsKey(newVolunteerRole.wish__c) || (wishMembersMap.containsKey(newVolunteerRole.wish__c) && volunteerUserMap.containsKey(newVolunteerRole.Volunteer_Name__c) && !wishMembersMap.get(newVolunteerRole.wish__c).contains(volunteerUserMap.get(newVolunteerRole.Volunteer_Name__c))))
                {
                    system.debug('++++++' + wishMembersMap.containsKey(newVolunteerRole.wish__c));
                    system.debug('------' + wishMembersMap.get(newVolunteerRole.wish__c));
                    system.debug('======' + newVolunteerRole.Volunteer_Name__c);
                    CaseTeamMember newCaseTeamMembers = new CaseTeamMember();
                    newCaseTeamMembers.ParentId = newVolunteerRole.Wish__c;
                    newCaseTeamMembers.MemberId = newVolunteerRole.Volunteer_Name__c;
                    if(volunteerUserMap.containsKey(newVolunteerRole.Volunteer_Name__c)) {
                        
                        newCaseTeamMembers.MemberId = volunteerUserMap.get(newVolunteerRole.Volunteer_Name__c);
                        wishAssignedSet.add(newCaseTeamMembers.MemberId);
                    }
                    If(teamMemberRoleMap.containsKey(newVolunteerRole.Role__c)){
                        newCaseTeamMembers.TeamRoleId = teamMemberRoleMap.get(newVolunteerRole.Role__c).id;
                    }
                    else{
                        newCaseTeamMembers.TeamRoleId = caseRoleID.id;
                    }
                    CaseTeamMemberList.add(newCaseTeamMembers);
                    
                    
                    if(updateCaseMemberCount.containsKey(newVolunteerRole.Wish__c)){
                        updateCaseMemberCount.get(newVolunteerRole.Wish__c).add(newCaseTeamMembers);
                    }
                    else{
                        updateCaseMemberCount.put(newVolunteerRole.Wish__c, new Set<CaseTeamMember>{newCaseTeamMembers});
                        
                    }
                } else {
                    /* system.debug('++++++' + wishMembersMap.containsKey(newVolunteerRole.wish__c));
system.debug('------' + wishMembersMap.get(newVolunteerRole.wish__c));
system.debug('======' + newVolunteerRole.Volunteer_Name__c);*/
                    
                }
                
            }
        } 
        
        if(updateContactList.size() > 0)
            update updateContactList;
        
        
        if(CaseTeamMemberList.size() > 0)
        {//wishRelatedContactMap, wishUserMap
            insert CaseTeamMemberList;
            if(wishUserMap.size() > 0) {
                List<ContactShare> contactToShareList = new List<ContactShare>();
                for(Id caseId : wishUserMap.keySet()) {
                    if(wishUserMap.containsKey(caseId)) {
                        for(Id userId : wishUserMap.get(caseId)) {
                            ContactShare shareContact = new ContactShare();
                            shareContact.ContactAccessLevel = 'Read';
                            if(wishRelatedContactMap.containsKey(caseId)) {
                                shareContact.ContactId = wishRelatedContactMap.get(caseId);
                            }
                            if(volunteerUserMap.containsKey(userId)) {
                                shareContact.UserOrGroupId = volunteerUserMap.get(userId);
                                contactToShareList.add(shareContact);
                            }
                            
                        }
                    }
                }
                if(contactToShareList.size() > 0) {
                    insert contactToShareList;
                }
            }        
        }
        List<Case> updateCaseList = new List<Case>();
        if(updateCaseMemberCount.size() > 0)
        {
            for(Case getCase : [SELECT Id,CaseNumber,Case_Member_Count__c from Case WHERE Id IN :updateCaseMemberCount.keySet()])
            {
                Case updatCase = new Case();
                updatCase.id = getCase.id;
                updatCase.Assigned_Date__c = Date.Today();
                
                if(getCase.Case_Member_Count__c  == Null){
                    updatCase.Case_Member_Count__c = 0 + ((updateCaseMemberCount.get(getCase.id)).size());
                }
                else{
                    updatCase.Case_Member_Count__c = getCase.Case_Member_Count__c  + ((updateCaseMemberCount.get(getCase.id)).size());
                }
                updateCaseList.add(updatCase);  
            }
        }
        if(updateCaseList.size() > 0)
            Update updateCaseList;
    }
    
    /*This updateVolunteerRegisterdCount() is used to update count of the number of volunteer opportunities that are registered for the corresponding NonWish & Event .*/
    public static void UpdateVolunteerRegisterdCount(List<Volunteer_Opportunity__c> nonWishListtoupdatecount){
        system.debug('@@@@@@@ UpdateVolunteerRegisterdCount CALLED  @@@@@@@@@'+nonWishListtoupdatecount);
        Set<Id> chapterRoleIdSet = new Set<Id>();
        Set<Id> NonWishEventIdSet = new Set<Id>();
        Map<Id,Integer> volunteercountMap = new Map<Id,Integer>();
        List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
        for(Volunteer_Opportunity__c newVolOpp :nonWishListtoupdatecount){
            chapterRoleIdSet .add(newVolOpp.Chapter_Role_Opportunity__c);
            NonWishEventIdSet.add(newVolOpp.Non_Wish_Event__c);
        }
        List<AggregateResult> groupedResults = [SELECT Chapter_Role_Opportunity__c nonwish, Count(Id)aver  FROM Volunteer_Opportunity__c WHERE Non_Wish_Event__c IN: NonWishEventIdSet  AND Volunteer_Name__c  != Null AND Reason_Inactive__c = Null AND Chapter_Role_Opportunity__c IN: chapterRoleIdSet GROUP BY Chapter_Role_Opportunity__c];
        system.debug('@@@@@@@ groupedResults  @@@@@@@@@'+groupedResults );
        if(!groupedResults.isEmpty()){
            for(AggregateResult arr : groupedResults){
                volunteercountMap.put((ID)arr.get('nonwish'),(integer)arr.get('aver'));
                
            }
        }
        if(volunteercountMap.size() > 0){
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: volunteercountMap.Keyset()]){
                if(NonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)){
                    if(volunteercountMap.containsKey(dbVolunteerCount.Chapter_Role__c)){
                        dbVolunteerCount.Registered__c  = volunteercountMap.get(dbVolunteerCount.Chapter_Role__c);
                        updateVolunteerCountList.add(dbVolunteerCount);
                    }
                }
            }
        }
        else{
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: chapterRoleIdSet ]){
                if(NonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)){
                    dbVolunteerCount.Registered__c  = 0;
                    updateVolunteerCountList.add(dbVolunteerCount);
                }
            }
        }
        update updateVolunteerCountList;
    }
    
    /*This updatevolunteerNeededCount() is used to update count of the number of volunteer opportunities that are created for the corresponding NonWish & Event.*/
    public static void UpdatevolunteerNeededCount(List<Volunteer_Opportunity__c> nonWishListtoupdatecount){
        Set<Id> chapterRoleIdSet = new Set<Id>();
        Set<Id> NonWishEventIdSet = new Set<Id>();
        set<Id> volunteercountIdSet = new Set<Id>();
        Map<Id,Integer> volunteercountMap = new Map<Id,Integer>();
        List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
        for(Volunteer_Opportunity__c newVolOpp :nonWishListtoupdatecount){
            chapterRoleIdSet .add(newVolOpp.Chapter_Role_Opportunity__c);
            NonWishEventIdSet .add(newVolOpp.Non_Wish_Event__c);
        }
        List<AggregateResult> groupedResults = [SELECT Chapter_Role_Opportunity__c nonwish, Count(Id)aver  FROM Volunteer_Opportunity__c WHERE Non_Wish_Event__c IN: NonWishEventIdSet AND Chapter_Role_Opportunity__c IN: chapterRoleIdSet GROUP BY Chapter_Role_Opportunity__c];
        if(!groupedResults.isEmpty()){
            for(AggregateResult arr : groupedResults){
                volunteercountMap.put((ID)arr.get('nonwish'),(integer)arr.get('aver'));
                
            }
        }
        if(volunteercountMap.size() > 0){
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: volunteercountMap.Keyset()]){
                if(NonWishEventIdSet .contains(dbVolunteerCount.Non_Wish_Events__c)){
                    if(volunteercountMap.containsKey(dbVolunteerCount.Chapter_Role__c)){
                        dbVolunteerCount.Volunteer_Needed__c = volunteercountMap.get(dbVolunteerCount.Chapter_Role__c);
                        
                        updateVolunteerCountList.add(dbVolunteerCount);
                    }
                }
            }
            update updateVolunteerCountList;
        }
        else{
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: chapterRoleIdSet ]){
                if(NonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)){
                    dbVolunteerCount.Volunteer_Needed__c = 0;
                    updateVolunteerCountList.add(dbVolunteerCount);
                    volunteercountIdSet.add(dbVolunteerCount.Id);
                }
            }
            //delete updateVolunteerCountList;
            //delete volunteercountIdSet;
        }
    }
    
    /* public static void updateVolunteerWishGrantedCount(List<Volunteer_Opportunity__c> volOpportunities){
Constant_AC  constant = new Constant_AC();
Id volunteerRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
Set<Id> volContactId = new Set<Id>();
Map<Id,Integer> volunteercountMap = new Map<Id,Integer>();
List<Contact> volunteerContactList = new List<Contact>();
for(Volunteer_Opportunity__c  dbVolOpp : volOpportunities){

volContactId.add(dbVolOpp.Volunteer_Name__c);
}
List<AggregateResult> groupedResults = [SELECT Volunteer_Name__c volCount, Count(Id)aver  FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c  IN: volContactId AND Wish__c != Null AND Wish__r.Status = 'Granted' GROUP BY Volunteer_Name__c ];

if(!groupedResults.isEmpty()){
for(AggregateResult arr : groupedResults){
volunteercountMap.put((ID)arr.get('volCount'),(integer)arr.get('aver'));

}
}

if(volunteercountMap.size() > 0){
for(Contact dbVolunteerContact : [SELECT Id,Number_of_wishes_granted__c,RecordTypeId FROM Contact where Id IN:volunteercountMap.KeySet() AND RecordTypeId =: volunteerRecordTypeId ]){
if(volunteercountMap.containsKey(dbVolunteerContact.Id)){
dbVolunteerContact.Number_of_wishes_granted__c  = volunteercountMap.get(dbVolunteerContact.Id);
volunteerContactList.add(dbVolunteerContact);
}
}
}

else{
for(Contact dbVolunteerContact : [SELECT Id,Number_of_wishes_granted__c FROM Contact where Id IN: volContactId]){
if(volContactId.contains(dbVolunteerContact.Id)){
dbVolunteerContact.Number_of_wishes_granted__c  = 0;
volunteerContactList.add(dbVolunteerContact);
}
}
}
if(volunteerContactList.size() > 0)
update volunteerContactList;
}*/
    
    
    public static void updateVolunteerWishAssignedCount(Set<Id> wishIdSet){
        
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        List<Contact> updateContactList = new List<Contact>();
        Map<Id,Integer> volunteercountMap = new Map<Id,Integer>();
        Map<Id,Id> sobjectMap = new Map<Id,Id>();
        List<AggregateResult> groupedResults = [SELECT Wish__c volCount, Count_Distinct(Wish__r.Id)aver  FROM Volunteer_Opportunity__c WHERE Wish__c  IN: wishIdSet AND Wish__c != Null GROUP BY Wish__c ];
        if(!groupedResults.isEmpty()){
            for(AggregateResult arr : groupedResults){
                volunteercountMap.put((ID)arr.get('volCount'),(integer)arr.get('aver'));
                
            } 
        }
        for(Volunteer_Opportunity__c  dbVoluOpportunity : [SELECT Id,Wish__c,Volunteer_Name__c,IsApproved__c From Volunteer_Opportunity__c WHERE Wish__c IN: volunteercountMap.KeySet() AND IsApproved__c =: TRUE]){
            sobjectMap.put(dbVoluOpportunity.Volunteer_Name__c,dbVoluOpportunity.Wish__c); 
        } 
        
        for(Contact dbVolunteerCon : [SELECT Id,Number_of_wishes_active__c,RecordTypeId FROM Contact where Id IN: sobjectMap.KeySet() AND RecordTypeId =: volunteerRecordTypeId]){
            if(sobjectMap.containsKey(dbVolunteerCon.Id)){
                Contact newCon = new Contact();
                newCon.Id = dbVolunteerCon.Id;
                if(volunteercountMap.containsKey(sobjectMap.get(dbVolunteerCon.Id))){
                    if(dbVolunteerCon.Number_of_wishes_active__c != Null && Integer.valueOf(dbVolunteerCon.Number_of_wishes_active__c) > 0 ){
                        newCon.Number_of_wishes_active__c =Integer.valueOf(dbVolunteerCon.Number_of_wishes_active__c) + Integer.valueOf(volunteercountMap.get(sobjectMap.get(dbVolunteerCon.Id)));
                        
                    }else{
                        newCon.Number_of_wishes_active__c =  Integer.valueOf(volunteercountMap.get(sobjectMap.get(dbVolunteerCon.Id)));
                        system.debug('@@@@@@@@@@ ELSE IF newCon.Number_of_wishes_active__c @@@@@@@@@@@'+ newCon.Number_of_wishes_active__c);
                    }
                    updateContactList.add(newCon);
                }
            }
        }  
        if(updateContactList.size() > 0)
            update updateContactList;
    }
    
    public static void CreateNewVolunteerOpportunity(List<Volunteer_Opportunity__c > volunteerOpportunityList){
        Constant_AC  constant = new Constant_Ac(); 
        Id nonWishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        Id wishEvents = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        List<Volunteer_Opportunity__c> createNewVolunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        Set<Id> wishIdSet = new Set<Id>();
        List<CaseTeamMember> removeCaseTeamMemberList = new List<CaseTeamMember>();
        for(Volunteer_Opportunity__c  processVolOpportunity : volunteerOpportunityList){
            Volunteer_Opportunity__c newVolOpportunity = new Volunteer_Opportunity__c();
            newVolOpportunity.Chapter_Name__c = processVolOpportunity.Chapter_Name__c;
            newVolOpportunity.Chapter_Role_Opportunity__c = processVolOpportunity.Chapter_Role_Opportunity__c;
            newVolOpportunity.Date_Time__c = processVolOpportunity.Date_Time__c;
            if(processVolOpportunity.Non_Wish_Event__c != null){
                newVolOpportunity.Non_Wish_Event__c = processVolOpportunity.Non_Wish_Event__c;
                newVolOpportunity.RecordTypeId = nonWishEvents;
            }
            newVolOpportunity.Required_Forms_for_Volunteers__c = processVolOpportunity.Required_Forms_for_Volunteers__c;
            newVolOpportunity.Volunteer_Notes__c = processVolOpportunity.Volunteer_Notes__c ;
            if(processVolOpportunity.Wish__c != null){
                newVolOpportunity.Wish__c = processVolOpportunity.Wish__c; 
                newVolOpportunity.RecordTypeId = wishEvents ;
                wishIdSet.add(processVolOpportunity.Wish__c );
            }
            createNewVolunteerOpportunityList.add(newVolOpportunity);
            system.debug('########## createNewVolunteerOpportunityList @@@@@@@@'+createNewVolunteerOpportunityList);
        }
        
        
        for(CaseTeamMember dbcaseTeamMember : [SELECT id,MemberId, ParentId  FROM CaseTeamMember WHERE ParentId IN : wishIdSet AND MemberId != Null]){
            
            removeCaseTeamMemberList.add(dbcaseTeamMember);
            
        }
        if(removeCaseTeamMemberList.size() > 0)
            delete removeCaseTeamMemberList;
        
        if(createNewVolunteerOpportunityList.size() > 0)
            insert createNewVolunteerOpportunityList;
        
        
    }
    
    public void updateUserRoleId(Set<Id> updateUserSet,Set<Id> volcontactIds){
        String roleIdinVolOpp;
        String roleInUser;
        Set<Id> volConId = new Set<Id>();
        List<User> dbVolConList = new List<User>();
        for(Volunteer_Opportunity__c  dbOpportunity : [SELECT Id,Volunteer_Name__c ,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Id IN:updateUserSet]){
            volConId.add(dbOpportunity.Volunteer_Name__c);
            system.debug('@@@@@@@@ volConId @@@@@@@@@'+volConId);
            roleIdinVolOpp = dbOpportunity.Chapter_Role_Opportunity__r.Role_Name__c+String.Valueof(dbOpportunity.Non_Wish_Event__c);
            system.debug('@@@@@@@@ roleIdinVolOpp @@@@@@@@@'+roleIdinVolOpp);
        }
        
        for(User dbVolUser : [SELECT Id,ContactId,Hidden_Role_Name_Id__c FROM User WHERE ContactId IN: volcontactIds ]){
            if(dbVolUser.Hidden_Role_Name_Id__c != Null  && dbVolUser.Hidden_Role_Name_Id__c != ''){
                system.debug('@@@@@@@@ roleInUser @@@@@@@@@'+dbVolUser);
                roleInUser = dbVolUser.Hidden_Role_Name_Id__c ;
                system.debug('@@@@@@@@ roleInUser @@@@@@@@@'+roleInUser);
                if(roleInUser.contains(roleIdinVolOpp)){
                    system.debug('@@@@@@@@ roleInUser IF @@@@@@@@@'+roleInUser);
                    roleInUser.remove(roleIdinVolOpp);
                    string s2 = roleInUser.remove(roleIdinVolOpp);
                    dbVolUser.Hidden_Role_Name_Id__c  = s2;
                    system.debug('@@@@@@@@ s2 @@@@@@@@@'+s2); 
                    dbVolConList.add(dbVolUser);
                }
            }
        }
        
        if(dbVolConList.size() > 0) 
            update  dbVolConList;
    }
    /***************** Number Of Assignment ***********/
    public static void Updatecontacts(Set <ID> volunteerOppName){
        List<Contact> conList=new List<Contact>();
        for(Contact  Con:[SELECT Id,Number_of_Assignments__c,Name,(select id,Volunteer_Name__c from Volunteer_Opportunities__r where Volunteer_Name__c IN:volunteerOppName) FROM Contact  WHERE ID IN:volunteerOppName]){
            Contact cont=new Contact();
            cont.Number_of_Assignments__c=Con.Volunteer_Opportunities__r.size();
            cont.id=Con.Id;
            conList.add(cont);
        }
        update conList;
    }
    
    public static void ActiveWishCount(set<Id> volunteerIdsSet){
        set<string> parentWishIdsSet = new set<string>();
        set<Id> volunteerNameSet = new set<Id>();
        string key;
        list<Contact> updateActiveWishCount = new list<Contact>();
        Map<Id,Integer> volunteerWithCount = new Map<id,Integer>();
        for(Volunteer_Opportunity__c currVolOpp : [SELECT ID,Wish__c,Wish__r.Status,Volunteer_Name__c,IsApproved__c FROM Volunteer_Opportunity__c WHERE 
                                                   IsApproved__c = True AND (Wish__r.Status != 'Granted' AND Volunteer_Name__c IN: volunteerIdsSet AND Wish__r.Status != 'Completed')]){
                                                       key = currVolOpp.Wish__c + '_' + currVolOpp.Volunteer_Name__c;
                                                       system.debug('Inside if parentWishIdsSet**'+parentWishIdsSet);
                                                       
                                                       if(!parentWishIdsSet.contains(key)){
                                                           parentWishIdsSet.add(key);
                                                           system.debug('Inside if volunteerNameSet**'+volunteerNameSet);
                                                           
                                                           if(volunteerNameSet.contains(currVolOpp.Volunteer_Name__c)){
                                                               system.debug('Inside if volunteerNameSet**'+volunteerWithCount);
                                                               volunteerWithCount.put(currVolOpp.Volunteer_Name__c,volunteerWithCount.get(currVolOpp.Volunteer_Name__c)+1);
                                                           }
                                                           else{
                                                               system.debug('Inside else**'+currVolOpp.Volunteer_Name__c);
                                                               volunteerWithCount.put(currVolOpp.Volunteer_Name__c,1);
                                                               volunteerNameSet.add(currVolOpp.Volunteer_Name__c);
                                                           }
                                                       }
                                                       
                                                   }
        system.debug('volunteerWithCount**'+ volunteerWithCount);
        
        for(Contact volunteerContact : [SELECT ID,Number_of_wishes_active__c From Contact WHERE ID IN: volunteerIdsSet]){
            if(volunteerWithCount.containsKey(volunteerContact.Id)){
                volunteerContact.Number_of_wishes_active__c = volunteerWithCount.get(volunteerContact.Id);
                updateActiveWishCount.add(volunteerContact);
                
            }
            
        }
        if(updateActiveWishCount.size() > 0){
            Update updateActiveWishCount;
            
        }
        
    }
    
    
}