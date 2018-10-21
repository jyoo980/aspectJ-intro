public aspect MainAspect {

    pointcut foo_call(): call(* Main.*(*));

    before(): foo_call() {
        System.out.println("Before: " + thisJoinPoint);
    }

    after(): foo_call() {
        System.out.printf("After: " + thisJoinPoint);
    }
}
