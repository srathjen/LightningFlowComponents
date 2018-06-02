/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeUpdateHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnAfterUpdateHelper{

// If Interview Task is rejected, then update affiliation status as "Declined".
    public static void UpdateAffiliationStatusToDeclined(Set<Id> rejectedIds,List<Sobject> exceptionList)
    {
        try{
            List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
            for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :rejectedIds AND npe5__Status__c != 'Active'])
            {
                npe5__Affiliation__c  updateRec = new npe5__Affiliation__c();
                updateRec.npe5__Status__c = 'Declined';
                updateRec.id = dbAffiliationRec.id;
                affiliationList.add(updateRec);
            }
            
            if(affiliationList.size() > 0){
                update affiliationList;
            }
        }
         catch(Exception ex){
            for(SObject currRec : exceptionList){
                ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdateAffiliationStatusToDeclined',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(SObject  currRec : exceptionList){
                currRec.addError(Label.Debug_log_error_message);
            } 
        }
        
    }
    // If Interview Task is approved, then update affiliation status as "Pending/Active" based on the training required.
    public static void UpdateAffiliationStatusToPending(Set<Id> approvedVolunteerIds,List<Background_check__c> exceptionList)
    {   
        try{
            List<npe5__Affiliation__c> updateAffliationList = new List<npe5__Affiliation__c>();
            Set<Id> activeContactIdsSet = new Set<Id>();
            Constant_AC  constant = new Constant_Ac(); 
            Id triainingRecordTypeId = Schema.Sobjecttype.Orientation_Training__c.getRecordTypeInfosByName().get(constant.trainingRT).getRecordTypeId();  
            Set<Id> orientationTrainingId = new Set<Id>();
            Map<String, Set<String>> volunteerChapterRoleMap = new Map<String, Set<String>>();
            Set<Id> chapterRolesSet = new Set<Id>();
            for(Volunteer_Roles__c currRole : [SELECT Id,Name,Chapter_Role__c,Volunteer_Name__c FROM Volunteer_Roles__c  WHERE Volunteer_Name__c  IN :approvedVolunteerIds])
            {
                chapterRolesSet.add(currRole.Chapter_Role__c);
                if(volunteerChapterRoleMap.containsKey(currRole.Volunteer_Name__c))
                    volunteerChapterRoleMap.get(currRole.Volunteer_Name__c).add(currRole.Chapter_Role__c); 
                else
                    volunteerChapterRoleMap.put(currRole.Volunteer_Name__c, new Set<String>{currRole.Chapter_Role__c}); 
            }
            
            Set<String> chapterRoleOandTsSet = new Set<String>();
            Map<String,Conflict_Of_Interest__c> coiMap = new Map<String,Conflict_Of_Interest__c>();
            
            for(Chapter_Role_O_T__c currChapterRole : [SELECT Id,Name,Orientation_Training__c,Orientation_Training__r.RecordTypeId,Required__c,Chapter_Role__c FROM Chapter_Role_O_T__c WHERE Chapter_Role__c IN :chapterRolesSet AND Required__c = TRUE AND Orientation_Training__r.RecordTypeId =:triainingRecordTypeId])
            {
                chapterRoleOandTsSet.add(currChapterRole.Chapter_Role__c);
            }
            
            for(Conflict_Of_Interest__c currCOI : [SELECT  id, Volunteer_Contact__c, Expiration_Date__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c IN :approvedVolunteerIds AND Expiration_Date__c > : Date.Today()])
            {
                coiMap.put(currCOI.Volunteer_Contact__c, currCOI);
            }
            
            for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : approvedVolunteerIds AND npe5__Status__c != 'Active'])
            {
                
                npe5__Affiliation__c currAffiliation = new npe5__Affiliation__c();
                if(coiMap.containsKey(dbAffiliationRec.npe5__Contact__c))
                {
                    currAffiliation.npe5__Status__c = 'Active';
                }
                else
                {
                    currAffiliation.npe5__Status__c = 'Pending';
                }
                currAffiliation.id = dbAffiliationRec.id;    
                if(volunteerChapterRoleMap.containsKey(dbAffiliationRec.npe5__Contact__c)){
                    for(String currChapterRole : volunteerChapterRoleMap.get(dbAffiliationRec.npe5__Contact__c))
                    {
                        if(chapterRoleOandTsSet.contains(currChapterRole))
                        {
                            currAffiliation.npe5__Status__c = 'Pending';
                        }
                        
                    }
                }
                
                if(currAffiliation.npe5__Status__c == 'Active')
                    activeContactIdsSet.add(dbAffiliationRec.npe5__Contact__c);
                updateAffliationList.add(currAffiliation);
            }
            
            if(updateAffliationList.size() > 0)
            {
                update updateAffliationList;
                if(activeContactIdsSet.size() > 0)
                    VolunteerOandTHandler.updateUser(activeContactIdsSet);
            }
        }
        catch(Exception ex){
           for(Background_check__c currRec : exceptionList){
                ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdateAffiliationStatusToPending',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(Background_check__c currRec : exceptionList){
                currRec.addError(Label.Debug_log_error_message);
            } 
        }
        
    }
    
    //Update the hidden vaolunteer role status on contact.
    Public static void updateVolunteerHiddenVolOTStatus(Set<Id> volIdsSet,List<Background_check__c> exceptionList){
        try{
            Map<ID,ID> chapterRoleIdsMap = new Map<ID,ID>();
            Set<ID> roleSpecificVolIdsSet = new Set<ID>();
            List<Contact> updateVolunteerConList = new List<Contact>();
            for(Volunteer_Roles__c currVolRole :[SELECT ID,Chapter_Role__c,Volunteer_Name__c from Volunteer_Roles__c WHERE Volunteer_Name__c IN:volIdsSet]){
                chapterRoleIdsMap.put(currVolRole.Chapter_Role__c, currVolRole.Volunteer_Name__c);
            }
            if(chapterRoleIdsMap.size() > 0){
                for(Chapter_Role_O_T__c currChpterRole: [SELECT ID,Chapter_Role__c FROM Chapter_Role_O_T__c WHERE Chapter_Role__c IN:chapterRoleIdsMap.keySet() AND Required__c = true]){
                    if(chapterRoleIdsMap.containsKey(currChpterRole.Chapter_Role__c)){
                        roleSpecificVolIdsSet.add(chapterRoleIdsMap.get(currChpterRole.Chapter_Role__c));
                        
                    }
                }
                
            }
            if(roleSpecificVolIdsSet.size() > 0){
                for(Contact currContact: [SELECT ID FROM Contact WHERE ID IN:roleSpecificVolIdsSet]){
                    currContact.Hidden_Volunteer_OT_Status__c = 'Role Specific Training Available';
                    updateVolunteerConList.add(currContact);
                    
                }
            }
            if(updateVolunteerConList.size() > 0){
                update updateVolunteerConList;
            }
        }
        catch(Exception ex){
           for(Background_check__c currRec : exceptionList){
                ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateVolunteerHiddenVolOTStatus',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(Background_check__c currRec : exceptionList){
                currRec.addError(Label.Debug_log_error_message);
            } 
        }
        
    }
    
    //Update volunteer Opportunity and volunteer Role status.
    Public static void UpdateVOppAndVRoleStatus(Set<Id> volunteerContactIdSet,string objectName,List<Sobject> exceptionList){
        try{
            if(volunteerContactIdSet.size() > 0){
                List<Volunteer_Opportunity__c> updateVolOpportunityList = new List<Volunteer_Opportunity__c>();
                List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
                Map<Id,Volunteer_Roles__c> VolunteerRoleMap = new Map<Id,Volunteer_Roles__c>();
                for(Volunteer_Opportunity__c dbVolOpportunity : [SELECT Id,Volunteer_Name__c,Status__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volunteerContactIdSet AND Status__c != 'Out of Compliance']){
                    
                    Volunteer_Opportunity__c updateVolStatus = new Volunteer_Opportunity__c();
                    updateVolStatus.Id = dbVolOpportunity.Id;
                    updateVolStatus.Status__c  = 'Out of Compliance';
                    updateVolOpportunityList.add(updateVolStatus);
                    
                }
                
                for(Volunteer_Roles__c dbVolRole : [SELECT Id,Volunteer_Name__c,Status__c,Chapter_Role__c,Chapter_Role__r.Background_Check_Required__c FROM Volunteer_Roles__c Where Volunteer_Name__c IN: volunteerContactIdSet AND  Status__c != 'Out of Compliance']){
                    
                    Volunteer_Roles__c updateVolStatus = new Volunteer_Roles__c();
                    updateVolStatus.Id = dbVolRole.Id;
                    if(dbVolRole.Chapter_Role__r.Background_Check_Required__c == true && objectName == 'backgroundcheck'){
                        updateVolStatus.Status__c = 'Out of Compliance';
                    }
                    if(objectName == 'COI'){
                        updateVolStatus.Status__c = 'Out of Compliance';
                    }
                    VolunteerRoleMap.put(updateVolStatus.Id,updateVolStatus);
                }
                
                
                
                if(updateVolOpportunityList.size() > 0)
                    update updateVolOpportunityList;
                
                if(VolunteerRoleMap.size() > 0)
                    update VolunteerRoleMap.values();
            }
        }
        catch(Exception ex){
           for(Sobject currRec : exceptionList){
                ErrorMessage_AC.createdebugRec('BackGroundCheck_OnAfterUpdateHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdateVOppAndVRoleStatus',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(Sobject currRec : exceptionList){
                currRec.addError(Label.Debug_log_error_message);
            } 
      }
    }
    
}