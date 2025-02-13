import { LightningElement, track, wire ,api} from 'lwc';
import getClaims from '@salesforce/apex/ClaimController.getClaims';
import updateClaims from '@salesforce/apex/ClaimController.updateClaims';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class UpdateCreditNote extends NavigationMixin(LightningElement) {
    @track claimList = []; // Holds the list of claims
    @track isLoading = false; // Controls the loading spinner
    @track buttonVisibility = true; // Controls button visibility
    @api recordId;

    // // Fetch claim data when the component loads
    // connectedCallback() {
    //     this.loadClaims();
    // }

    @wire(getClaims,{recordId:'$recordId'})
        wiredGetClaims(result){
            debugger;
            if (result.data) {
                this.claimList = result.data;
               // this.isLoading = false;
            }
        
    }

    // Handle input changes for Approved Amount and Credit Note
    handleInputChange(event) {
        const id = event.target.dataset.id; // Get the claim item ID
        const field = event.target.dataset.field; // Get the field name (e.g., Approved_Amount__c or Credit_Note__c)
        const value = event.target.value; // Get the new value

        // Update the claimList array
        this.claimList = this.claimList.map(item => {
            if (item.Id === id) {
                return { ...item, [field]: value }; // Update the specific field
            }
            return item;
        });
    }

    // Handle submit button click
    handleSubmit() {
        debugger;
        this.isLoading = true;
        const mappedClaims = this.claimList.map(claim => ({
            claimId: claim.Id, // Mapping Id field
            approvedAmount: claim.Approved_Amount__c || 0, // Correctly mapping approvedAmount field
            creditNoteNumber: claim.Credit_Note_Number__c || ' ' // Correctly mapping creditNoteNumber field
        }));
        

        const updatesJson = JSON.stringify(mappedClaims);
        updateClaims({ claimItemWrappersJson: updatesJson })
            .then(() => {
                this.isLoading = false;
                // Show success message or refresh the data
                this.showToast('Success', 'Claims updated successfully!', 'success');
               // this.loadClaims(); // Refresh the data
            })
            .catch(error => {
                console.error('Error updating claims:', error);
                this.isLoading = false;
                this.showToast('Error', 'Failed to update claims.', 'error');
            });
    }

    // Handle exit button click
    handleExit() {
        // Navigate to a different page or close the component
        // Example: Navigate to the home page
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Utility function to show a toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}