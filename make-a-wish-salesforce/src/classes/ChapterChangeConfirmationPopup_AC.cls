/*****************************************************************************************************************
Author      : MST Solutions
Date        : 
Description : It called the when the chapter is changed in lead reocord.
*******************************************************************************************************************/
global class ChapterChangeConfirmationPopup_AC {

	public ChapterChangeConfirmationPopup_AC(ApexPages.StandardController controller) {
	}

	/**
	 * Updates Lead's ChapterName
	 * @param opt
	 * @param leadId
	 * @return
	 */
	@RemoteAction
	global static String updateLeadChapter(String opt, String leadId) {
		List<Id> leadIds = new List<Id>();
		leadIds.add(leadId);
		Map<Id, Lead> leadMap = new Map<Id, Lead>();
		if (opt == 'revert') {
			leadMap = LeadService.revertChapterNameChange(leadIds);
		} else {
			leadMap = LeadService.backupChapterNameChange(leadIds);
		}
		return leadMap.get(leadId).Hidden_Chapter_Change_Confirmation__c;
	}
}