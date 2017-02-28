/*****************************************************************************
Created by    : Vennila Paramasivam
Author        : MST
CreatedDate   : 6/17/2016
Description   : This trigger used to validate the Start and End Time. Orientation/Training Start Time 
should not be greater than end time. Since Start & End Time field have been picklist(String) values, we have 
assigned some dummy values for start and end time checking.
*******************************************************************************/

trigger ClassOffering_AT on Class_Offering__c(before insert,before update) {
    
    Map<String, integer> timeConversion = new Map<String, integer>();
    
    Schema.DescribeFieldResult fieldResult = Class_Offering__c.Start_Time__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    
    // Assigning some dummy values for each time.
    integer i = 0;    
    for( Schema.PicklistEntry f : ple)
    {
        i=i+1;
        timeConversion.put(f.getValue(),i);
        
    }   
    
    
    for(Class_Offering__c currRec : Trigger.new)
    {
        Decimal startTime;
        Decimal endTime;
        
        if(currRec.Start_Time__c == Null && currRec.End_Time__c != Null)
            currRec.addError('Please Enter Start Time');
        if(timeConversion.containskey(currRec.Start_Time__c))
        {
            startTime = timeConversion.get(currRec.Start_Time__c);
        }
        if(timeConversion.containskey(currRec.end_Time__c))
        {
            endTime = timeConversion.get(currRec.end_Time__c);
        }
        // comparing start and end time. 
        if((startTime >= endTime) && (StartTime != i))
        {
            currRec.addError('End Time should be greater than start time');
        }
        
        // Start time should not be end of the day.  
        if(startTime == i)
            currRec.addError('Please enter valid Start and End Time');
    }
    
}