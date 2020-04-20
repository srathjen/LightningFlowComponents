/**
* @description Timesheet Service, centralizes Timesheet business rules
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/10/2020
*/

public class TimesheetService {

    /**
    * Splits time into hours and minutes
    * @param timesheetList
    */
    public static void splitHoursMinutes(List<Time_sheet__c> timesheetList) {
        Integer hours;
        Integer minutes;
        Integer hoursConverted;
        List<String> timeSplitString;
        for(Time_sheet__c sheet : timesheetList) {
            if(sheet.Hours_spent__c > 0) {
                timeSplitString = String.valueOf(sheet.Hours_spent__c).split('\\.');
                hours = Integer.valueOf(timeSplitString[0]);
                minutes =  Integer.valueOf(timeSplitString[1]);
                if(minutes > 99) {
                    sheet.Hours_spent__c.addError('Minutes should be 99 or less than 99');
                }
                if(hours != null) {
                    hoursConverted = hours * 60;
                }
                sheet.Hours_Hidden__c = hoursConverted + minutes;
            }
        }
    }

    /**
    * Checks hours spent has changed to split time into hours and minutes
    * @param newTimesheetsList
    * @param oldTimesheetsMap
    */
    public static void splitHoursMinutes(List<Time_sheet__c> newTimesheetsList, Map<Id, Time_sheet__c> oldTimesheetsMap) {
        List<Time_sheet__c> timesheetHourChange = new List<Time_sheet__c>();
        for(Time_sheet__c  newTimesheet : newTimesheetsList) {
            if(newTimesheet.Hours_spent__c != oldTimesheetsMap.get(newTimesheet.Id).Hours_spent__c) {
                timesheetHourChange.add(newTimesheet);
            }
        }
        if(!timesheetHourChange.isEmpty()) {
            splitHoursMinutes(timesheetHourChange);
        }
    }

    /**
    * Share the volunteer opportunity record on timesheet with the current volunteer user
    * @param timesheetList
    */
    public static void shareVolunteerOpportunity(List<Time_sheet__c> timesheetList) {
        Set<Id> newVolunteerOppIds = new Set<Id>();
        User currentUser = Utils.currentUser;
        List<Volunteer_Opportunity__Share> volOpportunitySharingList = new List<Volunteer_Opportunity__Share>();
        for(Time_sheet__c sheet : timesheetList) {
            if(sheet.Volunteer_Opportunity__c != null) {
                newVolunteerOppIds.add(sheet.Volunteer_Opportunity__c);
            }
        }
        if(newVolunteerOppIds.isEmpty() || currentUser.ContactId == null) {
            return;
        }
        Map<Id, Volunteer_Opportunity__c> volunteerOppMap = new Map<Id, Volunteer_Opportunity__c>([
            SELECT Id 
            FROM Volunteer_Opportunity__c
            WHERE Volunteer_Name__c = :currentUser.ContactId
            AND Id IN :newVolunteerOppIds]);
        if(!volunteerOppMap.isEmpty()) {
            Map<Id, Volunteer_Opportunity__Share> volOppShareMap = new Map<Id, Volunteer_Opportunity__Share>([
                SELECT Id, ParentId 
                FROM Volunteer_Opportunity__Share
                WHERE ParentId IN :volunteerOppMap.keySet()]);
            for(Id volunteerOppId : volunteerOppMap.keySet()) {
                if(!volOppShareMap.keySet().contains(volunteerOppId)) {
                    Volunteer_Opportunity__Share newVolOppShareRec = new Volunteer_Opportunity__Share();
                    newVolOppShareRec.ParentId = volunteerOppId;
                    newVolOppShareRec.AccessLevel = 'Edit';
                    newVolOppShareRec.UserOrGroupId = currentUser.Id;
                    newVolOppShareRec.rowCause = Schema.Volunteer_Opportunity__Share.RowCause.Grant_Edit_Access_to_assigned_Volunteer__c;
                    volOpportunitySharingList.add(newVolOppShareRec);
                }
            }
            insert volOpportunitySharingList;
        }
    }

