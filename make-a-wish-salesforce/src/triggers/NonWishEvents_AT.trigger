/****************************************************************************************
Created by : vennila paramasivam
Author : MST Solutions
Date : 6/29/2016
Description : If user tried to create events with same chapter, date and priority, It won't allow 
users to create an event.
*****************************************************************************************/

trigger NonWishEvents_AT on Non_Wish_Events__c (before insert, before update, before delete, 
                                                   after insert, after update, after delete, after undelete) {   
    trac_TriggerHandlerBase.triggerHandler(new NonwishEventDomain());            
}