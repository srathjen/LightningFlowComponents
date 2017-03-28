/**************************************************************************************************
Description : Its updating the Active flag as True whenever new records are inserted. And also its 
preventing duplicate active background check record.
Its updating Affiliation Record status based the Background check verification status.
***************************************************************************************************/

trigger BackGroundCheck_AT on Background_check__c (Before insert, Before update, After insert,After update) {
   
   //This is used to get volunteer conatct email and store value in hidden email field to send an email to this value
    if(Trigger.isBefore && Trigger.isInsert)
    {   Set<Id> volunteerIds = new Set<Id>();
        Map<Id,Contact> conMap = new Map<Id, Contact>();
        for(Background_check__c  currRec : Trigger.new)
        {
          if(currRec.Migrated_record__c == false)
          {
               if(!Test.isRunningTest())
               {
                    if(currRec.Date_Completed__c != null && (currRec.Status__c != Null))
                        currRec.Active__c = True;
               }
               volunteerIds.add(currRec.Volunteer__c);
          }
          if(currRec.Date_Completed__c != null)
          {
               currRec.Date__c = currRec.Date_Completed__c.addYears(3);
          }
        }
       
        if(volunteerIds.size() > 0)
        {
            BackGroundCheckTriggerHandler.UpdateHiddenEmailField(volunteerIds,Trigger.new);
        }
    }
    
// After Insert Begins Here----------------------
 // Deactivating Existing Records. 
    if(Trigger.isAfter && Trigger.isInsert)
    {
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        Map<String,List<Background_check__c>> bgcMap = new Map<String,List<Background_check__c>>();
        for(Background_check__c  currRec : Trigger.new)
        {
          if(currRec.Migrated_Record__c == false)
          {
            if(currRec.active__c == True)
            {
                newRecordIds.add(currRec.id);
                volunteerIds.add(currRec.Volunteer__c);
            }
            
            if(bgcMap.containsKey(currRec.Account_Name__c))
            {
                bgcMap.get(currRec.Account_Name__c).add(currRec);
            }
            else
                bgcMap.put(currRec.Account_Name__c,new List<Background_check__c>{currRec});
            
          }
          
          
        }
        if(newRecordIds.size() > 0 && volunteerIds.size() > 0)
        {
            BackGroundCheckTriggerHandler.DeactivateExistingRecords(newRecordIds,volunteerIds);
        }
        
        if(bgcMap.size() > 0)
        {
            ChapterStaffRecordSharing_AC.BGCRecordSharing(bgcMap);
        }
        
    }
    
// Before Update Event Begins Here---------------------------------------------------------

  // Preventing Duplicate Active Background Check.
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> volContactIdSet = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        for(Background_check__c currRec : Trigger.new)
        {   
                volunteerIds.add(currRec.volunteer__c);
                if(currRec.Date_Completed__c != null && currRec.Date_Completed__c != Trigger.oldMap.get(currRec.id).Date_Completed__c )
                {
                    currRec.Date__c = currRec.Date_Completed__c.addYears(3);
                }
                
                if((currRec.Date_Completed__c != null && CurrRec.Date_Completed__c != Trigger.oldMap.get(currRec.id).Date_Completed__c) 
                    && (currRec.Status__c != Null) && currRec.Status__c != Trigger.oldMap.get(currRec.id).status__c)
                {
                   currRec.Active__c = True;
                }
              
              
                if(currRec.active__c == True && Trigger.oldMap.get(currRec.id).active__c == false)
                { 
                    newRecordIds.add(currRec.id);
                    volContactIdSet.add(currRec.volunteer__c);
                }
           
           
           
        }
        if(volunteerIds.size() > 0)
        {
          BackGroundCheckTriggerHandler.UpdateHiddenEmailField(volunteerIds,Trigger.new);
        }
    
      /*  List<Background_check__c> exActiveRecList = [SELECT Id FROM Background_check__c WHERE Active__c = True AND ID NOT IN :newRecordIds];
    
        for(Background_check__c currRec : Trigger.new)
        {
           
            if(currRec.active__c == True && Trigger.oldMap.get(currRec.id).active__c == false)
            {
                if(exActiveRecList.size() > 0 && volContactIdSet.contains(currRec.volunteer__c))
                    currRec.addError('Active Background Check Already Exist'); 
            }
          
        }*/
     }
  
  
 // After  Update Events Begins Here -------------------------------
    
    // Updating Affiliation Status.
    If(Trigger.isAfter && Trigger.isUpdate)
    {
        Set<Id> rejectedIds = new Set<Id>();
        set<Id> approvedVolunteerIds = new Set<Id>();
        Map<Id,Background_check__c>   expirationDateMap = new Map<Id,Background_check__c>(); 
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        for(Background_check__c dbBackgroundCheckRec : trigger.new)
        {
            if(dbBackgroundCheckRec.Status__c == 'Approved' && dbBackgroundCheckRec.Status__c != Null && trigger.oldmap.get(dbBackgroundCheckRec.Id).Status__c != 'Approved')
            {
                approvedVolunteerIds.add(dbBackgroundCheckRec.Volunteer__c);
            }
            if((dbBackgroundCheckRec.Status__c == 'Rejected') && (Trigger.oldMap.get(dbBackgroundCheckRec.id).Status__c != 'Rejected') && dbBackgroundCheckRec.Status__c != Null)
            {
                rejectedIds.add(dbBackgroundCheckRec.Volunteer__c);
            }
            
            if(dbBackgroundCheckRec.Date__c != Null && Trigger.oldMap.get(dbBackgroundCheckRec.id).Date__c <> dbBackgroundCheckRec.Date__c)
            {
                 expirationDateMap.put(dbBackgroundCheckRec.Volunteer__c,dbBackgroundCheckRec);
            }
            
            if(dbBackgroundCheckRec.active__c == True && Trigger.oldMap.get(dbBackgroundCheckRec.id).active__c == false)
            {
                newRecordIds.add(dbBackgroundCheckRec.id);
                volunteerIds.add(dbBackgroundCheckRec.volunteer__c);
            }
        }
        
        if(newRecordIds.size() > 0 && volunteerIds.size() > 0)
        {
            BackGroundCheckTriggerHandler.DeactivateExistingRecords(newRecordIds,volunteerIds);
        }

        if(rejectedIds.size() > 0)
        {
            BackGroundCheckTriggerHandler.UpdateAffiliationStatusToDeclined(rejectedIds);
        }

        if(approvedVolunteerIds.size() > 0)
        {
            BackGroundCheckTriggerHandler.UpdateAffiliationStatusToPending(approvedVolunteerIds);
        }
        if(expirationDateMap.size() > 0)
        {
            BackGroundCheckTriggerHandler.UpdateVolunteerExpirationDate(expirationDateMap);
        }

    }
}