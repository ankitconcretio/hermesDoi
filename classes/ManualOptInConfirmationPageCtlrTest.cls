/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the ManualOptInConfirmationPageCtlr class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ManualOptInConfirmationPageCtlrTest {

    @testSetup static void setup(){
      	List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
    }
    
    //This test method is to test the confirmSubscription() method. 
    @isTest static void confirmSubscriptionTest(){
    	String inputValues;
        
        //for success condition with only Email Opt In.
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = false;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        inputValues = '{"recordId":"'+leadObj.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":false,"postOption":false,"generalOptOption":false}';
        Integer result = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(0, result);
        
        //for success condition with only Tel Opt In.
        Lead leadObj1 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj1.Email_Opt_In__c = false;
        leadObj1.Double_Opt_In__c = false;
        leadObj1.HasOptedOutOfEmail = false;
        leadObj1.Tel_Opt_In__c = false;
        update leadObj1;
        inputValues = '{"recordId":"'+leadObj1.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":true,"postOption":false,"generalOptOption":false}';
        Integer result1 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(5, result1);
        
        //for success condition with only Post Opt In.
        Lead leadObj2 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj2.Email_Opt_In__c = false;
        leadObj2.Double_Opt_In__c = false;
        leadObj2.HasOptedOutOfEmail = false;
        leadObj2.Postal_Opt_In__c = false;
        update leadObj1;
        inputValues = '{"recordId":"'+leadObj2.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":true,"generalOptOption":false}';
        Integer result2 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(6, result2);
        
        //for success condition with Tel & Post Opt In.
        Contact conObj1 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Contact LIMIT 1];
        conObj1.Email_Opt_In__c = false;
        conObj1.Double_Opt_In__c = false;
        conObj1.HasOptedOutOfEmail = false;
        conObj1.Postal_Opt_In__c = false;
        conObj1.Tel_Opt_In__c = false;
        update conObj1;
        inputValues = '{"recordId":"'+conObj1.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":true,"postOption":true,"generalOptOption":false}';
        Integer result3 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(4, result3);
        
        //for success condition with Email & Post Opt In.
        Contact conObj2 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Contact LIMIT 1];
        conObj2.Email_Opt_In__c = false;
        conObj2.Double_Opt_In__c = false;
        conObj2.HasOptedOutOfEmail = false;
        conObj2.Postal_Opt_In__c = false;
        update conObj2;
        inputValues = '{"recordId":"'+conObj2.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":false,"postOption":true,"generalOptOption":false}';
        Integer result4 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(7, result4);
        
        //for success condition with Email & Tel Opt In.
        Contact conObj3 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Contact LIMIT 1];
        conObj3.Email_Opt_In__c = false;
        conObj3.Double_Opt_In__c = false;
        conObj3.HasOptedOutOfEmail = false;
        conObj3.Tel_Opt_In__c = false;
        update conObj3;
        inputValues = '{"recordId":"'+conObj3.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":false,"generalOptOption":false}';
        Integer result5 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(8, result5);
        
        //for success condition with General Opt Out.
        Lead leadObj3 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj3.Email_Opt_In__c = true;
        leadObj3.Double_Opt_In__c = false;
        leadObj3.HasOptedOutOfEmail = false;
        leadObj3.Opt_Out__c = false;
        update leadObj3;
        inputValues = '{"recordId":"'+leadObj3.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false,"generalOptOption":true}';
        Integer result6 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(3, result6);
        
        //for success condition with Email & Post & Tel Opt In
        Lead leadObj4 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj4.Email_Opt_In__c = false;
        leadObj4.Double_Opt_In__c = false;
        leadObj4.Tel_Opt_In__c = false;
        leadObj4.Postal_Opt_In__c = false;
        update leadObj4;
        inputValues = '{"recordId":"'+leadObj4.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":true,"generalOptOption":false}';
        Integer result7 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(9, result7);
        
        //for wrong lead Id
        Lead leadObj5 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj5.Email_Opt_In__c = false;
        leadObj5.Double_Opt_In__c = false;
        leadObj5.Tel_Opt_In__c = false;
        leadObj5.Postal_Opt_In__c = false;
        update leadObj5;
        inputValues = '{"recordId":"00Q23456sdfbn","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":true,"generalOptOption":false}';
        Integer result8 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(1, result8);
        
        //for update fail condition (ip address blank).
        Contact conObj4 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Contact LIMIT 1];
        conObj4.Email_Opt_In__c = false;
        conObj4.Double_Opt_In__c = false;
        conObj4.HasOptedOutOfEmail = false;
        conObj4.Tel_Opt_In__c = false;
        update conObj3;
        inputValues = '{"recordId":"'+conObj4.Id+'","currentPageName":"ConfirmSubscription","ipAddress":"",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":false,"generalOptOption":false}';
        Integer result9 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(2, result9);
        
        //for blank lead Id
        Lead leadObj6 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c,
                        Manual_Opt_In__c, Tel_Opt_In__c, Postal_Opt_In__c from Lead LIMIT 1];
        leadObj6.Email_Opt_In__c = false;
        leadObj6.Double_Opt_In__c = false;
        leadObj6.Tel_Opt_In__c = false;
        leadObj6.Postal_Opt_In__c = false;
        update leadObj6;
        inputValues = '{"recordId":"","currentPageName":"ConfirmSubscription","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":true,"generalOptOption":false}';
        Integer result10 = ManualOptInConfirmationPageCtlr.confirmSubscription(inputValues);
        System.assertEquals(1, result10);
    }
    
    //This test method is to test the constructor of the ReSubscribeEmailCtlr(controller of vf page)
    @isTest static void pageTest(){
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = false;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = true;
        update leadObj;
        PageReference pageRef = Page.ManualOptInConfirmationPage;
  		pageRef.getParameters().put('id', String.valueOf(leadObj.Id));
  		Test.setCurrentPage(pageRef);
        
        ManualOptInConfirmationPageCtlr ob = new ManualOptInConfirmationPageCtlr();
    }
}