public class SeismicContentAPICallout {

    public static String getContentURL(String CampaignName, String emailAddress){
        
        String url= '';
        
        String jsonBody = '{"tags":["campaign:'+CampaignName+',email:' + emailAddress+'"],"settings":{"expiresAt":"2021-05-17T20:11:24.433Z","notificationType":"All","allowDownload":true,"singleView":false},"content":[{"libraryContent":{"id":"6ecd586b-7cbd-4051-9147-35d3e4e299bb","versionId":"3e5a3871-98c6-406f-acb6-0b72cca0449d","teamsiteId":"1"},"id":"6ecd586b-7cbd-4051-9147-35d3e4e299bb","teamsiteId":"1","contentProfileId":"f45cef79-bbc4-43e9-9c61-29ae46315606","name":"Guardian_QuickThoughts(CAD)_Apr29","repository":"Library","type":"url","versionId":"3e5a3871-98c6-406f-acb6-0b72cca0449d"}]}';
        
        Http http = new Http();
        httpRequest request = new httpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization' , 'Bearer '+ SesimicAccessTokenCallout.getPFAccessToken());
        request.setEndPoint('https://api.seismic.com/integration/v2/liveSend/links');
        request.setBody(jsonBody);
        request.setTimeout(60000);
        request.setMethod('POST');
        HttpResponse res = new httpResponse();
        system.debug(request);
        res = http.send(request);
        System.debug(res.getBody());
        System.debug(res.getStatusCode());
        
        Map<String, Object> mapOfResBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
		system.debug(mapOfResBody.get('url'));
        
        return String.valueOf(mapOfResBody.get('url'));
       
    }
    
    @AuraEnabled
    public static void CallBatchForCM_URL(String CampaignId){
        
        Batch_Seismic_CM_URL batch = new Batch_Seismic_CM_URL('7015e000000Hyr9AAC');
		Id batchId = Database.executeBatch(batch);
        
    }
}