    /**
    * Calculates the total hours spent by the volunteer to close the corresponding wish
    * @param timesheetList
    */
    public static void calculateHoursOfWish(List<Time_sheet__c> timesheetList) {
        Set<Id> volOpportunityIdSet = new Set<Id>();
        Set<Id> wishIdSet = new Set<Id>();
        Map<Id, Decimal> volOpportunityMap = new Map<Id, Decimal>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Decimal hrs = 0;
        Decimal min = 0;
        String totalHours;
        for(Time_sheet__c sheet : timesheetList) {
            if(sheet.Volunteer_Opportunity__c != null) {
                volOpportunityIdSet.add(sheet.Volunteer_Opportunity__c);
            }
        }
        if(volOpportunityIdSet.isEmpty()) {
            return;
        }
        for(Volunteer_Opportunity__c volOpp : [
            SELECT Id, Wish__c 
            FROM Volunteer_Opportunity__c 
            WHERE Id IN :volOpportunityIdSet 
            AND Wish__c != null]) {
                wishIdSet.add(volOpp.Wish__c);
            }
        if(wishIdSet.isEmpty()) {
            return;
        }
        for(AggregateResult agResult : [
            SELECT Volunteer_Opportunity__r.Wish__c wish, Sum(Hours_Hidden__c)aver
            FROM Time_sheet__c
            WHERE Volunteer_Opportunity__r.Wish__c IN :wishIdSet 
            AND Volunteer_Opportunity__r.Wish__c != null
            GROUP BY Volunteer_Opportunity__r.Wish__c]) {
                volOpportunityMap.put((Id)agResult.get('wish'), (decimal)agResult.get('aver'));
            }
        if(!volOpportunityMap.isEmpty()) {
            for(Volunteer_Opportunity__c volOpp : [
                SELECT Id, Wish__c, Wish__r.Total_Hour_Spent_Hidden__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :volOpportunityMap.keySet() 
                AND Wish__c != null]) {
                    Case updateCase = new Case();
                    if(caseMap.containsKey(volOpp.Wish__c)) {
                        updateCase.Id = caseMap.get(volOpp.Wish__c).Id;
                    } else {
                        updateCase.Id = volOpp.Wish__c;
                    }
                    if((updateCase.Total_Hour_Spent_Hidden__c == null || updateCase.Total_Hour_Spent_Hidden__c == 0.00) 
                       && volOpp.Wish__r.Total_Hour_Spent_Hidden__c != null && volOpp.Wish__r.Total_Hour_Spent_Hidden__c > 0) {
                           hrs = math.floor(volOpp.Wish__r.Total_Hour_Spent_Hidden__c / 60);
                           min = math.mod(Integer.valueOf(volOpp.Wish__r.Total_Hour_Spent_Hidden__c), 60);
                           totalHours = hrs + '.' + min;
                           updateCase.Total_Hour_Spent_Hidden__c = Decimal.valueOf(totalHours);
                       }
                    if(updateCase.Total_Hour_Spent_Hidden__c == null || updateCase.Total_Hour_Spent_Hidden__c == 0.00) {
                        hrs = math.floor(volOpportunityMap.get(volOpp.Wish__c) / 60);
                        min = math.mod(Integer.valueOf(volOpportunityMap.get(volOpp.Wish__c)), 60);
                        totalHours = hrs + '.' + min;
                        updateCase.Total_Hour_Spent_Hidden__c = Decimal.valueOf(totalHours);
                    } else {
                        hrs = math.floor(volOpportunityMap.get(volOpp.Wish__c) / 60);
                        min = math.mod(Integer.ValueOf(volOpportunityMap.get(volOpp.Wish__c)), 60);
                        totalHours = hrs + '.' + min;
                        updateCase.Total_Hour_Spent_Hidden__c = Decimal.valueOf(totalHours);
                    }
                    if(updateCase.Total_Hour_Spent_Hidden__c > 0) {
                        Decimal toRound = updateCase.Total_Hour_Spent_Hidden__c;
                        Decimal rounded = toRound.setScale(2);
                        List<String> timeList = String.valueOf(rounded).split('\\.');
                        Integer hours = Integer.valueOf(timeList[0]);
                        Integer minutes = Integer.valueOf(timeList[1]);
                        if(hours > 0) {
                            if(minutes > 59) {
                                Integer divideMinutes = minutes / 60;
                                Integer roundMinutes = math.mod(minutes, 60);
                                if(divideMinutes != null) {
                                    hours = hours + divideMinutes;
                                    if(roundMinutes < 10) {
                                        updateCase.Total_Hour_Spent__c = hours + ':0' + roundMinutes ;
                                        caseMap.put(updateCase.Id, updateCase);
                                    } else {
                                        updateCase.Total_Hour_Spent__c = hours + ':' + roundMinutes ;
                                        caseMap.put(updateCase.Id, updateCase);
                                    }
                                }
                            } else {
                                updateCase.Total_Hour_Spent__c = hours + ':' + minutes;
                                caseMap.put(updateCase.Id, updateCase);
                            }
                        } else {
                            updateCase.Total_Hour_Spent__c = hours + ':' + minutes;
                            caseMap.put(updateCase.Id, updateCase);
                        }
                    }
                }
        } else {
            for(Case caseUpdate : [
                SELECT Id, Total_Hour_Spent_Hidden__c
                FROM Case
                WHERE Id IN :wishIdSet]) {
                    caseUpdate.Total_Hour_Spent__c = String.valueof(0);
                    caseMap.put(caseUpdate.Id, caseUpdate);
                }
        }
        update caseMap.values();
    }

