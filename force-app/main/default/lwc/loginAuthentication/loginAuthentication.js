import { LightningElement, track, api } from 'lwc';
import CallBatchForCM_URL from '@salesforce/apex/SesimicAccessTokenCallout.getPFAccessToken';
import connectSeismic from '@salesforce/apex/SesimicAccessTokenCallout.connectToSeismicURL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LoginAuthentication extends LightningElement {

    username = '';
    password = '';
    isNonSSO = true;
    @api token = '';
    authCode = '';

    parameters = {};

    connectedCallback() {

        this.parameters = this.getQueryParameters();
        console.log(this.parameters);
    }

    
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        console.log('Search ::' + search );

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    handleOnChange(e){

        console.log(e.target.dataset.id);
        if(e.target.dataset.id == 'username'){

            console.log('Username::' + e.target.value);
            this.username = e.target.value;

        }

        if(e.target.dataset.id == 'password'){

            console.log('Password::' + e.target.value);
            this.password = e.target.value;

        }

    }

    handleAuthentication(e){

        console.log('Handle Authentication');

        CallBatchForCM_URL({user_name: this.username, pwd: this.password})
        .then(result=>{

            console.log('Result::' + result);
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'User has logged in successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

        })
        .catch(error=>{

           
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Something has happened. Please contact your salesforce Administrator',
                variant: 'error',
                mode: 'dismissable'
            });

            this.dispatchEvent(event);
            console.log('Error for Authentication ::' + error);
        })

    }

    handleSSOLogin(event){

        //console.log('Class list::' + event.classlist);
        
        //console.log( 'Class list::'+event.classlist);
        console.log('Non-SSO');
        let target = this.template.querySelector('[data-id="Non-SSO"]');
        console.log('Targets of Non-SSO::' + target);
        target.classList.add('slds-button_neutral');
        target.classList.remove('slds-button_outline-brand');
        console.log(event);

        let target1 = this.template.querySelector('[data-id="SSO"]');
        console.log('Targets of Non-SSO::' + target1);
        target1.classList.remove('slds-button_neutral');
        target1.classList.add('slds-button_outline-brand');

        this.isNonSSO = false;
    }

    handleNonSSOLogin(event){

        console.log('SSO');
        //console.log( 'Class list::'+event.classlist);
        let target = this.template.querySelector('[data-id="SSO"]');
        target.classList.add('slds-button_neutral');
        target.classList.remove('slds-button_outline-brand');
        this.isNonSSO = true;


        let target1 = this.template.querySelector('[data-id="Non-SSO"]');
        console.log('Targets of Non-SSO::' + target1);
        target1.classList.remove('slds-button_neutral');
        target1.classList.add('slds-button_outline-brand');
    }

    redirectToSSO(event){

        connectSeismic()
        .then(result=>{

            window.open(result, '_blank');
            console.log('Result::' + result );
        })
        .catch(error=>{

            console.log('Error::' + error );
        })

    }

}