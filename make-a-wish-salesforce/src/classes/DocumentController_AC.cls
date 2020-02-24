/***************************************
 * SIW-238 To View the Background Check Report From First Advantage Using Mulesoft
 * **************************************/
public class DocumentController_AC {
	public Id pageId;
	public String objName;
	public String orderId;
	public String packageId;
	public String access_token;
	public String screenUrl;
	public String firstAdvantageLink;
	public String firstAdvantageAuthorization;
	PageReference pageRef;
	//Get the Id from Salesforce Records
	public DocumentController_AC(ApexPages.StandardController controller) {
		pageId = ApexPages.currentPage().getParameters().get('Id');
		objName = pageId.getSObjectType().getDescribe().getName();
		List<sObject> documnetObjs = Database.query('Select Id, Package_Id__c, Order_Id__c from ' + objName + ' where Id =\'' + pageId + '\' Limit 1');
		Sobject documnetObj = documnetObjs.get(0);
		orderId = String.valueOf(documnetObj.get('Order_Id__c'));
		packageId = String.valueOf(documnetObj.get('Package_Id__c'));
	}
	//Redirect to the First Advantage Report Page
	public PageReference redirect() {
		if (orderId != NULL && packageId != NULL) {
			List<AccessTokenList__mdt> accessTokenList = [
					Select API_URL__c, Authorization__c
					from AccessTokenList__mdt
					where MasterLabel = 'First Advantage'
			];
			if (accessTokenList.size() != 0) {
				AccessTokenList__mdt accessToken = accessTokenList.get(0);
				String firstAdvantageLink = accessToken.API_URL__c;
				String firstAdvantageAuthorization = accessToken.Authorization__c;

				String RestLink = firstAdvantageLink + '/orders/' + orderId + '/report/viewAccount/' + packageId + '/viewUser/XCHANGE';
				System.debug(RestLink);
				HttpRequest req = new HttpRequest();
				req.setEndpoint(RestLink);
				req.setMethod('GET');
				String authorizationHeader = firstAdvantageAuthorization;
				req.setHeader('Authorization', authorizationHeader);
				Http ht = new Http();
				HTTPResponse res = ht.send(req);
				System.debug(res.getBody());
				if (res.getStatusCode() == 200) {
					Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
					String access_token = (String) results.get('screening_results_url');
					system.debug('ScreenResult' + access_token);
					screenUrl = access_token;
					pageRef = new PageReference(screenUrl);
					pageRef.setRedirect(true);
				}
			}
		} else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Order Id and Package Id does not have a value'));
		}
		return pageRef;
	}

}