import { LightningElement, api, track, wire } from 'lwc';
import getLineItems from '@salesforce/apex/DiscrepancyController.getLineItems';
import updateSupportingMedia from '@salesforce/apex/DiscrepancyController.updateSupportingMedia';
import getUserProfile from '@salesforce/apex/DiscrepancyController.getUserProfile';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddSupportingMedia extends LightningElement {
    @api recordId;
    @track lineItems = [];
    @track mediaUpdates = {};
    isLoading = true;
    isAdmin = false;
    SpareUser = false;
    Warehouse = false;
    @track onLoadSpare = true;
    @track SpareOnApprove = false;
    @track onLoadReject = true;
    @track SpareOnReject = false;

    connectedCallback() {
        debugger;
        getUserProfile()
            .then(result => {
                if (result == 'System Administrator') {
                    this.SpareUser = true
                }
                if (result == 'Warehouse') {
                    this.Warehouse = true
                }
            })
            .catch(error => {
                this.showToast('Error', error, 'error');
                this.isLoading = false;
            });
    }

    @wire(getLineItems, { discrepancyId: '$recordId' })
    wiredLineItems({ error, data }) {
        if (data) {
            this.lineItems = data.map(item => ({
                ...item,
                isChecked: false,
                isDisabled: true,
                onLoadSpare: true,
                onLoadReject: true,
                feedback: '',
            }));
            this.isLoading = false;
        } else if (error) {
            this.showToast('Error', 'Failed to fetch line items', 'error');
            this.isLoading = false;
        }
    }

    handleCheckboxChange(event) {
        const itemId = event.target.dataset.id;
        const isChecked = event.target.checked;
        this.lineItems = this.lineItems.map(item =>
            item.Id === itemId ? { ...item, isChecked, isDisabled: !isChecked } : item
        );
    }

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.lineItems = this.lineItems.map(item => ({
            ...item,
            isChecked,
            isDisabled: !isChecked
        }));
    }

    handleInputChange(event) {
        debugger;
        const itemId = event.target.dataset.id;
        this.mediaUpdates[itemId] = event.target.value;
    }

    iconClicked(event) {
        const itemId = event.target.dataset.id;
        const clickedName = event.target.name;

        this.lineItems = this.lineItems.map(item => {
            if (item.Id === itemId) {
                return {
                    ...item,
                    onLoadSpare: clickedName === 'spareApprove' ? false : true,
                    SpareOnApprove: clickedName === 'spareApprove' ? true : false,
                    onLoadReject: clickedName === 'spareReject' ? false : true,
                    SpareOnReject: clickedName === 'spareReject' ? true : false,
                    showFeedback: clickedName === 'spareReject' ? true : false
                };
            }
            return item;
        });

        this.lineItems = [...this.lineItems];
    }

    handleFeedbackChange(event) {
        debugger;
        const itemId = event.target.dataset.id;
        const feedbackValue = event.target.value;
    
        this.lineItems = this.lineItems.map(item =>
            item.Id === itemId ? { ...item, feedback: feedbackValue } : item
        );
    
        this.lineItems = [...this.lineItems];
    }
    

    handleAddSupportingMedia() {
        debugger;
        if (Object.keys(this.mediaUpdates).length === 0) {
            this.showToast('Warning', 'No media entered to update!', 'warning');
            return;
        }

        let updates = {};
        let isValid = true;

        this.lineItems.forEach(item => {
            if (this.mediaUpdates[item.Id]) {
                updates[item.Id] = {
                    media: this.mediaUpdates[item.Id],
                    status: item.SpareOnApprove ? 'Approved' : item.SpareOnReject ? 'Rejected' : null,
                    feedback: item.feedback
                };

                if (item.SpareOnReject && (!item.feedback || item.feedback.trim() === '')) {
                    this.showToast('Error', 'Feedback is required for rejected items', 'error');
                    isValid = false;
                }
            }
        });

        if (!isValid) return;

        this.isLoading = true;

        updateSupportingMedia({ mediaUpdates: updates })
            .then(() => {
                this.showToast('Success', 'Supporting Media updated successfully!', 'success');
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to update media', 'error');
                console.error(error);
                this.isLoading = false;
            });
    }


    


    handleExit() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}