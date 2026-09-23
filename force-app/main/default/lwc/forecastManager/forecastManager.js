import { LightningElement, wire } from 'lwc';

import getOpenPipelineOpportunities from
'@salesforce/apex/ForecastManagerController.getOpenPipelineOpportunities';

import setExpectedRevenue from 
'@salesforce/apex/ForecastManagerController.setExpectedRevenue';

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ForecastManager extends LightningElement {

    opportunities = [];
    isLoading = false;
    error;

    @wire(getOpenPipelineOpportunities)
    wiredOpportunities({data, error}){
        if(data){
            this.opportunities = data;
            this.error = undefined;
        }else{
            this.opportunities = [];
            this.error = error;
        }
    }



    async handleSetExpectedRevenue(event){
        
        const selectedOppId = event.target.dataset.id;

        try {
            await setExpectedRevenue({opportunityId: selectedOppId});
            await refreshApex(this.wiredOpportunities);

        }catch(e){
            this.error = e.details?.message || e.message;
            console.log(e.details?.message || e.message);
        }

    }



}