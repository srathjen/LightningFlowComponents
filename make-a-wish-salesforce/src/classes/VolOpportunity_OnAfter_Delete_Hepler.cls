/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a Volunteer Opportunity record delete then it will call the corresponding methods based on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
Public class VolOpportunity_OnAfter_Delete_Hepler{
    
     /*This updatevolunteerNeededCount() is used to update count of the number of volunteer opportunities that are created for the corresponding NonWish & Event.*/
    public static void UpdatevolunteerNeededCount(List<Volunteer_Opportunity__c> nonWishListtoupdatecount){
        Set<Id> chapterRoleIdSet = new Set<Id>();
        Set<Id> NonWishEventIdSet = new Set<Id>();
        set<String> volunteercountDescSet = new Set<String>();
        List<Volunteer_Count__c > volunteercountIdList = new List<Volunteer_Count__c>();
        Boolean isRegistered = false;
        Map<Id,Integer> volunteercountMap = new Map<Id,Integer>();
        List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
        
        try{
        for(Volunteer_Opportunity__c newVolOpp :nonWishListtoupdatecount){
            chapterRoleIdSet .add(newVolOpp.Chapter_Role_Opportunity__c);
            NonWishEventIdSet .add(newVolOpp.Non_Wish_Event__c);
            volunteercountDescSet.add(newVolOpp.Hidden_VolunteerCount_Desc__c+''+newVolOpp.Date__c+''+newVolOpp.Start_Time__c+''+newVolOpp.End_Time__c);
        }
        List<AggregateResult> groupedResults = [SELECT Chapter_Role_Opportunity__c nonwish, Count(Id)aver,Hidden_VolunteerCount_Desc__c   FROM Volunteer_Opportunity__c WHERE Non_Wish_Event__c IN: NonWishEventIdSet AND Reason_Inactive__c = Null AND Chapter_Role_Opportunity__c IN: chapterRoleIdSet GROUP BY Chapter_Role_Opportunity__c,Hidden_VolunteerCount_Desc__c,Date__c,Start_Time__c,End_Time__c];
        if(!groupedResults.isEmpty()){
            for(AggregateResult arr : groupedResults){
                volunteercountMap.put((ID)arr.get('nonwish'),(integer)arr.get('aver'));
            }
        }
        if(volunteercountMap.size() > 0){
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: volunteercountMap.Keyset()]){
                if(NonWishEventIdSet .contains(dbVolunteerCount.Non_Wish_Events__c)){
                    if(volunteercountMap.containsKey(dbVolunteerCount.Chapter_Role__c)){
                        if(volunteercountDescSet.contains(dbVolunteerCount.Description__c+''+dbVolunteerCount.Date__c+''+dbVolunteerCount.Start_Time__c+''+dbVolunteerCount.End_Time__c)){
                            //dbVolunteerCount.Volunteer_Needed__c = volunteercountMap.get(dbVolunteerCount.Chapter_Role__c);
                            if(dbVolunteerCount.Volunteer_Needed__c > 0)
                                dbVolunteerCount.Volunteer_Needed__c = dbVolunteerCount.Volunteer_Needed__c - 1;
                            updateVolunteerCountList.add(dbVolunteerCount);
                        }
                    }
                }
            }
            update updateVolunteerCountList;
        }
        else{
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: chapterRoleIdSet ]){
                if(NonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)){
                    if(volunteercountDescSet.contains(dbVolunteerCount.Description__c+''+dbVolunteerCount.Date__c+''+dbVolunteerCount.Start_Time__c+''+dbVolunteerCount.End_Time__c)){
                        dbVolunteerCount.Volunteer_Needed__c = 0;
                        updateVolunteerCountList.add(dbVolunteerCount);
                        volunteercountIdList.add(dbVolunteerCount);
                    }
                }
            } 
            update updateVolunteerCountList;
        }
      }
      
      catch(Exception ex){
            for(Volunteer_Opportunity__c currRec : nonWishListtoupdatecount){
                ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Delete_Hepler',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdatevolunteerNeededCount',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Volunteer_Opportunity__c currRec : nonWishListtoupdatecount){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
    }
    
     /*This updateVolunteerRegisterdCount() is used to update count of the number of volunteer opportunities that are registered for the corresponding NonWish & Event .*/
    public static void updateVolunteerRegisterdCount(List<Volunteer_Opportunity__c> nonWishListtoupdatecount,Set<id> nonWishRegisteredUpdateSet,boolean isdelete){
        RecursiveTriggerHandler.isFirstTime = false;
        Set<Id> chapterRoleIdSet = new Set<Id>();
        Set<Id> nonWishEventIdSet = new Set<Id>();
        Set<String> descriptionSetId = new Set<String>();
        Map<Id,Integer> volunteercountMap = new Map<Id,Integer>();
        List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
        Boolean isRegistered = false;
        Boolean isPending = false;
        try{
        for(Volunteer_Opportunity__c newVolOpp :nonWishListtoupdatecount){
            chapterRoleIdSet .add(newVolOpp.Chapter_Role_Opportunity__c);
            descriptionSetId.add(newVolOpp.Hidden_VolunteerCount_Desc__c+''+newVolOpp.Date__c+''+newVolOpp.Start_Time__c+''+newVolOpp.End_Time__c);
            nonWishEventIdSet.add(newVolOpp.Non_Wish_Event__c);
            if((newVolOpp.Inactive__c == true && newVolOpp.Reason_Inactive__c != Null && newVolOpp.Status__c == 'Approved') || (newVolOpp.Inactive__c == true && newVolOpp.Reason_Inactive__c != Null && newVolOpp.Reason_Inactive__c == 'Not Approved')){
                isdelete = true;
                if(isdelete == true)
                    isRegistered = true;
                System.debug('isRegistered'+isRegistered);
            } 
            if(newVolOpp.Status__c == 'Pending' && isdelete == false) 
                isPending = true;
        }
        List<AggregateResult> groupedResults = [SELECT Chapter_Role_Opportunity__c nonwish, Count(Id)aver,Hidden_VolunteerCount_Desc__c FROM Volunteer_Opportunity__c WHERE Non_Wish_Event__c IN: NonWishEventIdSet  AND Volunteer_Name__c  != Null AND (Reason_Inactive__c = Null OR Reason_Inactive__c != Null) AND Chapter_Role_Opportunity__c IN: chapterRoleIdSet AND id IN : nonWishRegisteredUpdateSet GROUP BY Chapter_Role_Opportunity__c,Hidden_VolunteerCount_Desc__c,Date__c,Start_Time__c,End_Time__c];
        if(!groupedResults.isEmpty()){
            for(AggregateResult arr : groupedResults){
                volunteercountMap.put((ID)arr.get('nonwish'),(integer)arr.get('aver'));
            }
        }
        if(volunteercountMap.size() > 0){
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: volunteercountMap.Keyset()]){
                if(nonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)){
                    if(descriptionSetId.contains(dbVolunteerCount.Description__c+''+dbVolunteerCount.Date__c+''+dbVolunteerCount.Start_Time__c+''+dbVolunteerCount.End_Time__c)){
                        if(volunteercountMap.containsKey(dbVolunteerCount.Chapter_Role__c)){
                            dbVolunteerCount.Registered__c  = volunteercountMap.get(dbVolunteerCount.Chapter_Role__c);
                            System.debug('groupedResults'+dbVolunteerCount.Registered__c);
                            if(isPending == true){
                                dbVolunteerCount.Registered__c = dbVolunteerCount.Registered__c + 1;
                                System.debug('dbVolunteerCount.Registered__c'+dbVolunteerCount.Registered__c);
                            }
                            if(dbVolunteerCount.Registered__c > 0 && isRegistered == true)
                                System.debug('dbVolunteerCount.Registered__c'+dbVolunteerCount.Registered__c);
                            dbVolunteerCount.Registered__c = dbVolunteerCount.Registered__c - 1;
                            System.debug('dbVolunteerCount.Registered__c'+dbVolunteerCount.Registered__c);
                            updateVolunteerCountList.add(dbVolunteerCount);
                        }
                    }
                }
            }
            update updateVolunteerCountList;
        }
        else{
            for(Volunteer_Count__c dbVolunteerCount : [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c From Volunteer_Count__c  WHERE Chapter_Role__c IN: chapterRoleIdSet ]){
                if(nonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)){
                    if(descriptionSetId.contains(dbVolunteerCount.Description__c+''+dbVolunteerCount.Date__c+''+dbVolunteerCount.Start_Time__c+''+dbVolunteerCount.End_Time__c)){
                        if(dbVolunteerCount.Registered__c > 0 && isRegistered == true)
                            System.debug('dbVolunteerCount.Registered__c'+dbVolunteerCount.Registered__c);
                        dbVolunteerCount.Registered__c = 0;
                        System.debug('dbVolunteerCount.Registered__c'+dbVolunteerCount.Registered__c);
                        updateVolunteerCountList.add(dbVolunteerCount);
                        System.debug('updateVolunteerCountList'+updateVolunteerCountList);
                    }
                }
            }
        }
        update updateVolunteerCountList;
    }
    
     catch(Exception ex){
            for(Volunteer_Opportunity__c currRec : nonWishListtoupdatecount){
                ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Delete_Hepler',String.valueof(currRec),String.valueOf(ex.getCause()),'updateVolunteerRegisterdCount',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Volunteer_Opportunity__c currRec : nonWishListtoupdatecount){
                currRec.addError(Label.Debug_log_error_message);
            }
        }
  }
}