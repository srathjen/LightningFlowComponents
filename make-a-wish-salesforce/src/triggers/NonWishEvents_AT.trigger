/****************************************************************************************
Created by : vennila paramasivam
Author : MST Solutions
Date : 6/29/2016
Description : If user tried to create events with same chapter, date and priority, It won't allow 
users to create an event.
*****************************************************************************************/

trigger NonWishEvents_AT on Non_Wish_Events__c (before insert,before update) {   
    
    if(Trigger.isBefore && Trigger.isInsert)
        NonwishEvent_OnBeforeInsertHandler.onBeforeInsert(Trigger.new);
    if(Trigger.isBefore && Trigger.isUpdate)
        NonwishEvent_OnBeforeUpdateHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
            
}