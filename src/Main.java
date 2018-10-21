public class Main {

    public static int foo() {
        System.out.println("Foo called");
        return 1;
    }

    public static void main(String[] args) {
        System.out.println("Main Called");
        foo();
    }
}
