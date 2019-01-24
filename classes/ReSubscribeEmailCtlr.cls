/*
* @purpose: This is the controller class of ReSubscribeEmail(Vf page) in which Object is verified using record Id(fetched from URL) and email inserted by user. Then on the
the basis of record Id and email Id verifying the identity of user and then update the Email Opt In field on click of Submit button.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (20-04-2018)          | Cloud Consulting Group GmbH  | initial version
*/

public class ReSubscribeEmailCtlr {
    public String recordId {get;set;}
    public String leadSource {get;set;}
    public String ipAddress {get;set;}
    public String currentPageName {get;set;}
    public String salutation {set;get;}
    public Boolean postalOptIn {get;set;}
    public Boolean telephoneOptIn {get;set;}
    public Boolean emailOptIn {get;set;}
    public Boolean generalOptOut {get;set;}
    
    public ReSubscribeEmailCtlr(){
        List<SObject> sObjList = new List<SObject>();
        String recievedId = '';
        //fetch record Id from page URL.
        recievedId = ApexPages.currentPage().getParameters().get('id');
        ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if(String.isBlank(ipAddress)){
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');    
        }       
        currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        
        if(String.isNotBlank(recievedId)){
            //verify whether object is Lead or not, if object is Lead then check lead isConverted or not.
            try{
                recordId = DoiHelper.isConvertedLead(recievedId);
            }
            catch(Exception e){
                System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
        }
        
        if(String.isNotBlank(recordId)){
            //get sObjectInstance from DoiHelper
            try{
                if(DoiQueryManager.isLeadOrContact(recordId)){
                    String condition = 'WHERE Id=' +'\''+recordId+'\'';
                    sObjList = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(recordId),
                                                          new List<String>{'LeadSource','Postal_Opt_In__c','Tel_Opt_In__c','EMail_Opt_In__c',
                                                              'Opt_Out__c','Salutation_Mktg_EN__c'},
                                                          condition);	    
                }
            }
            catch(Exception e){
                System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
            if(sObjList.size() == 1){
                Sobject sObj = sObjList.get(0);
                //set the properties of this class.
                leadSource = String.valueOf(sObj.get('LeadSource'));
                postalOptIn = Boolean.valueOf(sObj.get('Postal_Opt_In__c'));
                telephoneOptIn = Boolean.valueOf(sObj.get('Tel_Opt_In__c'));
                emailOptIn = Boolean.valueOf(sObj.get('EMail_Opt_In__c'));
                generalOptOut = Boolean.valueOf(sObj.get('Opt_Out__c'));
                salutation = String.valueOf(sObj.get('Salutation_Mktg_EN__c'));
            }
        }  
    }
    
    /**
	 * @name   : resubscribeEmail 
	 * @params : reSubscribeVal   : This string type varibale holds the javascript object which contains all values obtained on vf page.
	 * @description : This method verify subscriber using email Id and record Id, then update the fields related to Re-Subscribe.
	 * @returnType : Integer : (0 => Success with Email Opt In), (1 => Record not found), (2 => Email not found),
	 * 						   (3 => Update Failed), (4 => Email is Blank), (5 => Success with General Opt Out), (6 => Success with both Tel & Post Opt In),
	 * 						   (7 => Success with only Tel opt in), (8 => Success with only post opt in)
	**/
    @RemoteAction
    public static Integer resubscribeEmail(String reSubscribeVal){
        System.debug('reSubscribeVal>> '+ reSubscribeVal);
        Map<String, Object> mapReSubscribeVal = (Map<String, Object>) JSON.deserializeUntyped(reSubscribeVal);
        String recordId = String.valueOf(mapReSubscribeVal.get('recordId'));
        String currentPageName = String.valueOf(mapReSubscribeVal.get('currentPageName'));
        String ipAddress = String.valueOf(mapReSubscribeVal.get('ipAddress'));
        String emailId = String.valueOf(mapReSubscribeVal.get('emailId'));
        
        List<SObject> sObjectList = new List<SObject>();
        Id templateId;
        Boolean isEmailOptIn, isTelephoneOption, isPostOption , emailStatus = false;
        String emailFromRecordID = '', sObjectName = '';
        Integer response = 0;
        
        Map<String, Boolean> OptValues = new Map<String, Boolean>();
        OptValues.put('emailOption', Boolean.valueOf(mapReSubscribeVal.get('emailOption')));
        OptValues.put('telephoneOption', Boolean.valueOf(mapReSubscribeVal.get('telephoneOption')));
        OptValues.put('postOption', Boolean.valueOf(mapReSubscribeVal.get('postOption')));
        OptValues.put('generalOptOut', Boolean.valueOf(mapReSubscribeVal.get('generalOptOption')));
        
        if(String.isNotBlank(recordId) && String.isNotBlank(emailId)){
            //get sObjectInstance from DoiHelper
            try{
                if(DoiQueryManager.isLeadOrContact(recordId)){
                    String condition = 'WHERE Id=' +'\''+recordId+'\'';
                    sObjectList = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(recordId),
                                                             new List<String>{'Email_Opt_In__c', 'Email','Tel_Opt_In__c','Opt_Out__c',
                                                                 'Postal_Opt_In__c','HasOptedOutOfEmail','Manual_Opt_In__c','Double_Opt_In__c'},
                                                             condition);	    
                }
            }
            catch(Exception e){
                System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
            if(sObjectList.isEmpty()){
                response = 1;
            }
            else if(sObjectList.size() == 1){
                Sobject sObj = sObjectList.get(0);
                System.debug('sObj'+sObj);
                emailFromRecordID = String.valueOf(sObj.get('Email'));
                isEmailOptIn = Boolean.valueOf(sObj.get('Email_Opt_In__c'));
                isTelephoneOption =  Boolean.valueOf(sObj.get('Tel_Opt_In__c'));
                isPostOption =  Boolean.valueOf(sObj.get('Postal_Opt_In__c'));
                
                System.debug('emailFromRecordID='+emailFromRecordID);
                //check email entered by user matched with email fethed by record id or not.
                if(String.isNotBlank(emailFromRecordID) && emailId.equalsIgnoreCase(emailFromRecordID)){
                    if(String.isBlank(currentPageName) || String.isBlank(ipAddress)){
                        response = 3;    
                    }
                    else{
                        try{
                            Boolean result = DoiDmlManager.processRecords(setReSubscribeValues(sObj, OptValues), 'Update');
                            if(result == true){
                                Boolean SubHistoryResult = setTypeAndCreateRecord(OptValues, recordId, currentPageName, ipAddress);    
                            }
                            else{
                                response = 3;        
                            }
                        }
                        catch(Exception e){
                            System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
                            response = 3;
                        }
                        if(OptValues.get('generalOptOut') == true){
                            response = 5;    
                        }
                        else if(OptValues.get('emailOption') == false && OptValues.get('telephoneOption') == true && OptValues.get('postOption') == true){
                            response = 6;    
                        }
                        else if(OptValues.get('emailOption') == false && OptValues.get('telephoneOption') == true){
                            response = 7;    
                        }
                        else if(OptValues.get('emailOption') == false && OptValues.get('postOption') == true){
                            response = 8;    
                        }
                    }
                }
                else{
                    response = 1;
                }
            }
        }
        else if(String.isBlank(emailId)){
            response = 2;    
        }
        else{
            response = 4;
        }
        return response;
    }
    
    /**
    * @description This method set type & create Subscription History Records.
    * @param OptValues, contains the resubscription values.
    * @param recordId, contains the record id on which this object will be created.
    * @param pageName, contains the name of vf page.
    * @param ipAddress, contains ip address where vf page was accessed
    * @return Boolean, true if record is created successfully.
    */
    private static Boolean setTypeAndCreateRecord(Map<String,Boolean> OptValues, String recordId, String pageName, String ipAddress){
        Boolean response = true;
        List<String> types = new List<String>();
        try{
            if(OptValues.get('emailOption') == true && OptValues.get('generalOptOut') == false){
                types.add('Email Opt In'); 
            }
            if(OptValues.get('telephoneOption') == true && OptValues.get('generalOptOut') == false){
                types.add('Tel Opt In');
            }
            if(OptValues.get('postOption') == true && OptValues.get('generalOptOut') == false){
                types.add('Postal Opt In'); 
            }
            if(OptValues.get('generalOptOut') == true){
                types.add('General Opt Out');   
            }
            if(types.size() > 0){
            	response = SubscriptionHistoryService.createRecords(types, recordId, pageName, ipAddress);    
            }
        }
        catch(Exception e){
            System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
            throw new DoiException(e);
        }
        return response;
    }
    
    /**
    * @description This method set Resubscription values to sObject.
    * @param sObj, contains the sObject whose values to be updated.
    * @param OptValues, contains the map of values for resubscription.
    * @return SObject, sObject with new values which will be updated.
    */
    private static SObject setReSubscribeValues(SObject sObj, Map<String,Boolean> OptValues){
        sObj.put('Opt_Out__c', OptValues.get('generalOptOut'));
        if(OptValues.get('emailOption') == true){
            sObj.put('HasOptedOutOfEmail', false);
            sObj.put('Email_Opt_In__c', true);
        }
        if(OptValues.get('telephoneOption') == true){
            sObj.put('Tel_Opt_In__c', true);     
        }
        if(OptValues.get('postOption') == true){
            sObj.put('Postal_Opt_In__c', true);     
        }
        if((Boolean.valueOf(sObj.get('HasOptedOutOfEmail')) == true && Boolean.valueOf(sObj.get('Postal_Opt_In__c')) == false && Boolean.valueOf(sObj.get('Tel_Opt_In__c')) == false) || OptValues.get('generalOptOut') == true){
            sObj.put('Opt_Out__c', true);
            sObj.put('Double_Opt_In__c', false);
        }
        sObj.put('Manual_Opt_In__c', true);
        return sObj;    
    }
}