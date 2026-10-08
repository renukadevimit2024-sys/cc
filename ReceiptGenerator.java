import java.time.format.DateTimeFormatter;

class ReceiptGenerator {
    public static String generate(Transaction t) {
        StringBuilder sb = new StringBuilder();
        sb.append("============ RECEIPT ============\n");
        sb.append(String.format("Transaction ID : %s%n", t.getTransactionId()));
        sb.append(String.format("Date / Time    : %s%n",
                t.getTimestamp().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))));
        sb.append(String.format("Merchant       : %s%n", t.getMerchant().getName()));
        sb.append(String.format("Card           : %s%n", t.getCard().getMasked()));
        sb.append(String.format("Amount         : $%.2f%n", t.getAmount()));
        sb.append(String.format("Auth Code      : %s%n", t.getAuthCode()));
        sb.append(String.format("Status         : %s%n", t.getStatus()));
        sb.append("=================================");
        return sb.toString();
    }
}
