/**
* @author [Dinesh Baddawar]
* @email dinesh.b@utilitarianLab.com
* @create date 2024-07-18 13:30:49
* @modify date 2024-07-18 13:30:49
* @desc [This class is used to capture exception]
*/
public with sharing class ExceptionHelper {
    public static Exception_Log__c createExceptionLog(Exception expObj) {
        try {
            if (expObj != null) {
                Exception_Log__c exceptionLog = new Exception_Log__c();
                exceptionLog.Error_Message__c = String.valueOf(expObj.getMessage());
                exceptionLog.Error_Stack_Trace__c = String.valueOf(expObj.getStackTraceString());
                exceptionLog.Timestamp__c = DateTime.now();
                exceptionLog.Error_Line_No__c = Decimal.valueOf(expObj.getLineNumber());
                exceptionLog.Error_Type__c = String.valueOf(expObj.getTypeName());
                String tempObj = expObj.getStackTraceString();
                String[] stackTraceParts = tempObj.split(':')[0].split('\\.');
                if (stackTraceParts.size() > 1) {
                    exceptionLog.Class_Name__c = stackTraceParts[1];
                    exceptionLog.Method_Name__c = stackTraceParts[2];
                    exceptionLog.Developer_Name__c = [SELECT CreatedBy.Name FROM ApexClass WHERE Name =:stackTraceParts[1] LIMIT 1].CreatedBy.Name;
                }
                insert exceptionLog;
                System.debug('exceptionLog == >'+exceptionLog);
                return exceptionLog;
            }
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error: ' + e.getMessage() + ' AND Error Line No: ' + e.getLineNumber());
        }
        return null;
    }
}