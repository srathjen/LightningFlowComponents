/******************************************************************************
Author : MAWA
Created Date: 4/25/2019
Description:  This class is used to set the Age_Requirement_Met__c field to 
              True on lead when a wish child turns 2.5 years old.
Modification: 05/20/2019 - Samer - SIW-252
              Modified code to use Apex Date methods when calculating age, and
              added code for End-of-Month date calculation exceptions 
*******************************************************************************/
global class batch_leadChildAge implements Database.Batchable<Sobject> {
    
    global integer recordsProcessed = 1;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return database.getQueryLocator([SELECT Id,DOB__c, Child_Age__c, Status, Age_Requirement_Met__c 
                                         FROM Lead WHERE Status = 'Inquiry' AND Age_Requirement_Met__c = False AND Child_Age__c = 'Under 2.5']);        
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        
        List<lead> updateLeads = new List<lead>();
        
        for (Lead leads : scope) {
        // SIW-252 Start 
            /*Integer birthMonth = leads.DOB__c.month();  
            Integer birthDay = leads.DOB__c.day();
            Integer birthYear = leads.DOB__c.Year();
            Integer currentMonth =  System.Today().Month();
            Integer sixMonthbefore = System.Today().Month()+6;
            Integer threeYearsBefore = System.Today().Year()-3;
            Integer todayDate = System.Today().Day();
            
            if(birthMonth == sixMonthbefore && birthDay == System.today().Day() && birthYear == threeYearsBefore){ 
                 leads.Age_Requirement_Met__c = true;
             }*/
            
            Date runDate = Date.today();
                     
            //*******************************************************************************************************
            //                                F O R   T E S T I N G   O N L Y
            //           WHEN WE GO TO PRODUCTION, COMMENT OUT LINE 44 (runDate ASSIGNMENT STATEMENT) 
            // OVERRIDE SYSTEM DATE WITH A SIMULATED RUN DATE
            //runDate = Date.parse('06/30/2019');                 // COMMENT OUT WHEN GOING TO PRODUCTION
            //*******************************************************************************************************
            
            // Calculate DOB of children who have turned 2.5 years old today
            // if today is the last day of the month, and If daysInCurrentMonth is less than daysInSixthMonth, 
            // we use date range to check if the DOB falls between them  
            Integer daysInCurrentMonth = Date.daysInMonth(runDate.Year(), runDate.Month());                         // Get last day of the current month
            Date twoAndHalfToday = runDate.addYears(-2).addMonths(-6);                                              // Subtract 2 years and 6 months from current date
            Integer daysInSixthMonth = Date.daysInMonth(twoAndHalfToday.Year(), twoAndHalfToday.month());           // Get last day of DOB month

            if((runDate.Day() == daysInCurrentMonth) && (daysInCurrentMonth < daysInSixthMonth)) {                  // Is today the last day of the current month
                Date fromDate = twoAndHalfToday;
                date toDate   = fromDate.addDays(daysInSixthMonth - daysInCurrentMonth);
                if((leads.DOB__c >= fromDate) && (leads.DOB__c <= toDate)){
                    leads.Age_Requirement_Met__c = true;
                    updateLeads.add(leads);
                }
            } else if(twoAndHalfToday.isSameDay(leads.DOB__c)) {                                                    // Compare Lead's DOB to twoAndHalfToday
                leads.Age_Requirement_Met__c = true; 
                updateLeads.add(leads);             
            } // SIW-252 End

        }
        
        if(updateLeads.size()>0){
            update updateLeads;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}