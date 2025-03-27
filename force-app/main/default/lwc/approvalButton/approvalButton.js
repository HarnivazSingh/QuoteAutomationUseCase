import { LightningElement, api, wire } from 'lwc';
import sendApprovalEmail from '@salesforce/apex/ApprovalProcessHandler.sendApprovalEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

export default class ApprovalButton extends LightningElement {
    @api recordId; 

    // Fallback to fetch recordId in case it's not passed automatically
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            this.wiredRecordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        console.log('Record ID from @api:', this.recordId);
        console.log('Record ID from @wire:', this.wiredRecordId);

        // Use whichever recordId is available
        const finalRecordId = this.wiredRecordId;
        
        if (finalRecordId) {
            this.callApexMethod(finalRecordId);
        } else {
            this.showToast('Error', 'Record ID is missing', 'error');
            this.closeQuickAction();
        }
    }

    callApexMethod(recordId) {
        sendApprovalEmail({ recordId })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.closeQuickAction();
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Unknown error', 'error');
                this.closeQuickAction();
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
