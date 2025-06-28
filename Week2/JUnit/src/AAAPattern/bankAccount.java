package AAAPattern;

public class bankAccount {
	private int balance;

    public bankAccount(int initialBalance) {
        this.balance = initialBalance;
    }

    public void deposit(int amount) {
        if (amount > 0)
            balance += amount;
    }

    public void withdraw(int amount) {
        if (amount > 0 && amount <= balance)
            balance -= amount;
    }

    public int getBalance() {
        return balance;
    }
}
