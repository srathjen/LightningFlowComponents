/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a Volunteer Opportunity record delete then it will call the corresponding methods based on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
public class VolOpportunity_OnBefore_Delete_Helper{
    
    //This method is used to update the volunteer oportunity Id into volunteer user record.
    public static void updateUserRoleId(Set<Id> updateUserSet,Set<Id> volcontactIds){
        String roleIdinVolOpp;
        String roleInUser;
        Set<Id> volConId = new Set<Id>();
        List<User> dbVolConList = new List<User>();
        try{
        for(Volunteer_Opportunity__c  dbOpportunity : [SELECT Id,Volunteer_Name__c ,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Id IN:updateUserSet]){
            volConId.add(dbOpportunity.Volunteer_Name__c);
            roleIdinVolOpp = dbOpportunity.Chapter_Role_Opportunity__r.Role_Name__c+String.Valueof(dbOpportunity.Non_Wish_Event__c);
        }
        for(User dbVolUser : [SELECT Id,ContactId,Hidden_Role_Name_Id__c FROM User WHERE ContactId IN: volcontactIds ]){
            if(dbVolUser.Hidden_Role_Name_Id__c != Null  && dbVolUser.Hidden_Role_Name_Id__c != ''){
                roleInUser = dbVolUser.Hidden_Role_Name_Id__c ;
                if(roleInUser.contains(roleIdinVolOpp)){
                    roleInUser.remove(roleIdinVolOpp);
                    string s2 = roleInUser.remove(roleIdinVolOpp);
                    dbVolUser.Hidden_Role_Name_Id__c  = s2;
                    dbVolConList.add(dbVolUser);
                }
            }
        }
        if(dbVolConList.size() > 0) 
            update  dbVolConList;
       }
       
       catch(Exception ex){
            for(Volunteer_Opportunity__c currRec : [SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volcontactIds]){
                ErrorMessage_AC.createdebugRec('VolOpportunity_OnBefore_Delete_Helper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateUserRoleId',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Volunteer_Opportunity__c currRec : [SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volcontactIds]){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
}