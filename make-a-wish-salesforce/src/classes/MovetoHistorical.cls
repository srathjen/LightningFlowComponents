/****************************************************************************************
Author : MST Solutions
CreateDate : 10/03/2017
Description : This Controller is used to update the volunteer opportunity status as "completed" when 
the user click the Move to Historical button on volunteer opportunity detail page for wish 
related volunteer opportunity.
*****************************************************************************************/
global class MovetoHistorical{
    
    /*This method return boolean value when the user click the Move to Historical button clicked. 
    Whether the move to historical is checked or not in the role object.*/
    Webservice static boolean CheckHistoricalRole(Id VolunteerOpportunityId){
        
        List<Volunteer_Opportunity__c> dbVolunteerOpportunity = [SELECT Id,Wish__c,Non_Wish_Event__c,Chapter_Role_Opportunity__r.Role_Name__r.Moved_to_Historical_by_Volunteer__c FROM Volunteer_Opportunity__c WHERE Id =: VolunteerOpportunityId Limit 1];
         return dbVolunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__r.Moved_to_Historical_by_Volunteer__c;
        }
    
    /*This method is used to update the volunteer opportunity status as "completed" and also update the 
    case team member role as "Inactive" and moved that volunteer opportunity to "Historical" tab  .*/
    Webservice static String UpdateVolunteerOpportunity(Id VolunteerOpportunityId){
        Constant_AC  constant = new Constant_Ac();  
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        Set<Id> WishIdSet = new Set<Id>();
        List<CaseTeamMember> CaseTeamMemList = new List<CaseTeamMember>();
        String message;
        String roleName;
        String dbroleName;
        for(Volunteer_Opportunity__c dbVolunteerOpportunity : [SELECT Id,Wish__c,Non_Wish_Event__c,Volunteer_Name__c,Status__c,RecordTypeId,Chapter_Role_Opportunity__r.Role_Name__r.Name From Volunteer_Opportunity__c WHERE Id =: VolunteerOpportunityId AND Volunteer_Name__c != Null]){
            if(dbVolunteerOpportunity.Wish__c != Null ){
                WishIdSet.add(dbVolunteerOpportunity.Wish__c);
            }
            dbroleName = dbVolunteerOpportunity.Chapter_Role_Opportunity__r.Role_Name__r.Name;
            roleName = dbVolunteerOpportunity.Chapter_Role_Opportunity__r.Role_Name__r.Name+' '+'(Inactive)';
            dbVolunteerOpportunity.Status__c = 'Completed';
            volunteerOpportunityList.add(dbVolunteerOpportunity);
            }
        if(WishIdSet.size()> 0){
            List<CaseTeamRole> dbCaseTeamRole =  [SELECT Id,Name FROM CaseTeamRole WHERE Name =: roleName];
            if(dbCaseTeamRole.size() > 0){
                for(CaseTeamMember dbCaseTeamMember : [SELECT Id,MemberId,Member.FirstName,Member.LastName,ParentId,Parent.RecordTypeId,TeamRoleId,TeamRole.Name FROM CaseTeamMember WHERE ParentId IN: WishIdSet AND TeamRole.Name =: dbroleName]){
                    dbCaseTeamMember.TeamRoleId = dbCaseTeamRole[0].Id;
                    CaseTeamMemList.add(dbCaseTeamMember);
                }
            }
            else{
                message = 'Please add inactive role for the wish';
            }
        }
        try{
            if(volunteerOpportunityList.size() > 0){
                update volunteerOpportunityList;
                message = 'Success';
            }
            if(CaseTeamMemList.size() > 0){
             update CaseTeamMemList;
            }
        }
        catch (DMLException Ex){
            message = Ex.getMessage();
        }
        return message;
    } 
}