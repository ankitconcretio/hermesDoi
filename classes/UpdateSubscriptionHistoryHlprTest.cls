@isTest
public class UpdateSubscriptionHistoryHlprTest {
	@testSetup static void setup(){
      	List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
        List<Subscription_History__c> subHistoryList = DoiTestDataUtility.createSubscriptionHistoryRecords(100);
    }
    
    //This test method is to test the resubscribeEmail() method. 
    @isTest static void updateSubscriptionHistoryTest(){
        List<Lead> lstLead = new List<Lead>();
    	Lead leadObj = [Select Id, isConverted from Lead LIMIT 1];
        
        List<Subscription_History__c> subHistoryList = new List<Subscription_History__c>();
        for(Subscription_History__c subHistoryObj : [Select Id, Lead__c from Subscription_History__c]){
        	subHistoryObj.Lead__c = leadObj.Id;	 
            subHistoryList.add(subHistoryObj);
        }
        update subHistoryList;
        
        Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(leadObj.id);
		lc.setDoNotCreateOpportunity(true);
		LeadStatus Leads= [SELECT Id, MasterLabel, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(Leads.ApiName);
		Database.LeadConvertResult lcr = Database.convertLead(lc);
        lstLead.add(leadObj);
        System.assert(lcr.isSuccess());
        UpdateSubscriptionHistoryHlpr.updateSubscriptionHistory(lstLead);
    }
}