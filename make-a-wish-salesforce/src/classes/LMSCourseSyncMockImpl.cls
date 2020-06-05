/**
 * @description This class will create Mock callout and used in test classes
 *
 * @author MST
 */
@IsTest
global class LMSCourseSyncMockImpl implements HttpCalloutMock {
    HttpResponse[] responses = new HttpResponse[0];
    public void addResponse(HttpResponse response) {
        responses.add(response);
    }
    global HttpResponse respond(HttpRequest req) {
        return responses.remove(0);
    }
}