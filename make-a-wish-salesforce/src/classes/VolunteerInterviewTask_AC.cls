/**
 * @description 	VolunteerInterviewTask_AC is used to authorize the support user.
 *
 * @author			MST Solutions
 * @createdDate		2018-03-23
 */
global class VolunteerInterviewTask_AC {
	private static final String RECALL_APPROVAL_ENDPOINT = 'Callout:Support_User_Access/services/apexrest/recalApproval/';
	/**
	 * @description		Recall the approval process by using Salesforce Support User.
	 *
	 * @param			String volOppIsString
	 *
	 * @return			String
	 *
	 * @author			MST Solutions
	 * @createdDate		2018-03-23
	 */
	global static String getApprovalRecal(String volOppIsString) {
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();

		req.setEndpoint(RECALL_APPROVAL_ENDPOINT + volOppIsString);
		req.setMethod('POST');
		req.setBody('');

		try {
			res = http.send(req);
			return null;
		} catch (Exception e) {
			return Label.VolunteerInterviewTask_Error + e.getMessage();
		}
	}
}