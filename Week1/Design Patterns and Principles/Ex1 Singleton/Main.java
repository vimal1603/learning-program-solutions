
class Main{
    public static void main(String args[]){
        Logger instance1=Logger.getInstance();
        Logger instance2=Logger.getInstance();
        if(instance1==instance2){
            System.out.println("Singleton done");
        }
    }
}
class Logger{
    private static Logger instance;
    private Logger(){
        System.out.println("Singleton is Initiated");
    }
    public static Logger getInstance(){
        if(instance==null){
            instance=new Logger();
        }
        return instance;
    }
}