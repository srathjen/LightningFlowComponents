global class batch_changeVolunOppSatus implements Database.Batchable<SObject>, Schedulable {

	private final static String VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED;
	private final static String VOLUNTEER_RT_LABEL_NON_WISH_EVENT = Constant_AC.VOLUNTEER_RT_LABEL_NON_WISH_EVENT;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT Event_Date__c, Id, Status__c
				FROM Volunteer_Opportunity__c
				WHERE Event_Date__c < :Date.today()
				AND RecordType.Name = :VOLUNTEER_RT_LABEL_NON_WISH_EVENT
		]);
	}

	global void execute(Database.BatchableContext bc, List<Volunteer_Opportunity__c> nonWishEventList) {
		if (nonWishEventList.size () > 0 && nonWishEventList != null) {
			Map<Id, Volunteer_Opportunity__c> volunteerOpportunityMap = new Map<Id, Volunteer_Opportunity__c>();
			Volunteer_Opportunity__c volunteerOpportunity;
			for (Volunteer_Opportunity__c currRec : nonWishEventList) {
				volunteerOpportunity = new Volunteer_Opportunity__c ();
				volunteerOpportunity.Id = currRec.Id;
				volunteerOpportunity.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED;
				volunteerOpportunityMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
			update volunteerOpportunityMap.values();
		}
	}

	global void finish(Database.BatchableContext BC) {
	}

	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new batch_changeVolunOppSatus(), 25);
	}
}