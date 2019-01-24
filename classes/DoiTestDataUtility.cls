/*
* @purpose: This class provides test data to test classes.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (03-05-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class DoiTestDataUtility {
    public static List<Lead> createLeads(Integer leadsToCreate){
    	List<Lead> leadList = new List<Lead>();
        for(Integer i=0; i< leadsToCreate; i++){
        	leadList.add(new Lead(LastName='test'+i, Email='test'+i+'@test.com', Company='testCompany'+i, LeadSource='Web', Email_Opt_In__c=false, Double_Opt_In__c=false, Opt_Out__c=false));		    
        }        
        if(leadList.size() > 0){
        	insert leadList;    
        }
        return leadList;
    }
    
    public static List<Contact> createContacts(Integer contactsToCreate){
    	List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i< contactsToCreate; i++){
        	contactList.add(new Contact(LastName='testHello'+i, Email='testqwerty'+i+'@test.com', LeadSource='Web', Email_Opt_In__c=false, Double_Opt_In__c=false, Opt_Out__c=false));		    
        }        
        if(contactList.size() > 0){
        	insert contactList;    
        }
        return contactList;
    }
    
    public static List<Subscription_History__c> createSubscriptionHistoryRecords(Integer recordsToCreate){
    	List<Subscription_History__c> subHistoryList = new List<Subscription_History__c>();
        for(Integer i=0; i< recordsToCreate; i++){
        	subHistoryList.add(new Subscription_History__c(DateTime__c = datetime.now(), Type__c = 'Email Opt In'));		    
        }        
        if(subHistoryList.size() > 0){
        	insert subHistoryList;    
        }
        return subHistoryList;
    }
}