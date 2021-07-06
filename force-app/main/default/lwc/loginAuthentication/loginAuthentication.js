import { LightningElement, track, api } from 'lwc';
import CallBatchForCM_URL from '@salesforce/apex/SesimicAccessTokenCallout.getPFAccessToken';

export default class LoginAuthentication extends LightningElement {

    username = '';
    password = '';

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

        })
        .catch(error=>{

            console.log('Error for Authentication ::' + error);
        })

    }

}