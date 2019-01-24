/*
* @purpose: This trigger will fire when Lead is Updated & if Lead is converted then subscription history related to the Lead will be updated to
*			converted contact.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (11-05-2018)          | Cloud Consulting Group GmbH  | initial version
*/
trigger UpdateSubscriptionHistoryOnLeadConversion on Lead (after update) {
	if(Trigger.isAfter && Trigger.isUpdate){
    	UpdateSubscriptionHistoryHlpr.updateSubscriptionHistory(Trigger.New);			    
    }
}