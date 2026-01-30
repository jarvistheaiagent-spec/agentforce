public with sharing class YouseeStoreHoursService {
    public class StoreLookupRequest {
        @InvocableVariable(required=true)
        public String query; // store name + city/address

        @InvocableVariable
        public String country; // optional, e.g. "DK"
    }

    public class StoreLookupResponse {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public String storeName;
        @InvocableVariable public String formattedAddress;
        @InvocableVariable public String formattedPhone;
        @InvocableVariable public Boolean openNow;
        @InvocableVariable public String weekdayText; // newline-separated
        @InvocableVariable public String placeId;
    }

    @InvocableMethod(label='Get YouSee Store Opening Hours' description='Looks up a YouSee store in Google Places and returns opening hours.')
    public static List<StoreLookupResponse> getOpeningHours(List<StoreLookupRequest> requests) {
        List<StoreLookupResponse> out = new List<StoreLookupResponse>();
        for (StoreLookupRequest req : requests) {
            out.add(handleOne(req));
        }
        return out;
    }

    private static StoreLookupResponse handleOne(StoreLookupRequest req) {
        StoreLookupResponse res = new StoreLookupResponse();
        res.success = false;

        String apiKey = IntegrationSettings__c.getOrgDefaults() != null
            ? IntegrationSettings__c.getOrgDefaults().GoogleMapsApiKey__c
            : null;

        if (String.isBlank(apiKey)) {
            res.message = 'Google Maps API key is not configured. Set IntegrationSettings__c.GoogleMapsApiKey__c in Setup.';
            return res;
        }

        if (req == null || String.isBlank(req.query)) {
            res.message = 'Missing query. Provide store name + city/address.';
            return res;
        }

        String query = req.query.trim();
        if (!String.isBlank(req.country)) query += ' ' + req.country.trim();

        // 1) Text Search to find a place
        Map<String, Object> searchJson = doGetJson(
            'https://maps.googleapis.com/maps/api/place/textsearch/json?query=' + EncodingUtil.urlEncode(query, 'UTF-8') +
            '&key=' + EncodingUtil.urlEncode(apiKey, 'UTF-8')
        );

        List<Object> results = (List<Object>) searchJson.get('results');
        if (results == null || results.isEmpty()) {
            res.message = 'No store found for query: ' + req.query;
            return res;
        }

        Map<String, Object> top = (Map<String, Object>) results[0];
        String placeId = (String) top.get('place_id');
        if (String.isBlank(placeId)) {
            res.message = 'Found a result but it did not contain a place_id.';
            return res;
        }
        res.placeId = placeId;

        // 2) Place Details for hours + contact
        Map<String, Object> detailsJson = doGetJson(
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=' + EncodingUtil.urlEncode(placeId, 'UTF-8') +
            '&fields=' + EncodingUtil.urlEncode('name,formatted_address,formatted_phone_number,opening_hours', 'UTF-8') +
            '&key=' + EncodingUtil.urlEncode(apiKey, 'UTF-8')
        );

        Map<String, Object> detail = (Map<String, Object>) detailsJson.get('result');
        if (detail == null) {
            res.message = 'Google Place Details returned no result.';
            return res;
        }

        res.storeName = (String) detail.get('name');
        res.formattedAddress = (String) detail.get('formatted_address');
        res.formattedPhone = (String) detail.get('formatted_phone_number');

        Map<String, Object> opening = (Map<String, Object>) detail.get('opening_hours');
        if (opening != null) {
            Object openNow = opening.get('open_now');
            if (openNow instanceof Boolean) res.openNow = (Boolean) openNow;
            List<Object> weekdayText = (List<Object>) opening.get('weekday_text');
            if (weekdayText != null && !weekdayText.isEmpty()) {
                List<String> lines = new List<String>();
                for (Object o : weekdayText) {
                    if (o != null) lines.add(String.valueOf(o));
                }
                res.weekdayText = String.join(lines, '\n');
            }
        }

        res.success = true;
        res.message = 'OK';
        return res;
    }

    private static Map<String, Object> doGetJson(String url) {
        HttpRequest r = new HttpRequest();
        r.setMethod('GET');
        r.setTimeout(20000);
        r.setEndpoint(url);

        Http h = new Http();
        HttpResponse resp = h.send(r);

        Integer status = resp.getStatusCode();
        if (status < 200 || status >= 300) {
            throw new CalloutException('Google API call failed: ' + status + ' ' + resp.getStatus() + ' :: ' + resp.getBody());
        }

        Object parsed = JSON.deserializeUntyped(resp.getBody());
        if (!(parsed instanceof Map<String, Object>)) {
            throw new CalloutException('Unexpected JSON response (not an object).');
        }
        return (Map<String, Object>) parsed;
    }
}
