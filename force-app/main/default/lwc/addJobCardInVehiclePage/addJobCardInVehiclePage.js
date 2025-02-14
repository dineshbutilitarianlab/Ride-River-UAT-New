import { LightningElement,wire,api,track } from 'lwc';
import getVehicleDetails from '@salesforce/apex/AddJobCardInVehiclePageController.getVehicleDetails';
import createJobCard from '@salesforce/apex/AddJobCardInVehiclePageController.createJobCard';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class AddJobCardInVehiclePage extends LightningElement {
    @api recordId;
    @track vehicleDetails=[];
    @track jobType='';
    @track odoMeter='';
    @wire(getVehicleDetails,{recordId:'$recordId'})
    wiredData({data,error}){
        debugger;
       if(data){
        this.vehicleDetails=data;
        console.log('Data===>',data);
       }else if(error){
        console.log(error);
       }
    }
    get jobTypeOptions(){
        return[
           {label:'Paid Service' ,value:'Paid Service'},
           {label:'Warranty' ,value:'Warranty'},
           {label:'Accidental' ,value:'Accidental'},
           {label:'PDI' ,value:'PDI'}
        ]
    }
    handleChange(event){
       this.jobType=event.detail.value;
       console.log('JobType===>',this.jobType);
 
    }
    handleOdometerChange(event){
        this.odoMeter=parseFloat(event.target.value);

    }
    handleCloseScreen(){
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleSubmit(){
        const jobCardDataInObject = {
            accId:this.vehicleDetails.AccountIds,
            conId:this.vehicleDetails.ContactIds,
            vehId:this.vehicleDetails.VehicleId,
            oRed:this.odoMeter,
            jobType:this.jobType
        };
        const jobCardData = JSON.stringify(jobCardDataInObject);
        console.log('jobCardData==>'+jobCardData);
        debugger;
        createJobCard({jobCardData:jobCardData})
        .then((result)=>{
            this.showToast('Success','Job Card Has Been Created','success');
            this.handleCloseScreen();

        })
        .catch((error)=>{
            this.showToast('Error','Something Went Wrong!!!','error');
        })
    }
    showToast(Title,Message,Variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title:Title,
                message:Message,
                variant:Variant
            })
        )
    }
}