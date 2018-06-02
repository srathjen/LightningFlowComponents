/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeUpdateHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnAfterUpdateHandler{

     public static void OnAfterUpdate(List<Background_check__c> newBCList,Map<Id,Background_check__c> oldBCMap){
        Set<Id> rejectedIds = new Set<Id>();
        set<Id> approvedVolunteerIds = new Set<Id>();
        Map<Id,Background_check__c>   expirationDateMap = new Map<Id,Background_check__c>(); 
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> volunteerContactIdSet = new Set<Id>();
        Set<Id> backgroundRejectedSet = new Set<Id>();
        Map<String,List<Background_check__c>> bgcMap = new Map<String,List<Background_check__c>>();
        Set<String> chapterNamesSet = new Set<String>();
        Map<Id,String> chapterNameMap = new Map<Id,String>();
        Map<String,String> chapterRoleMap = new Map<String,String>();
        List<User> currUser = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Id =: UserInfo.getUserID() Limit 1];
        
        for(Background_check__c dbBackgroundCheckRec : newBCList)
        {
            if((dbBackgroundCheckRec.Status__c == 'Approved' || dbBackgroundCheckRec.Status__c ==  'Approved w/ Conditions') && dbBackgroundCheckRec.Status__c != Null && oldBCMap.get(dbBackgroundCheckRec.Id).Status__c != dbBackgroundCheckRec.Status__c && dbBackgroundCheckRec.Current__c == true)
            {
                approvedVolunteerIds.add(dbBackgroundCheckRec.Volunteer__c);
            }
            if((dbBackgroundCheckRec.Status__c == 'Rejected') && (oldBCMap.get(dbBackgroundCheckRec.id).Status__c != 'Rejected') && dbBackgroundCheckRec.Status__c != Null)
            {
                rejectedIds.add(dbBackgroundCheckRec.Volunteer__c);
            }
            
            if(dbBackgroundCheckRec.Date__c != Null && oldBCMap.get(dbBackgroundCheckRec.id).Date__c <> dbBackgroundCheckRec.Date__c && dbBackgroundCheckRec.current__c == True)
            {
                expirationDateMap.put(dbBackgroundCheckRec.Volunteer__c,dbBackgroundCheckRec);
            }
            
            if(dbBackgroundCheckRec.current__c == True && oldBCMap.get(dbBackgroundCheckRec.id).current__c == false)
            {
                newRecordIds.add(dbBackgroundCheckRec.id);
                volunteerIds.add(dbBackgroundCheckRec.volunteer__c);
            }
            
            if(dbBackgroundCheckRec.HiddenBackgroundExpire__c == true && oldBCMap.get(dbBackgroundCheckRec.Id).HiddenBackgroundExpire__c == false)
            {
                volunteerContactIdSet.add(dbBackgroundCheckRec.Volunteer__c);
            }
            if(dbBackgroundCheckRec.Hidden_Background_Rejected__c == true && oldBCMap.get(dbBackgroundCheckRec.Id).Hidden_Background_Rejected__c == false)
            {
                backgroundRejectedSet.add(dbBackgroundCheckRec.Volunteer__c);
            }
            // if(dbBackgroundCheckRec.ownerId != Trigger.oldMap.get(dbBackgroundCheckRec.id).ownerId)
            //  ownerIds.add(dbBackgroundCheckRec.ownerId);
            if(dbBackgroundCheckRec.Account_Name__c != Null && currUser[0].UserRole.Name != 'National Staff' && currUser[0].profile.Name != 'System Administrator' && currUser[0].profile.Name != 'Integration'  && currUser[0].profile.Name != 'Active Volunteer (Login)' && currUser[0].profile.Name != 'Active Volunteer (Member)'){
                chapterNamesSet.add(dbBackgroundCheckRec.Account_Name__c );
                chapterNameMap.put(dbBackgroundCheckRec.Id,dbBackgroundCheckRec.Account_Name__c ); 
            }
        }
        
        if(chapterNamesSet.Size() > 0){
            chapterRoleMap=ChapterStaffRecordSharing_AC.FindChapterRole(chapterNamesSet);
            
            for(Background_check__c currRec :newBCList){ 
                system.debug('Chapter Name****************'+chapterNameMap.get(currRec.Id));
                if((chapterRoleMap.get(chapterNameMap.get(currRec.Id)) != currUser[0].UserRole.Name || currRec.Account_Name__C != oldBCMap.get(currRec.Id).Account_Name__C) && !Test.isRunningTest())
                {
                    currRec.addError('Insufficient previlege to update this record. Please contact system administrator.');        
                }
            }
        } 
        
        /*   Map<id, String> userRoleMap = UserRoleUtility.getUserRole(ownerIds);
        for(Background_check__c currRec : Trigger.new)
        {
        if(currRec.Account_Name__c != Null && userRoleMap.get(currRec.OwnerId) == 'National Staff' 
        && currRec.OwnerId != Trigger.oldMap.get(currRec.id).ownerId)
        {  
        if(bgcMap.containsKey(currRec.Account_Name__c))
        {
        bgcMap.get(currRec.Account_Name__c).add(currRec);
        }
        else
        bgcMap.put(currRec.Account_Name__c,new List<Background_check__c>{currRec});
        }
        }*/
                
                /* if(volunteerIds.size() > 0)
        {
        BackGroundCheckTriggerHandler.UpdateHiddenEmailField(volunteerIds,Trigger.new);
        }*/
        
        if(newRecordIds.size() > 0 && volunteerIds.size() > 0)
        {
            BackGroundCheck_OnAfterInsertHelper.DeactivateExistingRecords(newRecordIds,volunteerIds,newBCList);
        }
        
        if(rejectedIds.size() > 0)
        {
            BackGroundCheck_OnAfterUpdateHelper.UpdateAffiliationStatusToDeclined(rejectedIds,newBCList);
        }
        
        if(approvedVolunteerIds.size() > 0)
        {
            BackGroundCheck_OnAfterUpdateHelper.UpdateAffiliationStatusToPending(approvedVolunteerIds,newBCList);
            BackGroundCheck_OnAfterUpdateHelper.updateVolunteerHiddenVolOTStatus(approvedVolunteerIds,newBCList);
        }
        if(expirationDateMap.size() > 0)
        {
            BackGroundCheck_OnAfterInsertHelper.UpdateVolunteerExpirationDate(expirationDateMap);
        }
        
        if(volunteerContactIdSet.size() > 0)
            BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(volunteerContactIdSet,'backgroundcheck',newBCList);
        
        if(backgroundRejectedSet.size() > 0)
            BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(backgroundRejectedSet,'backgroundcheck',newBCList);
     }
}