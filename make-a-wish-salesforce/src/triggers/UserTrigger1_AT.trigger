trigger UserTrigger1_AT on User (before update) {
   Set<Id> UserIdSet=new Set<Id>();
     if(Trigger.isbefore && Trigger.isUpdate){
        Set<Id> inActiveCommunityUserIdSet = new Set<Id>();
      
         for(User newUser : Trigger.new){
             if(newUser.IsActive == false && trigger.oldMap.get(newUser.Id).IsActive == TRue ){//&& (newUser.Profile.name == 'Prospective Volunteer' || newUser.profile.name=='Active Volunteer') ){
                // inActiveCommunityUserIdSet.add(newUser.Contactid);
                newUser.Inactive_Date__c=system.Today();
             }
            
         }
        
         }
}