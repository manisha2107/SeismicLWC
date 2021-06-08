global  class Batch_Seismic_CM_URL implements  Database.Batchable<sObject>, Database.Stateful , Database.AllowsCallouts{
    
    global String campaignId = '';
    
    global Batch_Seismic_CM_URL(String campaignId){
        
        System.debug('Campaign Id::' + campaignId );
        this.campaignId = campaignId;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext info){ 

        System.debug('Campaign Id::' + [Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId] );

        return database.getQueryLocator('Select id ,LiveSend_URL__c, Campaign.name , email from CampaignMember where CampaignId =: campaignId'); 
   }
    
    global void execute(Database.BatchableContext BC, list<CampaignMember> lst_campaign_members){
    
        System.debug('List of Campaign Members::' + lst_campaign_members);
        for(CampaignMember campaign_member: lst_campaign_members){
            
            String url = SeismicContentAPICallout.getContentURL(campaign_member.Campaign.Name, campaign_member.email);
            
            campaign_member.LiveSend_URL__c = url;
            
        }
        
        update lst_campaign_members;
    }
    
    global void finish(Database.BatchableContext BC){
        
        System.debug('Data has been updated');
    }

}