/**
 * @author Dinesh Baddawar
 * @email dinesh.butilitarianlab@gmail.com
 * @create date 2024-12-10 11:00:42
 * @modify date 2024-12-20 20:38:52
 * @desc [Component to update Receive GRN]
 */

import getPOrelatedPLI from '@salesforce/apex/ProductRequestLineController.getPOrelatedPLI';
import getShipmentDetail from '@salesforce/apex/ProductRequestLineController.getShipmentDetail';
import { CurrentPageReference } from 'lightning/navigation';

import createDiscrepancyAndLineitem from '@salesforce/apex/ProductRequestLineController.createDiscrepancyAndLineitem';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';
export default class BulkrecieveGRN extends LightningElement {
    @api recordId;
    @track requestLineItems = [];
    @track updatedValues = {};
    @track selectAllChecked = false;
    showSpinner = false;
    ShowGRNDone = false;
    secondScreen = false;
    connectedCallback() {
        debugger;
        let url = window.location.href.toString();
        let id = url.split('/').slice(-2, -1)[0];
        this.recordId = id;

        this.getShipmentDetailApex();
    }


    @wire(CurrentPageReference)
    getCurrentPageReference(currentPageReference) {
        debugger;
        if (currentPageReference) {
            if (currentPageReference.attributes.recordId != undefined) {
                this.recordId = currentPageReference.attributes.recordId;
            }
        }
    }

    getShipmentDetailApex() {
        debugger;
        getShipmentDetail({ recordId: this.recordId }).then(result => {
            if (result != null) {
                if (result.Status == 'Delivered') {
                    this.ShowGRNDone = true;
                } else {
                    this.ShowGRNDone = false;
                    this.CallDetailsMethod();
                }
            }
        })
    }

    CallDetailsMethod() {
        debugger;
        getPOrelatedPLI({ recordId: this.recordId }).then(data => {
            if (data) {
                debugger;
                this.requestLineItems = data.map((res) => ({
                    Id: res.Id,
                    Name: res.Product2?.Name,
                    ProductName: res.Product2?.Name || 'N/A',
                    PartName: res.Product2?.ProductCode || 'N/A',
                    Product2Id: res.Product2?.Id || null,
                    QuantityRequested: res.Quantity,
                    ShipmentId: res.ShipmentId,
                    DestinationLocationId: res.Shipment.DestinationLocationId,
                    SourceLocationId: res.Shipment.SourceLocationId,
                    RecievedQuantity: res.Received_Quantity__c,
                    selected: false,
                    isChargesDisabled: true,
                }));
                this.showSpinner = false;
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.requestLineItems = [];
                console.error('Error fetching product request items == >', error);
            }
        })
    }

    // @wire(getPOrelatedPLI, { recordId: '$recordId' })
    // wiredProductRequestItems({ error, data }) {
    //     if (data) {
    //         debugger;
    //         this.requestLineItems = data.map((res) => ({
    //             Id: res.Id,
    //             Name: res.Product2?.Name,
    //             ProductName: res.Product2?.Name || 'N/A',
    //             Product2Id: res.Product2?.Id || null,
    //             QuantityRequested: res.Quantity,
    //             ShipmentId: res.ShipmentId,
    //             DestinationLocationId : res.Shipment.DestinationLocationId,
    //             SourceLocationId : res.Shipment.SourceLocationId,
    //             RecievedQuantity : res.Received_Quantity__c,
    //             selected: false,
    //             isChargesDisabled: true,
    //         }));
    //         this.showSpinner = false;
    //         this.error = undefined;
    //     } else if (error) {
    //         this.error = error;
    //         this.requestLineItems = [];
    //         console.error('Error fetching product request items == >', error);
    //      }
    //  }

    handleInputChange(event) {
        debugger;
        const rowId = event.target.dataset.id;
        const fieldName = event.target.name;
        const updatedValue = event.target.value;

        if (!this.updatedValues[rowId]) {
            this.updatedValues[rowId] = {
                Id: null,
                receivedQuantity: null,
                MIT: null,
                DIT: null,
                WP: null
            };
        }
        this.updatedValues[rowId][fieldName] = updatedValue;
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSelectAll(event) {
        debugger;
        const isChecked = event.target.checked;
        this.selectAllChecked = isChecked;
        this.requestLineItems = this.requestLineItems.map(item => ({
            ...item,
            selected: isChecked,
            isChargesDisabled: !isChecked
        }));
    }

    handleCheckboxChange(event) {
        debugger;
        const itemId = event.target.dataset.id;
        const isChecked = event.target.checked;
        this.requestLineItems = this.requestLineItems.map(item => {
            if (item.Id === itemId) {
                return {
                    ...item,
                    selected: isChecked,
                    isChargesDisabled: !isChecked
                };
            }
            return item;
        });
        this.selectAllChecked = this.requestLineItems.every(item => item.selected);
    }

    handleUpdateProcess() {
        debugger;
        createDiscrepancyAndLineitem({ updatedItems : JSON.stringify(this.updatedValues) })
            .then((result) => {
                if (result === 'SUCCESS') {
                    debugger;
                    this.showSpinner = false;
                    this.secondScreen = true;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Records updated successfully',
                            variant: 'success'
                        })
                    );

                    this.updatedValues = {};

                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error updating records: ' + result,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error updating records: ' + error.body.message,
                        variant: 'error'
                    })
                );
                console.error('Error updating records:', error);
            });
    }

}