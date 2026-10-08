import java.util.ArrayList;
import java.util.List;

/** Payment Processing + Transaction modules: validate -> fraud check -> authorize -> capture -> record. */
class PaymentService {
    private final PaymentGateway gateway;
    private final FraudDetector fraudDetector = new FraudDetector();
    private final List<Transaction> transactions = new ArrayList<>();
    private final List<Payment> payments = new ArrayList<>();
    private int txnSeq = 1000;
    private int paySeq = 5000;

    public PaymentService(PaymentGateway gateway) { this.gateway = gateway; }

    public Transaction process(CreditCard card, Merchant merchant, double amount) {
        Transaction t = new Transaction("T" + (++txnSeq), card, merchant, amount);
        t.initiate();
        transactions.add(t);

        String error = card.validationError();
        if (error != null) {
            t.fail(error);
            return t;
        }

        t.setFlagged(fraudDetector.isSuspicious(t, transactions));

        String authCode = gateway.authorize(card, amount);
        if (authCode == null) {
            t.decline(gateway.getLastMessage());
            gateway.voidTransaction();
            return t;
        }
        if (!gateway.capture(card, amount)) {
            t.fail("Gateway error");
            return t;
        }

        t.setAuthCode(authCode);
        t.complete();
        payments.add(new Payment("P" + (++paySeq), t, "CREDIT_CARD", authCode));
        return t;
    }

    public List<Transaction> getTransactions() { return transactions; }
    public List<Payment> getPayments() { return payments; }
}
