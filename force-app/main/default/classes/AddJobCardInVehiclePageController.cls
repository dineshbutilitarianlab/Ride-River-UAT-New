/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-13-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AddJobCardInVehiclePageController {
    @AuraEnabled(cacheable = true)
    public static wrapperForJobCards getVehicleDetails(String recordId){
        try {
            Vehicle v = [Select Id,Account__c,VehicleIdentificationNumber from Vehicle Where Id =: recordId LIMIT 1];
            Account a = [Select Id from Account Where Id=:v.Account__c LIMIT 1];
            Contact c = [Select Id,AccountId from Contact Where AccountId =:a.Id];

            wrapperForJobCards w = new wrapperForJobCards();
            w.VehicleId = v.Id;
            w.AccountIds=a.Id;
            w.ContactIds=c.Id;
            w.VIN=v.VehicleIdentificationNumber;

            return w;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class wrapperForJobCards{
        @AuraEnabled
        public Id VehicleId{get;set;}
        @AuraEnabled
        public Id AccountIds{get;set;}
        @AuraEnabled
        public Id ContactIds{get;set;}
        @AuraEnabled
        public String VIN{get;set;}
    }
    @AuraEnabled
    public static void createJobCard(String jobCardData){
        try {
            System.debug('jobCardData===>'+jobCardData);
            Map<String,Object> jobCardMap = (Map<String,Object>) JSON.deserializeUntyped(jobCardData);
            WorkOrder w = new WorkOrder();
            w.AccountId=(Id)jobCardMap.get('accId');
            w.ContactId=(Id)jobCardMap.get('conId');
            w.vehicle__c=(Id)jobCardMap.get('vehId');
            w.Odometer_Reading__c=(Decimal)jobCardMap.get('oRed');
            w.RR_Job_Type__c=(String)jobCardMap.get('jobType');

            insert w;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}