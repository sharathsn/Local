import { LightningElement, api, wire } from 'lwc';
import getRelatedRecords from '@salesforce/apex/Lilly_AccountSurveyRecordsController.getRelatedRecords';
import sendEmail from '@salesforce/apex/Lilly_AccountSurveyRecordsController.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LillyAccountSurveyRelatedRecord extends LightningElement {
    @api recordId;
    relatedRecords;
    error;

    @wire(getRelatedRecords, { parentId: '$recordId' })
    wiredRecords({ error, data }) {
        if (data) {
            this.relatedRecords = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.relatedRecords = undefined;
        }
    }

    handleSendEmail(event) {
        const childRecordId = event.target.dataset.recordId;
        sendEmail({ recordId: childRecordId, parentId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email sent successfully.',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error sending email',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
}