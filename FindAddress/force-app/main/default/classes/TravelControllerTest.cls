/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TravelControllerTest {

    @isTest
    static void testGetTravelDetails() {
        Test.startTest();

        // Mock HTTP response
        HttpResponseMock mock = new HttpResponseMock();
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.setBody('{"routes": [{"legs": [{"distance": {"text": "10 miles", "value": 16093}, "duration": {"text": "15 mins", "value": 900}}]}], "status": "OK"}');
        Test.setMock(HttpCalloutMock.class, mock);

        // Create test data for Custom Metadata
        if (Test.isRunningTest()) {
            TransportationRate_mdt rate = new TransportationRate_mdt();
            rate.DeveloperName = 'Driving';
            rate.Rate_per_Mile__c = 0.5;
            insert rate;
        }

        TravelController.TravelDetails details = TravelController.getTravelDetails('Origin Address', 'Destination Address');

        Test.stopTest();

        System.assertEquals('10 miles', details.distance);
        System.assertEquals('15 mins', details.travelTime);
        System.assertEquals('$5.00', details.cost);
    }

    public class HttpResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"routes": [{"legs": [{"distance": {"text": "10 miles", "value": 16093}, "duration": {"text": "15 mins", "value": 900}}]}], "status": "OK"}');
            res.setStatusCode(200);
            return res;
        }
    }
}