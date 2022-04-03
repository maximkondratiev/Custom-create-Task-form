@isTest
public with sharing class CreateTaskFormControllerTest {
    @TestSetup
    static void makeData(){

        ID standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        ID adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User newUser = new User(
            FirstName = 'Doe',
            LastName = 'John',
            Alias = 'johndoe',
            Email = 'johndoe@test.email',
            Username = 'johndoe@test.user',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileId = standardProfileId,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true
            );
        insert newUser;

        User adminUser = new User(
            FirstName = 'Test',
            LastName = 'John',
            Alias = 'johntest',
            Email = 'johntest@test.email',
            Username = 'johntest@test.user',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileId = adminProfileId,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true
            );
        insert adminUser;

        Lead newLead = new Lead(
            Company = 'Test',
            LastName = 'Last Name',
            Status = 'Open'
            );
        insert newLead;
    }

    @isTest
    public static void testGetUsers() {
        List<User> receivedUsers;
        
        Test.startTest();
        receivedUsers = CreateTaskFormController.getUsers('Doe');
        Test.stopTest();

        System.assertEquals(1, receivedUsers.size());
    }

    @isTest
    public static void testCreateTask() {
        User admin = [SELECT ID From User WHERE Email = 'johntest@test.email' LIMIT 1];
        String userId = [SELECT ID FROM User WHERE Email = 'johndoe@test.email'LIMIT 1].Id;
        String leadId = [SELECT ID FROM Lead LIMIT 1].Id;
        String description ='Test';
        Date dueDate = System.today() + 5;
        String taskId;

        System.runAs(admin){
            Test.startTest();
            taskId = CreateTaskFormController.createTask(leadId, userId, description, dueDate);
            Test.stopTest();
        }
        System.assert(!String.isEmpty(taskId));
    }
}
