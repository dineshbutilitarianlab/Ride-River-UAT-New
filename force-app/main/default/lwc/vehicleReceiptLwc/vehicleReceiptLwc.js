import { LightningElement,api,wire,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import generateEInvoice from '@salesforce/apex/ClearTaxApiHelper.generateEInvoice';
import generatePayloadForIRN from '@salesforce/apex/ClearTaxApiHelper.generatePayloadForIRN';
import genereteE_invoicePDF from '@salesforce/apex/ClearTaxApiHelper.genereteE_invoicePDF';
import { updateRecord } from 'lightning/uiRecordApi';
export default class VehicleReceiptLwc extends LightningElement {
    @api recordId;
    error;
    @track pdfUrl;
    @track payloadData;
    @track loading = true;
    @track isSubmitDisabled = false;

    connectedCallback() {
        debugger;
        const url = window.location.href.toString();
            const queryParams = url.split("&");
            const recordIdParam = queryParams.find(param => param.includes("recordId"));

            if (recordIdParam) {
                const recordIdKeyValue = recordIdParam.split("=");
                if (recordIdKeyValue.length === 2) {
                    const recordId = recordIdKeyValue[1];
                    this.recordId = recordId;
                } else {
                    console.error("Invalid recordId parameter format");
                }
            } else {
                console.error("recordId parameter not found in the URL");
            }
        this.validatePayloadData(); 
    }

    handleCancel() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    validatePayloadData(){
        debugger;
        generatePayloadForIRN({orderId : this.recordId}) 
        .then(result => {
            if (result) {
                this.payloadData = JSON.parse(result);
               // this.checkRequiredFields();
                  this.callApexMethod();
            } else {
                this.showToast("Error", "Invalid response from server", "error");
            }
        })
    }

    callApexMethod(){
        debugger;
        generateEInvoice({recordId : this.recordId}) .then(result =>{
            if(result != null){
             this.loading = false;
             this.pdfUrl = `/apex/CreateReceiptVehicle?Id=${this.recordId}`;
            }
        })
        .catch(error =>{
            console.log('Error == >'+this.error);
        })
    }

    handleSave(){
        debugger;
        this.isSubmitDisabled = true;
        genereteE_invoicePDF({recordId : this.recordId}) .then(result =>{
            if(result && result == 'success'){
                updateRecord({ fields: { Id: this.recordId }})
                this.showToast('Success', 'Invoice generated successfully', 'success');
            }else{
                this.showToast('Error', result, 'error');
            }
        })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, 
        });
        setTimeout(() => {
            this.dispatchEvent(event);
            this.handleCancel();
        }, 2000);
    }

    checkRequiredFields() {
        debugger;
        let missingFields = [];
        // Checking Transaction Details
        if (!this.payloadData.TranDtls?.TaxSch) missingFields.push("Tax Scheme");
        if (!this.payloadData.TranDtls?.SupTyp) missingFields.push("Supply Type");
        if (typeof this.payloadData.TranDtls?.IgstOnIntra === "undefined") missingFields.push("IGST on Intrastate");

        // Checking Document Details
        if (!this.payloadData.DocDtls?.Typ) missingFields.push("Document Type");
        if (!this.payloadData.DocDtls?.No) missingFields.push("Document Number");

        // Checking Seller Details
        if (!this.payloadData.SellerDtls?.Gstin) missingFields.push("Seller GSTIN");
        if (!this.payloadData.SellerDtls?.LglNm) missingFields.push("Seller Legal Name");
        if (!this.payloadData.SellerDtls?.Addr1) missingFields.push("Seller Address");

        // Checking Buyer Details
        if (!this.payloadData.BuyerDtls?.Gstin) missingFields.push("Buyer GSTIN");
        if (!this.payloadData.BuyerDtls?.LglNm) missingFields.push("Buyer Legal Name");
        if (!this.payloadData.BuyerDtls?.Addr1) missingFields.push("Buyer Address");

        // Checking Item List
        if (!this.payloadData.ItemList || this.payloadData.ItemList.length === 0) {
            missingFields.push("Item List");
        } else {
            this.payloadData.ItemList.forEach((item, index) => {
                if (!item.PrdDesc) missingFields.push(`Product Description (Item ${index + 1})`);
                if (!item.HsnCd) missingFields.push(`HSN Code (Item ${index + 1})`);
                if (!item.Qty) missingFields.push(`Quantity (Item ${index + 1})`);
            });
        }

        // Checking Value Details
        if (!this.payloadData.ValDtls?.AssVal) missingFields.push("Invoice Taxable Value");

        // Show toast if any required fields are missing
        if (missingFields.length > 0) {
            this.showToast(
                "Missing Required Fields",
                `Please fill the following fields before generating e-Invoice: ${missingFields.join(', ')}`,
                "error"
            );
        } else {
            this.callApexMethod();
           // this.showToast("Success", "All required fields are filled. You can proceed!", "success");
        }
    }
    
}