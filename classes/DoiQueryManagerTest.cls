/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the DoiQueryManager class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class DoiQueryManagerTest {
	@testSetup static void setup(){
        List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
        List<Subscription_History__c> subHistoryList = DoiTestDataUtility.createSubscriptionHistoryRecords(2);
    }
    
    //This test method is to test the getObjectName() method. 
    @isTest static void getObjectNameTest(){
        //for Lead Object
    	Lead leadObj = [Select Id from Lead LIMIT 1];
        String result1 = DoiQueryManager.getObjectName(leadObj.Id);
        System.assertEquals('Lead', result1);
        
        //for Contact Object
    	Contact conObj = [Select Id from Contact LIMIT 1];
        String result2 = DoiQueryManager.getObjectName(conObj.Id);
        System.assertEquals('Contact', result2);
    }
    
    //This test method is to test the isLeadOrContact() method. 
    @isTest static void isLeadOrContactTest(){
        //for Lead Object
    	Lead leadObj = [Select Id from Lead LIMIT 1];
        Boolean result1 = DoiQueryManager.isLeadOrContact(leadObj.Id);
        System.assertEquals(true, result1);
        
        //for Contact Object
    	Contact conObj = [Select Id from Contact LIMIT 1];
        Boolean result2 = DoiQueryManager.isLeadOrContact(conObj.Id);
        System.assertEquals(true, result2);
        
        //for Other Object
    	Subscription_History__c subObj = [Select Id from Subscription_History__c LIMIT 1];
        Boolean result3 = DoiQueryManager.isLeadOrContact(subObj.Id);
        System.assertEquals(false, result3);
    }
    
    //This test method is to test the getRecords with condition. 
    @isTest static void getRecordsTest(){
    	//for Lead Object
    	Lead leadObj = [Select Id from Lead LIMIT 1];
        String condition = 'Where Id=' +'\''+leadObj.Id+'\'';
        List<SObject> sObjList = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(leadObj.Id),
                                                            new List<String>{'Name'},
                                                            condition);
        System.assertEquals(leadObj.Id, sObjList.get(0).Id);	
        
        //for Lead Object with no condition
        Lead leadObj1 = [Select Id from Lead LIMIT 1];
        List<SObject> sObjList1 = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(leadObj1.Id),
                                                            new List<String>{'Name'},
                                                            '');
        System.assertNotEquals(0, sObjList1.size());
    }
}