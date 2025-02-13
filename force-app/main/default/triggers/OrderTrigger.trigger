/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
Trigger OrderTrigger on Order (before insert, after update, after insert, before update) {
    // OrderCounter__c counterSetting = OrderCounter__c.getInstance('Count');
    // if (counterSetting != null) {
    //     Decimal baseCounter = counterSetting.Counter__c;
    //     Decimal counter = baseCounter;
    //     Set<Id> accountIds = new Set<Id>();
    //     for (Order ord : Trigger.new) {
    //         accountIds.add(ord.AccountId);
    //     }
    //     Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, AccountSource, Center_Code__c FROM Account WHERE Id IN :accountIds]);
    //     for (Order ord : Trigger.new) {
    //         Account acc = accounts.get(ord.AccountId);
    //         System.debug('AccountSource: ' + acc.AccountSource);
    //         if (acc.AccountSource != 'River Website') {
    //             System.debug('Counter before increment: ' + counter);
    //             counter++;
    //             System.debug('Counter after increment: ' + counter);
    //             String paddedCounter = String.valueOf(Integer.valueOf(counter));
    //             while (paddedCounter.length() < 5) {
    //                 paddedCounter = '0' + paddedCounter;
    //             }
    //             Account account = [SELECT Id, Center_Code__c FROM Account WHERE Id = :ord.Dealer__c];
    //             String centerCode = account.Center_Code__c;
    //             ord.Website_Order_Id__c = 'SB' + centerCode + DateTime.now().format('MMYYYY') + paddedCounter;
    //             System.debug('Website_Order_Id__c: ' + ord.Website_Order_Id__c);
    //         }
    //     }
    //     counterSetting.Counter__c = counter;
    //     update counterSetting;
    // } else {
    //     System.debug('OrderCounter__c custom setting is not initialized');
    // }

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        System.debug('Inside Order Insert or Updadte Trigger');
        OrderTriggerHandler.maintainOrderCounter(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('Inside Orderrrrrrrrr Updadte Trigger');
       
        OrderTriggerHandler.handleOrderUpdate(Trigger.new, Trigger.oldMap);
        OrderTriggerHandler.createProductTransferForBackOrder(Trigger.oldMap, Trigger.newMap);
        OrderTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        //OrderTriggerHandler.sendWhatsAppAfterOrderCreation(Trigger.new);
        

    }
    if(Trigger.isAfter && Trigger.isInsert){
        OrderTriggerHandler.sendWhatsAppAfterOrderCreation(Trigger.new);
    }
}