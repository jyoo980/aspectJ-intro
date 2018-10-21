# Intro to AspectJ

This serves as a ridiculously basic intro to the ideas of [Aspect-Oriented Programming](https://en.wikipedia.org/wiki/Aspect-oriented_programming), which was a programming paradigm developed by Gregor Kiczales at Xerox Parc. I use AspectJ, a superset of the Java programming language, beacuse of its extensive use in development and the familiarity that most software developers have with its syntax.

## Concrete Example

Consider the following code which is part of some class `ATM` for a banking application

```Java
public double makeWithdrawal(double amount) throws NotEnoughMoneyException {
    Log.info("Withdrawal attemping to be made");
    assert(amount > 0);
    try {
        if (this.cashReserve - amount >= 0) {
            this.cashReserve -= amount;
            return amount;
        } else {
            Log.error("Not enough cash in reserve");
            throw new NotEnoughMoneyException();
        }
    } catch (Exception err) {
        Log.error(err);
    }
}
```

If we look at what `makeWithdrawal` is doing, you might notice that it's really doing three things

1. Logging that a user has attempted to make a withdrawal
2. Checking the amount to withdraw is a positive number
3. Actually making the withdrawal
4. Logging that an error has been thrown when not enough money is in reserves

One may argue that the core logic of this method only relates to numbers 1 and 3 of the above, and they are right. `makeWithdrawal` should not be responsible for logging when a user is making a cash withdrawal or when an error occurs, but the general business logic of the system dictates this. There should be *some* logging in case of errors or other exceptional circumstances, and if you look at the system as a whole, there are likely cases where methods handle code which is *not* part of their core business logic. These are what we call **cross-cutting concerns** - the goal of AOP is to provide a mechanism for cleanly separating business logic from cross-cutting concerns, and it does with the idea of an **Aspect**.

This is the **Aspect** that we'll use to separate some of the logging behaviour of `makeWithdrawal` from its core concerns

```AspectJ
public aspect ATMAspect {

    pointcut executeWithdrawal: execution(double ATM.makeWithdrawal(*));

    before(): executeWithdrawal() {
        Log.info("Withdrawal attempting to be made");
    }    
}

public aspect ExceptionLoggerAspect {

    before (Exception e): handler(Exception+) && args(e) {
        System.err.println("Caught by aspect: " + e.toString());
        e.printStackTrace();
    }
}
```
Notice that each Aspect serves to encapsulate a cross-cutting concern which was prevalent in the system before. In the case of `ATMAspect`, we are able to capture the cross-cutting concerns which pollute the `ATM` class and remove them from the original class. The `ExceptionLoggerAspect` is now able to handle logic related to handling exceptional cases in our code without the need to have this code scattered throughout everywhere exceptions are thrown. This modularization leads to further decoupling of business logic and unrelated logic, and increases cohesion within each method. With the aspects above, `makeWithdrawal` is no longer responsible for logging each call to it, and some other logging behaviour.

```Java
public double makeWithdrawal(double amount) throws NotEnoughMoneyException {
    assert(amount > 0);
    try {
        if (this.cashReserve - amount >= 0) {
            this.cashReserve -= amount;
            return amount;
        } else {
            throw new NotEnoughMoneyException();
        }
    } catch (Exception err) {
        Log.error(err);
    }
}
```

We're now left with a method which isn't polluted with cross-cutting concerns.