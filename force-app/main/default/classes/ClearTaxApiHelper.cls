/**
* @author Dinesh Baddawar
* @email dinesh.butilitarianlab@gmail.com
* @create date 2025-01-08 11:39:15
* @modify date 2025-01-08 11:39:15
* @desc [ClearTax All API Method whihc using for the API]
*/

public with sharing class ClearTaxApiHelper {
    
    private static ClearTax_Api_Details__c clearTaxDetails;
    static {
        clearTaxDetails = ClearTax_Api_Details__c.getInstance('ClearTax Api');
        if (clearTaxDetails == null) {
            System.debug('Custom setting "ClearTax Api" is not found.');
        }
    }
    
    // Method to get Access Token
    public static String getAccessToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(clearTaxDetails.BaseURL_AccessToken__c);
        request.setMethod('GET');
        request.setHeader('x-clear-client-secret', clearTaxDetails.Client_Secret__c);
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (responseMap.containsKey('access_token')) {
                    String accessToken = (String) responseMap.get('access_token');
                    System.debug('Access Token == > ' + accessToken);
                    return accessToken;
                } else {
                    System.debug('access_token not found in the response');
                    return null;
                }
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception Message == > ' + e.getMessage()+' && Line  === >'+e.getLineNumber());
            return null;
        }
    }
    
    // Method to Generate IRN & SignedQRCode 
    @AuraEnabled
    public static String generateEInvoice(String recordId) {
        String returnResponse;
        String attachmentId;
        Order orderRecord = [ SELECT Id, Name, AccountId, Dealer__c,Dealer__r.Company_GSTIN_name__c, TotalAmount,Is_IGST_on_Intrastate__c,OrderNumber  FROM Order WHERE Id = :recordId ];
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(clearTaxDetails.E_Invoice_Base_URL__c);
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Cleartax-Auth-Token', getAccessToken());
          //  request.setHeader('gstin', '29AAFCD5862R000'); // Seller GSTIN
            request.setHeader('gstin', orderRecord.Dealer__r.Company_GSTIN_name__c); // Seller GSTIN
            String payload = generatePayloadForIRN(recordId);
            System.debug('payload === >'+payload);
            request.setBody(payload);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Response == > ' + response.getBody());
                List<Object> responseList = (List<Object>) JSON.deserializeUntyped(response.getBody());
                if (!responseList.isEmpty()) {
                    Map<String, Object> firstItem = (Map<String, Object>) responseList[0];
                    if (firstItem.containsKey('govt_response')) {
                        Map<String, Object> govtResponse = (Map<String, Object>) firstItem.get('govt_response');
                        if (govtResponse.containsKey('Irn')) {
                            String IrnNumber = (String) govtResponse.get('Irn');
                            System.debug('IrnNumber == > ' + IrnNumber);
                        }
                        if (govtResponse.containsKey('SignedQRCode')) {
                            String signedQRCode = (String) govtResponse.get('SignedQRCode');
                            System.debug('SignedQRCode == > ' + signedQRCode);
                            attachmentId =   generateAndStoreQRCode(signedQRCode,recordId);
                            System.debug('attachmentId ## === >'+attachmentId);
                            return returnResponse = 'SUCCESS';
                        } else {
                            System.debug('SignedQRCode not found in govt_response.');
                            return returnResponse = 'SignedQRCode not found in govt_response.';
                        }
                    } else {
                        System.debug('govt_response not found in the first item.');
                        return returnResponse = 'govt_response not found in the first item.';
                    }
                } else {
                    System.debug('Response list is empty.');
                    return returnResponse = 'Response list is empty.';
                }
            } else {
                System.debug('Error = > ' + response.getStatusCode() + ' ' + response.getBody());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
            return returnResponse = 'Error :'+e.getMessage();
        }
        return null;
    }
    
    // Method to Cancel IRN (before 24 hours)
    public static HttpResponse cancelEInvoice(String irn, String cancellationReason, String cancellationRemark) {
        try{
            Map<String, String> result = new Map<String, String>();
            List<CancelRequest> requestBody = new List<CancelRequest>();
            CancelRequest cancelReq = new CancelRequest();
            cancelReq.irn = irn;
            cancelReq.CnlRsn = cancellationReason;
            cancelReq.CnlRem = cancellationRemark;
            requestBody.add(cancelReq);
            String jsonBody = JSON.serialize(requestBody);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(clearTaxDetails.Cancel_IRN_Base_URL__c);
            req.setMethod('PUT');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Cleartax-Auth-Token', getAccessToken());
            req.setHeader('gstin', '29AAFCD5862R000');
            req.setBody(jsonBody);
            req.setTimeout(120000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                Object responseObj = JSON.deserializeUntyped(res.getBody());
                if (responseObj instanceof List<Object>) {
                    List<Object> responseList = (List<Object>) responseObj;
                    if (!responseList.isEmpty() && responseList[0] instanceof Map<String, Object>) {
                        Map<String, Object> firstResponse = (Map<String, Object>) responseList[0];
                        result.put('document_status', (String) firstResponse.get('document_status'));
                        Map<String, Object> govtResponse = (Map<String, Object>) firstResponse.get('govt_response');
                        if (govtResponse != null) {
                            result.put('Success', (String) govtResponse.get('Success'));
                            result.put('AckNo', String.valueOf(govtResponse.get('AckNo')));
                            result.put('AckDt', (String) govtResponse.get('AckDt'));
                        }
                        System.debug('Result == > ' + result);
                    }
                }
            }else {
                System.debug('HTTP Error: Status Code = ' + res.getStatusCode() + ', Status = ' + res.getStatus());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    // Method to Get E-Invoice PDF using IRN
    public static HttpResponse downloadEInvoice(String irn, String templateId) {
        try{
            HttpResponse response;
            String endpoint =clearTaxDetails.E_Invoice_PDF_BaseURL__c + EncodingUtil.urlEncode(irn, 'UTF-8') + '&template=' + EncodingUtil.urlEncode(templateId, 'UTF-8');
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('X-Cleartax-Auth-Token', getAccessToken());
            request.setHeader('gstin', '29AAFCD5862R000');
            request.setHeader('Content-Type', 'application/pdf');
            request.setTimeout(120000);
            Http http = new Http();
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                Blob pdfContent = response.getBodyAsBlob();
                savePDFFile(pdfContent, irn);
            }else {
                System.debug('Error: HTTP Status Code == > ' + response.getStatusCode()+' && Error Response == > ' + response.getBody());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    private static void savePDFFile(Blob pdfContent, String irn) {
        try {
            Attachment attachment = new Attachment();
            attachment.ParentId = '001F800001DQGf1IAH'; // Associate the attachment with a record (e.g., Account, Case)
            attachment.Name = 'eInvoice_' + irn + '.pdf';
            attachment.Body = pdfContent;
            attachment.ContentType = 'application/pdf';
            insert attachment;
            System.debug('PDF saved successfully with attachment: ' + attachment.Id);
        } catch (Exception e) {
            System.debug('Error saving PDF: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String generateAndStoreQRCode(String data,String recordId) {
        Integer xsize = 170;
        Integer ysize = 170;
        String qrApiUrl = 'http://api.qrserver.com/v1/create-qr-code/?data=' + EncodingUtil.urlEncode(data, 'UTF-8') + '&size=' + ysize + 'x' + xsize + '&format=png';
        try {
            Order ord = [SELECT Id,OrderNumber,Is_QR_Generated__c FROM Order WHERE Id=:recordId LIMIT 1];
            System.debug('ord ##  == >'+ord);
            if(ord.Is_QR_Generated__c != true){ 
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(qrApiUrl);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                System.debug('response  == >'+response);
                if (response.getStatusCode() == 200) {
                    Blob qrCodeBlob = response.getBodyAsBlob();
                    System.debug('qrCodeBlob  == >'+qrCodeBlob);
                    Attachment attachment = new Attachment();
                    attachment.ParentId = recordId; 
                    attachment.Name = 'ON-'+String.valueOf(ord.OrderNumber)+'_QRCode ' +String.valueOf(system.now())+'.png';
                    attachment.Body = qrCodeBlob;
                    attachment.ContentType = 'png'; 
                    insert attachment;
                    System.debug('attachment  == >'+attachment);
                   // ord.Is_QR_Generated__c = true;
                    update ord;
                    System.debug('Updated ord  == >'+ord);
                   // genereteE_invoicePDF(recordId);
                    return attachment.Id;
                }
            }else{
                return 'QR Code Generated !';
            }
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    // OLD Code
    // @AuraEnabled
    // public static String generatePayloadForIRN(Id orderId) {
    //     List<Map<String, Object>> payloadList = new List<Map<String, Object>>();
        
    //     try {
    //         System.debug('orderId == >' + orderId);
    //         Order orderRecord = [ SELECT Id, Name, AccountId, Dealer__c, TotalAmount,  Is_IGST_on_Intrastate__c, OrderNumber  FROM Order WHERE Id = :orderId ];
    //         System.debug('orderRecord == >' + orderRecord);
    
    //         if (orderRecord != null) {
    //             Account buyer = [ SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode,   BillingState, Company_GSTIN_name__c, Phone, Email__c   FROM Account WHERE Id = :orderRecord.AccountId ];
    //             System.debug('buyer == >' + buyer);
    
    //             Account seller = [ SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode,  BillingState, Company_GSTIN_name__c, Phone, Email__c  FROM Account WHERE Id = :orderRecord.Dealer__c];
    //             System.debug('seller == >' + seller);
    
    //             List<OrderItem> orderItems = [ SELECT Product2.Name, Quantity, Product2.HSN_Code__c, UnitPrice   FROM OrderItem WHERE OrderId = :orderId ];
    //             System.debug('orderItems == >' + orderItems);
    
    //             Map<String, Object> transactionMap = new Map<String, Object>();
    //             transactionMap.put('Version', '1.1');
    
    //             // Transaction Details
    //             transactionMap.put('TranDtls', new Map<String, Object>{
    //                 'TaxSch' => 'GST',
    //                 'SupTyp' => 'B2B',
    //                 'RegRev' => 'N',
    //                 'EcmGstin' => null,
    //                 'IgstOnIntra' => orderRecord.Is_IGST_on_Intrastate__c ? 'Y' : 'N'
    //             });
    
    //             // Document Details
    //             Date today = System.today();
    //             String dayStr = today.day() < 10 ? '0' + String.valueOf(today.day()) : String.valueOf(today.day());
    //             String monthStr = today.month() < 10 ? '0' + String.valueOf(today.month()) : String.valueOf(today.month());

    //             String formattedDate = dayStr + '/' + monthStr + '/' + today.year();
    //             System.debug('data === > ' + formattedDate);

    //             transactionMap.put('DocDtls', new Map<String, Object>{
    //                 'Typ' => 'INV',
    //                 'No' => 'INR'+orderRecord.OrderNumber.substring(Math.max(0, orderRecord.OrderNumber.length() - 4)) + '/' + String.valueOf(System.today().year()),
    //                 'Dt' => formattedDate
    //             });
    
    //             // Seller Details
    //             transactionMap.put('SellerDtls', new Map<String, Object>{
    //                 'Gstin' => seller.Company_GSTIN_name__c,
    //                 'LglNm' => seller.Name,
    //                 'TrdNm' => seller.Name,
    //                 'Addr1' => seller.BillingStreet,
    //                 'Addr2' => '', // Assuming no second address is available
    //                 'Loc' => seller.BillingCity,
    //                 'Pin' => Integer.valueOf(seller.BillingPostalCode),
    //                 'Stcd' => '29', // Should be dynamically determined
    //                 'Ph' => seller.Phone,
    //                 'Em' => seller.Email__c
    //             });
    
    //             // Buyer Details
    //             transactionMap.put('BuyerDtls', new Map<String, Object>{
    //                 'Gstin' => buyer.Company_GSTIN_name__c,
    //                 'LglNm' => buyer.Name,
    //                 'TrdNm' => buyer.Name, 
    //                 'Pos' => '12', // Should be dynamically determined
    //                 'Addr1' => buyer.BillingStreet,
    //                 'Addr2' => '', // Assuming no second address is available
    //                 'Loc' => buyer.BillingCity,
    //                 'Pin' => Integer.valueOf(buyer.BillingPostalCode),
    //                 'Stcd' => '29', // Should be dynamically determined
    //                 'Ph' => buyer.Phone,
    //                 'Em' => buyer.Email__c
    //             });
    
    //             // Item List
    //             List<Map<String, Object>> itemList = new List<Map<String, Object>>();
    //             Integer slNo = 1;
    //             Decimal totalIgstAmt = 0;
    //             Decimal totalCesAmt = 0;
    //             Decimal totalStateCesAmt = 0;
    //             Decimal totalAmountOrderItem = 0;
    //             for (OrderItem item : orderItems) {
    //                 System.debug('item data == >'+item);
    //                 Decimal totAmt = item.Quantity * item.UnitPrice;
    //                 totalAmountOrderItem += totAmt;
    //                 Decimal discount = 0; 
    //                 Decimal preTaxVal = 1;
    //                 Decimal gstRate = 12.0;
    //                 System.debug('totAmt == >'+totAmt);
    //                 System.debug('gstRate === >'+gstRate);
    //                 Decimal igstAmt = totAmt * (gstRate / 100);
    //                 System.debug('igstAmt #1 == >'+igstAmt);
    //                 Decimal cesAmt = totAmt * (5 / 100);
    //                 Decimal stateCesAmt = totAmt * (12 / 100);
    
    //                 totalIgstAmt += igstAmt;
    //                 totalCesAmt += cesAmt;
    //                 totalStateCesAmt += stateCesAmt;
    
    //                 itemList.add(new Map<String, Object>{
    //                     'SlNo' => String.valueOf(slNo),
    //                     'PrdDesc' => item.Product2.Name,
    //                     'IsServc' => 'N',
    //                     'HsnCd' => item.Product2.HSN_Code__c,
    //                     'Barcde' => '123456',
    //                     'Qty' => item.Quantity,
    //                     'FreeQty' => 10,
    //                     'Unit' => 'BAG',
    //                     'UnitPrice' => item.UnitPrice,
    //                     'TotAmt' => totAmt,
    //                     'Discount' => discount,
    //                     'PreTaxVal' => preTaxVal,
    //                     'AssAmt' => totAmt,
    //                     'GstRt' => gstRate,
    //                     'IgstAmt' => igstAmt,
    //                     'CgstAmt' => 0,
    //                     'SgstAmt' => 0,
    //                     'CesRt' => 0,
    //                     'CesAmt' => 0,
    //                     'CesNonAdvlAmt' => 0,
    //                     'StateCesRt' => 0,
    //                     'StateCesAmt' => 0,
    //                     'StateCesNonAdvlAmt' => 0,
    //                     'OthChrg' => 0, // Corrected Other Charges
    //                     'TotItemVal' => totAmt + 0+igstAmt, // Updated Other Charges
    //                     'OrdLineRef' => '3256', 
    //                     'OrgCntry' => 'AG',
    //                     'PrdSlNo' => '12345'
    //                 });
    //                 slNo++;
    //             }
    //             transactionMap.put('ItemList', itemList);
                
    //             System.debug('totalAmountOrderItem == >'+totalAmountOrderItem);
    //             // Value Details
    //             transactionMap.put('ValDtls', new Map<String, Object>{
    //                 'AssVal' => totalAmountOrderItem,        //orderRecord.TotalAmount,
    //                 'CgstVal' => 0,
    //                 'SgstVal' => 0,
    //                 'IgstVal' => totalIgstAmt,
    //                 'CesVal' => totalCesAmt,
    //                 'StCesVal' => totalStateCesAmt,
    //                 'Discount' => 0,
    //                 'OthChrg' => 20,
    //                 'RndOffAmt' => 0.3,
    //                 'TotInvVal' => orderRecord.TotalAmount + 20,
    //                 'TotInvValFc' => orderRecord.TotalAmount + 20
    //             });
    
    //             // Wrap everything inside a "transaction" key
    //             Map<String, Object> wrapperMap = new Map<String, Object>();
    //             wrapperMap.put('transaction', transactionMap);
    //             // Add to list (ensuring correct format)
    //             payloadList.add(wrapperMap);
    //            // System.debug('Updated Payload JSON == >' + JSON.serialize(payloadList));
    //             return JSON.serialize(payloadList);
    //         } else {
    //             System.debug('No Order Record Found!');
    //         }
    //     } catch (Exception e) {
    //         System.debug('Error Message ==>' + e.getMessage() + ' && Error Line == >' + e.getLineNumber());
    //     }
    //     return null;
    // }

    @AuraEnabled
    public static String generatePayloadForIRN(Id orderId) {
        List<Map<String, Object>> payloadList = new List<Map<String, Object>>();

        try {
            System.debug('orderId == >' + orderId);
            Order orderRecord = [
                SELECT Id, Name, AccountId, Dealer__c, TotalAmount, Is_IGST_on_Intrastate__c, OrderNumber 
                FROM Order WHERE Id = :orderId
            ];
            System.debug('orderRecord == >' + orderRecord);

            if (orderRecord != null) {
                // Fetch Buyer Details
                Account buyer = [
                    SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, 
                        Company_GSTIN_name__c, Phone, Email__c 
                    FROM Account WHERE Id = :orderRecord.AccountId
                ];
                System.debug('buyer == >' + buyer);

                // Fetch Seller Details
                Account seller = [
                    SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, 
                        Company_GSTIN_name__c, Phone, Email__c 
                    FROM Account WHERE Id = :orderRecord.Dealer__c
                ];
                System.debug('seller == >' + seller);

                // Fetch Order Items
                List<OrderItem> orderItems = [
                    SELECT Product2.Name, Quantity, Product2.HSN_Code__c, UnitPrice 
                    FROM OrderItem WHERE OrderId = :orderId
                ];
                System.debug('orderItems == >' + orderItems);

                // Create Transaction Map
                Map<String, Object> transactionMap = new Map<String, Object>();
                transactionMap.put('Version', '1.1');

                // Transaction Details
                transactionMap.put('TranDtls', new Map<String, Object>{
                    'TaxSch' => 'GST',
                    'SupTyp' => 'B2B',
                    'RegRev' => 'N',
                    'EcmGstin' => null,
                    'IgstOnIntra' => orderRecord.Is_IGST_on_Intrastate__c ? 'Y' : 'N'
                });

                // Document Details
                Date today = System.today();
                String formattedDate = 
                    (today.day() < 10 ? '0' + String.valueOf(today.day()) : String.valueOf(today.day())) + '/' +
                    (today.month() < 10 ? '0' + String.valueOf(today.month()) : String.valueOf(today.month())) + '/' +
                    today.year();

                System.debug('Formatted Date === > ' + formattedDate);

                transactionMap.put('DocDtls', new Map<String, Object>{
                    'Typ' => 'INV',
                    'No' => 'INR' + orderRecord.OrderNumber.substring(Math.max(0, orderRecord.OrderNumber.length() - 4)) + 
                            '/' + String.valueOf(System.today().year()),
                    'Dt' => formattedDate
                });

                // Seller Details
                transactionMap.put('SellerDtls', new Map<String, Object>{
                    'Gstin' => seller.Company_GSTIN_name__c,
                    'LglNm' => seller.Name,
                    'TrdNm' => seller.Name,
                    'Addr1' => seller.BillingStreet,
                    'Addr2' => '', // Assuming no second address is available
                    'Loc' => seller.BillingCity,
                    'Pin' => Integer.valueOf(seller.BillingPostalCode),
                    'Stcd' => '29', // Should be dynamically determined
                    'Ph' => seller.Phone,
                    'Em' => seller.Email__c
                });

                // Buyer Details
                transactionMap.put('BuyerDtls', new Map<String, Object>{
                    'Gstin' => buyer.Company_GSTIN_name__c,
                    'LglNm' => buyer.Name,
                    'TrdNm' => buyer.Name,
                    'Pos' => '12', // Should be dynamically determined
                    'Addr1' => buyer.BillingStreet,
                    'Addr2' => '', // Assuming no second address is available
                    'Loc' => buyer.BillingCity,
                    'Pin' => Integer.valueOf(buyer.BillingPostalCode),
                    'Stcd' => '29', // Should be dynamically determined
                    'Ph' => buyer.Phone,
                    'Em' => buyer.Email__c
                });

                // Item List and Totals Calculation
                List<Map<String, Object>> itemList = new List<Map<String, Object>>();
                Integer slNo = 1;
                Decimal totalIgstAmt = 0;
                Decimal totalCesAmt = 0;
                Decimal totalStateCesAmt = 0;
                Decimal sumTotItemVal = 0;
                Decimal totalAmountOrderItem = 0;

                for (OrderItem item : orderItems) {
                    System.debug('Processing item == >'+item);

                    Decimal totAmt = item.Quantity * item.UnitPrice;
                    totalAmountOrderItem += totAmt;

                    Decimal discount = 0; 
                    Decimal preTaxVal = 1;
                    Decimal gstRate = 12.0;
                    Decimal igstAmt = totAmt * (gstRate / 100);
                    Decimal cesAmt = totAmt * (5 / 100);
                    Decimal stateCesAmt = totAmt * (12 / 100);

                    totalIgstAmt += igstAmt;
                    totalCesAmt += cesAmt;
                    totalStateCesAmt += stateCesAmt;

                    Decimal totItemVal = totAmt + igstAmt + 0 + 0 + 0; // Ensure all components are included
                    sumTotItemVal += totItemVal;

                    itemList.add(new Map<String, Object>{
                        'SlNo' => String.valueOf(slNo),
                        'PrdDesc' => item.Product2.Name,
                        'IsServc' => 'N',
                        'HsnCd' => item.Product2.HSN_Code__c,
                        'Barcde' => '123456',
                        'Qty' => item.Quantity,
                        'FreeQty' => 10,
                        'Unit' => 'BAG',
                        'UnitPrice' => item.UnitPrice,
                        'TotAmt' => totAmt,
                        'Discount' => discount,
                        'PreTaxVal' => preTaxVal,
                        'AssAmt' => totAmt,
                        'GstRt' => gstRate,
                        'IgstAmt' => igstAmt,
                        'CgstAmt' => 0,
                        'SgstAmt' => 0,
                        'CesRt' => 0,
                        'CesAmt' => 0,
                        'CesNonAdvlAmt' => 0,
                        'StateCesRt' => 0,
                        'StateCesAmt' => 0,
                        'StateCesNonAdvlAmt' => 0,
                        'OthChrg' => 0, // Ensure Other Charges are correctly handled
                        'TotItemVal' => totItemVal, // Corrected Total Item Value Calculation
                        'OrdLineRef' => '3256',
                        'OrgCntry' => 'AG',
                        'PrdSlNo' => '12345'
                    });

                    slNo++;
                }

                // Corrected Total Invoice Value Calculation
                Decimal totalInvoiceValue = sumTotItemVal - 0 + 20 + 0.3;

                transactionMap.put('ItemList', itemList);
                
                // Value Details
                transactionMap.put('ValDtls', new Map<String, Object>{
                    'AssVal' => totalAmountOrderItem,
                    'CgstVal' => 0,
                    'SgstVal' => 0,
                    'IgstVal' => totalIgstAmt,
                    'CesVal' => totalCesAmt,
                    'StCesVal' => totalStateCesAmt,
                    'Discount' => 0,
                    'OthChrg' => 20,
                    'RndOffAmt' => 0.3,
                    'TotInvVal' => totalInvoiceValue, // Corrected Total Invoice Value
                    'TotInvValFc' => totalInvoiceValue
                });

                // Wrap everything inside a "transaction" key
                Map<String, Object> wrapperMap = new Map<String, Object>();
                wrapperMap.put('transaction', transactionMap);
                payloadList.add(wrapperMap);
                return JSON.serialize(payloadList);
            }
        } catch (Exception e) {
            System.debug('Error Message ==>' + e.getMessage() + ' && Error Line == >' + e.getLineNumber());
        }
        return null;
    }

    public class CancelRequest {
        public String irn { get; set; }
        public String CnlRsn { get; set; }
        public String CnlRem { get; set; }
    }
            
    public static void fetchEWaybillPDF(String recordId) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api-sandbox.clear.in/einv/v2/eInvoice/ewaybill/print?format=PDF');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Cleartax-Auth-Token', getAccessToken());
            request.setHeader('gstin', '29AAFCD5862R000');
            request.setBody('{"ewb_numbers": [131010819484], "print_type": "BASIC"}');
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                Blob pdfBlob = response.getBodyAsBlob();
                saveEwayBillAttachment(pdfBlob, 'EWaybill.pdf', recordId);
            } else {
                System.debug('Error: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    private static void saveEwayBillAttachment(Blob pdfBlob, String fileName, Id parentRecordId) {
        if (parentRecordId == null) {
            System.debug('Error: Parent Record ID is required to save attachment.');
            return;
        }
        Attachment attachment = new Attachment();
        attachment.Name = fileName;
        attachment.Body = pdfBlob;
        attachment.ParentId = parentRecordId;
        insert attachment;
        System.debug('PDF saved successfully as Attachment with ID: ' + attachment.Id);
    }
    
    // Method to Generate E-invoice PDF
    @AuraEnabled
    Public static string genereteE_invoicePDF(String recordId){
        String response;
        try{
            if(recordId != null){
                Order ord = [SELECT Id,OrderNumber,Is_QR_Generated__c FROM Order WHERE Id=:recordId LIMIT 1];
                PageReference vfPagepdf = page.CreateReceiptVehicle;
                vfPagepdf.getParameters().put('id',recordId);
                Blob pdfBlob;
                if(Test.isRunningTest()){
                    pdfBlob = Blob.valueOf('Test');
                    }else{
                     pdfBlob = vfPagepdf.getContentAsPDF();
                    }
                Attachment attachment = new Attachment();
                attachment.ParentId = recordId;
                attachment.Name = 'E-invoice-'+ord.OrderNumber+'-'+Date.Today().Format()+'.pdf';
                attachment.Body = pdfBlob;
                attachment.ContentType = 'application/pdf';
                insert attachment;
                System.debug('E-invoice === >'+attachment);
                if(attachment != null){
                    ord.Is_QR_Generated__c = true;
                    update ord;
                    response = 'success';
                }
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
            response = e.getMessage();
        }
        System.debug('response == >'+response);
        return response;
    }
    
}