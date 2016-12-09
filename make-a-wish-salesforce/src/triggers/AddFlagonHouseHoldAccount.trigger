trigger AddFlagonHouseHoldAccount on Account (before insert) {

    Constant_AC  constant = new Constant_AC();
    public Id houseHoldRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.HouseholdRT).getRecordTypeId();
    Map<String,Turnon_Household_Trigger__c> triggerStatus = Turnon_Household_Trigger__c.getAll();
    for(Account currAccount : Trigger.new)
    {
       if(currAccount.RecordTypeId == houseHoldRT)
       {
         if(triggerStatus.containsKey('HouseHold Account'))
         {
          if(triggerStatus.get('HouseHold Account').Activate_AddFlagonHouseHoldAccount_Tgr__c == True)
              currAccount.Migrated_Record__c = true;
         }
       } 
    }

}