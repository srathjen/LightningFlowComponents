@IsTest
private class VolunteerInterviewTask_AC_Test {

	@IsTest
	public static void shouldGetApprovalRecal() {
		Test.setMock(HttpCalloutMock.class, new RecallApprovalMock(200,
				'ok', 0, ''));

		VolunteerInterviewTask_AC.getApprovalRecal('VolOpp123');
	}

	private class RecallApprovalMock implements HttpCalloutMock {
		public Integer firstResponseCode;
		public String firstResponseBody;
		public Integer secondResponseCode;
		public String secondResponseBody;

		RecallApprovalMock(Integer firstResponseCode, String firstResponseBody, Integer secondResponseCode, String secondResponseBody) {
			this.firstResponseCode = firstResponseCode;
			this.firstResponseBody = firstResponseBody;
			this.secondResponseCode = secondResponseCode;
			this.secondResponseBody = secondResponseBody;
		}

		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			if (req.getEndpoint().contains('recalApproval')) {
				res.setBody(this.secondResponseBody);
				res.setStatusCode(this.secondResponseCode);
			} else {
				res.setBody(this.firstResponseBody);
				res.setStatusCode(this.firstResponseCode);
			}
			return res;
		}
	}
}