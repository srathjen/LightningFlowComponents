@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"order_id": "WPS-6991282","screening_results_url": "https://enterprisetest.fadv.com/pub/l/link?key=9E74AC84-9FE6-D0B0-5F6C-8E6AC1AEF04B"}');
        res.setStatusCode(200);
        System.assertEquals('GET', req.getMethod());
        return res;
    }
    
}