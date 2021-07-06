import { LightningElement,track ,api} from 'lwc';
import getContent from '@salesforce/apex/SeismicContentCallout.getContent';
import generateLS_Link from '@salesforce/apex/SeismicContentCallout.generateLS_Link';

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


    clickedButtonLabel;
    value = '';

    @api
    callChildFunction(recordId){


      console.log('recordId in addContent LWC::' + recordId);

      getContent()
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

        // for
        // let list = [];
        // {index: i; name: name , link:link, checked:false}

      })
      .catch(error=>{

        console.log('Error occured::' + JSON.stringify(error)) ;

      })
      
    }


    allowDownloadfunc(event)
    {
      this.allowDownload=event.target.checked;
      console.log("Allow download"+this.allowDownload);

    
    }


    // fucntion to fill data for the radio group options
    get options() {
      return [
          { label: 'Alert me about all viewing activity', value: 'option1' },
          { label: 'Alert me about all viewing activity', value: 'option2' },
      ];
  }

 


   

  // connected callback to get data from Apex Class SeismicContentCallout.cls 
  // This will return a JSON in result parameter which will be used to populate data in html in second screen
  // The json parameter "item" will contain the value of text to be diplayed in the list view and the parameter
  // "link" contains the hyperlink that is diplayed at the bottom

  
    notificationHandler(event)
    {
      this.notification=event.target.value;
      console.log("Notification button pressed :"+this.notification);

    }
    SendData(event)
    {

      console.log('SEND DATE::' + event.target.label);
      generateLS_Link({'expiresAt':this.expirationDate,'password':this.Password,'allowDownload':this.allowDownload,'notificationType':'ALL','singleView':this.passwordEnabled,'CampaignId': this.recordId, 'LstSL':this.listOfSelectedItem})
      .then(result=>{
        console.log("Sent Successfully"+result);
      })
      .catch(error=>{
        console.log("Error in Sending data is :"+error);
      })

    }

    expiryDateFunc(event)
    {
      this.expirationDate=event.target.value;
      console.log("This is the Expiration date :"+this.expirationDate);

    }

    changeHandler(event) {
      this.greeting = event.target.value;
    }


    // Add item button on last screen to go back to second screen
    Additems(event)
    {
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
    openLastScreen(event)
    {
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

    Passwordtogglefunc(event)
    {
    

     // password

      this.passwordtoggle=event.target.checked;
      if(this.passwordtoggle==true)
      {
        this.passwordtoggle=false;

      }
      else
      {
        this.passwordtoggle=true;

      }

       console.log("event value is:"+event.target.checked );

       passwordEnabled=event.target.checked;
       console.log("Password enabled:"+passwordEnabled);
    
    
    
    }
    

    //This is the funciton to bind the checklist values with the list items selecteced on second screen
    handleContentChecked(event){

      console.log(event.target.checked + 'Index' + event.target.dataset.id);
      let lstCon = this.listOfContent;
      this.listOfContent = [];
      lstCon[event.target.dataset.id].checked = event.target.checked;
      this.listOfContent = lstCon;

    }

    }