    /**
    * Calculates the total hours spent by the volunteer to close the corresponding Nonwish & Event
    * @param timesheetList
    */
    public static void calculateHoursOfNonwish(List<Time_sheet__c> timesheetList) {
        Set<Id> volOpportunityIdSet = new Set<Id>();
        Map<Id, Decimal> volOpportunityMap = new Map<Id, Decimal>();
        Map<Id, Non_Wish_Events__c> nonwishMap = new Map<Id, Non_Wish_Events__c>();
        Set<Id> nonwishIdSet = new Set<Id>();
        Decimal hrs = 0;
        Decimal min = 0;
        String totalHours;
        for(Time_sheet__c sheet : timesheetList) {
            if(sheet.Volunteer_Opportunity__c != null) {
                volOpportunityIdSet.add(sheet.Volunteer_Opportunity__c);
            }
        }
        if(!volOpportunityIdSet.isEmpty()) {
            for(Volunteer_Opportunity__c volOpp : [
                SELECT Id, Non_Wish_Event__c
                FROM Volunteer_Opportunity__c
                WHERE Id IN :volOpportunityIdSet AND Non_Wish_Event__c != null]) {
                    nonwishIdSet.add(volOpp.Non_Wish_Event__c);
                }
            if(nonwishIdSet.isEmpty()) {
                return;
            }
            for(AggregateResult aggResult : [
                SELECT Volunteer_Opportunity__r.Non_Wish_Event__c nonwish, Sum(Hours_Hidden__c)aver
                FROM Time_sheet__c
                WHERE Volunteer_Opportunity__r.Non_Wish_Event__c IN :nonwishIdSet 
                AND Volunteer_Opportunity__r.Non_Wish_Event__c != null
                GROUP BY Volunteer_Opportunity__r.Non_Wish_Event__c]) {
                    volOpportunityMap.put((Id)aggResult.get('nonwish'), (decimal)aggResult.get('aver'));
                }
            if(volOpportunityMap.isEmpty()) {
                return;
            }
            for(Volunteer_Opportunity__c volOpp : [
                SELECT Id, Non_Wish_Event__c, Non_Wish_Event__r.Total_Hour_Spent_Hidden__c
                FROM Volunteer_Opportunity__c
                WHERE Non_Wish_Event__c IN :volOpportunityMap.keySet() 
                AND Non_Wish_Event__c != null]) {
                    Non_Wish_Events__c nonwishUpdate = new Non_Wish_Events__c();
                    if(nonwishMap.containsKey(volOpp.Non_Wish_Event__c)) {
                        nonwishUpdate.Id = nonwishMap.get(volOpp.Non_Wish_Event__c).Id;
                    } else {
                        nonwishUpdate.Id = volOpp.Non_Wish_Event__c;
                    }
                    if((nonwishUpdate.Total_Hour_Spent_Hidden__c == null || nonwishUpdate.Total_Hour_Spent_Hidden__c == 0.00) 
                       && volOpp.Non_Wish_Event__r.Total_Hour_Spent_Hidden__c != null 
                       && volOpp.Non_Wish_Event__r.Total_Hour_Spent_Hidden__c > 0) {
                           hrs = math.floor(volOpp.Non_Wish_Event__r.Total_Hour_Spent_Hidden__c / 60);
                           min = math.mod(Integer.valueOf(volOpp.Non_Wish_Event__r.Total_Hour_Spent_Hidden__c), 60);
                           totalHours = hrs + '.' + min;
                           nonwishUpdate.Total_Hour_Spent_Hidden__c = Decimal.valueOf(totalHours);
                       }
                    if(nonwishUpdate.Total_Hour_Spent_Hidden__c == null || nonwishUpdate.Total_Hour_Spent_Hidden__c == 0.00) {
                        hrs = math.floor(volOpportunityMap.get(volOpp.Non_Wish_Event__c) / 60);
                        min = math.mod(Integer.valueOf(volOpportunityMap.get(volOpp.Non_Wish_Event__c)), 60);
                        totalHours = hrs + '.' + min;
                        nonwishUpdate.Total_Hour_Spent_Hidden__c = Decimal.valueOf(totalHours);
                    } else {
                        hrs = math.floor(volOpportunityMap.get(volOpp.Non_Wish_Event__c) / 60);
                        min = math.mod(Integer.valueOf(volOpportunityMap.get(volOpp.Non_Wish_Event__c)), 60);
                        totalHours = hrs + '.' + min;
                        nonwishUpdate.Total_Hour_Spent_Hidden__c = Decimal.valueOf(totalHours);
                    }
                    if(nonwishUpdate.Total_Hour_Spent_Hidden__c > 0) {
                        Decimal toRound = nonwishUpdate.Total_Hour_Spent_Hidden__c ;
                        Decimal rounded = toRound.setScale(2);
                        List<String> timeList = String.valueOf(rounded).split('\\.');
                        Integer hours = Integer.valueOf(timeList[0]);
                        Integer minutes = Integer.valueOf(timeList[1]);
                        if(hours > 0) {
                            if(minutes > 59) {
                                Integer divideMinutes = minutes / 60;
                                Integer roundMinutes = math.mod(minutes, 60);
                                if(divideMinutes != null) {
                                    hours = hours + divideMinutes;
                                    if(roundMinutes < 10) {
                                        nonwishUpdate.Total_Hour_Spent__c = hours + ':0' + roundMinutes ;
                                        nonwishMap.put(nonwishUpdate.id, nonwishUpdate);
                                    } else {
                                        nonwishUpdate.Total_Hour_Spent__c = hours + ':' + roundMinutes ;
                                        nonwishMap.put(nonwishUpdate.id, nonwishUpdate);
                                    }
                                }
                            } else {
                                nonwishUpdate.Total_Hour_Spent__c = hours + ':' + minutes;
                                nonwishMap.put(nonwishUpdate.Id, nonwishUpdate);
                            }
                        } else {
                            nonwishUpdate.Total_Hour_Spent__c = hours + ':' + minutes;
                            nonwishMap.put(nonwishUpdate.Id, nonwishUpdate);
                        }
                    }
                    
                }
        } else {
            for(Non_Wish_Events__c nonwishUpdate : [
                SELECT Id, Total_Hour_Spent__c 
                FROM Non_Wish_Events__c
                WHERE Id IN :nonwishIdSet
            ]) {
                nonwishUpdate.Total_Hour_Spent__c = String.valueOf(0);
                nonwishMap.put(nonwishUpdate.Id, nonwishUpdate);
            }
        }
        update nonwishMap.values();
    }
    
