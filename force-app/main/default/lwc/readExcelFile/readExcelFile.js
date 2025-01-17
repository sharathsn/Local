import { LightningElement, track, api } from 'lwc';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import csvFileRead from '@salesforce/apex/CSVFileReadLWCCntrl.csvFileRead';

const columnsAccount = [
    { label: 'Name', fieldName: 'Name' }, 
    { label: 'Source', fieldName: 'AccountSource' },
    { label: 'Account Site', fieldName: 'Site'}, 
    { label: 'Type', fieldName: 'Type'}, 
    { label: 'Website', fieldName: 'Website', type:'url'}
];

export default class ReadExcelFile extends LightningElement {
    @api recordId;
    @track error;
    @track columnsAccount = columnsAccount;
    @track data;

    // accepted parameters
    get acceptedCSVFormats() {
        return ['.csv'];
    } 
    
    uploadFileHandler(event) {
        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class csvFileread method
        csvFileRead({contentDocumentId : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Accoount Plans are created according to the CSV file upload!!!',
                    variant: 'Success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            alert(error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                   // message: 'Accoount Plans are avilable in data base',
                   message: error.body.message,
                    variant: 'error',
                }),

            );     
        })

    }
}