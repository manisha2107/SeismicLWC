public class SesimicAccessTokenCallout {
    
    public static String getPFAccessToken(){
        
        // Password Flow Credentials
        String grant_type = 'password';
        String client_id = '5de354cd-3a76-4cce-9251-3cc7658f099a';
        String client_secret = 'c382b597-57ae-4099-9476-72fce5a6c058';
        String username = 'mohsin@cloudjunction.cloud';
        String password = 'Salesforce$5';
        String scope = '';
        
        String jsonBody ='grant_type=' + grant_type + '&client_id=' + client_id + '&client_secret=' + client_secret + '&username=' + username + '&password=' + password;
        
        Http http = new Http();
        httpRequest request = new httpRequest();
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setEndPoint('https://auth.seismic.com/tenants/guardiancapital/connect/token#p');
        request.setBody(jsonBody);
        request.setMethod('POST');
        //system.debug('grant_type set to:' + request.getHeader('grant_type'));
        HttpResponse res = new httpResponse();
        system.debug(request);
        res = http.send(request);
        System.debug(res.getBody());
        System.debug(res.getStatusCode());
        
        Map<String, Object> mapOfResBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
		system.debug(mapOfResBody.get('access_token'));
        
        return String.valueOf(mapOfResBody.get('access_token'));
    }
    
}