/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 01-29-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ScheduleQueueableOnDayOfTestRide implements Schedulable {
    public void execute(SchedulableContext sc){
        DateTime currentTime = DateTime.now();
        DateTime endTime = currentTime.addHours(-4);  
        DateTime startTime = currentTime.addHours(-4).addMinutes(-29); 

        String templateName = 'on_day_of_test_ride';

        List<Id> tdIdsToProcess = new List<Id>();
        List<Id> leadIdsToFetch = new List<Id>();
        Map<Id,String> idToPhoneMap = new Map<Id,String>();

        List<Test_Drive__c> testDrivesToProcess = [SELECT Id, Test_Ride_Date__c, Test_Drive_Status__c,Lead__r.Phone__c FROM Test_Drive__c 
                                                  WHERE Test_Ride_Date__c >= :startTime AND 
                                                  Test_Ride_Date__c <= :endTime AND Test_Drive_Status__c = 'Scheduled'];
        for(Test_Drive__c t : testDrivesToProcess){
            tdIdsToProcess.add(t.Id);
            if(t.Lead__c != null && t.Lead__r.Phone__c != null){
                idToPhoneMap.put(t.Id,t.Lead__r.Phone__c);
            }
        }
        
        System.enqueueJob(new QueueableOnDayOfTestRide(tdIdsToProcess, templateName,idToPhoneMap));
        
    }
}