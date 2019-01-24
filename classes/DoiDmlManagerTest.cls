/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the DoiDmlManager class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class DoiDmlManagerTest {
	@testSetup static void setup(){
        List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(10);
    }
    
    //This test method is to test the updateRecords() method. 
    @isTest static void processRecordsTest(){
    	Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;        
        Boolean result = DoiDmlManager.processRecords(leadObj, 'Update');
        System.assertEquals(true, result);
        
        //update bulk records
        List<SObject> sObjList = [Select Id from Contact Limit 10];
        List<SObject> sObjListToUpdate = new List<SObject>();
        for(SObject sObj : sObjList){
        	sObj.put('Email_Opt_In__c', true);
            sObjListToUpdate.add(sObj);
        }
        Boolean result2 = DoiDmlManager.processRecords(sObjListToUpdate, 'Update');
        System.assertEquals(true, result2);       
    }
    
    //This test method is to test the createRecords() method. 
    @isTest static void createRecordsTest(){
    	Lead leadObj = new Lead();
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
		leadObj.lastName = 'testr6gh';
		leadObj.company='testCompany';        
        Boolean result = DoiDmlManager.processRecords(leadObj, 'Insert');
        System.assertEquals(true, result);    
    }
}