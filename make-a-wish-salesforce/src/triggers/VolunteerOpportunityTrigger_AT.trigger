/*************************************************************************************************
Author   : MST Solutions
CreatedDate : 05/27/2015
Description : TBD
*************************************************************************************************/

trigger VolunteerOpportunityTrigger_AT on Volunteer_Opportunity__c (Before Insert,Before Update,After Insert,After Update,After delete) {
    Constant_AC  constant = new Constant_AC();
    
    Id registeredWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.registeredWish).getRecordTypeId();
    Id registeredNonWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.registeredNonWish).getRecordTypeId();
    Id wishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
    Id nonWishRecordTypeId = Schema.SobjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
    if(Trigger.isBefore && Trigger.isUpdate){
        
        Set<Id> volunteerContactIdSet = new set<Id>();
        Map<Id,String> volunteerContactMap = new Map<Id,String>();
        for(Volunteer_Opportunity__c currRec : Trigger.new)
        {
           
                
                if(currRec.Volunteer_Name__c!= Null){
                    
                    volunteerContactIdSet.add(currRec.Volunteer_Name__c);
                }
                if(currRec.Reason_Inactive__c != Null){
                    currRec.Inactive__c = True;
                }
                
                if(currRec.RecordTypeId == wishRecordTypeId  && currRec.IsApproved__c == true){
                    currRec.RecordTypeId = registeredWishRecordTypeId;
                }
                if(currRec.RecordTypeId == nonWishRecordTypeId && currRec.IsApproved__c == true){
                    currRec.RecordTypeId = registeredNonWishRecordTypeId;
                }
                /*   if(currRec.IsApproved__c == True && currRec.Volunteer_Name__c!= Null && Trigger.oldMap.get(currRec.id).Reason_Inactive__c == Null  && currRec.Reason_Inactive__c != Null){
volunteerOpportunityList.add(currRec);
System.debug('>>>>>>>1111111>>>>>'+currRec.Hidden_Volunteer_Contact_Email__c);
} */
            
        }
        
        if(volunteerContactIdSet.size() > 0){
            for(Contact volunteerContact : [SELECT Id,Email From Contact WHERE Id IN:volunteerContactIdSet]){
                
                volunteerContactMap.put(volunteerContact.Id,volunteerContact.Email);
            }
        }
        if(volunteerContactMap.size() > 0){
            for(Volunteer_Opportunity__c currRec : Trigger.new){
                if(currRec.Volunteer_Name__c!= Null && volunteerContactMap.containsKey(currRec.Volunteer_Name__c)){
                    currRec.Hidden_Volunteer_Contact_Email__c = volunteerContactMap.get(currRec.Volunteer_Name__c);
                    System.debug('>>>>>>>222222>>>>>'+currRec.Hidden_Volunteer_Contact_Email__c);
                }
            }
        }
        /*  if(volunteerOpportunityList.size() > 0){
system.debug('@@@@@@@@ createNewVolunteerOpportunityList @@@@@@@@'+volunteerOpportunityList);
VolunteerOpportunityTriggerHandler.CreateNewVolunteerOpportunity(volunteerOpportunityList);
} */
    }
    
    
    if(Trigger.IsBefore && Trigger.isDelete){
        Set<Id> updateUserSet = new Set<Id>();
        Set<Id> volconId= new Set<Id>();
        for(Volunteer_Opportunity__c oldDbRec : trigger.old){
            
            if(oldDbRec.Volunteer_Name__c != Null){
                updateUserSet.add(oldDbRec.Id);
                volconId.add(oldDbRec.Volunteer_Name__c );
            }
        }
        
        if(updateUserSet.size() > 0)
        {
            VolunteerOpportunityTriggerHandler volTriggerHandler = new VolunteerOpportunityTriggerHandler();
            volTriggerHandler.updateUserRoleId(updateUserSet,volconId);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        
        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> VolunteerwishIdSet = new Set<Id>();
        set<Id> volunteerIdsSet = new set<Id>();
        //Map<id,set<id>> volunteerWishMap = new Map<id,set<id>>();
        List<Volunteer_Opportunity__c> recordsForApprovalProcess = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams = new List<Volunteer_Opportunity__c>();
        Map<Id,Volunteer_Opportunity__c> volunteerforApexSharing = new Map<Id,Volunteer_Opportunity__c>();
        Map<String,Set<String>> volunteerCaseMap = new Map<String, set<String>>();
        List<Volunteer_Opportunity__c> nonWishList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> nonWishListtoupdatecount = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> updateWishGrantedList = new List<Volunteer_Opportunity__c>();
        Set<Id> updateUserSet = new Set<Id>();
        Set<Id> volconId= new Set<Id>();
        List<Volunteer_Opportunity__c> rejectedVolunteerOpportunitiesList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> volOpportunitySharingList = new List<Volunteer_Opportunity__c>();
        Set<Id> wishIds = new Set<Id>();
        
        for(Volunteer_Opportunity__c currRec : Trigger.new)
        { 
            if(currRec.isRejected__c == true && currRec.isRejected__c != Trigger.oldMap.get(currRec.Id).isRejected__c) {
                if(RecursiveTriggerHandler.isFirstTime == true || Test.isRunningTest())
                {
                    rejectedVolunteerOpportunitiesList.add(currRec);
                    wishIds.add(currRec.wish__c);
                }
            }
           
                if(currRec.IsApproved__c == False &&  (currRec.Volunteer_Name__c!= Null && Trigger.oldMap.get(currRec.id).Volunteer_Name__c== Null)&& (currRec.Wish__c != Null && currRec.Reason_Inactive__c == Null))
                {
                    
                    recordsForApprovalProcess.add(currRec); 
                    chapterIdsSet.add(currRec.Chapter_Name__c);
                } 
                
                if(currRec.IsApproved__c == true && currRec.Volunteer_Name__c!= Null && Trigger.oldMap.get(currRec.id).Reason_Inactive__c == Null  && currRec.Reason_Inactive__c != Null){
                    if(RecursiveTriggerHandler.isFirstTime == true || Test.isRunningTest())
                {
                    volunteerOpportunityList.add(currRec);
                 }
                    System.debug('>>>>>>>1111111>>>>>'+currRec.Hidden_Volunteer_Contact_Email__c);
                }
                else if(currRec.IsApproved__c == False &&  (currRec.Volunteer_Name__c!= Null && Trigger.oldMap.get(currRec.id).Volunteer_Name__c== Null)&& (currRec.Wish__c == Null) && (currRec.Non_Wish_Event__c != Null && currRec.Reason_Inactive__c == Null)){
                    
                    recordsForApprovalProcess.add(currRec); 
                    chapterIdsSet.add(currRec.Chapter_Name__c);
                }
                
                if((currRec.IsApproved__c == True && Trigger.oldMap.get(currRec.id).isApproved__c == False)  &&  (currRec.Volunteer_Name__c!= Null) && (currRec.Wish__c != Null && currRec.Reason_Inactive__c == Null))
                {
                    volOpportunitySharingList.add(currRec); 
                    recordsForCreatingCaseTeams.add(currRec); 
                }
                
                
                
                if((currRec.Volunteer_Name__c != Null) &&(currRec.Wish__c != Null))
                {
                    volunteerforApexSharing.put(currRec.Id,currRec);
                    if(volunteerCaseMap.containsKey(currRec.Volunteer_Name__c))
                    {
                        volunteerCaseMap.get(currRec.wish__c).add(currRec.Volunteer_Name__c);
                    }
                    else
                    {
                        volunteerCaseMap.put(currRec.wish__c,new Set<String>{currRec.Volunteer_Name__c});
                    }
                }
                
                if((currRec.Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && currRec.IsApproved__c == false && currRec.isRejected__c == true) || (currRec.Volunteer_Name__c == Null && trigger.oldMap.get(currRec.Id).Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && (currRec.IsApproved__c == false || currRec.IsApproved__c == true) && currRec.Reason_Inactive__c == Null)){
                    
                    nonWishListtoupdatecount.add(currRec);
                }
                
                if(currRec.Volunteer_Name__c == Null && trigger.oldMap.get(currRec.Id).Volunteer_Name__c  != Null){
                    updateUserSet.add(currRec.Id);
                    volconId.add(trigger.oldMap.get(currRec.Id).Volunteer_Name__c);
                }
                if((currRec.Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && currRec.IsApproved__c == true && currRec.Reason_Inactive__c != Null) || (currRec.Volunteer_Name__c == Null && trigger.oldMap.get(currRec.Id).Volunteer_Name__c != Null && currRec.Non_Wish_Event__c != Null && currRec.IsApproved__c == false && currRec.Reason_Inactive__c == Null)){
                    system.debug('@@@@@@@ currRec.Volunteer_Name__c @@@@@@@@@'+currRec.Volunteer_Name__c);
                    nonWishListtoupdatecount.add(currRec);
                }
                
                if(currRec.Volunteer_Name__c != Null && currRec.Wish__c != Null && currRec.IsApproved__c == true && trigger.oldMap.get(currRec.Id).IsApproved__c  == false ){
                    //VolunteerwishIdSet.add(currRec.Wish__c);
                    volunteerIdsSet.add(currRec.Volunteer_Name__c);
                }
          
        }
        
          if(volunteerOpportunityList.size() > 0){
            if(RecursiveTriggerHandler.isFirstTime == true || Test.isRunningTest()){
                VolunteerOpportunityTriggerHandler.CreateNewVolunteerOpportunity(volunteerOpportunityList);
            }
        }
        
        if(rejectedVolunteerOpportunitiesList.size() > 0) {
            VolunteerOpportunityTriggerHandler.CreateVolunteerOpportunityRecord(rejectedVolunteerOpportunitiesList,wishIds);
        }
        if(volunteerIdsSet.size() > 0){
            VolunteerOpportunityTriggerHandler.ActiveWishCount(volunteerIdsSet);
        }
        if(updateUserSet.size() > 0)
        {
            VolunteerOpportunityTriggerHandler volTriggerHandler = new VolunteerOpportunityTriggerHandler();
            volTriggerHandler.updateUserRoleId(updateUserSet,volconId);
        }
        
        //Used to create approval process for volunteer opportunity record
        if(recordsForApprovalProcess.size() > 0 && chapterIdsSet.size()>0) {
            VolunteerOpportunityTriggerHandler.SubmitforApprovalProcess(recordsForApprovalProcess, chapterIdsSet);
        }
        //Adding to volunteer to case team member once it is approved
        if(recordsForCreatingCaseTeams.size() > 0) {
            VolunteerOpportunityTriggerHandler.CreateCaseTeamMembers(recordsForCreatingCaseTeams);
        }
        
        if(volunteerCaseMap.size() > 0) {
            //VolunteerRecordSharing_AC.recordSharing(volunteerforApexSharing,volunteerCaseMap);
        }
        
        
        if(nonWishListtoupdatecount.Size() > 0 && RecursiveTriggerHandler.isFirstTime == true  ){
            system.debug('@@@@@@@ ENTER INTO IF  @@@@@@@@@'+nonWishListtoupdatecount);
            VolunteerOpportunityTriggerHandler.UpdateVolunteerRegisterdCount(nonWishListtoupdatecount);
            
        }
        if(updateWishGrantedList.size() > 0){
            //VolunteerOpportunityTriggerHandler.updateVolunteerWishGrantedCount(updateWishGrantedList);
        }
        if(VolunteerwishIdSet.size() > 0){
            // VolunteerOpportunityTriggerHandler.updateVolunteerWishAssignedCount(VolunteerwishIdSet);
        }
        
        if(volOpportunitySharingList.size() > 0)
            VolunteerOpportunityTriggerHandler.shareolunteerOpportunityRecord(volOpportunitySharingList);
        
    }
    
    If(Trigger.isAfter && Trigger.isDelete){
        List<Volunteer_Opportunity__c> nonWishListtoupdatecount = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> nonwishListRegisteredList = new List<Volunteer_Opportunity__c>();
        
        
        for(Volunteer_Opportunity__c oldDbRec : Trigger.old){
            
            if(oldDbRec.Volunteer_Name__c == Null && oldDbRec .Non_Wish_Event__c != Null && (oldDbRec.IsApproved__c == false || oldDbRec.IsApproved__c == true) && oldDbRec.Chapter_Role_Opportunity__c != Null && oldDbRec.Reason_Inactive__c == Null || oldDbRec.Reason_Inactive__c != Null){
                nonWishListtoupdatecount.add(oldDbRec);
            }
            
            if(oldDbRec.Volunteer_Name__c != Null && oldDbRec .Non_Wish_Event__c != Null && (oldDbRec.IsApproved__c == false || oldDbRec.IsApproved__c == true) && oldDbRec.Chapter_Role_Opportunity__c != Null && oldDbRec.Reason_Inactive__c == Null){
                nonwishListRegisteredList.add(oldDbRec);
            }
            
        }
        if(nonWishListtoupdatecount.Size() > 0){
            VolunteerOpportunityTriggerHandler.updatevolunteerNeededCount(nonWishListtoupdatecount);
        }
        
        if(nonwishListRegisteredList.size() > 0){
            VolunteerOpportunityTriggerHandler.updateVolunteerRegisterdCount(nonwishListRegisteredList);
        }
        
    }
    if(trigger.isafter && (trigger.isinsert || trigger.isupdate))
    {
        Set<ID> volunteerOppName=new Set<ID>();
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        for(Volunteer_Opportunity__c currRec:trigger.new){
            
           
                if(currRec.IsApproved__c==true && ((trigger.isinsert && currRec.Migrated_Record__c==false) || trigger.oldMap.get(currRec.id).IsApproved__c == false)){
                    volunteerOppName.add(currRec.Volunteer_Name__c);
                }
           
            
              
            if(currRec.Migrated_Record__c == True && Trigger.isInsert)
            {
               volunteerOppList.add(currRec);
            }
        }
        if(volunteerOppName.size() > 0){
            VolunteerOpportunityTriggerHandler.Updatecontacts(volunteerOppName);
        }
        if(volunteerOppList.size() > 0)
            VolunteerOpportunityTriggerHandler.CreateCaseTeamMembers(volunteerOppList);
        
   Map<String, List<Volunteer_Opportunity__c >> volunteerOppMap = new Map<String, List<Volunteer_Opportunity__c>>();
    
   for(Volunteer_Opportunity__c  currRec :[SELECT id, ownerId, owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c, 
                                       Chapter_Name__r.Name FROM Volunteer_Opportunity__c WHERE Id IN :Trigger.newMap.keySet()])
   {
     if( (Trigger.isInsert || (Trigger.isUpdate && currRec.OwnerId != Trigger.oldMap.get(currRec.Id).OwnerId)) 
           && currRec.Chapter_Name__c != Null && currRec.Owner.userRole.Name == 'National Staff') 
         {
                if(volunteerOppMap.containsKey(currRec.Chapter_Name__r.Name))
                   volunteerOppMap.get(currRec.Chapter_Name__r.Name).add(currRec);
                else
                   volunteerOppMap.put(currRec.Chapter_Name__r.Name, new List<Volunteer_Opportunity__c>{currRec});
         }
   } 
   
   if(volunteerOppMap.size() > 0)
           ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOppMap);
  }

}