/*==============================================
* Apex Class Name : BookList
* Version             : 1.0 
* Created Date        : 10 October 2016
* Function            : If Credit Collection Queue has more than 4 records, then send email notification queue members.
* Modification Log 
* Developer                   Date                    Description
* -----------------------------------------------------------------------------------------------------------
* Krishna Bogavelli           10/Oct/2016            Initial version
-------------------------------------------------------------------------------------------------------------
=================================================*/
@isTest
public class TestDataHelper {
 
    Public Static List<account> createWhareHouseAccts(){ 
        id WhareRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId(); 
        List<Account> WhareHouseAcct = new List<Account>();
        //created 24 Book wharehouse Accounts
        for (Integer i=0; i<24; i++){ 
            WhareHouseAcct.add(new Account(Name = 'Warehouse'+i,RecordTypeId =WhareRecTypeId, Type= 'Warehouse'));
        }
        Insert WhareHouseAcct;
        List<Account> returnAcctRecs = [select id,Name,RecordTypeId,Type from Account];
        return returnAcctRecs;
    }
 //===================================================================================================================================//   
    Public Static List<account> createbookSellerAccts(){ 
        id BookSellRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Book Seller').getRecordTypeId(); 
        List<Account> bookSellerAcct = new List<Account>();
        //created  202 Book Seller Accounts 
        for (Integer i=0; i<202; i++){  
            bookSellerAcct.add(new Account(Name = 'Book Seller Store'+i,RecordTypeId =BookSellRecTypeId, Type= 'Book Seller'  ));
        }
        Insert bookSellerAcct; 
        
        List<Account> returnAcctRecs = [select id,Name,RecordTypeId,Type from Account];
     return returnAcctRecs;
    }
     
//====================================================================================================================================//
    Public Static List<product2> CreateBooks(){
        createbookSellerAccts(); createWhareHouseAccts();
        
        List<Account> getBookSellerAcct = new List<Account>(createbookSellerAccts());// [select id from account where type ='Book Seller'];
        List<Account> getWhareHouseAcct = new List<Account>(createWhareHouseAccts());//[select id from account where type ='Warehouse'];
    
        List<Product2> BookSellerBooks = new List<Product2>();
        List<Product2> WhareHouseBooks = new List<Product2>();
    
        Integer count = 0;
        for (Integer i=0;i<300;i++){
            //Inventory Record
            system.assertNotEquals(getWhareHouseAcct[2].Id,Null);
             WhareHouseBooks.add(new Product2(name = 'Book_'+i,Family = 'Inventory',IsActive=True,Inventory__c = 100,Account__c = getWhareHouseAcct[2].Id ));
            if(i<30){system.assertNotEquals(getWhareHouseAcct[0].Id,Null);
               WhareHouseBooks.add(new Product2(name = 'Book_'+i,Family = 'Inventory',IsActive=True,Inventory__c = 100,Account__c = getWhareHouseAcct[0].Id ));		
            } else {
                 WhareHouseBooks.add(new Product2(name = 'Book_'+i,Family = 'Inventory',IsActive=True,Inventory__c = 100,Account__c = getWhareHouseAcct[1].Id ));
            }
    
            
            //Collection Records
            if(i==0){
              BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Collection',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[0].Id));	
            }
            //Paperback Records
            if(i>0 && i<40){
              if(i <30){
                 BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Paperback',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[0].Id ));		
              }else{
                 BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Paperback',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[1].Id ));		
              }  
            }
            //Hardcover Records
            if(i>=40 ){
                if(i>=60){
                    BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Hardcover',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[1].Id ));	
                }else {
                    BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Hardcover',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[0].Id ));	
                }
            }
                      
           
        }
        Insert BookSellerBooks; 
        Insert WhareHouseBooks;
            
        List<Product2> returnCreatedBooks = [Select id, Name, Family,IsActive,Current_Price__c,Account__c FROM Product2];
    return returnCreatedBooks;
    }
//========================================================================================================================================//
    Public Static List<Contact> createContacts(Integer numOfContacts, String userName){
        List<Account> getBookSellerAcct = new List<Account>(createbookSellerAccts());
        user userinfo = [select id from user where name =: userName]; /*'BWS Customer'*/
        List<Contact> lstCont = new List<Contact>();
        for (Integer i=0;i<numOfContacts;i++){ 
            lstCont.add(new Contact(LastName = 'TestOrderUser'+i, User__c = userinfo.id, AccountId = getBookSellerAcct[i].id ));
        }
        Insert lstCont;
        List<Contact> returnCreatedContactRecs = [select id,Name,User__c,AccountId from contact];
    return returnCreatedContactRecs;
    }
//========================================================================================================================================//
    Public Static Contact createContact(id accountID,id userNameID){
  
        user userinfo = [select id from user where name ='BWS Customer'];
         Contact  createContact =  new Contact(LastName = 'TestOrderUser', User__c = userinfo.id, AccountId = accountID );
  
        Insert createContact;
        Contact returnCreatedContactRecs = [select id,Name,User__c,AccountId from contact Limit 1];
    return returnCreatedContactRecs;
    }

//========================================================================================================================================//
    Public static Book_Order__c bookOrder(id contactID){ 
        
        Book_Order__c createBookOrder = new Book_Order__c(Name = 'order_2',Contact__c  = contactID);
        Insert createBookOrder;
        Book_Order__c returnBookOrder = [SELECT id,name,Contact__c,Contact__r.Accountid From Book_Order__c Limit 1];
        return returnBookOrder;
    }
    
    
}