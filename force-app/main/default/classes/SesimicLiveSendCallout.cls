public class SesimicLiveSendCallout {

    public static void getLiveSend(){
        
        String token = SesimicAccessTokenCallout.getPFAccessToken();
        Http http = new Http();
        httpRequest request = new httpRequest();
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('authorization', 'Bearer '+token);
        request.setEndPoint('https://api.seismic.com/reporting/v2/livesendLinks');
        request.setMethod('GET');
        //system.debug('grant_type set to:' + request.getHeader('grant_type'));
        HttpResponse res = new httpResponse();
        system.debug(request);
        res = http.send(request);
        System.debug(res.getBody());
        System.debug(res.getStatusCode());
        	
        
    }
}