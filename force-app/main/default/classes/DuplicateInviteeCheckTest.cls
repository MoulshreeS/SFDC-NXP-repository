@isTest
private class DuplicateInviteeCheckTest {
    static testMethod void validateDuplicateInviteeCheck(){
        Integer NoOfUsers=5;
        List<Project_Team__c> tempUsers=new List<Project_Team__c>();
        List<List<Project_Team__c>> temp=new List<List<Project_Team__c>>();
        
        Project_Team__c prjMember1=new Project_Team__c(First_Name__c='member1',Last_Name__c='b',Email_Address__c='member1@tcs.com',Company__c='tcs');
        Project_Team__c prjMember2=new Project_Team__c(First_Name__c='member2',Last_Name__c='b',Email_Address__c='member2@tcs.com',Company__c='tcs');
        Project_Team__c prjMember3=new Project_Team__c(First_Name__c='member3',Last_Name__c='b',Email_Address__c='member1@tcs.com',Company__c='tcs');

        	tempUsers.add(prjMember1);
            tempUsers.add(prjMember2);
            tempUsers.add(prjMember3);
        	temp.add(tempUsers); 

     
        
        Test.startTest();
		DuplicateInviteeCheck.getUserInfo(temp);
 		Test.stopTest();
        
    }

}