import { LightningElement , api} from 'lwc';
import CallBatchForCM_URL from '@salesforce/apex/SeismicContentAPICallout.CallBatchForCM_URL';

export default class GenerateLiveSendForCMembers extends LightningElement {

    @api recordId;
    success;
    
    handleGenerateLinks(e){

        console.log('Campaign Id::' + this.recordId);

        CallBatchForCM_URL({CampaignId: this.recordId})
        .then(result => {

            console.log('Batch has been scheduled, you will recieve an email once completed' + result);
            this.success =  'Batch has been scheduled, you will recieve an email once completed';
        })
        .catch(error => {

            console.log('Error occured::' + JSON.stringify(error));

        })


    }

}