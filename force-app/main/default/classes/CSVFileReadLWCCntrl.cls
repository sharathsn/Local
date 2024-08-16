public with sharing class CSVFileReadLWCCntrl {
    @AuraEnabled
    public static list<OCE__AccountPlan__c> csvFileRead(Id contentDocumentId){
        list<OCE__AccountPlan__c> accountPlanInsertList = new list<OCE__AccountPlan__c>();
        list<OCE__AccountPlan__c> accountPlanInsertList1 = new list<OCE__AccountPlan__c>();
        if(contentDocumentId != null) {
            
            // Fetch File Data based on the basic of document id 
            ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
            // split the file data
            list<String> csvRecordsList = contentVersionObj.VersionData.toString().split('\n');
            
            
            list<String> csvRowData1 = csvRecordsList[0].split(',');
            map<string,integer> csvRowDatamap = new map<string,integer>();
            integer count =0;
            for(string s : csvRowData1){
            csvRowDatamap.put(s,count);
            count++;
            }
              system.debug('csvRowDatamap=='+csvRowDatamap);
              set<String> uniqPlanName = new set<String>();
             for(Integer i = 1; i < csvRecordsList.size(); i++){
                OCE__AccountPlan__c accountPlan = new OCE__AccountPlan__c();
                list<String> csvRowData = csvRecordsList[i].split(',');
                if(csvRowDatamap.containskey('TLE Plan ID Plan Name')){
                accountPlan.OCE__UniqueIntegrationID__c = csvRowData[csvRowDatamap.get('TLE Plan ID Plan Name')]; // accName
                accountPlan.Name = csvRowData[csvRowDatamap.get('TLE Plan ID Plan Name')];
                uniqPlanName.add(accountPlan.Name);
                accountPlan.OCE__ApprovedStatus__c='Pending';
                accountPlan.OCE__Status__c='Defined';
                }
                if(csvRowDatamap.containskey('TerritoryID')){
                accountPlan.OCE__Territory__c = csvRowData[csvRowDatamap.get('TerritoryID')];
                }
                if(csvRowDatamap.containskey('Plan Source')){
                accountPlan.OCE__Description__c = csvRowData[csvRowDatamap.get('Plan Source')];
                }
                if(csvRowDatamap.containskey('Country/Affiliate')){
                accountPlan.OCE__ContactCountryRef__c = csvRowData[csvRowDatamap.get('Country/Affiliate')];
                }
                if(csvRowDatamap.containskey('Start Time')){
                    accountPlan.OCE__StartDate__c= Date.valueof(csvRowData[csvRowDatamap.get('Start Time')]);
                }
                if(csvRowDatamap.containskey('End Time')){
                accountPlan.OCE__EndDate__c =  Date.valueof(csvRowData[csvRowDatamap.get('End Time')]);
                }
                accountPlanInsertList.add(accountPlan);
            }
            set<String> planName = new set<string>();
            for(OCE__AccountPlan__c accplan : accountPlanInsertList){
                if(!planName.contains(accplan.Name)){
                    accountPlanInsertList1.add(accplan);
                    planName.add(accplan.Name);
                } 
            }
            try{    
                if(!accountPlanInsertList1.isEmpty()) {
                    upsert accountPlanInsertList1 OCE__AccountPlan__c.OCE__UniqueIntegrationID__c;
                }
                list<OCE__AccountPlan__c> accountPlanInsertList2 = [select Id,Name from OCE__AccountPlan__c where Name=:uniqPlanName];
                // add account objectives 
                system.debug('accountPlanInsertList2='+accountPlanInsertList2);
                map<string,Id> accplanIDMap = new map<string,Id>();

                for(OCE__AccountPlan__c accpln1 : accountPlanInsertList2){
                    accplanIDMap.put(accpln1.Name,accpln1.Id);
                }
                list<OCE__AccountObjective__c> accObjectiveList = new list<OCE__AccountObjective__c>();
                list<OCE__AccountObjective__c> accObjectiveList1 = new list<OCE__AccountObjective__c>();
            for(Integer i = 1; i < csvRecordsList.size(); i++){
                OCE__AccountObjective__c accObj = new OCE__AccountObjective__c();
                list<String> csvRowData = csvRecordsList[i].split(',');
                string planname1 = csvRowData[csvRowDatamap.get('TLE Plan ID Plan Name')];
                if(csvRowDatamap.containskey('Business Need')){
                accObj.OCE__UniqueIntegrationID__c = csvRowData[csvRowDatamap.get('Business Need')]; // accName              
                accObj.Name = csvRowData[csvRowDatamap.get('Business Need')];
                accObj.OCE__AccountPlan__c = accplanIDMap.get(planname1);
                }
                if(csvRowDatamap.containskey('Business Unit')){
                accObj.OCE__Description__c = csvRowData[csvRowDatamap.get('Business Unit')];
                }
                if(csvRowDatamap.containskey('Plan Therapeutic Area')){
                accObj.OCE__Target__c = csvRowData[csvRowDatamap.get('Plan Source')];
                }
                
                accObjectiveList.add(accObj);
            }
           system.debug('accObjectiveList=='+accObjectiveList);    
                
                //insert accObjectiveList;
              set<String> objName = new set<string>();
              set<String> uniqobjName = new set<string>();
              for(OCE__AccountObjective__c accobj1 : accObjectiveList){
                if(!objName.contains(accobj1.Name)){
                    accObjectiveList1.add(accobj1);
                    objName.add(accobj1.Name);
                    uniqobjName.add(accobj1.OCE__UniqueIntegrationID__c);
                } 
            }
            upsert accObjectiveList1 OCE__AccountObjective__c.OCE__UniqueIntegrationID__c;
            
            list<OCE__AccountObjective__c> accObjectiveList2 = new list<OCE__AccountObjective__c>();
            accObjectiveList2 =[select Id,Name from OCE__AccountObjective__c where OCE__UniqueIntegrationID__c=:uniqobjName];
            
            system.debug('accObjectiveList1=='+accObjectiveList1);
            
            system.debug('csvRowDatamap=='+csvRowDatamap);
    
                // add tactic
                 map<string,Id> tacticName = new map<string,Id>();

                for(OCE__AccountObjective__c acctac : accObjectiveList2){
                    tacticName.put(acctac.Name,acctac.Id);
                }
                list<OCE__AccountTactic__c> acctacticList = new list<OCE__AccountTactic__c>();
                list<OCE__AccountTactic__c> acctacticList1 = new list<OCE__AccountTactic__c>();
                for(Integer i = 1; i < csvRecordsList.size(); i++){
                OCE__AccountTactic__c acctactic = new OCE__AccountTactic__c();
                list<String> csvRowData = csvRecordsList[i].split(',');
                if(csvRowDatamap.containskey('Activity Name')){
                acctactic.OCE__UniqueIntegrationID1__c = csvRowData[csvRowDatamap.get('Activity Name')]; // accName              
                acctactic.Name = csvRowData[csvRowDatamap.get('Activity Name')];
                acctactic.OCE__AccountObjective__c = tacticName.get(csvRowData[csvRowDatamap.get('Business Need')]);
                }
                if(csvRowDatamap.containskey('Activity Name (Local Language)')){
                acctactic.Lilly_Activity_Name_Local_Language__c = csvRowData[csvRowDatamap.get('Activity Name (Local Language)')]; 
                }
                if(csvRowDatamap.containskey('Contract Type')){
                acctactic.Lilly_Contract_Type__c = csvRowData[csvRowDatamap.get('Contract Type')]; 
                }
                if(csvRowDatamap.containskey('Maximum # of Contracted Participants')){
                acctactic.Lilly_Max_of_Contracted_Participants__c = Integer.valueOf(csvRowData[csvRowDatamap.get('Maximum # of Contracted Participants')]); 
                }
                if(csvRowDatamap.containskey('Activity Type')){
                acctactic.Lilly_Activity_Type__c = csvRowData[csvRowDatamap.get('Activity Type')]; 
                }
                if(csvRowDatamap.containskey('Meeting Type')){
                acctactic.Lilly_Meeting_Type__c = csvRowData[csvRowDatamap.get('Meeting Type')]; 
                }
                if(csvRowDatamap.containskey('Associated Congress')){
                acctactic.Lilly_Associated_Congress__c = csvRowData[csvRowDatamap.get('Associated Congress')]; 
                }
                if(csvRowDatamap.containskey('Forecasted # US Contracted HCPS')){
            
                acctactic.Lilly_Forecasted_US_Contracted_HCPs__c = Integer.valueOf(csvRowData[csvRowDatamap.get('Forecasted # US Contracted HCPS')]);
                }
                if(csvRowDatamap.containskey('Functional Owner')){
                acctactic.Lilly_Functional_Owner__c  = csvRowData[csvRowDatamap.get('Functional Owner')]; 
                }
                if(csvRowDatamap.containskey('Platform/Disease State Activity?')){
                acctactic.Lilly_Platform_Disease_State_Activity__c = csvRowData[csvRowDatamap.get('Platform/Disease State Activity?')]; 
                }
                if(csvRowDatamap.containskey('Primary Brand/Molecule')){
                acctactic.Lilly_Primary_Brand_Molecule__c = csvRowData[csvRowDatamap.get('Primary Brand/Molecule')]; 
                }
                if(csvRowDatamap.containskey('Primary Indication/Condition')){
                acctactic.Lilly_Primary_Indication_Condition__c = csvRowData[csvRowDatamap.get('Primary Indication/Condition')]; 
                }
                if(csvRowDatamap.containskey('TL Selection Criteria')){
                acctactic.Lilly_TL_Selection_Criteria__c = csvRowData[csvRowDatamap.get('TL Selection Criteria')]; 
                }
                if(csvRowDatamap.containskey('Sponsoring Organization')){
                acctactic.Lilly_Sponsoring_Organization__c = csvRowData[csvRowDatamap.get('Sponsoring Organization')]; 
                }
                if(csvRowDatamap.containskey('Sponsoring Country')){
                acctactic.Lilly_Sponsoring_Country__c = csvRowData[csvRowDatamap.get('Sponsoring Country')]; 
                }
                if(csvRowDatamap.containskey('Start Time')){
                acctactic.OCE__StartDate__c =  Date.valueof(csvRowData[csvRowDatamap.get('Start Time')]); 
                }
                if(csvRowDatamap.containskey('End Time')){
                acctactic.OCE__EndDate__c =  Date.valueof(csvRowData[csvRowDatamap.get('End Time')]); 
                }
                 if(csvRowDatamap.containskey('Activity Owner')){
                acctactic.Lilly_ActivityOwner__c = '005f20000079POG';//csvRowData[csvRowDatamap.get('Activity Owner')]; 
                }

                acctacticList.add(acctactic);
            }
              //insert acctactic;
              set<String> tacName = new set<string>();
              for(OCE__AccountTactic__c acctac1 : acctacticList){
                if(!tacName.contains(acctac1.Name)){
                    acctacticList1.add(acctac1);
                    tacName.add(acctac1.Name);
                } 
            }
              system.debug('test=='+acctacticList1);
              upsert acctacticList1 OCE__AccountTactic__c.OCE__UniqueIntegrationID1__c;
           // upsert acctacticList1;
            
           
                
            }
            catch (Exception ex) {
                system.debug('test=='+ex.getMessage());
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        return accountPlanInsertList1;    
    }

}