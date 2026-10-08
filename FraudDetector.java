import java.time.LocalDateTime;
import java.util.List;

class FraudDetector {
    /** Simple rules: very large amount for the card, or 3+ payments on the card within a minute. */
    public boolean isSuspicious(Transaction current, List<Transaction> history) {
        CreditCard card = current.getCard();
        if (current.getAmount() > 0.4 * card.getCreditLimit()) return true;

        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(1);
        int recent = 0;
        for (Transaction t : history) {
            if (t != current && t.getCard() == card && t.getTimestamp().isAfter(cutoff)) recent++;
        }
        return recent >= 3;
    }
}
