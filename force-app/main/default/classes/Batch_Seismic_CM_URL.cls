global  class Batch_Seismic_CM_URL implements  Database.Batchable<sObject>, Database.Stateful , Database.AllowsCallouts{
    
    global String campaignId = '';
    global list<CampaignMember> lst_campaign_membs = new list<CampaignMember>();
    global Integer iteration = 1;
    global String body = '';
    global List<CampaignMember> campaignMember = new List<CampaignMember>();
    global Map<String, String> mapOfError = new Map<String, String>();
    global List<String> lstCSVRows = new List<String>();
    global DateTime expiresTime = System.Now();
    global Seismic_User_Credientals__mdt userCred =SesimicAccessTokenCallout.getUserDetails();
        
    
    global Batch_Seismic_CM_URL(String campaignId , String body){
        
        System.debug('Campaign Id::' + campaignId );
        this.campaignId = campaignId;
        this.body = body;
        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext info){ 

        System.debug('Campaign Id::' + [Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId and LiveSend_URL__c =: null] );

        expiresTime = userCred.Expires_At__c;
        
        System.debug('Expires Time::' + expiresTime);
            
        return database.getQueryLocator('Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId and LiveSend_URL__c = null limit 10'); 
   }
    
    global void execute(Database.BatchableContext BC, list<CampaignMember> lst_campaign_members){
    
        String token = null;
        Map<String, Object> mapOfResBody = new Map<String, Object>();
     	DateTime etime;
        Boolean UpdateMDT = false;
         
        
        if(userCred!=null){

                if(expiresTime<System.Now().addSeconds(120)){
                    
                    System.debug('Expires At::' + expiresTime);
                    mapOfResBody = SesimicAccessTokenCallout.pwdFlowCallout(userCred.Username__c, userCred.Password__c);
                    
                    if(mapOfResBody!=null){
                        
                        token = String.valueOf(mapOfResBody.get('access_token'));
                        String expires_in = String.valueOf(mapOfResBody.get('expires_in'));
                        Integer seconds = Integer.valueOf(expires_in);
                        DateTime nTime = System.Now();
                        expiresTime = nTime.addSeconds(seconds);
                        userCred.Access_Token__c = String.valueOf(mapOfResBody.get('access_token'));
                        UpdateMDT = true;
                    }
                    

                    
                }
                
                else{
                    
                    token = userCred.Access_Token__c;
                }
                
            }
            
        
        System.debug('List of Campaign Members::' + lst_campaign_members);
        
        lst_campaign_membs = lst_campaign_members;
        
        for(CampaignMember campaign_member: lst_campaign_members){
           
            if(token!=null){
                
                mapOfError = SeismicContentAPICallout.getContentURL(campaign_member.Campaign.Name, campaign_member.email, body, token);
            	
                
                if(mapOfError.get('Success')!=null){
                    
                    campaign_member.LiveSend_URL__c = mapOfError.get('Success');
                    //lstCSVRows.add(campaign_member.Id +','+ mapOfError.get('Success') +' , Success');
                    campaign_member.Campaign_Name_Tag__c = campaign_member.Campaign.Name;
                    campaign_member.Email_Tag__c = campaign_member.Email;
                    campaign_member.Result__c = 'Success';
                    
                }
                
                else{
                    
                    //lstCSVRows.add(campaign_member.Id +','+ mapOfError.get('Error') +', Error');
                    campaign_member.Campaign_Name_Tag__c = campaign_member.Campaign.Name;
                    campaign_member.Email_Tag__c = campaign_member.Email;
                    campaign_member.Result__c = 'Failed';
                    campaign_member.Failure_Reason__c = mapOfError.get('Error');
                }
            }
            
        }
        
        update lst_campaign_members;
        
           
        /*if(UpdateMDT){
            
			SesimicAccessTokenCallout.upsertMetaData(userCred.Username__c, userCred.Password__c, token , userCred.SF_User_Id__c, etime);
            
        }*/
    }
    
    global void finish(Database.BatchableContext BC){
        
        List<CampaignMember> lstCamMem = [Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId and LiveSend_URL__c =: ''];
        
        System.debug('Remaining Campaign Member Size::' + lstCamMem.size());
        System.debug('Remaining Campaign Members::' + lstCamMem);
        
        if(lstCamMem.size()>0){
            
            String cronID = System.scheduleBatch(new Batch_Seismic_CM_URL(campaignId, body), 'Seismic LiveSend Request '+iteration++, 1);
            
        }
        
        else{
            
            createSuccessAttachment('Campaign Member Id, Message, Status' , campaignId);
        }
       
    }

    public static void createSuccessAttachment(String csvColumnHeader, String campaignId ){
        
        /*
        
        System.debug('CSV Row Values Error::' + csvRowValues);
        
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        
        // Insert the generated CSV file in Document object under "Setup Audit Trail Logs".
        Document doc = new Document(Name = 'Error Log File', Body = Blob.valueOf(csvFile), Type = 'csv', ContentType='application/vnd.ms-excel');
        //Blob txtEft = Blob.valueOf(doc);
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
       
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Log File');
        efa.setBody( Blob.valueOf(csvFile));
        efa.setContentType('application/vnd.ms-excel');
     	attachments.add(efa);
       
		*/
                
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        //semail.setFileAttachments(attachments);
		//semail.setDocumentAttachments(new ID[]{doc.Name});
		semail.setSubject('Generate LiveSend URL Process Completed for' + campaignId);
        String email = UserInfo.getuserEmail();
		String[] sendTo = new String[]{email};
		semail.setToAddresses(sendTo);
        semail.setPlainTextBody('Please find the report link below. \n' + 'https://cloudjunctionadvisors-6f-dev-ed.lightning.force.com/lightning/r/Report/00O5e000008EEdREAW?pv0='+campaignId);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
	   
    }
    
}