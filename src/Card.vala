namespace ElementaryAccount {
    public class Card : GLib.Object {
        public string last_four { get; construct; }
        public string brand { get; construct; }
        public int exp_month { get; construct; }
        public int exp_year { get; construct; }
        public string stripe_id { get; construct; }

        public AccountManager account { get; construct; }

        public class Card (string brand, string last_four, int exp_month, int exp_year, string stripe_id, AccountManager account) {
            Object (
                brand: brand,
                last_four: last_four,
                exp_month: exp_month,
                exp_year: exp_year,
                stripe_id: stripe_id,
                account: account
            );
        }

        public void delete () {
            account.delete_card (this);
        }
    }
}
