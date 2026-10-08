import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

/** Report Module: transaction summary and billing. */
class ReportService {
    public static void printSummary(List<Transaction> txns) {
        int success = 0, declined = 0, failed = 0, flagged = 0;
        double total = 0;
        for (Transaction t : txns) {
            switch (t.getStatus()) {
                case "SUCCESS": success++; total += t.getAmount(); break;
                case "DECLINED": declined++; break;
                case "FAILED": failed++; break;
                default: break;
            }
            if (t.isFlagged()) flagged++;
        }
        System.out.println("Total transactions : " + txns.size());
        System.out.println("Successful         : " + success);
        System.out.println("Declined           : " + declined);
        System.out.println("Failed             : " + failed);
        System.out.println("Flagged suspicious : " + flagged);
        System.out.printf("Total processed    : $%.2f%n", total);
        System.out.printf("Average successful : $%.2f%n", success == 0 ? 0.0 : total / success);
    }

    public static Bill generateBill(Customer c, List<Transaction> txns, int seq) {
        double total = 0;
        for (Transaction t : txns) {
            if ("SUCCESS".equals(t.getStatus()) && t.getCard().getOwner() == c) total += t.getAmount();
        }
        return new Bill("B" + seq, c, YearMonth.now().toString(), total, LocalDate.now().plusDays(15));
    }
}
