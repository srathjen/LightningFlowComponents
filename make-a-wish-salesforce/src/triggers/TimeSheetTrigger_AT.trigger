/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 5/23/2016
Description : This TimeSheetTrigger_AT is used to calculate the total hours spent by volunteers to close the wish and 
              Non-wish & Event.
*******************************************************************************************************************/
Trigger TimeSheetTrigger_AT on Time_sheet__c (before insert,before update, After insert,After update,After delete) {
    List<Time_sheet__c> timeSheetList = new List<Time_sheet__c>();
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Time_sheet__c  newTimeSheetEntry : Trigger.new){
            if(newTimeSheetEntry.Hours_spent__c > 0){
                timeSheetList.add(newTimeSheetEntry);
            }
        }
        if(timeSheetList.size () > 0){
            TimeSheetTriggerHandler timesheetIns = new TimeSheetTriggerHandler();
            timesheetIns.SplitBefore(timeSheetList);
        }
    }
    if(Trigger.isBefore && Trigger.isupdate){
        for(Time_sheet__c  newTimeSheetEntry : Trigger.new){
            if((newTimeSheetEntry.Hours_spent__c) >0 && (newTimeSheetEntry.Hours_spent__c != trigger.oldmap.get(newTimeSheetEntry.id).Hours_spent__c)){
                timeSheetList.add(newTimeSheetEntry);
            }
        }
        if(timeSheetList.size () > 0){
            TimeSheetTriggerHandler timesheetIns = new TimeSheetTriggerHandler();
            timesheetIns.SplitBefore(timeSheetList);
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        
        for(Time_sheet__c  newTimeSheetEntry : Trigger.new){
            if(newTimeSheetEntry.Hours_spent__c > 0){
                timeSheetList.add(newTimeSheetEntry);
            }
        }
        if(timeSheetList.size () > 0){
            TimeSheetTriggerHandler timesheetIns = new TimeSheetTriggerHandler();
            timesheetIns.calculateHourstoWish(timeSheetList);
            timesheetIns.calculateHourstoNonWish(timeSheetList);
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Time_sheet__c  newTimeSheetEntry : Trigger.new){
            if(newTimeSheetEntry.Hours_Hidden__c!= trigger.oldmap.get(newTimeSheetEntry.Id).Hours_Hidden__c){
                timeSheetList.add(newTimeSheetEntry);
                
            }
        }
        if(timeSheetList.size () > 0){
            TimeSheetTriggerHandler timesheetIns = new TimeSheetTriggerHandler();
            timesheetIns.calculateHourstoWish(timeSheetList);
            timesheetIns.calculateHourstoNonWish(timeSheetList);
        }
    }
    if(Trigger.isAfter && Trigger.isDelete){
        for(Time_sheet__c  newTimeSheetEntry : Trigger.old){
            
            timeSheetList.add(newTimeSheetEntry);
        }
        if(timeSheetList.size () > 0){
            TimeSheetTriggerHandler timesheetIns = new TimeSheetTriggerHandler();
            timesheetIns.calculateHourstoWish(timeSheetList);
            timesheetIns.calculateHourstoNonWish(timeSheetList);
        }
    }
}