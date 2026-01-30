@IsTest
private class YouseeStoreHoursServiceTest {
    private class GoogleMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            String url = req.getEndpoint();
            if (url.contains('/textsearch/json')) {
                res.setBody('{"results":[{"place_id":"test_place"}],"status":"OK"}');
                return res;
            }
            if (url.contains('/details/json')) {
                res.setBody('{"result":{"name":"YouSee Store Test","formatted_address":"Test Address","formatted_phone_number":"+45 12345678","opening_hours":{"open_now":true,"weekday_text":["Monday: 10–17","Tuesday: 10–17"]}},"status":"OK"}');
                return res;
            }

            res.setBody('{"status":"OK"}');
            return res;
        }
    }

    @IsTest
    static void testLookupSuccess() {
        // Configure org default setting
        IntegrationSettings__c s = new IntegrationSettings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Name = 'OrgDefaults',
            GoogleMapsApiKey__c = 'dummy'
        );
        insert s;

        Test.setMock(HttpCalloutMock.class, new GoogleMock());

        Test.startTest();
        YouseeStoreHoursService.StoreLookupRequest req = new YouseeStoreHoursService.StoreLookupRequest();
        req.query = 'YouSee Store Copenhagen';
        List<YouseeStoreHoursService.StoreLookupResponse> out = YouseeStoreHoursService.getOpeningHours(new List<YouseeStoreHoursService.StoreLookupRequest>{ req });
        Test.stopTest();

        System.assertEquals(1, out.size());
        System.assertEquals(true, out[0].success);
        System.assertEquals('YouSee Store Test', out[0].storeName);
        System.assertEquals(true, out[0].openNow);
        System.assert(out[0].weekdayText.contains('Monday'));
    }

    @IsTest
    static void testMissingKey() {
        // Ensure no org default exists (best-effort)
        List<IntegrationSettings__c> existing = [SELECT Id FROM IntegrationSettings__c WHERE SetupOwnerId = :UserInfo.getOrganizationId() LIMIT 1];
        if (!existing.isEmpty()) delete existing;

        YouseeStoreHoursService.StoreLookupRequest req = new YouseeStoreHoursService.StoreLookupRequest();
        req.query = 'YouSee Store Copenhagen';
        List<YouseeStoreHoursService.StoreLookupResponse> out = YouseeStoreHoursService.getOpeningHours(new List<YouseeStoreHoursService.StoreLookupRequest>{ req });

        System.assertEquals(false, out[0].success);
        System.assert(out[0].message.contains('not configured'));
    }
}
