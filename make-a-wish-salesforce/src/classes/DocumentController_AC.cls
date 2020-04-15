/*
 * @description 	To view the Background Check Report from First Advantage using Mulesoft.
 *
 * @author			MST Solutions
 * @createdDate		unknown
 */
public class DocumentController_AC {
	public Id pageId;
	public String objName;
	public String orderId;
	public String packageId;
	public String screenUrl;
	PageReference pageRef;

	public DocumentController_AC(ApexPages.StandardController controller) {
		pageId = ApexPages.currentPage().getParameters().get('Id');
		objName = pageId.getSobjectType().getDescribe().getName();

		List<SObject> documentObjs = Database.query('SELECT Id, Package_Id__c, Order_Id__c FROM ' + objName + ' WHERE Id =\'' + pageId + '\' LIMIT 1');

		SObject documentObj = documentObjs.get(0);
		orderId = String.valueOf(documentObj.get('Order_Id__c'));
		packageId = String.valueOf(documentObj.get('Package_Id__c'));
	}

	/**
	 * @description		Redirect to the First Advantage Report page.
	 *
	 * @author 			MST Solutions
	 * @createdDate		unknown
	 */
	public PageReference redirect() {
		if (orderId != null && packageId != null) {
			List<AccessTokenList__mdt> accessTokenList = [
				SELECT API_URL__c, Authorization__c
				FROM AccessTokenList__mdt
				WHERE MasterLabel = :Constant_AC.ACCESS_TOKEN_LISTS_FIRST_ADVANTAGE
			];

			if (accessTokenList.size() != 0) {
				AccessTokenList__mdt accessToken = accessTokenList.get(0);
				String firstAdvantageLink = accessToken.API_URL__c;
				String firstAdvantageAuthorization = accessToken.Authorization__c;

				String restLink = firstAdvantageLink + '/orders/' + orderId + '/report/viewAccount/' + packageId + '/viewUser/XCHANGE';

				HttpRequest req = new HttpRequest();
				req.setEndpoint(restLink);
				req.setMethod('GET');
				req.setHeader('Authorization', firstAdvantageAuthorization);

				Http http = new Http();
				HttpResponse res = http.send(req);
				if (res.getStatusCode() == 200) {
					Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
					String access_token = (String) results.get('screening_results_url');

					screenUrl = access_token;
					pageRef = new PageReference(screenUrl);
					pageRef.setRedirect(true);
				}
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.DocumentController_OrderAndPackageIdNoValue));
		}

		return pageRef;
	}
}