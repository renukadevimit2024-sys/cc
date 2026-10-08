import java.time.LocalDate;

class Bill {
    private final String billId;
    private final Customer customer;
    private final String billingCycle;
    private final double totalDue;
    private final LocalDate dueDate;

    public Bill(String billId, Customer customer, String billingCycle, double totalDue, LocalDate dueDate) {
        this.billId = billId;
        this.customer = customer;
        this.billingCycle = billingCycle;
        this.totalDue = totalDue;
        this.dueDate = dueDate;
    }

    @Override
    public String toString() {
        return String.format("Bill %s | %s | cycle %s | total due $%.2f | due date %s",
                billId, customer.getName(), billingCycle, totalDue, dueDate);
    }
}
