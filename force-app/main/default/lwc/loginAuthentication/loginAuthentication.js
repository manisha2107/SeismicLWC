import { LightningElement, track, api } from 'lwc';
import CallBatchForCM_URL from '@salesforce/apex/SesimicAccessTokenCallout.getPFAccessToken';
import connectSeismic from '@salesforce/apex/SesimicAccessTokenCallout.connectToSeismicURL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LoginAuthentication extends LightningElement {

    username = '';
    password = '';
    isNonSSO = true;

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
        console.log(event);
        this.isNonSSO = false;
    }

    handleNonSSOLogin(event){

        //console.log( 'Class list::'+event.classlist);
        this.isNonSSO = true;
    }

    redirectToSSO(event){

        connectSeismic()
        .then(result=>{

            window.location.replace(result);
            console.log('Result::' + result );
        })
        .catch(error=>{

            console.log('Error::' + error );
        })

    }

}