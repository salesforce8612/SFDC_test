public with sharing class TravelController {
    public TravelDetails() {
        @auraEnabled public String distance;
        @auraEnabled public String cost;
        @auraEnabled public String travelTime;
    }
    @AuraEnabled
    public static TravelDetails getTravelDetails(String origin, String destination) {
        // Assign your full name in Base64 encoding to vHash
        String vHash = 'Sm9obiBEb2U='; // Replace with your name encoded in Base64

        // Call Google Maps API to get distance and travel time
        String googleApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://maps.googleapis.com/maps/api/directions/json?origin=' + EncodingUtil.urlEncode(origin, 'UTF-8') + '&destination=' + EncodingUtil.urlEncode(destination, 'UTF-8') + '&key=' + googleApiKey);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        Map<String, Object> directionsResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if (directionsResponse.get('status') != 'OK') {
            throw new AuraHandledException('Error getting directions from Google Maps API');
        }

        Map<String, Object> route = ((List<Map<String, Object>>) directionsResponse.get('routes')).get(0);
        Map<String, Object> leg = ((List<Map<String, Object>>) route.get('legs')).get(0);

        String distance = (String) ((Map<String, Object>) leg.get('distance')).get('text');
        String travelTime = (String) ((Map<String, Object>) leg.get('duration')).get('text');
        Integer distanceInMeters = (Integer) ((Map<String, Object>) leg.get('distance')).get('value');

        // Convert meters to miles
        Decimal distanceInMiles = distanceInMeters / 1609.34;

        // Get the rate per mile from Custom Metadata
        List<TransportationRate_mdt> rates = [SELECT DeveloperName, Rate_per_Milec FROM TransportationRate_mdt];
        Decimal rate = rates[0].Rate_per_Mile__c; // Use the rate for driving as default
        Decimal cost = distanceInMiles * rate;

        TravelDetails details = new TravelDetails();
        details.distance = distance;
        details.travelTime = travelTime;
        details.cost = '$' + String.valueOf(cost.setScale(2, RoundingMode.HALF_UP));
        return details;
    }
}