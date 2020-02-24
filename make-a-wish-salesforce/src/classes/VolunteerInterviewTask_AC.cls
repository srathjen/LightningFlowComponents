/*****************************************************************************
Author : MST Solutions
Date : 03/25/2016
Description :This VolunteerInterviewTask_AC is used to authorize the support user and verifying the records
Modification Log: 
23/03/2018 - Kanagaraj
******************************************************************************/
//This class is run the logic by using Salesforce Support user
global class VolunteerInterviewTask_AC {

	/**
	 * WLP-434
	 * Deprecating Task from Volunteer Interview and Volunteer Welcome Page
	 */
	//Used to verify the class offering records
//	global static string getClassOfferingRecList(String contactId) {
//		HttpRequest req = new HttpRequest();
//		HttpResponse res = new HttpResponse();
//		Http http = new Http();
//		req.setEndpoint('Callout:Support_User_Access/services/apexrest/orientation/' + contactId);
//		req.setMethod('GET');
//		try {
//			res = http.send(req);
//			return res.getBody();
//		} catch (Exception e) {
//			return 'Error while retriving records :' + e.getMessage();
//		}
//	}

	/**
	 * WLP-434
	 * Unused method
	 */
	//Used to verify whethere there is any other volunteer review task is created for the day
//	global static string getUploadReviewTask(String contactId) {
//
//		HttpRequest req = new HttpRequest();
//		HttpResponse res = new HttpResponse();
//		Http http = new Http();
//		req.setEndpoint('Callout:Support_User_Access/services/apexrest/uploadTask/' + contactId);
//		req.setMethod('GET');
//
//		try {
//			res = http.send(req);
//			return res.getBody();
//		} catch (Exception e) {
//			return 'Error while retriving records :' + e.getMessage();
//		}
//
//	}

	//This class is used to recall the approval process by using Salesforce Support User.
	global static String getApprovalRecal(String volOppIsString) {
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setEndpoint('Callout:Support_User_Access/services/apexrest/recalApproval/' + volOppIsString);
		req.setMethod('POST');
		req.setBody('');
		try {
			res = http.send(req);
			return NULL;
		} catch (Exception e) {
			System.debug('Callout Error:' + e.getMessage());
			return 'Error while retriving records :' + e.getMessage();
		}

	}
}