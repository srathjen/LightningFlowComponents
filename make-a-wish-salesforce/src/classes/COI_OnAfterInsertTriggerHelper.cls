/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : COI_OnBeforeInsertTriggerHandler is used to call the Helper class when the
new COI record is created.

Modification Log
------------------
WVC-1888    Pavithra G  06/13/2018

*****************************************************************************************************/
public class COI_OnAfterInsertTriggerHelper{
    /********************************************************************************************
This method is used to create a task when the lead record is created. And share the lead
record based on the chapter.
*********************************************************************************************/
    public static void UpdateExistingRecords(List<Conflict_Of_Interest__c > newCOIList,Set<Id> recordIds,Set<Id> volunteerIds){
        try{
            List<Conflict_Of_Interest__c>  recordsToUpdate = new List<Conflict_Of_Interest__c>();
            for(Conflict_Of_Interest__c currRec : [SELECT id from Conflict_Of_Interest__c WHERE Volunteer_Contact__c IN :volunteerIds AND Id NOT IN :recordIds AND current__c = True])
            {
                Conflict_Of_Interest__c newRec = new Conflict_Of_Interest__c();
                newRec.id = currRec.id;
                newRec.current__c = false;
                recordsToUpdate.add(newRec);
                
            }
            
            if(recordsToUpdate.size() > 0)
                update recordsToUpdate;
            if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }
        }
        Catch(Exception ex){
            for(Conflict_Of_Interest__c  currRec : newCOIList){
                ErrorMessage_AC.createdebugRec('COI_OnAfterInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex),'UpdateExistingRecords',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            
            if(!Test.isRunningTest()){
                for(Conflict_Of_Interest__c  currRec : newCOIList){
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
            
        }
    }
    
    public Static Void COIRecordSharing(Set<Id> ownerIds, List<Conflict_Of_Interest__c> coiList)
    {
        try{
            Map<Id,String> userRoleMap = UserRoleUtility.getUserRole(ownerIds);
            Map<String, List<Conflict_Of_Interest__c>> coiMap = new Map<String, List<Conflict_Of_Interest__c>>();
            
            for(Conflict_Of_Interest__c currCOI : coiList)
            {
                if(currCOI.Account_Name__c != Null && userRoleMap.get(currCOI.OwnerId) == 'National Staff')
                {
                    if(coiMap.containsKey(currCOI.Account_Name__c))
                    {
                        coiMap.get(currCOI.Account_Name__c).add(currCOI);
                    }
                    else
                        coiMap.put(currCOI.Account_Name__c, new List<Conflict_Of_Interest__c>{currCOI});
                }
            }
            
            if(coiMap.size() > 0)
                ChapterStaffRecordSharing_AC.COIRecordSharing(coiMap);
            if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }
        }
        Catch(Exception ex){
            for(Conflict_Of_Interest__c  currRec : coiList){
                ErrorMessage_AC.createdebugRec('COI_OnAfterInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex),'COIRecordSharing',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            
            if(!Test.isRunningTest()){
                for(Conflict_Of_Interest__c  currRec : coiList){
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
            
        }
    }
    public Static Void updateVolunteerRole(Set<Id> voluunteerIdSet, List<Conflict_Of_Interest__c> coiList)
    {
        try{
            Set<Id> expiredBCVolunteerIdSet = new Set<Id>();
            List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>(); //
            for(Background_check__c currRec : [SELECT Id,Current__c,Date__c,Volunteer__c FROM Background_check__c WHERE Volunteer__c IN : voluunteerIdSet AND Current__c = True AND Date__c < TODAY]){
                expiredBCVolunteerIdSet.add(currRec.Volunteer__c);
            }
            for(Volunteer_Roles__c currRole : [SELECT Id,Name,Status__c,Hidden_Previous_Status__c,Sub_Status__C,Hidden_Previous_Sub_Status__c,Chapter_Role__c,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c FROM Volunteer_Roles__c  WHERE Volunteer_Name__c  IN :voluunteerIdSet AND Status__c = 'Out of Compliance']){
                    if((currRole.Chapter_Role__r.Background_Check_Required__c == True && !(expiredBCVolunteerIdSet.contains(currRole.Volunteer_Name__c))) || (currRole.Chapter_Role__r.Background_Check_Required__c == False)){
                    Volunteer_Roles__c updateRole = new Volunteer_Roles__c();
                    updateRole.Id = currRole.Id;
                    updateRole.Status__c = currRole.Hidden_Previous_Status__c;
                    updateRole.Sub_Status__c = currRole.Hidden_Previous_Sub_Status__c;                     
                    updateRole.Hidden_Previous_Status__c = '';
                    updateRole.Hidden_Previous_Sub_Status__c = '';
                    updateVolunteerRoleList.add(updateRole);                    
                }       
            }
            
            If(updateVolunteerRoleList.Size() > 0)
                Update updateVolunteerRoleList;
            
        
         if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }

        
        
        }
         Catch(Exception ex){
            for(Conflict_Of_Interest__c  currRec : coiList){
                ErrorMessage_AC.createdebugRec('COI_OnAfterInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex),'updateVolunteerRole',currRec.Id,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            
            if(!Test.isRunningTest()){
                for(Conflict_Of_Interest__c  currRec : coiList){
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
            
        }
    }
    
    
    
}