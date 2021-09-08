import { LightningElement,track ,api} from 'lwc';
import getContent from '@salesforce/apex/SeismicContentCallout.getContent';
import generateLS_Link from '@salesforce/apex/SeismicContentCallout.generateLS_Link';
import isAuthenticated from '@salesforce/apex/SeismicContentCallout.isAuthenticated';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Add_contents extends LightningElement {
@track clickedButtonLabel = 'Show';  
  @track screen1 = true;
  @track screen2= false; 
  @track screen3= false;
  @track listOfSelectedItem=[];
  @track listOfContent = [];
  @track PasswordEnabled= true;
  @track passwordtoggle=true;
  @api recordId;
  @track Password='test';
  @track notification='';
  @track expirydate='';
  @track allowDownload='';
  @track isAuthenticated = true;
  @track limitNo = 10;
  @track CreatedEndDate;
  @track CreatedStartDate;
  @track showLoading = false;;


  clickedButtonLabel;
  value = '';

     // fucntion to fill data for the radio group options
     get options() {
      return [
          { label: 'Alert me about all viewing activity', value: 'option1' },
          { label: 'Alert me about all viewing activity', value: 'option2' },
      ];
  }

  
 
  connectedCallback(){
   console.log('recordId in addContent LWC::' + this.recordId);
      isAuthenticated()
      .then(result =>{

        console.log('Result::' + this.isAuthenticated);
        this.isAuthenticated = result;

      })
      .catch(error =>{

        console.log('Error:' + JSON.stringify(error));

      })

  }

  getContentData(){
    this.showLoading = true;

    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
    .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
    }, true); 
    if (isInputsCorrect) {
    

      getContent({"CreatedStartDate":this.CreatedStartDate , "CreatedEndDate": this.CreatedEndDate, "limitNo": this.limitNo})
      .then(result => {


        console.log('Get Content recieved::' + JSON.stringify(result));
        this.listOfContent=result;

        let Listofitems=[];
        for(let i=0;i<result.length;i++)
        {
          
          Listofitems.push
          ({
                        rowIndex: i,
                        item: result[i].item,
                        checked: false,
                        link: result[i].link,
                        id : result[i].id
                      
          })
          

        }
          this.listOfContent=Listofitems;

          this.showLoading = false;
          

      })
      .catch(error=>{

        console.log('Error occured::' + JSON.stringify(error)) ;
        this.showLoading = false;

      })


      let target = this.template.querySelector('.slds-panel_docked-right');
      target.classList.add('hide-class');

   }



    
  }

  allowDownloadfunc(event){
    this.allowDownload=event.target.checked;
    console.log("Allow download"+this.allowDownload);

  }


 



    

  // connected callback to get data from Apex Class SeismicContentCallout.cls 
  // This will return a JSON in result parameter which will be used to populate data in html in second screen
  // The json parameter "item" will contain the value of text to be diplayed in the list view and the parameter
  // "link" contains the hyperlink that is diplayed at the bottom


  notificationHandler(event){
    this.notification=event.target.value;
    console.log("Notification button pressed :"+this.notification);

  }
  SendData(event){

    console.log(JSON.stringify(this.listOfSelectedItem));
    console.log('SEND DATE::' + event.target.label);
    generateLS_Link({'expiresAt':this.expirationDate,'password':this.Password,'allowDownload':this.allowDownload,'notificationType':'ALL','singleView':this.passwordEnabled,'CampaignId': this.recordId, 'LstSL':this.listOfSelectedItem})
    .then(result=>{
      console.log("Sent Successfully"+result);
      const event = new ShowToastEvent({
        title: 'Success',
        message: 'Request has been sent. Once it completed you will recieve a confirmation email',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(event);
    })
    .catch(error=>{
      console.log("Error in Sending data is :"+ JSON.stringify(error));

      const event = new ShowToastEvent({
        title: 'Error',
        message: 'Something has happened. Please contact your salesforce Administrator',
        variant: 'error',
        mode: 'dismissable'
    });

    this.dispatchEvent(event);
    })

    this.closeAction();

  }

  expiryDateFunc(event){
    this.expirationDate=event.target.value;
    console.log("This is the Expiration date :"+this.expirationDate);

  }

  changeHandler(event) {
    this.greeting = event.target.value;
  }


  // Add item button on last screen to go back to second screen
  Additems(event) {
    this.screen3=false;
    this.screen2=true;

  }

    //  Open Second screen function

  handleClick(event) {

    

    this.clickedButtonLabel = event.target.label;
    const label = event.target.label; 
    this.screen1=false;
    this.screen2=true;

  }

  // Function to open last screen and bind the values with selected true                                                                                                                                                                                                                                                       
  openLastScreen(event){
      this.boolVisible=false;
      this.screen2=false;
      
      
      console.log("Last screen opened :"+ event.target.label);

      let listofitems=[];
      let length1=this.listOfContent.length;
      console.log("List initialized")
      for(let i=0;i<length1;i++)
      {
        console.log("Entered For Loop")
        console.log(this.listOfContent[i].rowIndex)
        console.log(this.listOfContent[i].checked)
        if(this.listOfContent[i].checked)
        {
          listofitems.push(this.listOfContent[i]);
          console.log("Checked value is :"+listofitems[i]);

        }

      }

      this.listOfSelectedItem=listofitems;
      console.log("List of selecteditems :"+JSON.stringify(listofitems));

      this.screen3=true;

  }

  //Toggle functionalit to enable disable password field based on this toggle field

  Passwordtogglefunc(event){
    
      this.passwordtoggle=event.target.checked;
      if(this.passwordtoggle==true) {
        this.passwordtoggle=false;
      }
      else{
        this.passwordtoggle=true;

      }

      console.log("event value is:"+event.target.checked );

      passwordEnabled=event.target.checked;
      console.log("Password enabled:"+passwordEnabled);
    
  }
    

  //This is the funciton to bind the checklist values with the list items selecteced on second screen
  handleContentChecked(event){

      let lstCon = this.listOfContent;
      //this.listOfContent = [];
      this.listOfSelectedItem = [];
      this.listOfSelectedItem.push(lstCon[event.target.dataset.id]);



      // console.log(event.target.checked + 'Index' + event.target.dataset.id);
      // let lstCon = this.listOfContent;
      // this.listOfContent = [];
      // lstCon[event.target.dataset.id].checked = event.target.checked;
      // this.listOfContent = lstCon;

  }

  handleOpen(event){

      let target = this.template.querySelector('.slds-panel_docked.slds-is-open');
      target.classList.remove('hide-class');

  }

  handleClose(event){

    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
          let target = this.template.querySelector('.slds-panel_docked.slds-is-open');
          target.classList.add('hide-class');

        }

   

  }

  handleonChangeFilters(event){

    if(event.target.label=='Created At Start Time'){

      this.CreatedStartDate = event.target.value;
    }

    else if(event.target.label=='Created At End Time'){


      this.CreatedEndDate = event.target.value;
    }

  }


   
closeAction(){
  this.dispatchEvent(new CloseActionScreenEvent());
}


}