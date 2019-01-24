/*
* @purpose: This is the helper method for UpdateSubscriptionHistoryOnLeadConversion(trigger) & it updates the subscription history record when Lead is Converted. 
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (11-05-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class UpdateSubscriptionHistoryHlpr {
    public static void updateSubscriptionHistory(List<Lead> leadList){
        List<Subscription_History__c> subscriptionHistoryListToUpdate = new List<Subscription_History__c>();
        Map<Id,Id> mapConvertedLeadToContact = new Map<Id,Id>();
        
        //iterate list of updatedLead & if lead is converted map lead Id to converted contact Id.
        for(Lead leadObj : leadList){
            if(leadObj.isConverted){
            	 mapConvertedLeadToContact.put(leadObj.Id, leadObj.ConvertedContactId);  
            }    
        }
        
        //get SubscriptionHistory records related to the LeadId's which are converted to contact.
        if(mapConvertedLeadToContact.size() > 0){
            for(Subscription_History__c subHistoryObj: [Select Id, Lead__c, Contact__c from Subscription_History__c where Lead__c In : mapConvertedLeadToContact.keySet() LIMIT 50000]){
            	subHistoryObj.Contact__c = 	 mapConvertedLeadToContact.get(subHistoryObj.Lead__c);
                subscriptionHistoryListToUpdate.add(subHistoryObj);
            }
            
            //check whether any records to Update or not.
            if(subscriptionHistoryListToUpdate.size() > 0){
                try{
                    update subscriptionHistoryListToUpdate;    
                }
                catch(Exception e){
                    System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
                }
                
            }
        }        
    }	
}