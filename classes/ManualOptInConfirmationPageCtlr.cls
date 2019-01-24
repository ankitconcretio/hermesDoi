/*
* @purpose: This is the controller class of ManualOptInConfirmationPage(Vf page) in which Object is verified using record Id(fetched from URL),
* 			then on the the basis of record Id verifying the identity of user and then performs subscription process on the click of confirmation button.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (10-09-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class ManualOptInConfirmationPageCtlr {
	public String recordId {get;set;}
    public String ipAddress {get;set;}
    public String currentPageName {get;set;}
    public String salutation {set;get;}
    public Boolean postalOptIn {get;set;}
    public Boolean telephoneOptIn {get;set;}
    public Boolean emailOptIn {get;set;}
    public Boolean generalOptOut {get;set;}
    
    public ManualOptInConfirmationPageCtlr(){
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
                postalOptIn = Boolean.valueOf(sObj.get('Postal_Opt_In__c'));
                telephoneOptIn = Boolean.valueOf(sObj.get('Tel_Opt_In__c'));
                emailOptIn = Boolean.valueOf(sObj.get('EMail_Opt_In__c'));
                generalOptOut = Boolean.valueOf(sObj.get('Opt_Out__c'));
                salutation = String.valueOf(sObj.get('Salutation_Mktg_EN__c'));
            }
        }  
    }
    
    /**
	 * @name   : confirmSubscription 
	 * @params : confirmationVal   : This string type varibale holds the javascript object which contains all values obtained on vf page.
	 * @description : This method verify subscriber using record Id, then update the fields related to confirmation process.
	 * @returnType : Integer : (0 => Success with Only Email Opt In), (1 => Record not found), (2 => Update Failed),
	 * 						   (3 => Success with General Opt Out), (4 => Success with both Tel & Post Opt In),
	 * 						   (5 => Success with only Tel opt in), (6 => Success with only post opt in),
	 * 						   (7 => Success with email & post opt in), (8 => Success with email & tel opt in), (9 => Success with all three)
	**/
    @RemoteAction
    public static Integer confirmSubscription(String confirmationVal){
        System.debug('confirmationVal>> '+ confirmationVal);
        Map<String, Object> mapConfirmationVal = (Map<String, Object>) JSON.deserializeUntyped(confirmationVal);
        String recordId = String.valueOf(mapConfirmationVal.get('recordId'));
        String currentPageName = String.valueOf(mapConfirmationVal.get('currentPageName'));
        String ipAddress = String.valueOf(mapConfirmationVal.get('ipAddress'));
        
        Map<String, Boolean> OptValues = new Map<String, Boolean>();
        OptValues.put('emailOption', Boolean.valueOf(mapConfirmationVal.get('emailOption')));
        OptValues.put('telephoneOption', Boolean.valueOf(mapConfirmationVal.get('telephoneOption')));
        OptValues.put('postOption', Boolean.valueOf(mapConfirmationVal.get('postOption')));
        OptValues.put('generalOptOut', Boolean.valueOf(mapConfirmationVal.get('generalOptOption')));
        List<SObject> sObjectList = new List<SObject>();
        
        Integer response = 0;

        if(String.isNotBlank(recordId)){
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
                
                if(String.isBlank(currentPageName) || String.isBlank(ipAddress)){
                    response = 2;    
                }
                else{
                    try{
                        Boolean result = DoiDmlManager.processRecords(setConfirmationValues(sObj, OptValues), 'Update');
                        if(result == true){
                            Boolean SubHistoryResult = setTypeAndCreateRecords(OptValues, recordId, currentPageName, ipAddress);    
                        }
                        else{
                            response = 2;        
                        }
                    }
                    catch(Exception e){
                        System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
                        response = 2;
                    }
                    if(OptValues.get('generalOptOut') == true){
                        response = 3;    
                    }
                    else if(OptValues.get('emailOption') == false && OptValues.get('telephoneOption') == true && OptValues.get('postOption') == true){
                        response = 4;    
                    }
                    else if(OptValues.get('emailOption') == false && OptValues.get('telephoneOption') == true){
                        response = 5;    
                    }
                    else if(OptValues.get('emailOption') == false && OptValues.get('postOption') == true){
                        response = 6;    
                    }
                    else if(OptValues.get('emailOption') == true && OptValues.get('postOption') == true && OptValues.get('telephoneOption') == true){
                        response = 9;    
                    }
                    else if(OptValues.get('emailOption') == true && OptValues.get('postOption') == true && OptValues.get('telephoneOption') == false){
                        response = 7;    
                    }
                    else if(OptValues.get('emailOption') == true && OptValues.get('postOption') == false && OptValues.get('telephoneOption') == true){
                        response = 8;    
                    }
                }
            }
        }
        else{
            response = 1;
        }
        return response;
    }
    
    /**
    * @description This method set Confirmation values to sObject.
    * @param sObj, contains the sObject whose values to be updated.
    * @param OptValues, contains the map of values for confirmation.
    * @return SObject, sObject with new values which will be updated.
    */
    public static SObject setConfirmationValues(SObject sObj, Map<String,Boolean> OptValues){
        sObj.put('Opt_Out__c', OptValues.get('generalOptOut'));
        if(OptValues.get('emailOption') == true){
            sObj.put('HasOptedOutOfEmail', false);
            sObj.put('Email_Opt_In__c', true);
            sObj.put('Double_Opt_In__c', true);
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
    
    /**
    * @description This method set type & create Subscription History Records.
    * @param OptValues, contains the confirmation values.
    * @param recordId, contains the record id on which this object will be created.
    * @param pageName, contains the name of vf page.
    * @param ipAddress, contains ip address where vf page was accessed
    * @return Boolean, true if records are created successfully.
    */
    public static Boolean setTypeAndCreateRecords(Map<String,Boolean> OptValues, String recordId, String pageName, String ipAddress){
        Boolean response = true;
        List<String> types = new List<String>();
        try{
            if(OptValues.get('emailOption') == true && OptValues.get('generalOptOut') == false){
                types.add('Email Opt In');
                types.add('Double Opt In');	    
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
}