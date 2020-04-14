/**
* Updates volunteer date of last engagement to most recent non-wish event
*/
global class batch_UpdateVolunteerLastEngage implements Database.Batchable<AggregateResult>, Schedulable {
    
    private final static Id NON_WISH_EVENT_RT_ID = Constant_AC.NON_WISH_EVENT_RT_ID;
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        return [
            SELECT Max(Event_date__c)eventDate, Volunteer_Name__c
            FROM Volunteer_Opportunity__c
            WHERE Event_date__c < :Date.today() AND RecordTypeId = :NON_WISH_EVENT_RT_ID
            GROUP BY Volunteer_Name__c
        ];
    }
    
    global void execute(Database.BatchableContext bc, List<AggregateResult> nonWishEventList) {
        List<Contact> updateContactList = new List<Contact>();
        Map<String, Date> eventDateMap = new Map<String, Date>();
        for(AggregateResult getRec : nonWishEventList) {
            String currVol = String.valueOf(getRec.get('Volunteer_Name__c'));
            Date eventDate = Date.valueOf(getRec.get('eventDate'));
            eventDateMap.put(currVol, eventDate);
        }
        
        for(Contact currCon : [
            SELECT Id, Date_of_last_engagement__c
            FROM Contact
            WHERE Id IN :eventDateMap.keySet()
        ]) {
            if(currCon.Date_of_last_engagement__c == null || eventDateMap.get(currCon.Id) > currCon.Date_of_last_engagement__c) {
                Contact currContact = new Contact();
                currContact.Id = currcon.Id;
                currContact.Date_of_last_engagement__c = eventDateMap.get(currCon.Id);
                updateContactList.add(currContact);
            }
        }
        update updateContactList;
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new batch_UpdateVolunteerLastEngage(), 25);
    }
}