public with sharing class CreateTaskFormController {

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers(String input){
        String searchString = '%' + input + '%';

        List<User> result = [SELECT ID, FirstName, LastName, Email 
                            FROM User 
                            WHERE LastName LIKE :searchString 
                            OR FirstName LIKE :searchString 
                            OR Email LIKE :searchString];

                            
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
            AccessType.READABLE,
            result
        );

        return securityDecision.getRecords();
    }

    @AuraEnabled
    public static String createTask(String leadId,String id, String description, Date dueDate){
        Task newTask = new Task(
            Subject = 'Other',
            Priority = 'Normal',
            OwnerId = Id,
            WhoId = leadId,
            Description = description,
            ActivityDate = dueDate
        );

        if (Schema.SObjectType.Task.isCreateable()) {
            insert newTask;
            return newTask.Id;
        }

        return null;
    }
}
