/*****************************************************************************
Author : MST Solutions
Date : 03/25/2016
Description :This VolunteerInterviewTask_AC is used to authorize the support user and verifying the records
Modification Log: 
23/03/2018 - Kanagaraj
******************************************************************************/
//This class is run the logic by using Salesforce Support user
global class VolunteerInterviewTask_AC {
    public static String auth{get;set;}
    public static String accessToken;
    Public static Support_User_Access__mdt sfSupport = [SELECT Id, URL__c, Username__c, Password__c, Client_Secret__c, Grant_Type__c FROM Support_User_Access__mdt LIMIT 50000];
    
    //Used to retrive the token
    Public Static String authorizeWebServiceCallout() {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        Map<String, Object> responseMap = new Map<String, Object>();
        auth = 'grant_type=password&client_id='+sfSupport.Grant_Type__c+'&client_secret='+sfSupport.Client_Secret__c+'&username='+sfSupport.Username__c+'&password='+sfSupport.Password__c;
        req.setEndpoint(sfSupport.URL__c+'/services/oauth2/token?'+auth);
        req.setMethod('POST');
        try {
            if((!Test.isRunningTest())) {
                res = http.send(req);
            }
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getbody());
            return string.valueof(responseMap.get('access_token'));
        }
        catch(Exception e) {
            return NULL;
        }
    }
    
    //Used to verify the class offering records
    global static string getClassOfferingRecList(String contactId) {
        
        if(!Test.isRunningTest()){        
            accessToken = AuthorizeWebServiceCallout();
        }
        if(accessToken != NULL){
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(sfSupport.URL__c+'/services/apexrest/orientation/'+contactId);
            req.setMethod('GET');
            req.setHeader('Authorization','OAuth '+accessToken);
            try {
                res = http.send(req);
                system.debug('RRRRes : ' + res.getBody());
                return res.getBody();
            } catch(Exception e) {
                System.debug('Callout Error:'+ e.getMessage());
                return 'Error while retriving records :'+e.getMessage();
            }
        } else {
            return 'No Access Token Retrived';
        }
    }  
    
    //Used to verify whethere there is any other volunteer review task is created for the day
    global static string getUploadReviewTask(String contactId){
        if(!Test.isRunningTest()){        
            accessToken = AuthorizeWebServiceCallout();
        }
        if(accessToken != NULL){
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(sfSupport.URL__c+'/services/apexrest/uploadTask/'+contactId);
            req.setMethod('GET');
            req.setHeader('Authorization','OAuth '+accessToken);
            try {
                res = http.send(req);
                system.debug('RRRRes : ' + res.getBody());
                return res.getBody();
            } catch(Exception e) {
                System.debug('Callout Error:'+ e.getMessage());
                return 'Error while retriving records :'+e.getMessage();
            }
        } else {
            return 'No Access Token Retrived';
        }
    }  
    
    
    //This class is used to recall the approval process by using Salesforce Support User.
    global static String getApprovalRecal(String volOppIsString) {
        if(!Test.isRunningTest()) {        
            accessToken = AuthorizeWebServiceCallout();
        }
        if(accessToken != NULL) {
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(sfSupport.URL__c+'/services/apexrest/recalApproval/'+volOppIsString);
            req.setMethod('POST');
            req.setBody('');
            req.setHeader('Authorization','OAuth '+accessToken);
            try {
                res = http.send(req);
                return NULL;
            } catch(Exception e) {
                System.debug('Callout Error:'+ e.getMessage());
                return 'Error while retriving records :'+e.getMessage();
            }
        } else {
            return 'No Access Token Retrived';
        }
    }  
}