    /**
    * Checks hours hidden has been changed to update total hours volunteer has spent to close wish/non-wish event
    * @param newTimesheetsList
    * @param oldTimesheetsMap
    */
    public static void calculateHoursOfWish(List<Time_sheet__c> newTimesheetsList, Map<Id, Time_sheet__c> oldTimesheetsMap) {
        List<Time_sheet__c> timesheetHoursList = new List<Time_sheet__c>();
        for(Time_sheet__c  newTimesheet : newTimesheetsList) {
            if(newTimesheet.Hours_Hidden__c != oldTimesheetsMap.get(newTimesheet.Id).Hours_Hidden__c) {
                timesheetHoursList.add(newTimesheet);
            }
        }
        if(!timesheetHoursList.isEmpty()) {
            calculateHoursOfWish(timesheetHoursList);
            calculateHoursOfNonwish(timesheetHoursList);
        }
    }

    /**
    * Updates volunteer date of last engagement 
    * @param timesheetList
    */
    public static void findRecentTimesheetDate(List<Time_sheet__c> timesheetList) {
        Set<Id> timesheetIds = new Set<Id>();
        Map<Id, Contact> volunteerInfoUpdateMap = new Map<Id, Contact>();
        for(Time_sheet__c sheet : timesheetList) {
            if(sheet.Date__c != null) {
                timesheetIds.add(sheet.Id);
            }
        }
        if(timesheetIds.isEmpty()) {
            return;
        }
        for(Time_sheet__c sheet : [
                SELECT Id, Date__c, Volunteer_Opportunity__r.Volunteer_Name__c,
                    Volunteer_Opportunity__r.Volunteer_Name__r.Date_of_last_engagement__c
                FROM Time_sheet__c
                WHERE Id IN :timeSheetIds
        ]) {
            if(sheet.Volunteer_Opportunity__r.Volunteer_Name__r.Date_of_last_engagement__c == null 
                || sheet.Volunteer_Opportunity__r.Volunteer_Name__r.Date_of_last_engagement__c < sheet.Date__c) {
                    Contact updateContact = new Contact();
                    updateContact.Id = sheet.Volunteer_Opportunity__r.Volunteer_Name__c;
                    updateContact.Date_of_last_engagement__c = sheet.Date__c;
                    volunteerInfoUpdateMap.put(updateContact.Id, updateContact);
                }
        }
        if(!volunteerInfoUpdateMap.isEmpty()) {
            update volunteerInfoUpdateMap.values();
        }
    }
    
    /**
    * Checks date has been changed to update volunteer date of last engagement 
    * @param newTimesheetsList
    * @param oldTimesheetsMap
    */
    public static void findRecentTimesheetDate(List<Time_sheet__c> newTimesheetsList, Map<Id, Time_sheet__c> oldTimesheetsMap) {
        List<Time_sheet__c> timesheetDateList = new List<Time_sheet__c>();
        for(Time_sheet__c  newTimesheet : newTimesheetsList) {
            if(newTimesheet.Date__c != oldTimesheetsMap.get(newTimesheet.Id).Date__c) {
                timesheetDateList.add(newTimesheet);
            }
        }
        if(!timesheetDateList.isEmpty()) {
            findRecentTimesheetDate(timesheetDateList);
        }
    }
}