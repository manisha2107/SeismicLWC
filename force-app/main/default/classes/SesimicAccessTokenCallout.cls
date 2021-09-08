public class SesimicAccessTokenCallout implements Metadata.DeployCallback{
    
    public static String token { get; set; }
    public static String authCode { get; set; }
    
    @AuraEnabled(cacheable=true)
    public static String getPFAccessToken(String user_name, String pwd){
        String token = '';
            
            Map<String, Object> mapOfResBody = SesimicAccessTokenCallout.pwdFlowCallout(user_name, pwd);
            token =String.valueOf(mapOfResBody.get('access_token'));
            String expires_in = String.valueOf(mapOfResBody.get('expires_in'));
            Integer seconds = Integer.valueOf(expires_in);
            DateTime nTime = System.Now();
            DateTime dtime = nTime.addSeconds(seconds);
            upsertMetaData(user_name, pwd, String.valueOf(mapOfResBody.get('access_token')) , UserInfo.getUserId(), dtime);
            token = String.valueOf(mapOfResBody.get('access_token'));
        
        return token;
    }
    
    public static Map<String, Object> pwdFlowCallout(String user_name, String pwd){
        
        try{
            
            Sesmic_Authentication_Parameters__mdt authParams = [SELECT ID, Label, DeveloperName, Client_Id__c, Client_Secret__c, Grant_Type__c, Scope__c from Sesmic_Authentication_Parameters__mdt where DeveloperName = 'Password_Credientals' LIMIT 1];
            
            // Password Flow Credentials
            String grant_type = authParams.Grant_Type__c;
            String client_id = authParams.Client_Id__c; //'5de354cd-3a76-4cce-9251-3cc7658f099a';
            String client_secret = authParams.Client_Secret__c; //'c382b597-57ae-4099-9476-72fce5a6c058';
            String username = user_name;
            String password = pwd;
            String scope = '';
            
            String authBody ='grant_type=' + grant_type + '&client_id=' + client_id + '&client_secret=' + client_secret + '&username=' + username + '&password=' + password;
            
            List<Seismic_HTTPCallout.CalloutHeaders> lstHeaders = new List<Seismic_HTTPCallout.CalloutHeaders>();
            lstHeaders.add(new Seismic_HTTPCallout.CalloutHeaders('Content-Type', 'application/x-www-form-urlencoded'));
            
            HttpResponse res = Seismic_HTTPCallout.getResponse(authBody, 'POST' , System.label.Seismic_Auth_URL+'/token#a' , lstHeaders);
            
            Map<String, Object> mapOfResBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            system.debug(mapOfResBody.get('access_token'));
            
            return mapOfResBody;
        }
        catch(Exception e){
            
            System.debug('Execption in Password Flow Callout::' + e.getLineNumber());
            return null;
        }
        
    }
    
    
    public static PageReference connectToSeismic () {
        String statusMessage;
        try {
            
            Sesmic_Authentication_Parameters__mdt authParams = [SELECT ID, Label, DeveloperName, Redirect_URL__c, Client_Id__c, Client_Secret__c, Grant_Type__c, Scope__c from Sesmic_Authentication_Parameters__mdt where DeveloperName = 'Authentication_Credientals' LIMIT 1];
            
            String response_type = 'code';
            String client_id = authParams.Client_Id__c;
            String redirect_uri = authParams.Redirect_URL__c;
            String scope = authParams.Scope__c;
            
            String endPoint =  System.Label.Seismic_Auth_URL+'/authorize' + '?response_type=' + response_type + '&client_id='+client_id+'&redirect_uri=' +redirect_uri+ '&scope=' + scope;
            System.debug('Endpoint='+endPoint);
            PageReference pageRef = new PageReference(endPoint);
            pageRef.setRedirect(true);
            return pageRef;
            //return null;
        }
        catch(System.Exception e){
            statusMessage = 'Exception: ' + e.getMessage();
        } 
        return null;
    }
    
    public static Seismic_User_Credientals__mdt getUserDetails(){
        
        String userId = UserInfo.getUserId();
        
        List<Seismic_User_Credientals__mdt>  lstUserCred = [Select id ,  Username__c, SF_User_Id__c, Access_Token__c, Password__c, Expires_At__c from Seismic_User_Credientals__mdt where SF_User_Id__c =: userId LIMIT 1];
        
        
        if(Test.isRunningTest()){
            lstUserCred = new List<Seismic_User_Credientals__mdt>();
            Seismic_User_Credientals__mdt userCred = new Seismic_User_Credientals__mdt();
            
            userCred.Username__c = UserInfo.getUserName();
            userCred.SF_User_Id__c = UserInfo.getUserId();
            userCred.Password__c = UserInfo.getUserId();
            userCred.Access_Token__c = 'abc';
            userCred.Expires_At__c = System.Now();
            lstUserCred.add(userCred);
        }
        
        if(lstUserCred.size()>0){
            
            return lstUserCred[0];
        }
        
        return null;
        
    }

	public static void upsertMetaData(String username, String password, String token, String id, DateTime ExpiresAt){
        
        // Intialize the Meta Data which needs to update
        
        MetaData.CustomMetadata customMDT =  new MetaData.CustomMetaData();
        
        // full name is object name + recordName which needs to upsert
        customMDT.fullName  = 'Seismic_User_Credientals.'+UserInfo.getFirstName() + '_'+ UserInfo.getLastName()  ;
        customMDT.Label = Id;
        
        List<Metadata.CustomMetadataValue> metadatafields = new List<Metadata.CustomMetadataValue>();
        metadatafields.add(createCustomMetadataField('Access_Token__c',token));
        metadatafields.add(createCustomMetadataField('SF_User_Id__c', Id));
        metadatafields.add(createCustomMetadataField('Username__c', username));
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'Expires_At__c';
        customField.value = ExpiresAt;
        metadatafields.add(customField);
        metadatafields.add(createCustomMetadataField('Password__c',password));
        
        customMDT.values.addAll(metadatafields);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMDT);
        
        
        SesimicAccessTokenCallout callback = new SesimicAccessTokenCallout();
         // Enqueue custom metadata deployment
        // jobId is the deployment ID
        
        // Enqueue custom metadata deployment
		Id jobId = Test.isRunningTest() ? '0Af5e00000Cwg5g' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        
        //Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        system.debug('JobID::'+jobId);

  
    }
    
    public static Metadata.CustomMetadataValue createCustomMetadataField(String field,String fieldValue){
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = field;
        customField.value = fieldValue;
        return customField;
    }
    
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        } else {
            // Deployment was not successful
            System.debug('fail: '+ result);
        }
    }

    public static void getOAuthToken(){
        
        try{
            
            Sesmic_Authentication_Parameters__mdt authParams = [SELECT ID, Label, Redirect_URL__c, DeveloperName, Client_Id__c, Client_Secret__c, Grant_Type__c, Scope__c from Sesmic_Authentication_Parameters__mdt where DeveloperName = 'Authentication_Credientals' LIMIT 1];
            
            // Password Flow Credentials
            String grant_type = authParams.Grant_Type__c;
            String client_id = authParams.Client_Id__c; //'5de354cd-3a76-4cce-9251-3cc7658f099a';
            String client_secret = authParams.Client_Secret__c; //'c382b597-57ae-4099-9476-72fce5a6c058';
            String scope = authParams.Scope__c;
            String redirectURl = authParams.Redirect_URL__c;
            
            authCode = ApexPages.currentPage().getParameters().get('code');
            String requestBody;
            String errorMessage = '';

            String authBody ='grant_type=' + grant_type + '&client_id=' + client_id + '&client_secret=' + client_secret +'&redirect_uri='+redirectURl + '&code=' + authCode;
            
             List<Seismic_HTTPCallout.CalloutHeaders> lstHeaders = new List<Seismic_HTTPCallout.CalloutHeaders>();
            lstHeaders.add(new Seismic_HTTPCallout.CalloutHeaders('Content-Type', 'application/x-www-form-urlencoded'));
            
            HttpResponse res = Seismic_HTTPCallout.getResponse(authBody, 'POST' , System.label.Seismic_Auth_URL+'/token#a' , lstHeaders);
            
            
            Map<String, Object> mapOfResBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            system.debug('Access TOken::' + mapOfResBody.get('access_token'));
            
            token = String.valueOf(mapOfResBody.get('access_token'));
            
            
            //PageReference pageRef = new PageReference('https://cloudjunctionadvisors-6f-dev-ed.lightning.force.com/lightning/page/home');
        	//return pageRef;

            
        }
        catch(Exception e){
            
            System.debug('Execption in Password Flow Callout::' + e.getLineNumber());
            //return null;
           
        }
        
        
    }
    
    @AuraEnabled
     public static String connectToSeismicURL () {
        String statusMessage;
        try {
            
            Sesmic_Authentication_Parameters__mdt authParams = [SELECT ID, Label, DeveloperName, Redirect_URL__c, Client_Id__c, Client_Secret__c, Grant_Type__c, Scope__c from Sesmic_Authentication_Parameters__mdt where DeveloperName = 'Authentication_Credientals' LIMIT 1];
            
            String response_type = 'code';
            String client_id = authParams.Client_Id__c;
            String redirect_uri = authParams.Redirect_URL__c;
            String scope = authParams.Scope__c;
            
            String endPoint =  System.Label.Seismic_Auth_URL+'/authorize' + '?response_type=' + response_type + '&client_id='+client_id+'&redirect_uri=' +redirect_uri+ '&scope=' + scope;
            System.debug('Endpoint='+endPoint);
            
            return endPoint;
            //return null;
        }
        catch(System.Exception e){
            statusMessage = 'Exception: ' + e.getMessage();
        } 
        return statusMessage;
    }
    
}