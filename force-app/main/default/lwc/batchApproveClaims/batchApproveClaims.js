import { LightningElement,api,wire,track } from 'lwc';
import updateClaimItemsApprovedQuantityAndReason from '@salesforce/apex/clainAndShipmentItemController.updateClaimItemsApprovedQuantityAndReason';
import getAllClaimItems from '@salesforce/apex/clainAndShipmentItemController.getAllClaimItems';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BatchApproveClaims extends LightningElement {
     @api recordId;
        isLoading=false;
        refreshData=[];
        claimList=[];
        buttonVisibility=true;
        @track claimUpdates = {};
        
        @wire(getAllClaimItems,{recordId:'$recordId'})
        wiredData(result){
            this.refreshData=result;
            debugger;
            if(result.data){
                this.claimList=result.data;
                // if(this.claimList[0].Claim.Create_Batch__r.Is_GRN_Received__c === true){
                //     console.log('this.claimList.Create_Batch__r.Is_GRN_Received__c===>',this.claimList[0].Claim.Create_Batch__r.Is_GRN_Received__c);
                //     this.buttonVisibility=false;
                // }
                
                // console.log('Claim List==>',result.data);
            }else if(result.error){
                console.log('Error===>',result.error);
            }
    
        }
        get inputDisable(){
            return this.claimList[0].Create_Batch__r.Is_GRN_Received__c === true;
        }
        
        handleInputChange(event) {
            const { id, field } = event.target.dataset;
            let value = event.target.value;
        
            // Convert Approved_Quantity__c to a number
            if (field === 'Approved_Quantity__c') {
                value = value ? parseFloat(value) : 0;
            }
        
            // If the field is Rejection_Reason__c, it should store the string value
            if (field === 'Rejection_Reason__c') {
                value = value || ''; // Ensure it's always a string
            }
        
            // Ensure claimUpdates object is properly structured
            if (!this.claimUpdates[id]) {
                this.claimUpdates[id] = {};
            }
        
            // Store the updated values
            this.claimUpdates[id][field] = value;
        }
        

        inputValidation() {
            let isValid = true;
            this.claimList.forEach((ClaimItem) => {
                if (ClaimItem.ReceivedQuantity > ClaimItem.QuantityRejected) {
                    this.showToast('Warning', 'Received Quantity cannot be greater than Rejected Quantity', 'warning');
                    isValid = false;
                }
            });
            return isValid;
        }
        
        
        handleSubmit(){
    
            debugger;
            if (!this.inputValidation()) {
                return; 
            }
        
const updatesArray = Object.keys(this.claimUpdates).map(id => ({
    claimItemId: id,
    approvedQuantity: this.claimUpdates[id]['Approved_Quantity__c'] || 0,
    rejectionReason: this.claimUpdates[id]['Rejection_Reason__c'] || '' 
}));

const updatesJson = JSON.stringify(updatesArray);
this.isLoading = true;
updateClaimItemsApprovedQuantityAndReason({ claimItemWrappersJson: updatesJson })
    .then(result => {
        this.showToast('Success', 'Claim Items Update successfully', 'success');
        setTimeout(() => {
            this.isLoading = false;
            this.handleExit();
        }, 2000);
    })
    .catch(error => {
        console.error('Error updating claim items:', error);
        this.showToast('Failure', 'Something went wrong!!!', 'error');
        this.isLoading = false;
    })
    .finally(() => {
        refreshApex(this.refreshData);
    });

        }
        handleExit(){
            this.dispatchEvent(new CloseActionScreenEvent());
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