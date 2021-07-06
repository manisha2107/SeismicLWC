global  class Batch_Seismic_CM_URL implements  Database.Batchable<sObject>, Database.Stateful , Database.AllowsCallouts{
    
    global String campaignId = '';
    global list<CampaignMember> lst_campaign_membs = new list<CampaignMember>();
    global Integer iteration = 1;
    global String body = '';
    
    global Batch_Seismic_CM_URL(String campaignId, String body){
        
        System.debug('Campaign Id::' + campaignId );
        this.campaignId = campaignId;
        this.body = body;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext info){ 

        System.debug('Campaign Id::' + [Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId and LiveSend_URL__c = null] );

        return database.getQueryLocator('Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId and LiveSend_URL__c = null limit 10'); 
   }
    
    global void execute(Database.BatchableContext BC, list<CampaignMember> lst_campaign_members){
    
        System.debug('List of Campaign Members::' + lst_campaign_members);
        
        lst_campaign_membs = lst_campaign_members;
        
        for(CampaignMember campaign_member: lst_campaign_members){
            
            String url = SeismicContentAPICallout.getContentURL(campaign_member.Campaign.Name, campaign_member.email);
            
            campaign_member.LiveSend_URL__c = url;
            
        }
        
        update lst_campaign_members;
    }
    
    global void finish(Database.BatchableContext BC){
        
        List<CampaignMember> lstCamMem = [Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId and LiveSend_URL__c != null];
        
        if(lstCamMem.size()>0){
            
            //String cronID = System.scheduleBatch(new Batch_Seismic_CM_URL(campaignId, body), 'job example'+iteration++, 1);
            
        }
       
    }

}