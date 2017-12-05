public class TempQueueableTest implements Queueable {
// implements Queueable
    
    public void execute(QueueableContext context) {
            for(integer i = 0; i <= 60; i++){
                calcCommunityRollups();
            }
    }

    @future
    public static void calcCommunityRollups() {
        System.debug('This is for testing');
    }

}